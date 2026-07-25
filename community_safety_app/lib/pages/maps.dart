import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_color.dart';
import '../widgets/custom_3d_button.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _radarController;
  late AnimationController _pinBounceController;
  late AnimationController _routeController;

  late Animation<double> _pulse1;
  late Animation<double> _pulse2;
  late Animation<double> _pulse3;
  late Animation<double> _radar;
  late Animation<double> _pinBounce;
  late Animation<double> _routeDash;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _pinBounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _routeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _pulse1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _pulse2 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _pulse3 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );
    _radar = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _radarController, curve: Curves.linear),
    );
    _pinBounce = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _pinBounceController, curve: Curves.easeInOut),
    );
    _routeDash = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _routeController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _radarController.dispose();
    _pinBounceController.dispose();
    _routeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _MapAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section Header ─────────────────────────────────────────────
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Safety Map",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Text(
                      "Active Moonwalk Perimeters",
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textLight),
                    ),
                  ],
                ),
                const Spacer(),
                _LiveBadge(),
              ],
            ),
            const SizedBox(height: 14),

            // ── Map Frame ──────────────────────────────────────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF080E1C),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // ── Animated Map Background ──────────────────────────
                      AnimatedBuilder(
                        animation: Listenable.merge(
                            [_routeDash, _radar, _pulse1]),
                        builder: (context, _) {
                          return CustomPaint(
                            size: Size.infinite,
                            painter: _PremiumMapPainter(
                              routeProgress: _routeDash.value,
                              radarAngle: _radar.value,
                            ),
                          );
                        },
                      ),

                      // ── Animated GPS Pulse (3 rings) ──────────────────────
                      Positioned(
                        top: 150,
                        left: 120,
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                // Ring 3 (outermost)
                                if (_pulse3.value > 0)
                                  Opacity(
                                    opacity: (1 - _pulse3.value).clamp(0, 1),
                                    child: Container(
                                      width: 80 * _pulse3.value,
                                      height: 80 * _pulse3.value,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.4),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                // Ring 2
                                if (_pulse2.value > 0)
                                  Opacity(
                                    opacity: (1 - _pulse2.value).clamp(0, 1),
                                    child: Container(
                                      width: 60 * _pulse2.value,
                                      height: 60 * _pulse2.value,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.secondary
                                              .withValues(alpha: 0.5),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                // Ring 1
                                Opacity(
                                  opacity: (1 - _pulse1.value).clamp(0, 1),
                                  child: Container(
                                    width: 40 * _pulse1.value,
                                    height: 40 * _pulse1.value,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary
                                          .withValues(alpha: 0.1),
                                    ),
                                  ),
                                ),
                                // Core GPS dot
                                child!,
                              ],
                            );
                          },
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.8),
                                  blurRadius: 12,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.navigation,
                                color: Colors.white, size: 10),
                          ),
                        ),
                      ),

                      // ── Floating Glass Search Bar ──────────────────────────
                      Positioned(
                        top: 14,
                        left: 14,
                        right: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search,
                                  color: AppColors.textLight, size: 18),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  "Search locations or coordinates...",
                                  style: TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.filter_list,
                                    color: AppColors.primary, size: 16),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Incident Pin — Fire ───────────────────────────────
                      Positioned(
                        top: 110,
                        left: 70,
                        child: AnimatedBuilder(
                          animation: _pinBounce,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _pinBounce.value),
                              child: child,
                            );
                          },
                          child: _IncidentPin(
                            label: "Fire Incident",
                            color: AppColors.danger,
                            icon: Icons.local_fire_department,
                          ),
                        ),
                      ),

                      // ── Incident Pin — Medical ────────────────────────────
                      Positioned(
                        bottom: 140,
                        right: 100,
                        child: _IncidentPin(
                          label: "Medical",
                          color: AppColors.solved,
                          icon: Icons.medical_services,
                        ),
                      ),

                      // ── Incident Pin — Theft ──────────────────────────────
                      Positioned(
                        bottom: 200,
                        left: 60,
                        child: _IncidentPin(
                          label: "Theft",
                          color: AppColors.pending,
                          icon: Icons.local_police,
                        ),
                      ),

                      // ── Premium Zoom Controls ─────────────────────────────
                      Positioned(
                        bottom: 20,
                        right: 16,
                        child: Column(
                          children: [
                            _MapControlButton(
                                icon: Icons.add, onTap: () {}),
                            const SizedBox(height: 8),
                            _MapControlButton(
                                icon: Icons.remove, onTap: () {}),
                            const SizedBox(height: 8),
                            _MapControlButton(
                              icon: Icons.my_location,
                              onTap: () {},
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 8),
                            _MapControlButton(
                                icon: Icons.compass_calibration,
                                onTap: () {}),
                          ],
                        ),
                      ),

                      // ── Bottom status strip ───────────────────────────────
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xFF080E1C)
                                    .withValues(alpha: 0.95),
                              ],
                            ),
                          ),
                          child: Row(
                            children: [
                              _MapLegendDot(
                                  color: AppColors.danger, label: "Fire"),
                              const SizedBox(width: 16),
                              _MapLegendDot(
                                  color: AppColors.pending, label: "Theft"),
                              const SizedBox(width: 16),
                              _MapLegendDot(
                                  color: AppColors.solved, label: "Medical"),
                              const Spacer(),
                              const Text(
                                "3 Active",
                                style: TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── CTA Button ─────────────────────────────────────────────────
            Custom3dButton(
              icon: Icons.map,
              text: "Continue with Google Maps",
              gradient: AppColors.primaryGradient,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Supporting Widgets ───────────────────────────────────────────────────────

class _MapAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64 + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
            bottom: BorderSide(color: AppColors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
              onPressed: () => Navigator.pop(context),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.primary,
                    child:
                        const Icon(Icons.shield, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "Safety Map",
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: AppColors.primary, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveBadge extends StatefulWidget {
  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppColors.danger.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.danger,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.danger
                          .withValues(alpha: 0.7 * _ctrl.value),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                "LIVE",
                style: TextStyle(
                  color: AppColors.danger,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IncidentPin extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _IncidentPin({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1627),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 12),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        CustomPaint(
          size: const Size(12, 8),
          painter: _TrianglePainter(color: color),
        ),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.6),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.7);
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapControlButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  const _MapControlButton({required this.icon, required this.onTap, this.color});

  @override
  State<_MapControlButton> createState() => _MapControlButtonState();
}

class _MapControlButtonState extends State<_MapControlButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: widget.color != null
              ? widget.color!.withValues(alpha: _pressed ? 0.4 : 0.15)
              : Colors.white.withValues(alpha: _pressed ? 0.15 : 0.08),
          shape: BoxShape.circle,
          border: Border.all(
            color: (widget.color ?? Colors.white)
                .withValues(alpha: _pressed ? 0.5 : 0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            if (widget.color != null)
              BoxShadow(
                color: widget.color!.withValues(alpha: 0.25),
                blurRadius: 12,
              ),
          ],
        ),
        child: Icon(
          widget.icon,
          color: widget.color ?? AppColors.textDark,
          size: 18,
        ),
      ),
    );
  }
}

class _MapLegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _MapLegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 6),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: AppColors.textLight, fontSize: 11),
        ),
      ],
    );
  }
}

// ─── Premium Map Painter ──────────────────────────────────────────────────────

class _PremiumMapPainter extends CustomPainter {
  final double routeProgress;
  final double radarAngle;

  _PremiumMapPainter({required this.routeProgress, required this.radarAngle});

  @override
  void paint(Canvas canvas, Size size) {
    // Background grid
    final gridPaint = Paint()
      ..color = const Color(0xFF0A84FF).withValues(alpha: 0.04)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Green spaces (blocks)
    final greenPaint = Paint()
      ..color = const Color(0xFF30D158).withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(20, 100, 130, 85), const Radius.circular(8)),
      greenPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width - 160, size.height - 190, 140, 95),
          const Radius.circular(8)),
      greenPaint,
    );

    // Roads
    final roadPaint = Paint()
      ..color = const Color(0xFF1E2D4A)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
        Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.4), roadPaint);
    canvas.drawLine(
        Offset(0, size.height * 0.65), Offset(size.width, size.height * 0.68), roadPaint);
    canvas.drawLine(
        Offset(size.width * 0.35, 0), Offset(size.width * 0.35, size.height), roadPaint);
    canvas.drawLine(
        Offset(size.width * 0.72, 0), Offset(size.width * 0.70, size.height), roadPaint);
    canvas.drawLine(
        const Offset(30, 0), Offset(size.width * 0.28, size.height), roadPaint);

    // Road glow
    final glowPaint = Paint()
      ..color = const Color(0xFF0A84FF).withValues(alpha: 0.06)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawLine(
        Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.4), glowPaint);
    canvas.drawLine(
        Offset(size.width * 0.35, 0), Offset(size.width * 0.35, size.height), glowPaint);

    // Animated route line
    final routePath = Path()
      ..moveTo(120, size.height * 0.4)
      ..cubicTo(
        size.width * 0.35,
        size.height * 0.4,
        size.width * 0.35,
        size.height * 0.65,
        size.width * 0.6,
        size.height * 0.65,
      );

    final pathMetrics = routePath.computeMetrics().toList();
    if (pathMetrics.isNotEmpty) {
      final totalLength = pathMetrics.first.length;
      final routeDrawPaint = Paint()
        ..color = AppColors.secondary.withValues(alpha: 0.7)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final extractedPath =
          pathMetrics.first.extractPath(0, totalLength * routeProgress);
      canvas.drawPath(extractedPath, routeDrawPaint);

      // Route glow
      final routeGlowPaint = Paint()
        ..color = AppColors.secondary.withValues(alpha: 0.2)
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(extractedPath, routeGlowPaint);
    }

    // Radar sweep
    final radarCenter = Offset(120, size.height * 0.4 - 20);
    const radarRadius = 50.0;
    final radarPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: [
          Colors.transparent,
          AppColors.primary.withValues(alpha: 0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(radarAngle),
      ).createShader(Rect.fromCircle(center: radarCenter, radius: radarRadius));

    canvas.drawCircle(radarCenter, radarRadius, radarPaint);

    // Radar border
    final radarBorderPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.15)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(radarCenter, radarRadius, radarBorderPaint);
    canvas.drawCircle(radarCenter, radarRadius * 0.66, radarBorderPaint);
    canvas.drawCircle(radarCenter, radarRadius * 0.33, radarBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _PremiumMapPainter oldDelegate) =>
      oldDelegate.routeProgress != routeProgress ||
      oldDelegate.radarAngle != radarAngle;
}