import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/advisor.dart';
import 'api_config.dart';

/// AGRITEX advisor hub — calls backend's /advisors (list) and
/// /advisors/request (a farm-visit/escalation/consultation ticket).
/// The directory itself is a labeled placeholder server-side (see
/// backend/app/services/advisor_service.py); this just talks to it.
abstract class AdvisorService {
  Future<(List<Advisor>, String)> listAdvisors();
  Future<AdvisorRequestResult> submitRequest({
    required String farmerId,
    String? advisorId,
    required AdvisorRequestType requestType,
    String notes = '',
  });
}

class HttpAdvisorService implements AdvisorService {
  @override
  Future<(List<Advisor>, String)> listAdvisors() async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/advisors'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Advisor request failed: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final advisors = (data['advisors'] as List<dynamic>)
        .map((a) => Advisor.fromJson(a as Map<String, dynamic>))
        .toList();
    return (advisors, data['data_source'] as String? ?? '');
  }

  @override
  Future<AdvisorRequestResult> submitRequest({
    required String farmerId,
    String? advisorId,
    required AdvisorRequestType requestType,
    String notes = '',
  }) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/advisors/request'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'farmer_id': farmerId,
            if (advisorId != null) 'advisor_id': advisorId,
            'request_type': requestType.apiValue,
            'notes': notes,
          }),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Could not submit request: ${response.statusCode}');
    }
    return AdvisorRequestResult.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
