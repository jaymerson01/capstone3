import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:community_safety_app/core/presentation/neo/outer_shadow.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/neo_tokens.dart';

/// One tab of a [NeoBottomNav].
class NeoNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const NeoNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

/// RESQ floating frosted tab bar with the glowing red REPORT button in the
/// middle. The first half of [items] sits left of the button, the rest
/// right. Use with `Scaffold(extendBody: true)` so content shows through.
class NeoBottomNav extends StatelessWidget {
  final List<NeoNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String reportLabel;
  final VoidCallback onReport;
  final IconData reportIcon;

  const NeoBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.reportLabel,
    required this.onReport,
    this.reportIcon = Icons.warning_amber_rounded,
  });

  static const double _barHeight = 76;
  static const double _reportSize = 70;
  static const double _reportRise = 14; // How far the button sits above the bar

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = AppColors.isDarkMode;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final radius = BorderRadius.circular(NeoRadii.panel);
    final leftCount = (items.length + 1) ~/ 2;

    Widget tab(int index) => Expanded(
          child: _NavTab(
            item: items[index],
            selected: index == currentIndex,
            textTheme: textTheme,
            onTap: () => onTap(index),
          ),
        );

    final bar = OuterShadow(
      borderRadius: radius,
      shadows: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.45)
              : const Color(0xFF1E2D50).withValues(alpha: 0.22),
          offset: const Offset(0, 16),
          blurRadius: 34,
        ),
      ],
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: NeoBlur.glass, sigmaY: NeoBlur.glass),
          child: Container(
            height: _barHeight,
            decoration: BoxDecoration(
              color: AppColors.surfaceGlass,
              borderRadius: radius,
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              children: [
                for (var i = 0; i < leftCount; i++) tab(i),
                const SizedBox(width: _reportSize + 8),
                for (var i = leftCount; i < items.length; i++) tab(i),
              ],
            ),
          ),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, bottomInset > 0 ? bottomInset : 16),
      child: SizedBox(
        height: _barHeight + _reportRise,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(left: 0, right: 0, bottom: 0, child: bar),
            Positioned(
              top: 0,
              child: _ReportButton(
                label: reportLabel,
                icon: reportIcon,
                textTheme: textTheme,
                onPressed: onReport,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  final NeoNavItem item;
  final bool selected;
  final TextTheme textTheme;
  final VoidCallback onTap;

  const _NavTab({
    required this.item,
    required this.selected,
    required this.textTheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryText : AppColors.textLight;
    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: selected,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(NeoRadii.card),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? item.selectedIcon : item.icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextTheme textTheme;
  final VoidCallback onPressed;

  const _ReportButton({
    required this.label,
    required this.icon,
    required this.textTheme,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // The glow sits outside the Material: ink is clipped to its box.
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.7),
                blurRadius: 22,
              ),
              BoxShadow(
                color: AppColors.dangerDeep.withValues(alpha: 0.45),
                offset: const Offset(0, 10),
                blurRadius: 22,
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: Ink(
                width: NeoBottomNav._reportSize,
                height: NeoBottomNav._reportSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondary, width: 3),
                  gradient: const RadialGradient(
                    center: Alignment(0, -0.4),
                    radius: 0.72,
                    colors: [Color(0xFFEF4444), AppColors.dangerDeep],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 26),
                    Text(
                      label,
                      maxLines: 1,
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
