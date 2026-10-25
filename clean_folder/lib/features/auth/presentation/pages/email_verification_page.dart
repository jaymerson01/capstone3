import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/presentation/neo/glass_card.dart';
import 'package:community_safety_app/core/presentation/neo/landscape_backdrop.dart';
import 'package:community_safety_app/core/presentation/neo/live_indicator.dart';
import 'package:community_safety_app/core/presentation/neo/neo_dialog.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_button.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

class EmailVerificationPage extends StatefulWidget {
  final UserEntity? user;
  final String? email;

  const EmailVerificationPage({
    super.key,
    this.user,
    this.email,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  Timer? _countdownTimer;
  int _secondsRemaining = 60;
  bool _canResend = false;
  bool _isChecking = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        setState(() {
          _secondsRemaining = 0;
          _canResend = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String get _displayEmail {
    if (widget.email != null && widget.email!.isNotEmpty) {
      return widget.email!;
    }
    if (widget.user != null && widget.user!.email.isNotEmpty) {
      return widget.user!.email;
    }
    return FirebaseAuth.instance.currentUser?.email ?? AppLocalizations.of(context).verifyYourEmailFallback;
  }

  Future<void> _checkVerificationStatus() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    final messenger = ScaffoldMessenger.of(context);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).verifyNoSession),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _isChecking = false);
        return;
      }

      await user.reload();
      final freshUser = FirebaseAuth.instance.currentUser;

      if (freshUser != null && freshUser.emailVerified) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(freshUser.uid)
              .update({'isVerified': true});
        } catch (e) {
          debugPrint("Note: Firestore isVerified sync exception: $e");
        }

        if (!mounted) return;

        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).verifySuccess,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.solved,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );

        context.read<AuthBloc>().add(const AuthCheckRequested());
        Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (r) => false);
      } else {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).verifyNotYet,
            ),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: AppLocalizations.of(context).verifyResendShort,
              textColor: Colors.white,
              onPressed: _canResend ? _resendVerificationEmail : () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).verifyCheckFailed('$e')),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (!_canResend || _isResending) return;
    setState(() => _isResending = true);

    final messenger = ScaffoldMessenger.of(context);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        _startCountdown();
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).verifyLinkResent(_displayEmail),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.solved,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).verifySessionExpired),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).verifyResendFailed('$e')),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _activateDemoBypass() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        title: Row(
          children: [
            NeoDialogIcon(
              icon: Icons.shield_rounded,
              color: AppColors.warning,
              size: 40,
            ),
            SizedBox(width: 12),
            Flexible(
              child: Text(
                AppLocalizations.of(context).verifyDemoTitle,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          AppLocalizations.of(context).verifyDemoMessage,
          style: TextStyle(
            fontSize: 13.5,
            height: 1.45,
            color: AppColors.textLight,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              AppLocalizations.of(context).commonCancel,
              style: TextStyle(
                  color: AppColors.textLight, fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: const StadiumBorder(),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppLocalizations.of(context).verifyDemoConfirm,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'isVerified': true});
        } catch (_) {}
      }
      if (!mounted) return;
      context.read<AuthBloc>().add(const AuthCheckRequested());
      Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppColors.isDarkModeNotifier,
      builder: (context, isDark, _) {
        final soft = Colors.white.withValues(alpha: 0.9);
        return Scaffold(
          backgroundColor: AppColors.background,
          // ── Dusk landscape (night in dark mode) ─────────────────────────────
          body: LandscapeBackdrop(
            time: isDark ? LandscapeTime.night : LandscapeTime.dusk,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Civic Badge with Long-press Demo Trigger
                        GestureDetector(
                          onLongPress: _activateDemoBypass,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.glassSmoke,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.shield_outlined,
                                  size: 15,
                                  color: AppColors.secondaryLight,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    AppLocalizations.of(context).verifyBadge,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Smoked Glass Card
                        GlassCard(
                          tone: GlassTone.smoke,
                          blur: true,
                          borderRadius: 30,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 30),
                          child: Column(
                            children: [
                              // Live mail badge: waiting for the link
                              ScaleTransition(
                                scale: _pulseAnimation,
                                child: const LiveIndicator.ring(
                                  size: 86,
                                  child: Icon(Icons.mark_email_unread_rounded),
                                ),
                              ),
                              const SizedBox(height: 22),

                              // Title
                              Text(
                                AppLocalizations.of(context).verifyTitle,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),

                              // Instruction text
                              Text(
                                AppLocalizations.of(context).verifyInstruction,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: soft,
                                  height: 1.45,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 14),

                              // Highlighted Email Pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.email_outlined,
                                      size: 17,
                                      color: AppColors.secondaryLight,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        _displayEmail,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Status Badge: Pending
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.warningLight,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      AppLocalizations.of(context).verifyPending,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppColors.warningLight,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 26),

                              // ── Button 1: "I've Verified My Email" ───
                              Custom3dButton(
                                text: _isChecking ? AppLocalizations.of(context).verifyChecking : AppLocalizations.of(context).verifyDone,
                                icon: _isChecking ? null : Icons.check_circle_outline_rounded,
                                height: 54,
                                borderRadius: 16,
                                gradient: AppColors.ctaGradient,
                                borderColor:
                                    AppColors.secondary.withValues(alpha: 0.35),
                                onPressed: _isChecking ? null : _checkVerificationStatus,
                              ),
                              const SizedBox(height: 14),

                              // ── Button 2: Resend Verification Link ───
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: OutlinedButton.icon(
                                  onPressed: (_canResend && !_isResending)
                                      ? _resendVerificationEmail
                                      : null,
                                  icon: _isResending
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.secondaryLight,
                                          ),
                                        )
                                      : Icon(
                                          Icons.refresh_rounded,
                                          size: 18,
                                          color: _canResend
                                              ? Colors.white
                                              : Colors.white.withValues(alpha: 0.45),
                                        ),
                                  label: Text(
                                    _canResend
                                        ? AppLocalizations.of(context).verifyResend
                                        : AppLocalizations.of(context).verifyResendIn(_secondsRemaining),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _canResend
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.55),
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white.withValues(
                                        alpha: _canResend ? 0.14 : 0.06),
                                    side: BorderSide(
                                      color: Colors.white.withValues(
                                          alpha: _canResend ? 0.45 : 0.2),
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // ── Button 3: Sign Out / Change Account ──
                              TextButton.icon(
                                onPressed: () {
                                  context.read<AuthBloc>().add(const LogoutRequested());
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/welcome',
                                    (r) => false,
                                  );
                                },
                                icon: Icon(
                                  Icons.logout_rounded,
                                  size: 16,
                                  color: soft,
                                ),
                                label: Text(
                                  AppLocalizations.of(context).verifyWrongEmail,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: soft,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Discreet defense note / bypass helper
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.glassSmoke,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context).verifyTip,
                            style: TextStyle(
                              fontSize: 12,
                              color: soft,
                              height: 1.45,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
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
