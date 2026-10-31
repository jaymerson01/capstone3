// QA sweep: renders each resident screen at a small phone width (360dp)
// with the app font, in day and night mode, English and Filipino, at 1.0x
// and 1.3x text, and fails on any layout overflow.
//
// Screenshots for review (not committed):
//   flutter test test/qa/resident_screens_sweep_test.dart \
//     --update-goldens --dart-define=QA_SHOTS=true
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/app_theme.dart';
import 'package:community_safety_app/core/presentation/neo/aurora_background.dart';
import 'package:community_safety_app/core/widgets/emergency_siren_alert.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:community_safety_app/features/auth/presentation/pages/email_verification_page.dart';
import 'package:community_safety_app/features/auth/presentation/pages/login_page.dart';
import 'package:community_safety_app/features/auth/presentation/pages/sign_up_page.dart';
import 'package:community_safety_app/features/auth/presentation/pages/welcome_page.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/features/incident/domain/repositories/incident_repository.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_event.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';
import 'package:community_safety_app/features/incident/presentation/pages/incident_detail_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/emergency_hotlines_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/instruction_video_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/maps_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/my_reports_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/report_incident_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/settings_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/widgets/home_sections.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockIncidentBloc extends MockBloc<IncidentEvent, IncidentState>
    implements IncidentBloc {}

class MockIncidentRepository extends Mock implements IncidentRepository {}

const bool shots = bool.fromEnvironment('QA_SHOTS');

// A tall window, so long pages lay out (and can overflow) below the fold.
const Size phone = Size(360, 2000);

// Each map view gets its own numbered plugin channel.
const int mapChannels = 64;

final List<IncidentEntity> incidents = [
  IncidentEntity(
    id: 'abc123xyz',
    reporterId: 'resident_1',
    description: 'Usok mula sa bahay sa kanto, may naiwang bata sa loob.',
    category: 'Fire Incident',
    status: 'in_progress',
    urgencyStatus: 'CRITICAL',
    timestamp: DateTime(2026, 10, 24, 9, 30),
    latitude: 14.4851,
    longitude: 121.0116,
    resolvedAddress: 'Barangay Moonwalk, Parañaque City',
    estimatedResponseTime: '10-15 mins',
    dispatcherNotes: 'Responders on the way.',
    upvoteCount: 3,
  ),
  IncidentEntity(
    id: 'def456uvw',
    reporterId: 'resident_1',
    description: 'Hanggang tuhod ang baha sa kalsada.',
    category: 'Flood / Calamity',
    status: 'pending',
    urgencyStatus: 'HIGH',
    timestamp: DateTime(2026, 10, 23, 18, 5),
    latitude: 14.4895,
    longitude: 121.0105,
    isReportingOnBehalf: true,
    victimName: 'Relative',
  ),
  IncidentEntity(
    id: 'ghi789rst',
    reporterId: 'resident_1',
    description: 'Ninakaw ang cellphone malapit sa waiting shed.',
    category: 'Theft / Robbery',
    status: 'Resolved',
    urgencyStatus: 'MEDIUM',
    timestamp: DateTime(2026, 10, 20, 7, 45),
    latitude: 14.4815,
    longitude: 121.0135,
  ),
];

/// The home screen's sections, filled the way DashboardPage fills them.
class HomeSectionsPreview extends StatelessWidget {
  const HomeSectionsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final padding = MediaQuery.paddingOf(context);
    // Same stacking as DashboardPage inside ResidentNavShell: the aurora
    // behind, the landscape behind the header, the sections on top.
    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 300 + padding.top,
                child: const HomeHeroLandscape(),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    20, padding.top + 16, 20, padding.bottom + 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeHeroHeader(
                      welcomeLabel: l10n.dashboardWelcomeBack,
                      userName: 'Juan Dela Cruz',
                      placeLabel: "Barangay Moonwalk • ${l10n.commonResident}",
                      unreadCount: 12,
                      onNotificationsTap: () {},
                    ),
                    const SizedBox(height: 24),
                    HomeSirenCard(
                      activeLabel: l10n.dashboardActiveSiren,
                      alertType: 'Flood Evacuation',
                      title: 'Flash flood advisory',
                      message:
                          'Lumikas na sa mataas na lugar at sundin ang mga responder.',
                      targetLabel: l10n
                          .dashboardBroadcastTarget(l10n.dashboardAllSectors),
                    ),
                    HomeVideoCard(
                      title: l10n.dashboardVideoInstructions,
                      subtitle: l10n.dashboardVideoSubtitle,
                      onTap: () {},
                    ),
                    const SizedBox(height: 18),
                    HomeMyReportsPanel(
                      title: l10n.dashboardMyReportsStatus,
                      subtitle: l10n.dashboardMyReportsSubtitle,
                      viewAllLabel: l10n.dashboardViewAll,
                      onOpenMyReports: () {},
                      stats: [
                        HomeStat(
                          value: '12',
                          label: l10n.dashboardStatPending,
                          sublabel: l10n.dashboardStatInQueue,
                          color: AppColors.pending,
                          icon: Icons.hourglass_empty_rounded,
                        ),
                        HomeStat(
                          value: '3',
                          label: l10n.dashboardStatActive,
                          sublabel: l10n.dashboardStatResponding,
                          color: AppColors.progress,
                          icon: Icons.sync_rounded,
                          highlight: true,
                        ),
                        HomeStat(
                          value: '128',
                          label: l10n.dashboardStatSolved,
                          sublabel: l10n.dashboardStatResolved,
                          color: AppColors.solved,
                          icon: Icons.check_circle_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    HomeCommunityPanel(
                      title: l10n.dashboardCommunityIncidents,
                      subtitle: l10n.dashboardCommunitySubtitle,
                      activeLabel: l10n.dashboardActiveCount(2),
                      children: [
                        HomeIncidentRow(
                          icon: Icons.local_fire_department_rounded,
                          urgencyColor: AppColors.danger,
                          title: 'Fire Incident',
                          status: 'in_progress',
                          statusLabel: 'In Progress',
                          location: 'Area 1 - San Jose, Barangay Moonwalk',
                          time: l10n.dashboardReportedOn('10/24/2026'),
                          description:
                              'Usok mula sa bahay sa kanto, may naiwang bata sa loob.',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Every screen in the sweep, with whether a resident is signed in.
final Map<String, (Widget Function(), bool)> screens = {
  'welcome': (() => const WelcomePage(), false),
  'login': (() => const LoginPage(), false),
  'sign_up': (() => const SignUpPage(), false),
  'email_verification': (
    () => const EmailVerificationPage(email: 'juan.delacruz@example.com'),
    false,
  ),
  'home': (() => const HomeSectionsPreview(), true),
  'my_reports': (() => const MyReportsPage(), true),
  'incident_detail': (
    () => IncidentDetailPage(initialIncident: incidents.first),
    true,
  ),
  'report_incident': (() => const ReportIncidentPage(), true),
  'maps': (() => const MapsPage(), true),
  'hotlines': (() => const EmergencyHotlinesPage(), true),
  'settings': (() => const SettingsPage(), true),
  'edit_profile': (() => const EditProfilePage(), true),
  'privacy_security': (() => const PrivacySecurityPage(), true),
  'instruction_video': (() => const InstructionVideoPage(), true),
  'siren_alert': (
    () => EmergencySirenAlert(
          header: 'EMERGENCY SIREN NG MUNISIPYO',
          alertType: 'Flood Evacuation',
          title: 'Municipal emergency advisory',
          message:
              'Pinapayuhan ng mga awtoridad ng Barangay ang agarang pag-iingat.',
          targetLabel: 'Sektor: Lahat ng Sektor',
          originLabel: 'Mula sa: Barangay Command Center',
          timeLabel: '9:30 AM',
          acknowledgeLabel: 'KILALANIN ANG ALERTO',
          onAcknowledge: () {},
        ),
    true,
  ),
};

Future<void> _loadFonts() async {
  final jakarta = FontLoader(AppTheme.fontFamily);
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    jakarta.addFont(
      rootBundle.load('assets/fonts/PlusJakartaSans/PlusJakartaSans-$weight.ttf'),
    );
  }
  await jakarta.load();

  // Real icons only matter for the screenshots.
  final root = Platform.environment['FLUTTER_ROOT'];
  final icons = File('$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
  if (shots && root != null && icons.existsSync()) {
    final loader = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())));
    await loader.load();
  }
}

void main() {
  late MockAuthBloc authBloc;
  late MockIncidentBloc incidentBloc;
  late MockIncidentRepository repository;

  setUpAll(() async {
    registerFallbackValue(const LogoutRequested());
    await _loadFonts();
  });

  setUp(() {
    // Google Maps is a native view that can't start in a test; answer its
    // channel so the map shows as an empty box.
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      SystemChannels.platform_views,
      (call) async => call.method == 'create' ? 0 : null,
    );
    for (var id = 0; id < mapChannels; id++) {
      messenger.setMockMethodCallHandler(
        MethodChannel('plugins.flutter.io/google_maps_$id'),
        (call) async => null,
      );
    }
    SharedPreferences.setMockInitialValues({});
    authBloc = MockAuthBloc();
    incidentBloc = MockIncidentBloc();
    repository = MockIncidentRepository();
    when(() => incidentBloc.state).thenReturn(IncidentLoaded(incidents));
    when(() => repository.streamUserIncidents(any()))
        .thenAnswer((_) => Stream.value(incidents));
    when(() => repository.streamActiveIncidents())
        .thenAnswer((_) => Stream.value(incidents));
    sl.registerLazySingleton<IncidentRepository>(() => repository);
  });

  tearDown(() {
    sl.reset();
    AppColors.isDarkMode = false;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform_views, null);
    for (var id = 0; id < mapChannels; id++) {
      messenger.setMockMethodCallHandler(
        MethodChannel('plugins.flutter.io/google_maps_$id'),
        null,
      );
    }
  });

  for (final MapEntry(key: name, value: (build, signedIn)) in screens.entries) {
    testWidgets('$name fits a 360dp phone in every mode', (tester) async {
      when(() => authBloc.state).thenReturn(
        signedIn
            ? const Authenticated(
                UserEntity(
                  id: 'resident_1',
                  email: 'juan.delacruz@example.com',
                  displayName: 'Juan Dela Cruz',
                ),
              )
            : Unauthenticated(),
      );
      tester.view.physicalSize = phone;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      final problems = <String>[];
      for (final dark in [false, true]) {
        for (final locale in const [Locale('en'), Locale('fil')]) {
          for (final scale in [1.0, 1.3]) {
            final combo =
                '${dark ? 'night' : 'day'}-${locale.languageCode}-${scale}x';
            AppColors.isDarkMode = dark;
            tester.platformDispatcher.textScaleFactorTestValue = scale;

            final errors = <FlutterErrorDetails>[];
            final previous = FlutterError.onError;
            FlutterError.onError = errors.add;
            final key = GlobalKey();
            await tester.pumpWidget(
              MultiBlocProvider(
                key: ValueKey(combo),
                providers: [
                  BlocProvider<AuthBloc>.value(value: authBloc),
                  BlocProvider<IncidentBloc>.value(value: incidentBloc),
                ],
                child: RepaintBoundary(
                  key: key,
                  child: MaterialApp(
                    debugShowCheckedModeBanner: false,
                    theme: AppTheme.resident(),
                    locale: locale,
                    supportedLocales: AppLocalizations.supportedLocales,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    home: build(),
                  ),
                ),
              ),
            );
            // Let entrance animations and first frames finish.
            for (var i = 0; i < 6; i++) {
              await tester.pump(const Duration(milliseconds: 400));
            }
            FlutterError.onError = previous;

            for (final error in errors) {
              // Native plugins (the map) don't exist in tests.
              if (error.exception is MissingPluginException) continue;
              final text = error.exceptionAsString().split('\n').first;
              final where = error
                  .toString()
                  .split('\n')
                  .firstWhere(
                    (line) => line.contains('lib/'),
                    orElse: () => '',
                  )
                  .trim();
              problems.add('$combo: $text $where');
            }

            if (shots) {
              await expectLater(
                find.byKey(key),
                matchesGoldenFile('qa_shots/$name-$combo.png'),
              );
            }
          }
        }
      }

      expect(problems, isEmpty, reason: problems.join('\n'));
    });
  }
}
