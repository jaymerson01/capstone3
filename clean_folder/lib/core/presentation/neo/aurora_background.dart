import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';

/// RESQ aurora backdrop: soft blue, cyan, peach and violet glows on frost,
/// or on night navy in dark mode. Fills the space it's given; put the
/// screen content in [child].
class AuroraBackground extends StatelessWidget {
  final Widget? child;

  const AuroraBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    // Depend on the theme so the backdrop repaints when dark mode flips.
    Theme.of(context);
    return SizedBox.expand(
      child: CustomPaint(
        painter: _AuroraPainter(
          AppColors.isDarkMode ? _AuroraPalette.night : _AuroraPalette.day,
        ),
        // Scrolling and pulses in the content repaint on their own layer,
        // so the full-screen backdrop isn't redrawn with them.
        child: child == null ? null : RepaintBoundary(child: child),
      ),
    );
  }
}

/// One glow: an ellipse at [x], [y] with radii [rx], [ry], all as fractions
/// of the backdrop size, fading out at 70% of its radius.
class _Glow {
  final double x, y, rx, ry;
  final Color color;

  const _Glow(this.x, this.y, this.rx, this.ry, this.color);
}

class _AuroraPalette {
  final Color top, bottom;
  final List<_Glow> glows;

  const _AuroraPalette(this.top, this.bottom, this.glows);

  static const day = _AuroraPalette(AppColors.frost, Color(0xFFE6ECF6), [
    _Glow(0.12, 0.08, 0.42, 0.26, Color(0x6B638DFF)),
    _Glow(0.92, 0.26, 0.46, 0.28, Color(0x4D22D3EE)),
    _Glow(0.18, 0.72, 0.55, 0.30, Color(0x7AF2C6A0)),
    _Glow(0.88, 0.92, 0.50, 0.26, Color(0x338B5CF6)),
  ]);

  static const night = _AuroraPalette(Color(0xFF0B1428), Color(0xFF0E1A33), [
    _Glow(0.12, 0.08, 0.42, 0.26, Color(0x592F6BF0)),
    _Glow(0.92, 0.26, 0.46, 0.28, Color(0x2922D3EE)),
    _Glow(0.18, 0.72, 0.55, 0.30, Color(0x386366F1)),
    _Glow(0.88, 0.92, 0.50, 0.26, Color(0x2E8B5CF6)),
  ]);
}

class _AuroraPainter extends CustomPainter {
  final _AuroraPalette palette;

  _AuroraPainter(this.palette);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.top, palette.bottom],
        ).createShader(rect),
    );
    for (final glow in palette.glows) {
      canvas.save();
      canvas.translate(glow.x * size.width, glow.y * size.height);
      canvas.scale(glow.rx * size.width, glow.ry * size.height);
      canvas.drawCircle(
        Offset.zero,
        1,
        Paint()
          ..shader = ui.Gradient.radial(
            Offset.zero,
            1,
            [glow.color, glow.color.withValues(alpha: 0)],
            const [0, 0.7],
          ),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_AuroraPainter oldDelegate) =>
      oldDelegate.palette != palette;
}
