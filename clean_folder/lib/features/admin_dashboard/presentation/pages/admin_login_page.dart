import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/core/presentation/neo/landscape_backdrop.dart';
import 'package:community_safety_app/core/presentation/neo/outer_shadow.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:community_safety_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/admin_ui.dart';

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
        builder: (dialogStateContext, setDialogState) => AdminDialog(
          title: "Reset Admin Password",
          icon: Icons.lock_reset_rounded,
          maxWidth: 460,
          actions: [
            AdminButton(
              label: "Cancel",
              style: AdminButtonStyle.ghost,
              onPressed: isSending ? null : () => Navigator.pop(dialogCtx),
            ),
            AdminButton(
              label: "Send Reset Link",
              busy: isSending,
              onPressed: isSending
                  ? null
                  : () async {
                      final email = resetEmailController.text.trim();
                      if (email.isEmpty || !email.contains('@')) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                                "Please enter a valid registered email address."),
                            backgroundColor: AdminColors.amber,
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
                            backgroundColor: AdminColors.success,
                            duration: const Duration(seconds: 6),
                          ),
                        );
                      } catch (e) {
                        setDialogState(() => isSending = false);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text("Failed to send reset link: $e"),
                            backgroundColor: AdminColors.danger,
                          ),
                        );
                      }
                    },
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter your registered municipal admin email address. We will dispatch a secure Google password reset link directly to your inbox.",
                style: TextStyle(
                  color: AdminColors.textSoft,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              const AdminFieldLabel("Admin Email"),
              TextField(
                controller: resetEmailController,
                keyboardType: TextInputType.emailAddress,
                style: adminInputText,
                cursorColor: AdminColors.cyan,
                decoration: adminInputDecoration(
                  hint: "admin@example.com",
                  icon: Icons.email_outlined,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool narrow = MediaQuery.of(context).size.width < 420;

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: Stack(
        children: [
          // ── Animated Background ──────────────────────────────────────────
          // The night landscape, with slow ambient glows drifting over it.
          const Positioned.fill(
            child: RepaintBoundary(
              child: LandscapeBackdrop(time: LandscapeTime.night),
            ),
          ),
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _bgController,
                builder: (context, _) {
                  return Stack(
                    children: [
                      // Ambient orbs
                      Positioned(
                        top: -60 + (50 * _bgController.value),
                        right: -40,
                        child: _Orb(
                            size: 300,
                            color: AdminColors.primary.withValues(alpha: 0.12)),
                      ),
                      Positioned(
                        bottom: -80,
                        left: -60 + (30 * (1 - _bgController.value)),
                        child: _Orb(
                            size: 350,
                            color: AdminColors.cyan.withValues(alpha: 0.06)),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height * 0.5,
                        right: MediaQuery.of(context).size.width * 0.15,
                        child: _Orb(
                            size: 200,
                            color: AdminColors.cyanText.withValues(alpha: 0.06)),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // ── Main Content ─────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: FadeTransition(
                  opacity: _cardFade,
                  child: SlideTransition(
                    position: _cardSlide,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Back button (if accessible from navigation stack)
                          if (Navigator.canPop(context))
                            Align(
                              alignment: Alignment.centerLeft,
                              child: AdminButton(
                                label: "Back",
                                icon: Icons.arrow_back,
                                style: AdminButtonStyle.ghost,
                                height: 38,
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          const SizedBox(height: 24),

                          // Admin logo tile
                          const _LogoTile(),
                          const SizedBox(height: 22),

                          // ── Glass Card Form ─────────────────────────────────
                          OuterShadow(
                            borderRadius: BorderRadius.circular(30),
                            shadows: [
                              BoxShadow(
                                color: AdminColors.cyan.withValues(alpha: 0.18),
                                spreadRadius: 1,
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.45),
                                blurRadius: 70,
                                offset: const Offset(0, 30),
                              ),
                            ],
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AdminColors.surfaceDeep
                                            .withValues(alpha: 0.8),
                                        AdminColors.surfaceDeep
                                            .withValues(alpha: 0.88),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.4),
                                      width: 1.5,
                                    ),
                                  ),
                                  padding: narrow
                                      ? const EdgeInsets.fromLTRB(22, 28, 22, 24)
                                      : const EdgeInsets.fromLTRB(30, 34, 30, 30),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "ADMIN PORTAL",
                                          style: TextStyle(
                                            color: AdminColors.textStrong,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 28,
                                            letterSpacing: 1.5,
                                            height: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        const Text(
                                          "Barangay Safety & Incident Command Center",
                                          style: TextStyle(
                                            color: AdminColors.textBody,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 22),

                                        // Error alert
                                        if (_errorMessage != null) ...[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 16),
                                            child: AdminInset(
                                              tone: AdminTone.red,
                                              radius: 14,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Icon(Icons.error_outline,
                                                      color: AdminColors.dangerSoft,
                                                      size: 18),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      _errorMessage!,
                                                      style: const TextStyle(
                                                        color: AdminColors.dangerText,
                                                        fontSize: 12.5,
                                                        fontWeight: FontWeight.w600,
                                                        height: 1.4,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],

                                        const AdminFieldLabel("Admin Email"),
                                        TextFormField(
                                          controller: _emailController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          style: adminInputText,
                                          cursorColor: AdminColors.cyan,
                                          decoration: _glassInputDecoration(
                                            hint: "e.g. dispatcher@gmail.com",
                                            icon: Icons.email_outlined,
                                          ),
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
                                        const SizedBox(height: 16),

                                        const AdminFieldLabel("Admin Password"),
                                        TextFormField(
                                          controller: _passwordController,
                                          obscureText: _obscurePassword,
                                          style: adminInputText,
                                          cursorColor: AdminColors.cyan,
                                          decoration: _glassInputDecoration(
                                            hint: "Enter secure password",
                                            icon: Icons.lock_outline,
                                            suffix: IconButton(
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                                color: AdminColors.textSoft,
                                                size: 20,
                                              ),
                                              onPressed: () => setState(() =>
                                                  _obscurePassword =
                                                      !_obscurePassword),
                                            ),
                                          ),
                                          validator: (v) {
                                            if (v == null || v.isEmpty) {
                                              return "Password required.";
                                            }
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 8),

                                        // Forgot Password trigger
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: _isLoading
                                                ? null
                                                : _showForgotPasswordDialog,
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  AdminColors.cyanText,
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 4, vertical: 2),
                                              visualDensity: VisualDensity.compact,
                                            ),
                                            child: const Text(
                                              "Forgot Password?",
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 12),

                                        AdminButton(
                                          label: _isLoading
                                              ? "VERIFYING..."
                                              : "LOGIN TO DASHBOARD",
                                          icon: _isLoading
                                              ? null
                                              : Icons.login_rounded,
                                          busy: _isLoading,
                                          height: 56,
                                          expand: true,
                                          debounce: true,
                                          onPressed: _isLoading
                                              ? null
                                              : _handleLogin,
                                        ),

                                        const SizedBox(height: 20),

                                        // Municipal Security Notice
                                        const AdminInset(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 12),
                                          radius: 14,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.shield_outlined,
                                                color: AdminColors.success,
                                                size: 18,
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  "Authorized municipal personnel only. All access attempts are recorded.",
                                                  style: TextStyle(
                                                    color: AdminColors.textBody,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.45,
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
                        ],
                      ),
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

/// The round app logo above the sign-in card. Falls back to the
/// admin shield if the image can't load.
class _LogoTile extends StatelessWidget {
  const _LogoTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const DecoratedBox(
            decoration: BoxDecoration(gradient: AdminColors.primaryGradient),
            child: Center(
              child: Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The sign-in fields: clear glass with a white edge, so they read on the
/// smoked card over the night landscape (the admin input well, lightened).
InputDecoration _glassInputDecoration({
  required String hint,
  required IconData icon,
  Widget? suffix,
}) {
  OutlineInputBorder edge(Color color, [double width = 1.5]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  final Color rest = Colors.white.withValues(alpha: 0.5);

  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      color: AdminColors.textHint,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    prefixIcon: Icon(icon, size: 20, color: AdminColors.textSoft),
    suffixIcon: suffix,
    errorStyle: const TextStyle(
      color: AdminColors.dangerText,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.07),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    border: edge(rest),
    enabledBorder: edge(rest),
    focusedBorder: edge(AdminColors.cyan, 2),
    errorBorder: edge(AdminColors.dangerSoft),
    focusedErrorBorder: edge(AdminColors.dangerSoft, 2),
  );
}
