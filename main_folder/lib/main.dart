import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/shared_incident_database.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/welcome_page.dart';
import 'features/admin_dashboard/presentation/pages/admin_login_page.dart';
import 'features/admin_dashboard/presentation/pages/admin_panel_shell.dart';
import 'features/incident_reporting/presentation/blocs/incident_bloc.dart';
import 'features/incident_reporting/presentation/pages/emergency_hotlines_page.dart';
import 'features/incident_reporting/presentation/widgets/floating_chat_bot.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('auth');
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
        title: 'ResQ',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomePage(),
          '/admin/login': (context) => const AdminLoginPage(),
          '/admin/dashboard': (context) => const AdminPanelShell(),
          '/emergency_hotlines': (context) => const EmergencyHotlinesPage(),
        },
        builder: (context, child) {
          return Scaffold(
            body: Stack(
              children: [
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
