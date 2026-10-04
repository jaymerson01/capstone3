import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';

/// Reusable helper for dialing emergency hotlines with direct calling and fallback support.
class DirectCallerHelper {
  DirectCallerHelper._();

  static bool _isCalling = false;
  static DateTime? _lastCallTime;

  /// Initiates an emergency call.
  /// On Android, attempts native direct calling via [FlutterPhoneDirectCaller].
  /// Guarded against rapid re-entry, concurrent permission requests, and race conditions.
  static Future<void> makeDirectCall(
    BuildContext context,
    String number, {
    String? label,
  }) async {
    final now = DateTime.now();
    if (_isCalling ||
        (_lastCallTime != null &&
            now.difference(_lastCallTime!) < const Duration(milliseconds: 1500))) {
      debugPrint('[DirectCallerHelper] Call in progress or debounced, ignoring tap.');
      return;
    }

    _isCalling = true;
    _lastCallTime = now;

    try {
      final cleanNumber = number.replaceAll(RegExp(r'[^0-9+]'), '');
      debugPrint('[DirectCallerHelper] Calling $cleanNumber ($label)');

      try {
        final bool? directCallSuccess =
            await FlutterPhoneDirectCaller.callNumber(cleanNumber);
        if (directCallSuccess == true) {
          return;
        }
      } catch (e) {
        debugPrint('[DirectCallerHelper] Direct call error: $e');
      }

      // Fallback to url_launcher dialer
      final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);
      try {
        final launched = await launchUrl(
          phoneUri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched && context.mounted) {
          _showDialerError(context, number);
        }
      } catch (_) {
        if (context.mounted) {
          _showDialerError(context, number);
        }
      }
    } finally {
      // Delay releasing the lock to allow Android activity transition and permission dialogs to settle
      Future.delayed(const Duration(milliseconds: 1500), () {
        _isCalling = false;
      });
    }
  }

  static void _showDialerError(BuildContext context, String number) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Could not open dialer for $number. Please dial manually.'),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
