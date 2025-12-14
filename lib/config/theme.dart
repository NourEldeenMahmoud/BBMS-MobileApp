import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFFDC143C);
  static const Color secondaryColor = Color(0xFFFF6B6B);
  static const Color backgroundColorLight = Color(0xFFF5F5F5);
  static const Color backgroundColorDark = Color(0xFF211114);
  static const Color textPrimaryLight = Color(0xFF2C3E50);
  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF374151);
  static const Color buttonSecondary = Color(0xFFFF6B6B);

  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;
  static const double borderRadiusFull = 9999.0;

  // Text Styles
  static TextStyle get displayLarge => GoogleFonts.lexend(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => GoogleFonts.lexend(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      );

  static TextStyle get headlineMedium => GoogleFonts.lexend(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.3,
      );

  static TextStyle get titleLarge => GoogleFonts.lexend(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.3,
      );

  static TextStyle get titleMedium => GoogleFonts.lexend(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyLarge => GoogleFonts.lexend(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodyMedium => GoogleFonts.lexend(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodySmall => GoogleFonts.lexend(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      );

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColorLight,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: cardLight,
        error: Colors.red,
      ),
      textTheme: TextTheme(
        displayLarge: displayLarge.copyWith(color: textPrimaryLight),
        displayMedium: displayMedium.copyWith(color: textPrimaryLight),
        headlineMedium: headlineMedium.copyWith(color: textPrimaryLight),
        titleLarge: titleLarge.copyWith(color: textPrimaryLight),
        titleMedium: titleMedium.copyWith(color: textPrimaryLight),
        bodyLarge: bodyLarge.copyWith(color: textPrimaryLight),
        bodyMedium: bodyMedium.copyWith(color: textSecondaryLight),
        bodySmall: bodySmall.copyWith(color: textSecondaryLight),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColorLight,
        elevation: 0,
        iconTheme: const IconThemeData(color: textPrimaryLight),
        titleTextStyle: titleLarge.copyWith(color: textPrimaryLight),
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          textStyle: titleMedium.copyWith(color: Colors.white),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColorDark,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: cardDark,
        error: Colors.red,
      ),
      textTheme: TextTheme(
        displayLarge: displayLarge.copyWith(color: textPrimaryDark),
        displayMedium: displayMedium.copyWith(color: textPrimaryDark),
        headlineMedium: headlineMedium.copyWith(color: textPrimaryDark),
        titleLarge: titleLarge.copyWith(color: textPrimaryDark),
        titleMedium: titleMedium.copyWith(color: textPrimaryDark),
        bodyLarge: bodyLarge.copyWith(color: textPrimaryDark),
        bodyMedium: bodyMedium.copyWith(color: textSecondaryDark),
        bodySmall: bodySmall.copyWith(color: textSecondaryDark),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColorDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: textPrimaryDark),
        titleTextStyle: titleLarge.copyWith(color: textPrimaryDark),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          textStyle: titleMedium.copyWith(color: Colors.white),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
}

