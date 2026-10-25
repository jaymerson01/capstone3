import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';

/// RESQ Premium Text Field — Animated neon focus ring, glass surface, icon glow
class Custom3dTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  /// Light text, a clear fill and a white edge, for fields on smoked glass
  /// over a landscape (the sign-in screens).
  final bool onGlass;

  const Custom3dTextField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.onGlass = false,
  });

  @override
  State<Custom3dTextField> createState() => _Custom3dTextFieldState();
}

class _Custom3dTextFieldState extends State<Custom3dTextField>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _focusNode.addListener(() {
      final focused = _focusNode.hasFocus;
      setState(() => _isFocused = focused);
      if (focused) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.value = 0;
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glass = widget.onGlass;
    final accent = glass ? AppColors.secondaryLight : AppColors.primary;
    final quiet = glass ? Colors.white.withValues(alpha: 0.78) : AppColors.textLight;
    final error = glass ? AppColors.dangerLight : AppColors.danger;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: glass
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isFocused
                  ? accent.withValues(
                      alpha: 0.6 + (0.4 * _pulseAnimation.value))
                  : (glass
                      ? Colors.white.withValues(alpha: 0.6)
                      : AppColors.border),
              width: _isFocused ? 2 : (glass ? 1.5 : 1),
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: accent.withValues(
                          alpha: 0.25 * _pulseAnimation.value),
                      offset: const Offset(0, 0),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                    if (!glass)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        offset: const Offset(0, 4),
                        blurRadius: 12,
                      ),
                  ]
                : [
                    if (!glass)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                      ),
                  ],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            validator: widget.validator,
            onChanged: widget.onChanged,
            cursorColor: accent,
            style: TextStyle(
              color: glass ? Colors.white : AppColors.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: TextStyle(
                color: _isFocused ? accent : quiet,
                fontWeight: _isFocused ? FontWeight.w600 : FontWeight.w400,
                fontSize: 14,
              ),
              hintText: widget.hintText,
              hintStyle: TextStyle(color: quiet, fontSize: 14),
              prefixIcon: widget.prefixIcon != null
                  ? AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        widget.prefixIcon,
                        color: _isFocused
                            ? accent
                            : (glass
                                ? Colors.white.withValues(alpha: 0.9)
                                : AppColors.textLight),
                        size: 20,
                      ),
                    )
                  : null,
              suffixIcon: widget.suffixIcon,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              filled: true,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: error, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: error, width: 2),
              ),
              errorStyle: TextStyle(color: error,
                fontSize: 12,
              ),
            ),
          ),
        );
      },
    );
  }
}
