import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted dark/light/system preference — offline-first, same as the
/// farmer record: reads and writes locally, no network needed.
class ThemeController extends ValueNotifier<ThemeMode> {
  static const _storageKey = 'agrishield_theme_mode_v1';

  ThemeController() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_storageKey);
    value = ThemeMode.values.firstWhere((m) => m.name == stored, orElse: () => ThemeMode.system);
  }

  Future<void> cycle() async {
    const order = [ThemeMode.system, ThemeMode.light, ThemeMode.dark];
    value = order[(order.indexOf(value) + 1) % order.length];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, value.name);
  }

  IconData get icon => switch (value) {
        ThemeMode.system => Icons.brightness_auto,
        ThemeMode.light => Icons.light_mode,
        ThemeMode.dark => Icons.dark_mode,
      };

  String get label => switch (value) {
        ThemeMode.system => 'Theme: matching phone',
        ThemeMode.light => 'Theme: light',
        ThemeMode.dark => 'Theme: dark',
      };
}
