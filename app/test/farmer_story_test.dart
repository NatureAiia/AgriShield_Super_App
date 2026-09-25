import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrishield/screens/farmer_story_screen.dart';
import 'package:agrishield/theme.dart';

void main() {
  testWidgets('story answers the four farmer questions, then finishes', (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    var finished = false;
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigator,
      theme: buildAgriShieldLightTheme(),
      home: const Scaffold(body: SizedBox()),
    ));
    navigator.currentState!.push(MaterialPageRoute(
      builder: (_) => FarmerStoryScreen(finishLabel: 'Got it', onFinish: () => finished = true),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    const questions = [
      'WHAT DOES IT DO FOR ME?',
      'WILL IT MAKE MY LIFE EASIER?',
      'WILL IT SAVE ME MONEY?',
      'CAN I USE IT ON MY PHONE?',
    ];
    for (var i = 0; i < questions.length; i++) {
      expect(find.text(questions[i]), findsOneWidget);
      await tester.tap(find.text(i == questions.length - 1 ? 'Got it' : 'Next'));
      // Page turns and route pops are animations: pump through them, then
      // one more frame so the next page is built.
      for (var f = 0; f < 10; f++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }
    expect(finished, isTrue);
    expect(find.byType(FarmerStoryScreen), findsNothing);
  });
}
