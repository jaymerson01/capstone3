import 'package:flutter/material.dart';

class CustomLineChart extends StatelessWidget {
  const CustomLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Monthly Incidents Trend",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: LineChartPainter(),
            ),
          ),
          const SizedBox(height: 15),
          // Chart Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              legendItem("Theft", Colors.orange),
              const SizedBox(width: 24),
              legendItem("Accident", Colors.blue),
              const SizedBox(width: 24),
              legendItem("Fire/Violence", Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget legendItem(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    // Draw Grid Lines and Y-Axis labels
    final Paint gridPaint = Paint()
      ..color = Colors.grey.shade100
      ..strokeWidth = 1.0;

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    const int gridRows = 5;
    final List<String> yLabels = ['25%', '20%', '15%', '10%', '5%'];
    
    // Available drawing area offset for labels
    const double leftMargin = 35.0;
    const double bottomMargin = 20.0;
    final double graphWidth = width - leftMargin;
    final double graphHeight = height - bottomMargin;

    // Draw horizontal grid lines
    for (int i = 0; i < gridRows; i++) {
      double y = (graphHeight / gridRows) * i;
      canvas.drawLine(
        Offset(leftMargin, y),
        Offset(width, y),
        gridPaint,
      );

      // Y-axis label text
      textPainter.text = TextSpan(
        text: yLabels[i],
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - 6));
    }

    // X-axis baseline
    canvas.drawLine(
      Offset(leftMargin, graphHeight),
      Offset(width, graphHeight),
      Paint()
        ..color = Colors.grey.shade200
        ..strokeWidth = 1.0,
    );

    // Draw X-axis labels (months)
    final List<String> xLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final double xSpacing = graphWidth / (xLabels.length - 1);
    for (int i = 0; i < xLabels.length; i++) {
      double x = leftMargin + (xSpacing * i);
      textPainter.text = TextSpan(
        text: xLabels[i],
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - (textPainter.width / 2), graphHeight + 6));
    }

    // Available height function
    double getCorrectY(double percentage) {
      double pctFactor = percentage / 25.0;
      return graphHeight - (graphHeight * pctFactor);
    }

    final List<double> orangePoints = [10.0, 18.0, 21.0, 20.0, 25.0, 32.0];
    final List<double> bluePoints = [5.0, 10.0, 12.0, 8.0, 10.0, 9.0];
    final List<double> greenPoints = [2.0, 4.0, 6.0, 10.0, 19.0, 14.0];

    drawLineGraph(canvas, orangePoints, Colors.orange, leftMargin, xSpacing, getCorrectY, graphHeight);
    drawLineGraph(canvas, bluePoints, Colors.blue, leftMargin, xSpacing, getCorrectY, graphHeight);
    drawLineGraph(canvas, greenPoints, Colors.green, leftMargin, xSpacing, getCorrectY, graphHeight);
  }

  void drawLineGraph(
    Canvas canvas, 
    List<double> values, 
    Color color, 
    double leftMargin, 
    double xSpacing,
    double Function(double) getY,
    double graphHeight,
  ) {
    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final Paint dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Paint borderDotPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    final Path areaPath = Path();

    // Generate Points List
    List<Offset> points = [];
    for (int i = 0; i < values.length; i++) {
      double x = leftMargin + (xSpacing * i);
      double y = getY(values[i]);
      points.add(Offset(x, y));
    }

    // Bezier Draw Method
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      areaPath.moveTo(points[0].dx, points[0].dy);

      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];

        // Smooth wave controls
        final controlX1 = p0.dx + (p1.dx - p0.dx) / 2;
        final controlY1 = p0.dy;
        final controlX2 = p0.dx + (p1.dx - p0.dx) / 2;
        final controlY2 = p1.dy;

        path.cubicTo(controlX1, controlY1, controlX2, controlY2, p1.dx, p1.dy);
        areaPath.cubicTo(controlX1, controlY1, controlX2, controlY2, p1.dx, p1.dy);
      }

      // Close Area Path for Gradient Fill
      areaPath.lineTo(points.last.dx, graphHeight);
      areaPath.lineTo(points.first.dx, graphHeight);
      areaPath.close();

      // Draw Gradient Area
      final Paint areaPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withOpacity(0.24),
            color.withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTRB(leftMargin, 0, points.last.dx, graphHeight))
        ..style = PaintingStyle.fill;

      canvas.drawPath(areaPath, areaPaint);
    }

    // Draw the main line
    canvas.drawPath(path, linePaint);

    // Draw indicator dots on each node
    for (var point in points) {
      canvas.drawCircle(point, 5.0, dotPaint);
      canvas.drawCircle(point, 5.0, borderDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

