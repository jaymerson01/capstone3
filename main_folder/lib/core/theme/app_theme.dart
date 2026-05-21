import 'package:flutter/material.dart';

class AppTheme {
  static const Color darkGreen = Color(0xFF1E5325);
  static const Color lightGreen = Color(0xFF6BD18B);
  static const Color greyGreen = Color(0xFF9DA299);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkGreen,
        primary: darkGreen,
        secondary: lightGreen,
        surface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: lightGreen,
        secondary: greyGreen,
        surface: backgroundDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
      ),
    );
  }
}
