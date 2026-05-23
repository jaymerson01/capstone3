import 'package:flutter/material.dart';
import 'pages/welcome_page.dart';
import 'admin/pages/admin_login_page.dart';
import 'admin/admin_panel_shell.dart';
import 'theme/app_color.dart';

void main() {
  runApp(const CommunitySafetyApp());
}

class CommunitySafetyApp extends StatelessWidget {
  const CommunitySafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var themeData = ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.darkGreen,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkGreen,
        primary: AppColors.darkGreen,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Community Safety System',
      theme: themeData,

      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/admin/login': (context) => const AdminLoginPage(),
        '/admin/dashboard': (context) => const AdminPanelShell(),
      },
    );
  }
}
