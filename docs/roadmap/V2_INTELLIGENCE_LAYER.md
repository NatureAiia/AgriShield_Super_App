# V2 — Intelligence Layer

**When: post-hackathon, through the POTRAZ Innovation Expo (Sept 29–Oct 2, 2026) and beyond.**

## Goal

Turn AgriShield from three demo parts into a season-long companion: real weather, real prices, real planting advice, and the start of a data-backed reliability signal — all genuinely buildable now, each with a real, cited free data source. This is also where the eventual fintech layer (V3) gets seeded, not built.

## Scope — what's built

- **Module 4 — Weather.** [Open-Meteo](https://open-meteo.com) (free, no key needed at this tier, up to 16-day forecast for any location including Zimbabwe) → plain-language alerts ("rain expected in two days — a good time to plant"; "dry spell ahead — check soil moisture"). V1's satellite view already gives a slower, free backup rainfall/drought signal, so this module has two real sources, not one.
- **Module 5 — Market prices.** Zimbabwe's **Agricultural Marketing Authority** publishes real, regularly updated public prices across four markets (Mbare, Sakubva, Chipadze, Renkini) — **for vegetables and horticultural produce only**. Grain prices are a named, unfilled gap — not invented, not built around a guess. *This vegetable-only feed is the seed of V3's fuller commodity price ticker.*
- **Module 6 — Planting-window advice.** Rule-based: combines FAO's public crop-calendar tool with Part 3's soil-moisture/rainfall signal and Module 4's forecast to suggest a rough planting window. **Flagged:** Zimbabwe's specific coverage in the FAO tool, and the exact combination rules, still need checking before this reaches a farmer.
- **Module 7 — Waste-to-feed guidance.** Rule-based (not ML) — turns crop residue (stalks, husks, peels) into livestock feed guidance, per FAO's published technical guidance on processing/preserving crop residues as feed. Replaces the dropped "livestock disease photo checker" idea permanently — no usable public animal-disease photo dataset exists, unlike PlantVillage for plants. **Flagged:** exact safe recipes/ratios need a local livestock-extension partner to verify before reaching a farmer.
- **Module 8 — Seasonal pest-risk reminder.** Calendar-based nudge only, for when a known pest is typically active in the season — **explicitly not** sensor-based pest prediction. That specific claim was reviewed and rejected: the real early-warning system for that pest (run by FAO) uses physical insect traps and field scouting, not weather sensors.
- **AgriShield reliability score (V2 version).** A transparent, data-driven score computed from telemetry the app already has by this point: storage conditions and spoilage-avoidance history (Part 1), disease-checker usage and outcomes (Part 2), satellite-observed field health (Part 3), and weather/planting-advice adherence (Modules 4–6). Shown to the farmer as a simple in-app gauge. **Explicitly not** a certified financial credit score at this stage — no lender or credit bureau is involved yet. This is the seed V3 later extends into real financial products, once real partners exist.
- **Module 9 — Crop & fertilizer recommendation, server-side disease diagnosis.** Ported from [AgriLite-FL](https://github.com/marknature/AgriLite-FL) (GPLv3): a scikit-learn RandomForest suggests a crop from soil N/P/K, pH, rainfall, temperature and humidity (`backend/app/services/recommendation_service.py`) — the response also carries the top-3 crops with confidence and a `demo_only` flag, since the training data is India-oriented and misses key Zimbabwean crops (sorghum, wheat, tobacco, groundnuts, soybeans); a rule-based CSV lookup turns the gap between a farmer's N/P/K and a crop's ideal values into fertilizer advice; a ResNet9 (38 PlantVillage classes) gives a second, server-side opinion on a leaf photo (`backend/app/services/disease_model_service.py`) alongside Part 2's on-device checker, not replacing it. AgriLite-FL's own shipped crop model pickle (scikit-learn 0.23.2, 2020) doesn't load on current scikit-learn, so `backend/scripts/train_crop_model.py` retrains it from the same public training data instead (99.1% held-out accuracy). The disease model's original PyTorch checkpoint was converted to TFLite (`backend/scripts/convert_to_tflite.py`, PyTorch → ONNX → onnx2tf) and runs on the lightweight `ai-edge-litert` runtime — matching what Part 2's on-device checker already uses — instead of a torch/torchvision runtime dependency; verified identical top-1 predictions before the original `.pth` was dropped from the repo. AgriLite-FL's README also claims federated learning and a multilingual chatbot — neither exists in its actual code (no FL framework, no chatbot route); see `V4_FUTURE_EXPLORATION.md` for those as unconfirmed ideas, not things that were ported.
- **Validation work:** local dataset collection, a human-in-the-loop extension-officer review workflow, and confidence scoring on the disease checker — moving it from "first opinion" toward something closer to validated advice.

## Explicitly excluded from V2

The market/hub matching layer, parametric insurance, agrifinance/BNPL, the fuller marketplace, and the real cold room — all of these need V1+V2 usage data to exist first, per the "evidence before infrastructure" principle this whole roadmap follows (the same reasoning the source docs use for not building the $30,000 cold room on a guess).

## Tech / data sources

Open-Meteo (weather), Zimbabwe Agricultural Marketing Authority (vegetable prices), FAO crop-calendar tool (planting windows), FAO crop-residue guidance (waste-to-feed), FAO pest early-warning program as the real-world reference for what Module 8 deliberately does *not* claim to be, AgriLite-FL (GPLv3, Module 9's crop/fertilizer/disease models) built on the public "Crop Recommendation Dataset" and PlantVillage. Backend: Python/FastAPI + PostgreSQL for anything that must sync across phones (price/weather caches, the reliability-score computation, synced records).

## Demo / acceptance criteria

- A farmer with no smartphone data plan receives a weather-based planting alert and a vegetable price alert over SMS/USSD/voice, generated from real API pulls, not canned text.
- The in-app reliability-score gauge changes visibly in response to real V1/V2 activity (e.g. a storage alert acted on, a disease scan logged) — not a static number.
- At least one extension-officer review loop is demonstrated end-to-end on a disease-checker case flagged low-confidence.

## Known limitations (said plainly)

- Weather and price feeds depend on free-tier third-party APIs staying free and online — kept as a thin, swappable layer so Modules 4–5 don't lock the whole app to one provider.
- Grain price coverage is a real, named gap in Module 5 until a source is found.
- The reliability score is only as good as the telemetry feeding it — early on, with few V1 users, it will be noisy; say so rather than presenting it as authoritative from day one.
- Module 9's disease model runs on `ai-edge-litert` (~18MB installed) rather than torch/torchvision (several hundred MB+) after the PyTorch→TFLite conversion, so it's no longer the heaviest thing in the backend — but its CPU inference latency under real load still hasn't been measured yet. Its code (not the retrained crop model, which comes from public data) is ported from a GPLv3 project — carries a copyleft obligation worth a license review before this goes further than a hackathon/prototype.

## What unlocks V3

Once V2's Modules 4–8 and reliability score are running with real usage across several farmers/collection points, that's the evidence base V3's market layer, insurance, and BNPL are gated on.
