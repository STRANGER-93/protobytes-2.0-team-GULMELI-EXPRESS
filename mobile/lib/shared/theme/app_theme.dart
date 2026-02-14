import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core Brand — Saffron (matching frontend)
  static const Color saffron = Color(0xFFE8810A);
  static const Color saffronDark = Color(0xFFC46D07);
  static const Color saffronLight = Color(0xFFF5A03A);
  static const Color saffronPale = Color(0xFFFDF3E7);

  // Slate Civic (matching frontend)
  static const Color slate900 = Color(0xFF0F1923);
  static const Color slate800 = Color(0xFF1A2635);
  static const Color slate700 = Color(0xFF243447);
  static const Color slate600 = Color(0xFF3A5068);
  static const Color slate500 = Color(0xFF5B7A96);
  static const Color slate400 = Color(0xFF8AA5BD);
  static const Color slate300 = Color(0xFFB8CCDB);
  static const Color slate200 = Color(0xFFDDE8F0);
  static const Color slate100 = Color(0xFFF0F5F9);
  static const Color slate50 = Color(0xFFF8FAFC);

  // Legacy aliases for compatibility
  static const Color crimson = saffron;
  static const Color deepBlue = slate700;
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = slate50;
  static const Color darkText = slate900;
  static const Color grey = slate500;
  static const Color lightGrey = slate200;

  // Semantic Colors (matching frontend)
  static const Color success = Color(0xFF1A9E5C);
  static const Color successLight = Color(0xFFE6F7EF);
  static const Color danger = Color(0xFFD63939);
  static const Color dangerLight = Color(0xFFFDEAEA);
  static const Color warning = Color(0xFFD4890A);
  static const Color warningLight = Color(0xFFFEF3E0);
  static const Color info = Color(0xFF1A6EB5);
  static const Color infoLight = Color(0xFFE6F0FA);

  static ThemeData get nepaliTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: saffron,
        primary: saffron,
        secondary: slate700,
        surface: white,
        onPrimary: white,
        onSecondary: white,
        onSurface: slate900,
        error: danger,
        tertiary: success,
      ),
      scaffoldBackgroundColor: slate50,
      textTheme: GoogleFonts.soraTextTheme().copyWith(
        displayLarge: GoogleFonts.sora(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: slate900,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.sora(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: slate900,
          letterSpacing: -0.3,
        ),
        titleLarge: GoogleFonts.sora(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: slate900,
        ),
        titleMedium: GoogleFonts.sora(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: slate900,
        ),
        bodyLarge: GoogleFonts.sora(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: slate900,
        ),
        bodyMedium: GoogleFonts.sora(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: slate600,
        ),
        labelLarge: GoogleFonts.sora(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: white,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: saffron,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.sora(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: saffron,
          foregroundColor: white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.sora(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
          shadowColor: saffron.withValues(alpha: 0.25),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: slate700,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: slate300, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.sora(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: saffron,
          textStyle: GoogleFonts.sora(
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
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: slate200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: slate200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: saffron, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: danger),
        ),
        labelStyle: GoogleFonts.sora(color: slate700, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.3),
        hintStyle: GoogleFonts.sora(color: slate500, fontSize: 14),
        prefixIconColor: slate600,
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: slate200),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: slate800,
        contentTextStyle: GoogleFonts.sora(color: white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: saffron,
        unselectedItemColor: slate500,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(color: slate200, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: slate100,
        selectedColor: saffronPale,
        labelStyle: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
