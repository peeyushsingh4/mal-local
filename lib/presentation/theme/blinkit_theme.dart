import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class BlinkitTheme {
  // Brand Primary & Accent Palette
  static const Color blinkitGreen = Color(0xFF0C831F);
  static const Color blinkitGreenLight = Color(0xFFE8F7EE);
  static const Color blinkitYellow = Color(0xFFF7C413);
  static const Color swiggyOrange = Color(0xFFFC8019);
  static const Color zomatoRed = Color(0xFFE23744);

  // Dark Theme Colors (Deep Slate Charcoal)
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkCardBg = Color(0xFF1E293B);
  static const Color darkElevated = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Light Theme Colors (Clean Off-White)
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightCardBg = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFEDF2F7);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Smooth Custom Page Transitions
  static final _smoothPageTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: const FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: const FadeUpwardsPageTransitionsBuilder(),
    },
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: blinkitGreen,
      cardColor: darkCardBg,
      pageTransitionsTheme: _smoothPageTransitions,
      colorScheme: const ColorScheme.dark(
        primary: blinkitGreen,
        onPrimary: Colors.white,
        secondary: blinkitYellow,
        onSecondary: Color(0xFF0F172A),
        surface: darkCardBg,
        onSurface: darkTextPrimary,
        error: zomatoRed,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.sora(fontWeight: FontWeight.w900, color: darkTextPrimary, letterSpacing: -0.5),
        headlineMedium: GoogleFonts.sora(fontWeight: FontWeight.w800, color: darkTextPrimary, letterSpacing: -0.4),
        titleLarge: GoogleFonts.sora(fontWeight: FontWeight.w800, color: darkTextPrimary, letterSpacing: -0.3),
        titleMedium: GoogleFonts.sora(fontWeight: FontWeight.w700, color: darkTextPrimary),
        bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, color: darkTextPrimary, height: 1.3),
        bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, color: darkTextSecondary, height: 1.3),
        labelLarge: GoogleFonts.sora(fontWeight: FontWeight.w800, letterSpacing: 0.2),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: darkCardBg,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: darkBorder),
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
      scaffoldBackgroundColor: lightBg,
      primaryColor: blinkitGreen,
      cardColor: lightCardBg,
      pageTransitionsTheme: _smoothPageTransitions,
      colorScheme: const ColorScheme.light(
        primary: blinkitGreen,
        onPrimary: Colors.white,
        secondary: blinkitYellow,
        onSecondary: Color(0xFF0F172A),
        surface: lightCardBg,
        onSurface: lightTextPrimary,
        error: zomatoRed,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.sora(fontWeight: FontWeight.w900, color: lightTextPrimary, letterSpacing: -0.5),
        headlineMedium: GoogleFonts.sora(fontWeight: FontWeight.w800, color: lightTextPrimary, letterSpacing: -0.4),
        titleLarge: GoogleFonts.sora(fontWeight: FontWeight.w800, color: lightTextPrimary, letterSpacing: -0.3),
        titleMedium: GoogleFonts.sora(fontWeight: FontWeight.w700, color: lightTextPrimary),
        bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w600, color: lightTextPrimary, height: 1.3),
        bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w500, color: lightTextSecondary, height: 1.3),
        labelLarge: GoogleFonts.sora(fontWeight: FontWeight.w800, letterSpacing: 0.2),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightCardBg,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: lightCardBg,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: lightBorder),
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

/// Helper extension for smooth page navigation transitions
extension SmoothRouteExtension on BuildContext {
  Future<T?> pushSmooth<T>(Widget page) {
    return Navigator.push<T>(
      this,
      PageRouteBuilder<T>(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curve,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
