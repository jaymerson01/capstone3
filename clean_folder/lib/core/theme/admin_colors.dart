import 'package:flutter/material.dart';

/// RESQ Admin Command Center — Color System 2026
class AdminColors {
  // ─── Brand Colors (mirrors AppColors for consistent admin experience) ─────
  static const Color primaryRose = Color(0xFF0A84FF);    // Electric blue (renamed alias kept)
  static const Color secondaryGreen = Color(0xFF00D4FF); // Cyan glow
  static const Color accentGreen = Color(0xFF6E40C9);    // Violet
  static const Color lightGreen = Color(0xFFB8E0FF);     // Light tint

  @Deprecated('Use AdminColors.primaryRose instead')
  static const Color primaryGreen = primaryRose;

  // ─── Background System ────────────────────────────────────────────────────
  static const Color background = Color(0xFF060D1A);
  static const Color cardBackground = Color(0xFF0D1627);
  static const Color surfaceLight = Color(0xFF1A2540);

  // ─── Text Colors ──────────────────────────────────────────────────────────
  static const Color textDark = Color(0xFFE8F0FE);
  static const Color textLight = Color(0xFF7B8DB0);
  static const Color border = Color(0xFF1E2D4A);

  // ─── Status Colors ────────────────────────────────────────────────────────
  static const Color pendingYellow = Color(0xFFFF9F0A);
  static const Color progressBlue = Color(0xFF0A84FF);
  static const Color solvedGreen = Color(0xFF30D158);
  static const Color dangerRed = Color(0xFFFF3B30);

  // ─── Card Accent Colors ───────────────────────────────────────────────────
  static const Color cardRed = Color(0xFFFF3B30);
  static const Color cardBlue = Color(0xFF0A84FF);
  static const Color cardGreen = Color(0xFF30D158);
  static const Color cardYellow = Color(0xFFFF9F0A);
  static const Color cardViolet = Color(0xFF6E40C9);
  static const Color cardCyan = Color(0xFF00D4FF);

  // ─── Shadow System ────────────────────────────────────────────────────────
  static List<BoxShadow> get card3dShadow => [
        BoxShadow(
          color: const Color(0xFF0A84FF).withValues(alpha: 0.12),
          offset: const Offset(0, 8),
          blurRadius: 24,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          offset: const Offset(0, 4),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ];

  // ─── Glassmorphism ────────────────────────────────────────────────────────
  static BoxDecoration glassCard({double borderRadius = 20}) {
    return BoxDecoration(
      color: const Color(0xFF0D1627),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: const Color(0xFF1E2D4A), width: 1),
      boxShadow: card3dShadow,
    );
  }

  // ─── Gradients ────────────────────────────────────────────────────────────
  static const Gradient sidebarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF060D1A), Color(0xFF0A1628)],
  );

  static const Gradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D1627), Color(0xFF0A1628)],
  );
}
