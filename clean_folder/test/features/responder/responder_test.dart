import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:community_safety_app/core/utils/departments.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/incident/data/models/incident_model.dart';
import 'package:community_safety_app/features/responder/data/responder_repository.dart';
import 'package:community_safety_app/features/responder/presentation/pages/responder_home_page.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

class MockResponderRepository extends Mock implements ResponderRepository {}

IncidentModel report(
  String id,
  String category, {
  String status = 'pending',
  String? assignedTo,
  List<String>? departments,
}) =>
    IncidentModel(
      id: id,
      reporterId: 'resident_1',
      description: 'May insidente',
      category: category,
      status: status,
      timestamp: DateTime(2026, 11, 11, 9),
      latitude: 14.4851,
      longitude: 121.0116,
      assignedResponderId: assignedTo,
      assignedResponderName: assignedTo == null ? null : 'Tanod $assignedTo',
      departmentIds: departments,
    );

void main() {
  group('routing', () {
    test('reports go to departments by type', () {
      expect(Department.forCategory('Fire Incident'), [Department.bfp, Department.tanod]);
      expect(Department.forCategory('Medical Emergency'), [Department.health]);
      expect(Department.forCategory('Theft / Robbery'), [Department.pnp, Department.tanod]);
      expect(Department.forCategory('Noise Complaint'), [Department.tanod]);
      expect(Department.forCategory('Other Emergency (gas leak)'), [Department.tanod]);
    });

    test("an admin's choice replaces the default", () {
      expect(report('a', 'Fire Incident').departments, [Department.bfp, Department.tanod]);
      expect(report('a', 'Fire Incident', departments: ['health']).departments, [Department.health]);
    });
  });

  test("a responder sees their department's open reports and their own", () {
    final all = [
      report('fire_open', 'Fire Incident'),
      report('theft_open', 'Theft / Robbery'),
      report('fire_mine_done', 'Fire Incident', status: 'resolved', assignedTo: 'me'),
      report('fire_other_done', 'Fire Incident', status: 'resolved', assignedTo: 'someone'),
      report('medical_moved_to_bfp', 'Medical Emergency', departments: ['bfp']),
    ];
    final seen = ResponderRepository.reportsFor(all, Department.bfp, 'me').map((r) => r.id);
    expect(seen, unorderedEquals(['fire_open', 'fire_mine_done', 'medical_moved_to_bfp']));
  });

  testWidgets('the portal home sorts reports into the three tabs', (tester) async {
    final repository = MockResponderRepository();
    when(() => repository.streamReports(Department.bfp, 'me')).thenAnswer((_) => Stream.value([
          report('mine', 'Fire Incident', status: 'in_progress', assignedTo: 'me'),
          report('open', 'Fire Incident'),
          report('done', 'Fire Incident', status: 'resolved', assignedTo: 'me'),
        ]));
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ResponderHomePage(
        user: const UserEntity(id: 'me', email: 'bfp1@resq.ph', displayName: 'FO1 Cruz', role: 'responder', department: 'bfp'),
        repository: repository,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('ResQ Responder · Fire (BFP)'), findsOneWidget);
    expect(find.text('Assigned to me (1)'), findsOneWidget);
    expect(find.text('Department queue (1)'), findsOneWidget);
    expect(find.text('Done (1)'), findsOneWidget);
    expect(find.text('Accepted'), findsOneWidget);

    await tester.tap(find.text('Department queue (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Waiting for a responder'), findsOneWidget);
  });
}
