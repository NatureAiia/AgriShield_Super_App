import 'package:flutter/material.dart';

/// Consistent corner radii across every card/control — "Consistent
/// Component Radii" from the UI brief: standardize, don't vary per screen.
/// Soft, generous rounding to match the "modern farming" design language.
class AgriShieldRadii {
  static const card = 24.0;
  static const tile = 18.0;
  static const control = 16.0;
  static const pill = 999.0;
}

/// Fixed brand marks — used only where a color must stay constant
/// regardless of theme (the logo itself, illustrations). Anywhere else in
/// the UI, use `context.colors.*` / `context.palette.*` so dark/light mode
/// actually changes what's on screen.
class AgriShieldBrand {
  static const forestGreen = Color(0xFF1F4D37);
  static const leafGreen = Color(0xFF2E6A4F);
  static const mint = Color(0xFF5CBF8C); // brighter, for legibility on dark surfaces
  static const amber = Color(0xFFB45309);
  static const amberBright = Color(0xFFF59E0B); // higher contrast on dark surfaces
}

/// Semantic status colors (mold-risk tiers) are deliberately NOT part of
/// the Material ColorScheme — "amber means caution" should read the same
/// in light or dark mode. `dot`/vivid colors are for the small indicator
/// only; text uses a separate, checked variant — the vivid tones alone
/// measured well under WCAG AA 4.5:1 against their own pale tint.
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

/// Extra design tokens that Material's ColorScheme has no slot for:
/// the soft tinted chips (sky / sun / leaf) used on stat cards and action
/// rows, plus a secondary surface for inner panels.
@immutable
class AgriShieldPalette extends ThemeExtension<AgriShieldPalette> {
  final Color surface2;
  final Color surface3;
  final Color muted;
  final Color primarySoft;
  final Color skyBg, skyInk;
  final Color sunBg, sunInk;
  final Color leafBg, leafInk;

  const AgriShieldPalette({
    required this.surface2,
    required this.surface3,
    required this.muted,
    required this.primarySoft,
    required this.skyBg,
    required this.skyInk,
    required this.sunBg,
    required this.sunInk,
    required this.leafBg,
    required this.leafInk,
  });

  static const light = AgriShieldPalette(
    surface2: Color(0xFFF3F8F5),
    surface3: Color(0xFFE8F1EC),
    muted: Color(0xFF6B7F73),
    primarySoft: Color(0xFFE3F1E8),
    skyBg: Color(0xFFE2F3FB),
    skyInk: Color(0xFF2B7FA8),
    sunBg: Color(0xFFFDF5DC),
    sunInk: Color(0xFFB7791F),
    leafBg: Color(0xFFE4F5E8),
    leafInk: Color(0xFF2E6A4F),
  );

  static const dark = AgriShieldPalette(
    surface2: Color(0xFF182820),
    surface3: Color(0xFF1F3229),
    muted: Color(0xFF8FA698),
    primarySoft: Color(0xFF183326),
    skyBg: Color(0xFF13293A),
    skyInk: Color(0xFF7CC6EA),
    sunBg: Color(0xFF2D2612),
    sunInk: Color(0xFFF2C35B),
    leafBg: Color(0xFF163022),
    leafInk: Color(0xFF7BD3A5),
  );

  @override
  AgriShieldPalette copyWith() => this;

  @override
  AgriShieldPalette lerp(ThemeExtension<AgriShieldPalette>? other, double t) {
    if (other is! AgriShieldPalette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AgriShieldPalette(
      surface2: l(surface2, other.surface2),
      surface3: l(surface3, other.surface3),
      muted: l(muted, other.muted),
      primarySoft: l(primarySoft, other.primarySoft),
      skyBg: l(skyBg, other.skyBg),
      skyInk: l(skyInk, other.skyInk),
      sunBg: l(sunBg, other.sunBg),
      sunInk: l(sunInk, other.sunInk),
      leafBg: l(leafBg, other.leafBg),
      leafInk: l(leafInk, other.leafInk),
    );
  }
}

extension AgriShieldContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  AgriShieldPalette get palette =>
      Theme.of(this).extension<AgriShieldPalette>() ?? (isDark ? AgriShieldPalette.dark : AgriShieldPalette.light);

  /// Soft card shadow used across the redesign.
  List<BoxShadow> get softShadow => [
        BoxShadow(
          color: isDark ? Colors.black.withValues(alpha: 0.35) : const Color(0xFF1F4D37).withValues(alpha: 0.08),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];
}

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final palette = isDark ? AgriShieldPalette.dark : AgriShieldPalette.light;

  final colorScheme = isDark
      ? const ColorScheme.dark(
          primary: AgriShieldBrand.mint,
          onPrimary: Color(0xFF052113),
          secondary: Color(0xFF7BD3A5),
          onSecondary: Color(0xFF052113),
          surface: Color(0xFF121E18),
          onSurface: Color(0xFFE7F2EC),
          error: AgriShieldBrand.amberBright,
          onError: Color(0xFF0A150F),
          outline: Color(0xFF22362C),
        )
      : const ColorScheme.light(
          primary: AgriShieldBrand.leafGreen,
          onPrimary: Colors.white,
          secondary: Color(0xFF3F8A67),
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Color(0xFF13261C),
          error: AgriShieldBrand.amber,
          onError: Colors.white,
          outline: Color(0xFFE1EBE5),
        );

  final scaffoldBackground = isDark ? const Color(0xFF0A1310) : const Color(0xFFE9F4EE);

  // High-contrast, scalable sans-serif type scale — WCAG AA-safe pairings.
  final baseText = ThemeData(brightness: brightness).textTheme;
  final textTheme = baseText.copyWith(
    headlineMedium: baseText.headlineMedium?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.onSurface),
    headlineSmall: baseText.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.onSurface),
    titleLarge: baseText.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.onSurface),
    titleMedium: baseText.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: colorScheme.onSurface),
    titleSmall: baseText.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
    bodyMedium: baseText.bodyMedium?.copyWith(color: colorScheme.onSurface),
    bodySmall: baseText.bodySmall?.copyWith(color: palette.muted),
    labelSmall: baseText.labelSmall?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      color: palette.muted,
    ),
  );

  final pillShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AgriShieldRadii.pill));

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: scaffoldBackground,
    textTheme: textTheme,
    extensions: [palette],
    // Pushed screens (Advisor, Calendar, Weather…) get the same airy header
    // as the main shell: no colored bar, centered title, round back button.
    appBarTheme: AppBarTheme(
      backgroundColor: scaffoldBackground,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: colorScheme.onSurface),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AgriShieldRadii.card),
        side: BorderSide(color: colorScheme.outline),
      ),
      elevation: isDark ? 0 : 1.5,
      shadowColor: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0xFF1F4D37).withValues(alpha: 0.10),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        disabledBackgroundColor: colorScheme.outline,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: pillShape,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: pillShape,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        side: BorderSide(color: colorScheme.outline),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: pillShape,
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        shape: pillShape,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 3,
      shape: pillShape,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.surface2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: TextStyle(color: palette.muted),
      hintStyle: TextStyle(color: palette.muted.withValues(alpha: 0.7)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AgriShieldRadii.control), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AgriShieldRadii.control), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AgriShieldRadii.control),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colorScheme.surface,
      selectedColor: colorScheme.primary,
      side: BorderSide(color: colorScheme.outline),
      shape: pillShape,
      labelStyle: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
      secondaryLabelStyle: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onPrimary),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(shape: pillShape),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AgriShieldRadii.tile)),
      iconColor: colorScheme.primary,
    ),
    dividerTheme: DividerThemeData(color: colorScheme.outline, space: 1),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AgriShieldRadii.control)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AgriShieldRadii.card)),
    ),
    iconTheme: IconThemeData(color: colorScheme.onSurface),
  );
}

ThemeData buildAgriShieldLightTheme() => _buildTheme(Brightness.light);
ThemeData buildAgriShieldDarkTheme() => _buildTheme(Brightness.dark);
