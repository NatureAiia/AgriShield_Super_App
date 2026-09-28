import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrishield/models/crop_recommendation.dart';
import 'package:agrishield/screens/recommendation_screen.dart';
import 'package:agrishield/services/recommendation_service.dart';
import 'package:agrishield/theme.dart';

class _FakeRecommendationService implements RecommendationService {
  @override
  Future<CropRecommendation> recommend({
    required double nitrogen,
    required double phosphorous,
    required double potassium,
    required double ph,
    required double rainfall,
    required double temperature,
    required double humidity,
  }) async =>
      const CropRecommendation(
        crop: 'rice',
        suggestions: [
          CropSuggestion(crop: 'rice', confidence: 0.82),
          CropSuggestion(crop: 'jute', confidence: 0.12),
          CropSuggestion(crop: 'coffee', confidence: 0.03),
        ],
        limitations: 'Demo only — not validated for Zimbabwe.',
      );
}

void main() {
  for (final theme in [buildAgriShieldLightTheme(), buildAgriShieldDarkTheme()]) {
    testWidgets('shows ranked suggestions and the demo notice (${theme.brightness.name})', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Scaffold(body: RecommendationScreen(recommendationService: _FakeRecommendationService())),
      ));

      await tester.tap(find.text('Get recommendation'));
      await tester.pumpAndSettle();

      expect(find.text('Demo only — not validated for Zimbabwe.'), findsOneWidget);
      expect(find.text('HOW SURE THE MODEL IS'), findsOneWidget);
      expect(find.text('82%'), findsOneWidget);
      expect(find.text('jute'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNWidgets(3));
    });
  }
}
