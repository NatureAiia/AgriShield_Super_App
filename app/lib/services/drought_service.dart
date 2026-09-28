import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/drought_status.dart';
import 'api_config.dart';

/// Drought early-warning — calls backend's /drought/status (aggregated
/// district risk level) and /drought/report (escalation ticket, see
/// backend/app/routers/drought.py).
abstract class DroughtService {
  Future<DroughtStatus> status();
  Future<DroughtReportResult> report({
    required String farmerId,
    required String district,
    required String riskLevel,
    String notes = '',
  });
}

class HttpDroughtService implements DroughtService {
  @override
  Future<DroughtStatus> status() async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/drought/status'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Drought status request failed: ${response.statusCode}');
    }
    return DroughtStatus.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<DroughtReportResult> report({
    required String farmerId,
    required String district,
    required String riskLevel,
    String notes = '',
  }) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/drought/report'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'farmer_id': farmerId,
            'district': district,
            'risk_level': riskLevel,
            'notes': notes,
          }),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Could not submit drought report: ${response.statusCode}');
    }
    return DroughtReportResult.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
