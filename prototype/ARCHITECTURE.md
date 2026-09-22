# AgriShield — Prototype Architecture Sketch

This is a first-pass system diagram and schema sketch, saved from planning. It is a direction, not a reviewed technical spec — cross-check it against `docs/roadmap/` before building from it, since it names some components (satellite/weather engine, mobile-money wallet) that only apply once later versions are actually built.

## Component diagram

```
                          [ Mobile App / USSD Gateway ]
                                       │
                                       ▼
                       [ API Gateway / JWT Auth Service ]
                                       │
         ┌─────────────────────────────┼─────────────────────────────┐
         ▼                             ▼                             ▼
 [ AI Vision Service ]     [ Satellite Weather Engine ]    [ Agrifinance & Wallet ]
 PyTorch ONNX Classifier   Copernicus Sentinel NDVI &      EcoCash / Mobile Money API
 Leaf Disease Inference    CHIRPS Rain Fall Triggers       Pay-at-Harvest BNPL Engine
         │                             │                             │
         └─────────────────────────────┼─────────────────────────────┘
                                       ▼
                       [ PostgreSQL + PostGIS Storage ]
```

**Reconciling this with `docs/roadmap`'s recommended stack:** the roadmap specifies Flutter + `tflite_flutter` for on-device (offline-first) inference, TensorFlow/TFLite trained on PlantVillage, Google Earth Engine (not Copernicus/CHIRPS directly) for the free Sentinel-2 pull, and Africa's Talking as the one messaging/mobile-money channel — reconcile any differences here (e.g. ONNX vs TFLite, CHIRPS vs GEE) against the roadmap docs before treating this diagram as final; the roadmap is the source of truth on sequencing and sourcing, this file is a UI/schema sketch.

## Table-to-version mapping

| Table | Version | Notes |
|---|---|---|
| `farmers` | V1 foundation / V2 | `agrishield_credit_score` is the V2 reliability-score seed, not a certified credit score (see `schema.sql` header) |
| `farm_plots` | V1 foundation | one shared farmer/field record, per roadmap §Foundation |
| `crop_scans` | V1 (Part 2) / V2 | V1 stores demo results; V2 adds confidence scoring / extension-officer workflow |
| `insurance_policies` | V3 only | parametric, triggered by the same satellite pipeline built in V1 Part 3 — ships only once a real underwriter partner is confirmed |
| `bnpl_loans` | V3 only | ships only once a real lending/microfinance partner is confirmed |

See `docs/roadmap/README.md` for the full three-version roadmap this schema is meant to support.
