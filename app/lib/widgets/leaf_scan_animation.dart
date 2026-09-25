import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';

/// Shown while Part 2's on-device check runs: a leaf under a sweeping scan
/// line, corner brackets like a camera viewfinder, and plain-language
/// steps ticking off (the screen's own badge already says it's offline). The steps describe what any leaf check does; they
/// don't claim more than the model underneath.
class LeafScanAnimation extends StatelessWidget {
  const LeafScanAnimation({super.key});

  static const _steps = ['Finding the leaf', 'Looking for disease signs', 'Preparing advice'];

  @override
  Widget build(BuildContext context) {
    final accent = context.colors.secondary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 170,
          height: 170,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.eco_rounded, size: 120, color: accent.withValues(alpha: 0.85))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(begin: 0.96, end: 1.04, duration: 900.ms, curve: Curves.easeInOut),
              ..._corners(accent),
              // The scan line: a bright bar with a soft trailing glow.
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AgriShieldBrand.mint,
                    boxShadow: [BoxShadow(color: AgriShieldBrand.mint.withValues(alpha: 0.8), blurRadius: 14, spreadRadius: 2)],
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(begin: 8, end: 160, duration: 1100.ms, curve: Curves.easeInOut),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < _steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, size: 18, color: accent)
                    .animate()
                    .scaleXY(begin: 0, end: 1, delay: (350 + i * 380).ms, duration: 250.ms, curve: Curves.easeOutBack),
                const SizedBox(width: 8),
                Text(_steps[i], style: TextStyle(color: context.colors.onSurface, fontWeight: FontWeight.w600)),
              ],
            ).animate().fadeIn(delay: (i * 380).ms, duration: 250.ms),
          ),
      ],
    );
  }

  List<Widget> _corners(Color color) {
    Widget corner(Alignment a) {
      final top = a.y < 0;
      final left = a.x < 0;
      final side = BorderSide(color: color, width: 4);
      return Align(
        alignment: a,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            border: Border(
              top: top ? side : BorderSide.none,
              bottom: top ? BorderSide.none : side,
              left: left ? side : BorderSide.none,
              right: left ? BorderSide.none : side,
            ),
          ),
        ),
      );
    }

    return [
      corner(Alignment.topLeft),
      corner(Alignment.topRight),
      corner(Alignment.bottomLeft),
      corner(Alignment.bottomRight),
    ];
  }
}
