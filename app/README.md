# AgriShield — Flutter app (V1)

Scope: [`docs/roadmap/V1_HACKATHON_DEMO.md`](../docs/roadmap/V1_HACKATHON_DEMO.md) — Foundation (offline-first farmer record) + Part 1 (storage/shelf-life) + Part 2 (offline disease scan) + Part 3 (satellite district view). Modules 4–8, the market layer, and the fintech layer are later-version roadmap and not built here — see [`docs/roadmap/README.md`](../docs/roadmap/README.md).

## Status: scaffold with mocked integrations

No real hardware, trained model, or third-party credentials exist yet, so every external integration is behind a small interface with a `Mock*` implementation actually wired into the app:

| Interface | File | Mock behavior | What a real implementation needs |
|---|---|---|---|
| `SensorService` | `lib/services/sensor_service.dart` | Two simulated streams — `outsideReadings()` and `insideCoolerReadings()` (temp/humidity/CO2) — with the inside reading pulled progressively cooler over time, so the Storage screen's "two thermometers" gap actually widens live, matching the vision doc's demo script | A Bluetooth LE or serial bridge to Part 1's physical sensor box(es) |
| `DiseaseService` | `lib/services/disease_service.dart` | Canned result after a delay | A trained `assets/model.tflite` (PlantVillage) + `tflite_flutter` |
| `SatelliteService` | `lib/services/satellite_service.dart` | Calls the backend, falls back to a cached zone grid if unreachable | Backend-side Google Earth Engine credentials (see `/backend`) |
| `MessagingService` | `lib/services/messaging_service.dart` | Calls the backend, which logs instead of sending | Backend-side Africa's Talking API key (see `/backend`) |

Swapping a mock for a real implementation is a one-line change in `lib/main.dart` — nothing else depends on which implementation is in use.

## Demo-day additions

Built to make the app match the vision doc's own live-demo script (docs/roadmap/V1_HACKATHON_DEMO.md, "Moments 1–3") as closely as a mocked build can:

- **Storage screen** shows outside vs. inside-cooler readings side by side, with a live "N°C cooler inside" readout that grows as the (simulated) cooler works — Moments 1 and 2.
- **Mold risk** now follows OPIsystems' three-signal approach cited in the vision doc (§5.2): temperature, humidity, *and* CO2 — a CO2 spike alone is flagged as high risk, matching the doc's point that CO2 is meant to catch spoilage before anything else is visible.
- **Home screen** has a "Trigger farmer alert now" button that calls the real `MessagingService` → backend `/alerts/send` round trip and shows the result — Moment 3, made actually triggerable rather than only theoretical.
- **Branding**: the app bar uses the real logo from `/assets/logo/1.jpeg` (copied to `assets/branding/logo.jpeg` since Flutter asset bundling expects paths inside the project).

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
