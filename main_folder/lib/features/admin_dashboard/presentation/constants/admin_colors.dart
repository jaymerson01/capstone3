import 'package:flutter/material.dart';

class AdminColors {
  // Primary Green Government theme colors
  static const Color primaryRose = Color(0xFF2E7D32); // Primary Green
  static const Color secondaryGreen = Color(0xFF43A047);
  static const Color accentGreen = Color(0xFF66BB6A);
  static const Color lightGreen = Color(0xFFC8E6C9);

  @Deprecated('Use AdminColors.primaryRose instead')
  static const Color primaryGreen = primaryRose;

  // Clean backgrounds and surfaces
  static const Color background = Color(0xFFF8FAF8);
  static const Color cardBackground = Colors.white;
  static const Color textDark = Color(0xFF1B1B1B);
  static const Color textLight = Color(0xFF5F6368);
  static const Color border = Color(0xFFE0E0E0);

  // Status and Category Colors
  static const Color pendingYellow = Color(0xFFFB8C00);
  static const Color progressBlue = Color(0xFF1976D2);
  static const Color solvedGreen = Color(0xFF2E7D32);
  static const Color dangerRed = Color(0xFFD32F2F);

  // Card/Highlight Colors for Admin theme
  static const Color cardRed = Color(0xFFD32F2F);
  static const Color cardBlue = Color(0xFF1976D2);
  static const Color cardGreen = Color(0xFF2E7D32);
  static const Color cardYellow = Color(0xFFFB8C00);
}
