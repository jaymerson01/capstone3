import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:community_safety_app/firebase_options.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_event.dart';
import 'package:community_safety_app/features/incident/data/models/incident_model.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/pages/admin_login_page.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/pages/admin_panel_shell.dart';

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

  runApp(const ResQAdminApp());
}

class ResQAdminApp extends StatelessWidget {
  const ResQAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<IncidentBloc>(
          create: (context) =>
              sl<IncidentBloc>()..add(const StreamAllIncidentsRequested()),
        ),
      ],
      child: MaterialApp(
        title: 'ResQ Admin Command Center',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AdminColors.background,
          colorScheme: const ColorScheme.dark(
            primary: AdminColors.primaryRose,
            secondary: AdminColors.secondaryGreen,
            surface: AdminColors.surfaceLight,
          ),
          fontFamily: 'Inter',
          useMaterial3: true,
        ),
        home: const AdminAuthWrapper(),
        routes: {
          '/admin/login': (context) => const AdminLoginPage(),
          '/admin/dashboard': (context) => const AdminPanelShell(),
        },
      ),
    );
  }
}

class AdminAuthWrapper extends StatelessWidget {
  const AdminAuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated && !state.user.isAdmin) {
          // Immediately log out non-admin users attempting web portal access
          context.read<AuthBloc>().add(const LogoutRequested());
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            backgroundColor: AdminColors.background,
            body: Center(
              child: CircularProgressIndicator(
                color: AdminColors.primaryRose,
              ),
            ),
          );
        }

        if (state is Authenticated) {
          if (state.user.isAdmin) {
            return const AdminPanelShell();
          } else {
            return const AdminLoginPage(
              initialErrorMessage:
                  "Access Denied: Admin privileges required. Please sign in with an authorized municipal desk account.",
            );
          }
        }

        return const AdminLoginPage();
      },
    );
  }
}
