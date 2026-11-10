import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:community_safety_app/features/auth/presentation/pages/email_verification_page.dart';
import 'package:community_safety_app/features/auth/presentation/widgets/auth_glass_widgets.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';
import 'package:community_safety_app/core/utils/localized_labels.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _termsAccepted = false;

  late AnimationController _cardCtrl;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 850));
    _cardFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut));
    _cardSlide =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
            CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 100),
        () => mounted ? _cardCtrl.forward() : null);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(LocalizedLabels.authError(
              context,
              code: state.code,
              message: state.message,
            )),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ));
        } else if (state is Authenticated) {
          final isVerified = (FirebaseAuth.instance.currentUser?.emailVerified ?? false) || state.user.isVerified;
          if (!isVerified) {
            await _showSuccessDialog(context, email: state.user.email);
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => EmailVerificationPage(user: state.user),
                ),
              );
            }
          } else {
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, '/dashboard');
            }
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return ValueListenableBuilder<bool>(
          valueListenable: AppColors.isDarkModeNotifier,
          builder: (context, isDark, _) {
            final eyeColor = Colors.white.withValues(alpha: 0.9);
            return Scaffold(
              backgroundColor: AppColors.background,
              // ── Dusk landscape (night in dark mode) ───────────────────────
              body: LandscapeBackdrop(
                time: isDark ? LandscapeTime.night : LandscapeTime.dusk,
                child: SafeArea(
                  child: FadeTransition(
                    opacity: _cardFade,
                    child: SlideTransition(
                      position: _cardSlide,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 460),
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                const AuthBrandLogo(size: 64),
                                const SizedBox(height: 18),

                                // ── Smoked Glass Form Card ────────────────────
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context).signUpTitle,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 26,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          AppLocalizations.of(context).signUpSubtitle,
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.92),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 22),
                                        Semantics(
                                          label: 'name_input',
                                          child: Custom3dTextField(
                                            controller: _nameController,
                                            onGlass: true,
                                            labelText: AppLocalizations.of(context).signUpNameLabel,
                                          hintText: AppLocalizations.of(context).signUpNameHint,
                                          prefixIcon: Icons.person_outline,
                                          validator: (v) {
                                            if (v == null || v.trim().isEmpty) {
                                              return AppLocalizations.of(context).signUpNameRequired;
                                            }
                                            if (!RegExp(r'^[a-zA-Z\s\-]{2,50}$')
                                                .hasMatch(v.trim())) {
                                              return AppLocalizations.of(context).signUpNameInvalid;
                                            }
                                            return null;
                                          },
                                        ),
                                        ),
                                        Semantics(
                                          label: 'email_input',
                                          child: Custom3dTextField(
                                            controller: _emailController,
                                            onGlass: true,
                                            labelText: AppLocalizations.of(context).authEmailLabel,
                                          hintText: AppLocalizations.of(context).authEmailHint,
                                          prefixIcon: Icons.email_outlined,
                                          keyboardType: TextInputType.emailAddress,
                                          validator: (v) {
                                            if (v == null || v.trim().isEmpty) {
                                              return AppLocalizations.of(context).authEmailRequired;
                                            }
                                            if (!RegExp(
                                                    r'^[\w-\.]+@gmail\.com$')
                                                .hasMatch(v.trim().toLowerCase())) {
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
                                              color: eyeColor,
                                              size: 20,
                                            ),
                                            onPressed: () => setState(() =>
                                                _obscurePassword = !_obscurePassword),
                                          ),
                                          validator: (v) {
                                            if (v == null || v.isEmpty) {
                                              return AppLocalizations.of(context).authPasswordRequired;
                                            }
                                            if (v.contains(' ')) {
                                              return AppLocalizations.of(context).signUpPasswordNoSpaces;
                                            }
                                            if (!RegExp(
                                                    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[_\-@#\$%&!?*.]).{8,20}$')
                                                .hasMatch(v)) {
                                              return AppLocalizations.of(context).signUpPasswordRules;
                                            }
                                            return null;
                                          },
                                        ),
                                        ),
                                        Semantics(
                                          label: 'confirm_password_input',
                                          child: Custom3dTextField(
                                            controller: _confirmPasswordController,
                                            onGlass: true,
                                            labelText: AppLocalizations.of(context).signUpConfirmLabel,
                                          hintText: AppLocalizations.of(context).signUpConfirmHint,
                                          prefixIcon: Icons.lock_outline,
                                          obscureText: _obscurePassword,
                                          validator: (v) {
                                            if (v == null || v.isEmpty) {
                                              return AppLocalizations.of(context).signUpConfirmRequired;
                                            }
                                            if (v != _passwordController.text) {
                                              return AppLocalizations.of(context).signUpPasswordMismatch;
                                            }
                                            return null;
                                          },
                                        ),
                                        ),

                                        // ── Terms Checkbox ─────────────────────────
                                        Semantics(
                                          button: true,
                                          label: 'terms_checkbox',
                                          child: GestureDetector(
                                            onTap: () => setState(
                                                () => _termsAccepted = !_termsAccepted),
                                            child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                  alpha: _termsAccepted ? 0.12 : 0.06),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                color: _termsAccepted
                                                    ? AppColors.solved
                                                        .withValues(alpha: 0.8)
                                                    : Colors.white
                                                        .withValues(alpha: 0.3),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 150),
                                                  width: 22,
                                                  height: 22,
                                                  decoration: BoxDecoration(
                                                    color: _termsAccepted
                                                        ? AppColors.solved
                                                        : Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                    border: Border.all(
                                                      color: _termsAccepted
                                                          ? AppColors.solved
                                                          : Colors.white
                                                              .withValues(alpha: 0.8),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: _termsAccepted
                                                      ? Icon(Icons.check,
                                                          color: Colors.white,
                                                          size: 14)
                                                      : null,
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    AppLocalizations.of(context).signUpAcceptTerms,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        ),
                                        SizedBox(height: 20),

                                        Semantics(
                                          button: true,
                                          label: 'register_button',
                                          child: Custom3dButton(
                                            text: isLoading
                                                ? AppLocalizations.of(context).signUpRegistering
                                                : AppLocalizations.of(context).signUpButton,
                                          icon: isLoading
                                              ? null
                                              : Icons.check_circle_outline,
                                          gradient: AppColors.ctaGradient,
                                          borderRadius: 16,
                                          borderColor: AppColors.secondary
                                              .withValues(alpha: 0.35),
                                          onPressed: (!_termsAccepted || isLoading)
                                              ? null
                                              : () {
                                                  if (!_formKey.currentState!
                                                      .validate()) {
                                                    return;
                                                  }
                                                  final email = _emailController
                                                      .text
                                                      .trim();
                                                  final password = _passwordController.text;
                                                  final fullName = _nameController.text.trim();
                                                  context.read<AuthBloc>().add(
                                                    RegisterRequested(
                                                      email,
                                                      password,
                                                      fullName: fullName,
                                                      role: 'resident',
                                                    ),
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

                                        // ── Google Sign-In Button ──────────────
                                        AuthGoogleButton(
                                          label: AppLocalizations.of(context)
                                              .authContinueWithGoogle,
                                          onTap: () {
                                            context.read<AuthBloc>().add(
                                                const GoogleSignInRequested());
                                          },
                                        ),
                                        const SizedBox(height: 10),

                                        Center(
                                          child: TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text(
                                              AppLocalizations.of(context).signUpHaveAccount,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                                decoration: TextDecoration.underline,
                                                decorationColor: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
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

  Future<void> _showSuccessDialog(BuildContext context, {String? email}) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => NeoDialog(
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LiveIndicator.ring(
                size: 74,
                child: Icon(Icons.mark_email_unread_rounded),
              ),
              const SizedBox(height: 18),
              Text(
                AppLocalizations.of(context).signUpCreatedTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                email != null && email.isNotEmpty
                    ? AppLocalizations.of(context).signUpVerificationSentTo(email)
                    : AppLocalizations.of(context).signUpVerificationSent,
                style: TextStyle(
                    color: AppColors.textLight, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: AppColors.primaryGlowShadow,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(26),
                      onTap: () => Navigator.pop(ctx),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context).signUpProceedToVerification,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15),
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
    );
  }
}
