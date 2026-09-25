import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/farmer.dart';
import '../models/storage_reading.dart';
import '../services/messaging_service.dart';
import '../services/sensor_service.dart';
import '../theme.dart';
import '../widgets/animated_count.dart';
import '../widgets/app_card.dart';
import '../widgets/risk_badge.dart';
import '../widgets/shimmer_box.dart';

/// Home dashboard — a dense, bento-style grid of the real V1 signals
/// (shelf life, mold risk, CO2, cooler effect), not a decorative landing
/// screen. Every tile is real, computed data; nothing here anticipates
/// V2/V3 features (weather, prices, market alerts) that don't exist yet —
/// same honesty principle as the rest of the roadmap.
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
        backgroundColor: sent ? context.colors.secondary : context.colors.error,
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
      stream: widget.sensorService.outsideReadings(),
      builder: (context, outsideSnapshot) {
        return StreamBuilder<StorageReading>(
          stream: widget.sensorService.insideCoolerReadings(),
          builder: (context, insideSnapshot) {
            final outside = outsideSnapshot.data;
            final reading = insideSnapshot.data;
            final gap = (outside != null && reading != null) ? outside.temperatureC - reading.temperatureC : null;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Good morning,', style: TextStyle(color: context.colors.secondary, fontSize: 14))
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
                Text(widget.farmer.name, style: context.text.headlineSmall)
                    .animate()
                    .fadeIn(delay: 60.ms, duration: 350.ms)
                    .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [
                    _BentoTile(
                      icon: Icons.eco,
                      label: 'SHELF LIFE — ${widget.farmer.crop.toUpperCase()}',
                      valueWidget: reading == null
                          ? null
                          : AnimatedCount(
                              value: reading.estimatedShelfLifeHours,
                              format: (v) => '${v.toStringAsFixed(0)}h',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: context.colors.onSurface),
                            ),
                      accent: context.colors.secondary,
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
                    _BentoTile(
                      icon: Icons.warning_amber_rounded,
                      label: 'MOLD RISK',
                      valueWidget: reading == null ? null : RiskBadge(key: ValueKey(reading.moldRisk), risk: reading.moldRisk),
                      accent: context.colors.error,
                    ).animate().fadeIn(delay: 80.ms, duration: 400.ms).slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
                    _BentoTile(
                      icon: Icons.air,
                      label: 'CO2 (INSIDE)',
                      valueWidget: reading == null
                          ? null
                          : AnimatedCount(
                              value: reading.co2Ppm,
                              format: (v) => '${v.toStringAsFixed(0)} ppm',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: reading.co2High ? context.colors.error : context.colors.onSurface,
                              ),
                            ),
                      accent: reading?.co2High == true ? context.colors.error : context.colors.secondary,
                    ).animate().fadeIn(delay: 160.ms, duration: 400.ms).slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
                    _BentoTile(
                      icon: Icons.water_drop,
                      label: 'COOLER EFFECT',
                      valueWidget: gap == null
                          ? null
                          : AnimatedCount(
                              value: gap,
                              format: (v) => '-${v.toStringAsFixed(1)}°C',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: context.colors.onSurface),
                            ),
                      accent: context.colors.secondary,
                    ).animate().fadeIn(delay: 240.ms, duration: 400.ms).slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: reading == null || _sendingAlert ? null : () => _sendDemoAlert(reading),
                    icon: _sendingAlert
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.onSecondary),
                          )
                        : const Icon(Icons.phone_forwarded),
                    label: Text(_sendingAlert ? 'Calling farmer…' : 'Trigger farmer alert now'),
                  ),
                ).animate().fadeIn(delay: 320.ms, duration: 400.ms).slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
              ],
            );
          },
        );
      },
    );
  }
}

class _BentoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? valueWidget;
  final Color accent;

  const _BentoTile({
    required this.icon,
    required this.label,
    required this.accent,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: accent, size: 20),
          Text(label, style: context.text.labelSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(position: Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(animation), child: child),
            ),
            child: valueWidget ??
                ShimmerBox(key: const ValueKey('loading'), width: 56, height: 22, borderRadius: BorderRadius.circular(4)),
          ),
        ],
      ),
    );
  }
}
