import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:community_safety_app/firebase_options.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/services/fcm_service.dart';
import 'package:community_safety_app/core/services/sync_service.dart';
import 'package:community_safety_app/core/widgets/emergency_broadcast_listener.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_event.dart';
import 'package:community_safety_app/features/incident/data/models/incident_model.dart';
import 'package:community_safety_app/features/incident/presentation/pages/incident_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:community_safety_app/features/auth/presentation/pages/welcome_page.dart';
import 'package:community_safety_app/features/auth/presentation/pages/login_page.dart';
import 'package:community_safety_app/features/auth/presentation/pages/sign_up_page.dart';
import 'package:community_safety_app/features/auth/presentation/pages/email_verification_page.dart';
import 'package:community_safety_app/features/auth/presentation/widgets/auth_modals.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/report_incident_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/my_reports_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/maps_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/emergency_hotlines_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/settings_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/resident_nav_shell.dart';
import 'package:community_safety_app/features/notifications/data/datasources/notification_service.dart';


final GlobalKey<NavigatorState> residentNavigatorKey =
    GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Notice: .env load skipped or not found: $e");
  }

  try {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(IncidentModelAdapter());
    }
    await Hive.openBox('auth');
    await Hive.openBox<IncidentModel>('incidents');
  } catch (e) {
    debugPrint("Notice: Hive initialization warning: $e");
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Notice: Firebase initialization warning: $e");
  }

  try {
    await init();
  } catch (e) {
    debugPrint("Notice: Service locator initialization warning: $e");
  }

  try {
    // Register background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Initialize FCM, local channels, and foreground/background listeners
    sl<FCMService>().initialize(
      onNotificationTap: (incidentId) {
        if (incidentId != null && incidentId.isNotEmpty) {
          void attemptNav(int retries) {
            final ctx = residentNavigatorKey.currentContext;
            if (ctx != null) {
              IncidentDetailPage.openById(ctx, incidentId);
            } else if (retries > 0) {
              Future.delayed(const Duration(milliseconds: 500), () => attemptNav(retries - 1));
            }
          }
          attemptNav(10); // Wait up to 5 seconds for the app to mount
        }
      },
    );
  } catch (e) {
    debugPrint("Notice: FCM / Notification service offline or skipped: $e");
  }

  SyncService().startSyncTimer();

  runApp(const ResQResidentApp());
}

class ResQResidentApp extends StatelessWidget {
  const ResQResidentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<IncidentBloc>(
          create: (context) =>
              sl<IncidentBloc>()..add(const StreamActiveIncidentsRequested()),
        ),
      ],
      child: ValueListenableBuilder<bool>(
        valueListenable: AppColors.isDarkModeNotifier,
        builder: (context, isDark, child) {
          return MaterialApp(
            navigatorKey: residentNavigatorKey,
            title: 'ResQ Community Safety',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF49769F)),
              scaffoldBackgroundColor: AppColors.background,
              useMaterial3: true,
        ),
        home: const ResidentAuthWrapper(),
        routes: {
          '/welcome': (context) => const WelcomePage(),
          '/login': (context) => const LoginPage(),
          '/sign-up': (context) => const SignUpPage(),
          '/email-verification': (context) => const EmailVerificationPage(),
          '/dashboard': (context) => const ResidentNavShell(),
          '/report-incident': (context) => const ReportIncidentPage(),
          '/my-reports': (context) => const MyReportsPage(),
          '/maps': (context) => const MapsPage(),
          '/emergency-hotlines': (context) => const EmergencyHotlinesPage(),
          '/settings': (context) => const SettingsPage(),
        },
        builder: (context, child) {
          return EmergencyBroadcastListener(
            navigatorKey: residentNavigatorKey,
            child: child ?? const SizedBox.shrink(),
          );
        },
      );
    }
  ),
);
  }
}

class ResidentAuthWrapper extends StatelessWidget {
  const ResidentAuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          if (state.user.isAdmin) {
            context.read<AuthBloc>().add(const LogoutRequested());
            final navContext = residentNavigatorKey.currentContext ?? context;
            AuthModals.showAdminAccountBlocked(navContext);
            return;
          }

          // Always ensure community active incidents stream is fresh and active for Dashboard & Maps
          context.read<IncidentBloc>().add(const StreamActiveIncidentsRequested());

          final isVerified = (FirebaseAuth.instance.currentUser?.emailVerified ?? false) || state.user.isVerified;
          if (isVerified) {
            sl<FCMService>().syncUserToken(state.user.id);
            NotificationService().startForegroundNotificationListener(
              userId: state.user.id,
              onNotificationReceived: (title, body, incidentId) {
                sl<FCMService>().showLocalNotification(
                  title: title,
                  body: body,
                  incidentId: incidentId,
                );
              },
            );
          }
        } else if (state is Unauthenticated) {
          NotificationService().stopForegroundNotificationListener();
        }
      },
      builder: (context, state) {
        if (state is Authenticated && !state.user.isAdmin) {
          final isVerified = (FirebaseAuth.instance.currentUser?.emailVerified ?? false) || state.user.isVerified;
          if (!isVerified) {
            return EmailVerificationPage(user: state.user);
          }

          // Sync device token immediately if user is already logged in and verified
          sl<FCMService>().syncUserToken(state.user.id);
          NotificationService().startForegroundNotificationListener(
            userId: state.user.id,
            onNotificationReceived: (title, body, incidentId) {
              sl<FCMService>().showLocalNotification(
                title: title,
                body: body,
                incidentId: incidentId,
              );
            },
          );
          return const ResidentNavShell();
        }

        return const WelcomePage();
      },
    );
  }
}

