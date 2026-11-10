import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:community_safety_app/core/services/locale_controller.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    LocaleController.localeNotifier.value = LocaleController.english;
  });

  tearDown(() {
    binding.platformDispatcher.clearLocalesTestValue();
  });

  group('resolveDeviceLocale', () {
    test('uses Filipino when the phone is set to Filipino', () {
      expect(
        LocaleController.resolveDeviceLocale(const [Locale('fil', 'PH')]),
        LocaleController.filipino,
      );
    });

    test('treats Tagalog (tl) as Filipino', () {
      expect(
        LocaleController.resolveDeviceLocale(const [Locale('tl')]),
        LocaleController.filipino,
      );
    });

    test('uses English for English and any other language', () {
      expect(
        LocaleController.resolveDeviceLocale(const [Locale('en', 'US')]),
        LocaleController.english,
      );
      expect(
        LocaleController.resolveDeviceLocale(const [Locale('ja')]),
        LocaleController.english,
      );
    });

    test('only looks at the primary phone language', () {
      expect(
        LocaleController.resolveDeviceLocale(const [Locale('en'), Locale('fil')]),
        LocaleController.english,
      );
    });

    test('uses English when the phone reports no language', () {
      expect(
        LocaleController.resolveDeviceLocale(const []),
        LocaleController.english,
      );
    });
  });

  group('load', () {
    test('restores the saved choice over the phone language', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'fil'});
      binding.platformDispatcher.localesTestValue = const [Locale('en', 'US')];

      await LocaleController.load();

      expect(LocaleController.locale, LocaleController.filipino);
    });

    test('follows the phone language when nothing is saved', () async {
      SharedPreferences.setMockInitialValues({});
      binding.platformDispatcher.localesTestValue = const [Locale('fil', 'PH')];

      await LocaleController.load();

      expect(LocaleController.locale, LocaleController.filipino);
    });

    test('ignores a saved language the app does not support', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'es'});
      binding.platformDispatcher.localesTestValue = const [Locale('en', 'US')];

      await LocaleController.load();

      expect(LocaleController.locale, LocaleController.english);
    });
  });

  group('setLocale', () {
    test('switches the language and saves it for the next launch', () async {
      SharedPreferences.setMockInitialValues({});

      await LocaleController.setLocale(LocaleController.filipino);

      expect(LocaleController.locale, LocaleController.filipino);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), 'fil');
    });

    test('falls back to English for an unsupported language', () async {
      SharedPreferences.setMockInitialValues({});

      await LocaleController.setLocale(const Locale('es'));

      expect(LocaleController.locale, LocaleController.english);
    });
  });
}
