import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_color.dart';
import '../widgets/custom_3d_button.dart';
import '../widgets/custom_3d_card.dart';
import '../widgets/custom_3d_text_field.dart';
import 'dashboard.dart';
import 'sign_up.dart';

import '../services/mock_database_service.dart';
import '../widgets/auth_modals.dart';
import '../admin/admin_panel_shell.dart';

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
  bool _rememberMe = false;
  bool _isLoading = false;

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

  Future<void> _launchAuthUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw "Could not redirect to authorization screen.";
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Redirect Error: ${e.toString()}"),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    decoration: const BoxDecoration(
                      gradient: AppColors.commandGradient,
                    ),
                  ),
                  Positioned(
                    top: -60 + (40 * _bgController.value),
                    right: -40,
                    child: _Orb(
                        size: 280,
                        color: AppColors.primary.withValues(alpha: 0.1)),
                  ),
                  Positioned(
                    bottom: -100,
                    left: -60 + (20 * (1 - _bgController.value)),
                    child: _Orb(
                        size: 320,
                        color: AppColors.secondary.withValues(alpha: 0.07)),
                  ),
                  CustomPaint(
                    size: Size(
                      MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height,
                    ),
                    painter: _GridPainter(),
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
                                color: AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
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
                        const Text(
                          "Barangay Incident & Public Safety Portal",
                          style:
                              TextStyle(color: AppColors.textLight, fontSize: 13),
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
                                color: Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color:
                                      Colors.white.withValues(alpha: 0.1),
                                  width: 1,
                                ),
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
                                    Custom3dTextField(
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

                                    Custom3dTextField(
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

                                    // Remember Me
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: Checkbox(
                                            value: _rememberMe,
                                            onChanged: (v) => setState(
                                                () => _rememberMe =
                                                    v ?? false),
                                            activeColor: AppColors.primary,
                                            side: const BorderSide(
                                                color: AppColors.border),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          "Remember Me",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textLight,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 22),

                                    Custom3dButton(
                                      text: _isLoading
                                          ? "SIGNING IN..."
                                          : "CONTINUE",
                                      icon: _isLoading
                                          ? null
                                          : Icons.arrow_forward_rounded,
                                      gradient: AppColors.primaryGradient,
                                      onPressed: _isLoading
                                          ? null
                                          : () async {
                                              if (!_formKey.currentState!
                                                  .validate()) return;
                                              setState(() =>
                                                  _isLoading = true);

                                              final email = _emailController
                                                  .text
                                                  .trim();
                                              final password =
                                                  _passwordController.text;
                                              final db =
                                                  MockDatabaseService();
                                              final errorMessage =
                                                  await db.login(
                                                      email, password);

                                              if (!context.mounted) return;
                                              setState(
                                                  () => _isLoading = false);

                                              if (errorMessage == null) {
                                                await showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (_) =>
                                                      _SuccessDialog(),
                                                );
                                                if (context.mounted) {
                                                  if (db.currentUser?.role
                                                          .toLowerCase() ==
                                                      'admin') {
                                                    Navigator
                                                        .pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            const AdminPanelShell(),
                                                      ),
                                                    );
                                                  } else {
                                                    Navigator
                                                        .pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            const DashboardPage(),
                                                      ),
                                                    );
                                                  }
                                                }
                                              } else {
                                                if (errorMessage
                                                    .contains("locked")) {
                                                  final expiration = db
                                                      .getLockoutExpiration(
                                                          email);
                                                  if (expiration != null) {
                                                    AuthModals
                                                        .showAccountLocked(
                                                            context,
                                                            expiration);
                                                  } else {
                                                    AuthModals
                                                        .showInvalidCredentials(
                                                            context);
                                                  }
                                                } else {
                                                  AuthModals
                                                      .showInvalidCredentials(
                                                          context);
                                                }
                                              }
                                            },
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
                                  color: AppColors.border),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
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
                                  color: AppColors.border),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Social Buttons
                        _socialButton(
                          context,
                          "Continue with Google",
                          Icons.g_mobiledata,
                          "https://accounts.google.com/signin",
                        ),
                        const SizedBox(height: 10),
                        _socialButton(
                          context,
                          "Continue with Facebook",
                          Icons.facebook,
                          "https://www.facebook.com/login/",
                        ),
                        const SizedBox(height: 10),
                        _socialButton(
                          context,
                          "Continue with Apple",
                          Icons.apple,
                          "https://appleid.apple.com/auth/authorize",
                        ),

                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(color: AppColors.textLight),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SignUpPage()),
                              ),
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.primary,
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
  }

  Widget _socialButton(
    BuildContext context,
    String text,
    IconData icon,
    String targetUrl,
  ) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
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
          onTap: () => _launchAuthUrl(context, targetUrl),
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: AppColors.textDark),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
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
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
              child: const Icon(Icons.check_circle_outline,
                  color: AppColors.solved, size: 40),
            ),
            const SizedBox(height: 18),
            const Text(
              "Welcome Back!",
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "You have successfully signed in.",
              style: TextStyle(color: AppColors.textLight, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Custom3dButton(
              text: "Continue",
              gradient: const LinearGradient(
                colors: [AppColors.solved, Color(0xFF00A843)],
              ),
              height: 48,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
