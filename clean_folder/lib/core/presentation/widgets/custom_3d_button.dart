import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';

/// RESQ Premium 3D Button — Spring animation, glow, haptic, glassmorphism
class Custom3dButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Gradient? gradient;
  final double height;
  final double? width;
  final double borderRadius;

  const Custom3dButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.gradient,
    this.height = 56.0,
    this.width,
    this.borderRadius = 18.0,
  });

  @override
  State<Custom3dButton> createState() => _Custom3dButtonState();
}

class _Custom3dButtonState extends State<Custom3dButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
  }

  void _onTap() {
    widget.onPressed?.call();
  }

  void _onTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = widget.gradient ??
        (widget.backgroundColor == null ? AppColors.primaryGradient : null);
    final effectiveBgColor = widget.backgroundColor ?? AppColors.primary;
    final effectiveTextColor = widget.textColor ?? Colors.white;
    final isDisabled = widget.onPressed == null;

    // Determine glow color from gradient or background
    Color glowColor = AppColors.primary;
    if (widget.gradient != null) {
      final g = widget.gradient!;
      if (g is LinearGradient && g.colors.isNotEmpty) {
        glowColor = g.colors.first;
      }
    } else if (widget.backgroundColor != null) {
      glowColor = widget.backgroundColor!;
    }

    return GestureDetector(
      onTapDown: isDisabled ? null : _onTapDown,
      onTapUp: isDisabled ? null : _onTapUp,
      onTap: isDisabled ? null : _onTap,
      onTapCancel: isDisabled ? null : _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: widget.width ?? double.infinity,
        height: widget.height,
        color: Colors.transparent,
        alignment: Alignment.center,
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return AnimatedScale(
              scale: _isPressed ? 0.96 : 1.0,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOutBack,
                width: widget.width ?? double.infinity,
                height: widget.height,
                decoration: BoxDecoration(
              color: effectiveGradient == null ? effectiveBgColor : null,
              gradient: effectiveGradient,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: isDisabled
                  ? []
                  : _isPressed
                      ? [
                          BoxShadow(
                            color: glowColor.withValues(alpha: 0.3),
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: glowColor.withValues(
                                alpha: 0.45 * _glowAnimation.value),
                            offset: const Offset(0, 6),
                            blurRadius: 20,
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            offset: const Offset(0, 3),
                            blurRadius: 10,
                          ),
                        ],
            ),
              child: child,
            ),
          );
        },
          child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Stack(
            children: [
              // Glossy shine overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: widget.height * 0.45,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.18),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // Button content
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                        if (widget.icon != null) ...[
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 120),
                            transform: Matrix4.identity()
                              ..translate(
                                  _isPressed ? 2.0 : 0.0, _isPressed ? 1.0 : 0.0),
                            child: Icon(
                              widget.icon,
                              color: isDisabled
                                  ? effectiveTextColor.withValues(alpha: 0.5)
                                  : effectiveTextColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          widget.text,
                          style: TextStyle(
                            color: isDisabled
                                ? effectiveTextColor.withValues(alpha: 0.5)
                                : effectiveTextColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
