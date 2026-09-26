# Deploy runbook — cPanel frontend (Tremhost) + Vercel serverless API + Supabase

Status: Supabase project verified live; `farmers` table exists and is
queryable (`GET /rest/v1/farmers` → 200).

> Decision log: the API was first staged for cPanel's Python Selector, but
> the account has no Python Selector (nothing found in cPanel search) and
> its CLI crashes with a system-dir `PermissionError` — so cPanel can't run
> Python at all. The API therefore goes to Vercel serverless (slim/lite);
> cPanel serves the static frontend only. If Tremhost later enables the
> Python Selector, `passenger_wsgi.py` + the full requirements are still in
> the repo for that path.

## Hostnames

| Piece | URL |
|---|---|
| Frontend (static, `public_html`) | http://welcoming-navy-sparrow.172-93-106-10.cpanel.site/ |
| Backend API (Vercel, Root Directory `backend`) | TBD after Vercel deploy — then rebuild the frontend zip with it |

## API on Vercel (user clicks, ~10 min)

1. Vercel → New Project → import repo → **Root Directory `backend`**.
2. Env vars: `DATABASE_URL` = Supabase **pooler** URI (port 6543 —
   required from serverless), `CORS_ORIGINS` =
   `http://welcoming-navy-sparrow.172-93-106-10.cpanel.site`.
   No `AGRISHIELD_LITE` needed — lite auto-detects (no ML routers on
   Vercel: `/recommendations/*` and `/scans/diagnose` stay off).
3. Deploy → verify `https://<api>/health`, `/docs`,
   `/weather/current?lat=-17.82&lon=31.05`.
4. Hand the API URL over: frontend `dist/` gets rebuilt with it
   (`VITE_AGRISHIELD_API_URL` in `web-demo/.env.production`) and
   re-uploaded to `public_html`, then a full sign-up → reading round-trip
   is verified end-to-end.

After AutoSSL is active, switch both to `https://` and rebuild the zip
(`npx vite build --mode production` in `web-demo/`).

## cPanel steps (in order)

1. **Subdomains** — create `api` subdomain for the temp domain.
2. **Backend files** — upload `backend/` to `~/agrishield-api` via File
   Manager (skip `.venv/`, `*.db`, `.env`).
3. **Setup Python App** (cPanel UI — required; the `cloudlinux-selector`
   CLI crashes for this user with a system-dir `PermissionError`, so this
   one step can't be scripted): Python **3.11**, application root
   `agrishield-api`, startup file `passenger_wsgi.py`, application URL =
   the API domain above at URI `/`. This creates `~/virtualenv`; everything
   after it (pip, restart, verify) is done over SSH.
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
