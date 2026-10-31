import 'package:flutter/material.dart';
import 'package:community_safety_app/core/presentation/neo/neo_surface.dart';
import 'package:community_safety_app/core/presentation/neo/word_safe_text.dart';

/// Blue for actions, red only for emergencies, raised white for the rest,
/// and slate for buttons on dark trays.
enum NeoButtonVariant { primary, emergency, standard, slate }

/// RESQ Neo-Tactile pill button. Pass `onPressed: null` for the disabled
/// look; [expand] makes it fill the available width.
class NeoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final NeoButtonVariant variant;
  final IconData? icon;
  final bool expand;
  final double height;

  const NeoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = NeoButtonVariant.primary,
    this.icon,
    this.expand = false,
    this.height = 52,
  });

  NeoFill get _fill {
    switch (variant) {
      case NeoButtonVariant.primary:
        return NeoFill.primary;
      case NeoButtonVariant.emergency:
        return NeoFill.emergency;
      case NeoButtonVariant.standard:
        return NeoFill.raised;
      case NeoButtonVariant.slate:
        return NeoFill.slate;
    }
  }

  TextStyle? _labelStyle(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          );

  /// Whether the label fits on one line in a button [width] wide, so a row
  /// of buttons can stack instead when it does not.
  bool fitsOneLine(BuildContext context, double width) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: _labelStyle(context)),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    // 44 of side padding, plus the icon and its gap.
    final needed = painter.width + 44 + (icon == null ? 0 : 28);
    painter.dispose();
    return needed <= width;
  }

  @override
  Widget build(BuildContext context) {
    final fill = _fill;
    final style = ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => NeoSurface.foreground(
          fill,
          enabled: !states.contains(WidgetState.disabled),
        ),
      ),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      elevation: const WidgetStatePropertyAll(0),
      minimumSize: WidgetStatePropertyAll(Size(64, height)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 22, vertical: 8),
      ),
      shape: const WidgetStatePropertyAll(StadiumBorder()),
      textStyle: WidgetStatePropertyAll(_labelStyle(context)),
      backgroundBuilder: NeoSurface.background(fill),
    );

    // Clip.none keeps the shadows, which a background builder would clip.
    // Long labels (often in Filipino, or with large text) wrap before
    // clipping, and never break a word in the middle.
    final text = WordSafeText(
      label,
      maxLines: 3,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
    );
    final button = icon == null
        ? FilledButton(
            onPressed: onPressed,
            style: style,
            clipBehavior: Clip.none,
            child: text,
          )
        : FilledButton.icon(
            onPressed: onPressed,
            style: style,
            clipBehavior: Clip.none,
            icon: Icon(icon, size: 20),
            label: text,
          );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
