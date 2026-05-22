import 'package:flutter/material.dart';
import 'pages/welcome_page.dart';
import 'admin/pages/admin_login_page.dart';
import 'admin/admin_panel_shell.dart';

void main() {
  runApp(const CommunitySafetyApp());
}

class CommunitySafetyApp extends StatelessWidget {
  const CommunitySafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Community Safety System',
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/admin/login': (context) => const AdminLoginPage(),
        '/admin/dashboard': (context) => const AdminPanelShell(),
      },
    );
  }
}