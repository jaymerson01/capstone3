import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/domain/repositories/incident_repository.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_event.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';
import 'package:community_safety_app/features/incident/presentation/pages/incident_detail_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/my_reports_page.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockIncidentBloc extends MockBloc<IncidentEvent, IncidentState>
    implements IncidentBloc {}

class MockIncidentRepository extends Mock implements IncidentRepository {}

void main() {
  late MockAuthBloc authBloc;
  late MockIncidentBloc incidentBloc;

  final incident = IncidentEntity(
    id: 'abc123xyz',
    reporterId: 'resident_1',
    description: 'Usok mula sa bahay sa kanto',
    category: 'Fire Incident',
    status: 'in_progress',
    urgencyStatus: 'HIGH',
    timestamp: DateTime(2026, 10, 24, 9, 30),
    latitude: 14.4851,
    longitude: 121.0116,
    resolvedAddress: 'E. Rodriguez Ave, Barangay Moonwalk, Parañaque City',
  );

  setUp(() {
    authBloc = MockAuthBloc();
    incidentBloc = MockIncidentBloc();
    when(() => authBloc.state).thenReturn(
      const Authenticated(UserEntity(id: 'resident_1', email: 'juan@example.com')),
    );
    when(() => incidentBloc.state).thenReturn(IncidentLoaded([incident]));
  });

  tearDown(() => sl.reset());

  Future<void> pumpPage(WidgetTester tester, Widget page, Locale locale) async {
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
          home: page,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('Incident Details is in Filipino; resident text is untouched', (tester) async {
    await pumpPage(tester, IncidentDetailPage(initialIncident: incident), const Locale('fil'));

    expect(find.text('Sunog'), findsWidgets); // stored "Fire Incident"
    expect(find.text('INAAKSYUNAN'), findsOneWidget); // stored "in_progress"
    expect(find.text('Salaysay ng Insidente'), findsOneWidget);
    expect(find.text('Usok mula sa bahay sa kanto'), findsOneWidget);
    expect(find.text('Nakabinbin'), findsOneWidget); // timeline node
    expect(find.text('Fire Incident'), findsNothing);
  });

  testWidgets('My Reports is in Filipino and filters still work', (tester) async {
    final repository = MockIncidentRepository();
    when(() => repository.streamUserIncidents(any()))
        .thenAnswer((_) => Stream.value([incident]));
    sl.registerLazySingleton<IncidentRepository>(() => repository);

    await pumpPage(tester, const MyReportsPage(), const Locale('fil'));

    expect(find.text('AKING MGA ULAT'), findsOneWidget);
    expect(find.text('LAHAT'), findsOneWidget);
    expect(find.text('Sunog'), findsOneWidget);

    // The "Resolved" filter hides the in-progress report.
    await tester.tap(find.text('Naresolba na'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Sunog'), findsNothing);
    expect(find.text('Walang ulat sa filter na ito.'), findsOneWidget);
  });
}
