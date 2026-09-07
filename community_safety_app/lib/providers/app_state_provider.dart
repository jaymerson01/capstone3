import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/app_translations.dart';
import '../services/mock_database_service.dart';

class AppStateProvider extends ChangeNotifier {
  static final AppStateProvider _instance = AppStateProvider._internal();
  factory AppStateProvider() => _instance;
  AppStateProvider._internal() {
    _loadState();
  }

  String _language = 'en';
  ThemeMode _themeMode = ThemeMode.dark;

  String get language => _language;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void _loadState() {
    if (Hive.isBoxOpen('auth')) {
      final box = Hive.box('auth');
      _language = box.get('language', defaultValue: 'en');
      final String themeStr = box.get('theme', defaultValue: 'dark');
      _themeMode = themeStr == 'light' ? ThemeMode.light : ThemeMode.dark;
    }
    AppTranslations.currentLanguage = _language;
  }

  Future<void> setLanguage(String lang) async {
    if (lang != 'en' && lang != 'fil') return;
    _language = lang;
    AppTranslations.currentLanguage = lang;

    if (Hive.isBoxOpen('auth')) {
      await Hive.box('auth').put('language', lang);
    }

    // Sync to backend if user is logged in
    MockDatabaseService().updateUserSettings(language: lang);

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final String themeStr = mode == ThemeMode.light ? 'light' : 'dark';

    if (Hive.isBoxOpen('auth')) {
      await Hive.box('auth').put('theme', themeStr);
    }

    // Sync to backend if user is logged in
    MockDatabaseService().updateUserSettings(theme: themeStr);

    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  void syncWithUserPreferences() {
    final user = MockDatabaseService().currentUser;
    if (user != null) {
      if (user.language.isNotEmpty && user.language != _language) {
        _language = user.language;
        AppTranslations.currentLanguage = _language;
      }
      final userThemeMode = user.theme == 'light' ? ThemeMode.light : ThemeMode.dark;
      if (userThemeMode != _themeMode) {
        _themeMode = userThemeMode;
      }
      notifyListeners();
    }
  }
}
