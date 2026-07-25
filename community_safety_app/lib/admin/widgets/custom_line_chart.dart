import 'package:flutter/material.dart';

/// RESQ Command Center — Premium Animated Line Chart
class CustomLineChart extends StatefulWidget {
  const CustomLineChart({super.key});

  @override
  State<CustomLineChart> createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _drawController;
  late Animation<double> _drawProgress;

  @override
  void initState() {
    super.initState();
    _drawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _drawProgress = CurvedAnimation(
      parent: _drawController,
      curve: Curves.easeOutCubic,
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _drawController.forward();
    });
  }

  @override
  void dispose() {
    _drawController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1627),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E2D4A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A84FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.trending_up,
                    color: Color(0xFF0A84FF), size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                "Monthly Incidents Trend",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Color(0xFFE8F0FE),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AnimatedBuilder(
              animation: _drawProgress,
              builder: (context, _) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _PremiumLineChartPainter(
                      drawProgress: _drawProgress.value),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem("Theft", const Color(0xFFFF9F0A)),
              const SizedBox(width: 20),
              _legendItem("Accident", const Color(0xFF0A84FF)),
              const SizedBox(width: 20),
              _legendItem("Fire/Violence", const Color(0xFF30D158)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 6,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF7B8DB0),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PremiumLineChartPainter extends CustomPainter {
  final double drawProgress;

  _PremiumLineChartPainter({required this.drawProgress});

  @override
  void paint(Canvas canvas, Size size) {
    const double leftMargin = 38.0;
    const double bottomMargin = 22.0;
    final double graphWidth = size.width - leftMargin;
    final double graphHeight = size.height - bottomMargin;

    // ── Grid lines ──────────────────────────────────────────────────────
    final gridPaint = Paint()
      ..color = const Color(0xFF1E2D4A)
      ..strokeWidth = 0.8;

    final tp = TextPainter(textDirection: TextDirection.ltr);
    final yLabels = ['25', '20', '15', '10', '5'];
    const gridRows = 5;

    for (int i = 0; i < gridRows; i++) {
      double y = (graphHeight / gridRows) * i;
      canvas.drawLine(Offset(leftMargin, y), Offset(size.width, y), gridPaint);
      tp.text = TextSpan(
        text: yLabels[i],
        style: const TextStyle(
            color: Color(0xFF4A5568), fontSize: 9, fontWeight: FontWeight.w500),
      );
      tp.layout();
      tp.paint(canvas, Offset(2, y - 6));
    }

    // ── X-axis ──────────────────────────────────────────────────────────
    canvas.drawLine(
      Offset(leftMargin, graphHeight),
      Offset(size.width, graphHeight),
      Paint()
        ..color = const Color(0xFF1E2D4A)
        ..strokeWidth = 1.0,
    );

    final xLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final xSpacing = graphWidth / (xLabels.length - 1);
    for (int i = 0; i < xLabels.length; i++) {
      double x = leftMargin + xSpacing * i;
      tp.text = TextSpan(
        text: xLabels[i],
        style: const TextStyle(
            color: Color(0xFF4A5568), fontSize: 9, fontWeight: FontWeight.w500),
      );
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, graphHeight + 6));
    }

    // ── Data Series ──────────────────────────────────────────────────────
    double getY(double pct) {
      double factor = pct / 25.0;
      return graphHeight - graphHeight * factor;
    }

    _drawSeries(canvas, [10, 18, 21, 20, 25, 32], const Color(0xFFFF9F0A),
        leftMargin, xSpacing, getY, graphHeight, size, drawProgress);
    _drawSeries(canvas, [5, 10, 12, 8, 10, 9], const Color(0xFF0A84FF),
        leftMargin, xSpacing, getY, graphHeight, size, drawProgress);
    _drawSeries(canvas, [2, 4, 6, 10, 19, 14], const Color(0xFF30D158),
        leftMargin, xSpacing, getY, graphHeight, size, drawProgress);
  }

  void _drawSeries(
    Canvas canvas,
    List<double> values,
    Color color,
    double leftMargin,
    double xSpacing,
    double Function(double) getY,
    double graphHeight,
    Size size,
    double progress,
  ) {
    List<Offset> points = [];
    for (int i = 0; i < values.length; i++) {
      points.add(Offset(leftMargin + xSpacing * i, getY(values[i])));
    }

    // Build full bezier path
    final fullPath = Path();
    final areaPath = Path();
    if (points.isNotEmpty) {
      fullPath.moveTo(points[0].dx, points[0].dy);
      areaPath.moveTo(points[0].dx, points[0].dy);
      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final cpx = p0.dx + (p1.dx - p0.dx) / 2;
        fullPath.cubicTo(cpx, p0.dy, cpx, p1.dy, p1.dx, p1.dy);
        areaPath.cubicTo(cpx, p0.dy, cpx, p1.dy, p1.dx, p1.dy);
      }
      areaPath.lineTo(points.last.dx, graphHeight);
      areaPath.lineTo(points.first.dx, graphHeight);
      areaPath.close();
    }

    // Extract partial path based on drawProgress
    final metrics = fullPath.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final totalLen = metrics.first.length;
    final drawnPath = metrics.first.extractPath(0, totalLen * progress);

    // Area gradient fill
    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.18),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTRB(leftMargin, 0, size.width, graphHeight))
      ..style = PaintingStyle.fill;
    canvas.drawPath(areaPath, areaPaint);

    // Line
    canvas.drawPath(
      drawnPath,
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 0),
    );

    // Glow line
    canvas.drawPath(
      drawnPath,
      Paint()
        ..color = color.withValues(alpha: 0.3)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Dots at each node (only drawn up to progress)
    final visibleCount = (points.length * progress).round().clamp(0, points.length);
    for (int i = 0; i < visibleCount; i++) {
      final pt = points[i];
      canvas.drawCircle(pt, 5,
          Paint()..color = color..style = PaintingStyle.fill);
      canvas.drawCircle(pt, 5,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.15)
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke);
      canvas.drawCircle(
        pt,
        5,
        Paint()
          ..color = color.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PremiumLineChartPainter old) =>
      old.drawProgress != drawProgress;
}
