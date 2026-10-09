import 'package:flutter/material.dart';

class AppColors {
  // Primary Green Palette - Premium Government Theme
  static const Color primary = Color(0xFF2E7D32); // Primary Green
  static const Color secondary = Color(0xFF43A047); // Secondary Green
  static const Color accent = Color(0xFF66BB6A); // Accent Green
  static const Color lightGreen = Color(0xFFC8E6C9); // Light Green
  static const Color darkNavy = Color(0xFF1B4D20); // Dark Forest Green

  // Premium Government Gradients
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );

  static const Gradient sunsetGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [secondary, darkNavy],
  );

  static const Color darkGreen = primary;

  // Modern UI Colors
  static const Color background = Color(0xFFF8FAF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1B1B1B);
  static const Color textLight = Color(0xFF5F6368);
  static const Color border = Color(0xFFE0E0E0);
  
  static const Color accentGreenBg = accentBg;
  static const Color accentBg = Color(0xFFF0F7F1);
  
  // Status Colors
  static const Color pending = Color(0xFFFB8C00);
  static const Color progress = Color(0xFF43A047);
  static const Color solved = Color(0xFF2E7D32);
  static const Color danger = Color(0xFFD32F2F);
}
