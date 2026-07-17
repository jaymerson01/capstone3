import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_color.dart';
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

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Safe external URI launcher wrapper
  Future<void> _launchAuthUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode
              .externalApplication, // Forces real external system browser redirection
        );
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

  Widget appLogo() {
    return ClipOval(
      child: Image.asset(
        'assets/images/logo.png',
        height: 100,
        width: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.lock, size: 50, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7BBDE8), Color(0xFF001D39)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  appLogo(),
                  const SizedBox(height: 20),
                  const Text(
                    "SIGN IN TO YOUR ACCOUNT",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Enter your email to sign in for this app",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 30),

                  // Retained Existing Login Form Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Email Address",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Email is required.";
                              }
                              final emailRegex = RegExp(r'^[\w-\.]+@gmail\.com$');
                              if (!emailRegex.hasMatch(value.trim().toLowerCase())) {
                                return "Enter a valid Gmail address.";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "e.g. juan@gmail.com",
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: AppColors.textLight,
                                size: 20,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Password",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password is required.";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "e.g. Moonwalk#01",
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: AppColors.textLight,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  color: AppColors.textLight,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Remember Me",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
  
                          // Main Continuation Action Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _isLoading ? null : () async {
                                if (!_formKey.currentState!.validate()) return;
                                
                                setState(() {
                                  _isLoading = true;
                                });
  
                                final email = _emailController.text.trim();
                                final password = _passwordController.text;
  
                                final db = MockDatabaseService();
                                final errorMessage = await db.login(email, password);
  
                                if (!context.mounted) return;
                                
                                setState(() {
                                  _isLoading = false;
                                });
  
                                if (errorMessage == null) {
                                  await showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Success"),
                                      content: const Text("You have successfully logged in!"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("OK", style: TextStyle(color: AppColors.primary)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (context.mounted) {
                                    if (db.currentUser?.role.toLowerCase() == 'admin') {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const AdminPanelShell(),
                                        ),
                                      );
                                    } else {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const DashboardPage(),
                                        ),
                                      );
                                    }
                                  }
                                } else {
                                  if (errorMessage.contains("locked")) {
                                    final expiration = db.getLockoutExpiration(email);
                                    if (expiration != null) {
                                      AuthModals.showAccountLocked(context, expiration);
                                    } else {
                                      AuthModals.showInvalidCredentials(context);
                                    }
                                  } else {
                                    AuthModals.showInvalidCredentials(context);
                                  }
                                }
                              },
                              child: _isLoading 
                                ? const SizedBox(
                                    width: 20, 
                                    height: 20, 
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    "CONTINUE",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Enhanced Divider Block
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white38)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "or continue with",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white38)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Social Authentication Button Layout Matrix
                  socialButton(
                    context,
                    "Continue with Google",
                    Icons.g_mobiledata,
                    "https://accounts.google.com/signin",
                  ),
                  const SizedBox(height: 12),
                  socialButton(
                    context,
                    "Continue with Facebook",
                    Icons.facebook,
                    "https://www.facebook.com/login/",
                  ),
                  const SizedBox(height: 12),
                  socialButton(
                    context,
                    "Continue with Apple",
                    Icons.apple,
                    "https://appleid.apple.com/auth/authorize",
                  ),

                  const SizedBox(height: 24),

                  // Alternate Sign Up Access Gateway
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.white70),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget socialButton(
    BuildContext context,
    String text,
    IconData icon,
    String targetUrl,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textDark,
          elevation: 1,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => _launchAuthUrl(context, targetUrl),
        icon: Icon(icon, size: 24, color: AppColors.textDark),
        label: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }
}
