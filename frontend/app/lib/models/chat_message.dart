/// One turn in the "Ask AgriShield" chat — either the farmer's own
/// message or the assistant's reply, plus the assistant's optional
/// suite suggestion (see ChatService).
class ChatMessage {
  final String role; // 'user' | 'assistant'
  final String content;
  final String? route;
  final String? routeLabel;
  final bool aiUnavailable;
  final bool isError;

  const ChatMessage({
    required this.role,
    required this.content,
    this.route,
    this.routeLabel,
    this.aiUnavailable = false,
    this.isError = false,
  });

  bool get isUser => role == 'user';
}
