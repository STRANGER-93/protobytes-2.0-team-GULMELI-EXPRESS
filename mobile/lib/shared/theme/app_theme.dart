import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Nepal flag colors
  static const Color crimson = Color(0xFFDC143C);
  static const Color deepBlue = Color(0xFF003893);
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF8F5F0);
  static const Color darkText = Color(0xFF1A1A2E);
  static const Color grey = Color(0xFF6B7280);
  static const Color lightGrey = Color(0xFFE5E7EB);

  static ThemeData get nepaliTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: crimson,
        primary: crimson,
        secondary: deepBlue,
        surface: white,
        onPrimary: white,
        onSecondary: white,
        onSurface: darkText,
        error: const Color(0xFFB00020),
      ),
      scaffoldBackgroundColor: offWhite,
      textTheme: GoogleFonts.muktaTextTheme().copyWith(
        displayLarge: GoogleFonts.mukta(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: darkText,
        ),
        headlineMedium: GoogleFonts.mukta(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        titleLarge: GoogleFonts.mukta(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        titleMedium: GoogleFonts.mukta(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: darkText,
        ),
        bodyLarge: GoogleFonts.mukta(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: darkText,
        ),
        bodyMedium: GoogleFonts.mukta(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: grey,
        ),
        labelLarge: GoogleFonts.mukta(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: white,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: crimson,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.mukta(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: crimson,
          foregroundColor: white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.mukta(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: crimson,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: crimson, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.mukta(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: deepBlue,
          textStyle: GoogleFonts.mukta(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: crimson, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB00020)),
        ),
        labelStyle: GoogleFonts.mukta(color: grey, fontSize: 16),
        hintStyle: GoogleFonts.mukta(color: grey, fontSize: 14),
        prefixIconColor: deepBlue,
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: deepBlue,
        contentTextStyle: GoogleFonts.mukta(color: white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: crimson,
        unselectedItemColor: grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: const DividerThemeData(color: lightGrey, thickness: 1),
    );
  }
}
