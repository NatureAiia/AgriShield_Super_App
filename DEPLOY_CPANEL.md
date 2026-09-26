# Deploy runbook — cPanel (Tremhost) + Supabase

Status: Supabase project verified live; `farmers` table exists and is
queryable (`GET /rest/v1/farmers` → 200). Webapp dist built with the API
URL below baked in (`web-demo/webapp-dist-cpanel.zip`, git-ignored).

## Hostnames

| Piece | URL |
|---|---|
| Frontend (static, `public_html`) | http://welcoming-navy-sparrow.172-93-106-10.cpanel.site/ |
| Backend API (Python app) | http://api.welcoming-navy-sparrow.172-93-106-10.cpanel.site |

After AutoSSL is active, switch both to `https://` and rebuild the zip
(`npx vite build --mode production` in `web-demo/`).

## cPanel steps (in order)

1. **Subdomains** — create `api` subdomain for the temp domain.
2. **Backend files** — upload `backend/` to `~/agrishield-api` via File
   Manager (skip `.venv/`, `*.db`, `.env`).
3. **Setup Python App** — Python 3.12 (3.11 if 3.12 absent), app root
   `agrishield-api`, startup file `passenger_wsgi.py`, URL = api subdomain.
4. **Environment** (Python app UI):
   - `DATABASE_URL` — Supabase **pooler** URI, port 6543
     (dashboard → Settings → Database → Connection string → pooler mode).
     Local `backend/.env` holds the direct URL as fallback.
   - `CORS_ORIGINS=http://welcoming-navy-sparrow.172-93-106-10.cpanel.site`
   - `AGRISHIELD_LITE` — leave unset unless slim fallback (step 5).
5. **pip, full first** — `pip install -r requirements.txt`. If it OOMs on
   scikit-learn/pandas/ai-edge-litert → `pip install -r
   requirements-cpanel.txt` + set `AGRISHIELD_LITE=1` + restart.
   Lite drops `/recommendations/*` and `/scans/diagnose`; everything else
   works (verified with heavy deps hard-blocked).
6. **Verify API** — `http://<api>/health` → `{"status":"ok"}`; also
   `/docs` and `/weather/current?lat=-17.82&lon=31.05`.
7. **Frontend** — upload `webapp-dist-cpanel.zip` to `public_html` →
   Extract → open site → sign up (phone) → log a reading → refresh to
   confirm the round-trip (web → cPanel API → Supabase).

## Post-deploy hygiene

- Rotate the cPanel password (it was shared in chat).
- Never commit `backend/.env` (already git-ignored) or API keys.
