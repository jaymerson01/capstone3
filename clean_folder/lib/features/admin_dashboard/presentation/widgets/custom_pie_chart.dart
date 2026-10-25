import 'dart:math';
import 'package:flutter/material.dart';
import 'package:community_safety_app/core/utils/barangay_sector_helper.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';

class CustomPieChart extends StatefulWidget {
  final List<IncidentEntity> incidents;

  const CustomPieChart({super.key, this.incidents = const []});

  @override
  State<CustomPieChart> createState() => _CustomPieChartState();
}

class _CustomPieChartState extends State<CustomPieChart> {
  bool _isCategoryView = true;

  // Curated harmonious neon palette for OLED dark mode
  static const List<Color> _palette = [
    AdminColors.cyan, // Cyan
    AdminColors.dangerSoft, // Coral Red
    AdminColors.chartAmber, // Amber
    AdminColors.chartMint, // Mint Green
    AdminColors.chartMagenta, // Magenta
    AdminColors.chartAzure, // Azure Blue
    AdminColors.orangeLight, // Orange
    AdminColors.violet, // Purple
    AdminColors.chartSky, // Light Blue
    AdminColors.chartTeal, // Teal
  ];

  @override
  Widget build(BuildContext context) {
    final List<PieSliceData> slices = _computeSlices();

    return Container(
      height: 310,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AdminColors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AdminColors.border.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Dual-View Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AdminColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AdminColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.pie_chart_outline_rounded,
                      color: AdminColors.primary,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isCategoryView
                            ? "Incidents by Category"
                            : "Incidents by Sector",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: AdminColors.textDark,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        _isCategoryView
                            ? "Emergency taxonomy breakdown"
                            : "Geographic territory distribution",
                        style: const TextStyle(
                          fontSize: 11,
                          color: AdminColors.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Dual-View Toggle Pill
              Container(
                decoration: BoxDecoration(
                  color: AdminColors.chartHole,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AdminColors.border),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _toggleButton("Category", _isCategoryView, () {
                      setState(() => _isCategoryView = true);
                    }),
                    _toggleButton("Sector", !_isCategoryView, () {
                      setState(() => _isCategoryView = false);
                    }),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18),

          // Donut & Legend Content
          Expanded(
            child: slices.isEmpty
                ? _buildEmptyState()
                : Row(
                    children: [
                      // Donut Chart with Center Count Label
                      Expanded(
                        flex: 5,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(180, 180),
                              painter: _DonutChartPainter(slices),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${widget.incidents.length}",
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: AdminColors.textDark,
                                  ),
                                ),
                                Text(
                                  "INCIDENTS",
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: AdminColors.textMuted,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16),
                      // Legend List
                      Expanded(
                        flex: 6,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: slices.map((d) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 9,
                                      height: 9,
                                      decoration: BoxDecoration(
                                        color: d.color,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                d.color.withValues(alpha: 0.5),
                                            blurRadius: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        d.label,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AdminColors.textSoft,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      "${d.percentage.toStringAsFixed(1)}%",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: d.color,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton(String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AdminColors.primary.withValues(alpha: 0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AdminColors.primary.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? AdminColors.cyan : AdminColors.textLight,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.hourglass_empty_rounded,
            color: AdminColors.textMuted.withValues(alpha: 0.5),
            size: 36,
          ),
          SizedBox(height: 10),
          Text(
            "No recorded incident logs yet",
            style: TextStyle(
              color: AdminColors.textLight,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<PieSliceData> _computeSlices() {
    if (widget.incidents.isEmpty) return [];

    final Map<String, int> counts = {};
    for (final inc in widget.incidents) {
      final key = _isCategoryView
          ? (inc.category.isEmpty ? 'General' : inc.category)
          : BarangaySectorHelper.normalizeSector(
              inc.areaSector,
              inc.resolvedAddress,
            );
      counts[key] = (counts[key] ?? 0) + 1;
    }

    final total = widget.incidents.length;
    // Sort descending by count
    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Limit to top 6 items + "Others"
    final List<PieSliceData> result = [];
    int otherCount = 0;

    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      if (i < 5 || sortedEntries.length <= 6) {
        final pct = (entry.value / total) * 100.0;
        final color = _palette[i % _palette.length];
        result.add(PieSliceData(entry.key, pct, color));
      } else {
        otherCount += entry.value;
      }
    }

    if (otherCount > 0) {
      final pct = (otherCount / total) * 100.0;
      result.add(PieSliceData("Others", pct, AdminColors.chartOther));
    }

    return result;
  }
}

class PieSliceData {
  final String label;
  final double percentage;
  final Color color;

  PieSliceData(this.label, this.percentage, this.color);
}

class _DonutChartPainter extends CustomPainter {
  final List<PieSliceData> data;

  _DonutChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final double center = min(size.width, size.height) / 2;
    final Offset centerPoint = Offset(size.width / 2, size.height / 2);
    final double radius = center * 0.95;
    final double thickness = radius * 0.38;

    final Rect rect =
        Rect.fromCircle(center: centerPoint, radius: radius - (thickness / 2));

    double startAngle = -pi / 2;
    const double gapAngle = 0.04;

    for (final slice in data) {
      final double sweepAngle = (slice.percentage / 100.0) * 2 * pi;

      final Paint paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;

      // Glow effect for slices
      final Paint glowPaint = Paint()
        ..color = slice.color.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness + 4
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      if (sweepAngle > gapAngle * 2) {
        canvas.drawArc(
          rect,
          startAngle + gapAngle,
          sweepAngle - gapAngle * 2,
          false,
          glowPaint,
        );
        canvas.drawArc(
          rect,
          startAngle + gapAngle,
          sweepAngle - gapAngle * 2,
          false,
          paint,
        );
      } else {
        canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}
