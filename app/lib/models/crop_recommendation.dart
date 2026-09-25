/// Result of V2's crop + fertilizer recommendation module
/// (docs/roadmap/V2_INTELLIGENCE_LAYER.md), ported from AgriLite-FL.
class CropRecommendation {
  final String crop;
  final String? fertilizerNutrient;
  final String? fertilizerDirection;
  final String? fertilizerAdvice;

  const CropRecommendation({
    required this.crop,
    this.fertilizerNutrient,
    this.fertilizerDirection,
    this.fertilizerAdvice,
  });
}
