import 'package:flutter/material.dart';
import 'emergency_hotlines_page.dart';
import 'login_page.dart';
import 'sign_up.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  Widget appLogo() {
    return Image.asset(
      'assets/images/logo.png',
      height: 100,
      width: 100,
      fit: BoxFit.contain,
    );
  }

  void _showLoginRequired(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text(
          'Please login or create an account first before reporting an incident.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Widget _topButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _mainButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF7BBDE8), Color(0xFF001D39)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _topButton(
                    text: 'Login',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                  ),
                  _topButton(
                    text: 'Sign Up',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpPage()),
                      );
                    },
                  ),
                ],
              ),

              const Spacer(),

              appLogo(),
              const SizedBox(height: 35),

              const Text(
                'RESQ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Your safety is our priority',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),

              const SizedBox(height: 35),

              _mainButton(
                icon: Icons.warning_amber,
                text: 'Report an Incident',
                onPressed: () => _showLoginRequired(context),
              ),

              const SizedBox(height: 15),

              _mainButton(
                icon: Icons.call,
                text: 'Emergency Hotlines',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmergencyHotlinesPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/admin/login');
                },
                child: const Text(
                  'Access Admin Portal',
                  style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}