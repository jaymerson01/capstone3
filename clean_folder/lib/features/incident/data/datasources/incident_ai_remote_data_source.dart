import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:community_safety_app/features/incident/data/models/triage_response_model.dart';
import 'package:flutter/foundation.dart';

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

/// AI features (triage, safety tips, assistant chat) go only through the
/// `geminiAssist` Cloud Function (functions/index.js). The Gemini API key
/// lives on the server as a secret; the app never holds or sends it, and it
/// never calls Gemini directly. If the function can't be reached, the call
/// fails and the screens fall back to their built-in answers.
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

  @override
  Future<TriageResponseModel> analyzeIncidentNarrative(String narrative) async {
    final result = await _callAssist(
      {'task': 'triage', 'narrative': narrative},
      timeout: const Duration(seconds: 12),
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
      timeout: const Duration(seconds: 12),
    );
    final measures = result['measures'];
    if (measures is List) {
      return measures
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    throw ServerException('AI returned no safety tips.');
  }

  @override
  Future<String> askCivilDefenseAssistant({
    required String userMessage,
    List<Map<String, String>> history = const [],
  }) async {
    final result = await _callAssist(
      {
        'task': 'assistant',
        'message': userMessage,
        'history': assistantHistory(history),
      },
      timeout: const Duration(seconds: 15),
    );
    final reply = result['reply'];
    if (reply is String && reply.trim().isNotEmpty) {
      return reply.trim();
    }
    throw ServerException('The assistant returned an empty answer.');
  }

  /// The last [maxPairs] complete exchanges (a question, then the assistant's
  /// answer), oldest first. Unanswered questions and stray assistant turns are
  /// dropped, so Gemini always gets user/model turns in strict alternation;
  /// otherwise it may reject the request and the chat falls back to canned
  /// answers.
  @visibleForTesting
  static List<Map<String, String>> assistantHistory(
    List<Map<String, String>> history, {
    int maxPairs = 3,
  }) {
    final pairs = <List<Map<String, String>>>[];
    Map<String, String>? question;
    for (final item in history) {
      final text = (item['text'] ?? '').trim();
      if (text.isEmpty) continue;
      if (item['role'] == 'user') {
        question = {'role': 'user', 'text': text};
      } else if (question != null) {
        pairs.add([question, {'role': 'model', 'text': text}]);
        question = null;
      }
    }
    final recent = pairs.length > maxPairs ? pairs.sublist(pairs.length - maxPairs) : pairs;
    return [for (final pair in recent) ...pair];
  }
}
