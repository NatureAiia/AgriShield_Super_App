import 'package:flutter/material.dart';
import '../models/storage_reading.dart';

class RiskBadge extends StatelessWidget {
  final MoldRisk risk;
  const RiskBadge({super.key, required this.risk});

  static const _labels = {
    MoldRisk.low: 'Low mold risk',
    MoldRisk.moderate: 'Moderate mold risk',
    MoldRisk.high: 'High mold risk',
  };

  static const _colors = {
    MoldRisk.low: Color(0xFF166534),
    MoldRisk.moderate: Color(0xFF92400E),
    MoldRisk.high: Color(0xFF991B1B),
  };

  static const _backgrounds = {
    MoldRisk.low: Color(0xFFDCF5E4),
    MoldRisk.moderate: Color(0xFFFEF3C7),
    MoldRisk.high: Color(0xFFFEE2E2),
  };

  @override
  Widget build(BuildContext context) {
    final fg = _colors[risk]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: _backgrounds[risk], borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(_labels[risk]!, style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 13)),
        ],
      ),
    );
  }
}
