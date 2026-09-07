import 'package:flutter/material.dart';
import 'package:community_safety_app/features/resident/resident_app.dart';
import 'package:community_safety_app/features/admin/admin_app.dart';
import 'package:community_safety_app/features/admin/presentation/pages/admin_landing_page.dart';

class AppRouter {
  static const String welcome = '/welcome';
  static const String residentDashboard = '/dashboard';
  static const String admin = '/admin';
  static const String adminLogin = '/admin/login';
  static const String adminDashboard = '/admin/dashboard';

  static Map<String, WidgetBuilder> get routes => {
        welcome: (context) => const WelcomePage(),
        residentDashboard: (context) => const DashboardPage(),
        admin: (context) => const AdminLandingPage(),
        adminLogin: (context) => const AdminLoginPage(),
        adminDashboard: (context) => const AdminPanelShell(),
      };
}
