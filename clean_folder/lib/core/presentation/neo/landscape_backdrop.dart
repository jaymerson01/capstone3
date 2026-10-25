import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Time of day of a [LandscapeBackdrop].
enum LandscapeTime { dusk, night }

/// RESQ landscape backdrop drawn in code (no image files): a sky with a
/// sun or moon glow over rolling hills. Dusk is for the resident sign-in
/// screens; night for dark mode and the admin portal. Tall areas get the
/// phone scene, wide areas the desktop scene, and both stretch to fill.
class LandscapeBackdrop extends StatelessWidget {
  final LandscapeTime time;
  final Widget? child;

  const LandscapeBackdrop({
    super.key,
    this.time = LandscapeTime.dusk,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: _LandscapePainter(
          time == LandscapeTime.dusk ? _Palette.dusk : _Palette.night,
        ),
        child: child,
      ),
    );
  }
}

/// The shapes of one scene, in the coordinates of [size].
class _Scene {
  final Size size;
  final List<double> skyStops;
  final Offset glowCenter; // Fractions of the size
  final double glowRadius; // Fraction of each side
  final List<Offset> ridge; // Far mountains, filled down to ridgeBase
  final double ridgeBase;
  // Each hill: start y, then two cubic segments (c1x c1y c2x c2y x y),
  // filled down to the bottom.
  final List<List<double>> hills;
  final List<(double, double, double)> lights; // x, y, radius (night only)

  const _Scene({
    required this.size,
    required this.skyStops,
    required this.glowCenter,
    required this.glowRadius,
    required this.ridge,
    required this.ridgeBase,
    required this.hills,
    required this.lights,
  });

  static const phone = _Scene(
    size: Size(390, 844),
    skyStops: [0, 0.3, 0.52, 1],
    glowCenter: Offset(0.66, 0.48),
    glowRadius: 0.35,
    ridge: [
      Offset(0, 430), Offset(40, 412), Offset(90, 420), Offset(140, 398),
      Offset(190, 414), Offset(250, 396), Offset(300, 410), Offset(350, 400),
      Offset(390, 412),
    ],
    ridgeBase: 480,
    hills: [
      [452, 80, 430, 160, 440, 230, 458, 290, 472, 340, 452, 390, 444],
      [520, 70, 480, 150, 500, 210, 530, 270, 560, 330, 520, 390, 500],
      [620, 90, 570, 180, 600, 250, 640, 300, 668, 350, 640, 390, 620],
      [740, 100, 700, 200, 720, 280, 760, 330, 784, 370, 770, 390, 760],
    ],
    lights: [
      (48, 556, 1.6), (62, 562, 2), (140, 548, 2), (226, 580, 1.6),
      (244, 576, 2), (318, 560, 1.6), (334, 566, 2), (110, 690, 1.6),
      (180, 672, 2), (290, 700, 1.6),
    ],
  );

  static const wide = _Scene(
    size: Size(1440, 900),
    skyStops: [0, 0.45, 0.62, 1],
    glowCenter: Offset(0.72, 0.55),
    glowRadius: 0.3,
    ridge: [
      Offset(0, 520), Offset(120, 492), Offset(260, 506), Offset(400, 470),
      Offset(560, 498), Offset(720, 466), Offset(880, 492), Offset(1040, 474),
      Offset(1200, 496), Offset(1440, 478),
    ],
    ridgeBase: 600,
    hills: [
      [560, 260, 520, 520, 540, 780, 572, 1000, 598, 1220, 560, 1440, 548],
      [650, 220, 600, 480, 626, 700, 664, 940, 704, 1180, 640, 1440, 618],
      [760, 300, 700, 600, 730, 860, 772, 1080, 808, 1280, 770, 1440, 752],
    ],
    lights: [
      (210, 618, 2), (232, 624, 1.6), (402, 640, 2), (640, 652, 1.6),
      (662, 648, 2), (900, 668, 2), (1110, 642, 1.6), (1132, 650, 2),
      (1300, 630, 1.6), (520, 742, 2),
    ],
  );
}

class _Palette {
  final List<Color> sky; // Top, middle, horizon
  final Color glow;
  final List<Color> phoneLayers; // Ridge, then hills front-most last
  final List<Color> wideLayers;
  final Color? lights;

  const _Palette({
    required this.sky,
    required this.glow,
    required this.phoneLayers,
    required this.wideLayers,
    this.lights,
  });

  static const dusk = _Palette(
    sky: [Color(0xFF3F5F9C), Color(0xFF8FA9D2), Color(0xFFF2C6A0)],
    glow: Color(0xF2FFF1D6),
    phoneLayers: [
      Color(0xFF8FA2BE), Color(0xFF78A58C), Color(0xFF548B6C),
      Color(0xFF356F52), Color(0xFF234F3B),
    ],
    wideLayers: [
      Color(0xFF8FA2BE), Color(0xFF6E9D84), Color(0xFF457D5F),
      Color(0xFF234F3B),
    ],
  );

  static const night = _Palette(
    sky: [Color(0xFF070D1C), Color(0xFF16295A), Color(0xFF2C4A86)],
    glow: Color(0x73A5F3FC),
    phoneLayers: [
      Color(0xFF22386A), Color(0xFF1A3150), Color(0xFF162C49),
      Color(0xFF11243B), Color(0xFF0D1D31),
    ],
    wideLayers: [
      Color(0xFF22386A), Color(0xFF1A3150), Color(0xFF132842),
      Color(0xFF0D1D31),
    ],
    lights: Color(0xD9FDE68A),
  );
}

class _LandscapePainter extends CustomPainter {
  final _Palette palette;

  _LandscapePainter(this.palette);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final isWide = size.width >= size.height;
    final scene = isWide ? _Scene.wide : _Scene.phone;
    final layers = isWide ? palette.wideLayers : palette.phoneLayers;
    final sx = size.width / scene.size.width;
    final sy = size.height / scene.size.height;
    Offset at(double x, double y) => Offset(x * sx, y * sy);
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [...palette.sky, palette.sky.last],
          stops: scene.skyStops,
        ).createShader(rect),
    );

    // Elliptical, like the SVG's bounding-box radial gradient.
    canvas.save();
    canvas.translate(
      scene.glowCenter.dx * size.width,
      scene.glowCenter.dy * size.height,
    );
    canvas.scale(scene.glowRadius * size.width, scene.glowRadius * size.height);
    canvas.drawCircle(
      Offset.zero,
      1,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset.zero,
          1,
          [palette.glow, palette.glow.withValues(alpha: 0)],
        ),
    );
    canvas.restore();

    final ridgeStart = at(0, scene.ridgeBase);
    final ridge = Path()..moveTo(ridgeStart.dx, ridgeStart.dy);
    for (final point in scene.ridge) {
      final p = at(point.dx, point.dy);
      ridge.lineTo(p.dx, p.dy);
    }
    final ridgeEnd = at(scene.size.width, scene.ridgeBase);
    ridge
      ..lineTo(ridgeEnd.dx, ridgeEnd.dy)
      ..close();
    canvas.drawPath(ridge, Paint()..color = layers.first);

    for (var i = 0; i < scene.hills.length; i++) {
      final h = scene.hills[i];
      final start = at(0, h[0]);
      final c1 = at(h[1], h[2]), c2 = at(h[3], h[4]), mid = at(h[5], h[6]);
      final c3 = at(h[7], h[8]), c4 = at(h[9], h[10]), end = at(h[11], h[12]);
      final hill = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, mid.dx, mid.dy)
        ..cubicTo(c3.dx, c3.dy, c4.dx, c4.dy, end.dx, end.dy)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(hill, Paint()..color = layers[i + 1]);
    }

    final lights = palette.lights;
    if (lights != null) {
      final paint = Paint()..color = lights;
      final scale = math.min(sx, sy);
      for (final (x, y, r) in scene.lights) {
        canvas.drawCircle(at(x, y), r * scale, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_LandscapePainter oldDelegate) =>
      oldDelegate.palette != palette;
}
