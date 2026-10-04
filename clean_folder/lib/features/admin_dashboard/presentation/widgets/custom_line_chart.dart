import 'dart:math';
import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';

class CustomLineChart extends StatelessWidget {
  final List<IncidentEntity> incidents;

  const CustomLineChart({super.key, this.incidents = const []});

  @override
  Widget build(BuildContext context) {
    // Generate the last 7 days buckets
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<DateTime> days = List.generate(
      7,
      (i) => today.subtract(Duration(days: 6 - i)),
    );

    // Calculate daily counts
    final List<double> totalCounts = [];
    final List<double> urgentCounts = [];
    final List<double> solvedCounts = [];

    for (final day in days) {
      final nextDay = day.add(const Duration(days: 1));
      final dayIncidents = incidents.where((inc) {
        return inc.timestamp.isAfter(day) && inc.timestamp.isBefore(nextDay);
      }).toList();

      totalCounts.add(dayIncidents.length.toDouble());
      urgentCounts.add(
        dayIncidents
            .where((inc) {
              final prio = (inc.urgencyStatus ?? '').toLowerCase();
              return prio == 'high' ||
                  prio == 'critical' ||
                  inc.upvoteCount >= 3;
            })
            .length
            .toDouble(),
      );
      solvedCounts.add(
        dayIncidents.where((inc) => inc.isSolved).length.toDouble(),
      );
    }

    final double maxVal = [
      ...totalCounts,
      ...urgentCounts,
      ...solvedCounts,
      4.0, // Minimum baseline ceiling
    ].reduce(max);

    final dayLabels = days.map((d) => _dayAbbr(d.weekday)).toList();

    return Container(
      height: 310,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1627),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF1E2D4A).withValues(alpha: 0.8),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.show_chart_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Incident Frequency Trend",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: Color(0xFFE8F0FE),
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Daily report volume (Past 7 Days)",
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF7B8DB0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  "${incidents.length} Total Logs",
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _OledLineChartPainter(
                totalCounts: totalCounts,
                urgentCounts: urgentCounts,
                solvedCounts: solvedCounts,
                dayLabels: dayLabels,
                maxValue: maxVal,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Chart Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem("Total Reports", const Color(0xFF00E5FF)),
              const SizedBox(width: 20),
              _legendItem("Urgent / Critical", const Color(0xFFFF3B30)),
              const SizedBox(width: 20),
              _legendItem("Resolved Cases", const Color(0xFF30D158)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF8DA0C2),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  static String _dayAbbr(int weekday) {
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday];
  }
}

class _OledLineChartPainter extends CustomPainter {
  final List<double> totalCounts;
  final List<double> urgentCounts;
  final List<double> solvedCounts;
  final List<String> dayLabels;
  final double maxValue;

  _OledLineChartPainter({
    required this.totalCounts,
    required this.urgentCounts,
    required this.solvedCounts,
    required this.dayLabels,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    const double leftMargin = 32.0;
    const double bottomMargin = 22.0;
    final double graphWidth = width - leftMargin;
    final double graphHeight = height - bottomMargin;

    final Paint gridPaint = Paint()
      ..color = const Color(0xFF1E2D4A).withValues(alpha: 0.6)
      ..strokeWidth = 1.0;

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    const int gridRows = 4;
    for (int i = 0; i <= gridRows; i++) {
      final double y = (graphHeight / gridRows) * i;
      canvas.drawLine(
        Offset(leftMargin, y),
        Offset(width, y),
        gridPaint,
      );

      final double labelVal = maxValue - ((maxValue / gridRows) * i);
      textPainter.text = TextSpan(
        text: labelVal.round().toString(),
        style: const TextStyle(
          color: Color(0xFF5A6E8C),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(4, y - 6));
    }

    final double xSpacing = graphWidth / (dayLabels.length - 1);
    for (int i = 0; i < dayLabels.length; i++) {
      final double x = leftMargin + (xSpacing * i);
      textPainter.text = TextSpan(
        text: dayLabels[i],
        style: TextStyle(
          color: i == dayLabels.length - 1
              ? const Color(0xFF00E5FF)
              : const Color(0xFF5A6E8C),
          fontSize: 10,
          fontWeight: i == dayLabels.length - 1
              ? FontWeight.w800
              : FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - (textPainter.width / 2), graphHeight + 6),
      );
    }

    double getY(double val) {
      if (maxValue <= 0) return graphHeight;
      final factor = (val / maxValue).clamp(0.0, 1.0);
      return graphHeight - (graphHeight * factor);
    }

    // Draw curves
    _drawCurvedLine(
      canvas: canvas,
      values: solvedCounts,
      color: const Color(0xFF30D158),
      leftMargin: leftMargin,
      xSpacing: xSpacing,
      getY: getY,
      graphHeight: graphHeight,
      fillGradient: false,
    );

    _drawCurvedLine(
      canvas: canvas,
      values: urgentCounts,
      color: const Color(0xFFFF3B30),
      leftMargin: leftMargin,
      xSpacing: xSpacing,
      getY: getY,
      graphHeight: graphHeight,
      fillGradient: false,
    );

    _drawCurvedLine(
      canvas: canvas,
      values: totalCounts,
      color: const Color(0xFF00E5FF),
      leftMargin: leftMargin,
      xSpacing: xSpacing,
      getY: getY,
      graphHeight: graphHeight,
      fillGradient: true,
    );
  }

  void _drawCurvedLine({
    required Canvas canvas,
    required List<double> values,
    required Color color,
    required double leftMargin,
    required double xSpacing,
    required double Function(double) getY,
    required double graphHeight,
    required bool fillGradient,
  }) {
    if (values.isEmpty) return;

    final List<Offset> points = [];
    for (int i = 0; i < values.length; i++) {
      final double x = leftMargin + (xSpacing * i);
      final double y = getY(values[i]);
      points.add(Offset(x, y));
    }

    final Path path = Path();
    final Path areaPath = Path();

    path.moveTo(points[0].dx, points[0].dy);
    areaPath.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];

      final controlX1 = p0.dx + (p1.dx - p0.dx) / 2;
      final controlY1 = p0.dy;
      final controlX2 = p0.dx + (p1.dx - p0.dx) / 2;
      final controlY2 = p1.dy;

      path.cubicTo(controlX1, controlY1, controlX2, controlY2, p1.dx, p1.dy);
      areaPath.cubicTo(controlX1, controlY1, controlX2, controlY2, p1.dx, p1.dy);
    }

    if (fillGradient) {
      areaPath.lineTo(points.last.dx, graphHeight);
      areaPath.lineTo(points.first.dx, graphHeight);
      areaPath.close();

      final Paint areaPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.28),
            color.withValues(alpha: 0.0),
          ],
        ).createShader(
          Rect.fromLTRB(leftMargin, 0, points.last.dx, graphHeight),
        )
        ..style = PaintingStyle.fill;

      canvas.drawPath(areaPath, areaPaint);
    }

    // Line paint
    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawPath(path, linePaint);

    // Points
    final Paint dotFill = Paint()
      ..color = const Color(0xFF0D1627)
      ..style = PaintingStyle.fill;

    final Paint dotBorder = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    for (final pt in points) {
      canvas.drawCircle(pt, 4.0, dotFill);
      canvas.drawCircle(pt, 4.0, dotBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _OledLineChartPainter oldDelegate) => true;
}
