import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/farmer.dart';
import '../models/weather_forecast.dart';
import '../services/weather_service.dart';
import '../theme.dart';
import '../widgets/app_card.dart';

/// Weather & spraying advisory (backend/app/routers/weather.py): current
/// conditions plus a 5-day spray-suitability outlook, so a farmer can plan
/// the week's chemical application around wind/rain/heat, not just today's.
class WeatherScreen extends StatefulWidget {
  final Farmer farmer;
  final WeatherService weatherService;
  const WeatherScreen({super.key, required this.farmer, required this.weatherService});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // Harare's coordinates stand in until the farmer record carries real
  // lat/lon (Farmer only has a free-text `location` today, see models/farmer.dart).
  static const _lat = -17.82;
  static const _lon = 31.05;

  CurrentWeather? _current;
  List<DailyForecast> _forecast = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        widget.weatherService.current(lat: _lat, lon: _lon),
        widget.weatherService.forecast(lat: _lat, lon: _lon),
      ]);
      if (!mounted) return;
      setState(() {
        _current = results[0] as CurrentWeather;
        _forecast = results[1] as List<DailyForecast>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = "Couldn't reach the weather service — check your connection.";
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 40, color: context.colors.onSurface.withValues(alpha: 0.5)),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final current = _current!;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.thermostat, color: context.colors.secondary),
                    const SizedBox(width: 8),
                    Text(
                      current.temperatureC == null ? '—' : '${current.temperatureC!.toStringAsFixed(0)}°C',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: context.colors.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(current.advice, style: TextStyle(color: context.colors.onSurface.withValues(alpha: 0.75))),
                const SizedBox(height: 4),
                Text(
                  current.dataSource,
                  style: TextStyle(fontSize: 11, color: context.colors.onSurface.withValues(alpha: 0.5)),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 12),
          _SprayAdvisoryCard(status: current.sprayStatus, reason: current.sprayReason)
              .animate()
              .fadeIn(delay: 80.ms, duration: 300.ms),
          const SizedBox(height: 16),
          Text('5-DAY SPRAY OUTLOOK', style: context.text.labelSmall),
          const SizedBox(height: 8),
          for (var i = 0; i < _forecast.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ForecastRow(day: _forecast[i])
                  .animate()
                  .fadeIn(delay: (120 + i * 60).ms, duration: 300.ms)
                  .slideX(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
            ),
        ],
      ),
    );
  }
}

Color _statusColor(BuildContext context, String status) {
  if (status.startsWith('Optimal')) return AgriShieldStatus.low;
  if (status.startsWith('Avoid')) return AgriShieldStatus.high;
  if (status.startsWith('Caution')) return AgriShieldStatus.moderate;
  return context.colors.onSurface.withValues(alpha: 0.4);
}

class _SprayAdvisoryCard extends StatelessWidget {
  final String status;
  final String reason;
  const _SprayAdvisoryCard({required this.status, required this.reason});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context, status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Color.alphaBlend(color.withValues(alpha: context.isDark ? 0.22 : 0.12), context.colors.surface),
        borderRadius: BorderRadius.circular(AgriShieldRadii.card),
      ),
      child: Row(
        children: [
          Icon(Icons.wb_twilight, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SPRAYING TODAY: ${status.toUpperCase()}',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: color)),
                const SizedBox(height: 2),
                Text(reason, style: TextStyle(fontSize: 12, color: context.colors.onSurface.withValues(alpha: 0.75))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastRow extends StatelessWidget {
  final DailyForecast day;
  const _ForecastRow({required this.day});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context, day.sprayStatus);
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(day.date, style: TextStyle(fontWeight: FontWeight.w700, color: context.colors.onSurface)),
          ),
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(day.sprayStatus, style: TextStyle(fontSize: 13, color: context.colors.onSurface)),
          ),
          Text(
            day.temperatureMaxC == null ? '—' : '${day.temperatureMaxC!.toStringAsFixed(0)}°C',
            style: TextStyle(fontSize: 13, color: context.colors.onSurface.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}
