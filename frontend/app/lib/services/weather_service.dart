import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_forecast.dart';
import 'api_config.dart';

/// Calls backend's /weather/current and /weather/forecast
/// (backend/app/routers/weather.py) — real Open-Meteo pulls with a spray-
/// suitability call layered on top (backend/app/services/spray_advisory.py).
/// No mock: like RecommendationService, this only exists server-side.
abstract class WeatherService {
  Future<CurrentWeather> current({required double lat, required double lon});
  Future<List<DailyForecast>> forecast({required double lat, required double lon});
}

class HttpWeatherService implements WeatherService {
  @override
  Future<CurrentWeather> current({required double lat, required double lon}) async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/weather/current?lat=$lat&lon=$lon'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Weather request failed: ${response.statusCode}');
    }
    return CurrentWeather.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  @override
  Future<List<DailyForecast>> forecast({required double lat, required double lon}) async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/weather/forecast?lat=$lat&lon=$lon'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Forecast request failed: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['days'] as List<dynamic>)
        .map((d) => DailyForecast.fromJson(d as Map<String, dynamic>))
        .toList();
  }
}
