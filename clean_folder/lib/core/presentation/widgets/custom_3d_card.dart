import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';

/// RESQ Premium Glass Card — Glassmorphism, blur, gradient border, lift animation
class Custom3dCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;
  final Color? glowColor;
  final bool enableHoverLift;

  const Custom3dCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18.0),
    this.margin = const EdgeInsets.only(bottom: 14.0),
    this.borderRadius = 20.0,
    this.backgroundColor = AppColors.cardBackground,
    this.borderColor = AppColors.border,
    this.onTap,
    this.boxShadow,
    this.glowColor,
    this.enableHoverLift = true,
  });

  @override
  State<Custom3dCard> createState() => _Custom3dCardState();
}

class _Custom3dCardState extends State<Custom3dCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final Color effectiveGlow = widget.glowColor ?? AppColors.primary;
    final bool interactive = widget.onTap != null;

    return Padding(
      padding: widget.margin,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: interactive ? (_) => setState(() => _isPressed = true) : null,
          onTapUp: interactive ? (_) => setState(() => _isPressed = false) : null,
          onTapCancel: interactive ? () => setState(() => _isPressed = false) : null,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()
              ..translate(
                0.0,
                widget.enableHoverLift
                    ? (_isPressed
                        ? 2.0
                        : _isHovered
                            ? -4.0
                            : 0.0)
                    : 0.0,
              ),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: _isHovered
                    ? effectiveGlow.withValues(alpha: 0.35)
                    : widget.borderColor,
                width: _isHovered ? 1.5 : 1.0,
              ),
              boxShadow: widget.boxShadow ??
                  [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(0, 8),
                      blurRadius: 24,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: effectiveGlow.withValues(
                        alpha: (_isHovered ? 0.18 : 0.08),
                      ),
                      offset: const Offset(0, 4),
                      blurRadius: 16,
                      spreadRadius: 0,
                    ),
                    if (_isHovered)
                      BoxShadow(
                        color: effectiveGlow.withValues(alpha: 0.12),
                        offset: const Offset(0, 0),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                  ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Stack(
                children: [
                  // Subtle top-left glass highlight
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.12),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Main content
                  Padding(
                    padding: widget.padding,
                    child: widget.child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glassmorphism blur card for overlay panels
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final double blurSigma;
  final Color? glowColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18.0),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 20.0,
    this.blurSigma = 12.0,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: (glowColor ?? Colors.white).withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
