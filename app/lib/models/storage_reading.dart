enum MoldRisk { low, moderate, high }

/// One reading from Part 1's solar sensor box — temperature, humidity, and
/// CO2 — plus the shelf-life countdown derived from it.
///
/// Shelf-life uses the food-science rule of thumb from
/// docs/roadmap/V1_HACKATHON_DEMO.md: spoilage roughly doubles for every
/// 10°C rise above a 20°C baseline. Flagged there as needing per-crop
/// verification before being stated as fact to a farmer — kept here as a
/// clearly-named estimate, not dressed up as exact.
///
/// Mold risk follows OPIsystems' three-signal approach cited in the vision
/// doc (§5.2): temperature, dampness, and CO2 are the three real signals
/// used to catch spoiling grain early — grain that's rotting or has pests
/// breathes out extra CO2 before anything is visible. A CO2 spike alone,
/// even with normal temperature/humidity, is treated as high risk for
/// exactly that reason: it's the one signal that's supposed to fire before
/// the others do.
class StorageReading {
  final double temperatureC;
  final double humidityPercent;
  final double co2Ppm;
  final DateTime takenAt;

  const StorageReading({
    required this.temperatureC,
    required this.humidityPercent,
    required this.co2Ppm,
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

  /// Outdoor ambient CO2 is roughly 400–420ppm. Enclosed grain storage
  /// runs a bit higher even when healthy; these thresholds mark "rising"
  /// vs. "a clear early-spoilage signal," not exact food-safety figures —
  /// same honesty-flagged status as the shelf-life multiplier above.
  static const _co2Elevated = 800.0;
  static const _co2High = 1200.0;

  bool get co2Elevated => co2Ppm >= _co2Elevated;
  bool get co2High => co2Ppm >= _co2High;

  MoldRisk get moldRisk {
    final warm = temperatureC >= 28;
    final damp = humidityPercent >= 65;
    if ((warm && damp) || co2High) return MoldRisk.high;
    if (warm || damp || co2Elevated) return MoldRisk.moderate;
    return MoldRisk.low;
  }
}
