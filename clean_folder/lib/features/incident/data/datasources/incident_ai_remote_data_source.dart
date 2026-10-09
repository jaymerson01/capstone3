import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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

/// Talks to the `geminiAssist` Cloud Function (functions/index.js).
///
/// The Gemini API key lives only on the server (Secret Manager). The app
/// sends the signed-in user's Firebase ID token plus the task; the server
/// builds the prompt, rate-limits per user and calls Gemini.
class IncidentAiRemoteDataSourceImpl implements IncidentAiRemoteDataSource {
  final http.Client client;

  /// Must match REGION in functions/index.js.
  static const String _functionsRegion = 'asia-southeast1';
  static const String _functionName = 'geminiAssist';

  IncidentAiRemoteDataSourceImpl({required this.client});

  Uri _functionUri() {
    final projectId = Firebase.app().options.projectId;
    return Uri.parse(
        'https://$_functionsRegion-$projectId.cloudfunctions.net/$_functionName');
  }

  /// Calls the callable function using the standard callable HTTPS protocol
  /// ({"data": ...} in, {"result": ...} out).
  Future<Map<String, dynamic>> _callAssist(
    Map<String, dynamic> data, {
    Duration timeout = const Duration(seconds: 25),
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw ServerException('Please sign in to use the AI assistant.');
    }

    try {
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
    } on TimeoutException {
      throw ServerException('AI request timed out.');
    } on FormatException catch (e) {
      throw ServerException('Failed to read AI response: ${e.message}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Could not reach the AI service: $e');
    }
  }

  @override
  Future<TriageResponseModel> analyzeIncidentNarrative(String narrative) async {
    final result = await _callAssist(
      {'task': 'triage', 'narrative': narrative},
      timeout: const Duration(seconds: 15),
    );
    return TriageResponseModel.fromJson(result);
  }

  @override
  Future<List<String>> generatePrecautionaryMeasures({
    required String category,
    required String narrative,
    String? location,
  }) async {
    final result = await _callAssist(
      {
        'task': 'precautions',
        'category': category,
        'narrative': narrative,
        'location': location,
      },
      timeout: const Duration(seconds: 15),
    );
    final measures = result['measures'];
    if (measures is List) {
      return measures
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
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
    final result = await _callAssist({
      'task': 'assistant',
      'message': userMessage,
      'history': recentHistory,
    });
    final reply = result['reply'];
    if (reply is String && reply.trim().isNotEmpty) {
      return reply.trim();
    }
    throw ServerException('The assistant returned an empty answer.');
  }
}
