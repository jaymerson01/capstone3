import 'dart:math';
import 'package:flutter/material.dart';
import 'package:community_safety_app/core/utils/barangay_sector_helper.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'admin_ui.dart';

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

    return SizedBox(
      height: 330,
      child: AdminPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Dual-View Toggle
            _ChartHeader(
              icon: Icons.pie_chart_outline_rounded,
              tone: AdminTone.violet,
              title: _isCategoryView
                  ? "Incidents by Category"
                  : "Incidents by Sector",
              subtitle: _isCategoryView
                  ? "Emergency taxonomy breakdown"
                  : "Geographic territory distribution",
              inlineMinWidth: 470,
              // Dual-View Toggle Pill
              trailing: AdminSegmented<bool>(
                segments: const [(true, "Category"), (false, "Sector")],
                value: _isCategoryView,
                onChanged: (isCategory) {
                  if (isCategory) {
                    setState(() => _isCategoryView = true);
                  } else {
                    setState(() => _isCategoryView = false);
                  }
                },
              ),
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
                                      fontWeight: FontWeight.w800,
                                      color: AdminColors.textStrong,
                                      height: 1.15,
                                    ),
                                  ),
                                  Text(
                                    "INCIDENTS",
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: AdminColors.textHint,
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
                                              color: d.color
                                                  .withValues(alpha: 0.5),
                                              blurRadius: 5,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 9),
                                      Expanded(
                                        child: Text(
                                          d.label,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AdminColors.textSoft,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "${d.percentage.toStringAsFixed(1)}%",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Icon(
              Icons.hourglass_empty_rounded,
              color: AdminColors.textLight,
              size: 24,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "No recorded incident logs yet",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AdminColors.textLight,
              fontSize: 12.5,
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

/// The chart panel heading: an icon tile, the title and its line, with
/// [trailing] on the right, or under the title when the panel is narrower
/// than [inlineMinWidth].
class _ChartHeader extends StatelessWidget {
  const _ChartHeader({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.inlineMinWidth = 400,
  });

  final IconData icon;
  final AdminTone tone;
  final String title;
  final String subtitle;
  final Widget trailing;
  final double inlineMinWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= inlineMinWidth) {
          return AdminSectionTitle(
            icon: icon,
            tone: tone,
            title: title,
            subtitle: subtitle,
            trailing: trailing,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AdminSectionTitle(
              icon: icon,
              tone: tone,
              title: title,
              subtitle: subtitle,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 48),
              child: trailing,
            ),
          ],
        );
      },
    );
  }
}
