import 'dart:math';
import 'package:flutter/material.dart';
import 'package:community_safety_app/features/incident/domain/entities/incident_entity.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'admin_ui.dart';
import 'package:community_safety_app/core/theme/app_theme.dart';

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

    return SizedBox(
      height: 330,
      child: AdminPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChartHeader(
              icon: Icons.show_chart_rounded,
              tone: AdminTone.blue,
              title: "Incident Frequency Trend",
              subtitle: "Daily report volume (Past 7 Days)",
              inlineMinWidth: 400,
              trailing: AdminPill(
                label: "${incidents.length} Total Logs",
                tone: AdminTone.blue,
              ),
            ),
            SizedBox(height: 18),
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
            SizedBox(height: 12),
            // Chart Legend
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 18,
                runSpacing: 8,
                children: [
                  _legendItem("Total Reports", AdminColors.cyan),
                  _legendItem("Urgent / Critical", AdminColors.danger),
                  _legendItem("Resolved Cases", AdminColors.success),
                ],
              ),
            ),
          ],
        ),
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
        SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AdminColors.textSoft,
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
      ..color = AdminColors.border.withValues(alpha: 0.6)
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
          fontFamily: AppTheme.fontFamily,
          color: AdminColors.chartAxis,
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
          fontFamily: AppTheme.fontFamily,
          color: i == dayLabels.length - 1
              ? AdminColors.cyan
              : AdminColors.chartAxis,
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
      color: AdminColors.success,
      leftMargin: leftMargin,
      xSpacing: xSpacing,
      getY: getY,
      graphHeight: graphHeight,
      fillGradient: false,
    );

    _drawCurvedLine(
      canvas: canvas,
      values: urgentCounts,
      color: AdminColors.danger,
      leftMargin: leftMargin,
      xSpacing: xSpacing,
      getY: getY,
      graphHeight: graphHeight,
      fillGradient: false,
    );

    _drawCurvedLine(
      canvas: canvas,
      values: totalCounts,
      color: AdminColors.cyan,
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
      ..color = AdminColors.cardBackground
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
