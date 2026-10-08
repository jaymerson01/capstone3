import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/widgets/emergency_broadcast_listener.dart';
import 'package:community_safety_app/features/auth/presentation/pages/welcome_page.dart';
import 'package:community_safety_app/features/auth/presentation/pages/login_page.dart';
import 'package:community_safety_app/features/auth/presentation/pages/sign_up_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/report_incident_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/my_reports_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/maps_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/emergency_hotlines_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/settings_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/resident_nav_shell.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/pages/admin_login_page.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/pages/admin_panel_shell.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_event.dart';
import 'package:community_safety_app/features/incident/data/models/incident_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:community_safety_app/firebase_options.dart';
import 'package:community_safety_app/core/services/sync_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();
  Hive.registerAdapter(IncidentModelAdapter());
  await Hive.openBox('auth');
  await Hive.openBox<IncidentModel>('incidents');
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await init();

  SyncService().startSyncTimer();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<IncidentBloc>(
          create: (context) => sl<IncidentBloc>()..add(const StreamActiveIncidentsRequested()),
        ),
      ],
      child: MaterialApp(
        title: 'ResQ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF49769F)),
          scaffoldBackgroundColor: const Color(0xFF060D1A),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/welcome': (context) => const WelcomePage(),
          '/login': (context) => const LoginPage(),
          '/sign-up': (context) => const SignUpPage(),
          '/dashboard': (context) => const ResidentNavShell(),
          '/report-incident': (context) => const ReportIncidentPage(),
          '/my-reports': (context) => const MyReportsPage(),
          '/maps': (context) => const MapsPage(),
          '/emergency-hotlines': (context) => const EmergencyHotlinesPage(),
          '/settings': (context) => const SettingsPage(),
          '/admin/login': (context) => const AdminLoginPage(),
          '/admin/dashboard': (context) => const AdminPanelShell(),
        },
        builder: (context, child) {
          return EmergencyBroadcastListener(
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          if (state.user.isAdmin) {
            return const AdminPanelShell();
          } else {
            return const ResidentNavShell();
          }
        }
        return const WelcomePage();
      },
    );
  }
}
