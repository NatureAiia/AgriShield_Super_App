import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../services/language_controller.dart';
import '../theme.dart';
import '../widgets/language_picker.dart';

/// "Ask AgriShield" — a farmer types a question in plain language;
/// the backend's keyword router always suggests a suite, and adds a
/// conversational reply on top when ANTHROPIC_API_KEY is configured.
/// Concept ported from Sebastian's chat suite (bubble transcript,
/// starter chips, a route deep-link chip, an explicit "AI not
/// configured" state), rebuilt for AgriShield's own suites.
class AdviceChatScreen extends StatefulWidget {
  final ChatService chatService;
  final LanguageController languageController;
  final void Function(String route)? onOpenRoute;

  const AdviceChatScreen({super.key, required this.chatService, required this.languageController, this.onOpenRoute});

  @override
  State<AdviceChatScreen> createState() => _AdviceChatScreenState();
}

const _starters = {
  AppLanguage.english: [
    'My maize smells musty, what do I do?',
    'Is it going to rain this week?',
    'What crop suits my soil?',
    "What's a fair price for maize right now?",
  ],
  AppLanguage.shona: [
    'Chibage changu chine makonye, ndoita sei?',
    'Mvura ichanaya rinhi?',
    'Ndingadyara mbeu rinhi?',
    'Mutengo wechibage nhasi?',
  ],
  AppLanguage.ndebele: [
    'Isibungu sihlasela umumbu wami, ngenzeni?',
    'Imvula izana nini?',
    'Ngingahlanyela nini?',
    'Yimalini umumbu eRenkini?',
  ],
};

class _AdviceChatScreenState extends State<AdviceChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _busy = false;
  String? _lastError;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _busy) return;
    final history = List<ChatMessage>.from(_messages);
    setState(() {
      _messages.add(ChatMessage(role: 'user', content: trimmed));
      _controller.clear();
      _busy = true;
      _lastError = null;
    });
    _scrollToBottom();

    try {
      final reply = await widget.chatService.ask(
        trimmed,
        history,
        language: widget.languageController.value.code,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(reply);
        _busy = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _lastError = trimmed;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ask AgriShield')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: LanguagePicker(controller: widget.languageController, compact: true),
          ),
          Expanded(
            child: ValueListenableBuilder<AppLanguage>(
              valueListenable: widget.languageController,
              builder: (context, language, _) {
                return _messages.isEmpty
                    ? _StarterGrid(onPick: _send, starters: _starters[language]!)
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length + (_busy ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i >= _messages.length) {
                            return const _ThinkingBubble();
                          }
                          return _MessageBubble(
                            message: _messages[i],
                            onOpenRoute: widget.onOpenRoute,
                          );
                        },
                      );
              },
            ),
          ),
          if (_lastError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: _ErrorNotice(onRetry: () => _send(_lastError!)),
            ),
          _Composer(controller: _controller, busy: _busy, onSend: _send, languageController: widget.languageController),
        ],
      ),
    );
  }
}

class _StarterGrid extends StatelessWidget {
  final ValueChanged<String> onPick;
  final List<String> starters;
  const _StarterGrid({required this.onPick, required this.starters});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.eco, size: 40, color: context.colors.secondary),
          const SizedBox(height: 12),
          Text('Ask about your crop, storage, weather or prices',
              style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            "I'll answer in plain words, and point you to the right part of the app.",
            style: TextStyle(color: context.colors.onSurface.withValues(alpha: 0.65)),
          ),
          const SizedBox(height: 20),
          for (final s in starters)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => onPick(s),
                borderRadius: BorderRadius.circular(AgriShieldRadii.card),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    border: Border.all(color: context.colors.outline),
                    borderRadius: BorderRadius.circular(AgriShieldRadii.card),
                  ),
                  child: Text(s),
                ),
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final void Function(String route)? onOpenRoute;
  const _MessageBubble({required this.message, this.onOpenRoute});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final bubbleColor = isUser
        ? context.colors.secondary
        : (message.aiUnavailable
            ? AgriShieldBrand.amber.withValues(alpha: context.isDark ? 0.28 : 0.14)
            : context.colors.surface);
    final textColor = isUser ? context.colors.onSecondary : context.colors.onSurface;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(AgriShieldRadii.card),
          border: isUser ? null : Border.all(color: context.colors.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.aiUnavailable)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  "Conversational assistant isn't configured",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: textColor.withValues(alpha: 0.75)),
                ),
              ),
            if (!isUser && message.language != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Answered in ${AppLanguage.fromCode(message.language).label}'
                  '${message.isOfflineAnswer ? ' · offline answer' : ''}',
                  style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.6)),
                ),
              ),
            Text(message.content, style: TextStyle(color: textColor)),
            if (!isUser && message.route != null && message.routeLabel != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton.icon(
                  onPressed: onOpenRoute == null ? null : () => onOpenRoute!(message.route!),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: Text('Go to ${message.routeLabel}'),
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border.all(color: context.colors.outline),
          borderRadius: BorderRadius.circular(AgriShieldRadii.card),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.secondary),
            ),
            const SizedBox(width: 8),
            const Text('AgriShield is thinking…'),
          ],
        ),
      ),
    );
  }
}

class _ErrorNotice extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorNotice({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.colors.error.withValues(alpha: context.isDark ? 0.24 : 0.12),
        borderRadius: BorderRadius.circular(AgriShieldRadii.control),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: context.colors.error),
          const SizedBox(width: 8),
          const Expanded(child: Text("Couldn't reach AgriShield — check your connection.")),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool busy;
  final ValueChanged<String> onSend;
  final LanguageController languageController;
  const _Composer(
      {required this.controller, required this.busy, required this.onSend, required this.languageController});

  static const _hints = {
    AppLanguage.english: 'Ask about your crop, storage, weather…',
    AppLanguage.shona: 'Bvunza nezvechirimwa chako, dura, ekunze…',
    AppLanguage.ndebele: 'Buza ngesilimo sakho, isibaya, sezulu…',
  };

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: languageController,
      builder: (context, language, _) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: busy ? null : onSend,
                    decoration: InputDecoration(
                      hintText: _hints[language],
                      filled: true,
                      fillColor: context.colors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AgriShieldRadii.pill),
                        borderSide: BorderSide(color: context.colors.outline),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: busy ? null : () => onSend(controller.text),
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
