/// One day of backend's /weather/forecast (backend/app/routers/weather.py),
/// including the same spray-suitability call as /weather/current.
class DailyForecast {
  final String date;
  final double? temperatureMaxC;
  final double? rainProbabilityMax;
  final double? windSpeedMaxKph;
  final String sprayStatus;
  final String sprayReason;

  const DailyForecast({
    required this.date,
    this.temperatureMaxC,
    this.rainProbabilityMax,
    this.windSpeedMaxKph,
    required this.sprayStatus,
    required this.sprayReason,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) => DailyForecast(
        date: json['date'] as String,
        temperatureMaxC: (json['temperature_max_c'] as num?)?.toDouble(),
        rainProbabilityMax: (json['rain_probability_max'] as num?)?.toDouble(),
        windSpeedMaxKph: (json['wind_speed_max_kph'] as num?)?.toDouble(),
        sprayStatus: json['spray_status'] as String? ?? '',
        sprayReason: json['spray_reason'] as String? ?? '',
      );
}

class CurrentWeather {
  final double? temperatureC;
  final double? humidityPercent;
  final double? rainMm24h;
  final double? rainProbabilityMax;
  final double? windSpeedKph;
  final String advice;
  final String sprayStatus;
  final String sprayReason;
  final String dataSource;

  const CurrentWeather({
    this.temperatureC,
    this.humidityPercent,
    this.rainMm24h,
    this.rainProbabilityMax,
    this.windSpeedKph,
    required this.advice,
    required this.sprayStatus,
    required this.sprayReason,
    required this.dataSource,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) => CurrentWeather(
        temperatureC: (json['temperature_c'] as num?)?.toDouble(),
        humidityPercent: (json['humidity_percent'] as num?)?.toDouble(),
        rainMm24h: (json['rain_mm_24h'] as num?)?.toDouble(),
        rainProbabilityMax: (json['rain_probability_max'] as num?)?.toDouble(),
        windSpeedKph: (json['wind_speed_kph'] as num?)?.toDouble(),
        advice: json['advice'] as String? ?? '',
        sprayStatus: json['spray_status'] as String? ?? '',
        sprayReason: json['spray_reason'] as String? ?? '',
        dataSource: json['data_source'] as String? ?? '',
      );
}
