import 'package:flutter/material.dart';

/// Consistent corner radii across every card/control — "Consistent
/// Component Radii" from the UI brief: standardize, don't vary per screen.
class AgriShieldRadii {
  static const card = 16.0;
  static const control = 14.0;
  static const pill = 999.0;
}

/// Fixed brand marks — used only where a color must stay constant
/// regardless of theme (the logo itself, the splash background). Anywhere
/// else in the UI, use `context.colors.*` below so dark/light mode
/// actually changes what's on screen.
class AgriShieldBrand {
  static const forestGreen = Color(0xFF1B4332);
  static const leafGreen = Color(0xFF2D6A4F);
  static const mint = Color(0xFF52C48A); // brighter, for legibility on dark surfaces
  static const amber = Color(0xFFB45309);
  static const amberBright = Color(0xFFF59E0B); // higher contrast on dark surfaces
}

/// Semantic status colors (mold-risk tiers) are deliberately NOT part of
/// the Material ColorScheme — "amber means caution" should read the same
/// in light or dark mode. `dot`/vivid colors are for the small indicator
/// only; text uses a separate, checked variant — the vivid tones alone
/// measured well under WCAG AA 4.5:1 against their own pale tint
/// (verified numerically while building this, not assumed).
class AgriShieldStatus {
  static const low = Color(0xFF22C55E);
  static const moderate = Color(0xFFF59E0B);
  static const high = Color(0xFFEF4444);

  static Color text(Color dot, bool isDark) {
    if (dot == low) return isDark ? const Color(0xFF6EE7A0) : const Color(0xFF166534);
    if (dot == moderate) return isDark ? const Color(0xFFFCD34D) : const Color(0xFF92400E);
    return isDark ? const Color(0xFFFCA5A5) : const Color(0xFF991B1B);
  }
}

extension AgriShieldContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  final colorScheme = isDark
      ? const ColorScheme.dark(
          primary: AgriShieldBrand.mint,
          onPrimary: Color(0xFF0A150F),
          secondary: Color(0xFF74C69D),
          onSecondary: Color(0xFF0A150F),
          surface: Color(0xFF16241D),
          onSurface: Color(0xFFE7F3EC),
          error: AgriShieldBrand.amberBright,
          onError: Color(0xFF0A150F),
          outline: Color(0xFF2C4239),
        )
      : const ColorScheme.light(
          primary: AgriShieldBrand.forestGreen,
          onPrimary: Colors.white,
          secondary: AgriShieldBrand.leafGreen,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: AgriShieldBrand.forestGreen,
          error: AgriShieldBrand.amber,
          onError: Colors.white,
          outline: Color(0xFFDCE6E0),
        );

  final scaffoldBackground = isDark ? const Color(0xFF0F1A16) : const Color(0xFFF1F8F4);

  // High-contrast, scalable sans-serif type scale — WCAG AA-safe pairings
  // (onSurface against surface/background both exceed 4.5:1 in each mode).
  final baseText = ThemeData(brightness: brightness).textTheme;
  final textTheme = baseText
      .copyWith(
        headlineSmall: baseText.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: colorScheme.onSurface),
        titleMedium: baseText.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: colorScheme.onSurface),
        bodyMedium: baseText.bodyMedium?.copyWith(color: colorScheme.onSurface),
        labelSmall: baseText.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      )
      .apply(fontSizeFactor: 1.0);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: scaffoldBackground,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: isDark ? 0 : 2,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AgriShieldRadii.card),
        side: BorderSide(color: colorScheme.outline),
      ),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.5 : 0.06),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        disabledBackgroundColor: colorScheme.outline,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AgriShieldRadii.control)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
      ),
    ),
    iconTheme: IconThemeData(color: colorScheme.onSurface),
  );
}

ThemeData buildAgriShieldLightTheme() => _buildTheme(Brightness.light);
ThemeData buildAgriShieldDarkTheme() => _buildTheme(Brightness.dark);
