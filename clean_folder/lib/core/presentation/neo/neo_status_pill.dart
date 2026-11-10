import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/neo_tokens.dart';

/// RESQ status pill: a soft tint of [color] with darker text in the same
/// hue. [NeoStatusPill.status] takes the color from `AppColors.statusColor`,
/// so it matches the status colors used everywhere else.
class NeoStatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const NeoStatusPill({super.key, required this.label, required this.color});

  /// [status] is the stored value (e.g. "pending", "in_progress");
  /// [label] is the translated text to show.
  NeoStatusPill.status({super.key, required String status, required this.label})
      : color = AppColors.statusColor(status);

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode;
    final foreground = isDark
        ? Color.lerp(color, Colors.white, 0.45)!
        : Color.lerp(color, AppColors.ink, 0.4)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.22 : 0.14),
        borderRadius: BorderRadius.circular(NeoRadii.pill),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: foreground,
            ),
      ),
    );
  }
}
