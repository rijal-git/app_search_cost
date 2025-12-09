import 'package:flutter/material.dart';

/// 🎨 Premium Navy & Gold Color Scheme
class AppColors {
  // Navy Colors
  static const Color premiumNavy = Color(0xFF0A1A2F);
  static const Color softNavy = Color(0xFF153354);
  static const Color lightNavy = Color(0xFF1F4A6F);

  // Gold/Accent
  static const Color goldMedium = Color(0xFFE9C678);
  static const Color goldLight = Color(0xFFF5E6D3);
  static const Color goldDark = Color(0xFFD4A574);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF757575);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color divider = Color(0xFFE0E0E0);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF2196F3);
}

/// 🎨 Get Navy Gold Theme for MaterialApp
ThemeData getNavyGoldTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.premiumNavy,
      brightness: Brightness.light,
      primary: AppColors.premiumNavy,
      onPrimary: AppColors.white,
      secondary: AppColors.goldMedium,
      onSecondary: AppColors.premiumNavy,
      tertiary: AppColors.softNavy,
      surface: AppColors.white,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.premiumNavy,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.goldMedium,
      foregroundColor: AppColors.premiumNavy,
      elevation: 4,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.premiumNavy,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.premiumNavy,
        side: const BorderSide(color: AppColors.goldMedium, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.premiumNavy,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.goldMedium, width: 2),
      ),
      filled: true,
      fillColor: AppColors.lightGrey,
      labelStyle: const TextStyle(color: AppColors.softNavy),
      hintStyle: const TextStyle(color: AppColors.grey),
      prefixIconColor: AppColors.softNavy,
      suffixIconColor: AppColors.softNavy,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.premiumNavy,
        fontSize: 32,
        fontWeight: FontWeight.w900,
      ),
      displayMedium: TextStyle(
        color: AppColors.premiumNavy,
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: AppColors.premiumNavy,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: TextStyle(
        color: AppColors.softNavy,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: AppColors.premiumNavy,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        color: AppColors.grey,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        color: AppColors.grey,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
    scaffoldBackgroundColor: AppColors.lightGrey,
    cardTheme: CardTheme(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.divider),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightGrey,
      selectedColor: AppColors.goldMedium,
      labelStyle: const TextStyle(
        color: AppColors.premiumNavy,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    dividerColor: AppColors.divider,
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 16,
    ),
  );
}
