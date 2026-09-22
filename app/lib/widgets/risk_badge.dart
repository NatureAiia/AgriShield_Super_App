import 'package:flutter/material.dart';
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
    final bg = Color.alphaBlend(dot.withOpacity(context.isDark ? 0.22 : 0.14), context.colors.surface);
    // The vivid dot color alone measures well under WCAG AA on its own
    // pale tint (checked numerically) — text uses a separately-checked
    // darker/lighter variant instead, see AgriShieldStatus.text().
    final textColor = AgriShieldStatus.text(dot, context.isDark);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AgriShieldRadii.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(_labels[risk]!, style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 13)),
        ],
      ),
    );
  }
}
