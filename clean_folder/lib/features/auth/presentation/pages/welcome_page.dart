import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_button.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/emergency_hotlines_page.dart';
import 'package:community_safety_app/features/auth/presentation/pages/login_page.dart';
import 'package:community_safety_app/features/auth/presentation/pages/sign_up_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _logoController;
  late AnimationController _contentController;
  late AnimationController _pulseController;

  late Animation<double> _bgAnimation;
  late Animation<double> _logoScale;
  late Animation<double> _logoPulse;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _btn1Fade;
  late Animation<double> _btn2Fade;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _bgAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.easeInOut),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoPulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _btn1Fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );
    _btn2Fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.55, 0.8, curve: Curves.easeOut),
      ),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _logoController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _logoController.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  bool _isLoginDialogShowing = false;

  void _showLoginRequired(BuildContext context) {
    if (_isLoginDialogShowing) return;
    _isLoginDialogShowing = true;
    showDialog(
      context: context,
      builder: (context) => _PremiumDialog(
        icon: Icons.lock_outline,
        iconColor: AppColors.primary,
        title: 'Login Required',
        content:
            'Please login or create an account first before reporting an incident.',
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: AppColors.textLight)),
          ),
          _DialogButton(
            label: 'Login',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LoginPage()));
            },
          ),
        ],
      ),
    ).then((_) {
      _isLoginDialogShowing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppColors.isDarkModeNotifier,
      builder: (context, isDark, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: AnimatedBuilder(
            animation: Listenable.merge([_bgAnimation, _logoPulse]),
            builder: (context, child) {
              return Stack(
                children: [
                  // ── Animated Mesh Gradient Background ──────────────────────────
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? const LinearGradient(
                              colors: [Color(0xFF060D1A), Color(0xFF0A1628)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [Color(0xFFF8FAFC), Color(0xFFEDF2F7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                    ),
                  ),

                  // ── Ambient Orbs ───────────────────────────────────────────────
                  Positioned(
                    top: -80 + (40 * _bgAnimation.value),
                    left: -60 + (20 * _bgAnimation.value),
                    child: _Orb(
                      size: 300,
                      color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.08),
                    ),
                  ),
                  Positioned(
                    bottom: -100 + (30 * (1 - _bgAnimation.value)),
                    right: -80,
                    child: _Orb(
                      size: 350,
                      color: AppColors.secondary.withValues(alpha: isDark ? 0.08 : 0.05),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.4,
                    left: MediaQuery.of(context).size.width * 0.6,
                    child: _Orb(
                      size: 200,
                      color: AppColors.accent.withValues(alpha: isDark ? 0.08 : 0.05),
                    ),
                  ),

                  // ── Grid Overlay ───────────────────────────────────────────────
                  CustomPaint(
                    size: Size(
                      MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height,
                    ),
                    painter: _GridPainter(isDark: isDark),
                  ),

              // ── Main Content ────────────────────────────────────────────────
              SafeArea(
                child: Column(
                  children: [
                    // Top bar with Login / Sign Up
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Semantics(
                            label: 'nav_login_button',
                            button: true,
                            child: _GlassTopButton(
                              text: 'Login',
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginPage()),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          _GlassTopButton(
                            text: 'Sign Up',
                            filled: true,
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SignUpPage()),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // ── Animated Logo ──────────────────────────────────────────
                    ScaleTransition(
                      scale: _logoScale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer pulse ring
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, _) {
                              return Container(
                                width: 140 + (20 * _pulseController.value),
                                height: 140 + (20 * _pulseController.value),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primary.withValues(
                                        alpha: 0.3 *
                                            (1 - _pulseController.value)),
                                    width: 2,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Middle ring
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  AppColors.primary.withValues(alpha: 0.08),
                              border: Border.all(
                                color:
                                    AppColors.primary.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                          ),
                          // Logo
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  color: AppColors.primary,
                                  child: Icon(Icons.shield,
                                      color: Colors.white, size: 48),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32),

                    // ── Hero Text ──────────────────────────────────────────────
                    FadeTransition(
                      opacity: _contentFade,
                      child: SlideTransition(
                        position: _contentSlide,
                        child: Column(
                          children: [
                            // RESQ title with gradient
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppColors.cyanGradient.createShader(bounds),
                              blendMode: BlendMode.srcIn,
                              child: Text(
                                'RESQ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 52,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 8,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 7),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.primary.withValues(alpha: 0.15)
                                    : AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                    color: isDark
                                        ? AppColors.primary.withValues(alpha: 0.3)
                                        : AppColors.primary.withValues(alpha: 0.25)),
                              ),
                              child: Text(
                                'Smart Barangay Command System',
                                style: TextStyle(
                                  color: isDark ? AppColors.secondary : AppColors.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 48),
                              child: Text(
                                'Your safety and community trust are our priority',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // ── Action Buttons (Staggered) ──────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          FadeTransition(
                            opacity: _btn1Fade,
                            child: Custom3dButton(
                              icon: Icons.warning_amber_rounded,
                              text: 'Report an Incident',
                              gradient: AppColors.emergencyGradient,
                              onPressed: () => _showLoginRequired(context),
                            ),
                          ),
                          const SizedBox(height: 14),
                          FadeTransition(
                            opacity: _btn2Fade,
                            child: Custom3dButton(
                              icon: Icons.call,
                              text: 'Emergency Hotlines',
                              gradient: AppColors.cyanGradient,
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const EmergencyHotlinesPage()),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // ── Official Municipal Civic Trust Badge ────────────────────
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : AppColors.border.withValues(alpha: 0.7),
                          ),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Text(
                          '🛡️ Republic of the Philippines • Barangay Moonwalk, Parañaque City',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  },
);
  }
}

// ─── Supporting Widgets ───────────────────────────────────────────────────────

class _Orb extends StatelessWidget {
  final double size;
  final Color color;

  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}

class _GlassTopButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool filled;

  const _GlassTopButton({
    required this.text,
    required this.onPressed,
    this.filled = false,
  });

  @override
  State<_GlassTopButton> createState() => _GlassTopButtonState();
}

class _GlassTopButtonState extends State<_GlassTopButton> {
  DateTime? _lastTap;

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTap != null &&
        now.difference(_lastTap!) < const Duration(milliseconds: 600)) {
      return;
    }
    _lastTap = now;
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode;
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: widget.filled
              ? AppColors.primary
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.9)),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: widget.filled
                ? AppColors.primary
                : (isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.35)),
          ),
          boxShadow: widget.filled
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : (isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]),
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            color: widget.filled
                ? Colors.white
                : (isDark ? Colors.white : AppColors.primary),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final bool isDark;
  const _GridPainter({this.isDark = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.025)
          : const Color(0xFF0F172A).withValues(alpha: 0.035)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const spacing = 50.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

class _PremiumDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;
  final List<Widget> actions;

  const _PremiumDialog({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppColors.border),
      ),
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 10),
            Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: actions
                  .map((w) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: w)))
                  .toList(),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DialogButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'dialog_button_$label',
      child: Custom3dButton(
        text: label,
        height: 44,
        onPressed: onTap,
        gradient: AppColors.primaryGradient,
      ),
    );
  }
}
