import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tema do Madame Jam (Material 3).
///
/// Tipografia: serifada elegante (Playfair Display) para títulos/display e
/// sans-serif limpa (Nunito Sans) para corpo e rótulos — conforme UX-DR1.
abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.champagne,
      brightness: Brightness.light,
      primary: AppColors.champagneDark,
      onPrimary: AppColors.white,
      secondary: AppColors.champagne,
      surface: AppColors.cream,
      onSurface: AppColors.charcoal,
      error: AppColors.error,
    );

    final baseText = ThemeData.light().textTheme;
    final serif = GoogleFonts.playfairDisplayTextTheme(baseText);
    final sans = GoogleFonts.nunitoSansTextTheme(baseText);

    // Títulos e display em serifada; corpo e rótulos em sans-serif.
    final textTheme = sans.copyWith(
      displayLarge: serif.displayLarge?.copyWith(color: AppColors.charcoal),
      displayMedium: serif.displayMedium?.copyWith(color: AppColors.charcoal),
      displaySmall: serif.displaySmall?.copyWith(color: AppColors.charcoal),
      headlineLarge: serif.headlineLarge?.copyWith(color: AppColors.charcoal),
      headlineMedium: serif.headlineMedium?.copyWith(color: AppColors.charcoal),
      headlineSmall: serif.headlineSmall?.copyWith(color: AppColors.charcoal),
      titleLarge: serif.titleLarge?.copyWith(color: AppColors.charcoal),
    ).apply(
      bodyColor: AppColors.charcoal,
      displayColor: AppColors.charcoal,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.offWhite,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.offWhite,
        foregroundColor: AppColors.charcoal,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.champagneDark,
          foregroundColor: AppColors.white,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.charcoal,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.champagneDark, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
    );
  }
}
