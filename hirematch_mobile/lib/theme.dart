import 'package:flutter/material.dart';

class AppColors {
  static const tealDark = Color(0xFF0D4A4A);
  static const tealMain = Color(0xFF0E7C7C);
  static const tealMid = Color(0xFF1A9999);
  static const tealLight = Color(0xFFE0F4F4);
  static const sidebarBg = Color(0xFF0A3535);
  static const bgPage = Color(0xFFF5F7F7);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF555555);
  static const textMuted = Color(0xFF888888);
  static const border = Color(0xFFE0E0E0);

  static const statusActive = Color(0xFF2ECC71);
  static const statusClosed = Color(0xFFE74C3C);
  static const statusProgress = Color(0xFFF39C12);
  static const statusNew = Color(0xFF3498DB);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bgPage,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.tealMain,
      primary: AppColors.tealDark,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.tealDark,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.tealDark,
        side: const BorderSide(color: AppColors.tealDark, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.tealMain, width: 1.5),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
