import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color scaffoldBackground = Color(0xFF212121);
  static const Color appBarBackground = Color(0xFF303030);
  static const Color cardBackground = Color(0xFF11144C);
  static const Color cardDark = Color(0xFF424242);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textHint = Colors.grey;
  static const Color accent = Colors.blueAccent;
  static const Color danger = Colors.redAccent;

  static const Color dotGold = Color(0xFFFABC60);
  static const Color dotRed = Color(0xFFE16262);
  static const Color dotGreen = Color(0xFF3A9679);

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: scaffoldBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: appBarBackground,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: accent,
      foregroundColor: textPrimary,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: cardDark,
      titleTextStyle: const TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
