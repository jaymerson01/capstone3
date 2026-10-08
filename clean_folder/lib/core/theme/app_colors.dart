import 'package:flutter/material.dart';

/// RESQ Smart City Command Center — Premium Color System 2026
/// Deep Navy · Electric Blue · Cyan Glow · Emergency Crimson
class AppColors {
  // ─── Theme Mode Toggle ────────────────────────────────────────────────────
  // Defaulting to light mode per user request
  static final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false);
  static bool get isDarkMode => isDarkModeNotifier.value;
  static set isDarkMode(bool val) => isDarkModeNotifier.value = val;

  // ─── Core Brand Palette ───────────────────────────────────────────────────
  static const Color primary = Color(0xFF0A84FF);        // Electric blue
  static const Color secondary = Color(0xFF00D4FF);      // Cyan glow
  static const Color accent = Color(0xFF6E40C9);         // Violet accent
  static const Color lightGreen = Color(0xFFB8E0FF);     // Light blue tint

  // Legacy alias — kept to avoid breaking any references
  static const Color darkNavy = Color(0xFF0A0F1E);       // Deep navy

  // ─── Background System ────────────────────────────────────────────────────
  static Color get background => isDarkMode ? const Color(0xFF060D1A) : const Color(0xFFF0F4F8);
  static Color get surface => isDarkMode ? const Color(0xFF0D1627) : const Color(0xFFFFFFFF);
  static Color get cardBackground => isDarkMode ? const Color(0xFF0D1627) : const Color(0xFFFFFFFF);
  static Color get surfaceLight => isDarkMode ? const Color(0xFF1A2540) : const Color(0xFFE2E8F0);
  static Color get surfaceGlass => isDarkMode ? const Color(0x1AFFFFFF) : const Color(0x4DFFFFFF);

  // ─── Text Colors ──────────────────────────────────────────────────────────
  static Color get textDark => isDarkMode ? const Color(0xFFE8F0FE) : const Color(0xFF1E293B);
  static Color get textLight => isDarkMode ? const Color(0xFF7B8DB0) : const Color(0xFF64748B);
  static Color get textMuted => isDarkMode ? const Color(0xFF4A5568) : const Color(0xFF94A3B8);
  static Color get border => isDarkMode ? const Color(0xFF1E2D4A) : const Color(0xFFCBD5E1);

  // Legacy aliases
  static Color get accentBg => isDarkMode ? const Color(0xFF0D1627) : const Color(0xFFFFFFFF);
  @Deprecated('Use AppColors.accentBg instead')
  static Color get accentGreenBg => accentBg;
  @Deprecated('Use AppColors.primary instead')
  static const Color darkGreen = primary;

  // ─── Status Colors ────────────────────────────────────────────────────────
  static const Color pending = Color(0xFFFF9F0A);        // Amber warning
  static const Color warning = pending;                  // Warning alias
  static const Color progress = Color(0xFF0A84FF);       // Blue in-progress
  static const Color solved = Color(0xFF30D158);         // Green success
  static const Color danger = Color(0xFFFF3B30);         // Red emergency

  // ─── Glow Colors ──────────────────────────────────────────────────────────
  static const Color primaryGlow = Color(0xFF0A84FF);
  static const Color cyanGlow = Color(0xFF00D4FF);
  static const Color dangerGlow = Color(0xFFFF3B30);
  static const Color successGlow = Color(0xFF30D158);
  static const Color warningGlow = Color(0xFFFF9F0A);

  // ─── Premium Gradients ────────────────────────────────────────────────────
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A84FF), Color(0xFF0066CC)],
  );

  static const Gradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF060D1A), Color(0xFF0A1628), Color(0xFF0D1F3C)],
  );

  static const Gradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A84FF), Color(0xFF00D4FF)],
  );

  static const Gradient commandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF060D1A), Color(0xFF0A1628)],
  );

  static const Gradient emergencyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF2D55), Color(0xFFFF6B00)],
  );

  static const Gradient cyanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00D4FF), Color(0xFF0A84FF)],
  );

  // ─── Shadow System ────────────────────────────────────────────────────────

  /// Soft floating card shadow
  static List<BoxShadow> get soft3dShadow => [
        BoxShadow(
          color: const Color(0xFF0A84FF).withValues(alpha: 0.15),
          offset: const Offset(0, 8),
          blurRadius: 24,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          offset: const Offset(0, 4),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ];

  /// Premium button glow shadow
  static List<BoxShadow> get button3dShadow => [
        BoxShadow(
          color: const Color(0xFF0A84FF).withValues(alpha: 0.45),
          offset: const Offset(0, 6),
          blurRadius: 20,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          offset: const Offset(0, 2),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];

  /// Primary blue button glow shadow
  static List<BoxShadow> get primaryGlowShadow => [
        BoxShadow(
          color: const Color(0xFF0A84FF).withValues(alpha: 0.45),
          offset: const Offset(0, 6),
          blurRadius: 22,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          offset: const Offset(0, 2),
          blurRadius: 8,
          spreadRadius: 0,
        ),
      ];

  /// Emergency/danger glow shadow
  static List<BoxShadow> get dangerGlowShadow => [
        BoxShadow(
          color: const Color(0xFFFF3B30).withValues(alpha: 0.4),
          offset: const Offset(0, 6),
          blurRadius: 24,
          spreadRadius: 0,
        ),
      ];

  /// Success/green glow shadow
  static List<BoxShadow> get successGlowShadow => [
        BoxShadow(
          color: const Color(0xFF30D158).withValues(alpha: 0.35),
          offset: const Offset(0, 4),
          blurRadius: 16,
          spreadRadius: 0,
        ),
      ];

  /// Cyan glow shadow
  static List<BoxShadow> get cyanGlowShadow => [
        BoxShadow(
          color: const Color(0xFF00D4FF).withValues(alpha: 0.35),
          offset: const Offset(0, 4),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ];

  // ─── Glassmorphism Helpers ────────────────────────────────────────────────

  static BoxDecoration glassCard({
    double opacity = 0.08,
    double borderOpacity = 0.15,
    double borderRadius = 20,
    Color? glowColor,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: (glowColor ?? Colors.white).withValues(alpha: borderOpacity),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        if (glowColor != null)
          BoxShadow(
            color: glowColor.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
      ],
    );
  }

  static BoxDecoration glassCardLight({
    double borderRadius = 20,
    Color? glowColor,
  }) {
    return BoxDecoration(
      color: const Color(0xFF0D1627),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: const Color(0xFF1E2D4A),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
        if (glowColor != null)
          BoxShadow(
            color: glowColor.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
      ],
    );
  }

  // ─── Status System ────────────────────────────────────────────────────────

  static Color statusColor(String status) {
    switch (status
        .toLowerCase()
        .replaceAll('_', '')
        .replaceAll(' ', '')
        .trim()) {
      case 'pending':
        return pending;
      case 'inprogress':
      case 'assigned':
      case 'responding':
        return progress;
      case 'solved':
      case 'resolved':
        return solved;
      case 'cancelled':
      case 'spam':
      case 'archived':
        return textMuted;
      default:
        return primary;
    }
  }

  static List<BoxShadow> statusGlow(String status) {
    switch (status
        .toLowerCase()
        .replaceAll('_', '')
        .replaceAll(' ', '')
        .trim()) {
      case 'pending':
        return [
          BoxShadow(
              color: pending.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ];
      case 'inprogress':
      case 'assigned':
      case 'responding':
        return [
          BoxShadow(
              color: progress.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ];
      case 'solved':
      case 'resolved':
        return [
          BoxShadow(
              color: solved.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ];
      default:
        return [];
    }
  }
}
