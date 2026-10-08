import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

class IncidentAiRemoteDataSourceImpl implements IncidentAiRemoteDataSource {
  final http.Client client;
  static const String _model = 'gemini-3.5-flash';

  IncidentAiRemoteDataSourceImpl({required this.client});

  @override
  Future<TriageResponseModel> analyzeIncidentNarrative(String narrative) async {
    // Load API Key from environment (dotenv should be loaded in main.dart)
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    
    if (apiKey == null || apiKey.isEmpty) {
      throw ServerException('Gemini API Key not found in environment.');
    }

    // Using Gemini 3.5 Flash endpoint for fast JSON structured response
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$apiKey');

    final prompt = '''
You are an expert emergency response dispatcher for Barangay Moonwalk.
Evaluate the following incident narrative and determine the urgency of the situation.
You must reply ONLY in raw, valid JSON format without any markdown wrappers or additional text.
The JSON must have exactly two keys:
1. "urgency": strictly either "LOW", "MEDIUM", or "HIGH".
2. "justification": a brief 1-2 sentence explanation for the urgency level.

Narrative: "$narrative"
''';

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ],
      "generationConfig": {
        "responseMimeType": "application/json",
      }
    });

    try {
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        
        final String textResponse =
            decodedResponse['candidates'][0]['content']['parts'][0]['text'];
        
        // Clean markdown blocks if the model still includes them despite instructions
        final String cleanJson = textResponse
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        
        final Map<String, dynamic> jsonMap = jsonDecode(cleanJson);
        return TriageResponseModel.fromJson(jsonMap);
      } else {
        throw ServerException(
            'Failed to communicate with AI Engine. Status code: ${response.statusCode}');
      }
    } on TimeoutException {
      throw ServerException('Request to AI Engine timed out.');
    } on FormatException catch (e) {
      throw ServerException('Failed to parse JSON response from AI Engine: ${e.message}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('An unexpected error occurred during AI analysis: $e');
    }
  }

  @override
  Future<List<String>> generatePrecautionaryMeasures({
    required String category,
    required String narrative,
    String? location,
  }) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null ||
        apiKey.isEmpty ||
        apiKey.trim() == 'your_gemini_api_key_here') {
      throw ServerException('Gemini API Key not configured.');
    }

    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$apiKey');

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

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ],
      "generationConfig": {
        "responseMimeType": "application/json",
      }
    });

    try {
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        final String textResponse =
            decodedResponse['candidates'][0]['content']['parts'][0]['text'];

        final String cleanJson = textResponse
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();

        final dynamic parsed = jsonDecode(cleanJson);
        if (parsed is List) {
          return parsed.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
        } else if (parsed is Map && parsed.values.first is List) {
          return (parsed.values.first as List)
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }
        return [];
      } else {
        throw ServerException(
            'Failed to generate AI precautions. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw ServerException('AI safety precautions request timed out.');
    } on FormatException catch (e) {
      throw ServerException('Failed to parse AI response: ${e.message}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to generate precautionary measures: $e');
    }
  }

  @override
  Future<String> askCivilDefenseAssistant({
    required String userMessage,
    List<Map<String, String>> history = const [],
  }) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null ||
        apiKey.isEmpty ||
        apiKey.trim() == 'your_gemini_api_key_here') {
      throw ServerException('Gemini API Key not configured.');
    }

    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$apiKey');

    final systemInstructionText = '''
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

    // Add recent history for conversational continuity (up to last 6 messages)
    final recentHistory =
        history.length > 6 ? history.sublist(history.length - 6) : history;
    for (final item in recentHistory) {
      final role = item['role'] == 'user' ? 'user' : 'model';
      final text = item['text'] ?? '';
      if (text.isNotEmpty) {
        contents.add({
          "role": role,
          "parts": [
            {"text": text}
          ]
        });
      }
    }

    // Add current user query
    contents.add({
      "role": "user",
      "parts": [
        {"text": userMessage}
      ]
    });

    final body = jsonEncode({
      "systemInstruction": {
        "parts": [
          {"text": systemInstructionText}
        ]
      },
      "contents": contents,
      "generationConfig": {
        "temperature": 0.3,
        "maxOutputTokens": 2048,
        "thinkingConfig": {
          "thinkingBudget": 0
        }
      }
    });

    try {
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        final String textResponse =
            decodedResponse['candidates'][0]['content']['parts'][0]['text'];
        return textResponse.trim();
      } else {
        throw ServerException(
            'Failed to generate assistant response. Status: ${response.statusCode}');
      }
    } on TimeoutException {
      throw ServerException('Assistant request timed out.');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Failed to communicate with Civil Defense Assistant: $e');
    }
  }
}

