# V1 — Hackathon Demo

**Target: 2026-09-28 (Hack4Africa 2026 pitch day), carried into the POTRAZ Innovation Expo (Sept 29–Oct 2, 2026).**

## Goal

Prove, live and in front of judges, that the core hardware and on-device AI actually work — not slides, not a mockup. This is the only version scoped to a hard, near-term deadline; everything here has to be buildable and rehearsable in six days.

## Build status

Scaffolded: [`/app`](../../app) (Flutter, Home/Storage/Scan/Map/Profile screens) and [`/backend`](../../backend) (FastAPI, endpoints for all four). No real hardware, trained model, or GEE/Africa's Talking credentials exist yet, so every external integration is a mocked implementation behind a small interface — see each directory's README for exactly what's mocked and what swapping in the real thing needs. The backend's endpoints are exercised end-to-end by `backend/tests/test_v1_flow.py` (actually run, not just written); the Flutter app hasn't been run (no Flutter SDK in this environment) — its screens were written against the same interfaces and reviewed, but not build-verified.

## Scope — what's built

### Foundation
One shared farmer/field record (name, rough location, crop, storage hub), offline-first sync, and one communication channel via **Africa's Talking** (SMS, USSD, voice — confirmed to support all three).

### Part 1 — Watching stored food
- A small solar-powered box with a cheap temperature/humidity sensor, running off a battery.
- Shelf-life countdown recalculated from live temperature, using the food-science rule of thumb that spoilage roughly doubles for every 10°C rise ("Your tomatoes have about 14 hours of good condition left — sell today."). **Flagged plainly:** the exact multiplier differs per crop and needs checking against a proper food-storage reference before being stated as fact.
- A second alert for grain: mold risk, watching for warm+damp conditions together (the same two signals a real grain-monitoring company, OPIsystems, confirms are used for early spoilage detection).
- The response to a mold/pest alert: move grain into a **PICS bag** (Purdue Improved Crop Storage) — a real, widely used ~$2–3 hermetic bag across West/East Africa. Exact current pricing wasn't reconfirmed this session.
- A real, no-electricity cooler: the **"zeer" pot-in-pot cooler** (a smaller clay pot inside a bigger one, wet sand between them, evaporation pulling heat out) — invented by Mohammed Bah Abba, 2001 Rolex Award winner, ~$1 to build. One sensor inside the cooler, one outside, so the demo shows two real, diverging numbers.

### Part 2 — Checking sick plants, without internet
- A phone photographs a leaf; an on-device model (TensorFlow Lite via `tflite_flutter`, no internet needed) gives a likely disease and a next step.
- Trained on **PlantVillage** — ~54,000 public images across 38 plant-disease combinations (2015).
- **Said plainly, every time this is shown:** this is a first opinion, not a final answer. PlantVillage photos are clean and well-lit; a well-known follow-up study (Mohanty, Hughes & Salathé, 2016) found real-world field photos perform noticeably worse than the dataset's own clean test set. A hard or unclear case always points to a real extension officer.

### Part 3 — Watching the whole area from space
- Free **Sentinel-2** imagery via **Google Earth Engine**, ~10m resolution, ~5-day revisit — district-level, not per-plant.
- Pre-built district map for the live demo.
- **Said plainly:** clouds block the view entirely, and Zimbabwe's rainy season — exactly when this signal matters most — is also when cloud cover is worst. This is an early district-scale signal over days, not a live camera.
- *This same NDVI/soil-moisture pipeline becomes the parametric-insurance trigger in V3 — built once here, reused later, no new data source needed.*

## Explicitly excluded from V1

Modules 4–8 (weather, market prices, planting advice, waste-to-feed, pest reminder), the market/hub access layer, and the entire fintech layer (AgriShield reliability score, parametric insurance, agrifinance/BNPL, marketplace) — none of it is buildable or honestly demoable in six days. All of it is V2/V3 roadmap, and the pitch should say so rather than imply it exists.

## Tech / data sources

Flutter (Android-first) + `tflite_flutter`; TensorFlow/TFLite model trained on PlantVillage; Python via Google Earth Engine for the Sentinel-2 pull; Africa's Talking for the phone alert; Python/FastAPI + PostgreSQL only for what must sync across phones (satellite tiles, synced farmer records) — nothing that runs fine on a single phone needs the backend.

## Demo / acceptance criteria — the five moments

1. **Two real thermometers, side by side** — live temperature outside vs. inside the cooler.
2. **The countdown changes because the temperature did** — the two shelf-life numbers visibly pull apart as the cooler keeps working.
3. **A phone actually rings** — trigger the warning, get a real phone ringing with a spoken message, proving "works on any phone" rather than just stating it.
4. **A photo, answered instantly, with no internet** — venue Wi-Fi off on purpose, photograph a leaf with a real, visible problem, get an answer in seconds.
5. **Zoom out to the whole district** — the pre-built satellite map, highlighting which part of the district looks stressed right now.

## Known limitations (said plainly)

- **Hardware can fail in ways software doesn't** — a loose wire or flat battery is harder to fix live than a bug. Mitigation: rehearse each part standalone, keep spares, record a backup video of every demo moment.
- **Disease-checker accuracy on real photos is unverified** until tested on the team's own field photos, not just the clean training set.
- **Satellite view is cloud-limited and delayed (up to 5 days)**, not a live feed — frame it as an early-warning tool, not a camera.

## What unlocks V2

Parts 1–3 running live generates the first real telemetry (storage conditions, disease-checker usage, satellite field health) that V2's reliability-score concept and Modules 4–8 build on top of.
