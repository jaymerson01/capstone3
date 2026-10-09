import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_button.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_text_field.dart';

import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:community_safety_app/features/auth/presentation/pages/email_verification_page.dart';

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

  late AnimationController _bgCtrl;
  late AnimationController _cardCtrl;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 12))
      ..repeat(reverse: true);
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
    _bgCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.message),
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
            return Scaffold(
              backgroundColor: AppColors.background,
              body: Stack(
                children: [
                  // ── Animated Background ─────────────────────────────────────────
                  AnimatedBuilder(
                    animation: _bgCtrl,
                    builder: (context, _) {
                      return Stack(children: [
                        Container(
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
                        Positioned(
                          top: -80 + 60 * _bgCtrl.value,
                          left: -60,
                          child: _GlowOrb(
                              size: 320,
                              color: AppColors.primary
                                  .withValues(alpha: isDark ? 0.09 : 0.06)),
                        ),
                        Positioned(
                          bottom: -60,
                          right: -40 + 30 * (1 - _bgCtrl.value),
                          child: _GlowOrb(
                              size: 380,
                              color: AppColors.secondary
                                  .withValues(alpha: isDark ? 0.07 : 0.04)),
                        ),
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.4,
                          right: MediaQuery.of(context).size.width * 0.1,
                          child: _GlowOrb(
                              size: 220,
                              color: AppColors.accent
                                  .withValues(alpha: isDark ? 0.05 : 0.03)),
                        ),
                      ]);
                    },
                  ),

                  // ── Content ──────────────────────────────────────────────────────
                  SafeArea(
                    child: FadeTransition(
                      opacity: _cardFade,
                      child: SlideTransition(
                        position: _cardSlide,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          child: Column(
                            children: [
                              // ── Brand header ─────────────────────────────────────
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: isDark ? 0.4 : 0.2),
                                      blurRadius: 24,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      width: 60,
                                      height: 60,
                                      color: AppColors.primary,
                                      child: const Icon(Icons.shield,
                                          color: Colors.white, size: 30),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              ShaderMask(
                                shaderCallback: (b) =>
                                    AppColors.cyanGradient.createShader(b),
                                blendMode: BlendMode.srcIn,
                                child: const Text(
                                  "CREATE ACCOUNT",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 24,
                                    letterSpacing: 3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Join the RESQ Barangay Safety Network",
                                style: TextStyle(
                                    color: AppColors.textLight, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),

                              // ── Glass Card Form ────────────────────────────────────
                              ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.06)
                                          : Colors.white.withValues(alpha: 0.92),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white.withValues(alpha: 0.1)
                                            : AppColors.border,
                                      ),
                                      boxShadow: isDark
                                          ? []
                                          : [
                                              BoxShadow(
                                                color: const Color(0x140A1628),
                                                blurRadius: 24,
                                                offset: const Offset(0, 8),
                                              ),
                                            ],
                                    ),
                                    padding: const EdgeInsets.all(24),
                                child: Form(
                                  key: _formKey,
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Semantics(
                                        label: 'name_input',
                                        child: Custom3dTextField(
                                          controller: _nameController,
                                          labelText: "Full Name",
                                        hintText: "Enter your full name",
                                        prefixIcon: Icons.person_outline,
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty) {
                                            return "Name is required.";
                                          }
                                          if (!RegExp(r'^[a-zA-Z\s\-]{2,50}$')
                                              .hasMatch(v.trim())) {
                                            return "Letters, spaces, hyphens only (2-50 chars).";
                                          }
                                          return null;
                                        },
                                      ),
                                      ),
                                      Semantics(
                                        label: 'email_input',
                                        child: Custom3dTextField(
                                          controller: _emailController,
                                          labelText: "Email Address",
                                        hintText: "e.g. juan@gmail.com",
                                        prefixIcon: Icons.email_outlined,
                                        keyboardType: TextInputType.emailAddress,
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty) {
                                            return "Email is required.";
                                          }
                                          if (!RegExp(
                                                  r'^[\w-\.]+@gmail\.com$')
                                              .hasMatch(v.trim().toLowerCase())) {
                                            return "Enter a valid Gmail address.";
                                          }
                                          return null;
                                        },
                                      ),
                                      ),
                                      Semantics(
                                        label: 'password_input',
                                        child: Custom3dTextField(
                                          controller: _passwordController,
                                          labelText: "Password",
                                        hintText: "e.g. Moonwalk#01",
                                        prefixIcon: Icons.lock_outline,
                                        obscureText: _obscurePassword,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: AppColors.textLight,
                                            size: 20,
                                          ),
                                          onPressed: () => setState(() =>
                                              _obscurePassword = !_obscurePassword),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.isEmpty) {
                                            return "Password is required.";
                                          }
                                          if (v.contains(' ')) {
                                            return "No spaces allowed.";
                                          }
                                          if (!RegExp(
                                                  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[_\-@#\$%&!?*.]).{8,20}$')
                                              .hasMatch(v)) {
                                            return "8-20 chars, 1 upper, 1 lower, 1 num, 1 special.";
                                          }
                                          return null;
                                        },
                                      ),
                                      ),
                                      Semantics(
                                        label: 'confirm_password_input',
                                        child: Custom3dTextField(
                                          controller: _confirmPasswordController,
                                          labelText: "Confirm Password",
                                        hintText: "Repeat your password",
                                        prefixIcon: Icons.lock_outline,
                                        obscureText: _obscurePassword,
                                        validator: (v) {
                                          if (v == null || v.isEmpty) {
                                            return "Please confirm password.";
                                          }
                                          if (v != _passwordController.text) {
                                            return "Passwords do not match.";
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
                                            color: _termsAccepted
                                                ? AppColors.primary
                                                    .withValues(alpha: 0.08)
                                                : (isDark
                                                    ? AppColors.surfaceLight
                                                    : Colors.white),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: _termsAccepted
                                                  ? AppColors.primary
                                                      .withValues(alpha: 0.35)
                                                  : AppColors.border,
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
                                                      ? AppColors.primary
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: _termsAccepted
                                                        ? AppColors.primary
                                                        : AppColors.textLight,
                                                    width: 2,
                                                  ),
                                                  boxShadow: _termsAccepted
                                                      ? [
                                                          BoxShadow(
                                                            color: AppColors
                                                                .primary
                                                                .withValues(alpha: 0.4),
                                                            blurRadius: 8,
                                                          )
                                                        ]
                                                      : [],
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
                                                  "I accept the Terms and Conditions",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textDark,
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
                                              ? "REGISTERING..."
                                              : "CREATE ACCOUNT",
                                        icon: isLoading
                                            ? null
                                            : Icons.check_circle_outline,
                                        gradient: AppColors.primaryGradient,
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
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          // ── Divider ────────────────────────────────────────────
                          Row(children: [
                            Expanded(
                                child: Container(
                                    height: 1,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.12)
                                        : AppColors.border)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text("or continue with",
                                  style: TextStyle(
                                      color: AppColors.textLight, fontSize: 12)),
                            ),
                            Expanded(
                                child: Container(
                                    height: 1,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.12)
                                        : AppColors.border)),
                          ]),
                          const SizedBox(height: 14),

                          // ── Google Sign-In Button ──────────────────────────────
                          _googleSignUpButton(context, isDark: isDark),

                          const SizedBox(height: 24),

                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Already have an account? Sign In",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primary,
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
            ],
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
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
                color: AppColors.solved.withValues(alpha: 0.3))),
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.solved.withValues(alpha: 0.12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.solved.withValues(alpha: 0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      )
                    ],
                  ),
                  child: Icon(Icons.mark_email_unread_rounded,
                      color: AppColors.solved, size: 38),
                ),
                const SizedBox(height: 18),
                Text(
                  "Account Created!",
                  style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 20,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  email != null && email.isNotEmpty
                      ? "A verification link was sent to $email. Please verify your email to activate your account."
                      : "A verification link was sent to your email. Please verify your email to activate your account.",
                  style: TextStyle(
                      color: AppColors.textLight, fontSize: 13, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppColors.primaryGlowShadow,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.pop(ctx),
                        child: const Center(
                          child: Text(
                            "Proceed to Verification",
                            style: TextStyle(
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
      ),
    );
  }

  Widget _googleSignUpButton(BuildContext context, {required bool isDark}) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceLight : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.border
              : AppColors.border.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            offset: const Offset(0, 3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.read<AuthBloc>().add(const GoogleSignInRequested());
          },
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.g_mobiledata, size: 28, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                "Continue with Google",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Supporting Widgets ────────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }
}
