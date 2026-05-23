import 'dart:math';
import 'package:flutter/material.dart';

class CustomPieChart extends StatelessWidget {
  const CustomPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Dataset aligned with screenshot:
    // Moonwalk: 35%, Jacinto: 20%, Purok 7: 15%, Doang Batang: 10%, Pepa Compound: 20%
    final List<PieSliceData> data = [
      PieSliceData("Moonwalk", 35, Colors.blue.shade400),
      PieSliceData("Jacinto", 20, Colors.orange.shade300),
      PieSliceData("Purok 7", 15, Colors.teal.shade300),
      PieSliceData("Doang Batang", 10, Colors.lightBlue.shade200),
      PieSliceData("Pepa Compound", 20, Colors.amber.shade300),
    ];

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Incidents by Area Distribution",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: DonutChartPainter(data),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: data.map((d) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: d.color,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  d.label,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1E293B),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                "${d.percentage}%",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
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
}

class PieSliceData {
  final String label;
  final double percentage;
  final Color color;

  PieSliceData(this.label, this.percentage, this.color);
}

class DonutChartPainter extends CustomPainter {
  final List<PieSliceData> data;

  DonutChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final double center = min(size.width, size.height) / 2;
    final Offset centerPoint = Offset(size.width / 2, size.height / 2);
    final double radius = center * 0.9;
    final double thickness = radius * 0.45; // Width of donut ring

    final Rect rect = Rect.fromCircle(center: centerPoint, radius: radius - (thickness / 2));

    double startAngle = -pi / 2; // Start drawing from the top (12 o'clock)

    for (var slice in data) {
      final double sweepAngle = (slice.percentage / 100.0) * 2 * pi;

      final Paint paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness
        ..isAntiAlias = true;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }

    // Optional: Draw outer and inner borders for an ultra clean look
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Outer border
    canvas.drawCircle(centerPoint, radius, borderPaint);

    // Inner border
    canvas.drawCircle(centerPoint, radius - thickness, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
