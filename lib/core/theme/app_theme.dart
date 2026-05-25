import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Boursa Theme — light mode efficace, style mobile.de adapté à l'identité Boursa.
///
/// Typo : Source Sans 3 (sans-serif efficace, lisible).
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnBrand,
      primaryContainer: AppColors.brand100,
      onPrimaryContainer: AppColors.brand900,
      secondary: AppColors.priceColor,
      onSecondary: AppColors.textOnBrand,
      tertiary: AppColors.info,
      onTertiary: AppColors.textOnBrand,
      error: AppColors.error,
      onError: AppColors.textOnBrand,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceMuted,
      outline: AppColors.border,
      outlineVariant: AppColors.borderSubtle,
    );

    final body = GoogleFonts.sourceSans3TextTheme(base.textTheme);

    final textTheme = body.copyWith(
      displayLarge: GoogleFonts.sourceSans3(
        fontSize: 40, fontWeight: FontWeight.w800,
        height: 1.1, letterSpacing: -1.2,
        color: AppColors.textPrimary,
      ),
      displayMedium: GoogleFonts.sourceSans3(
        fontSize: 32, fontWeight: FontWeight.w800,
        height: 1.15, letterSpacing: -0.8,
        color: AppColors.textPrimary,
      ),
      displaySmall: GoogleFonts.sourceSans3(
        fontSize: 26, fontWeight: FontWeight.w700,
        height: 1.2, letterSpacing: -0.4,
        color: AppColors.textPrimary,
      ),
      headlineLarge: GoogleFonts.sourceSans3(
        fontSize: 22, fontWeight: FontWeight.w700,
        height: 1.25, color: AppColors.textPrimary,
      ),
      headlineMedium: GoogleFonts.sourceSans3(
        fontSize: 18, fontWeight: FontWeight.w700,
        height: 1.3, color: AppColors.textPrimary,
      ),
      titleLarge: GoogleFonts.sourceSans3(
        fontSize: 17, fontWeight: FontWeight.w700,
        height: 1.3, color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.sourceSans3(
        fontSize: 15, fontWeight: FontWeight.w600,
        height: 1.35, color: AppColors.textPrimary,
      ),
      titleSmall: GoogleFonts.sourceSans3(
        fontSize: 13, fontWeight: FontWeight.w600,
        height: 1.4, color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.sourceSans3(
        fontSize: 15, fontWeight: FontWeight.w400,
        height: 1.5, color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.sourceSans3(
        fontSize: 14, fontWeight: FontWeight.w400,
        height: 1.5, color: AppColors.textPrimary,
      ),
      bodySmall: GoogleFonts.sourceSans3(
        fontSize: 12, fontWeight: FontWeight.w400,
        height: 1.5, color: AppColors.textSecondary,
      ),
      labelLarge: GoogleFonts.sourceSans3(
        fontSize: 14, fontWeight: FontWeight.w700,
        letterSpacing: 0.2, color: AppColors.textPrimary,
      ),
      labelMedium: GoogleFonts.sourceSans3(
        fontSize: 11, fontWeight: FontWeight.w700,
        letterSpacing: 0.4, color: AppColors.textSecondary,
      ),
      labelSmall: GoogleFonts.sourceSans3(
        fontSize: 10, fontWeight: FontWeight.w700,
        letterSpacing: 0.5, color: AppColors.textMuted,
      ),
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      textTheme: textTheme,
      primaryTextTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.sourceSans3(
          fontSize: 16, fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 22),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        shape: const Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: GoogleFonts.sourceSans3(
          color: AppColors.textMuted, fontSize: 14,
        ),
        labelStyle: GoogleFonts.sourceSans3(
          color: AppColors.textSecondary, fontSize: 13,
        ),
        floatingLabelStyle: GoogleFonts.sourceSans3(
          color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnBrand,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.sourceSans3(
            fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.2,
          ),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.sourceSans3(
            fontSize: 14, fontWeight: FontWeight.w700,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.sourceSans3(
            fontSize: 14, fontWeight: FontWeight.w600,
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.brand100,
        labelStyle: GoogleFonts.sourceSans3(
          color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: GoogleFonts.sourceSans3(
          color: AppColors.brand700, fontWeight: FontWeight.w700,
        ),
        side: const BorderSide(color: AppColors.borderStrong),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        showCheckmark: false,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.sourceSans3(
          color: AppColors.textOnDark, fontSize: 14, fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        modalBackgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.border,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withOpacity(0.15),
        valueIndicatorColor: AppColors.textPrimary,
        valueIndicatorTextStyle: GoogleFonts.sourceSans3(
          color: AppColors.textOnDark, fontSize: 12, fontWeight: FontWeight.w600,
        ),
        trackHeight: 3,
      ),
    );
  }

  /// Compat (le main.dart appelle .light())
  static ThemeData dark() => light();
}
