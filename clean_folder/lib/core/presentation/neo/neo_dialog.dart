import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/neo_tokens.dart';

/// RESQ Neo-Tactile dialog card: a soft white panel (night glass in dark
/// mode) floating over the dimmed screen. Use it as a `showDialog` builder's
/// root, with the dialog's own content as [child].
class NeoDialog extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const NeoDialog({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(22, 26, 22, 22),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode;
    final radius = BorderRadius.circular(NeoRadii.panel + 2);
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [Color(0xFF1C2742), Color(0xFF141E36)]
                : const [Color(0xFFFFFFFF), Color(0xFFEEF2F7)],
          ),
          border: Border.all(
            color: isDark ? AppColors.glassBorder : Colors.white,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: isDark ? 0.6 : 0.4),
              offset: const Offset(0, 30),
              blurRadius: 60,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Round icon badge at the top of a [NeoDialog]: [icon] on a soft tint of
/// [color].
class NeoDialogIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const NeoDialogIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: AppColors.isDarkMode ? 0.2 : 0.12),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Icon(icon, color: color, size: size * 0.48),
    );
  }
}
