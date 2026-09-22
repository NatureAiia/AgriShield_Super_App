enum MoldRisk { low, moderate, high }

/// One reading from Part 1's solar sensor box (temperature + humidity),
/// plus the shelf-life countdown derived from it.
///
/// Shelf-life uses the food-science rule of thumb from
/// docs/roadmap/V1_HACKATHON_DEMO.md: spoilage roughly doubles for every
/// 10°C rise above a 20°C baseline. Flagged there as needing per-crop
/// verification before being stated as fact to a farmer — kept here as a
/// clearly-named estimate, not dressed up as exact.
class StorageReading {
  final double temperatureC;
  final double humidityPercent;
  final DateTime takenAt;

  const StorageReading({
    required this.temperatureC,
    required this.humidityPercent,
    required this.takenAt,
  });

  /// Baseline: 48 hours of good condition at 20°C, halving every +10°C.
  double get estimatedShelfLifeHours {
    const baselineHours = 48.0;
    const baselineTempC = 20.0;
    final degreesAboveBaseline = (temperatureC - baselineTempC).clamp(0, 100);
    final halvings = degreesAboveBaseline / 10.0;
    return baselineHours / (1 << halvings.floor()).toDouble();
  }

  MoldRisk get moldRisk {
    final warm = temperatureC >= 28;
    final damp = humidityPercent >= 65;
    if (warm && damp) return MoldRisk.high;
    if (warm || damp) return MoldRisk.moderate;
    return MoldRisk.low;
  }
}
