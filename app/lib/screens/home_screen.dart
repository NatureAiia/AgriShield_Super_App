import 'package:flutter/material.dart';
import '../models/farmer.dart';
import '../models/storage_reading.dart';
import '../services/sensor_service.dart';
import '../theme.dart';
import '../widgets/app_card.dart';
import '../widgets/risk_badge.dart';

class HomeScreen extends StatelessWidget {
  final Farmer farmer;
  final SensorService sensorService;

  const HomeScreen({super.key, required this.farmer, required this.sensorService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StorageReading>(
      stream: sensorService.readings(),
      builder: (context, snapshot) {
        final reading = snapshot.data;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Good morning,', style: TextStyle(color: AgriShieldColors.accent, fontSize: 14)),
            Text(farmer.name,
                style: const TextStyle(color: AgriShieldColors.primary, fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            AppCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AgriShieldColors.background, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.eco, color: AgriShieldColors.accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SHELF LIFE — ${farmer.crop.toUpperCase()}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey)),
                        Text(
                          reading == null
                              ? 'Reading sensor…'
                              : '${reading.estimatedShelfLifeHours.toStringAsFixed(0)} hours left',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AgriShieldColors.primary),
                        ),
                        const Text('Sell or move to a cooler spot today', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (reading != null) RiskBadge(risk: reading.moldRisk),
          ],
        );
      },
    );
  }
}
