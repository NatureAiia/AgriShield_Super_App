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
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  child: gap == null
                      ? const SizedBox(width: double.infinity)
                      : Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: AppCard(
                            child: Row(
                              children: [
                                Icon(Icons.water_drop, size: 18, color: context.colors.secondary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'The cooler is working — ${gap.toStringAsFixed(1)}°C cooler inside than outside right now, real evaporation, honestly reported.',
                                    style: TextStyle(fontSize: 12, color: context.colors.onSurface),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                if (inside != null) ...[
                  const SizedBox(height: 10),
                  AppCard(
                    child: Row(
                      children: [
                        Icon(Icons.air, size: 18, color: context.colors.secondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('CO2 (INSIDE)', style: context.text.labelSmall),
                              Text('${inside.co2Ppm.toStringAsFixed(0)} ppm',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: inside.co2High ? context.colors.error : context.colors.onSurface,
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
                      Icon(Icons.eco, color: context.colors.secondary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          inside == null
                              ? 'Waiting for the sensor box…'
                              : "It's warmer than usual, so your crop is spoiling faster — about "
                                  "${inside.estimatedShelfLifeHours.toStringAsFixed(0)} hours of good condition left.",
                          style: TextStyle(color: context.colors.onSurface),
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
    final onHighlight = context.colors.onPrimary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? context.colors.primary : context.colors.surface,
        borderRadius: BorderRadius.circular(AgriShieldRadii.card),
        border: Border.all(color: context.colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: highlight ? onHighlight.withOpacity(0.75) : context.colors.onSurface.withOpacity(0.6),
              )),
          const SizedBox(height: 4),
          Text(
            reading == null ? '—' : '${reading!.temperatureC.toStringAsFixed(0)}°C',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: highlight ? onHighlight : context.colors.onSurface),
          ),
          Text(
            reading == null ? '' : '${reading!.humidityPercent.toStringAsFixed(0)}% humidity',
            style: TextStyle(fontSize: 12, color: highlight ? onHighlight.withOpacity(0.75) : context.colors.onSurface.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}
