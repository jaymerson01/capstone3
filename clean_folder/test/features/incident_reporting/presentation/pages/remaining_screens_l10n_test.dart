import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:community_safety_app/core/services/location_service.dart';
import 'package:community_safety_app/core/utils/localized_labels.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_event.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/emergency_hotlines_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/maps_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/settings_page.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockIncidentBloc extends MockBloc<IncidentEvent, IncidentState>
    implements IncidentBloc {}

const filipino = Locale('fil');

void main() {
  late MockAuthBloc authBloc;
  late MockIncidentBloc incidentBloc;

  setUpAll(() => registerFallbackValue(const LogoutRequested()));

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    authBloc = MockAuthBloc();
    incidentBloc = MockIncidentBloc();
    when(() => authBloc.state).thenReturn(
      const Authenticated(UserEntity(id: 'resident_1', email: 'juan@example.com')),
    );
    when(() => incidentBloc.state).thenReturn(IncidentLoaded([
      IncidentEntity(
        id: 'inc1',
        reporterId: 'someone_else',
        description: 'Sunog sa kanto',
        category: 'Fire Incident',
        status: 'pending',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        latitude: 14.4851,
        longitude: 121.0116,
      ),
    ]));
  });

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
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('Settings is in Filipino and the translated Log Out still logs out',
      (tester) async {
    await pumpPage(tester, const SettingsPage(isRootTab: true), filipino);

    expect(find.text('MGA SETTING'), findsOneWidget);
    expect(find.text('MGA KAGUSTUHAN SA APP'), findsOneWidget); // section titles are uppercased

    await tester.ensureVisible(find.text('Mag-log Out'));
    await tester.tap(find.text('Mag-log Out'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      find.text('Sigurado ka bang magla-log out ka sa iyong ResQ resident account?'),
      findsOneWidget,
    );

    await tester.tap(find.text('Kumpirmahin'));
    await tester.pump(const Duration(seconds: 1));
    verify(() => authBloc.add(any(that: isA<LogoutRequested>()))).called(1);

    // Let the Welcome screen's intro animation timers finish.
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('Feedback categories are translated', (tester) async {
    await pumpPage(tester, const SettingsPage(isRootTab: true), filipino);

    await tester.ensureVisible(find.text('Magpadala ng Feedback at Ulat ng Bug'));
    await tester.tap(find.text('Magpadala ng Feedback at Ulat ng Bug'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Pangkalahatang Feedback'), findsOneWidget);
    expect(find.text('Ulat ng Bug'), findsOneWidget);
    expect(find.text('Bug Report'), findsNothing);
  });

  testWidgets('Emergency Hotlines is in Filipino; numbers unchanged', (tester) async {
    await pumpPage(tester, const EmergencyHotlinesPage(), filipino);

    expect(find.text('Mga Emergency Hotline'), findsOneWidget);
    expect(find.text('Dispatch ng Pulisya'), findsOneWidget);
    expect(find.text('911'), findsWidgets);
  });

  testWidgets('Maps is in Filipino', (tester) async {
    await pumpPage(tester, const MapsPage(isRootTab: true), filipino);

    expect(find.text('MAPA NG KOMUNIDAD'), findsOneWidget);
    expect(find.text('Lahat'), findsOneWidget); // filter chip
    expect(find.text('1 Aktibong Insidente'), findsOneWidget);
  });

  testWidgets('location errors keep their English text but translate by code',
      (tester) async {
    const error = LocationServiceException('gps-off', 'GPS is turned off.');
    expect(error.toString(), 'Exception: GPS is turned off.');

    late BuildContext context;
    await pumpPage(
      tester,
      Builder(builder: (c) {
        context = c;
        return const SizedBox();
      }),
      filipino,
    );
    expect(
      LocalizedLabels.locationError(context, error.code),
      'Naka-off ang GPS. Mag-swipe pababa mula sa itaas ng screen at i-on ang Location.',
    );
  });
}
