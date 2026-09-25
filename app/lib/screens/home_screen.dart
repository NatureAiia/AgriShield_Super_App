import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/farmer.dart';
import '../models/storage_reading.dart';
import '../services/messaging_service.dart';
import '../services/sensor_service.dart';
import '../theme.dart';
import '../widgets/animated_count.dart';
import '../widgets/app_card.dart';
import '../widgets/coming_soon_carousel.dart';
import '../widgets/incoming_call_overlay.dart';
import 'farmer_story_screen.dart';
import '../widgets/risk_badge.dart';
import '../widgets/shimmer_box.dart';

/// Home dashboard — a hero card for the cooler's effect and a dense,
/// bento-style grid of the real V1 signals (shelf life, mold risk, CO2,
/// cooler effect). Every number above the fold is real, computed data.
/// V2/V3 features (weather, prices, insurance…) appear only in the
/// "What's coming next" row at the bottom, each badged SOON — same
/// honesty principle as the rest of the roadmap: roadmap, said plainly.
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
    await showIncomingCallOverlay(
      context,
      farmerName: widget.farmer.name,
      message: message,
      send: () => widget.messagingService.sendAlert(farmer: widget.farmer, message: message),
    );
    if (!mounted) return;
    setState(() => _sendingAlert = false);
  }

  // Shona first, English after — the farmer's own greeting, then the
  // translation (Mangwanani / Masikati / Manheru).
  static String _greeting(DateTime now) {
    if (now.hour < 12) return 'Mangwanani · Good morning,';
    if (now.hour < 17) return 'Masikati · Good afternoon,';
    return 'Manheru · Good evening,';
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
                Text(_greeting(DateTime.now()), style: TextStyle(color: context.colors.secondary, fontSize: 14))
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
                Text(widget.farmer.name, style: context.text.headlineSmall)
                    .animate()
                    .fadeIn(delay: 60.ms, duration: 350.ms)
                    .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 16),
                _DoThisNow(crop: widget.farmer.crop, reading: reading)
                    .animate()
                    .fadeIn(delay: 90.ms, duration: 400.ms)
                    .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 12),
                _CoolerHero(crop: widget.farmer.crop, outside: outside, inside: reading)
                    .animate()
                    .fadeIn(delay: 120.ms, duration: 450.ms)
                    .scaleXY(begin: 0.96, end: 1, curve: Curves.easeOutCubic),
                const SizedBox(height: 12),
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
                    label: Text(_sendingAlert ? 'Calling farmer…' : 'Call the farmer now'),
                  ),
                ).animate().fadeIn(delay: 320.ms, duration: 400.ms).slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
                const SizedBox(height: 12),
                _StoryLink(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FarmerStoryScreen())),
                ).animate().fadeIn(delay: 380.ms, duration: 400.ms),
                const SizedBox(height: 24),
                const ComingSoonCarousel(),
                const SizedBox(height: 8),
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

/// The one number a judge should remember: how much longer the crop lasts
/// inside the zeer cooler than outside it, from the same live readings and
/// shelf-life estimate as the tiles below (StorageReading).
class _CoolerHero extends StatelessWidget {
  final String crop;
  final StorageReading? outside;
  final StorageReading? inside;

  const _CoolerHero({required this.crop, required this.outside, required this.inside});

  @override
  Widget build(BuildContext context) {
    final out = outside?.estimatedShelfLifeHours;
    final ins = inside?.estimatedShelfLifeHours;
    final saved = (out != null && ins != null) ? (ins - out).clamp(0.0, 999.0) : null;
    final maxHours = [out ?? 1, ins ?? 1, 1.0].reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AgriShieldBrand.forestGreen, AgriShieldBrand.leafGreen, Color(0xFF40916C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AgriShieldRadii.card),
        boxShadow: [
          BoxShadow(color: AgriShieldBrand.leafGreen.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -8,
            top: -8,
            child: Icon(Icons.shield_rounded, size: 96, color: Colors.white.withValues(alpha: 0.08))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 0.95, end: 1.08, duration: 2200.ms, curve: Curves.easeInOut),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: AgriShieldBrand.mint, shape: BoxShape.circle),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeOut(duration: 900.ms),
                  const SizedBox(width: 6),
                  Text('LIVE · ZEER COOLER',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  saved == null
                      ? const SizedBox(height: 48, width: 90)
                      : AnimatedCount(
                          value: saved,
                          format: (v) => '+${v.toStringAsFixed(0)}h',
                          duration: const Duration(milliseconds: 1200),
                          style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900, height: 1),
                        ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'extra shelf life for your ${crop.toLowerCase()}, with no electricity',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, height: 1.3),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _HeroBar(label: 'Outside', hours: out, fraction: (out ?? 0) / maxHours, color: const Color(0xFFFCD34D)),
              const SizedBox(height: 8),
              _HeroBar(label: 'In cooler', hours: ins, fraction: (ins ?? 0) / maxHours, color: AgriShieldBrand.mint),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroBar extends StatelessWidget {
  final String label;
  final double? hours;
  final double fraction;
  final Color color;

  const _HeroBar({required this.label, required this.hours, required this.fraction, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12, fontWeight: FontWeight.w700)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AgriShieldRadii.pill),
            child: Stack(
              children: [
                Container(height: 10, color: Colors.white.withValues(alpha: 0.15)),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: fraction.clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => FractionallySizedBox(
                    widthFactor: v,
                    child: Container(height: 10, color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            hours == null ? '–' : '${hours!.toStringAsFixed(0)}h',
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}


/// One plain sentence of advice from the live reading — the farmer reads
/// what to do, not a number to interpret. Tone follows the same three mold
/// tiers as the risk badge; PICS bag pricing is the roadmap's own sourced
/// figure (docs/roadmap/V1_HACKATHON_DEMO.md, Part 1).
class _DoThisNow extends StatelessWidget {
  final String crop;
  final StorageReading? reading;
  const _DoThisNow({required this.crop, required this.reading});

  @override
  Widget build(BuildContext context) {
    final r = reading;
    final c = crop.toLowerCase();
    final (Color dot, IconData icon, String title, String detail) = switch (r?.moldRisk) {
      null => (AgriShieldStatus.low, Icons.hourglass_top_rounded, 'Checking your store…', 'The first reading is on its way.'),
      MoldRisk.high => (
          AgriShieldStatus.high,
          Icons.priority_high_rounded,
          'Act today: move your $c',
          'Put it into a sealed PICS bag (about \$2–3), or somewhere cooler and drier, to stop mold.',
        ),
      MoldRisk.moderate => (
          AgriShieldStatus.moderate,
          Icons.visibility_rounded,
          'Check your $c today',
          'It is getting warm or damp. If it gets worse, we will call you straight away.',
        ),
      MoldRisk.low => (
          AgriShieldStatus.low,
          Icons.check_rounded,
          'Your $c is safe',
          'Nothing to do right now. We will warn you if that changes.',
        ),
    };
    final textColor = AgriShieldStatus.text(dot, context.isDark);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color.alphaBlend(dot.withValues(alpha: context.isDark ? 0.22 : 0.14), context.colors.surface),
        borderRadius: BorderRadius.circular(AgriShieldRadii.card),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 22),
          )
              .animate(key: ValueKey(title), onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1, end: 1.08, duration: 900.ms, curve: Curves.easeInOut),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Column(
                key: ValueKey(title),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WHAT TO DO NOW', style: context.text.labelSmall?.copyWith(color: textColor)),
                  const SizedBox(height: 2),
                  Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: textColor)),
                  const SizedBox(height: 2),
                  Text(detail, style: TextStyle(fontSize: 13, height: 1.35, color: textColor)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryLink extends StatelessWidget {
  final VoidCallback onTap;
  const _StoryLink({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AgriShieldRadii.card),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AgriShieldRadii.card),
          border: Border.all(color: context.colors.outline),
        ),
        child: Row(
          children: [
            Icon(Icons.play_circle_fill_rounded, size: 34, color: context.colors.secondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How AgriShield helps you', style: TextStyle(fontWeight: FontWeight.w800, color: context.colors.onSurface)),
                  Text('Easier, cheaper, and on any phone — in 4 short pages',
                      style: TextStyle(fontSize: 12, color: context.colors.onSurface.withValues(alpha: 0.65))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: context.colors.onSurface.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
