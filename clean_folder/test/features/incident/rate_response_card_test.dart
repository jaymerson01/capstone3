import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/domain/repositories/incident_repository.dart';
import 'package:community_safety_app/features/incident/presentation/widgets/rate_response_card.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

class MockIncidentRepository extends Mock implements IncidentRepository {}

IncidentEntity resolved({int? rating, String? comment}) => IncidentEntity(
      id: 'inc_1',
      reporterId: 'r1',
      description: 'Nakaw na bisikleta',
      category: 'Theft / Robbery',
      status: 'resolved',
      timestamp: DateTime(2026, 11, 11, 8),
      latitude: 14.4851,
      longitude: 121.0116,
      rating: rating,
      ratingComment: comment,
    );

void main() {
  late MockIncidentRepository repository;

  setUp(() => repository = MockIncidentRepository());

  Future<void> pumpCard(WidgetTester tester, IncidentEntity incident) async {
    await tester.binding.setSurfaceSize(const Size(500, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('fil'),
      home: Scaffold(body: SingleChildScrollView(child: RateResponseCard(incident: incident, repository: repository))),
    ));
  }

  testWidgets('the reporter picks stars, comments and sends once', (tester) async {
    when(() => repository.rateIncident(any(), any(), comment: any(named: 'comment'))).thenAnswer((_) async {});
    await pumpCard(tester, resolved());

    expect(find.text('I-rate ang aksyon ng barangay'), findsOneWidget);
    expect(find.text('Ipadala ang rating'), findsNothing, reason: 'appears once a star is chosen');

    await tester.tap(find.byKey(const Key('rate-star-4')));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Mabilis dumating ang tanod');
    await tester.tap(find.text('Ipadala ang rating'));
    await tester.pumpAndSettle();

    verify(() => repository.rateIncident('inc_1', 4, comment: 'Mabilis dumating ang tanod')).called(1);
    expect(find.text('Ang rating mo'), findsOneWidget);
    expect(find.text('“Mabilis dumating ang tanod”'), findsOneWidget);
  });

  testWidgets('a report already rated shows the rating and cannot be rated again', (tester) async {
    await pumpCard(tester, resolved(rating: 3, comment: 'Medyo natagalan'));

    expect(find.text('Ang rating mo'), findsOneWidget);
    expect(find.text('“Medyo natagalan”'), findsOneWidget);
    await tester.tap(find.byKey(const Key('rate-star-5')));
    await tester.pump();
    verifyNever(() => repository.rateIncident(any(), any(), comment: any(named: 'comment')));
    expect(find.text('Ipadala ang rating'), findsNothing);
  });
}
