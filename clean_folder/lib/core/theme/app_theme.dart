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
    const Color edge = Color(0x1AFFFFFF);
    WidgetStateProperty<T> when<T>(T selected, T rest) =>
        WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? selected : rest,
        );
    RoundedRectangleBorder rounded(double radius, {bool edged = false}) =>
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: edged ? const BorderSide(color: edge) : BorderSide.none,
        );

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
      // Defaults for whatever a page doesn't style itself.
      dialogTheme: DialogThemeData(
        backgroundColor: AdminColors.dialogBackground,
        surfaceTintColor: Colors.transparent,
        shape: rounded(24, edged: true),
        titleTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: AdminColors.textStrong,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: AdminColors.textSoft,
          fontSize: 14,
          height: 1.45,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AdminColors.dialogBackground,
        behavior: SnackBarBehavior.floating,
        shape: rounded(14, edged: true),
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: AdminColors.textDark,
          fontWeight: FontWeight.w600,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AdminColors.dialogBackground,
        surfaceTintColor: Colors.transparent,
        shape: rounded(14, edged: true),
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          color: AdminColors.textBody,
          fontSize: 13,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AdminColors.slate,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: edge),
        ),
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          color: AdminColors.textDark,
          fontSize: 12,
        ),
      ),
      cardTheme: CardThemeData(
        color: AdminColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: rounded(22, edged: true),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0x14FFFFFF),
        thickness: 1,
        space: 1,
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: AdminColors.textHint,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
        dataTextStyle: const TextStyle(
          fontFamily: fontFamily,
          color: AdminColors.textBody,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        dividerThickness: 1,
        headingRowColor: WidgetStateProperty.all(Colors.transparent),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: when(Colors.white, AdminColors.textSoft),
        trackColor: when(
          AdminColors.cyan.withValues(alpha: 0.75),
          Colors.white.withValues(alpha: 0.1),
        ),
        trackOutlineColor: when(
          Colors.transparent,
          Colors.white.withValues(alpha: 0.18),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: when(AdminColors.cyan, Colors.transparent),
        checkColor: WidgetStateProperty.all(AdminColors.background),
        side: const BorderSide(color: AdminColors.textHint, width: 1.5),
        shape: rounded(5),
      ),
      radioTheme: RadioThemeData(
        fillColor: when(AdminColors.cyan, AdminColors.textHint),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AdminColors.cyan,
        linearTrackColor: Colors.white.withValues(alpha: 0.1),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AdminColors.cyan,
        selectionColor: AdminColors.cyan.withValues(alpha: 0.3),
        selectionHandleColor: AdminColors.cyan,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AdminColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: rounded(14),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w800,
            fontSize: 13.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AdminColors.textBody,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
          shape: rounded(14),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AdminColors.primaryText,
          shape: rounded(12),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 13.5,
          ),
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          Colors.white.withValues(alpha: 0.18),
        ),
        radius: const Radius.circular(8),
      ),
    );
  }
}
