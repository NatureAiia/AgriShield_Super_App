import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/storage_reading.dart';
import '../services/sensor_service.dart';
import '../theme.dart';
import '../widgets/animated_count.dart';
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
                    Expanded(
                      child: _SensorCard(label: 'OUTSIDE COOLER', reading: outside)
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: -0.1, end: 0, curve: Curves.easeOutCubic),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SensorCard(label: 'INSIDE ZEER COOLER', reading: inside, highlight: true)
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 400.ms)
                          .slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
                    ),
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
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: context.colors.secondary.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.water_drop, size: 20, color: context.colors.secondary),
                                )
                                    .animate(onPlay: (c) => c.repeat(reverse: true))
                                    .scaleXY(begin: 1.0, end: 1.12, duration: 900.ms, curve: Curves.easeInOut),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'COOLER WORKING LIVE',
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.6,
                                            color: context.colors.onSurface.withValues(alpha: 0.6)),
                                      ),
                                      AnimatedCount(
                                        value: gap,
                                        format: (v) => '${v.toStringAsFixed(1)}°C cooler inside',
                                        style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                            color: context.colors.secondary),
                                      ),
                                      Text(
                                        'Real evaporation — watch it grow while I talk.',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: context.colors.onSurface.withValues(alpha: 0.6)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
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
                              AnimatedCount(
                                value: inside.co2Ppm,
                                format: (v) => '${v.toStringAsFixed(0)} ppm',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: inside.co2High ? context.colors.error : context.colors.onSurface,
                                ),
                              ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              inside == null
                                  ? 'Waiting for the sensor box… • Kumirira bhokisi…'
                                  : "It's warmer than usual, so your crop is spoiling faster — about "
                                      "${inside.estimatedShelfLifeHours.toStringAsFixed(0)} hours of good condition left.",
                              style: TextStyle(color: context.colors.onSurface),
                            ),
                            if (inside != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Kunopisa, saka chibage chiri kukurumidza kuparara — chasara nemaawa ~${inside.estimatedShelfLifeHours.toStringAsFixed(0)} chakanaka.',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      color: context.colors.onSurface.withValues(alpha: 0.65)),
                                ),
                              ),
                          ],
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
    final temp = reading?.temperatureC ?? 27;
    // Map 15–40°C to 0–1 fill for the vertical thermometer bar.
    final fill = ((temp - 15) / 25).clamp(0.05, 1.0);
    final barColor = highlight ? onHighlight : (temp >= 30 ? const Color(0xFFEF4444) : context.colors.secondary);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? context.colors.primary : context.colors.surface,
        borderRadius: BorderRadius.circular(AgriShieldRadii.card),
        border: Border.all(color: context.colors.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Vertical thermometer — the physical wow judges see from 5 meters.
          Container(
            width: 10,
            height: 76,
            decoration: BoxDecoration(
              color: (highlight ? onHighlight : context.colors.onSurface).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                width: 10,
                height: 76 * fill,
                decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: highlight ? onHighlight.withValues(alpha: 0.75) : context.colors.onSurface.withValues(alpha: 0.6),
                    )),
                const SizedBox(height: 4),
                reading == null
                    ? Text(
                        '—',
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: highlight ? onHighlight : context.colors.onSurface),
                      )
                    : AnimatedCount(
                        value: reading!.temperatureC,
                        format: (v) => '${v.toStringAsFixed(0)}°C',
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: highlight ? onHighlight : context.colors.onSurface),
                      ),
                if (reading != null)
                  AnimatedCount(
                    value: reading!.humidityPercent,
                    format: (v) => '${v.toStringAsFixed(0)}% humidity',
                    style: TextStyle(fontSize: 12, color: highlight ? onHighlight.withValues(alpha: 0.75) : context.colors.onSurface.withValues(alpha: 0.6)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
