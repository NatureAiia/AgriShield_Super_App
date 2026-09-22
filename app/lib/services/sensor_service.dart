import 'dart:math';
import '../models/storage_reading.dart';

/// Reads Part 1's solar-powered temperature/humidity sensor box.
///
/// No real sensor hardware exists yet, so [MockSensorService] is the only
/// implementation wired into the app (see main.dart). A real one would
/// talk to the physical box over Bluetooth LE or a serial/USB bridge and
/// implement this same interface — nothing above it (screens, shelf-life
/// math) would need to change.
abstract class SensorService {
  Stream<StorageReading> readings();
}

class MockSensorService implements SensorService {
  final Random _random = Random();

  @override
  Stream<StorageReading> readings() async* {
    double temp = 31;
    double humidity = 68;
    while (true) {
      // Small random walk so the demo shows a live, changing reading
      // rather than a frozen number.
      temp += _random.nextDouble() * 1.2 - 0.6;
      humidity += _random.nextDouble() * 2 - 1;
      yield StorageReading(
        temperatureC: temp.clamp(18, 40),
        humidityPercent: humidity.clamp(30, 95),
        takenAt: DateTime.now(),
      );
      await Future.delayed(const Duration(seconds: 3));
    }
  }
}
