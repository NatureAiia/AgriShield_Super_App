import 'dart:math';
import '../models/storage_reading.dart';

/// Reads Part 1's solar-powered sensor box — two placements, matching the
/// vision doc's own demo script (docs/roadmap/V1_HACKATHON_DEMO.md,
/// "Moment 1"): one sensor outside the zeer cooler, one inside it, "so two
/// real numbers, side by side, actually change because of real physics."
///
/// No real sensor hardware exists yet, so [MockSensorService] is the only
/// implementation wired into the app (see main.dart). A real one would
/// talk to the physical box over Bluetooth LE or a serial/USB bridge and
/// implement this same interface — nothing above it (screens, shelf-life
/// math) would need to change.
abstract class SensorService {
  Stream<StorageReading> outsideReadings();
  Stream<StorageReading> insideCoolerReadings();
}

class MockSensorService implements SensorService {
  final Random _random = Random();

  double _outsideTemp = 34;
  double _outsideHumidity = 45;
  double _insideTemp = 34; // starts equal to outside; the cooler pulls it down as "time" passes
  double _insideHumidity = 45;
  double _co2 = 430; // ambient baseline ppm
  int _tick = 0;

  @override
  Stream<StorageReading> outsideReadings() async* {
    while (true) {
      _outsideTemp += _random.nextDouble() * 1.0 - 0.5;
      _outsideHumidity += _random.nextDouble() * 1.5 - 0.75;
      yield StorageReading(
        temperatureC: _outsideTemp.clamp(20, 40),
        humidityPercent: _outsideHumidity.clamp(20, 90),
        co2Ppm: 420 + _random.nextDouble() * 20, // open air stays near ambient
        takenAt: DateTime.now(),
      );
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  @override
  Stream<StorageReading> insideCoolerReadings() async* {
    while (true) {
      _tick++;
      // Evaporative cooling widens the gap from outside temperature as the
      // demo runs, up to a physically plausible ~10°C drop — the "two
      // shelf-life numbers visibly pull apart" moment.
      final targetGap = min(10.0, _tick * 0.4);
      _insideTemp += (_outsideTemp - targetGap - _insideTemp) * 0.3 + (_random.nextDouble() * 0.4 - 0.2);
      _insideHumidity += _random.nextDouble() * 1.5 - 0.5;
      // CO2 climbs slowly to demonstrate the "catches it before anything
      // is visible" story from the vision doc — an early-warning spike a
      // judge can watch happen live, not a static number.
      _co2 += _random.nextDouble() * 25 - 5;
      yield StorageReading(
        temperatureC: _insideTemp.clamp(15, 40),
        humidityPercent: _insideHumidity.clamp(30, 95),
        co2Ppm: _co2.clamp(400, 1600),
        takenAt: DateTime.now(),
      );
      await Future.delayed(const Duration(seconds: 3));
    }
  }
}
