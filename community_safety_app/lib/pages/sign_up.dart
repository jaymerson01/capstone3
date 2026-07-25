import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_color.dart';
import '../widgets/custom_3d_button.dart';
import '../widgets/custom_3d_card.dart';
import '../widgets/custom_3d_text_field.dart';
import '../services/mock_database_service.dart';
import 'login_page.dart';

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
  bool _isLoading = false;
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

  Future<void> _launchAuthUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw "Could not launch.";
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Redirect Error: $e"),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ));
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
            animation: _bgCtrl,
            builder: (context, _) {
              return Stack(children: [
                Container(
                    decoration:
                        const BoxDecoration(gradient: AppColors.commandGradient)),
                Positioned(
                  top: -80 + 60 * _bgCtrl.value,
                  left: -60,
                  child: _GlowOrb(
                      size: 320,
                      color: AppColors.primary.withValues(alpha: 0.09)),
                ),
                Positioned(
                  bottom: -60,
                  right: -40 + 30 * (1 - _bgCtrl.value),
                  child: _GlowOrb(
                      size: 380,
                      color: AppColors.secondary.withValues(alpha: 0.07)),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.4,
                  right: MediaQuery.of(context).size.width * 0.1,
                  child: _GlowOrb(
                      size: 220,
                      color: AppColors.accent.withValues(alpha: 0.05)),
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
                              color: AppColors.primary.withValues(alpha: 0.4),
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
                            errorBuilder: (_, __, ___) => Container(
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
                      const Text(
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
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Form(
                              key: _formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Custom3dTextField(
                                    controller: _nameController,
                                    labelText: "Full Name",
                                    hintText: "Enter your full name",
                                    prefixIcon: Icons.person_outline,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty)
                                        return "Name is required.";
                                      if (!RegExp(r'^[a-zA-Z\s\-]{2,50}$')
                                          .hasMatch(v.trim()))
                                        return "Letters, spaces, hyphens only (2-50 chars).";
                                      return null;
                                    },
                                  ),
                                  Custom3dTextField(
                                    controller: _emailController,
                                    labelText: "Email Address",
                                    hintText: "e.g. juan@gmail.com",
                                    prefixIcon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty)
                                        return "Email is required.";
                                      if (!RegExp(
                                              r'^[\w-\.]+@gmail\.com$')
                                          .hasMatch(v.trim().toLowerCase()))
                                        return "Enter a valid Gmail address.";
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
                                          _obscurePassword = !_obscurePassword),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return "Password is required.";
                                      if (v.contains(' '))
                                        return "No spaces allowed.";
                                      if (!RegExp(
                                              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[_\-@#\$%&!?*.]).{8,20}$')
                                          .hasMatch(v))
                                        return "8-20 chars, 1 upper, 1 lower, 1 num, 1 special.";
                                      return null;
                                    },
                                  ),
                                  Custom3dTextField(
                                    controller: _confirmPasswordController,
                                    labelText: "Confirm Password",
                                    hintText: "Repeat your password",
                                    prefixIcon: Icons.lock_outline,
                                    obscureText: _obscurePassword,
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return "Please confirm password.";
                                      if (v != _passwordController.text)
                                        return "Passwords do not match.";
                                      return null;
                                    },
                                  ),

                                  // ── Terms Checkbox ─────────────────────────
                                  GestureDetector(
                                    onTap: () => setState(
                                        () => _termsAccepted = !_termsAccepted),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: _termsAccepted
                                            ? AppColors.primary
                                                .withValues(alpha: 0.08)
                                            : AppColors.surfaceLight,
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
                                                ? const Icon(Icons.check,
                                                    color: Colors.white,
                                                    size: 14)
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          const Expanded(
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
                                  const SizedBox(height: 20),

                                  Custom3dButton(
                                    text: _isLoading
                                        ? "REGISTERING..."
                                        : "CREATE ACCOUNT",
                                    icon: _isLoading
                                        ? null
                                        : Icons.check_circle_outline,
                                    gradient: AppColors.primaryGradient,
                                    onPressed: (!_termsAccepted || _isLoading)
                                        ? null
                                        : () async {
                                            if (!_formKey.currentState!
                                                .validate()) return;
                                            setState(
                                                () => _isLoading = true);
                                            final name = _nameController.text
                                                .trim();
                                            final email = _emailController
                                                .text
                                                .trim();
                                            final password =
                                                _passwordController.text;
                                            final err =
                                                await MockDatabaseService()
                                                    .signUp(name, email,
                                                        password, "Reporter");
                                            if (!context.mounted) return;
                                            setState(
                                                () => _isLoading = false);
                                            if (err == null) {
                                              await _showSuccessDialog(
                                                  context);
                                              if (context.mounted) {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          const LoginPage()),
                                                );
                                              }
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                content: Text(err),
                                                backgroundColor:
                                                    AppColors.danger,
                                                behavior: SnackBarBehavior
                                                    .floating,
                                              ));
                                            }
                                          },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Divider ────────────────────────────────────────────
                      Row(children: [
                        Expanded(
                            child: Container(
                                height: 1,
                                color: Colors.white.withValues(alpha: 0.12))),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text("or continue with",
                              style: TextStyle(
                                  color: AppColors.textLight, fontSize: 12)),
                        ),
                        Expanded(
                            child: Container(
                                height: 1,
                                color: Colors.white.withValues(alpha: 0.12))),
                      ]),
                      const SizedBox(height: 14),

                      // ── Social Buttons ──────────────────────────────────────
                      _SocialButton(
                        label: "Continue with Google",
                        icon: Icons.g_mobiledata,
                        url:
                            "https://accounts.google.com/v3/signin/identifier",
                        onTap: (url) => _launchAuthUrl(context, url),
                      ),
                      const SizedBox(height: 10),
                      _SocialButton(
                        label: "Continue with Facebook",
                        icon: Icons.facebook,
                        url: "https://www.facebook.com/login/",
                        onTap: (url) => _launchAuthUrl(context, url),
                      ),
                      const SizedBox(height: 10),
                      _SocialButton(
                        label: "Continue with Apple",
                        icon: Icons.apple,
                        url: "https://appleid.apple.com/auth/authorize",
                        onTap: (url) => _launchAuthUrl(context, url),
                      ),
                      const SizedBox(height: 24),

                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
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
  }

  Future<void> _showSuccessDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
                color: AppColors.solved.withValues(alpha: 0.3))),
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
                child: const Icon(Icons.check_circle_outline,
                    color: AppColors.solved, size: 38),
              ),
              const SizedBox(height: 18),
              const Text(
                "Account Created!",
                style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                "You have successfully registered. Please log in to continue.",
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
                          "Proceed to Login",
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

class _SocialButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final String url;
  final void Function(String) onTap;
  const _SocialButton(
      {required this.label,
      required this.icon,
      required this.url,
      required this.onTap});

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap(widget.url);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: _pressed
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: _pressed
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, size: 24, color: AppColors.textDark),
            const SizedBox(width: 10),
            Text(
              widget.label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
