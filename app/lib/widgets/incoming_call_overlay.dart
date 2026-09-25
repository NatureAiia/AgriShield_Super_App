import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';

/// Moment 3 ("a phone actually rings", docs/roadmap/V1_HACKATHON_DEMO.md)
/// staged full-screen: a ringing phone while the alert goes out, then the
/// spoken message typed out as a live transcript. [send] is the real
/// MessagingService round trip; the overlay only dramatises its result.
Future<void> showIncomingCallOverlay(
  BuildContext context, {
  required String farmerName,
  required String message,
  required Future<bool> Function() send,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black87,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => _IncomingCall(farmerName: farmerName, message: message, send: send),
    transitionBuilder: (_, animation, __, child) => FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween(begin: 1.08, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
    ),
  );
}

enum _CallState { ringing, connected, failed }

class _IncomingCall extends StatefulWidget {
  final String farmerName;
  final String message;
  final Future<bool> Function() send;

  const _IncomingCall({required this.farmerName, required this.message, required this.send});

  @override
  State<_IncomingCall> createState() => _IncomingCallState();
}

class _IncomingCallState extends State<_IncomingCall> {
  _CallState _state = _CallState.ringing;
  int _typed = 0;
  Timer? _typer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    // Ring for at least ~2.4s so the room sees it, however fast the backend is.
    final results = await Future.wait([
      widget.send(),
      Future.delayed(const Duration(milliseconds: 2400), () => true),
    ]);
    if (!mounted) return;
    final sent = results.first;
    setState(() => _state = sent ? _CallState.connected : _CallState.failed);
    if (sent) {
      _typer = Timer.periodic(const Duration(milliseconds: 28), (t) {
        if (!mounted || _typed >= widget.message.length) {
          t.cancel();
          return;
        }
        setState(() => _typed++);
      });
    }
  }

  @override
  void dispose() {
    _typer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ringing = _state == _CallState.ringing;
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B2A1E), Color(0xFF1B4332), Color(0xFF0F1A16)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    switch (_state) {
                      _CallState.ringing => 'AgriShield is calling…',
                      _CallState.connected => 'Call connected',
                      _CallState.failed => 'No signal right now',
                    },
                    key: ValueKey(_state),
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 16, letterSpacing: 0.3),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.farmerName,
                  style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text('Voice call · works on any phone',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
                const Spacer(),
                _RingingAvatar(ringing: ringing, ok: _state != _CallState.failed),
                const Spacer(),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: switch (_state) {
                    _CallState.ringing => const SizedBox(width: double.infinity),
                    _CallState.connected => _Transcript(text: widget.message.substring(0, _typed)),
                    _CallState.failed => Text(
                        'The alert is queued and will ring through as soon as the phone is back in coverage. '
                        'The on-screen warning already works offline.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), height: 1.4),
                      ).animate().fadeIn(),
                  },
                ),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                    child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 34),
                  ),
                ).animate().scaleXY(begin: 0.6, end: 1, delay: 200.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 8),
                Text('End', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
                const SizedBox(height: 16),
                Text(
                  'Demo mode: sent through the AgriShield backend. Real calls go out over Africa\'s Talking once the account is live.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingingAvatar extends StatelessWidget {
  final bool ringing;
  final bool ok;
  const _RingingAvatar({required this.ringing, required this.ok});

  @override
  Widget build(BuildContext context) {
    final accent = ok ? AgriShieldBrand.mint : AgriShieldStatus.moderate;
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (ringing)
            for (var i = 0; i < 3; i++)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: accent, width: 2)),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .scaleXY(begin: 1, end: 2, delay: (i * 500).ms, duration: 1500.ms, curve: Curves.easeOut)
                  .fadeOut(delay: (i * 500).ms, duration: 1500.ms),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent,
              boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.5), blurRadius: 30, spreadRadius: 4)],
            ),
            child: ringing
                ? const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF0A150F), size: 54)
                    .animate(onPlay: (c) => c.repeat())
                    .shake(hz: 5, rotation: 0.12, duration: 700.ms)
                    .then(delay: 300.ms)
                : Icon(
                    ok ? Icons.graphic_eq_rounded : Icons.signal_cellular_off_rounded,
                    key: ValueKey(ok),
                    color: const Color(0xFF0A150F),
                    size: 54,
                  ).animate().scaleXY(begin: 0.5, end: 1, curve: Curves.easeOutBack, duration: 350.ms),
          ),
        ],
      ),
    );
  }
}

/// The spoken alert, appearing word by word like live captions, above a
/// small animated voice waveform.
class _Transcript extends StatelessWidget {
  final String text;
  const _Transcript({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AgriShieldRadii.card),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < 12; i++)
                Container(
                  margin: const EdgeInsets.only(right: 3),
                  width: 3,
                  height: 18,
                  decoration: BoxDecoration(color: AgriShieldBrand.mint, borderRadius: BorderRadius.circular(2)),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scaleY(begin: 0.25, end: 1, delay: ((i * 73) % 400).ms, duration: 380.ms, curve: Curves.easeInOut),
              const SizedBox(width: 8),
              Text('SPEAKING', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 10),
          Text('"$text"', style: const TextStyle(color: Colors.white, fontSize: 17, height: 1.4, fontWeight: FontWeight.w600)),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
  }
}
