import 'package:flutter/material.dart';
import 'dashboard.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  Widget appLogo() {
    return Image.asset(
      'assets/images/logo.png',
      height: 90,
      width: 90,
      fit: BoxFit.contain,
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
            colors: [
              Color(0xFF004D00),
              Color(0xFF9EA89E),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            appLogo(),

            const SizedBox(height: 25),

            const Text(
              "SIGN IN YOUR ACCOUNT",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "Enter your email to sign in for this app",
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),

            const SizedBox(height: 25),

            TextField(
              decoration: InputDecoration(
                hintText: "Email or mobile number",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Password",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardPage(),
                    ),
                  );
                },
                child: const Text("CONTINUE"),
              ),
            ),

            const SizedBox(height: 20),

            const Row(
              children: [
                Expanded(child: Divider(color: Colors.white)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text("or", style: TextStyle(color: Colors.white)),
                ),
                Expanded(child: Divider(color: Colors.white)),
              ],
            ),

            const SizedBox(height: 20),

            googleButton("Continue with Google"),
            const SizedBox(height: 10),
            googleButton("Continue with Apple"),
          ],
        ),
      ),
    );
  }

  Widget googleButton(String text) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        onPressed: () {},
        child: Text(text),
      ),
    );
  }
}