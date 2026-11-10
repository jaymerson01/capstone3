import 'package:flutter/material.dart';
import 'package:community_safety_app/core/presentation/neo/neo_surface.dart';

/// Raised white for light surfaces; slate for dark trays and headers.
enum NeoIconButtonTone { raised, slate }

/// RESQ Neo-Tactile round icon button. [tooltip] is also what screen
/// readers announce, so it's required.
class NeoIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final NeoIconButtonTone tone;
  final double size;

  const NeoIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.tone = NeoIconButtonTone.raised,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    // Depend on the theme so a const button repaints when dark mode flips.
    Theme.of(context);
    final fill =
        tone == NeoIconButtonTone.slate ? NeoFill.slate : NeoFill.raised;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
      style: ButtonStyle(
        backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => NeoSurface.foreground(
            fill,
            enabled: !states.contains(WidgetState.disabled),
          ),
        ),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        fixedSize: WidgetStatePropertyAll(Size.square(size)),
        minimumSize: WidgetStatePropertyAll(Size.square(size)),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        iconSize: WidgetStatePropertyAll(size * 0.43),
        shape: const WidgetStatePropertyAll(CircleBorder()),
        backgroundBuilder: NeoSurface.background(fill, circle: true),
      ),
    );
  }
}
