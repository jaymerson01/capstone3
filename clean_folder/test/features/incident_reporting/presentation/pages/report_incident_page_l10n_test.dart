import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
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

  setUp(() {
    authBloc = MockAuthBloc();
    incidentBloc = MockIncidentBloc();
    when(() => authBloc.state).thenReturn(
      const Authenticated(UserEntity(id: 'resident_1', email: 'juan@example.com')),
    );
    when(() => incidentBloc.state).thenReturn(IncidentInitial());
  });

  Future<void> pumpReportPage(WidgetTester tester, Locale locale) async {
    tester.view.physicalSize = const Size(1080, 2400);
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

  testWidgets('Report Incident screen is in Filipino', (tester) async {
    await pumpReportPage(tester, const Locale('fil'));

    expect(find.text('Mag-ulat ng Insidente'), findsOneWidget);
    expect(find.text('Detalye ng Insidente'), findsOneWidget);
    expect(find.text('Ako Mismo'), findsOneWidget);
    expect(find.text('Para sa Iba'), findsOneWidget);
    expect(find.text('Ako: juan'), findsOneWidget);
    expect(find.text('Report Incident'), findsNothing);
  });

  testWidgets('validation messages follow the language', (tester) async {
    await pumpReportPage(tester, const Locale('fil'));

    await tester.ensureVisible(find.text('ISUMITE ANG ULAT'));
    await tester.tap(find.text('ISUMITE ANG ULAT'));
    await tester.pump();

    expect(
      find.text('Pumili muna ng kategorya ng insidente bago magsumite.'),
      findsOneWidget,
    );
  });

  testWidgets('English is unchanged', (tester) async {
    await pumpReportPage(tester, const Locale('en'));

    expect(find.text('Report Incident'), findsOneWidget);
    expect(find.text('Incident Details'), findsOneWidget);
    expect(find.text('Self: juan'), findsOneWidget);
  });

  testWidgets('the category grid picks a category; Other asks for the type',
      (tester) async {
    await pumpReportPage(tester, const Locale('en'));
    expect(find.text('Specify Emergency Type'), findsNothing);

    await tester.ensureVisible(find.text('Other Emergency'));
    await tester.tap(find.text('Other Emergency'));
    await tester.pump();
    expect(find.text('Specify Emergency Type'), findsOneWidget);

    await tester.tap(find.text('Fire Incident'));
    await tester.pump();
    expect(find.text('Specify Emergency Type'), findsNothing);
  });

  testWidgets('For Someone shows the affected person fields', (tester) async {
    await pumpReportPage(tester, const Locale('en'));
    expect(find.text("Affected Person's Full Name *"), findsNothing);

    await tester.tap(find.text('For Someone'));
    await tester.pump();
    expect(find.text("Affected Person's Full Name *"), findsOneWidget);
  });
}
