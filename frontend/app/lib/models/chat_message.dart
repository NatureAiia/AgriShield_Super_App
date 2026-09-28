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
  // Backend-resolved answer language ('en' | 'sn' | 'nr') and where the
  // reply came from ('ai' | 'offline'), shown as a caption under the
  // bubble so the farmer knows what answered, and in which language.
  final String? language;
  final String? source;

  const ChatMessage({
    required this.role,
    required this.content,
    this.route,
    this.routeLabel,
    this.aiUnavailable = false,
    this.isError = false,
    this.language,
    this.source,
  });

  bool get isUser => role == 'user';
  bool get isOfflineAnswer => source == 'offline';
}
