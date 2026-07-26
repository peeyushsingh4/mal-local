import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BlinkitTheme {
  static const Color blinkitYellow = Color(0xFFF7C413);
  static const Color blinkitGreen = Color(0xFF0C831F);
  static const Color blinkitGreenLight = Color(0xFFE8F7EE);
  static const Color swiggyOrange = Color(0xFFFC8019);
  static const Color zomatoRed = Color(0xFFE23744);
  static const Color darkBg = Color(0xFF0B0F17);
  static const Color darkCardBg = Color(0xFF121826);
  static const Color darkElevated = Color(0xFF1A2234);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: blinkitYellow,
      colorScheme: const ColorScheme.dark(
        primary: blinkitYellow,
        onPrimary: Color(0xFF0F172A),
        secondary: blinkitGreen,
        onSecondary: Colors.white,
        surface: darkCardBg,
        onSurface: Color(0xFFF8FAFC),
        error: zomatoRed,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        headlineLarge: GoogleFonts.sora(fontWeight: FontWeight.w800, color: Colors.white),
        headlineMedium: GoogleFonts.sora(fontWeight: FontWeight.w800, color: Colors.white),
        titleLarge: GoogleFonts.sora(fontWeight: FontWeight.w800, color: Colors.white),
        titleMedium: GoogleFonts.sora(fontWeight: FontWeight.w700, color: Colors.white),
        bodyLarge: GoogleFonts.inter(color: const Color(0xFFF8FAFC)),
        bodyMedium: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: darkCardBg,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF1E293B)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: blinkitYellow,
        foregroundColor: Color(0xFF0C831F),
        elevation: 6,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF4F6FB),
      primaryColor: blinkitGreen,
      colorScheme: const ColorScheme.light(
        primary: blinkitGreen,
        onPrimary: Colors.white,
        secondary: blinkitYellow,
        onSecondary: Color(0xFF0F172A),
        surface: Colors.white,
        onSurface: Color(0xFF0F172A),
        error: zomatoRed,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        headlineLarge: GoogleFonts.sora(fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
        headlineMedium: GoogleFonts.sora(fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
        titleLarge: GoogleFonts.sora(fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
        titleMedium: GoogleFonts.sora(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
        bodyLarge: GoogleFonts.inter(color: const Color(0xFF0F172A)),
        bodyMedium: GoogleFonts.inter(color: const Color(0xFF64748B)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: blinkitYellow,
        foregroundColor: Color(0xFF0C831F),
        elevation: 6,
      ),
    );
  }
}
