import 'package:flutter/material.dart';
import '../models/farmer.dart';
import '../models/storage_reading.dart';
import '../services/messaging_service.dart';
import '../services/sensor_service.dart';
import '../theme.dart';
import '../widgets/app_card.dart';
import '../widgets/risk_badge.dart';

class HomeScreen extends StatefulWidget {
  final Farmer farmer;
  final SensorService sensorService;
  final MessagingService messagingService;

  const HomeScreen({
    super.key,
    required this.farmer,
    required this.sensorService,
    required this.messagingService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _sendingAlert = false;

  Future<void> _sendDemoAlert(StorageReading? reading) async {
    if (reading == null || _sendingAlert) return;
    setState(() => _sendingAlert = true);
    final message = reading.moldRisk != MoldRisk.low
        ? 'Move your ${widget.farmer.crop.toLowerCase()} to a cooler, drier place to reduce mold risk.'
        : 'Your ${widget.farmer.crop.toLowerCase()} has about ${reading.estimatedShelfLifeHours.toStringAsFixed(0)} '
            'hours of good condition left — sell today.';
    final sent = await widget.messagingService.sendAlert(farmer: widget.farmer, message: message);
    if (!mounted) return;
    setState(() => _sendingAlert = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: sent ? AgriShieldColors.accent : AgriShieldColors.alert,
        content: Text(
          sent
              ? '📞 Alert sent over Africa\'s Talking: "$message"'
              : 'Could not reach the backend — alert queued, will send once connected.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StorageReading>(
      stream: widget.sensorService.insideCoolerReadings(),
      builder: (context, snapshot) {
        final reading = snapshot.data;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Good morning,', style: TextStyle(color: AgriShieldColors.accent, fontSize: 14)),
            Text(widget.farmer.name,
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
                        Text('SHELF LIFE — ${widget.farmer.crop.toUpperCase()}',
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
            if (reading != null)
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  RiskBadge(risk: reading.moldRisk),
                  if (reading.co2High)
                    const Text(
                      '⚠︎ CO2 spike — early spoilage signal',
                      style: TextStyle(fontSize: 11, color: AgriShieldColors.alert, fontWeight: FontWeight.w700),
                    ),
                ],
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: reading == null || _sendingAlert ? null : () => _sendDemoAlert(reading),
                icon: _sendingAlert
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.phone_forwarded),
                label: Text(_sendingAlert ? 'Calling farmer…' : 'Trigger farmer alert now'),
              ),
            ),
          ],
        );
      },
    );
  }
}
