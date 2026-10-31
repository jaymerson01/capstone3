import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:community_safety_app/core/services/locale_controller.dart';
import 'package:community_safety_app/l10n/app_localizations.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LocaleController.localeNotifier.value = LocaleController.english;
  });

  testWidgets('switching the language updates the app without a restart',
      (tester) async {
    // Same wiring as ResQResidentApp in main_resident.dart.
    await tester.pumpWidget(
      ListenableBuilder(
        listenable: LocaleController.localeNotifier,
        builder: (context, child) => MaterialApp(
          locale: LocaleController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) => Text(
              AppLocalizations.of(context).languageSettingTitle,
            ),
          ),
        ),
      ),
    );
    expect(find.text('Language'), findsOneWidget);

    await LocaleController.setLocale(LocaleController.filipino);
    await tester.pumpAndSettle();

    expect(find.text('Wika'), findsOneWidget);
  });

  test('every English string has a Filipino entry', () {
    Set<String> messageKeys(String path) {
      final arb =
          jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
      return arb.keys.where((key) => !key.startsWith('@')).toSet();
    }

    final missing = messageKeys('lib/l10n/app_en.arb')
        .difference(messageKeys('lib/l10n/app_fil.arb'));

    expect(missing, isEmpty, reason: 'Missing in app_fil.arb: $missing');
  });
}
