import 'package:flutter/material.dart';
import 'pages/welcome_page.dart';

void main() {
  runApp(const CommunitySafetyApp());
}

class CommunitySafetyApp extends StatelessWidget {
  const CommunitySafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomePage(),
    );
  }
}