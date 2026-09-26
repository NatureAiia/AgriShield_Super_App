# AgriShield — FastAPI backend (V1 + V2)

Scope: [`docs/roadmap/V1_HACKATHON_DEMO.md`](../docs/roadmap/V1_HACKATHON_DEMO.md). Syncs what the offline-first app collects (farmer record, Part 1 storage readings, Part 2 disease-scan results), serves Part 3's satellite zones, and triggers Foundation alerts over Africa's Talking. Also carries V2's Module 9 ([`docs/roadmap/V2_INTELLIGENCE_LAYER.md`](../docs/roadmap/V2_INTELLIGENCE_LAYER.md)): crop/fertilizer recommendation and server-side disease diagnosis, ported from [AgriLite-FL](https://github.com/marknature/AgriLite-FL) (GPLv3 — see that doc's Known Limitations before shipping this past a hackathon/prototype).

## Status: real endpoints, mocked external integrations

`/satellite/zones` and `/alerts/send` work with **no credentials configured** — they return a mock zone grid / log the alert instead of sending it (see `app/services/`). Set `GEE_SERVICE_ACCOUNT_JSON` or `AFRICASTALKING_USERNAME`/`AFRICASTALKING_API_KEY` in `.env` (copy from `.env.example`) and the corresponding service raises `NotImplementedError` — the real call isn't written yet, since no such credential existed to test against. That's the one function each side needs filled in.

Foundation sign-up/sign-in (`POST /farmers`, `GET /farmers/by-phone/{phone}`) is real and persists to whatever `DATABASE_URL` points at — no password or verification code by design, a deliberate demo-scope tradeoff for a one-step, low-friction flow (see `Farmer`'s docstring in `app/models.py`), not a mocked integration like the others on this list.

## Running

```
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Defaults to a local SQLite file (`agrishield.db`) — set `DATABASE_URL` in `.env` to point at Postgres instead (the roadmap's recommended production database; this project currently points it at a Supabase-hosted Postgres instance).

### Why pg8000, not psycopg2

`requirements.txt` pins `pg8000` (a pure-Python Postgres driver) rather than the far more common `psycopg2-binary`. On at least one dev machine used on this project, Windows Defender Application Control blocked psycopg2's compiled `_psycopg.pyd` outright (`ImportError: ... An Application Control policy has blocked this file`) — a machine-level policy, not fixable from application code. pg8000 has no compiled extension, so there's nothing for a code-integrity policy to block. If your own machine doesn't have this restriction, psycopg2-binary would work too; pg8000 was kept since it's proven to work everywhere this was tested. Needs `sslmode`/`ssl_context` explicitly since Supabase requires SSL — see `app/database.py`.

## Requirements split

- `requirements.txt` — slim core, installs everywhere. Hosts without the
  ML stack automatically run lite (no `/recommendations/*`,
  no `/scans/diagnose`; everything else works).
- `requirements-ml.txt` — scikit-learn/pandas/numpy/ai-edge-litert/pillow
  for crop/fertilizer advice + server diagnosis. Install on Docker/Render/
  VPS alongside the core file.

## Vercel deploy (serverless API)

Vercel project with **Root Directory `backend`**: auto-detects
`api/index.py` (re-exports the FastAPI app; `vercel.json` routes all paths
to it). Only `requirements.txt` is installed, so it runs lite by design.
Env vars: `DATABASE_URL` (Supabase **pooler**, port 6543 — required, direct
connections exhaust from serverless), `CORS_ORIGINS` (the frontend origin).
No `AGRISHIELD_LITE` needed — auto-detected.

## cPanel deploy (Tremhost shared hosting)

Frontend (`../web-demo/dist`, built with `.env.production`) goes to
`public_html` as static files. The API runs via cPanel's **Setup Python
App**: application root = uploaded `backend/` folder, startup file =
`passenger_wsgi.py`, application URL = your `api` subdomain. Set in the
app's environment: `DATABASE_URL` (Supabase **pooler**, port 6543),
`CORS_ORIGINS` (the frontend origin), `AGRISHIELD_LITE` only if slim.

1. Try full first: `pip install -r requirements.txt -r requirements-ml.txt`.
   If pip OOM-kills on the ML stack, install just `requirements.txt` and
   (optionally) set `AGRISHIELD_LITE=1` — lite is automatic anyway when the
   packages are missing.
3. Check `https://<api>/health`, `/docs`, `/weather/current?lat=-17.82&lon=31.05`.

## Testing

```
pip install -r requirements-dev.txt
pytest
```

`tests/test_v1_flow.py` exercises every V1 endpoint below end-to-end (create a farmer, sync a reading and a scan, fetch mock satellite zones, trigger a mock alert) — actually run against a real in-memory SQLite DB while building this, not just syntax-checked. `tests/test_recommendations.py` does the same for Module 9's recommendation and diagnosis endpoints.

## Endpoints

| Method | Path | Purpose |
|---|---|---|
| POST | `/farmers` | Sign up / create a farmer record (409 if the phone already has an account) |
| GET | `/farmers/by-phone/{phone}` | Sign in — look up a farmer by phone (404 if none) |
| GET | `/farmers/{id}` | Fetch a farmer record |
| POST | `/storage/readings` | Sync a Part 1 sensor reading (temperature, humidity, CO2 — the three-signal mold-risk approach from the vision doc §5.2) |
| GET | `/storage/readings/{farmer_id}` | List a farmer's readings |
| POST | `/scans` | Sync a Part 2 (or Module 9 server-side) disease-scan result — `source` distinguishes them |
| GET | `/scans/{farmer_id}` | List a farmer's scans |
| POST | `/scans/diagnose` | Module 9 — server-side disease diagnosis from an uploaded leaf photo (returns a diagnosis only; sync it via `POST /scans` separately) |
| GET | `/satellite/zones` | Part 3 district zone grid (mock unless GEE is configured) |
| POST | `/alerts/send` | Foundation alert channel (mock unless Africa's Talking is configured) |
| POST | `/recommendations/crop` | Module 9 — crop recommendation from soil N/P/K/pH + rainfall/temperature/humidity. Returns the top pick as `crop`, plus top-3 `suggestions` with confidence and `demo_only`/`data_source`/`limitations` flags (India-oriented training data, not validated for Zimbabwe) |
| POST | `/recommendations/fertilizer` | Module 9 — fertilizer advice for a crop + soil N/P/K |
| GET | `/health` | Liveness check |
