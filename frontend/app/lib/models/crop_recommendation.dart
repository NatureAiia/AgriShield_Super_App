/// One ranked alternative from the crop model, with the model's own
/// class probability (0–1) — how sure it is, not how good the crop is.
class CropSuggestion {
  final String crop;
  final double confidence;

  const CropSuggestion({required this.crop, required this.confidence});

  factory CropSuggestion.fromJson(Map<String, dynamic> json) => CropSuggestion(
        crop: json['crop'] as String,
        confidence: (json['confidence'] as num).toDouble(),
      );
}

/// Result of V2's crop + fertilizer recommendation module
/// (docs/roadmap/V2_INTELLIGENCE_LAYER.md), ported from AgriLite-FL.
class CropRecommendation {
  final String crop;
  final List<CropSuggestion> suggestions;
  // Defaults to true: the model is demo-only until a validated local
  // dataset exists, so a response missing the flag is treated as demo.
  final bool demoOnly;
  final String? limitations;
  final String? fertilizerNutrient;
  final String? fertilizerDirection;
  final String? fertilizerAdvice;

  const CropRecommendation({
    required this.crop,
    this.suggestions = const [],
    this.demoOnly = true,
    this.limitations,
    this.fertilizerNutrient,
    this.fertilizerDirection,
    this.fertilizerAdvice,
  });

  CropRecommendation withFertilizer({String? nutrient, String? direction, String? advice}) => CropRecommendation(
        crop: crop,
        suggestions: suggestions,
        demoOnly: demoOnly,
        limitations: limitations,
        fertilizerNutrient: nutrient,
        fertilizerDirection: direction,
        fertilizerAdvice: advice,
      );
}
