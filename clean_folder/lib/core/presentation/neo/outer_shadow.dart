import 'dart:math' as math;
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';

/// Paints [shadows] around a rounded box but not under it, like CSS
/// `box-shadow`. A plain BoxShadow also darkens the area under the box,
/// which shows through translucent glass and turns it grey.
class OuterShadow extends StatelessWidget {
  final List<BoxShadow> shadows;
  final BorderRadius borderRadius;
  final Widget child;

  const OuterShadow({
    super.key,
    required this.shadows,
    required this.borderRadius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OuterShadowPainter(shadows, borderRadius),
      child: child,
    );
  }
}

class _OuterShadowPainter extends CustomPainter {
  final List<BoxShadow> shadows;
  final BorderRadius borderRadius;

  _OuterShadowPainter(this.shadows, this.borderRadius);

  @override
  void paint(Canvas canvas, Size size) {
    if (shadows.isEmpty) return;
    final box = borderRadius.toRRect(Offset.zero & size);
    var reach = 0.0;
    for (final shadow in shadows) {
      reach = math.max(
        reach,
        shadow.offset.distance + shadow.spreadRadius + shadow.blurRadius * 2,
      );
    }
    final outside = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect((Offset.zero & size).inflate(reach))
      ..addRRect(box);

    canvas.save();
    canvas.clipPath(outside);
    for (final shadow in shadows) {
      canvas.drawRRect(
        box.shift(shadow.offset).inflate(shadow.spreadRadius),
        shadow.toPaint(),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OuterShadowPainter oldDelegate) =>
      !listEquals(oldDelegate.shadows, shadows) ||
      oldDelegate.borderRadius != borderRadius;
}
