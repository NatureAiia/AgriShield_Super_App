import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../widgets/field_art.dart';
import '../../widgets/ui_kit.dart';
import '../farmer_story_screen.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

/// First screen a new install shows — a returning, already-signed-in
/// farmer skips straight past this to the app (see main.dart), matching
/// the research-backed pattern of not re-gating access behind a login
/// screen every launch.
///
/// Full-bleed field illustration, headline, and a slide-to-start button
/// (tap works too — sliding is a bonus, never a requirement).
class LandingScreen extends StatelessWidget {
  final AuthService authService;
  final VoidCallback onAuthenticated;
  final VoidCallback? onToggleTheme;

  const LandingScreen({super.key, required this.authService, required this.onAuthenticated, this.onToggleTheme});

  void _signUp(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SignUpScreen(authService: authService, onAuthenticated: onAuthenticated)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06140D),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const FieldArt(variant: FieldArtVariant.sunrise),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.35, 0.62, 1],
                colors: [Color(0x00000000), Color(0x8C06140D), Color(0xEB040E09)],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      ClipOval(child: Image.asset('assets/branding/logo.jpeg', width: 40, height: 40, fit: BoxFit.cover)),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text('AgriShield',
                            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                      ),
                      if (onToggleTheme != null) ThemeToggleButton(onToggle: onToggleTheme!, onImage: true),
                    ],
                  ).animate().fadeIn(duration: 400.ms),
                  const Spacer(),
                  const Text(
                    "Protecting the Future of\nZimbabwe's Harvests",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 27, height: 1.2, fontWeight: FontWeight.w700),
                  ).animate().fadeIn(delay: 150.ms, duration: 500.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
                  const SizedBox(height: 12),
                  Text(
                    'Storage monitoring, leaf disease screening and satellite field checks — built for smallholder farmers, even with no signal.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.78), fontSize: 13.5, height: 1.55),
                  ).animate().fadeIn(delay: 250.ms, duration: 500.ms),
                  const SizedBox(height: 26),
                  SlideToStart(label: 'Get Started', onDone: () => _signUp(context))
                      .animate()
                      .fadeIn(delay: 350.ms, duration: 500.ms)
                      .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: Colors.white),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SignInScreen(authService: authService, onAuthenticated: onAuthenticated),
                          ),
                        ),
                        child: const Text('I already have an account'),
                      ),
                      Text('·', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
                      TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: Colors.white),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const FarmerStoryScreen(finishLabel: 'Got it')),
                        ),
                        icon: const Icon(Icons.play_circle_outline_rounded, size: 18),
                        label: const Text('How it helps'),
                      ),
                    ],
                  ).animate().fadeIn(delay: 450.ms, duration: 500.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// White pill with a green knob you can drag to the right (or just tap).
class SlideToStart extends StatefulWidget {
  final String label;
  final VoidCallback onDone;
  const SlideToStart({super.key, required this.label, required this.onDone});

  @override
  State<SlideToStart> createState() => _SlideToStartState();
}

class _SlideToStartState extends State<SlideToStart> {
  static const _knob = 52.0;
  static const _pad = 6.0;
  double _dx = 0;

  void _finish() {
    widget.onDone();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _dx = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final maxDx = (c.maxWidth - _knob - _pad * 2).clamp(0.0, double.infinity).toDouble();
      return GestureDetector(
        onTap: _finish,
        onHorizontalDragUpdate: (d) => setState(() => _dx = (_dx + d.delta.dx).clamp(0.0, maxDx).toDouble()),
        onHorizontalDragEnd: (_) {
          if (_dx > maxDx * 0.6) {
            setState(() => _dx = maxDx);
            _finish();
          } else {
            setState(() => _dx = 0);
          }
        },
        child: Container(
          height: _knob + _pad * 2,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(99),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 30, offset: const Offset(0, 12))],
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Center(
                child: Opacity(
                  opacity: maxDx <= 0 ? 1.0 : (1 - _dx / maxDx).clamp(0.0, 1.0).toDouble(),
                  child: Text(widget.label,
                      style: const TextStyle(color: Color(0xFF13261C), fontSize: 15.5, fontWeight: FontWeight.w700)),
                ),
              ),
              Positioned(
                right: 18,
                child: Row(
                  children: [
                    for (var i = 0; i < 3; i++)
                      Align(
                        widthFactor: 0.55,
                        child: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9FB3A7), size: 22)
                            .animate(onPlay: (c) => c.repeat(reverse: true), delay: (i * 200).ms)
                            .fade(begin: 0.3, end: 1, duration: 700.ms),
                      ),
                  ],
                ),
              ),
              AnimatedPositioned(
                duration: Duration(milliseconds: _dx == 0 ? 250 : 0),
                curve: Curves.easeOutBack,
                left: _pad + _dx,
                child: Container(
                  width: _knob,
                  height: _knob,
                  decoration: const BoxDecoration(color: Color(0xFF2E6A4F), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
