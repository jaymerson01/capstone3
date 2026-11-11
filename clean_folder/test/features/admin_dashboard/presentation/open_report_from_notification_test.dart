import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/pages/incident_reports_page.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_event.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

class MockIncidentBloc extends MockBloc<IncidentEvent, IncidentState> implements IncidentBloc {}

final _report = IncidentEntity(
  id: 'ab3xk9ZqP0',
  reporterId: 'r1',
  description: 'Usok mula sa bahay sa kanto',
  category: 'Fire Incident',
  status: 'pending',
  timestamp: DateTime(2026, 11, 11, 9),
  latitude: 14.4851,
  longitude: 121.0116,
);

void main() {
  late MockIncidentBloc bloc;
  late int opened;

  setUp(() {
    bloc = MockIncidentBloc();
    opened = 0;
    when(() => bloc.state).thenReturn(IncidentLoaded([_report]));
  });

  Future<void> pumpPage(WidgetTester tester, String openId) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: BlocProvider<IncidentBloc>.value(
          value: bloc,
          child: IncidentReportsPage(openIncidentId: openId, onIncidentOpened: () => opened++),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets("a notification's report opens straight away", (tester) async {
    await pumpPage(tester, 'ab3xk9ZqP0');
    expect(opened, 1);
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.descendant(of: find.byType(Dialog), matching: find.textContaining('Usok mula sa bahay')), findsWidgets);
  });

  testWidgets('a report that no longer exists says so', (tester) async {
    await pumpPage(tester, 'deleted-report');
    expect(opened, 1);
    expect(find.text("That report isn't available anymore."), findsOneWidget);
  });
}
