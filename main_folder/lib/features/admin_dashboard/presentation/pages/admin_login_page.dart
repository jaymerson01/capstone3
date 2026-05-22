import 'package:flutter/material.dart';
import '../constants/admin_colors.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  // Form keys and controller for fields validation
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    setState(() {
      _errorMessage = null;
    });

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate a small delay for premium feels
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;

        final email = _emailController.text.trim();
        final password = _passwordController.text;

        // Verify simulated credentials
        if (email == "admin@safe.gov" && password == "admin123") {
          setState(() {
            _isLoading = false;
          });
          // Redirect to the Admin Dashboard Shell using routing
          Navigator.pushReplacementNamed(context, '/admin/dashboard');
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = "Invalid credentials. Use admin@safe.gov / admin123";
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Container wrapper with shadows for a modern aesthetic
                Container(
                  width: 450,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back to Portal button
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/');
                          },
                          icon: const Icon(Icons.arrow_back, size: 16, color: AdminColors.primaryGreen),
                          label: const Text(
                            "Return to App Welcome",
                            style: TextStyle(color: AdminColors.primaryGreen, fontSize: 13),
                          ),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        ),
                        const SizedBox(height: 20),

                        // Title Header
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: AdminColors.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.admin_panel_settings,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "ADMIN PORTAL",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AdminColors.primaryGreen,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Community Safety Incident Management",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AdminColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 35),

                        // Alert error prompt if any
                        if (_errorMessage != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: AdminColors.dangerRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AdminColors.dangerRed.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AdminColors.dangerRed),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: AdminColors.dangerRed,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Email Field
                        const Text(
                          "Email Address",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Enter admin email (e.g. admin@safe.gov)",
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AdminColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AdminColors.primaryGreen, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your email";
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return "Please enter a valid email format";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Password",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AdminColors.textDark,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Demo Mode: Default password is 'admin123'"),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: AdminColors.primaryGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: "Enter password (e.g. admin123)",
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AdminColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: AdminColors.primaryGreen, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your password";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AdminColors.primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    "LOGIN TO DASHBOARD",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                          ),
                        ),
                      ],
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
}
