import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/presentation/neo/glass_card.dart';
import 'package:community_safety_app/core/presentation/neo/landscape_backdrop.dart';
import 'package:community_safety_app/core/presentation/neo/live_indicator.dart';
import 'package:community_safety_app/core/presentation/neo/neo_dialog.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_button.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_text_field.dart';

import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:community_safety_app/features/auth/presentation/pages/sign_up_page.dart';
import 'package:community_safety_app/features/auth/presentation/widgets/auth_glass_widgets.dart';
import 'package:community_safety_app/features/auth/presentation/widgets/auth_modals.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';
import 'package:community_safety_app/core/utils/localized_labels.dart';
import 'package:community_safety_app/core/theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  late AnimationController _cardController;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _cardController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthError) {
          if (state.message.toLowerCase().contains("locked")) {
            AuthModals.showAccountLocked(
                context, DateTime.now().add(const Duration(minutes: 15)));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(LocalizedLabels.authError(
                  context,
                  code: state.code,
                  message: state.message,
                )),
                backgroundColor: AppColors.danger,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else if (state is Authenticated) {
          if (state.user.isAdmin) {
            context.read<AuthBloc>().add(const LogoutRequested());
            AuthModals.showAdminAccountBlocked(context);
            return;
          }

          final isVerified = (FirebaseAuth.instance.currentUser?.emailVerified ?? false) || state.user.isVerified;
          if (!isVerified) {
            Navigator.pushReplacementNamed(context, '/email-verification');
            return;
          }
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => _SuccessDialog(),
          );
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return ValueListenableBuilder<bool>(
          valueListenable: AppColors.isDarkModeNotifier,
          builder: (context, isDark, _) {
            return Scaffold(
              backgroundColor: AppColors.background,
              // ── Dusk landscape (night in dark mode) ───────────────────────
              body: LandscapeBackdrop(
                time: isDark ? LandscapeTime.night : LandscapeTime.dusk,
                child: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: FadeTransition(
                          opacity: _cardFade,
                          child: SlideTransition(
                            position: _cardSlide,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const AuthBrandLogo(),
                                const SizedBox(height: 18),

                                // ── Smoked Glass Login Card ───────────────────
                                GlassCard(
                                  tone: GlassTone.smoke,
                                  blur: true,
                                  borderRadius: 30,
                                  padding:
                                      const EdgeInsets.fromLTRB(22, 26, 22, 24),
                                  child: Form(
                                    key: _formKey,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context).loginTitle,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 30,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          AppLocalizations.of(context).loginSubtitle,
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.92),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 22),

                                        Semantics(
                                          label: 'email_input',
                                          child: Custom3dTextField(
                                            controller: _emailController,
                                            onGlass: true,
                                            labelText: AppLocalizations.of(context).authEmailLabel,
                                            hintText: AppLocalizations.of(context).authEmailHint,
                                            prefixIcon: Icons.email_outlined,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.trim().isEmpty) {
                                                return AppLocalizations.of(context).authEmailRequired;
                                              }
                                              final emailRegex = RegExp(
                                                  r'^[\w-\.]+@gmail\.com$');
                                              if (!emailRegex.hasMatch(
                                                  value.trim().toLowerCase())) {
                                                return AppLocalizations.of(context).authEmailInvalid;
                                              }
                                              return null;
                                            },
                                          ),
                                        ),

                                        Semantics(
                                          label: 'password_input',
                                          child: Custom3dTextField(
                                            controller: _passwordController,
                                            onGlass: true,
                                            labelText: AppLocalizations.of(context).authPasswordLabel,
                                            hintText: AppLocalizations.of(context).authPasswordHint,
                                            prefixIcon: Icons.lock_outline,
                                            obscureText: _obscurePassword,
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_off
                                                    : Icons.visibility,
                                                color: Colors.white
                                                    .withValues(alpha: 0.9),
                                                size: 20,
                                              ),
                                              onPressed: () => setState(() =>
                                                  _obscurePassword =
                                                      !_obscurePassword),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return AppLocalizations.of(context).authPasswordRequired;
                                              }
                                              return null;
                                            },
                                          ),
                                        ),

                                        // Forgot Password
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () =>
                                                _showForgotPasswordDialog(
                                                    context),
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: Text(
                                              AppLocalizations.of(context).loginForgotPassword,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 14),

                                        Semantics(
                                          label: 'login_button',
                                          button: true,
                                          child: Custom3dButton(
                                            text: isLoading
                                                ? AppLocalizations.of(context).loginSigningIn
                                                : AppLocalizations.of(context).loginContinue,
                                            icon: isLoading
                                                ? null
                                                : Icons.arrow_forward_rounded,
                                            gradient: AppColors.ctaGradient,
                                            borderRadius: 16,
                                            borderColor: AppColors.secondary
                                                .withValues(alpha: 0.35),
                                            onPressed: isLoading
                                                ? null
                                                : () {
                                                    if (!_formKey.currentState!
                                                        .validate()) {
                                                      return;
                                                    }
                                                    
                                                    final email = _emailController
                                                        .text
                                                        .trim();
                                                    final password =
                                                        _passwordController.text;
                                                    
                                                    context.read<AuthBloc>().add(
                                                      LoginRequested(email, password)
                                                    );
                                                  },
                                          ),
                                        ),
                                        const SizedBox(height: 18),

                                        AuthGlassDivider(
                                          label: AppLocalizations.of(context)
                                              .authOrContinueWith,
                                        ),
                                        const SizedBox(height: 14),

                                        // Google Sign-In Button
                                        AuthGoogleButton(
                                          label: AppLocalizations.of(context)
                                              .authContinueWithGoogle,
                                          onTap: () {
                                            context.read<AuthBloc>().add(
                                                const GoogleSignInRequested());
                                          },
                                        ),

                                        const SizedBox(height: 18),

                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                AppLocalizations.of(context).loginNoAccount,
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.92),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Semantics(
                                              button: true,
                                              label: 'nav_to_signup',
                                              child: GestureDetector(
                                                onTap: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) => const SignUpPage()),
                                                ),
                                                child: Text(
                                                  AppLocalizations.of(context).authSignUp,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w800,
                                                    decoration: TextDecoration.underline,
                                                    decorationColor: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
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
      },
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final resetEmailCtrl =
        TextEditingController(text: _emailController.text.trim());
    bool isSending = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          title: Row(
            children: [
              NeoDialogIcon(
                icon: Icons.lock_reset_rounded,
                color: AppColors.primary,
                size: 40,
              ),
              SizedBox(width: 12),
              Flexible(
                child: Text(
                  AppLocalizations.of(context).resetTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).resetMessage,
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textLight,
                  height: 1.45,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: resetEmailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: AppColors.textDark, fontSize: 13.5),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).resetEmailLabel,
                  labelStyle: TextStyle(color: AppColors.textLight),
                  prefixIcon: Icon(Icons.email_outlined,
                      color: AppColors.primary, size: 20),
                  filled: true,
                  fillColor: AppColors.isDarkMode
                      ? AppColors.surfaceLight
                      : const Color(0xFFEEF2F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.surfaceLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.surfaceLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSending ? null : () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context).commonCancel,
                  style: TextStyle(
                      color: AppColors.textLight, fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w700,
                ),
                shape: const StadiumBorder(),
              ),
              onPressed: isSending
                  ? null
                  : () async {
                      final email = resetEmailCtrl.text.trim();
                      if (email.isEmpty || !email.contains('@')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context).resetEmailInvalid),
                            backgroundColor: AppColors.warning,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isSending = true);
                      final messenger = ScaffoldMessenger.of(context);
                      final l10n = AppLocalizations.of(context);

                      try {
                        await FirebaseAuth.instance
                            .sendPasswordResetEmail(email: email);
                        if (ctx.mounted) Navigator.pop(ctx);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(l10n.resetSent(email)),
                            backgroundColor: AppColors.solved,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      } catch (e) {
                        setDialogState(() => isSending = false);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(l10n.resetFailed('$e')),
                            backgroundColor: AppColors.danger,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
              child: isSending
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(AppLocalizations.of(context).resetSendLink),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Supporting Widgets ───────────────────────────────────────────────────────

class _SuccessDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NeoDialog(
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LiveIndicator.ring(
              size: 74,
              child: Icon(Icons.check_rounded),
            ),
            SizedBox(height: 18),
            Text(
              AppLocalizations.of(context).loginWelcomeBack,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).loginSuccess,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textLight, fontSize: 14),
            ),
            SizedBox(height: 24),
            Semantics(
              label: 'continue_dialog_button',
              button: true,
              child: Custom3dButton(
                text: AppLocalizations.of(context).commonContinue,
                gradient: AppColors.primaryGradient,
                height: 52,
                borderRadius: 26,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
