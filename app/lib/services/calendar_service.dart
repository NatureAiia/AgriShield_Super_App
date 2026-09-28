import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/activity.dart';
import 'api_config.dart';

/// Spraying & activity calendar — calls backend's /calendar
/// (backend/app/routers/calendar.py).
abstract class CalendarService {
  Future<List<Activity>> list(String farmerId);
  Future<Activity> create({
    required String farmerId,
    required String title,
    String notes,
    required DateTime scheduledFor,
    String source,
  });
  Future<Activity> toggle(String activityId);
  Future<void> delete(String activityId);
}

class HttpCalendarService implements CalendarService {
  @override
  Future<List<Activity>> list(String farmerId) async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/calendar/$farmerId'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Could not load calendar: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((a) => Activity.fromJson(a as Map<String, dynamic>)).toList();
  }

  @override
  Future<Activity> create({
    required String farmerId,
    required String title,
    String notes = '',
    required DateTime scheduledFor,
    String source = 'manual',
  }) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/calendar'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'farmer_id': farmerId,
            'title': title,
            'notes': notes,
            'scheduled_for': scheduledFor.toIso8601String(),
            'source': source,
          }),
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Could not create activity: ${response.statusCode}');
    }
    return Activity.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<Activity> toggle(String activityId) async {
    final response = await http
        .patch(Uri.parse('${ApiConfig.baseUrl}/calendar/$activityId/toggle'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Could not update activity: ${response.statusCode}');
    }
    return Activity.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<void> delete(String activityId) async {
    final response = await http
        .delete(Uri.parse('${ApiConfig.baseUrl}/calendar/$activityId'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Could not delete activity: ${response.statusCode}');
    }
  }
}
