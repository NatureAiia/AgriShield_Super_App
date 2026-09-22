import 'package:flutter/material.dart';
import '../models/satellite_zone.dart';
import '../services/satellite_service.dart';
import '../theme.dart';
import '../widgets/app_card.dart';

class SatelliteMapScreen extends StatefulWidget {
  final SatelliteService satelliteService;
  const SatelliteMapScreen({super.key, required this.satelliteService});

  @override
  State<SatelliteMapScreen> createState() => _SatelliteMapScreenState();
}

class _SatelliteMapScreenState extends State<SatelliteMapScreen> {
  List<SatelliteZone> _zones = [];
  SatelliteZone? _selected;

  @override
  void initState() {
    super.initState();
    widget.satelliteService.fetchZones().then((z) => setState(() => _zones = z));
  }

  Color _colorFor(ZoneStatus status) {
    switch (status) {
      case ZoneStatus.healthy:
        return AgriShieldColors.accent;
      case ZoneStatus.stressed:
        return const Color(0xFFD97706);
      case ZoneStatus.droughtRisk:
        return AgriShieldColors.alert;
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_zones.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
        if (_zones.isNotEmpty)
          AppCard(
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              children: _zones.map((zone) {
                return GestureDetector(
                  onTap: () => setState(() => _selected = zone),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _colorFor(zone.status),
                      borderRadius: BorderRadius.circular(8),
                      border: zone.isFarmerPlot ? Border.all(color: AgriShieldColors.primary, width: 3) : null,
                    ),
                    child: zone.isFarmerPlot
                        ? const Center(
                            child: Text('You', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)))
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _legendDot(AgriShieldColors.accent, 'Healthy'),
            _legendDot(const Color(0xFFD97706), 'Stressed'),
            _legendDot(AgriShieldColors.alert, 'Drought risk'),
          ],
        ),
        if (_selected != null) ...[
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_selected!.isFarmerPlot ? 'Your plot' : 'Zone ${_selected!.id}',
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AgriShieldColors.primary)),
                const SizedBox(height: 4),
                Text('Status: ${_labelFor(_selected!.status)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AgriShieldColors.primary)),
      ],
    );
  }
}
