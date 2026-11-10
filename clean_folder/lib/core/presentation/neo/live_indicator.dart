import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';

/// RESQ "live" marker in Live Cyan, for active sirens, tracking and
/// anything happening now: a glowing dot, or [LiveIndicator.ring] around
/// an icon. Decorative unless [semanticLabel] is given.
class LiveIndicator extends StatelessWidget {
  final double size;
  final bool _ring;
  final Widget? child;
  final String? semanticLabel;

  const LiveIndicator({super.key, this.size = 8, this.semanticLabel})
      : _ring = false,
        child = null;

  /// A dark disc with a cyan edge and glow; [child] sits in the middle.
  const LiveIndicator.ring({
    super.key,
    this.size = 58,
    this.child,
    this.semanticLabel,
  }) : _ring = true;

  @override
  Widget build(BuildContext context) {
    final Widget indicator = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _ring ? AppColors.ink : AppColors.secondary,
        border: _ring
            ? Border.all(color: AppColors.secondary, width: size >= 60 ? 3 : 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: _ring ? 0.6 : 0.9),
            blurRadius: _ring ? size * 0.35 : size,
          ),
        ],
      ),
      child: _ring
          ? IconTheme.merge(
              data: IconThemeData(color: AppColors.secondary, size: size * 0.46),
              child: child ?? const SizedBox.shrink(),
            )
          : null,
    );
    final label = semanticLabel;
    if (label == null) return ExcludeSemantics(child: indicator);
    return Semantics(label: label, child: ExcludeSemantics(child: indicator));
  }
}
