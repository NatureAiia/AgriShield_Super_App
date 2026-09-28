import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/drought_status.dart';
import '../models/farmer.dart';
import '../models/satellite_zone.dart';
import '../services/drought_service.dart';
import '../services/satellite_service.dart';
import '../theme.dart';
import '../widgets/app_card.dart';
import '../widgets/shimmer_box.dart';

class SatelliteMapScreen extends StatefulWidget {
  final SatelliteService satelliteService;
  final Farmer farmer;
  final DroughtService droughtService;
  const SatelliteMapScreen({
    super.key,
    required this.satelliteService,
    required this.farmer,
    required this.droughtService,
  });

  @override
  State<SatelliteMapScreen> createState() => _SatelliteMapScreenState();
}

class _SatelliteMapScreenState extends State<SatelliteMapScreen> {
  List<SatelliteZone> _zones = [];
  SatelliteZone? _selected;
  bool _loading = true;
  int _scanId = 0; // bumps on each refresh so the sweep replays
  DroughtStatus? _drought;

  @override
  void initState() {
    super.initState();
    _refresh();
    widget.droughtService.status().then((d) {
      if (!mounted) return;
      setState(() => _drought = d);
    }).catchError((_) {
      // Best-effort — the zone grid still renders without this banner.
    });
  }

  Future<void> _refresh() async {
    final zones = await widget.satelliteService.fetchZones();
    if (!mounted) return;
    setState(() {
      _zones = zones;
      _loading = false;
      _scanId++;
    });
  }

  Future<void> _reportDrought() async {
    final drought = _drought;
    if (drought == null) return;
    try {
      final result = await widget.droughtService.report(
        farmerId: widget.farmer.id,
        district: widget.farmer.location,
        riskLevel: drought.riskLevel,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reported — ticket ${result.ticket}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't submit the report — check your connection.")),
      );
    }
  }

  // Same semantic palette used for mold risk — one consistent color
  // language for "this needs attention" across the whole app.
  Color _colorFor(ZoneStatus status) {
    switch (status) {
      case ZoneStatus.healthy:
        return AgriShieldStatus.low;
      case ZoneStatus.stressed:
        return AgriShieldStatus.moderate;
      case ZoneStatus.droughtRisk:
        return AgriShieldStatus.high;
    }
  }

  String _labelFor(ZoneStatus status) {
    switch (status) {
      case ZoneStatus.healthy:
        return 'Healthy';
      case ZoneStatus.stressed:
        return 'Stressed — watch for dryness';
      case ZoneStatus.droughtRisk:
        return 'Drought risk — check soon';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: context.colors.secondary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        // A scrollable body is required for pull-to-refresh to trigger even
        // when content is shorter than the viewport.
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          // District header — frames the map as TV weather forecast, not tech demo.
          Row(
            children: [
              Icon(Icons.satellite_alt, size: 18, color: context.colors.secondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text('Mashonaland East • Sentinel-2 • 5-day revisit',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.onSurface)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: context.colors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AgriShieldRadii.pill)),
                child: Text('FREE DATA',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: context.colors.secondary)),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms),
          if (_drought != null) ...[
            const SizedBox(height: 10),
            _DroughtBanner(status: _drought!, onReport: _reportDrought).animate().fadeIn(duration: 300.ms),
          ],
          const SizedBox(height: 10),
          if (_loading)
            AppCard(
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                children: List.generate(
                  9,
                  (_) => ShimmerBox(borderRadius: BorderRadius.circular(8), height: double.infinity, width: double.infinity),
                ),
              ),
            ),
          if (!_loading) ...[
            _ScanStatus(key: ValueKey(_scanId)),
            const SizedBox(height: 10),
          ],
          if (!_loading)
            AppCard(
              child: Stack(
                children: [
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    children: [
                      for (var i = 0; i < _zones.length; i++)
                        Builder(builder: (context) {
                          final zone = _zones[i];
                          final selected = _selected?.id == zone.id;
                          return GestureDetector(
                            onTap: () => setState(() => _selected = zone),
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 150),
                              scale: selected ? 0.92 : 1.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _colorFor(zone.status),
                                  borderRadius: BorderRadius.circular(8),
                                  border: zone.isFarmerPlot ? Border.all(color: context.colors.onSurface, width: 3) : null,
                                ),
                                child: zone.isFarmerPlot
                                    ? Center(
                                        child: Container(
                                          // White text directly on a saturated status color
                                          // (green/amber/red) fails WCAG AA on its own
                                          // (checked: 2.1-3.8:1) — a dark backdrop fixes it
                                          // regardless of which status color is underneath.
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.6),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: Colors.white, width: 1.5),
                                          ),
                                          child: const Text('YOU • Mai Moyo',
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10)),
                                        )
                                            .animate(onPlay: (c) => c.repeat(reverse: true))
                                            .scaleXY(begin: 1.0, end: 1.08, duration: 900.ms, curve: Curves.easeInOut),
                                      )
                                    : null,
                              ),
                            ),
                          ).animate().fadeIn(delay: (i * 35).ms, duration: 300.ms).scaleXY(begin: 0.85, end: 1, curve: Curves.easeOutBack);
                        }),
                    ],
                  ),
                  // A one-pass radar sweep over the fresh grid, then gone —
                  // IgnorePointer keeps zone taps working underneath.
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _RadarSweep(key: ValueKey(_scanId)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _legendDot(context, AgriShieldStatus.low, 'Healthy'),
              _legendDot(context, AgriShieldStatus.moderate, 'Stressed'),
              _legendDot(context, AgriShieldStatus.high, 'Drought risk'),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: _selected == null
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text('Tap a zone — your plot is marked YOU.',
                        style: TextStyle(fontSize: 12, color: context.colors.onSurface.withValues(alpha: 0.6))),
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: AppCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 12,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _colorFor(_selected!.status),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_selected!.isFarmerPlot ? 'Your plot — Mai Moyo' : 'Zone ${_selected!.id}',
                                    style: TextStyle(fontWeight: FontWeight.w800, color: context.colors.onSurface)),
                                const SizedBox(height: 2),
                                Text('Status: ${_labelFor(_selected!.status)}',
                                    style: TextStyle(fontSize: 12, color: context.colors.onSurface.withValues(alpha: 0.7))),
                                Text(
                                  _selected!.status == ZoneStatus.healthy
                                      ? 'Advice: keep scouting weekly.'
                                      : 'Advice: check soil moisture, alert neighbours.',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.secondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.1, end: 0),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.colors.onSurface)),
      ],
    );
  }
}

Color _droughtColor(BuildContext context, String riskLevel) {
  switch (riskLevel) {
    case 'Severe':
      return AgriShieldStatus.high;
    case 'Moderate':
      return AgriShieldStatus.moderate;
    case 'Watch':
      return AgriShieldStatus.moderate;
    default:
      return AgriShieldStatus.low;
  }
}

class _DroughtBanner extends StatelessWidget {
  final DroughtStatus status;
  final VoidCallback onReport;
  const _DroughtBanner({required this.status, required this.onReport});

  @override
  Widget build(BuildContext context) {
    final color = _droughtColor(context, status.riskLevel);
    final reportable = status.riskLevel == 'Moderate' || status.riskLevel == 'Severe';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.alphaBlend(color.withValues(alpha: context.isDark ? 0.22 : 0.12), context.colors.surface),
        borderRadius: BorderRadius.circular(AgriShieldRadii.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.grain, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DROUGHT RISK: ${status.riskLevel.toUpperCase()}',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: color)),
                const SizedBox(height: 2),
                Text(status.reason, style: TextStyle(fontSize: 12, color: context.colors.onSurface.withValues(alpha: 0.75))),
              ],
            ),
          ),
          if (reportable)
            TextButton(onPressed: onReport, child: const Text('Report to government')),
        ],
      ),
    );
  }
}

class _RadarSweep extends StatelessWidget {
  const _RadarSweep({super.key});

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      maxWidth: 900,
      maxHeight: 900,
      child: Container(
        width: 900,
        height: 900,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: [
              Colors.transparent,
              Colors.transparent,
              AgriShieldBrand.mint.withValues(alpha: 0.05),
              AgriShieldBrand.mint.withValues(alpha: 0.45),
            ],
            stops: const [0, 0.7, 0.9, 1],
          ),
        ),
      )
          .animate()
          .rotate(begin: 0, end: 2, duration: 2200.ms, curve: Curves.easeInOut)
          .fadeOut(delay: 1900.ms, duration: 400.ms),
    );
  }
}

/// "Scanning district…" with a pulsing dot, flipping to a satellite-sourced
/// done state once the sweep has passed.
class _ScanStatus extends StatefulWidget {
  const _ScanStatus({super.key});

  @override
  State<_ScanStatus> createState() => _ScanStatusState();
}

class _ScanStatusState extends State<_ScanStatus> {
  bool _done = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _done = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colors.secondary;
    return Row(
      children: [
        Icon(Icons.radar_rounded, size: 18, color: color)
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .rotate(begin: -0.03, end: 0.03, duration: 1200.ms),
        const SizedBox(width: 8),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              _done ? 'District view ready' : 'Scanning your district…',
              key: ValueKey(_done),
              style: TextStyle(fontWeight: FontWeight.w700, color: context.colors.onSurface),
            ),
          ),
        ),
        if (!_done)
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle))
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeOut(duration: 500.ms)
        else
          Icon(Icons.check_circle_rounded, size: 18, color: color).animate().scaleXY(begin: 0, end: 1, curve: Curves.easeOutBack),
      ],
    );
  }
}
