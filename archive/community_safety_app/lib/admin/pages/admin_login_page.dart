import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_color.dart';
import '../../widgets/custom_3d_button.dart';
import '../../widgets/custom_3d_text_field.dart';
import '../../services/mock_database_service.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

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
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
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

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final err = await MockDatabaseService().login(email, password);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (err == null) {
      if (MockDatabaseService().currentUser?.role.toLowerCase() == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin/dashboard');
      } else {
        MockDatabaseService().logout();
        setState(() {
          _errorMessage = "Access denied. Admin portal only.";
        });
      }
    } else {
      setState(() {
        _errorMessage = err;
      });
    }
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
                        // Back button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () =>
                                Navigator.pushReplacementNamed(context, '/'),
                            icon: const Icon(Icons.arrow_back,
                                size: 16, color: AppColors.textLight),
                            label: const Text(
                              "Return to App Welcome",
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
                                        hintText: "e.g. admin@safe.gov",
                                        prefixIcon: Icons.email_outlined,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (v) {
                                          if (v == null || v.isEmpty)
                                            return "Email required.";
                                          if (!RegExp(
                                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                              .hasMatch(v))
                                            return "Enter valid email.";
                                          return null;
                                        },
                                      ),

                                      Custom3dTextField(
                                        controller: _passwordController,
                                        labelText: "Admin Password",
                                        hintText: "e.g. admin123",
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
                                          if (v == null || v.isEmpty)
                                            return "Password required.";
                                          return null;
                                        },
                                      ),

                                      const SizedBox(height: 8),

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

                                      // Credentials hint
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.08),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.15)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                                Icons.info_outline,
                                                color: AppColors.primary,
                                                size: 15),
                                            const SizedBox(width: 8),
                                            const Expanded(
                                              child: Text(
                                                "Demo: admin@safe.gov · admin123",
                                                style: TextStyle(
                                                  color: AppColors.textLight,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
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
