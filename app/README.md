# AgriShield — Flutter app (V1 + V2)

Scope: [`docs/roadmap/V1_HACKATHON_DEMO.md`](../docs/roadmap/V1_HACKATHON_DEMO.md) — Foundation (offline-first farmer record) + Part 1 (storage/shelf-life) + Part 2 (offline disease scan) + Part 3 (satellite district view). Modules 4–8 and the market/fintech layers are later-version roadmap and not built here — see [`docs/roadmap/README.md`](../docs/roadmap/README.md) — except for V2's Module 9 (crop/fertilizer recommendation, server-side disease diagnosis; `docs/roadmap/V2_INTELLIGENCE_LAYER.md`), which is built here alongside V1.

## Status: scaffold with mocked integrations

No real hardware, trained model, or third-party credentials exist yet, so every external integration is behind a small interface with a `Mock*` implementation actually wired into the app:

| Interface | File | Mock behavior | What a real implementation needs |
|---|---|---|---|
| `SensorService` | `lib/services/sensor_service.dart` | Two simulated streams — `outsideReadings()` and `insideCoolerReadings()` (temp/humidity/CO2) — with the inside reading pulled progressively cooler over time, so the Storage screen's "two thermometers" gap actually widens live, matching the vision doc's demo script | A Bluetooth LE or serial bridge to Part 1's physical sensor box(es) |
| `DiseaseService` | `lib/services/disease_service.dart` | Canned result after a delay | A trained `assets/model.tflite` (PlantVillage) + `tflite_flutter` |
| `SatelliteService` | `lib/services/satellite_service.dart` | Calls the backend, falls back to a cached zone grid if unreachable | Backend-side Google Earth Engine credentials (see `/backend`) |
| `MessagingService` | `lib/services/messaging_service.dart` | Calls the backend, which logs instead of sending | Backend-side Africa's Talking API key (see `/backend`) |

Swapping a mock for a real implementation is a one-line change in `lib/main.dart` — nothing else depends on which implementation is in use.

`RecommendationService` (`lib/services/recommendation_service.dart`, V2's Module 9) has no mock — the recommendation logic (a scikit-learn model + a CSV lookup) only exists server-side, so `HttpRecommendationService` always calls the backend and needs it reachable. The Recommend screen shows the top pick, the model's top-3 crops with a confidence bar each, and an amber demo-only notice (the backend's `limitations` text) right next to the answer; `test/recommendation_screen_test.dart` checks that in light and dark themes (`flutter test`). `DiseaseService` also gained a second real implementation, `ServerDiseaseService`, calling the backend's `/scans/diagnose` as a heavier online alternative to the on-device mock — not wired in by default in `main.dart`, since Part 2's on-device check stays the primary flow.

## Sign-in

`AuthService` (`lib/services/auth_service.dart`) is Foundation's phone-number sign-in with no password or code — the one interface here where the *real* implementation (`HttpAuthService`, calling the backend's `POST /farmers` + `GET /farmers/by-phone/{phone}`) is what's wired into `main.dart` by default, not a mock, since it needs no hardware/credentials beyond a reachable backend. No SMS step by design: a deliberate demo-scope tradeoff for one-tap stage flow (the earlier OTP screen was removed — it proved nothing without a real Africa's Talking SMS account and cost a full screen of friction). `MockAuthService` (local-only, no backend) is kept in the same file as an offline-development alternative, not wired in.

A first launch shows `screens/auth/landing_screen.dart` → sign-up (collects phone + the same Foundation fields Profile lets you edit later, one tap creates the server record; 409 points at sign-in) or sign-in (phone-only lookup; 404 points at sign-up). A returning, already-signed-in farmer skips straight past it. Profile's "Sign out" clears the local session only — editing farmer fields in Profile after sign-up is still local-only (`FarmerRepository`'s own TODO), not synced back to the backend.

## Demo-day additions

Built to make the app match the vision doc's own live-demo script (docs/roadmap/V1_HACKATHON_DEMO.md, "Moments 1–3") as closely as a mocked build can:

- **Storage screen** shows outside vs. inside-cooler readings side by side, with a live "N°C cooler inside" readout that grows as the (simulated) cooler works — Moments 1 and 2.
- **Mold risk** now follows OPIsystems' three-signal approach cited in the vision doc (§5.2): temperature, humidity, *and* CO2 — a CO2 spike alone is flagged as high risk, matching the doc's point that CO2 is meant to catch spoilage before anything else is visible.
- **Home screen** has a "Trigger farmer alert now" button that calls the real `MessagingService` → backend `/alerts/send` round trip and shows the result — Moment 3, made actually triggerable rather than only theoretical.
- **Branding**: the app bar uses the real logo from `/assets/logo/1.jpeg` (copied to `assets/branding/logo.jpeg` since Flutter asset bundling expects paths inside the project).

## Dark / light mode

`lib/theme.dart` builds real, separate `ColorScheme`s for light and dark (not a single palette with opacity tweaks) — every screen reads colors via a `context.colors`/`context.text` extension rather than a static constant, so the toggle actually changes what's on screen everywhere, not just the app bar. A sun/moon/auto icon in the app bar cycles System → Light → Dark, persisted locally via `ThemeController` (`lib/services/theme_controller.dart`) so the choice survives a restart.

Every text/background pairing was checked against WCAG AA (4.5:1), not assumed — including two real contrast bugs found and fixed while building this: the mold-risk badge's vivid status colors (green/amber/red) failed badly against their own pale tint in light mode (as low as 1.93:1), and the satellite map's white "You" label failed against all three zone colors (2.1–3.8:1). Both now use separately-checked text colors / a dark backdrop rather than the raw brand color.

## UI polish

Built to a "dense dashboard, not a decorative landing screen" brief: a 2×2 bento grid of the real V1 signals on Home (shelf life, mold risk, CO2, cooler effect — nothing from V2/V3 invented to fill space), consistent 16px/14px corner radii everywhere via `AgriShieldRadii`, and real (not decorative) micro-interactions: `AnimatedSwitcher`/`AnimatedSize` on values and cards that change, a `Pressable` scale-down on the disease-scan capture button, skeleton shimmers (`ShimmerBox`) instead of bare "—" while a first reading or the satellite fetch is in flight, and pull-to-refresh on the Satellite screen (the one screen whose data is a one-shot fetch rather than a live stream, so it's the one place that pattern actually fits).

## Running

Requires the Flutter SDK. Verified in this project by running the real app live in Chrome (`flutter run -d chrome`) against a live backend — no Android SDK/emulator was available in that environment, so an actual Android device/emulator run is still outstanding.

```
flutter pub get
flutter run
```

Point the app at a real backend with:

```
flutter run --dart-define=AGRISHIELD_API_BASE_URL=http://<host>:8000
```
