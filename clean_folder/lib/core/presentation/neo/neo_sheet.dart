import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/neo_tokens.dart';

/// RESQ Neo-Tactile bottom sheet: a soft white panel (night glass in dark
/// mode) with a grab handle. Use it as a `showModalBottomSheet` builder's
/// root, with `backgroundColor: Colors.transparent`.
class NeoSheet extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const NeoSheet({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(22, 12, 22, 22),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF1C2742), Color(0xFF141E36)]
              : const [Color(0xFFFFFFFF), Color(0xFFEEF2F7)],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(NeoRadii.panel),
        ),
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: isDark ? 0.5 : 0.25),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
