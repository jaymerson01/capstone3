import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/neo_tokens.dart';

/// RESQ small tinted tag with an icon, for facts about a report such as
/// "For: Maria", "ETA: 5 min" or the area sector. The text is a darker
/// shade of [color] (lighter at night) so it stays readable on the tint.
class NeoTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const NeoTag({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode;
    final foreground = isDark
        ? Color.lerp(color, Colors.white, 0.45)!
        : Color.lerp(color, AppColors.ink, 0.35)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.22 : 0.13),
        borderRadius: BorderRadius.circular(NeoRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: foreground),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
