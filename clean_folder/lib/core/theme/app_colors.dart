import 'package:flutter/material.dart';

/// RESQ Smart City Command Center — Premium Color System 2026
/// Neo-Tactile: ResQuick Blue · Deep Blue · Emergency Red · Live Cyan,
/// on Frost (light mode) or Night glass (dark mode).
class AppColors {
  // ─── Theme Mode Toggle ────────────────────────────────────────────────────
  // Defaulting to light mode per user request
  static final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false);
  static bool get isDarkMode => isDarkModeNotifier.value;
  static set isDarkMode(bool val) => isDarkModeNotifier.value = val;

  // ─── Core Brand Palette ───────────────────────────────────────────────────
  static const Color primary = Color(0xFF2F6BF0);        // ResQuick blue · actions
  static const Color primaryDeep = Color(0xFF2353D6);    // Primary gradient end
  static const Color deepBlue = Color(0xFF1E3A8A);       // Headers, selected labels
  static const Color secondary = Color(0xFF22D3EE);      // Live cyan · live, active
  static const Color accent = Color(0xFF8B5CF6);         // Violet accent (aurora)
  static const Color lightGreen = Color(0xFFDBEAFE);     // Light blue tint
  static const Color ink = Color(0xFF0F172A);            // Text, dark bars
  static const Color frost = Color(0xFFEEF2FA);          // Light screen ground

  // Legacy alias — kept to avoid breaking any references
  static const Color darkNavy = ink;                     // Deep navy

  // ─── Background System ────────────────────────────────────────────────────
  static Color get background => isDarkMode ? const Color(0xFF0B1428) : frost;
  static Color get surface => isDarkMode ? const Color(0xFF141E36) : const Color(0xFFFFFFFF);
  static Color get cardBackground => isDarkMode ? const Color(0xFF141E36) : const Color(0xFFFFFFFF);
  static Color get surfaceLight => isDarkMode ? const Color(0xFF1D2944) : const Color(0xFFE2E8F0);
  static Color get surfaceGlass => isDarkMode ? const Color(0x1AFFFFFF) : const Color(0x99FFFFFF);

  // ─── Text Colors ──────────────────────────────────────────────────────────
  static Color get textDark => isDarkMode ? const Color(0xFFF1F5F9) : ink;
  static Color get textLight => isDarkMode ? const Color(0xFFA3B1C6) : const Color(0xFF64748B);
  static Color get textMuted => isDarkMode ? const Color(0xFF8392AB) : const Color(0xFF94A3B8);
  static Color get border => isDarkMode ? const Color(0xFF26334F) : const Color(0xFFCBD5E1);

  /// Blue for selected labels and text links: deeper on frost and lighter
  /// on night glass, so it stays readable in both modes.
  static Color get primaryText => isDarkMode ? const Color(0xFF7FA6FF) : primaryDeep;

  // ─── Glass ────────────────────────────────────────────────────────────────
  // Frosted cards and bars use surfaceGlass with this edge. Smoked glass is
  // for panels over a landscape picture, in both modes.
  static Color get glassBorder => isDarkMode ? const Color(0x24FFFFFF) : const Color(0xD9FFFFFF);
  static const Color glassSmoke = Color(0x800F172A);
  static const Color glassSmokeBorder = Color(0x80FFFFFF);

  // Legacy aliases
  static Color get accentBg => isDarkMode ? const Color(0xFF141E36) : const Color(0xFFFFFFFF);
  @Deprecated('Use AppColors.accentBg instead')
  static Color get accentGreenBg => accentBg;
  @Deprecated('Use AppColors.primary instead')
  static const Color darkGreen = primary;

  // ─── Status Colors ────────────────────────────────────────────────────────
  static const Color pending = Color(0xFFD97706);        // Amber warning
  static const Color warning = pending;                  // Warning alias
  static const Color progress = primary;                 // Blue in-progress
  static const Color solved = Color(0xFF059669);         // Emerald success
  static const Color danger = Color(0xFFDC2626);         // Emergency red · report, call
  static const Color dangerDeep = Color(0xFFB91C1C);     // Emergency gradient end

  // ─── Glow Colors ──────────────────────────────────────────────────────────
  static const Color primaryGlow = primary;
  static const Color cyanGlow = secondary;
  static const Color dangerGlow = danger;
  static const Color successGlow = solved;
  static const Color warningGlow = pending;

  // ─── Premium Gradients ────────────────────────────────────────────────────
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryDeep],
  );

  /// Dusk sky of the landscape backdrop.
  static const Gradient sunsetGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF3F5F9C), Color(0xFF8FA9D2), Color(0xFFF2C6A0)],
  );

  static const Gradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, deepBlue],
  );

  /// Night command-center background (admin sign-in).
  static const Gradient commandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF070D1C), Color(0xFF0B1428)],
  );

  static const Gradient emergencyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [danger, dangerDeep],
  );

  static const Gradient cyanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, primary],
  );

  // ─── Shadow System ────────────────────────────────────────────────────────

  static const Color _shadowTint = Color(0xFF1E2D50);

  /// Soft floating card shadow
  static List<BoxShadow> get soft3dShadow => [
        BoxShadow(
          color: isDarkMode
              ? Colors.black.withValues(alpha: 0.35)
              : _shadowTint.withValues(alpha: 0.14),
          offset: const Offset(0, 12),
          blurRadius: 28,
          spreadRadius: 0,
        ),
      ];

  /// Raised controls (default buttons, chips, icon buttons) float above the glass.
  static List<BoxShadow> get raisedShadow => [
        BoxShadow(
          color: isDarkMode
              ? Colors.black.withValues(alpha: 0.4)
              : _shadowTint.withValues(alpha: 0.16),
          offset: const Offset(0, 8),
          blurRadius: 16,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: isDarkMode
              ? Colors.black.withValues(alpha: 0.3)
              : _shadowTint.withValues(alpha: 0.12),
          offset: const Offset(0, 1),
          blurRadius: 2,
          spreadRadius: 0,
        ),
      ];

  /// A tapped control sinks back towards the glass.
  static List<BoxShadow> get pressedShadow => [
        BoxShadow(
          color: isDarkMode
              ? Colors.black.withValues(alpha: 0.3)
              : _shadowTint.withValues(alpha: 0.12),
          offset: const Offset(0, 2),
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ];

  /// Premium button glow shadow
  static List<BoxShadow> get button3dShadow => primaryGlowShadow;

  /// Primary blue button glow shadow
  static List<BoxShadow> get primaryGlowShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.4),
          offset: const Offset(0, 10),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ];

  /// Emergency/danger glow shadow
  static List<BoxShadow> get dangerGlowShadow => [
        BoxShadow(
          color: danger.withValues(alpha: 0.35),
          offset: const Offset(0, 10),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ];

  /// Success/green glow shadow
  static List<BoxShadow> get successGlowShadow => [
        BoxShadow(
          color: solved.withValues(alpha: 0.3),
          offset: const Offset(0, 8),
          blurRadius: 18,
          spreadRadius: 0,
        ),
      ];

  /// Cyan glow for anything live: active sirens, tracking, the report button
  static List<BoxShadow> get cyanGlowShadow => [
        BoxShadow(
          color: secondary.withValues(alpha: 0.6),
          offset: Offset.zero,
          blurRadius: 22,
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
