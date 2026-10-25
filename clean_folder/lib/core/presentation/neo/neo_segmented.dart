import 'package:flutter/material.dart';
import 'package:community_safety_app/core/presentation/neo/neo_surface.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/neo_tokens.dart';

/// One option of a [NeoSegmented].
class NeoSegment<T> {
  final T value;
  final String label;

  const NeoSegment({required this.value, required this.label});
}

/// RESQ Neo-Tactile segmented control: a sunken track with the selected
/// segment raised, e.g. "Myself / For Someone" on Report Incident.
class NeoSegmented<T> extends StatelessWidget {
  final List<NeoSegment<T>> segments;
  final T selected;
  final ValueChanged<T>? onChanged;

  const NeoSegmented({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        );
    final track = AppColors.surfaceLight;
    final shade = Colors.black.withValues(alpha: AppColors.isDarkMode ? 0.2 : 0.07);

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(NeoRadii.pill),
        // The shade along the top makes the track look sunk into the glass.
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.alphaBlend(shade, track), track],
          stops: const [0, 0.35],
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < segments.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: _Segment(
                label: segments[i].label,
                selected: segments[i].value == selected,
                textStyle: textStyle,
                onPressed: onChanged == null
                    ? null
                    : () => onChanged!(segments[i].value),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final TextStyle? textStyle;
  final VoidCallback? onPressed;

  const _Segment({
    required this.label,
    required this.selected,
    required this.textStyle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        selected: selected,
        inMutuallyExclusiveGroup: true,
        child: TextButton(
          onPressed: onPressed,
          clipBehavior: Clip.none,
          style: ButtonStyle(
            backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
            foregroundColor: WidgetStatePropertyAll(
              selected
                  ? (AppColors.isDarkMode ? Colors.white : AppColors.deepBlue)
                  : AppColors.textLight,
            ),
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            minimumSize: const WidgetStatePropertyAll(Size(0, 40)),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 12),
            ),
            shape: const WidgetStatePropertyAll(StadiumBorder()),
            textStyle: WidgetStatePropertyAll(textStyle),
            backgroundBuilder: (context, states, child) {
              final BoxDecoration decoration;
              if (selected) {
                // Raised even when disabled: it still shows the choice.
                decoration = NeoSurface.decoration(
                  NeoFill.raised,
                  states.difference({WidgetState.disabled}),
                );
              } else {
                final focused = states.contains(WidgetState.focused);
                decoration = BoxDecoration(
                  borderRadius: BorderRadius.circular(NeoRadii.pill),
                  border: focused
                      ? Border.all(color: AppColors.secondary, width: 2)
                      : null,
                );
              }
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                decoration: decoration,
                child: child,
              );
            },
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
