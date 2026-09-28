import 'package:flutter/material.dart';
import '../services/language_controller.dart';
import '../theme.dart';

/// EN / SN / NR answer-language picker, shared by the chat screen and the
/// profile screen. Rebuilds itself off the controller; the selection
/// persists (SharedPreferences) and applies to the next /chat call.
class LanguagePicker extends StatelessWidget {
  final LanguageController controller;
  final bool compact;

  const LanguagePicker({super.key, required this.controller, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: controller,
      builder: (context, selected, _) {
        return Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (!compact)
              Text(
                'ANSWER LANGUAGE',
                style: context.text.labelSmall,
              ),
            for (final language in AppLanguage.values)
              ChoiceChip(
                label: Text(compact ? language.code.toUpperCase() : language.label),
                selected: language == selected,
                tooltip: language.label,
                onSelected: (_) => controller.setLanguage(language),
              ),
          ],
        );
      },
    );
  }
}
