import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/neo_tokens.dart';

/// RESQ Neo-Tactile dark tray: a slate panel on the light screens for
/// urgent tools and live status (emergency hotlines, the command center,
/// evidence buttons). [live] adds the cyan edge and glow used for anything
/// happening now. Text inside defaults to near-white.
class NeoTray extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool live;

  const NeoTray({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = NeoRadii.card,
    this.live = false,
  });

  static const Gradient fill = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF273246), Color(0xFF151C2A)],
  );

  /// Body text on the tray.
  static const Color soft = Color(0xFFCBD5E1);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: fill,
        borderRadius: BorderRadius.circular(borderRadius),
        border: live
            ? Border.all(
                color: AppColors.secondary.withValues(alpha: 0.55),
                width: 1.5,
              )
            : null,
        boxShadow: [
          if (live)
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.28),
              blurRadius: 26,
            ),
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.32),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: Color(0xFFF8FAFC)),
        child: IconTheme.merge(
          data: const IconThemeData(color: soft),
          child: child,
        ),
      ),
    );
  }
}
