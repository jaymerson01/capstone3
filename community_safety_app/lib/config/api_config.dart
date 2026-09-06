import 'package:flutter/foundation.dart';

class ApiConfig {
  // Automatically detects Android Emulator (10.0.2.2) vs Windows / Web / Desktop (localhost)
  static String get baseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api/v1';
    }
    return 'http://localhost:5000/api/v1';
  }

  // Network request timeout duration
  static const Duration timeoutDuration = Duration(seconds: 10);
}
