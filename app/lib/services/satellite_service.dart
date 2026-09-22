import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/satellite_zone.dart';
import 'api_config.dart';

/// Fetches Part 3's district-level satellite view.
///
/// Real data comes from the backend's `/satellite/zones` endpoint, which
/// itself mocks the Sentinel-2/Google Earth Engine pull for now (see
/// backend/app/services/satellite_service.py) — no GEE credentials are
/// configured. [MockSatelliteService] additionally works with the backend
/// entirely unreachable (offline-first), falling back to a cached demo
/// grid so the map screen still renders with no connection.
abstract class SatelliteService {
  Future<List<SatelliteZone>> fetchZones();
}

class MockSatelliteService implements SatelliteService {
  static const _fallbackStatuses = [
    ZoneStatus.healthy, ZoneStatus.healthy, ZoneStatus.stressed,
    ZoneStatus.healthy, ZoneStatus.droughtRisk, ZoneStatus.stressed,
    ZoneStatus.healthy, ZoneStatus.healthy, ZoneStatus.healthy,
  ];

  @override
  Future<List<SatelliteZone>> fetchZones() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/satellite/zones'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((z) => SatelliteZone(
                  id: z['id'] as String,
                  status: ZoneStatus.values.byName(z['status'] as String),
                  isFarmerPlot: z['is_farmer_plot'] as bool? ?? false,
                ))
            .toList();
      }
    } catch (_) {
      // Offline or backend unreachable — fall through to the cached grid.
    }
    return List.generate(
      _fallbackStatuses.length,
      (i) => SatelliteZone(
        id: 'zone-$i',
        status: _fallbackStatuses[i],
        isFarmerPlot: i == 4,
      ),
    );
  }
}
