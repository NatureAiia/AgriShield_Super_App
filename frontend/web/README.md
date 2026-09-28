# AgriShield — MVP webapp (Vercel) + API (Render/Railway/Fly)

Real product, not a mockup: phone sign-in, storage readings, leaf-scan
server diagnosis, satellite zones, crop/fertilizer advice, live weather,
alerts — all served by `../backend` (FastAPI + Postgres).

## Run locally

```bash
# backend
cd ../../backend
pip install -r requirements.txt
uvicorn app.main:app --reload   # http://localhost:8000

# webapp
cd frontend/web
npm install
cp .env.example .env   # VITE_AGRISHIELD_API_URL=http://localhost:8000
npm run dev
```

## Deploy

**Backend (Render blueprint, `../../backend/render.yaml`):**
1. Render → New → Blueprint → point at repo.
2. It provisions `agrishield-api` (Docker) + `agrishield-db` (Postgres).
3. Set `CORS_ORIGINS` to the webapp URL, e.g. `https://agrishield.vercel.app`.
4. `DATABASE_URL` is injected from the managed DB (the `postgres://` →
   `postgresql+pg8000://` rewrite is automatic in `app/config.py`).

**Webapp (Vercel):**
1. Vercel → New Project → Root Directory = `frontend/web`.
2. Build `npm run build`, output `dist` (already in `vercel.json`).
3. Env var: `VITE_AGRISHIELD_API_URL` = your Render API URL.
4. Redeploy after changing env vars (Vite bakes them at build time).

## Honesty labels (kept in UI, not hidden)

- Satellite zones: mock grid until `GEE_SERVICE_ACCOUNT_JSON` is set.
- Alerts: logged, not sent, until `AFRICASTALKING_*` is set — the UI shows the returned channel.
- Prices: empty snapshot until the pilot team enters a dated AMA bulletin — the UI shows the source note.
- Crop advice: India-oriented training data, misses key ZW crops — the UI shows the backend's `limitations` text.
- Server diagnosis: first opinion, confirm with an extension officer.
