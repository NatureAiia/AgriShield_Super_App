import 'package:flutter/material.dart';
import '../models/storage_reading.dart';
import '../services/sensor_service.dart';
import '../theme.dart';
import '../widgets/app_card.dart';

class StorageScreen extends StatelessWidget {
  final SensorService sensorService;
  const StorageScreen({super.key, required this.sensorService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StorageReading>(
      stream: sensorService.readings(),
      builder: (context, snapshot) {
        final reading = snapshot.data;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TEMPERATURE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey)),
                        Text(
                          reading == null ? '—' : '${reading.temperatureC.toStringAsFixed(0)}°C',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AgriShieldColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('HUMIDITY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey)),
                        Text(
                          reading == null ? '—' : '${reading.humidityPercent.toStringAsFixed(0)}%',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AgriShieldColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.eco, color: AgriShieldColors.accent, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      reading == null
                          ? 'Waiting for the sensor box…'
                          : "It's warmer than usual, so your crop is spoiling faster — about "
                              "${reading.estimatedShelfLifeHours.toStringAsFixed(0)} hours of good condition left.",
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
  }
}
