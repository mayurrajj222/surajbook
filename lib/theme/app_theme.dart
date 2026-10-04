import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFF1E1B4B); // Deep Ink Indigo
  static const Color accentRed = Color(0xFFBE123C); // Hardcover Crimson/Maroon
  static const Color accentBlue = Color(0xFF2563EB); // Royal Blue
  static const Color successGreen = Color(0xFF0F766E); // Bookstore Teal
  static const Color warningOrange = Color(0xFFD97706); // Foil Gold / Amber
  static const Color bgLight = Color(0xFFFAF7F2); // Parchment White
  static const Color cardBg = Colors.white;

  // Modern Gradients
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient redGradient = LinearGradient(
    colors: [Color(0xFFE11D48), Color(0xFF9F1239)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient clayCardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFFBF9F6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 3D Neumorphic & Claymorphic Shadows
  static List<BoxShadow> clayShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      offset: const Offset(0, 10),
      blurRadius: 16,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      offset: const Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Colors.white.withOpacity(0.9),
      offset: const Offset(0, -2),
      blurRadius: 0,
      spreadRadius: 2,
    ),
  ];

  static List<BoxShadow> threeDButtonShadow = [
    BoxShadow(
      color: const Color(0xFFBE123C).withOpacity(0.4),
      offset: const Offset(0, 6),
      blurRadius: 10,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Colors.white.withOpacity(0.2),
      offset: const Offset(0, -2),
      blurRadius: 0,
      spreadRadius: 1,
    ),
  ];

  static List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      offset: const Offset(0, 8),
      blurRadius: 24,
    ),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accentRed,
        surface: bgLight,
      ),
      scaffoldBackgroundColor: bgLight,
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        titleLarge: GoogleFonts.outfit(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: const Color(0xFF0F172A),
        ),
        titleMedium: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: const Color(0xFF1E293B),
        ),
        bodyLarge: GoogleFonts.outfit(
          fontWeight: FontWeight.normal,
          fontSize: 16,
          color: const Color(0xFF334155),
        ),
        bodyMedium: GoogleFonts.outfit(
          fontWeight: FontWeight.normal,
          fontSize: 14,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }
}
