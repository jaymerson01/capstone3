import 'package:flutter/material.dart';
import 'login_page.dart';
import 'sign_up.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

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
            colors: [Color(0xFF004D00), Color(0xFF9EA89E)],
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            appLogo(),

            const SizedBox(height: 35),

            const Text(
              "SAFE MOONWALK",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Your safety is our priority",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),

            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
              ),

              child: const Center(
                child: Text(
                  "Moonwalk, Parañaque City",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 45,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },

                child: const Text("Login"),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 45,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage()),
                  );
                },

                child: const Text("Create an Account"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
