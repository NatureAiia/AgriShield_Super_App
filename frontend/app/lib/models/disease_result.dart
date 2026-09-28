/// Result of Part 2's offline disease check. Always shown to the farmer as
/// a first opinion, never a final answer — see
/// docs/roadmap/V1_HACKATHON_DEMO.md's honest limit on field-photo accuracy
/// (Mohanty, Hughes & Salathé, 2016).
class DiseaseResult {
  final String likelyIssue;
  final double confidence; // 0.0–1.0
  final bool isFirstOpinionOnly;
  final String? advice;

  const DiseaseResult({
    required this.likelyIssue,
    required this.confidence,
    this.isFirstOpinionOnly = true,
    this.advice,
  });

  String get confidenceLabel {
    if (confidence >= 0.85) return 'Likely match';
    if (confidence >= 0.6) return 'Possible match';
    return 'Uncertain — consider an extension officer first';
  }
}
