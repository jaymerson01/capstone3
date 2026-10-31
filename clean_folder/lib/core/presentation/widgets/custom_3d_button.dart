import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';

/// RESQ Premium 3D Button — Neo-Tactile raised gradient, soft colored glow,
/// press-in, haptic, and a guard against accidental double taps.
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

  /// Optional edge, e.g. white on a translucent glass button.
  final Color? borderColor;

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
    this.borderColor,
  });

  @override
  State<Custom3dButton> createState() => _Custom3dButtonState();
}

class _Custom3dButtonState extends State<Custom3dButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
  }

  DateTime? _lastTapTime;

  void _onTap() {
    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 600)) {
      return; // Debounce rapid multi-taps
    }
    _lastTapTime = now;
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
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            width: widget.width ?? double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              color: effectiveGradient == null
                  ? (isDisabled
                      ? effectiveBgColor.withValues(alpha: 0.5)
                      : effectiveBgColor)
                  : (isDisabled ? effectiveBgColor.withValues(alpha: 0.5) : null),
              gradient: isDisabled ? null : effectiveGradient,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: widget.borderColor == null
                  ? null
                  : Border.all(color: widget.borderColor!, width: 1.5),
              // Raised: a soft glow in the button's own color. Pressed: it
              // sinks back towards the surface.
              boxShadow: isDisabled
                  ? const []
                  : [
                      BoxShadow(
                        color: glowColor.withValues(alpha: _isPressed ? 0.3 : 0.4),
                        offset: Offset(0, _isPressed ? 4 : 10),
                        blurRadius: _isPressed ? 10 : 22,
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Stack(
                children: [
                  // Soft top highlight
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: widget.height * 0.45,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white
                                .withValues(alpha: isDisabled ? 0.06 : 0.16),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Button content
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: isDisabled
                                  ? effectiveTextColor.withValues(alpha: 0.5)
                                  : effectiveTextColor,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                          ],
                          // Long labels (Filipino, large text) shrink to fit
                          // instead of being cut off.
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                widget.text,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isDisabled
                                      ? effectiveTextColor.withValues(alpha: 0.5)
                                      : effectiveTextColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
