import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import 'api_config.dart';

/// "Ask AgriShield" — calls the backend's /chat (backend/app/routers/chat.py),
/// which always returns a suite suggestion from its keyword router, plus a
/// conversational reply when ANTHROPIC_API_KEY is configured server-side.
/// No mock: like RecommendationService, the router+AI logic only exists
/// server-side, so this always requires the backend.
abstract class ChatService {
  Future<ChatMessage> ask(String message, List<ChatMessage> history);
}

class HttpChatService implements ChatService {
  @override
  Future<ChatMessage> ask(String message, List<ChatMessage> history) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/chat'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'message': message,
            'history': history
                .map((m) => {'role': m.role, 'content': m.content})
                .toList(),
          }),
        )
        .timeout(const Duration(seconds: 25));

    if (response.statusCode != 200) {
      throw Exception('Chat request failed: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final code = data['code'] as String?;
    final route = data['route'] as String?;
    final routeLabel = data['route_label'] as String?;
    final reply = data['reply'] as String? ?? '';

    return ChatMessage(
      role: 'assistant',
      content: reply.isNotEmpty
          ? reply
          : (route != null
              ? "I can't reach the conversational assistant right now, but this sounds like something $routeLabel can help with."
              : "I can't reach the conversational assistant right now, and I'm not sure which part of the app answers that — try Storage, Disease Scan, Recommend, or Satellite Map."),
      route: route,
      routeLabel: routeLabel,
      aiUnavailable: code == 'ai_unavailable',
    );
  }
}
