import 'package:flutter/material.dart';

class CustomLineChart extends StatelessWidget {
  const CustomLineChart({super.key});

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 10),
          // Chart Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              legendItem("Theft", Colors.orange),
              const SizedBox(width: 20),
              legendItem("Accident", Colors.blue),
              const SizedBox(width: 20),
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
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
      ..color = Colors.grey.shade200
      ..strokeWidth = 1.0;

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    const int gridRows = 5;
    final List<String> yLabels = ['25%', '20%', '15%', '10%', '5%'];
    
    // Available drawing area offset for labels
    const double leftMargin = 40.0;
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
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 10,
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
        ..color = Colors.grey.shade300
        ..strokeWidth = 1.5,
    );

    // Draw X-axis labels (months)
    final List<String> xLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final double xSpacing = graphWidth / (xLabels.length - 1);
    for (int i = 0; i < xLabels.length; i++) {
      double x = leftMargin + (xSpacing * i);
      textPainter.text = TextSpan(
        text: xLabels[i],
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - (textPainter.width / 2), graphHeight + 6));
    }

    // Points for three lines matching reference:
    // Orange: rising high (e.g. 10%, 18%, 21%, 20%, 25%, 30%)
    // Blue: middle stable (e.g. 5%, 10%, 12%, 8%, 10%, 12%)
    // Green: starts low then surges (e.g. 2%, 4%, 6%, 10%, 19%, 23%)

    // Helper to calculate Y position on canvas based on percentage (0% to 25% max grid height)
    double getCorrectY(double percentage) {
      double pctFactor = percentage / 25.0; // grid tops at 25%
      return graphHeight - (graphHeight * pctFactor);
    }

    final List<double> orangePoints = [10.0, 18.0, 21.0, 20.0, 25.0, 32.0];
    final List<double> bluePoints = [5.0, 10.0, 12.0, 8.0, 10.0, 9.0];
    final List<double> greenPoints = [2.0, 4.0, 6.0, 10.0, 19.0, 14.0];

    drawLineGraph(canvas, orangePoints, Colors.orange, leftMargin, xSpacing, getCorrectY);
    drawLineGraph(canvas, bluePoints, Colors.blue, leftMargin, xSpacing, getCorrectY);
    drawLineGraph(canvas, greenPoints, Colors.green, leftMargin, xSpacing, getCorrectY);
  }

  void drawLineGraph(
    Canvas canvas, 
    List<double> values, 
    Color color, 
    double leftMargin, 
    double xSpacing,
    double Function(double) getY,
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
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    for (int i = 0; i < values.length; i++) {
      double x = leftMargin + (xSpacing * i);
      double y = getY(values[i]);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw the main line
    canvas.drawPath(path, linePaint);

    // Draw indicator dots on each node
    for (int i = 0; i < values.length; i++) {
      double x = leftMargin + (xSpacing * i);
      double y = getY(values[i]);

      canvas.drawCircle(Offset(x, y), 5.5, dotPaint);
      canvas.drawCircle(Offset(x, y), 5.5, borderDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
