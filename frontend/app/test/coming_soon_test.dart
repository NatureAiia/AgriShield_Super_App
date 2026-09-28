import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrishield/models/upcoming_feature.dart';
import 'package:agrishield/screens/coming_soon_screen.dart';
import 'package:agrishield/theme.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('every roadmap feature says what it needs before it ships', () {
    for (final f in upcomingFeatures) {
      expect(f.needsFirst, isNotEmpty, reason: f.id);
      expect(['V2', 'V3'], contains(f.version), reason: f.id);
      if (f.preview == FeaturePreview.message) {
        expect(previewMessages[f.id], isNotNull, reason: f.id);
      }
    }
  });

  for (final feature in upcomingFeatures) {
    testWidgets('${feature.id} detail is labelled coming soon, with sample data and its caveat', (tester) async {
      // A tall phone-width screen so the whole page (caveat, button) is built.
      tester.view.physicalSize = const Size(412, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        theme: buildAgriShieldDarkTheme(),
        home: ComingSoonScreen(feature: feature),
      ));
      // Ambient animations repeat forever, so pump fixed time, not settle.
      await tester.pump(const Duration(seconds: 3));

      expect(find.text('COMING SOON · ${feature.version}'), findsOneWidget);
      expect(find.text('Sample data'), findsOneWidget);
      expect(find.text('Before it ships: ${feature.needsFirst}'), findsOneWidget);

      await tester.tap(find.text('Notify me when it launches'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text("You'll be told first"), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('notify_${feature.id}'), isTrue);
    });
  }
}
