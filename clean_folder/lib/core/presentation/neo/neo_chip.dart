import 'package:flutter/material.dart';
import 'package:community_safety_app/core/presentation/neo/neo_surface.dart';

/// RESQ Neo-Tactile filter chip: blue when [selected], raised white
/// otherwise. Screen readers hear it as a selected (or not) button.
class NeoChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onPressed;
  final IconData? icon;

  const NeoChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final fill = selected ? NeoFill.primary : NeoFill.raised;
    final style = ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => NeoSurface.foreground(
          fill,
          enabled: !states.contains(WidgetState.disabled),
        ),
      ),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      minimumSize: const WidgetStatePropertyAll(Size(48, 36)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      shape: const WidgetStatePropertyAll(StadiumBorder()),
      textStyle: WidgetStatePropertyAll(
        Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
      ),
      backgroundBuilder: NeoSurface.background(fill),
    );

    // Long labels (often in Filipino) wrap to a second line before clipping.
    final text = Text(
      label,
      maxLines: 2,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
    );
    return MergeSemantics(
      child: Semantics(
        selected: selected,
        child: icon == null
            ? TextButton(
                onPressed: onPressed,
                style: style,
                clipBehavior: Clip.none,
                child: text,
              )
            : TextButton.icon(
                onPressed: onPressed,
                style: style,
                clipBehavior: Clip.none,
                icon: Icon(icon, size: 16),
                label: text,
              ),
      ),
    );
  }
}
