import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:community_safety_app/firebase_options.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/core/theme/app_theme.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:community_safety_app/features/incident/data/models/incident_model.dart';
import 'package:community_safety_app/features/responder/presentation/pages/responder_home_page.dart';
import 'package:community_safety_app/features/responder/presentation/pages/responder_login_page.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

/// The responder portal (/responder/): tanod, BFP, PNP and health/rescue
/// staff see their department's reports, accept them, and update progress.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(IncidentModelAdapter());
  await Hive.openBox('auth');
  await Hive.openBox<IncidentModel>('incidents');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await init();
  runApp(const ResQResponderApp());
}

class ResQResponderApp extends StatelessWidget {
  const ResQResponderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
      child: MaterialApp(
        title: 'ResQ Responder',
        debugShowCheckedModeBanner: false,
        // English, like the admin portal; the delegates serve shared widgets.
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.admin(),
        home: const ResponderAuthWrapper(),
      ),
    );
  }
}

class ResponderAuthWrapper extends StatelessWidget {
  const ResponderAuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated && !state.user.isResponder) {
          context.read<AuthBloc>().add(const LogoutRequested());
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            backgroundColor: AdminColors.background,
            body: Center(child: CircularProgressIndicator(color: AdminColors.cyan)),
          );
        }
        if (state is Authenticated) {
          return state.user.isResponder
              ? ResponderHomePage(user: state.user)
              : const ResponderLoginPage(
                  initialError: 'This portal is for responder accounts. Admins use /admin/, residents the ResQ app.',
                );
        }
        return const ResponderLoginPage();
      },
    );
  }
}
