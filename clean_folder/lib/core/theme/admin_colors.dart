import 'package:flutter/material.dart';

/// RESQ Admin Command Center colors. Every color the admin pages use lives
/// here, so the portal can be restyled from this one file.
class AdminColors {
  // ─── Surfaces ─────────────────────────────────────────────────────────────
  static const Color background = Color(0xFF060D1A);
  static const Color cardBackground = Color(0xFF0D1627);
  static const Color surfaceLight = Color(0xFF1A2540);
  static const Color surfaceRaised = Color(0xFF131F37);
  static const Color surfaceDeep = Color(0xFF0A1628);
  static const Color heroEnd = Color(0xFF0D2040);
  static const Color dialogBackground = Color(0xFF0A1220);
  static const Color well = Color(0xFF050B14);
  static const Color chartHole = Color(0xFF070E1A);
  static const Color rowIdle = Color(0xFF080F1E);
  static const Color rowActive = Color(0xFF101E38);
  static const Color slate = Color(0xFF1E293B);
  static const Color sirenIdle = Color(0xFF2A0A10);

  // ─── Lines ────────────────────────────────────────────────────────────────
  static const Color border = Color(0xFF1E2D4A);
  static const Color borderStrong = Color(0xFF2A3F60);
  static const Color borderHighlight = Color(0xFF3A4B6B);

  // ─── Text ─────────────────────────────────────────────────────────────────
  static const Color textDark = Color(0xFFE8F0FE);
  static const Color textSoft = Color(0xFFB0C4DE);
  static const Color textHint = Color(0xFF98A6BE);
  static const Color chartAxis = Color(0xFF8DA0C2);
  static const Color textLight = Color(0xFF7B8DB0);
  static const Color textMuted = Color(0xFF5A6E8C);
  static const Color textFaint = Color(0xFF4A5568);

  // ─── Accents ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF0A84FF);
  static const Color cyan = Color(0xFF00E5FF);
  static const Color cyanSoft = Color(0xFF00D4FF);
  static const Color violet = Color(0xFF7C4DFF);
  static const Color violetDeep = Color(0xFF651FFF);
  static const Color violetLight = Color(0xFF9D65FF);
  static const Color violetMuted = Color(0xFF6E40C9);
  static const Color lightTint = Color(0xFFB8E0FF);

  // ─── Status ───────────────────────────────────────────────────────────────
  static const Color danger = Color(0xFFFF3B30);
  static const Color dangerDeep = Color(0xFFC92A2A);
  static const Color dangerSoft = Color(0xFFFF5252);
  static const Color critical = Color(0xFFFF453A);
  static const Color success = Color(0xFF30D158);
  static const Color orange = Color(0xFFFF9500);
  static const Color orangeLight = Color(0xFFFFAB40);
  static const Color amber = Color(0xFFFF9F0A);
  static const Color amberLight = Color(0xFFFFB340);
  static const Color yellow = Color(0xFFFFCC00);
  static const Color neutral = Color(0xFF8E8E93);

  // ─── Chart series ─────────────────────────────────────────────────────────
  static const Color chartAmber = Color(0xFFFFD600);
  static const Color chartMint = Color(0xFF69F0AE);
  static const Color chartMagenta = Color(0xFFE040FB);
  static const Color chartAzure = Color(0xFF448AFF);
  static const Color chartSky = Color(0xFF00B0FF);
  static const Color chartTeal = Color(0xFF1DE9B6);
  static const Color chartOther = Color(0xFF78909C);

  // ─── Older names, kept so existing code reads the same ────────────────────
  static const Color primaryRose = primary;
  static const Color secondaryGreen = cyanSoft;
  static const Color accentGreen = violetMuted;
  static const Color lightGreen = lightTint;

  @Deprecated('Use AdminColors.primaryRose instead')
  static const Color primaryGreen = primaryRose;

  static const Color pendingYellow = amber;
  static const Color progressBlue = primary;
  static const Color solvedGreen = success;
  static const Color dangerRed = danger;

  static const Color cardRed = danger;
  static const Color cardBlue = primary;
  static const Color cardGreen = success;
  static const Color cardYellow = amber;
  static const Color cardViolet = violetMuted;
  static const Color cardCyan = cyanSoft;

  // ─── Shadow System ────────────────────────────────────────────────────────
  static List<BoxShadow> get card3dShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.12),
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
      color: cardBackground,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: border, width: 1),
      boxShadow: card3dShadow,
    );
  }

  // ─── Gradients ────────────────────────────────────────────────────────────
  static const Gradient sidebarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [background, surfaceDeep],
  );

  static const Gradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cardBackground, surfaceDeep],
  );
}
