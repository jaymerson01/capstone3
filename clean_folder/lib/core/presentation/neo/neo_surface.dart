import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/neo_tokens.dart';

/// Fills for Neo-Tactile controls: blue for actions, red only for
/// emergencies, raised white (or night glass) for everything else, and
/// slate for buttons on dark trays and headers.
enum NeoFill { primary, emergency, raised, slate }

/// RESQ Neo-Tactile control surfaces, shared by the Neo buttons and chips.
class NeoSurface {
  /// The decoration of a control in its current [states]: raised at rest,
  /// sunk in while pressed, flat when disabled, cyan ring on focus.
  static BoxDecoration decoration(
    NeoFill fill,
    Set<WidgetState> states, {
    bool circle = false,
  }) {
    final pressed = states.contains(WidgetState.pressed);
    final focused = states.contains(WidgetState.focused);
    final isDark = AppColors.isDarkMode;

    Color? color;
    Gradient? gradient;
    Color? edge;
    var shadows = pressed ? AppColors.pressedShadow : const <BoxShadow>[];

    if (states.contains(WidgetState.disabled)) {
      color = AppColors.surfaceLight;
      shadows = const [];
    } else {
      switch (fill) {
        case NeoFill.primary:
          gradient = pressed ? _primaryPressed : AppColors.primaryGradient;
          if (!pressed) shadows = AppColors.primaryGlowShadow;
        case NeoFill.emergency:
          gradient = pressed ? _emergencyPressed : AppColors.emergencyGradient;
          if (!pressed) shadows = AppColors.dangerGlowShadow;
        case NeoFill.raised:
          gradient = isDark
              ? (pressed ? _nightPressed : _nightRaised)
              : (pressed ? _frostPressed : _frostRaised);
          edge = AppColors.glassBorder;
          if (!pressed) shadows = AppColors.raisedShadow;
        case NeoFill.slate:
          gradient = pressed ? _slatePressed : _slateRaised;
          if (!pressed) shadows = _slateShadow;
      }
    }
    if (focused) edge = AppColors.secondary;

    return BoxDecoration(
      color: color,
      gradient: gradient,
      shape: circle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: circle ? null : BorderRadius.circular(NeoRadii.pill),
      border: edge == null ? null : Border.all(color: edge, width: focused ? 2 : 1),
      boxShadow: shadows,
    );
  }

  /// Label and icon color on a [NeoFill]; [enabled] false gives the
  /// disabled text color.
  static Color foreground(NeoFill fill, {bool enabled = true}) {
    if (!enabled) {
      return AppColors.isDarkMode ? AppColors.textMuted : const Color(0xFF475569);
    }
    switch (fill) {
      case NeoFill.primary:
      case NeoFill.emergency:
        return Colors.white;
      case NeoFill.raised:
        return AppColors.textDark;
      case NeoFill.slate:
        return const Color(0xFFE2E8F0);
    }
  }

  /// A sunken well in the glass for text fields and search bars, with a
  /// blue edge while [focused].
  static BoxDecoration inset({
    double radius = NeoRadii.pill,
    bool focused = false,
  }) {
    final isDark = AppColors.isDarkMode;
    final well = isDark ? const Color(0xFF0F1830) : const Color(0xFFEEF2F7);
    // The shade along the top makes the well look pressed into the glass.
    final shade = Colors.black.withValues(alpha: isDark ? 0.25 : 0.07);
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color.alphaBlend(shade, well), well],
        stops: const [0, 0.3],
      ),
      border: Border.all(
        color: focused
            ? AppColors.primary
            : (isDark ? AppColors.glassBorder : const Color(0xFFE2E8F0)),
        width: focused ? 1.5 : 1,
      ),
    );
  }

  /// [decoration] as a button background that animates between states,
  /// for `ButtonStyle.backgroundBuilder`.
  static ButtonLayerBuilder background(NeoFill fill, {bool circle = false}) {
    return (context, states, child) => AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          decoration: decoration(fill, states, circle: circle),
          child: child,
        );
  }
}

const Gradient _primaryPressed = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [AppColors.primaryDeep, Color(0xFF1F4AC0)],
);

const Gradient _emergencyPressed = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [AppColors.dangerDeep, Color(0xFF991B1B)],
);

const Gradient _frostRaised = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFFFFFFF), Color(0xFFEDF1F6)],
);

const Gradient _frostPressed = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFEDF1F6), Color(0xFFE2E8F0)],
);

const Gradient _nightRaised = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF26334F), Color(0xFF1C2742)],
);

const Gradient _nightPressed = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF1C2742), Color(0xFF172036)],
);

const Gradient _slateRaised = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF5B6578), Color(0xFF394254)],
);

const Gradient _slatePressed = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF394254), Color(0xFF2E3646)],
);

const List<BoxShadow> _slateShadow = [
  BoxShadow(color: Color(0x66000000), offset: Offset(0, 5), blurRadius: 12),
];
