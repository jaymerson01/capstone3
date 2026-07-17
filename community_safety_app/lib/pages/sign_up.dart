import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_color.dart';

import '../services/mock_database_service.dart';
import 'dashboard.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _termsAccepted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _launchAuthUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw "Could not redirect to registration provider screen.";
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
                  const Text(
                    "CREATE NEW ACCOUNT",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Sign up with your credentials or social identity profile",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 30),

                  // Traditional Sign Up Fields Container
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Full Name",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Name is required.";
                              }
                              final nameRegex = RegExp(r'^[a-zA-Z\s\-]{2,50}$');
                              if (!nameRegex.hasMatch(value.trim())) {
                                return "Letters, spaces, and hyphens only (2-50 chars).";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "Enter your full name",
                              prefixIcon: const Icon(
                                Icons.person_outline,
                                color: AppColors.textLight,
                                size: 20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
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
                              if (value.contains(' ')) {
                                return "Password cannot contain spaces.";
                              }
                              if (value == _emailController.text.trim()) {
                                return "Password cannot be identical to email.";
                              }
                              final commonPasswords = ['password123', 'admin123', '12345678', 'qwerty123', 'password', 'abcdefgh'];
                              if (commonPasswords.contains(value.toLowerCase())) {
                                return "Password is too common or sequential.";
                              }
                              final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[_\-@#\$%&!?*.]).{8,20}$');
                              if (!passwordRegex.hasMatch(value)) {
                                return "8-20 chars, 1 upper, 1 lower, 1 num, 1 special.";
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Confirm Password",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please confirm your password.";
                              }
                              if (value != _passwordController.text) {
                                return "Passwords do not match.";
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
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
                                  value: _termsAccepted,
                                  onChanged: (value) {
                                    setState(() {
                                      _termsAccepted = value ?? false;
                                    });
                                  },
                                  activeColor: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  "I accept the Terms and Conditions",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: (!_termsAccepted || _isLoading) ? null : () async {
                                if (!_formKey.currentState!.validate()) return;
                                
                                setState(() {
                                  _isLoading = true;
                                });
  
                                final name = _nameController.text.trim();
                                final email = _emailController.text.trim();
                                final password = _passwordController.text;
  
                                final errorMessage = await MockDatabaseService().signUp(name, email, password, "Reporter");
                                
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
                                      content: const Text("You have successfully registered! Please log in to continue."),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("OK", style: TextStyle(color: AppColors.primary)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (context.mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const LoginPage()),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
                                  );
                                }
                              },
                              child: _isLoading 
                                ? const SizedBox(
                                    width: 20, 
                                    height: 20, 
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    "REGISTER",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Modern Aesthetic Divider Text Block
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

                  // Reusable Redirect Action Elements
                  socialButton(
                    context,
                    "Continue with Google",
                    Icons.g_mobiledata,
                    "https://accounts.google.com/v3/signin/identifier",
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

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Already have an account? Sign In",
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
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
