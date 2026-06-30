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
}

class IncidentAiRemoteDataSourceImpl implements IncidentAiRemoteDataSource {
  final http.Client client;

  IncidentAiRemoteDataSourceImpl({required this.client});

  @override
  Future<TriageResponseModel> analyzeIncidentNarrative(String narrative) async {
    // Load API Key from environment (dotenv should be loaded in main.dart)
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    
    if (apiKey == null || apiKey.isEmpty) {
      throw ServerException('Gemini API Key not found in environment.');
    }

    // Using Gemini 1.5 Flash endpoint for fast JSON structured response
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey');

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
}
