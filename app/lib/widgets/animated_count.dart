import 'package:flutter/material.dart';

/// Counts up/down to a new numeric value instead of snapping to it — the
/// small "alive" motion that instant-swap text lacks. `format` controls
/// units/decimals; relies on [TweenAnimationBuilder]'s built-in retargeting
/// (it animates from the last rendered value, not from `value` itself, so
/// this keeps animating smoothly through rapid live-sensor updates).
class AnimatedCount extends StatelessWidget {
  final double value;
  final String Function(double) format;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCount({
    super.key,
    required this.value,
    required this.format,
    this.style,
    this.duration = const Duration(milliseconds: 700),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: value, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animated, child) => Text(format(animated), style: style),
    );
  }
}
