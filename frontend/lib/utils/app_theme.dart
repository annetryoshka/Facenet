import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
        shadowColor: AppColors.outline.withOpacity(0.3),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.libreBaskerville(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 1,
        shadowColor: AppColors.outline.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: AppColors.outline,
            width: 1,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: AppColors.outline, width: 1.5),
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.ibmPlexSans(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.ibmPlexSans(
          color: AppColors.textTertiary,
          fontSize: 14,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.libreBaskerville(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
        displayMedium: GoogleFonts.libreBaskerville(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 0.3,
        ),
        displaySmall: GoogleFonts.libreBaskerville(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 0.2,
        ),
        headlineLarge: GoogleFonts.libreBaskerville(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.libreBaskerville(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.ibmPlexSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.1,
        ),
        titleLarge: GoogleFonts.ibmPlexSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.1,
        ),
        titleMedium: GoogleFonts.ibmPlexSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleSmall: GoogleFonts.ibmPlexSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        bodyLarge: GoogleFonts.ibmPlexSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.ibmPlexSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.ibmPlexSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textTertiary,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.ibmPlexSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.ibmPlexSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          letterSpacing: 0.1,
        ),
        labelSmall: GoogleFonts.ibmPlexSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textTertiary,
          letterSpacing: 0.1,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurface,
        contentTextStyle: GoogleFonts.ibmPlexSans(
          color: AppColors.textOnPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 4,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerColor,
        thickness: 1,
        space: 16,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accentLight,
        surface: AppColors.darkSurface,
        background: AppColors.darkBackground,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.libreBaskerville(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textOnPrimary,
          letterSpacing: 0.5,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.libreBaskerville(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: AppColors.textOnPrimary,
          letterSpacing: 0.5,
        ),
        bodyLarge: GoogleFonts.ibmPlexSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textOnPrimary,
        ),
      ),
    );
  }
}