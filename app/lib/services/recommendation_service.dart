import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/crop_recommendation.dart';
import 'api_config.dart';

/// V2's crop + fertilizer recommendation (docs/roadmap/V2_INTELLIGENCE_LAYER.md),
/// calling the backend's /recommendations endpoints
/// (backend/app/services/recommendation_service.py), ported from
/// AgriLite-FL. Unlike DiseaseService/SatelliteService, there's no mock —
/// the recommendation logic only exists server-side (a scikit-learn
/// model + a CSV lookup), so this always requires the backend.
abstract class RecommendationService {
  Future<CropRecommendation> recommend({
    required double nitrogen,
    required double phosphorous,
    required double potassium,
    required double ph,
    required double rainfall,
    required double temperature,
    required double humidity,
  });
}

class HttpRecommendationService implements RecommendationService {
  @override
  Future<CropRecommendation> recommend({
    required double nitrogen,
    required double phosphorous,
    required double potassium,
    required double ph,
    required double rainfall,
    required double temperature,
    required double humidity,
  }) async {
    final cropResponse = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/recommendations/crop'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nitrogen': nitrogen,
            'phosphorous': phosphorous,
            'potassium': potassium,
            'ph': ph,
            'rainfall': rainfall,
            'temperature': temperature,
            'humidity': humidity,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (cropResponse.statusCode != 200) {
      throw Exception('Crop recommendation failed: ${cropResponse.statusCode}');
    }
    final crop = (jsonDecode(cropResponse.body) as Map<String, dynamic>)['crop'] as String;

    // Fertilizer advice is a best-effort follow-up — the crop reference
    // table doesn't cover every crop the model can predict, so a failure
    // here still leaves the caller with a usable crop recommendation.
    try {
      final fertResponse = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/recommendations/fertilizer'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'crop': crop,
              'nitrogen': nitrogen,
              'phosphorous': phosphorous,
              'potassium': potassium,
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (fertResponse.statusCode == 200) {
        final data = jsonDecode(fertResponse.body) as Map<String, dynamic>;
        return CropRecommendation(
          crop: crop,
          fertilizerNutrient: data['nutrient'] as String?,
          fertilizerDirection: data['direction'] as String?,
          fertilizerAdvice: data['advice'] as String?,
        );
      }
    } catch (_) {
      // Fall through to a crop-only result.
    }
    return CropRecommendation(crop: crop);
  }
}
