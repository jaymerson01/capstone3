import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:community_safety_app/core/presentation/neo/outer_shadow.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/neo_tokens.dart';

/// Frosted glass for content over the aurora; smoked (dark) glass for
/// panels over a landscape picture.
enum GlassTone { frost, smoke }

/// RESQ Neo-Tactile glass card. [blur] is off by default: list cards use
/// the translucent fill only, and blur is kept for big surfaces (bars,
/// dialogs, the Home hero), where it's worth the cost on low-end phones.
class GlassCard extends StatelessWidget {
  final Widget child;
  final GlassTone tone;
  final bool blur;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.tone = GlassTone.frost,
    this.blur = false,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = NeoRadii.card,
    this.onTap,
  });

  static const List<BoxShadow> _smokeShadow = [
    BoxShadow(color: Color(0x590F172A), offset: Offset(0, 24), blurRadius: 60),
  ];

  @override
  Widget build(BuildContext context) {
    // Depend on the theme so a const card repaints when dark mode flips.
    Theme.of(context);
    final radius = BorderRadius.circular(borderRadius);
    final isSmoke = tone == GlassTone.smoke;

    Widget content = Padding(padding: padding, child: child);
    if (onTap != null) {
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(onTap: onTap, borderRadius: radius, child: content),
      );
    }

    Widget surface = DecoratedBox(
      decoration: BoxDecoration(
        color: isSmoke ? AppColors.glassSmoke : AppColors.surfaceGlass,
        borderRadius: radius,
        border: Border.all(
          color: isSmoke ? AppColors.glassSmokeBorder : AppColors.glassBorder,
          width: isSmoke ? 1.5 : 1,
        ),
      ),
      child: content,
    );
    if (blur) {
      final sigma = isSmoke ? NeoBlur.smoke : NeoBlur.glass;
      surface = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: surface,
        ),
      );
    }

    return OuterShadow(
      shadows: isSmoke ? _smokeShadow : AppColors.soft3dShadow,
      borderRadius: radius,
      child: surface,
    );
  }
}
