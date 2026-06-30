import 'package:flutter/material.dart';

class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF6F7FB),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF5B6CFF),
    ),
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(color: Colors.white), // Changes back button color
      actionsIconTheme: IconThemeData(color: Colors.white),
    ),
  );

  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0B0F1A),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF5B6CFF),
      brightness: Brightness.dark,
    ),
  );
}