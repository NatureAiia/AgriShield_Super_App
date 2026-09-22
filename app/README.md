# AgriShield — Flutter app (V1)

Scope: [`docs/roadmap/V1_HACKATHON_DEMO.md`](../docs/roadmap/V1_HACKATHON_DEMO.md) — Foundation (offline-first farmer record) + Part 1 (storage/shelf-life) + Part 2 (offline disease scan) + Part 3 (satellite district view). Modules 4–8, the market layer, and the fintech layer are later-version roadmap and not built here — see [`docs/roadmap/README.md`](../docs/roadmap/README.md).

## Status: scaffold with mocked integrations

No real hardware, trained model, or third-party credentials exist yet, so every external integration is behind a small interface with a `Mock*` implementation actually wired into the app:

| Interface | File | Mock behavior | What a real implementation needs |
|---|---|---|---|
| `SensorService` | `lib/services/sensor_service.dart` | Simulated temp/humidity random walk | A Bluetooth LE or serial bridge to Part 1's physical sensor box |
| `DiseaseService` | `lib/services/disease_service.dart` | Canned result after a delay | A trained `assets/model.tflite` (PlantVillage) + `tflite_flutter` |
| `SatelliteService` | `lib/services/satellite_service.dart` | Calls the backend, falls back to a cached zone grid if unreachable | Backend-side Google Earth Engine credentials (see `/backend`) |
| `MessagingService` | `lib/services/messaging_service.dart` | Calls the backend, which logs instead of sending | Backend-side Africa's Talking API key (see `/backend`) |

Swapping a mock for a real implementation is a one-line change in `lib/main.dart` — nothing else depends on which implementation is in use.

## Running

Requires the Flutter SDK (not installed in this environment, so this hasn't been run here — see the repo's top-level notes on how this was verified instead).

```
flutter pub get
flutter run
```

Point the app at a real backend with:

```
flutter run --dart-define=AGRISHIELD_API_BASE_URL=http://<host>:8000
```
