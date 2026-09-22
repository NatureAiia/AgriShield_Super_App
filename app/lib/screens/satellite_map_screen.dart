import 'package:flutter/material.dart';
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
          if (!_loading)
            AppCard(
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                children: _zones.map((zone) {
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
                                    color: Colors.black.withOpacity(0.55),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('You', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                                ),
                              )
                            : null,
                      ),
                    ),
                  );
                }).toList(),
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
                              style: TextStyle(fontSize: 12, color: context.colors.onSurface.withOpacity(0.6))),
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
