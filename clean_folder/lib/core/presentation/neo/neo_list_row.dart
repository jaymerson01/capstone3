import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/neo_tokens.dart';

/// RESQ settings-style row: icon tile, title, optional subtitle, and a
/// chevron (or [trailing], e.g. a switch). Put rows in a GlassCard with
/// zero padding and Dividers between them for a grouped list.
class NeoListRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  const NeoListRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = AppColors.isDarkMode;
    final accent = destructive ? AppColors.danger : AppColors.primaryText;
    final subtitleText = subtitle;

    return MergeSemantics(
      child: Semantics(
        button: onTap != null,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: destructive
                          ? AppColors.danger.withValues(alpha: 0.1)
                          : (isDark ? AppColors.surfaceLight : const Color(0xFFEEF2F7)),
                      borderRadius: BorderRadius.circular(NeoRadii.tile),
                    ),
                    child: Icon(icon, size: 18, color: accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: textTheme.bodyLarge?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: destructive ? AppColors.danger : AppColors.textDark,
                          ),
                        ),
                        if (subtitleText != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitleText,
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null)
                    trailing!
                  else if (onTap != null)
                    Icon(Icons.chevron_right_rounded, color: AppColors.textLight),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
