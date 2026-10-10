import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:community_safety_app/features/incident/data/models/triage_response_model.dart';

class ServerException implements Exception {
  final String message;
  ServerException([this.message = '']);

  @override
  String toString() => 'ServerException: $message';
}

abstract class IncidentAiRemoteDataSource {
  Future<TriageResponseModel> analyzeIncidentNarrative(String narrative);
  Future<List<String>> generatePrecautionaryMeasures({
    required String category,
    required String narrative,
    String? location,
  });
  Future<String> askCivilDefenseAssistant({
    required String userMessage,
    List<Map<String, String>> history,
  });
}

/// Smart Hybrid AI Remote Data Source:
///
/// 1. Primary: Calls the `geminiAssist` Cloud Function (functions/index.js) when deployed.
/// 2. Direct Fallback: If Cloud Function is offline, returns 404, or unauthenticated,
///    it seamlessly falls back to calling Gemini 3.5 Flash directly using GEMINI_API_KEY.
class IncidentAiRemoteDataSourceImpl implements IncidentAiRemoteDataSource {
  final http.Client client;

  /// Must match REGION in functions/index.js.
  static const String _functionsRegion = 'asia-southeast1';
  static const String _functionName = 'geminiAssist';

  /// Active direct Gemini model
  static const String _directModel = 'gemini-3.5-flash';

  IncidentAiRemoteDataSourceImpl({required this.client});

  Uri _functionUri() {
    final projectId = Firebase.app().options.projectId;
    return Uri.parse(
        'https://$_functionsRegion-$projectId.cloudfunctions.net/$_functionName');
  }

  /// Calls the callable function using the standard callable HTTPS protocol.
  Future<Map<String, dynamic>> _callAssist(
    Map<String, dynamic> data, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw ServerException('Please sign in to use the AI assistant.');
    }

    final idToken = await user.getIdToken();
    final response = await client
        .post(
          _functionUri(),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({'data': data}),
        )
        .timeout(timeout);

    final dynamic decoded =
        response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode == 200 &&
        decoded is Map &&
        decoded['result'] is Map) {
      return Map<String, dynamic>.from(decoded['result'] as Map);
    }

    final serverMessage = (decoded is Map && decoded['error'] is Map)
        ? (decoded['error']['message'] as String?)
        : null;
    throw ServerException(serverMessage ??
        'AI service error (status ${response.statusCode}).');
  }

  String _getApiKey() {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key != null && key.isNotEmpty && key != 'your_gemini_api_key_here') {
      return key.trim();
    }
    return '';
  }

  /// Direct Google Gemini Generative Language API call (Fallback)
  Future<String> _directGeminiPost({
    required List<Map<String, dynamic>> contents,
    String? systemInstruction,
    bool responseJson = false,
  }) async {
    final apiKey = _getApiKey();
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_directModel:generateContent?key=$apiKey');

    final Map<String, dynamic> bodyMap = {
      'contents': contents,
      'generationConfig': {
        'temperature': 0.3,
        'maxOutputTokens': 2048,
        if (responseJson) 'responseMimeType': 'application/json',
      },
    };

    if (systemInstruction != null) {
      bodyMap['systemInstruction'] = {
        'parts': [
          {'text': systemInstruction}
        ]
      };
    }

    final response = await client
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(bodyMap),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final text = decoded['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (text is String && text.trim().isNotEmpty) {
        return text.trim();
      }
      throw ServerException('Empty response received from AI model.');
    }
    throw ServerException('Gemini API returned status ${response.statusCode}');
  }

  @override
  Future<TriageResponseModel> analyzeIncidentNarrative(String narrative) async {
    try {
      final result = await _callAssist(
        {'task': 'triage', 'narrative': narrative},
        timeout: const Duration(seconds: 8),
      );
      return TriageResponseModel.fromJson(result);
    } catch (_) {
      // Direct API fallback
      final prompt = '''
You are an expert emergency response dispatcher for Barangay Moonwalk.
Analyze the following citizen emergency report narrative and provide accurate triage classification in JSON format.
Rules:
1. Category MUST be exactly one of: "Fire Emergency", "Medical Emergency", "Crime & Security", "Flood / Water Level", "Road Accident", "Infrastructure Damage", "Public Disturbance", "Hazardous Waste", "Animal Threat", "Other Emergency".
2. Urgency Level MUST be one of: "CRITICAL", "HIGH", "MEDIUM", "LOW".
3. Confidence score: double from 0.0 to 1.0.
4. Summary: Concise 1-sentence synopsis under 20 words.
5. Key Elements: 2-4 primary keywords or entities.

Narrative: "$narrative"

Output ONLY valid raw JSON with keys: category, urgencyLevel, confidenceScore, summary, keyElements.
''';

      final responseText = await _directGeminiPost(
        contents: [
          {
            'role': 'user',
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        responseJson: true,
      );

      final cleanJson = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final Map<String, dynamic> jsonMap = jsonDecode(cleanJson);
      return TriageResponseModel.fromJson(jsonMap);
    }
  }

  @override
  Future<List<String>> generatePrecautionaryMeasures({
    required String category,
    required String narrative,
    String? location,
  }) async {
    try {
      final result = await _callAssist(
        {
          'task': 'precautions',
          'category': category,
          'narrative': narrative,
          'location': location,
        },
        timeout: const Duration(seconds: 8),
      );
      final measures = result['measures'];
      if (measures is List) {
        return measures
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } catch (_) {}

    // Direct API fallback
    final prompt = '''
You are an expert civil defense and emergency safety officer for Barangay Moonwalk.
A resident has reported the following incident:
- Category: "$category"
- Details: "$narrative"
- Location: "${location ?? 'Barangay Moonwalk'}"

Generate 3 to 4 concise, immediate, life-safety precautionary actions or first-aid instructions that the resident must take RIGHT NOW while waiting for emergency responders to arrive.
Rules:
- Be clear, direct, and actionable.
- Prioritize life safety, evacuation if necessary, avoiding secondary hazards.
- Output ONLY a raw, valid JSON array of strings, e.g.:
["Evacuate the structure immediately and stay upwind.", "Turn off main power breaker if safe to do so.", "Do not use elevators or re-enter for belongings."]
- Do NOT include markdown code blocks, intro, or explanations. Return only the JSON array.
''';

    final text = await _directGeminiPost(
      contents: [
        {
          'role': 'user',
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      responseJson: true,
    );

    final cleanJson = text
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    final dynamic parsed = jsonDecode(cleanJson);
    if (parsed is List) {
      return parsed.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  @override
  Future<String> askCivilDefenseAssistant({
    required String userMessage,
    List<Map<String, String>> history = const [],
  }) async {
    final recentHistory =
        history.length > 6 ? history.sublist(history.length - 6) : history;

    try {
      final result = await _callAssist(
        {
          'task': 'assistant',
          'message': userMessage,
          'history': recentHistory,
        },
        timeout: const Duration(seconds: 8),
      );
      final reply = result['reply'];
      if (reply is String && reply.trim().isNotEmpty) {
        return reply.trim();
      }
    } catch (_) {}

    // Direct API fallback
    const systemInstructionText = '''
You are the ResQ Civil Defense Emergency & Safety Assistant for Barangay Moonwalk.
Your mission: Deliver immediate, life-saving civil defense, disaster preparedness, and first-aid instructions to residents during safety crises and everyday inquiries.

Core Directives:
1. Immediate Life Safety First: If the resident's query involves active fire, raging flood, armed violence, structural collapse, gas leaks, or severe medical trauma, FIRST instruct them to evacuate or seek safe cover, call 911 or the Barangay Moonwalk Emergency Desk, and protect life over property.
2. Step-by-Step Clarity: Provide concise, numbered, easy-to-read instructions (e.g. 1., 2., 3.). In an emergency, people cannot read long walls of text. Keep responses direct and actionable.
3. Localized to Barangay Moonwalk, Parañaque: Aware of local context (emergency hotlines: National 911, Philippine Red Cross 143, Barangay Moonwalk Emergency Desk 888-9999).
4. Language Adaptability: Respond fluently in English, Tagalog, or Taglish depending on the resident's phrasing.
5. Basic First-Aid: Provide recognized basic first-aid steps (e.g., direct pressure for bleeding, cool water for minor burns, recovery position for unconscious breathing victims). Never attempt speculative clinical diagnosis.
6. Clean Complete Output: Ensure the response is fully completed and not cut off. Use clean text formatting with simple numbers or bullet points.
''';

    final List<Map<String, dynamic>> contents = [];
    for (final item in recentHistory) {
      final role = item['role'] == 'user' ? 'user' : 'model';
      final text = item['text'] ?? '';
      if (text.isNotEmpty) {
        contents.add({
          'role': role,
          'parts': [
            {'text': text}
          ]
        });
      }
    }

    contents.add({
      'role': 'user',
      'parts': [
        {'text': userMessage}
      ]
    });

    final reply = await _directGeminiPost(
      contents: contents,
      systemInstruction: systemInstructionText,
    );
    if (reply.isNotEmpty) {
      return reply;
    }
    throw ServerException('The assistant returned an empty answer.');
  }
}
