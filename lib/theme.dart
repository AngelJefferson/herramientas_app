// Angel Jefferson Sanchez Ventura
// Matricula:2021-1816

import 'package:flutter/material.dart';

/// Paleta corporativa de la aplicación.
class AppColors {
  const AppColors._();

  static const ink = Color(0xFF0B1220);
  static const navy = Color(0xFF101B35);
  static const indigo = Color(0xFF1E3A8A);
  static const teal = Color(0xFF14B8A6);
  static const cyan = Color(0xFF06B6D4);
  static const amber = Color(0xFFF59E0B);
  static const rose = Color(0xFFEC4899);
  static const violet = Color(0xFF8B5CF6);
  static const blue = Color(0xFF3B82F6);
  static const emerald = Color(0xFF10B981);
  static const surface = Color(0xFFF4F6FB);
  static const border = Color(0xFFE5EAF3);
  static const muted = Color(0xFF64748B);
}

/// Gradientes reutilizables.
class AppGradients {
  const AppGradients._();

  static const header = LinearGradient(
    colors: [Color(0xFF0B1220), Color(0xFF152A54), Color(0xFF0F5F63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const news = LinearGradient(
    colors: [Color(0xFF0B1220), Color(0xFF1E2A5A), Color(0xFF3B1D5A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient accent(Color color) => LinearGradient(
    colors: [color, Color.lerp(color, Colors.black, 0.24)!],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

ThemeData buildAppTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.teal,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.navy,
        onPrimary: Colors.white,
        secondary: AppColors.teal,
        onSecondary: Colors.white,
        tertiary: AppColors.amber,
        surface: Colors.white,
        onSurface: AppColors.ink,
        outlineVariant: AppColors.border,
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.ink,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
      hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
      prefixIconColor: AppColors.muted,
      suffixIconColor: AppColors.muted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.teal, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.navy,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.ink,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.teal,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white,
    ),
  );
}
