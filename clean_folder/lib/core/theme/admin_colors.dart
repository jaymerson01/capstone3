import 'package:flutter/material.dart';

/// RESQ Admin Command Center colors. Every color the admin pages use lives
/// here, so the portal can be restyled from this one file.
/// Neo command center: night slate glass, ResQuick blue, live cyan and
/// emergency red, matching the resident app's night style.
class AdminColors {
  // ─── Surfaces ─────────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0A0F1C);
  static const Color cardBackground = Color(0xFF141C2F);
  static const Color surfaceLight = Color(0xFF273246);
  static const Color surfaceRaised = Color(0xFF1A2336);
  static const Color surfaceDeep = Color(0xFF0D1527);
  static const Color heroEnd = Color(0xFF1B2A4A);
  static const Color dialogBackground = Color(0xFF121A2B);
  static const Color well = Color(0xFF0B111D);
  static const Color chartHole = Color(0xFF101828);
  static const Color rowIdle = Color(0xFF111A2C);
  static const Color rowActive = Color(0xFF1C2A48);
  static const Color slate = Color(0xFF1E293B);
  static const Color sirenIdle = Color(0xFF3A1218);

  // ─── Lines ────────────────────────────────────────────────────────────────
  static const Color border = Color(0xFF232C40);
  static const Color borderStrong = Color(0xFF2E3A52);
  static const Color borderHighlight = Color(0xFF3D4B66);

  // ─── Text ─────────────────────────────────────────────────────────────────
  static const Color textStrong = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFFF1F5F9);
  static const Color textSoft = Color(0xFFCBD5E1);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color chartAxis = Color(0xFF94A3B8);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF7D8BA3);
  static const Color textFaint = Color(0xFF64748B);

  // ─── Accents ──────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF2F6BF0);
  static const Color primaryDeep = Color(0xFF1E40AF);
  static const Color primaryText = Color(0xFF93C5FD);
  static const Color cyan = Color(0xFF22D3EE);
  static const Color cyanSoft = Color(0xFF67E8F9);
  static const Color cyanText = Color(0xFFA5F3FC);
  static const Color violet = Color(0xFF8B5CF6);
  static const Color violetDeep = Color(0xFF7C3AED);
  static const Color violetLight = Color(0xFFA78BFA);
  static const Color violetMuted = Color(0xFF6D5BD0);
  static const Color lightTint = Color(0xFFBFDBFE);

  // ─── Status ───────────────────────────────────────────────────────────────
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerDeep = Color(0xFFB91C1C);
  static const Color dangerDark = Color(0xFF991B1B);
  static const Color dangerSoft = Color(0xFFF87171);
  static const Color dangerText = Color(0xFFFCA5A5);
  static const Color dangerPale = Color(0xFFFECACA);
  static const Color critical = Color(0xFFDC2626);
  static const Color success = Color(0xFF22C55E);
  static const Color successText = Color(0xFF86EFAC);
  static const Color orange = Color(0xFFF97316);
  static const Color orangeLight = Color(0xFFFDBA74);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberLight = Color(0xFFFCD34D);
  static const Color yellow = Color(0xFFFACC15);
  static const Color pendingText = Color(0xFFFDE68A);
  static const Color neutral = Color(0xFF94A3B8);

  // ─── Chart series ─────────────────────────────────────────────────────────
  static const Color chartAmber = Color(0xFFFACC15);
  static const Color chartMint = Color(0xFF6EE7B7);
  static const Color chartMagenta = Color(0xFFE879F9);
  static const Color chartAzure = Color(0xFF60A5FA);
  static const Color chartSky = Color(0xFF38BDF8);
  static const Color chartTeal = Color(0xFF2DD4BF);
  static const Color chartOther = Color(0xFF8B98AD);

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
      color: Colors.black.withValues(alpha: 0.3),
      offset: const Offset(0, 14),
      blurRadius: 32,
      spreadRadius: 0,
    ),
  ];

  /// Raised slate buttons in the header and dialogs.
  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      offset: const Offset(0, 6),
      blurRadius: 14,
    ),
  ];

  /// Red glow around siren controls.
  static List<BoxShadow> sirenGlow({double strength = 1}) => [
    BoxShadow(
      color: dangerSoft.withValues(alpha: 0.5 * strength),
      spreadRadius: 1,
    ),
    BoxShadow(
      color: critical.withValues(alpha: 0.45 * strength),
      blurRadius: 22,
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
  /// The page ground: a soft blue glow at the top right fading to night.
  static const Gradient pageGradient = RadialGradient(
    center: Alignment(0.6, -1.0),
    radius: 1.3,
    colors: [heroEnd, surfaceDeep, background],
    stops: [0, 0.55, 1],
  );

  static const Gradient sidebarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF111827), background],
  );

  static const Gradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surfaceDeep, background],
  );

  /// Raised slate buttons (menu, notifications, close).
  static const Gradient buttonGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surfaceLight, Color(0xFF182032)],
  );

  /// Emergency red for siren buttons.
  static const Gradient sirenGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [critical, dangerDeep],
  );

  /// The selected sidebar item: a blue wash fading to the right.
  static const Gradient navActiveGradient = LinearGradient(
    colors: [Color(0x522F6BF0), Color(0x0F2F6BF0)],
  );

  /// The broadcast dialog panel.
  static const Gradient dialogGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xF51E2942), Color(0xF80F1422)],
  );
}
