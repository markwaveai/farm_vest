import 'package:flutter/material.dart';

class AppTheme {
  // Brand Cost Color Palette (from image)
  static const Color primary = Color(0xFF2E7D32); // Green
  static const Color secondary = Color(0xFFFF5722); // Orange
  static const Color tertiary = Color(0xFF00695C); // Teal Gradient Start
  static const Color beige = Color(0xFFFFF8E1); // Cream/Beige
  static const Color slate = Color(0xFF455A64); // Blue Grey
  static const Color dark = Color(0xFF263238); // Dark/Black

  // Derived variants
  static const Color darkPrimary = Color(0xFF1B5E20);
  static const Color lightPrimary = Color(0xFF4CAF50);
  static const Color darkSecondary = Color(0xFFE64A19);
  static const Color lightSecondary = Color(0xFFFF8A65);

  // Standard Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color mediumGrey = Color(0xFF9E9E9E);
  static const Color darkGrey = dark; // Mapped to brand dark

  // Semantic Colors
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color warningOrange = secondary;
  static const Color successGreen = primary;

  // Text styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: dark,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: dark,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: dark,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: dark,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: slate, // Use slate for body text variety
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: slate,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: white,
  );

  // Theme data
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.green,
      primaryColor: primary,
      scaffoldBackgroundColor: white, // Keep white for clean look
      appBarTheme: const AppBarTheme(
        backgroundColor: white, // Modern: White App Bar
        foregroundColor: dark, // Dark text
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: dark),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        shadowColor: slate.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: mediumGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        fillColor: lightGrey,
        filled: true,
        hintStyle: TextStyle(color: slate.withValues(alpha: 0.6)),
      ),
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        tertiary: tertiary, // Added tertiary
        surface: white,
        error: errorRed,
        onPrimary: white,
        onSecondary: white,
        onSurface: dark,
      ),
      // Custom extensions could go here
    );
  }
}
