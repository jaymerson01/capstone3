import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_button.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_text_field.dart';

import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:community_safety_app/features/auth/presentation/pages/sign_up_page.dart';
import 'package:community_safety_app/features/auth/presentation/widgets/auth_modals.dart';

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

  late AnimationController _bgController;
  late AnimationController _cardController;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

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
    _bgController.dispose();
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
                content: Text(state.message),
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
              body: Stack(
                children: [
                  // ── Animated Background ─────────────────────────────────────────
                  AnimatedBuilder(
                    animation: _bgController,
                    builder: (context, _) {
                      return Stack(
                        children: [
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
                            top: -60 + (40 * _bgController.value),
                            right: -40,
                            child: _Orb(
                                size: 280,
                                color: AppColors.primary
                                    .withValues(alpha: isDark ? 0.1 : 0.07)),
                          ),
                          Positioned(
                            bottom: -100,
                            left: -60 + (20 * (1 - _bgController.value)),
                            child: _Orb(
                                size: 320,
                                color: AppColors.secondary
                                    .withValues(alpha: isDark ? 0.07 : 0.04)),
                          ),
                          CustomPaint(
                            size: Size(
                              MediaQuery.of(context).size.width,
                              MediaQuery.of(context).size.height,
                            ),
                            painter: _GridPainter(isDark: isDark),
                          ),
                        ],
                      );
                    },
                  ),

                  // ── Main Content ────────────────────────────────────────────────
                  SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: FadeTransition(
                          opacity: _cardFade,
                          child: SlideTransition(
                            position: _cardSlide,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Logo
                                Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(alpha: isDark ? 0.35 : 0.2),
                                        blurRadius: 24,
                                        spreadRadius: 4,
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
                                const SizedBox(height: 20),

                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      AppColors.cyanGradient.createShader(bounds),
                                  blendMode: BlendMode.srcIn,
                                  child: const Text(
                                    "SIGN IN",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 28,
                                      letterSpacing: 4,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Barangay Incident & Public Safety Portal",
                                  style: TextStyle(
                                      color: AppColors.textLight, fontSize: 13),
                                ),
                                const SizedBox(height: 28),

                                // ── Glass Login Card ──────────────────────────────────
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
                                          width: 1,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Semantics(
                                          label: 'email_input',
                                          child: Custom3dTextField(
                                            controller: _emailController,
                                            labelText: "Email Address",
                                            hintText: "e.g. juan@gmail.com",
                                            prefixIcon: Icons.email_outlined,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.trim().isEmpty) {
                                                return "Email is required.";
                                              }
                                              final emailRegex = RegExp(
                                                  r'^[\w-\.]+@gmail\.com$');
                                              if (!emailRegex.hasMatch(
                                                  value.trim().toLowerCase())) {
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
                                                  _obscurePassword =
                                                      !_obscurePassword),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Password is required.";
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
                                              "Forgot Password?",
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 18),

                                        Semantics(
                                          label: 'login_button',
                                          button: true,
                                          child: Custom3dButton(
                                            text: isLoading
                                                ? "SIGNING IN..."
                                                : "CONTINUE",
                                            icon: isLoading
                                                ? null
                                                : Icons.arrow_forward_rounded,
                                            gradient: AppColors.primaryGradient,
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
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                      height: 1,
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.12)
                                          : AppColors.border),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    "or continue with",
                                    style: TextStyle(
                                        color: AppColors.textLight,
                                        fontSize: 12),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                      height: 1,
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.12)
                                          : AppColors.border),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Google Sign-In Button
                            _googleSignInButton(context, isDark: isDark),

                            const SizedBox(height: 24),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: TextStyle(color: AppColors.textLight),
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
                                      "Sign Up",
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
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

  Widget _googleSignInButton(BuildContext context, {required bool isDark}) {
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
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AppColors.border),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_reset_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                "Reset Password",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter your registered email and we'll send you an official link to reset your password.",
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textLight,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: resetEmailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: AppColors.textDark, fontSize: 13.5),
                decoration: InputDecoration(
                  labelText: "Registered Email",
                  labelStyle: TextStyle(color: AppColors.textLight),
                  prefixIcon: Icon(Icons.email_outlined,
                      color: AppColors.primary, size: 20),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSending ? null : () => Navigator.pop(ctx),
              child: Text("Cancel",
                  style: TextStyle(color: AppColors.textLight)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: isSending
                  ? null
                  : () async {
                      final email = resetEmailCtrl.text.trim();
                      if (email.isEmpty || !email.contains('@')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Please enter a valid registered email address."),
                            backgroundColor: AppColors.warning,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isSending = true);
                      final messenger = ScaffoldMessenger.of(context);

                      try {
                        await FirebaseAuth.instance
                            .sendPasswordResetEmail(email: email);
                        if (ctx.mounted) Navigator.pop(ctx);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                                "Password reset email sent to $email! Please check your inbox."),
                            backgroundColor: AppColors.solved,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      } catch (e) {
                        setDialogState(() => isSending = false);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text("Failed to send reset link: $e"),
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
                  : Text("Send Link"),
            ),
          ],
        ),
      ),
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
        gradient: RadialGradient(colors: [color, Colors.transparent]),
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
      ..strokeWidth = 0.5;
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

class _SuccessDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.solved),
      ),
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
                    color: AppColors.solved.withValues(alpha: 0.35),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(Icons.check_circle_outline,
                  color: AppColors.solved, size: 40),
            ),
            SizedBox(height: 18),
            Text(
              "Welcome Back!",
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "You have successfully signed in.",
              style: TextStyle(color: AppColors.textLight, fontSize: 14),
            ),
            SizedBox(height: 24),
            Semantics(
              label: 'continue_dialog_button',
              button: true,
              child: Custom3dButton(
                text: "Continue",
                gradient: const LinearGradient(
                  colors: [AppColors.solved, Color(0xFF00A843)],
                ),
                height: 48,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
