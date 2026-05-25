import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/welcome_page.dart';
import 'pages/dashboard.dart';
import 'admin/pages/admin_login_page.dart';
import 'admin/admin_panel_shell.dart';
// 1. Import your chatbot widget here
import 'widgets/floating_chat_bot.dart'; // Adjust path if necessary

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for session persistence
  await Hive.initFlutter();
  await Hive.openBox('auth');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Read local auth session persistent state
    final bool isLoggedIn = Hive.box(
      'auth',
    ).get('isLoggedIn', defaultValue: false);

    return MaterialApp(
      title: 'ResQ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF004D00)),
        useMaterial3: true,
      ),
      home: isLoggedIn ? const DashboardPage() : const WelcomePage(),
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/dashboard': (context) => const DashboardPage(),
        '/admin/login': (context) => const AdminLoginPage(),
        '/admin/dashboard': (context) => const AdminPanelShell(),
      },

      // 2. Use the builder property to overlay the ChatBot globally
      builder: (context, child) {
        return Scaffold(
          body: Stack(
            children: [
              // child represents whatever page is currently active via routes/home
              if (child != null) child,

              // The chatbot is placed on top of the entire application layer
              const FloatingChatBot(),
            ],
          ),
        );
      },
    );
  }
}
