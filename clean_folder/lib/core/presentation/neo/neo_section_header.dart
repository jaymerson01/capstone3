import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';

/// RESQ section label: small caps in secondary text, with an optional
/// action on the right (e.g. "See all"). Screen readers hear [title] as a
/// heading, in its normal case.
class NeoSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const NeoSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final action = actionLabel;
    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            label: title,
            child: ExcludeSemantics(
              child: Text(
                title.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.textLight,
                ),
              ),
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryText,
              textStyle: textTheme.labelLarge?.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(action),
          ),
      ],
    );
  }
}
