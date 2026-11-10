import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  test('Gemini gets each question once, in strict user/model alternation', () async {
    dotenv.loadFromString(envString: 'GEMINI_API_KEY=test-key');
    late Map<String, dynamic> sent;
    // Stands in for Gemini; nothing leaves the machine.
    final gemini = MockClient((request) async {
      sent = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({
          'candidates': [
            {
              'content': {
                'parts': [
                  {'text': 'Lumabas agad at tumawag sa 911.'}
                ]
              }
            }
          ]
        }),
        200,
      );
    });

    final reply = await IncidentAiRemoteDataSourceImpl(client: gemini).askCivilDefenseAssistant(
      userMessage: 'May sunog sa kapitbahay',
      history: [bot('Hello!'), user('Paano mag-report?'), bot('Tap Report Incident.')],
    );

    expect(reply, 'Lumabas agad at tumawag sa 911.');
    final turns = (sent['contents'] as List).cast<Map<String, dynamic>>();
    expect(turns.map((t) => t['role']), ['user', 'model', 'user']);
    expect(turns.last['parts'][0]['text'], 'May sunog sa kapitbahay');
    expect(sent['generationConfig']['thinkingConfig'], {'thinkingBudget': 0});
  });
}
