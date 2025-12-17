import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryAlert = Color(0xFFD32F2F); // Emergency Red
  static const Color secondaryTrust = Color(0xFF1565C0); // Medical Blue
  
  // Highlighting
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color warningOrange = Color(0xFFEF6C00);

  // Backgrounds
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);

  // Text
  static const Color textDark = Color(0xFF263238);
  static const Color textLight = Color(0xFFECEFF1);

  static ThemeData get paramedicTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryAlert,
        secondary: secondaryTrust,
        surface: darkSurface,
        background: darkBackground,
        error: primaryAlert,
        onSurface: textLight,
      ),
      scaffoldBackgroundColor: darkBackground,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: const TextStyle(fontWeight: FontWeight.w700, color: textLight),
        headlineMedium: const TextStyle(fontWeight: FontWeight.w600, color: textLight),
        bodyLarge: const TextStyle(fontSize: 18, color: textLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryTrust,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  static ThemeData get hospitalTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: secondaryTrust, // Blue is primary for Hospital trust vibe
        secondary: primaryAlert, // Red for alerts
        surface: lightSurface,
        background: lightBackground,
        onSurface: textDark,
      ),
      scaffoldBackgroundColor: lightBackground,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: const TextStyle(fontWeight: FontWeight.w700, color: textDark),
        headlineSmall: const TextStyle(fontWeight: FontWeight.w600, color: textDark),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
