import 'package:flutter/material.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  Widget appLogo() {
    return Image.asset(
      'assets/images/logo.png',
      height: 85,
      width: 85,
      fit: BoxFit.contain,
    );
  }

  Widget inputBox(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
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
            children: [
              const SizedBox(height: 50),
              appLogo(),
              const SizedBox(height: 20),

              const Text(
                "GET STARTED ON SAFE MOONWALK",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Create an account",
                style: TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 20),

              inputBox("FIRST NAME"),
              const SizedBox(height: 12),
              inputBox("LAST NAME"),

              const SizedBox(height: 20),

              const Text(
                "BIRTHDAY",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(child: inputBox("MONTH")),
                  const SizedBox(width: 8),
                  Expanded(child: inputBox("DAY")),
                  const SizedBox(width: 8),
                  Expanded(child: inputBox("YEAR")),
                ],
              ),

              const SizedBox(height: 20),

              inputBox("EMAIL OR MOBILE NUMBER"),
              const SizedBox(height: 12),
              inputBox("PASSWORD"),

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
                    Navigator.pop(context);
                  },
                  child: const Text("Create"),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}