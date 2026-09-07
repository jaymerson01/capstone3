import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/features/shared/navigation/app_router.dart';
import 'package:community_safety_app/features/resident/resident_app.dart';
import 'package:community_safety_app/features/admin/admin_app.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:community_safety_app/core/widgets/floating_chat_bot.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_event.dart';
import 'package:community_safety_app/features/incident/data/models/incident_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:community_safety_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();
  Hive.registerAdapter(IncidentModelAdapter());
  await Hive.openBox('auth');
  await Hive.openBox<IncidentModel>('incidents');
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await init();

  runApp(const MyApp());
}

Widget _buildInitialScreen() {
  final path = Uri.base.path.toLowerCase();
  if (path == '/admin' || path.startsWith('/admin/')) {
    return const AdminLandingPage();
  }
  return const AuthWrapper();
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
        home: _buildInitialScreen(),
        routes: AppRouter.routes,
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
          if (state.user.email.toLowerCase().contains('admin')) {
            return const AdminPanelShell();
          } else {
            return const DashboardPage();
          }
        }
        return const WelcomePage();
      },
    );
  }
}
