import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/map_styles.dart';

void main() {
  tearDown(() => AppColors.isDarkMode = false);

  test('both map styles are valid Google Maps style JSON', () {
    for (final style in [MapStyles.light, MapStyles.dark]) {
      final rules = jsonDecode(style) as List<dynamic>;
      expect(rules, isNotEmpty);
      for (final rule in rules.cast<Map<String, dynamic>>()) {
        expect(rule['stylers'], isA<List<dynamic>>());
      }
    }
  });

  test('the current style follows dark mode', () {
    expect(MapStyles.current, MapStyles.light);
    AppColors.isDarkMode = true;
    expect(MapStyles.current, MapStyles.dark);
  });
}
