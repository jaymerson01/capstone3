import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';

/// A dashboard figure: the label and a tinted icon tile on top, the number
/// below. [backgroundColor] is the accent that tints the icon tile, and
/// [highlight] washes the whole card red for a live alert.
class StatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final bool highlight;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    this.textColor = Colors.white,
    this.highlight = false,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color accent = widget.backgroundColor;
    final bool highlight = widget.highlight;
    final Color iconColor = highlight
        ? AdminColors.dangerPale
        : Color.lerp(accent, Colors.white, 0.55)!;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: isHovered
            ? Matrix4.translationValues(0.0, -4.0, 0.0)
            : Matrix4.identity(),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: highlight ? null : AdminColors.cardBackground,
          gradient: highlight
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.alphaBlend(
                      AdminColors.critical.withValues(alpha: 0.18),
                      AdminColors.cardBackground,
                    ),
                    Color.alphaBlend(
                      AdminColors.critical.withValues(alpha: 0.06),
                      AdminColors.cardBackground,
                    ),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: highlight
                ? AdminColors.dangerSoft.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: isHovered ? 0.18 : 0.1),
          ),
          boxShadow: [
            if (highlight)
              BoxShadow(
                color: AdminColors.critical.withValues(alpha: 0.18),
                blurRadius: 26,
              ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 32,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: highlight
                          ? AdminColors.dangerPale
                          : AdminColors.textLight,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: highlight ? 0.3 : 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, size: 18, color: iconColor),
                ),
              ],
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                widget.value,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: widget.textColor,
                  height: 1.0,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
