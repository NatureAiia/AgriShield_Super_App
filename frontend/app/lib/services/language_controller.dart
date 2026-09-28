import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The language "Ask AgriShield" answers in — sent as `language` on every
/// /chat call (backend/app/routers/chat.py), where it picks the offline
/// English/ChiShona/isiNdebele answers when the AI is unavailable.
///
/// Persisted like ThemeController: local SharedPreferences read, no
/// network needed, survives sign-out (it is an app preference, not part
/// of the farmer record).
enum AppLanguage {
  english('en', 'English'),
  shona('sn', 'ChiShona'),
  ndebele('nr', 'isiNdebele');

  final String code;
  final String label;
  const AppLanguage(this.code, this.label);

  static AppLanguage fromCode(String? code) =>
      AppLanguage.values.firstWhere((l) => l.code == code, orElse: () => AppLanguage.english);
}

class LanguageController extends ValueNotifier<AppLanguage> {
  static const _storageKey = 'agrishield_chat_language_v1';

  LanguageController() : super(AppLanguage.english) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    value = AppLanguage.fromCode(prefs.getString(_storageKey));
  }

  Future<void> setLanguage(AppLanguage language) async {
    value = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, language.code);
  }
}
