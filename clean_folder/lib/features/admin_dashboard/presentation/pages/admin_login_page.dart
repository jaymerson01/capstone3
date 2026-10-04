import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_button.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:community_safety_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';

class AdminLoginPage extends StatefulWidget {
  final String? initialErrorMessage;
  const AdminLoginPage({super.key, this.initialErrorMessage});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _errorMessage;
  bool _isLoading = false;

  late AnimationController _bgController;
  late AnimationController _cardController;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    _errorMessage = widget.initialErrorMessage;
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardFade = CurvedAnimation(parent: _cardController, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.14),
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

  Future<void> _handleLogin() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    debugPrint("🔑 [AdminLogin] Attempting admin sign-in for: '$email'");

    try {
      final authRepo = sl<AuthRepository>();
      final result = await authRepo.signInWithEmail(email, password);

      if (!mounted) return;

      result.fold(
        (failure) {
          debugPrint("❌ [AdminLogin] Sign-in failure: ${failure.message}");
          setState(() {
            _isLoading = false;
            _errorMessage = failure.message;
          });
        },
        (user) async {
          debugPrint("👤 [AdminLogin] User authenticated: ${user.email} (Role: '${user.role}', UID: ${user.id})");
          if (user.isAdmin) {
            try {
              await Hive.box('auth').put('isLoggedIn', true);
              await Hive.box('auth').put('userRole', user.role);
            } catch (_) {}
            if (!mounted) return;
            context.read<AuthBloc>().add(const AuthCheckRequested());
            setState(() => _isLoading = false);
            debugPrint("🚀 [AdminLogin] Access granted. Navigating to /admin/dashboard");
            Navigator.pushReplacementNamed(context, '/admin/dashboard');
          } else {
            debugPrint("⛔ [AdminLogin] Access Denied: User role is '${user.role}' instead of 'admin'.");
            await authRepo.signOut();
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _errorMessage =
                  "Access Denied: Account '${user.email}' has role '${user.role}', which does not have Admin privileges.";
            });
          }
        },
      );
    } catch (e, stack) {
      debugPrint("💥 [AdminLogin] Exception during login: $e\n$stack");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController =
        TextEditingController(text: _emailController.text.trim());
    final messenger = ScaffoldMessenger.of(context);
    bool isSending = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogStateContext, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF0D1627),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF1E2D4A)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lock_reset_rounded,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Reset Admin Password",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter your registered municipal admin email address. We will dispatch a secure Google password reset link directly to your inbox.",
                style: TextStyle(
                    color: Color(0xFF98A6BE), fontSize: 12.5, height: 1.4),
              ),
              const SizedBox(height: 16),
              Custom3dTextField(
                controller: resetEmailController,
                labelText: "Admin Email",
                hintText: "admin@example.com",
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSending ? null : () => Navigator.pop(dialogCtx),
              child: const Text("Cancel",
                  style: TextStyle(color: AppColors.textLight)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isSending
                  ? null
                  : () async {
                      final email = resetEmailController.text.trim();
                      if (email.isEmpty || !email.contains('@')) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Please enter a valid registered email address."),
                            backgroundColor: AppColors.warning,
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isSending = true);
                      try {
                        await FirebaseAuth.instance
                            .sendPasswordResetEmail(email: email);
                        if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                                "Password reset email dispatched to $email! Please check your inbox."),
                            backgroundColor: AppColors.solved,
                            duration: const Duration(seconds: 6),
                          ),
                        );
                      } catch (e) {
                        setDialogState(() => isSending = false);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text("Failed to send reset link: $e"),
                            backgroundColor: AppColors.danger,
                          ),
                        );
                      }
                    },
              child: isSending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text("Send Reset Link"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Animated Background ──────────────────────────────────────────
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, _) {
              return Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                        gradient: AppColors.commandGradient),
                  ),
                  // Ambient orbs
                  Positioned(
                    top: -60 + (50 * _bgController.value),
                    right: -40,
                    child: _Orb(
                        size: 300,
                        color: AppColors.primary.withValues(alpha: 0.08)),
                  ),
                  Positioned(
                    bottom: -80,
                    left: -60 + (30 * (1 - _bgController.value)),
                    child: _Orb(
                        size: 350,
                        color: AppColors.secondary.withValues(alpha: 0.06)),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.5,
                    right: MediaQuery.of(context).size.width * 0.15,
                    child: _Orb(
                        size: 200,
                        color: AppColors.accent.withValues(alpha: 0.05)),
                  ),
                  // Grid
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

          // ── Main Content ─────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: FadeTransition(
                  opacity: _cardFade,
                  child: SlideTransition(
                    position: _cardSlide,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Back button (if accessible from navigation stack)
                        if (Navigator.canPop(context))
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back,
                                  size: 16, color: AppColors.textLight),
                              label: const Text(
                                "Back",
                                style: TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),

                        // Admin shield icon
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF0A84FF), Color(0xFF00D4FF)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.45),
                                blurRadius: 28,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings,
                            color: Colors.white,
                            size: 44,
                          ),
                        ),
                        const SizedBox(height: 20),

                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColors.cyanGradient.createShader(bounds),
                          blendMode: BlendMode.srcIn,
                          child: const Text(
                            "ADMIN PORTAL",
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
                          "Barangay Safety & Incident Command Center",
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),

                        // ── Glass Card Form ─────────────────────────────────
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                  sigmaX: 16, sigmaY: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 36),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Error alert
                                      if (_errorMessage != null) ...[
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(14),
                                          margin: const EdgeInsets.only(
                                              bottom: 16),
                                          decoration: BoxDecoration(
                                            color: AppColors.danger
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            border: Border.all(
                                              color: AppColors.danger
                                                  .withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.error_outline,
                                                  color: AppColors.danger,
                                                  size: 18),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  _errorMessage!,
                                                  style: const TextStyle(
                                                    color: AppColors.danger,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],

                                      Custom3dTextField(
                                        controller: _emailController,
                                        labelText: "Admin Email",
                                        hintText: "e.g. dispatcher@gmail.com",
                                        prefixIcon: Icons.email_outlined,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (v) {
                                          if (v == null || v.isEmpty) {
                                            return "Email required.";
                                          }
                                          if (!RegExp(
                                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                              .hasMatch(v)) {
                                            return "Enter valid email.";
                                          }
                                          return null;
                                        },
                                      ),

                                      Custom3dTextField(
                                        controller: _passwordController,
                                        labelText: "Admin Password",
                                        hintText: "Enter secure password",
                                        prefixIcon: Icons.lock_outline,
                                        obscureText: _obscurePassword,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: AppColors.textLight,
                                            size: 20,
                                          ),
                                          onPressed: () => setState(() =>
                                              _obscurePassword =
                                                  !_obscurePassword),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.isEmpty) {
                                            return "Password required.";
                                          }
                                          return null;
                                        },
                                      ),

                                      const SizedBox(height: 4),

                                      // Forgot Password trigger
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: _isLoading
                                              ? null
                                              : _showForgotPasswordDialog,
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 2),
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          child: const Text(
                                            "Forgot Password?",
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      Custom3dButton(
                                        text: _isLoading
                                            ? "VERIFYING..."
                                            : "LOGIN TO DASHBOARD",
                                        icon: _isLoading
                                            ? null
                                            : Icons.login_rounded,
                                        gradient: AppColors.primaryGradient,
                                        onPressed: _isLoading
                                            ? null
                                            : _handleLogin,
                                      ),

                                      const SizedBox(height: 20),

                                      // Municipal Security Notice
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0D1627),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFF1E2D4A),
                                          ),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.shield_outlined,
                                              color: Color(0xFF30D158),
                                              size: 16,
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                "Authorized municipal personnel only. All access attempts are recorded.",
                                                style: TextStyle(
                                                  color: AppColors.textLight,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.3,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
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
          ),
        ],
      ),
    );
  }
}

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
  bool shouldRepaint(covariant CustomPainter old) => false;
}
