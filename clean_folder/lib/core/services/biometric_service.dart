import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck || isSupported;
    } catch (_) {
      return false;
    }
  }

  /// Anti-Prank submission verification
  /// Returns true if authentication succeeded or if hardware is unavailable.
  /// Falls back to device passcode / PIN (biometricOnly: false) if fingers are wet/dirty.
  Future<bool> verifySubmission({
    String reason =
        'Verify your biometric identity to submit official emergency report',
  }) async {
    try {
      final available = await isBiometricAvailable();
      if (!available) {
        // Device has no biometric hardware or user has not enrolled biometrics.
        // Allow submission so citizens are not blocked from emergency reporting.
        return true;
      }

      final didAuth = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // Allows device PIN/Passcode fallback
          stickyAuth: true,
        ),
      );
      return didAuth;
    } catch (e) {
      debugPrint("Biometric verification error or cancelled: $e");
      // If hardware error, allow report submission
      return true;
    }
  }

  /// Checks if the citizen has already been asked for first-time biometric enrollment
  Future<bool> hasPromptedFirstTimeEnrollment() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_prompted_first_time') ?? false;
  }

  Future<void> markFirstTimeEnrollmentPrompted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_prompted_first_time', true);
  }

  Future<bool> isBiometricLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_lock_enabled') ?? false;
  }

  Future<void> setBiometricLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_lock_enabled', enabled);
  }
}
