# AgriShield — FastAPI backend (V1)

Scope: [`docs/roadmap/V1_HACKATHON_DEMO.md`](../docs/roadmap/V1_HACKATHON_DEMO.md). Syncs what the offline-first app collects (farmer record, Part 1 storage readings, Part 2 disease-scan results), serves Part 3's satellite zones, and triggers Foundation alerts over Africa's Talking.

## Status: real endpoints, mocked external integrations

`/satellite/zones` and `/alerts/send` work with **no credentials configured** — they return a mock zone grid / log the alert instead of sending it (see `app/services/`). Set `GEE_SERVICE_ACCOUNT_JSON` or `AFRICASTALKING_USERNAME`/`AFRICASTALKING_API_KEY` in `.env` (copy from `.env.example`) and the corresponding service raises `NotImplementedError` — the real call isn't written yet, since no such credential existed to test against. That's the one function each side needs filled in.

## Running

```
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Defaults to a local SQLite file (`agrishield.db`) — set `DATABASE_URL` in `.env` to point at Postgres instead (the roadmap's recommended production database).

## Testing

```
pip install -r requirements-dev.txt
pytest
```

`tests/test_v1_flow.py` exercises every endpoint below end-to-end (create a farmer, sync a reading and a scan, fetch mock satellite zones, trigger a mock alert) — actually run against a real in-memory SQLite DB while building this, not just syntax-checked.

## Endpoints

| Method | Path | Purpose |
|---|---|---|
| POST | `/farmers` | Create a farmer record |
| GET | `/farmers/{id}` | Fetch a farmer record |
| POST | `/storage/readings` | Sync a Part 1 sensor reading (temperature, humidity, CO2 — the three-signal mold-risk approach from the vision doc §5.2) |
| GET | `/storage/readings/{farmer_id}` | List a farmer's readings |
| POST | `/scans` | Sync a Part 2 disease-scan result |
| GET | `/scans/{farmer_id}` | List a farmer's scans |
| GET | `/satellite/zones` | Part 3 district zone grid (mock unless GEE is configured) |
| POST | `/alerts/send` | Foundation alert channel (mock unless Africa's Talking is configured) |
| POST | `/recommendations/crop` | V2 Module 6 prototype — top-3 crop suggestions from soil N/P/K, pH, temperature, humidity, rainfall. **Demo only:** trained at first request from the bundled Kaggle Crop Recommendation Dataset (India-oriented, no sorghum/wheat/tobacco/groundnuts/soybeans); every response carries `demo_only: true` and a `limitations` string |
| GET | `/health` | Liveness check |
