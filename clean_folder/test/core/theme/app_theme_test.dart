import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/app_theme.dart';

void main() {
  tearDown(() => AppColors.isDarkMode = false);

  group('AppTheme.resident', () {
    test('uses the Neo-Tactile palette and Plus Jakarta Sans', () {
      final theme = AppTheme.resident();

      expect(theme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.colorScheme.secondary, AppColors.secondary);
      expect(theme.colorScheme.error, AppColors.danger);
      expect(theme.colorScheme.onSurface, AppColors.ink);
      expect(theme.scaffoldBackgroundColor, AppColors.frost);
      expect(theme.textTheme.bodyMedium?.fontFamily, AppTheme.fontFamily);
      expect(theme.textTheme.labelLarge?.fontFamily, AppTheme.fontFamily);
    });

    test('follows dark mode with the night palette', () {
      AppColors.isDarkMode = true;
      final theme = AppTheme.resident();

      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF0B1428));
      expect(theme.colorScheme.onSurface, const Color(0xFFF1F5F9));
      expect(theme.textTheme.bodyMedium?.fontFamily, AppTheme.fontFamily);
    });

    test('styles snackbars, dialogs, sheets and spinners', () {
      final theme = AppTheme.resident();

      expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
      expect(theme.snackBarTheme.backgroundColor, AppColors.ink);
      expect(theme.dialogTheme.backgroundColor, AppColors.surface);
      expect(theme.bottomSheetTheme.backgroundColor, AppColors.surface);
      expect(theme.progressIndicatorTheme.color, AppColors.secondary);
    });
  });

  test('AppTheme.admin stays dark with the command-center colors', () {
    final theme = AppTheme.admin();

    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, AdminColors.background);
    expect(theme.colorScheme.primary, AdminColors.primaryRose);
    expect(theme.textTheme.bodyMedium?.fontFamily, AppTheme.fontFamily);
  });

  testWidgets('bundles every Plus Jakarta Sans weight', (tester) async {
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
      final font = await rootBundle.load(
        'assets/fonts/PlusJakartaSans/PlusJakartaSans-$weight.ttf',
      );
      expect(font.lengthInBytes, greaterThan(50000), reason: weight);
    }
  });
}
