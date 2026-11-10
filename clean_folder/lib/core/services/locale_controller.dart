import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

/// Holds the resident app's interface language and remembers the choice.
///
/// Works like `AppColors.isDarkModeNotifier`: `MaterialApp` listens to
/// [localeNotifier], so a new language applies to every screen immediately,
/// without restarting the app or signing in again.
class LocaleController {
  const LocaleController._();

  static const String _prefsKey = 'app_locale';

  static const Locale english = Locale('en');
  static const Locale filipino = Locale('fil');

  static final ValueNotifier<Locale> localeNotifier =
      ValueNotifier<Locale>(english);

  static Locale get locale => localeNotifier.value;

  /// Restores the saved language. On first launch, uses Filipino when the
  /// phone itself is set to Filipino, otherwise English.
  static Future<void> load() async {
    Locale initial = resolveDeviceLocale(
      WidgetsBinding.instance.platformDispatcher.locales,
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = _supportedOrNull(prefs.getString(_prefsKey));
      if (saved != null) initial = saved;
    } catch (e) {
      debugPrint("Notice: saved language could not be read: $e");
    }
    localeNotifier.value = initial;
  }

  /// Switches the app language and saves it for the next launch.
  static Future<void> setLocale(Locale locale) async {
    final supported = _supportedOrNull(locale.languageCode) ?? english;
    localeNotifier.value = supported;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, supported.languageCode);
    } catch (e) {
      debugPrint("Notice: language choice could not be saved: $e");
    }
  }

  /// Name shown in the language picker, written in that language itself so
  /// residents can always find their own language.
  static String displayName(Locale locale) {
    return locale.languageCode == filipino.languageCode ? 'Filipino' : 'English';
  }

  /// Only the phone's primary language counts; Tagalog (`tl`) is treated
  /// as Filipino because older Android versions report it that way.
  static Locale resolveDeviceLocale(List<Locale> deviceLocales) {
    if (deviceLocales.isEmpty) return english;
    final code = deviceLocales.first.languageCode;
    return (code == 'fil' || code == 'tl') ? filipino : english;
  }

  static Locale? _supportedOrNull(String? languageCode) {
    for (final supported in AppLocalizations.supportedLocales) {
      if (supported.languageCode == languageCode) return supported;
    }
    return null;
  }
}
