import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/admin_ui.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';

/// Sign-in for responder accounts (created by a super admin).
class ResponderLoginPage extends StatefulWidget {
  const ResponderLoginPage({super.key, this.initialError});

  final String? initialError;

  @override
  State<ResponderLoginPage> createState() => _ResponderLoginPageState();
}

class _ResponderLoginPageState extends State<ResponderLoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;
  late String? _error = widget.initialError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _signIn() {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = 'Enter your email and password.');
      return;
    }
    setState(() => _error = null);
    context.read<AuthBloc>().add(LoginRequested(_email.text.trim(), _password.text));
  }

  Future<void> _resetPassword() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Type your email first, then tap "Forgot password?".');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) setState(() => _error = 'Check $email for a link to set a new password.');
    } catch (e) {
      if (mounted) setState(() => _error = "Couldn't send the reset email: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) setState(() => _error = state.message);
      },
      child: Scaffold(
        backgroundColor: AdminColors.background,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AdminPanel(
                padding: const EdgeInsets.all(26),
                glow: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 64,
                          height: 64,
                          errorBuilder: (_, _, _) =>
                              const AdminIconTile(icon: Icons.shield_outlined, tone: AdminTone.orange, size: 64),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'RESPONDER PORTAL',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AdminColors.textStrong, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: 1),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Barangay Moonwalk · Tanod, BFP, PNP, Health & Rescue',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AdminColors.textHint, fontSize: 12.5),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      style: adminInputText,
                      decoration: adminInputDecoration(hint: 'Email', icon: Icons.mail_outline),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _password,
                      obscureText: _hidePassword,
                      style: adminInputText,
                      onSubmitted: (_) => _signIn(),
                      decoration: adminInputDecoration(
                        hint: 'Password',
                        icon: Icons.lock_outline,
                        suffix: IconButton(
                          icon: Icon(_hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AdminColors.textHint),
                          onPressed: () => setState(() => _hidePassword = !_hidePassword),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _resetPassword,
                        child: const Text('Forgot password?', style: TextStyle(color: AdminColors.primaryText)),
                      ),
                    ),
                    if (_error != null) ...[
                      Text(_error!, style: const TextStyle(color: AdminColors.dangerText, fontSize: 13, height: 1.4)),
                      const SizedBox(height: 10),
                    ],
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) => AdminButton(
                        label: 'Sign in',
                        icon: Icons.login_rounded,
                        expand: true,
                        busy: state is AuthLoading,
                        onPressed: state is AuthLoading ? null : _signIn,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
