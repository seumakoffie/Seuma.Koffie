// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color espresso = Color(0xFF1A0A00);
  static const Color mocha = Color(0xFF2D1B00);
  static const Color darkRoast = Color(0xFF3D1F00);
  static const Color caramel = Color(0xFFC8702A);
  static const Color caramelDark = Color(0xFFA85520);
  static const Color gold = Color(0xFFD4A853);
  static const Color cream = Color(0xFFF5E6D3);
  static const Color creamLight = Color(0xFFFAF3EC);
  static const Color background = Color(0xFFFDF8F3);
  static const Color card = Colors.white;
  static const Color textDark = Color(0xFF1A0A00);
  static const Color textMuted = Color(0xFF7A5C3A);

  static const Color hotRed = Color(0xFFE63946);
  static const Color iceBlue = Color(0xFF0096C7);
  static const Color successGreen = Color(0xFF2E7D32);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A0A00),
      Color(0xFF331505),
      Color(0xFF542407),
    ],
  );

  static const LinearGradient caramelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFC8702A),
      Color(0xFFD4A853),
    ],
  );

  static const LinearGradient hotGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFE63946)],
  );

  static const LinearGradient iceGradient = LinearGradient(
    colors: [Color(0xFF48CAE4), Color(0xFF0096C7)],
  );

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: espresso.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> hoverShadow = [
    BoxShadow(
      color: caramel.withValues(alpha: 0.22),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.caramel,
        primary: AppColors.caramel,
        surface: AppColors.card,
        onPrimary: Colors.white,
      ),
      fontFamily: 'sans-serif',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
