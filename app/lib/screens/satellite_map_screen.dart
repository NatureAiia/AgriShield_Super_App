import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/satellite_zone.dart';
import '../services/satellite_service.dart';
import '../theme.dart';
import '../widgets/app_card.dart';
import '../widgets/shimmer_box.dart';

class SatelliteMapScreen extends StatefulWidget {
  final SatelliteService satelliteService;
  const SatelliteMapScreen({super.key, required this.satelliteService});

  @override
  State<SatelliteMapScreen> createState() => _SatelliteMapScreenState();
}

class _SatelliteMapScreenState extends State<SatelliteMapScreen> {
  List<SatelliteZone> _zones = [];
  SatelliteZone? _selected;
  bool _loading = true;
  int _scanId = 0; // bumps on each refresh so the sweep replays

  @override
  void initState() {
    super.initState();
    _refresh();
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
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.55),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text('You', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                                        ),
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
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_selected!.isFarmerPlot ? 'Your plot' : 'Zone ${_selected!.id}',
                              style: TextStyle(fontWeight: FontWeight.w800, color: context.colors.onSurface)),
                          const SizedBox(height: 4),
                          Text('Status: ${_labelFor(_selected!.status)}',
                              style: TextStyle(fontSize: 12, color: context.colors.onSurface.withValues(alpha: 0.6))),
                        ],
                      ),
                    ),
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
        Icon(Icons.satellite_alt_rounded, size: 18, color: color)
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
