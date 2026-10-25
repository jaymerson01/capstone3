import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/core/theme/app_colors.dart';
import 'package:community_safety_app/core/theme/neo_tokens.dart';

/// RESQ ThemeData for both apps, built from the Neo-Tactile tokens.
/// Material controls (text fields, switches, dialogs, sheets, snackbars,
/// spinners) pick these up, so screens get the new look without changes.
class AppTheme {
  /// Bundled in pubspec.yaml (assets/fonts/PlusJakartaSans).
  static const String fontFamily = 'PlusJakartaSans';

  /// Resident app theme for the current `AppColors.isDarkMode`. Build it
  /// again when the mode changes (main_resident.dart listens for that).
  static ThemeData resident() {
    final isDark = AppColors.isDarkMode;
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.ink,
      error: AppColors.danger,
      onError: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textDark,
      onSurfaceVariant: AppColors.textLight,
      outline: AppColors.border,
      outlineVariant: AppColors.surfaceLight,
      surfaceTint: Colors.transparent,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      // Only the fallback border: fields that set their own borders keep them.
      inputDecorationTheme: InputDecorationThemeData(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NeoRadii.field),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? AppColors.primary
              : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1));
          return states.contains(WidgetState.disabled)
              ? color.withValues(alpha: 0.5)
              : color;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoRadii.panel),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: AppColors.border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(NeoRadii.panel),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF1E293B) : AppColors.ink,
        actionTextColor: AppColors.secondary,
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeoRadii.field),
        ),
      ),
      // Live cyan, as in the "Gemini AI is analyzing..." loading ring.
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.secondary,
        circularTrackColor: AppColors.secondary.withValues(alpha: 0.2),
        linearTrackColor: AppColors.secondary.withValues(alpha: 0.2),
      ),
    );
  }

  /// Admin portal theme (dark command center).
  static ThemeData admin() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AdminColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AdminColors.primaryRose,
        secondary: AdminColors.secondaryGreen,
        surface: AdminColors.surfaceLight,
      ),
      fontFamily: fontFamily,
      useMaterial3: true,
    );
  }
}
