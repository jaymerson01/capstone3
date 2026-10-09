import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class AuthModals {
  /// ── Invalid Credentials ──────────────────────────────────────────────────
  static void showInvalidCredentials(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.88, end: 1.0)
                .animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutBack)),
            child: _PremiumDialog(
              icon: Icons.warning_amber_rounded,
              iconColor: AppColors.danger,
              title: "Invalid Credentials",
              message:
                  "The username or password you entered is incorrect. Please try again.",
              actionLabel: "Try Again",
              actionColor: AppColors.danger,
              onAction: () => Navigator.of(context).pop(),
            ),
          ),
        );
      },
    );
  }

  /// ── Account Locked ──────────────────────────────────────────────────────
  static void showAccountLocked(BuildContext context, DateTime expirationTime) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0)
                .animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutBack)),
            child: _AccountLockedDialogContent(expirationTime: expirationTime),
          ),
        );
      },
    );
  }
}

// ─── Premium Dialog Shell ─────────────────────────────────────────────────────

class _PremiumDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String actionLabel;
  final Color actionColor;
  final VoidCallback onAction;

  const _PremiumDialog({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.actionColor,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: iconColor.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon badge
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconColor.withValues(alpha: 0.1),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withValues(alpha: 0.35),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: iconColor, size: 36),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textLight,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: actionColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: actionColor.withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: actionColor.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: onAction,
                        child: Center(
                          child: Text(
                            actionLabel,
                            style: TextStyle(
                              color: actionColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

// ─── Account Locked Dialog ────────────────────────────────────────────────────

class _AccountLockedDialogContent extends StatefulWidget {
  final DateTime expirationTime;
  const _AccountLockedDialogContent({required this.expirationTime});

  @override
  State<_AccountLockedDialogContent> createState() =>
      _AccountLockedDialogContentState();
}

class _AccountLockedDialogContentState
    extends State<_AccountLockedDialogContent>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  Duration _remaining = Duration.zero;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();
    _timer = Timer.periodic(
        const Duration(seconds: 1), (_) => _updateRemainingTime());
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _updateRemainingTime() {
    final now = DateTime.now();
    if (now.isAfter(widget.expirationTime)) {
      _timer.cancel();
      if (mounted) Navigator.of(context).pop();
    } else {
      if (mounted) {
        setState(() => _remaining = widget.expirationTime.difference(now));
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final m =
        _remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s =
        _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final total = const Duration(minutes: 15).inSeconds;
    final curr = _remaining.inSeconds;
    final progress = curr > 0 ? curr / total : 0.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                  color: AppColors.pending.withValues(alpha: 0.25)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.pending.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Pulsing lock icon
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.pending.withValues(alpha: 0.1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.pending.withValues(alpha: 0.4),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_person_rounded,
                      color: AppColors.pending,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Account Temporarily Locked",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Too many failed login attempts detected. Your account is locked for security.",
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textLight,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Premium countdown ring
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background ring
                      CustomPaint(
                        painter: _RingPainter(
                          progress: progress,
                          trackColor: AppColors.surfaceLight,
                          progressColor: AppColors.pending,
                        ),
                      ),
                      // Glow ring
                      CustomPaint(
                        painter: _RingPainter(
                          progress: progress,
                          trackColor: Colors.transparent,
                          progressColor:
                              AppColors.pending.withValues(alpha: 0.25),
                          strokeWidth: 12,
                          blur: true,
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formattedTime,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDark,
                                fontFeatures: [
                                  FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                            const Text(
                              "remaining",
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;
  final bool blur;

  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    this.strokeWidth = 8,
    this.blur = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;

    // Track
    if (trackColor != Colors.transparent) {
      canvas.drawCircle(
          center,
          radius,
          Paint()
            ..color = trackColor
            ..strokeWidth = strokeWidth
            ..style = PaintingStyle.stroke);
    }

    // Progress arc
    final paint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (blur) {
      paint.maskFilter =
          const MaskFilter.blur(BlurStyle.normal, 6);
    }

    const startAngle = -3.14159 / 2;
    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress;
}
