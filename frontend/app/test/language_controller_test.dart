import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrishield/services/language_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('fromCode maps codes and falls back to English', () {
    expect(AppLanguage.fromCode('en'), AppLanguage.english);
    expect(AppLanguage.fromCode('sn'), AppLanguage.shona);
    expect(AppLanguage.fromCode('nr'), AppLanguage.ndebele);
    expect(AppLanguage.fromCode(null), AppLanguage.english);
    expect(AppLanguage.fromCode('xx'), AppLanguage.english);
  });

  test('defaults to English with empty storage', () async {
    final controller = LanguageController();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(controller.value, AppLanguage.english);
  });

  test('persists selection across instances', () async {
    final first = LanguageController();
    await first.setLanguage(AppLanguage.shona);

    final second = LanguageController();
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(second.value, AppLanguage.shona);
  });
}
