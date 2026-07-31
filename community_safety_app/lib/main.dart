import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'pages/welcome_page.dart';
import 'pages/dashboard.dart';
import 'admin/pages/admin_login_page.dart';
import 'admin/admin_panel_shell.dart';
import 'widgets/floating_chat_bot.dart';
import 'theme/app_color.dart';

import 'services/mock_database_service.dart';

import 'package:flutter/semantics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SemanticsBinding.instance.ensureSemantics();

  await Hive.initFlutter();
  await Hive.openBox('auth');
  await MockDatabaseService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = Hive.box(
      'auth',
    ).get('isLoggedIn', defaultValue: false);

    final textTheme = GoogleFonts.plusJakartaSansTextTheme().apply(
      bodyColor: AppColors.textDark,
      displayColor: AppColors.textDark,
    );

    return MaterialApp(
      title: 'ResQ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.danger,
          brightness: Brightness.dark,
        ).copyWith(
          surface: AppColors.surface,
          onSurface: AppColors.textDark,
        ),
        textTheme: textTheme,
        primaryTextTheme: textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textDark,
          elevation: 0,
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.plusJakartaSans(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
          iconTheme: const IconThemeData(color: AppColors.textDark),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardBackground,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceLight,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          hintStyle: const TextStyle(color: AppColors.textLight),
          labelStyle: const TextStyle(color: AppColors.textLight),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textLight,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          elevation: 24,
          titleTextStyle: GoogleFonts.plusJakartaSans(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
          contentTextStyle: GoogleFonts.plusJakartaSans(
            color: AppColors.textLight,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          checkColor: WidgetStateProperty.all(Colors.white),
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.primary;
            return AppColors.surfaceLight;
          }),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.surfaceLight,
          contentTextStyle: GoogleFonts.plusJakartaSans(
            color: AppColors.textDark,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: isLoggedIn ? const DashboardPage() : const WelcomePage(),
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/dashboard': (context) => const DashboardPage(),
        '/admin/login': (context) => const AdminLoginPage(),
        '/admin/dashboard': (context) => const AdminPanelShell(),
      },
      builder: (context, child) {
        return Scaffold(
          body: Stack(children: [child!]),
        );
      },
    );
  }
}
