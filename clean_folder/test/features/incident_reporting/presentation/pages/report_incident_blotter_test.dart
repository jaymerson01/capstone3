import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_event.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/report_incident_page.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockIncidentBloc extends MockBloc<IncidentEvent, IncidentState>
    implements IncidentBloc {}

void main() {
  late MockAuthBloc authBloc;
  late MockIncidentBloc incidentBloc;

  const blotterTitle = 'Record in the Barangay Blotter';
  final blotterSwitch = find.byKey(const Key('reportBlotterSwitch'));

  setUp(() {
    authBloc = MockAuthBloc();
    incidentBloc = MockIncidentBloc();
    when(() => authBloc.state).thenReturn(
      const Authenticated(UserEntity(id: 'resident_1', email: 'juan@example.com')),
    );
    when(() => incidentBloc.state).thenReturn(IncidentInitial());
  });

  Future<void> pumpReportPage(WidgetTester tester,
      {Locale locale = const Locale('en'),
      Size size = const Size(1080, 2400)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<IncidentBloc>.value(value: incidentBloc),
        ],
        child: MaterialApp(
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const ReportIncidentPage(),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> pickCategory(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.tap(find.text(label));
    await tester.pump();
  }

  testWidgets('the blotter toggle is hidden until a category is picked',
      (tester) async {
    await pumpReportPage(tester);
    expect(find.text(blotterTitle), findsNothing);
    expect(blotterSwitch, findsNothing);
  });

  for (final category in IncidentEntity.blotterCategories) {
    testWidgets('the blotter toggle shows for $category', (tester) async {
      await pumpReportPage(tester);
      await pickCategory(tester, category);
      expect(find.text(blotterTitle), findsOneWidget);
      expect(tester.widget<Switch>(blotterSwitch).value, isFalse);
    });
  }

  for (final category in const [
    'Fire Incident',
    'Medical Emergency',
    'Road Accident',
    'Flood / Calamity',
    'Other Emergency',
  ]) {
    testWidgets('the blotter toggle stays hidden for $category',
        (tester) async {
      await pumpReportPage(tester);
      await pickCategory(tester, category);
      expect(find.text(blotterTitle), findsNothing);
      expect(blotterSwitch, findsNothing);
    });
  }

  testWidgets('switching to a non-blotter category clears the choice',
      (tester) async {
    await pumpReportPage(tester);
    await pickCategory(tester, 'Theft / Robbery');
    await tester.ensureVisible(blotterSwitch);
    await tester.tap(blotterSwitch);
    await tester.pump();
    expect(tester.widget<Switch>(blotterSwitch).value, isTrue);

    await pickCategory(tester, 'Fire Incident');
    expect(blotterSwitch, findsNothing);

    await pickCategory(tester, 'Theft / Robbery');
    expect(tester.widget<Switch>(blotterSwitch).value, isFalse);
  });

  testWidgets('tapping the panel text also toggles it', (tester) async {
    await pumpReportPage(tester);
    await pickCategory(tester, 'Noise Complaint');
    await tester.ensureVisible(find.text(blotterTitle));
    await tester.tap(find.text(blotterTitle));
    await tester.pump();
    expect(tester.widget<Switch>(blotterSwitch).value, isTrue);
  });

  testWidgets('the blotter toggle is in Filipino', (tester) async {
    await pumpReportPage(tester, locale: const Locale('fil'));
    await pickCategory(tester, 'Karahasan / Away');
    expect(find.text('Itala sa Blotter ng Barangay'), findsOneWidget);
    expect(find.text(blotterTitle), findsNothing);
  });

  testWidgets('the blotter panel fits a 360dp phone in Filipino, large text',
      (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpReportPage(
      tester,
      locale: const Locale('fil'),
      size: const Size(360, 780),
    );
    await pickCategory(tester, 'Pagnanakaw / Holdap');
    await tester.ensureVisible(blotterSwitch);
    await tester.tap(blotterSwitch);
    await tester.pump();
    expect(tester.widget<Switch>(blotterSwitch).value, isTrue);
    expect(tester.takeException(), isNull);
  });

  test('only the five dispute and complaint categories qualify', () {
    expect(IncidentEntity.blotterCategories, const [
      'Violence / Physical Fight',
      'Theft / Robbery',
      'Noise Complaint',
      'Suspicious Activity',
      'Lost Item / Missing Person',
    ]);
    expect(IncidentEntity.isBlotterCategory('Fire Incident'), isFalse);
    expect(IncidentEntity.isBlotterCategory(null), isFalse);
    expect(
      IncidentEntity.isBlotterCategory('Other Emergency (Noise)'),
      isFalse,
    );
  });
}
