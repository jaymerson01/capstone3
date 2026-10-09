import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../admin/models/incident_report.dart';

class MarkerGenerator {
  static final Map<String, BitmapDescriptor> _cache = {};

  static Color getColorForStatus(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.pending:
        return const Color(0xFFFF9800); // Amber / Orange
      case IncidentStatus.inProgress:
        return const Color(0xFF0088FF); // Command Blue
      case IncidentStatus.solved:
        return const Color(0xFF00E676); // Emergency Green
      case IncidentStatus.spam:
        return const Color(0xFFFF334B); // Crimson Red
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case "Fire Incident":
        return Icons.local_fire_department;
      case "Theft / Robbery":
        return Icons.local_police;
      case "Medical Emergency":
        return Icons.medical_services;
      case "Violence / Physical Fight":
        return Icons.warning_amber_rounded;
      case "Road Accident":
        return Icons.car_crash;
      case "Suspicious Activity":
        return Icons.visibility;
      case "Flood / Calamity":
        return Icons.flood;
      case "Lost Item / Missing Person":
        return Icons.person_search;
      case "Noise Complaint":
        return Icons.campaign;
      default:
        return Icons.report_problem;
    }
  }

  /// Generates a custom canvas-drawn BitmapDescriptor marker for an incident.
  static Future<BitmapDescriptor> getIncidentMarker({
    required String category,
    required IncidentStatus status,
  }) async {
    final cacheKey = '${category}_${status.name}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final statusColor = getColorForStatus(status);
    final iconData = getCategoryIcon(category);

    const double width = 110;
    const double height = 130;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    const double centerX = width / 2;
    const double centerY = 48;
    const double radius = 38;

    // 1. Draw pointer tip at bottom
    final Path pinPath = Path();
    pinPath.moveTo(centerX - 18, centerY + 24);
    pinPath.lineTo(centerX, height - 10);
    pinPath.lineTo(centerX + 18, centerY + 24);
    pinPath.close();

    final Paint pinPaint = Paint()
      ..color = statusColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(pinPath, pinPaint);

    // Outer glow / halo ring
    final Paint haloPaint = Paint()
      ..color = statusColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(centerX, centerY), radius + 6, haloPaint);

    // Outer status ring fill
    final Paint statusRingPaint = Paint()
      ..color = statusColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(centerX, centerY), radius, statusRingPaint);

    // Inner dark background shield
    final Paint bgPaint = Paint()
      ..color = const Color(0xFF0D1B2A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(centerX, centerY), radius - 5, bgPaint);

    // Category Icon centered in dark circle
    final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: 32,
        fontFamily: iconData.fontFamily,
        package: iconData.fontPackage,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(centerX - textPainter.width / 2, centerY - textPainter.height / 2),
    );

    // Status indicator dot on top-right of marker
    final Paint dotBgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(centerX + 26, centerY - 24), 9, dotBgPaint);

    final Paint dotPaint = Paint()
      ..color = statusColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(centerX + 26, centerY - 24), 7, dotPaint);

    final ui.Image image = await pictureRecorder.endRecording().toImage(width.toInt(), height.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }

    final bitmap = BitmapDescriptor.bytes(byteData.buffer.asUint8List());
    _cache[cacheKey] = bitmap;
    return bitmap;
  }

  /// Generates a visually distinct user current location radar marker.
  static Future<BitmapDescriptor> getUserLocationMarker() async {
    const cacheKey = 'user_current_location';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    const double width = 100;
    const double height = 100;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    const double centerX = width / 2;
    const double centerY = height / 2;
    const Color cyanColor = Color(0xFF00E5FF);

    // 1. Outer translucent radar ring
    final Paint outerRingPaint = Paint()
      ..color = cyanColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(centerX, centerY), 42, outerRingPaint);

    // 2. Mid radar ring
    final Paint midRingPaint = Paint()
      ..color = cyanColor.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(centerX, centerY), 28, midRingPaint);

    // 3. Crisp white border circle
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(centerX, centerY), 16, borderPaint);

    // 4. Inner Cyan core
    final Paint corePaint = Paint()
      ..color = cyanColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(centerX, centerY), 12, corePaint);

    // 5. Center white dot
    final Paint dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(centerX, centerY), 4, dotPaint);

    final ui.Image image = await pictureRecorder.endRecording().toImage(width.toInt(), height.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
    }

    final bitmap = BitmapDescriptor.bytes(byteData.buffer.asUint8List());
    _cache[cacheKey] = bitmap;
    return bitmap;
  }
}
