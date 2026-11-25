
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:community_safety_app/features/incident/data/datasources/incident_ai_remote_data_source.dart';

Map<String, String> user(String text) => {'role': 'user', 'text': text};
Map<String, String> bot(String text) => {'role': 'model', 'text': text};

void main() {
  group('assistantHistory', () {
    test('keeps complete question-and-answer pairs in order', () {
      final history = [user('Q1'), bot('A1'), user('Q2'), bot('A2')];
      expect(IncidentAiRemoteDataSourceImpl.assistantHistory(history), history);
    });

    test('drops the greeting, unanswered questions and empty turns', () {
      final history = [bot('Hello! I am your assistant'), user('Q1'), user('Q2'), bot(''), bot('A2'), user('Q3')];
      expect(IncidentAiRemoteDataSourceImpl.assistantHistory(history), [user('Q2'), bot('A2')]);
    });

    test('keeps only the last three exchanges', () {
      final history = [for (var i = 1; i <= 5; i++) ...[user('Q$i'), bot('A$i')]];
      expect(
        IncidentAiRemoteDataSourceImpl.assistantHistory(history),
        [user('Q3'), bot('A3'), user('Q4'), bot('A4'), user('Q5'), bot('A5')],
      );
    });
  });

  test('the app never calls Gemini directly (the API key stays on the server)', () async {
    final requested = <Uri>[];
    final network = MockClient((request) async {
      requested.add(request.url);
      return http.Response('{}', 500);
    });

    // No signed-in user / no Firebase here, so the Cloud Function can't be
    // used: the call must fail instead of going straight to Gemini.
    await expectLater(
      IncidentAiRemoteDataSourceImpl(client: network).askCivilDefenseAssistant(
        userMessage: 'May sunog sa kapitbahay',
        history: [bot('Hello!'), user('Paano mag-report?'), bot('Tap Report Incident.')],
      ),
      throwsA(anything),
    );
    expect(requested.where((u) => u.host.contains('generativelanguage')), isEmpty);
  });
}
