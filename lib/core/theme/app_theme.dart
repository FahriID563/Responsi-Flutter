import 'package:flutter/material.dart';

import 'clay_styles.dart';

/// Konfigurasi Material Design 3 Theme dan Typography untuk tema Claymorphism.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ClayPalette.irisAccent,
      primary: ClayPalette.irisAccent,
      secondary: ClayPalette.coralPrimary,
      tertiary: ClayPalette.mintAccent,
      surface: ClayPalette.lightSurface,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ClayPalette.lightCanvas,
      textTheme: _buildTextTheme(isDark: false),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ClayPalette.lightInk,
        titleTextStyle: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w800,
          color: ClayPalette.lightInk,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: ClayPalette.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: TextStyle(
          color: ClayPalette.lightInkMuted,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ClayPalette.irisAccent,
      primary: const Color(0xFF9C92F5),
      secondary: ClayPalette.coralPrimary,
      tertiary: const Color(0xFF5ED4BC),
      surface: ClayPalette.darkSurface,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ClayPalette.darkCanvas,
      textTheme: _buildTextTheme(isDark: true),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: ClayPalette.darkInk,
        titleTextStyle: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w800,
          color: ClayPalette.darkInk,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: ClayPalette.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: TextStyle(
          color: ClayPalette.darkInkMuted,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme({required bool isDark}) {
    final ink = isDark ? ClayPalette.darkInk : ClayPalette.lightInk;
    final muted = isDark ? ClayPalette.darkInkMuted : ClayPalette.lightInkMuted;

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 64,
        fontWeight: FontWeight.w800,
        letterSpacing: -2.5,
        height: 1.0,
        color: ink,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: ink,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        color: ink,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        color: ink,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      bodyMedium: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        color: muted,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: muted,
      ),
    );
  }
}
