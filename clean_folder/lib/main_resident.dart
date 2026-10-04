import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:community_safety_app/firebase_options.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/services/fcm_service.dart';
import 'package:community_safety_app/core/widgets/floating_chat_bot.dart';
import 'package:community_safety_app/core/widgets/emergency_broadcast_listener.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_event.dart';
import 'package:community_safety_app/features/incident/data/models/incident_model.dart';
import 'package:community_safety_app/features/incident/presentation/pages/incident_detail_page.dart';
import 'package:community_safety_app/features/auth/presentation/pages/welcome_page.dart';
import 'package:community_safety_app/features/auth/presentation/pages/login_page.dart';
import 'package:community_safety_app/features/auth/presentation/pages/sign_up_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/dashboard_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/report_incident_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/my_reports_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/maps_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/emergency_hotlines_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/settings_page.dart';
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
    await sl<FCMService>().initialize(
      onNotificationTap: (incidentId) {
        if (incidentId != null && incidentId.isNotEmpty) {
          final ctx = residentNavigatorKey.currentContext;
          if (ctx != null) {
            IncidentDetailPage.openById(ctx, incidentId);
          }
        }
      },
    );
  } catch (e) {
    debugPrint("Notice: FCM / Notification service offline or skipped: $e");
  }

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
      child: MaterialApp(
        navigatorKey: residentNavigatorKey,
        title: 'ResQ Community Safety',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF49769F)),
          scaffoldBackgroundColor: const Color(0xFF060D1A),
          useMaterial3: true,
        ),
        home: const ResidentAuthWrapper(),
        routes: {
          '/welcome': (context) => const WelcomePage(),
          '/login': (context) => const LoginPage(),
          '/sign-up': (context) => const SignUpPage(),
          '/dashboard': (context) => const DashboardPage(),
          '/report-incident': (context) => const ReportIncidentPage(),
          '/my-reports': (context) => const MyReportsPage(),
          '/maps': (context) => const MapsPage(),
          '/emergency-hotlines': (context) => const EmergencyHotlinesPage(),
          '/settings': (context) => const SettingsPage(),
        },
        builder: (context, child) {
          return EmergencyBroadcastListener(
            navigatorKey: residentNavigatorKey,
            child: Scaffold(
              body: Stack(
                children: [
                  // ignore: use_null_aware_elements
                  if (child != null) child,
                  const FloatingChatBot(),
                ],
              ),
            ),
          );
        },
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
        } else if (state is Unauthenticated) {
          NotificationService().stopForegroundNotificationListener();
        }
      },
      builder: (context, state) {
        if (state is Authenticated) {
          // Sync device token immediately if user is already logged in
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
          return const DashboardPage();
        }


        return const WelcomePage();
      },
    );
  }
}

