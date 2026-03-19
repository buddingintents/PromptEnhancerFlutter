import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0E766E),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FBFA),
      useMaterial3: true,
    );
  }
}
