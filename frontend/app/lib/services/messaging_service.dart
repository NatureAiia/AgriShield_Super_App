import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/farmer.dart';
import 'api_config.dart';

/// Triggers an alert to the farmer over Africa's Talking (SMS/USSD/voice)
/// — the Foundation's one communication channel, reused by every part
/// rather than each building its own (docs/roadmap/README.md).
///
/// The actual Africa's Talking send happens server-side (it needs an API
/// key that isn't configured); the backend's `/alerts/send` endpoint mocks
/// it by logging the message instead of sending it. This service just
/// calls that endpoint, and fails soft when offline — matching the app's
/// offline-first shelf-life/mold alerts, which still show on-screen even
/// when the phone can't reach a network to also ring/text them out.
abstract class MessagingService {
  Future<bool> sendAlert({required Farmer farmer, required String message});
}

class MockMessagingService implements MessagingService {
  @override
  Future<bool> sendAlert({required Farmer farmer, required String message}) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/alerts/send'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'farmer': farmer.toJson(), 'message': message}),
          )
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
