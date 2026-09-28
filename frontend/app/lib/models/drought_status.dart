/// District-level drought early warning, aggregated server-side from
/// Part 3's satellite zones (backend/app/services/drought_service.py).
class DroughtStatus {
  final String riskLevel; // 'None' | 'Watch' | 'Moderate' | 'Severe' | 'Unknown'
  final double droughtZoneFraction;
  final double stressedZoneFraction;
  final String reason;
  final String dataSource;

  const DroughtStatus({
    required this.riskLevel,
    required this.droughtZoneFraction,
    required this.stressedZoneFraction,
    required this.reason,
    required this.dataSource,
  });

  factory DroughtStatus.fromJson(Map<String, dynamic> json) => DroughtStatus(
        riskLevel: json['risk_level'] as String,
        droughtZoneFraction: (json['drought_zone_fraction'] as num).toDouble(),
        stressedZoneFraction: (json['stressed_zone_fraction'] as num).toDouble(),
        reason: json['reason'] as String,
        dataSource: json['data_source'] as String? ?? '',
      );
}

class DroughtReportResult {
  final String ticket;
  final String status;
  const DroughtReportResult({required this.ticket, required this.status});

  factory DroughtReportResult.fromJson(Map<String, dynamic> json) => DroughtReportResult(
        ticket: json['ticket'] as String,
        status: json['status'] as String,
      );
}
