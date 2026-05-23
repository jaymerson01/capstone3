import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/services/shared_incident_database.dart';
import 'features/auth/presentation/pages/welcome_page.dart';
import 'features/admin_dashboard/presentation/pages/admin_login_page.dart';
import 'features/admin_dashboard/presentation/pages/admin_panel_shell.dart';
import 'features/incident_reporting/presentation/blocs/incident_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedIncidentDatabase().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<IncidentBloc>(
          create: (context) => IncidentBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Safe Moonwalk',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF004D00)),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomePage(),
          '/admin/login': (context) => const AdminLoginPage(),
          '/admin/dashboard': (context) => const AdminPanelShell(),
        },
      ),
    );
  }
}
