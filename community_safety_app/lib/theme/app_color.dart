import 'package:flutter/material.dart';

class AppColors {
  // New Brand Palette - Ocean/Safety Blue
  static const Color primary = Color(0xFF0A4174); // Cobalt Blue
  static const Color secondary = Color(0xFF7BBDE8); // Sky Blue
  static const Color darkNavy = Color(0xFF001D39); // Navy
  static const Color iceBlue = Color(0xFFBDD8E9); // Ice Blue

  // Ocean safety gradient matching your image's background
  static const Gradient sunsetGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [secondary, darkNavy],
  );

  @Deprecated('Use AppColors.primary instead')
  static const Color darkGreen = primary;

  // Modern UI Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color cardBackground = Colors.white;
  static const Color textDark = Color(0xFF0F172A);
  static const Color textLight = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  
  @Deprecated('Use AppColors.accentBg instead')
  static const Color accentGreenBg = accentBg;
  
  static const Color accentBg = Color(0xFFEBF3F8); // Very light ice blue background
  
  // Status Colors
  static const Color pending = Color(0xFFFFD166);
  static const Color progress = Color(0xFF118AB2);
  static const Color solved = Color(0xFF06D6A0);
  static const Color danger = Color(0xFF8B0000);
}