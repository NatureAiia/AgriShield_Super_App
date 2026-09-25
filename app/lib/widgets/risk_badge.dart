import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/storage_reading.dart';
import '../theme.dart';

class RiskBadge extends StatelessWidget {
  final MoldRisk risk;
  const RiskBadge({super.key, required this.risk});

  static const _labels = {
    MoldRisk.low: 'Low mold risk',
    MoldRisk.moderate: 'Moderate mold risk',
    MoldRisk.high: 'High mold risk',
  };

  static const _colors = {
    MoldRisk.low: AgriShieldStatus.low,
    MoldRisk.moderate: AgriShieldStatus.moderate,
    MoldRisk.high: AgriShieldStatus.high,
  };

  @override
  Widget build(BuildContext context) {
    final dot = _colors[risk]!;
    // A flat tint of the status color over the current surface reads
    // correctly in both themes without a separate light/dark color table.
    final bg = Color.alphaBlend(dot.withValues(alpha: context.isDark ? 0.22 : 0.14), context.colors.surface);
    // The vivid dot color alone measures well under WCAG AA on its own
    // pale tint (checked numerically) — text uses a separately-checked
    // darker/lighter variant instead, see AgriShieldStatus.text().
    final textColor = AgriShieldStatus.text(dot, context.isDark);

    final badge = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AgriShieldRadii.pill),
        boxShadow: risk == MoldRisk.high
            ? [BoxShadow(color: dot.withValues(alpha: 0.45), blurRadius: 10, spreadRadius: 0.5)]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(_labels[risk]!, style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 13)),
        ],
      ),
    );

    // High mold risk gets a slow, deliberate pulse — an urgency cue that
    // reads as "pay attention" without being an alarming flashing red.
    if (risk != MoldRisk.high) return badge;
    return badge
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 1.0, end: 1.04, duration: 900.ms, curve: Curves.easeInOut);
  }
}
