enum ZoneStatus { healthy, stressed, droughtRisk }

/// One district cell from Part 3's Sentinel-2/GEE pull. ~10m resolution,
/// ~5-day revisit, cloud-limited — an early district-scale signal, not a
/// live camera (docs/roadmap/V1_HACKATHON_DEMO.md).
class SatelliteZone {
  final String id;
  final ZoneStatus status;
  final bool isFarmerPlot;

  const SatelliteZone({
    required this.id,
    required this.status,
    this.isFarmerPlot = false,
  });
}
