import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_color.dart';

/// RESQ Command Center — Premium Animated Donut Chart
class CustomPieChart extends StatefulWidget {
  const CustomPieChart({super.key});

  @override
  State<CustomPieChart> createState() => _CustomPieChartState();
}

class _CustomPieChartState extends State<CustomPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _sweepController;
  late Animation<double> _sweepAnim;

  final List<_PieSlice> data = [
    _PieSlice("Moonwalk", 35, Color(0xFF0A84FF)),
    _PieSlice("Jacinto", 20, Color(0xFFFF9F0A)),
    _PieSlice("Purok 7", 15, Color(0xFF00D4FF)),
    _PieSlice("Doang Batang", 10, Color(0xFF6E40C9)),
    _PieSlice("Pepa Compound", 20, Color(0xFF30D158)),
  ];

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _sweepAnim = CurvedAnimation(
      parent: _sweepController,
      curve: Curves.easeOutCubic,
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _sweepController.forward();
    });
  }

  @override
  void dispose() {
    _sweepController.dispose();
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
                child: const Icon(Icons.pie_chart_outline,
                    color: Color(0xFF0A84FF), size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                "Incidents by Area",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Color(0xFFE8F0FE),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: AnimatedBuilder(
                    animation: _sweepAnim,
                    builder: (context, _) {
                      return CustomPaint(
                        size: Size.infinite,
                        painter: _PremiumDonutPainter(
                            data: data, progress: _sweepAnim.value),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: data.map((d) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: d.color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: d.color.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                d.label,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF7B8DB0),
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              "${d.value}%",
                              style: TextStyle(
                                fontSize: 11,
                                color: d.color,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PieSlice {
  final String label;
  final double value;
  final Color color;
  _PieSlice(this.label, this.value, this.color);
}

class _PremiumDonutPainter extends CustomPainter {
  final List<_PieSlice> data;
  final double progress;

  _PremiumDonutPainter({required this.data, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;
    const strokeWidth = 22.0;
    const gapAngle = 0.04;

    final total = data.fold<double>(0, (sum, d) => sum + d.value);
    double startAngle = -pi / 2;

    for (final slice in data) {
      final sweepAngle =
          (slice.value / total) * 2 * pi * progress - gapAngle;
      if (sweepAngle <= 0) continue;

      // Glow layer
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = slice.color.withValues(alpha: 0.3)
          ..strokeWidth = strokeWidth + 8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      // Main arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = slice.color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );

      startAngle += sweepAngle + gapAngle;
    }

    // Center text
    if (progress > 0.8) {
      final tp = TextPainter(
        text: const TextSpan(
          text: "100%",
          style: TextStyle(
            color: Color(0xFFE8F0FE),
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas,
          Offset(center.dx - tp.width / 2, center.dy - tp.height / 2 - 8));

      final tp2 = TextPainter(
        text: const TextSpan(
          text: "Coverage",
          style: TextStyle(
            color: Color(0xFF7B8DB0),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp2.layout();
      tp2.paint(canvas,
          Offset(center.dx - tp2.width / 2, center.dy + tp.height / 2 - 4));
    }
  }

  @override
  bool shouldRepaint(covariant _PremiumDonutPainter old) =>
      old.progress != progress;
}

// Legacy alias kept for backward compat
class PieSliceData {
  final String label;
  final double value;
  final Color color;
  PieSliceData(this.label, this.value, this.color);
}

class DonutChartPainter extends CustomPainter {
  final List<PieSliceData> data;
  DonutChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final painter = _PremiumDonutPainter(
      data: data
          .map((d) => _PieSlice(d.label, d.value, d.color))
          .toList(),
      progress: 1.0,
    );
    painter.paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
