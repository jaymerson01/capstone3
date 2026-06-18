import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/features/auth/presentation/pages/welcome_page.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/dashboard_page.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/pages/admin_login_page.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/pages/admin_panel_shell.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:community_safety_app/core/widgets/floating_chat_bot.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:community_safety_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('auth');
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => sl<AuthBloc>()..add(const AuthCheckRequested()),
      child: MaterialApp(
        title: 'ResQ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF49769F)),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
        routes: {
          '/welcome': (context) => const WelcomePage(),
          '/dashboard': (context) => const DashboardPage(),
          '/admin/login': (context) => const AdminLoginPage(),
          '/admin/dashboard': (context) => const AdminPanelShell(),
        },
        builder: (context, child) {
          return Scaffold(
            body: Stack(
              children: [
                // ignore: use_null_aware_elements
                if (child != null) child,
                const FloatingChatBot(),
              ],
            ),
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
          return const DashboardPage();
        }
        return const WelcomePage();
      },
    );
  }
}
