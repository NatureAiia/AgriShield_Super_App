import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';

/// One beat of the 60-second stage tour: which tab to show, what the room
/// reads, how long to hold before auto-advancing.
class DemoStep {
  final int tab;
  final String kicker;
  final String title;
  final String caption;
  final int seconds;

  const DemoStep({
    required this.tab,
    required this.kicker,
    required this.title,
    required this.caption,
    required this.seconds,
  });
}

/// The 60s arc from the demo script: story → cooler proof → offline scan →
/// district map → live call. Tab indices match _AgriShieldHomeState._titles:
/// 0 Home, 1 Storage, 2 Scan, 3 Recommend, 4 Map, 5 Profile.
const kDemoScript = [
  DemoStep(
    tab: 0,
    kicker: '1 / 5 · LIVE STORY',
    title: '500kg maize at stake — last year 40% lost.',
    caption: 'Mangwanani — watch the cooler gap grow live while I talk. (Moment 1)',
    seconds: 12,
  ),
  DemoStep(
    tab: 1,
    kicker: '2 / 5 · COOLER PROOF',
    title: '+Nh extra shelf life, with no electricity.',
    caption: 'Outside vs inside zeer cooler, side by side — real evaporation, not a slide.',
    seconds: 12,
  ),
  DemoStep(
    tab: 2,
    kicker: '3 / 5 · OFFLINE SCAN',
    title: 'On your phone · no internet needed.',
    caption: 'Tap the camera — Wi-Fi OFF still works. First opinion, not a final answer.',
    seconds: 14,
  ),
  DemoStep(
    tab: 4,
    kicker: '4 / 5 · DISTRICT VIEW',
    title: 'Your plot marked YOU — free Sentinel-2.',
    caption: 'Radar sweep once, then tap any zone. Green healthy, red drought risk.',
    seconds: 10,
  ),
  DemoStep(
    tab: 0,
    kicker: '5 / 5 · LIVE CALL',
    title: 'A phone actually rings — in Shona + English.',
    caption: 'Tap “Fonera murimi izvozvi • Call the farmer” — voice + SMS, works on any phone.',
    seconds: 12,
  ),
];

/// Projector-safe caption banner pinned above the demo tab. Shows progress,
/// Next/Skip, and a big End target — the presenter never hunts for controls.
class DemoTourOverlay extends StatelessWidget {
  final int stepIndex;
  final VoidCallback onNext;
  final VoidCallback onEnd;

  const DemoTourOverlay({
    super.key,
    required this.stepIndex,
    required this.onNext,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    final step = kDemoScript[stepIndex];
    final last = stepIndex == kDemoScript.length - 1;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2A1E),
        borderRadius: BorderRadius.circular(AgriShieldRadii.card),
        border: Border.all(color: AgriShieldBrand.mint.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AgriShieldBrand.amberBright,
                  borderRadius: BorderRadius.circular(AgriShieldRadii.pill),
                ),
                child: Text(step.kicker,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 0.5)),
              ),
              const Spacer(),
              Text('${step.seconds}s auto',
                  style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Text(step.title,
              style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900, height: 1.2)),
          const SizedBox(height: 4),
          Text(step.caption, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, height: 1.4)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey(stepIndex),
                    tween: Tween(begin: 0, end: (stepIndex + 1) / kDemoScript.length),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => LinearProgressIndicator(
                      value: v,
                      minHeight: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(AgriShieldBrand.amberBright),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: onNext,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text(last ? 'Replay' : 'Next ›', style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              ElevatedButton(
                onPressed: onEnd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AgriShieldBrand.amberBright,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: const Text('End', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ],
      ),
    ).animate(key: ValueKey(stepIndex)).fadeIn(duration: 250.ms).slideY(begin: -0.15, end: 0, curve: Curves.easeOutCubic);
  }
}
