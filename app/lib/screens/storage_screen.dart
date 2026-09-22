import 'package:flutter/material.dart';
import '../models/storage_reading.dart';
import '../services/sensor_service.dart';
import '../theme.dart';
import '../widgets/app_card.dart';

/// The Part 1 demo screen — built around the vision doc's own "Moment 1"
/// and "Moment 2" (docs/roadmap/V1_HACKATHON_DEMO.md): two live
/// thermometers side by side (outside vs. inside the zeer cooler), and the
/// gap between them visibly widening as the cooler keeps working.
class StorageScreen extends StatelessWidget {
  final SensorService sensorService;
  const StorageScreen({super.key, required this.sensorService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StorageReading>(
      stream: sensorService.outsideReadings(),
      builder: (context, outsideSnapshot) {
        return StreamBuilder<StorageReading>(
          stream: sensorService.insideCoolerReadings(),
          builder: (context, insideSnapshot) {
            final outside = outsideSnapshot.data;
            final inside = insideSnapshot.data;
            final gap = (outside != null && inside != null) ? outside.temperatureC - inside.temperatureC : null;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(child: _SensorCard(label: 'OUTSIDE COOLER', reading: outside)),
                    const SizedBox(width: 12),
                    Expanded(child: _SensorCard(label: 'INSIDE ZEER COOLER', reading: inside, highlight: true)),
                  ],
                ),
                if (gap != null) ...[
                  const SizedBox(height: 10),
                  AppCard(
                    child: Row(
                      children: [
                        const Icon(Icons.water_drop, size: 18, color: AgriShieldColors.accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'The cooler is working — ${gap.toStringAsFixed(1)}°C cooler inside than outside right now, real evaporation, honestly reported.',
                            style: const TextStyle(fontSize: 12, color: AgriShieldColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (inside != null) ...[
                  const SizedBox(height: 10),
                  AppCard(
                    child: Row(
                      children: [
                        const Icon(Icons.air, size: 18, color: AgriShieldColors.accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('CO2 (INSIDE)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey)),
                              Text('${inside.co2Ppm.toStringAsFixed(0)} ppm',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: inside.co2High ? AgriShieldColors.alert : AgriShieldColors.primary,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.eco, color: AgriShieldColors.accent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          inside == null
                              ? 'Waiting for the sensor box…'
                              : "It's warmer than usual, so your crop is spoiling faster — about "
                                  "${inside.estimatedShelfLifeHours.toStringAsFixed(0)} hours of good condition left.",
                          style: const TextStyle(color: AgriShieldColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SensorCard extends StatelessWidget {
  final String label;
  final StorageReading? reading;
  final bool highlight;

  const _SensorCard({required this.label, required this.reading, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? AgriShieldColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AgriShieldColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: highlight ? Colors.white70 : Colors.grey)),
          const SizedBox(height: 4),
          Text(
            reading == null ? '—' : '${reading!.temperatureC.toStringAsFixed(0)}°C',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: highlight ? Colors.white : AgriShieldColors.primary),
          ),
          Text(
            reading == null ? '' : '${reading!.humidityPercent.toStringAsFixed(0)}% humidity',
            style: TextStyle(fontSize: 12, color: highlight ? Colors.white70 : Colors.grey),
          ),
        ],
      ),
    );
  }
}
