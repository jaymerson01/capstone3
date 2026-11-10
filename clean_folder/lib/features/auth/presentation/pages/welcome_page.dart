import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/presentation/neo/glass_card.dart';
import 'package:community_safety_app/core/presentation/neo/landscape_backdrop.dart';
import 'package:community_safety_app/core/presentation/neo/neo_dialog.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_button.dart';
import 'package:community_safety_app/features/incident_reporting/presentation/pages/emergency_hotlines_page.dart';
import 'package:community_safety_app/features/auth/presentation/pages/login_page.dart';
import 'package:community_safety_app/features/auth/presentation/pages/sign_up_page.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';
import 'package:community_safety_app/core/presentation/neo/reduced_motion.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _contentController;
  late AnimationController _pulseController;

  late Animation<double> _logoScale;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _btn1Fade;
  late Animation<double> _btn2Fade;

  @override
  void initState() {
    super.initState();

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
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    syncLoop(_pulseController, context);
  }

  @override
  void dispose() {
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
        title: AppLocalizations.of(context).welcomeLoginRequiredTitle,
        content: AppLocalizations.of(context).welcomeLoginRequiredMessage,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).commonCancel,
                style: TextStyle(
                    color: AppColors.textLight, fontWeight: FontWeight.w700)),
          ),
          _DialogButton(
            id: 'Login',
            label: AppLocalizations.of(context).authLogin,
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
          // ── Dusk landscape (night in dark mode) ─────────────────────────────
          body: LandscapeBackdrop(
            time: isDark ? LandscapeTime.night : LandscapeTime.dusk,
            child: SafeArea(
              // Spreads out on tall screens and scrolls on short ones.
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          // Top bar with Login / Sign Up
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Semantics(
                                    label: 'nav_login_button',
                                    button: true,
                                    child: _GlassTopButton(
                                      text: AppLocalizations.of(context).authLogin,
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => const LoginPage()),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: _GlassTopButton(
                                    text: AppLocalizations.of(context).authSignUp,
                                    filled: true,
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const SignUpPage()),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // ── Brand Card on Smoked Glass ──────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 24),
                            child: GlassCard(
                              tone: GlassTone.smoke,
                              blur: true,
                              borderRadius: 30,
                              padding:
                                  const EdgeInsets.fromLTRB(22, 26, 22, 26),
                              child: Column(
                                children: [
                                  ScaleTransition(
                                    scale: _logoScale,
                                    child: _LogoRings(pulse: _pulseController),
                                  ),
                                  const SizedBox(height: 14),
                                  FadeTransition(
                                    opacity: _contentFade,
                                    child: SlideTransition(
                                      position: _contentSlide,
                                      child: Column(
                                        children: [
                                          const Text(
                                            'RESQ',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 40,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 4,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            AppLocalizations.of(context)
                                                .welcomeTagline
                                                .toUpperCase(),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Color(0xFFA5F3FC),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1.4,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            AppLocalizations.of(context)
                                                .welcomeSubtitle,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.92),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              height: 1.45,
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

                          const Spacer(),

                          // ── Action Buttons (Staggered) ──────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                FadeTransition(
                                  opacity: _btn1Fade,
                                  child: Custom3dButton(
                                    icon: Icons.warning_amber_rounded,
                                    text: AppLocalizations.of(context)
                                        .welcomeReportIncident,
                                    gradient: AppColors.emergencyCtaGradient,
                                    height: 58,
                                    borderRadius: 16,
                                    onPressed: () => _showLoginRequired(context),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                FadeTransition(
                                  opacity: _btn2Fade,
                                  child: Custom3dButton(
                                    icon: Icons.call,
                                    text: AppLocalizations.of(context)
                                        .welcomeHotlines,
                                    backgroundColor: const Color(0xB30F172A),
                                    borderColor:
                                        Colors.white.withValues(alpha: 0.5),
                                    height: 58,
                                    borderRadius: 16,
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

                          // ── Official Municipal Civic Trust Badge ─────────────
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.glassSmoke,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context).welcomeFooter,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
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
            ),
          ),
        );
      },
    );
  }
}

// ─── Supporting Widgets ───────────────────────────────────────────────────────

/// Logo in a cyan ring, with a soft white ring that pulses outwards.
class _LogoRings extends StatelessWidget {
  final Animation<double> pulse;

  const _LogoRings({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: pulse,
              builder: (context, _) {
                return Container(
                  width: 136 + (14 * pulse.value),
                  height: 136 + (14 * pulse.value),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white
                          .withValues(alpha: 0.1 + 0.35 * (1 - pulse.value)),
                      width: 1.5,
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            width: 114,
            height: 114,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.7),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.4),
                  blurRadius: 24,
                ),
              ],
            ),
          ),
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.45),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.primary,
                  child: const Icon(Icons.shield,
                      color: Colors.white, size: 40),
                ),
              ),
            ),
          ),
        ],
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
    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          // Smoked glass for Login; blue for Sign Up.
          color: widget.filled ? null : const Color(0x6B0F172A),
          gradient: widget.filled ? AppColors.ctaGradient : null,
          borderRadius: BorderRadius.circular(14),
          border: widget.filled
              ? null
              : Border.all(
                  color: Colors.white.withValues(alpha: 0.55),
                  width: 1.5,
                ),
          boxShadow: widget.filled
              ? [
                  BoxShadow(
                    color: const Color(0xFF1E40AF).withValues(alpha: 0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : const [],
        ),
        // Hug the label (an alignment alone would stretch the button).
        // Long labels shrink to fit instead of being cut off.
        child: Align(
          widthFactor: 1,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.text,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
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
    return NeoDialog(
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeoDialogIcon(icon: icon, color: iconColor),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: actions
                  .map((w) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: w)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  /// Fixed id for UI automation, so it doesn't change with the language.
  final String? id;

  const _DialogButton({required this.label, required this.onTap, this.id});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'dialog_button_${id ?? label}',
      child: Custom3dButton(
        text: label,
        height: 48,
        borderRadius: 24,
        onPressed: onTap,
        gradient: AppColors.primaryGradient,
      ),
    );
  }
}
