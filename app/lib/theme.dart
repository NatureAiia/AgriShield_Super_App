import 'package:flutter/material.dart';

/// Palette from docs/roadmap/UI_UX_DESIGN_SPEC.md — chosen for V1 over the
/// other prototype's dark theme because the spec's brief is the
/// usability-first one (low-end Android, high-contrast, low-literacy).
class AgriShieldColors {
  static const primary = Color(0xFF1B4332);
  static const accent = Color(0xFF2D6A4F);
  static const alert = Color(0xFFB45309);
  static const background = Color(0xFFF1F8F4);
  static const cardBorder = Color(0xFFDCE6E0);
}

ThemeData buildAgriShieldTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AgriShieldColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AgriShieldColors.primary,
      primary: AgriShieldColors.primary,
      secondary: AgriShieldColors.accent,
      error: AgriShieldColors.alert,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AgriShieldColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AgriShieldColors.cardBorder),
      ),
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AgriShieldColors.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
      ),
    ),
  );
}
