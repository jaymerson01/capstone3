import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers whether this phone or browser has seen the "How to use ResQ"
/// guide, so it opens by itself the first time the resident app opens
/// (right after installing the app, or on a first visit to the website).
class FirstRunGuide {
  const FirstRunGuide._();

  static const String _prefsKey = 'first_run_guide_seen';

  static bool _pending = false;

  /// Whether the guide still has to be shown on this device.
  static bool get pending => _pending;

  /// Reads the saved flag. If it can't be read, the guide stays closed rather
  /// than opening on every launch.
  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _pending = !(prefs.getBool(_prefsKey) ?? false);
    } catch (e) {
      debugPrint("Notice: first-run guide flag could not be read: $e");
      _pending = false;
    }
  }

  /// The guide has been watched or skipped: don't open it by itself again.
  static Future<void> markSeen() async {
    _pending = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, true);
    } catch (e) {
      debugPrint("Notice: first-run guide flag could not be saved: $e");
    }
  }
}
