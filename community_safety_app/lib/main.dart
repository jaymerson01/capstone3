import 'package:flutter/material.dart';
import 'pages/dashboard.dart';

void main() {
  runApp(const CommunitySafetyApp());
}

class CommunitySafetyApp extends StatelessWidget {
  const CommunitySafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardPage(),
    );
  }
}