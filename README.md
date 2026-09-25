# AgriShield

A super app for smallholder farmers in Zimbabwe — crop storage monitoring, offline disease screening, satellite field monitoring, and (later) a market/finance layer. Full scope, versioning, and the project's honesty principle: [`docs/roadmap/README.md`](docs/roadmap/README.md).

- [`/app`](app) — Flutter (Android-first)
- [`/backend`](backend) — FastAPI + Postgres
- [`/docs/roadmap`](docs/roadmap) — what's built, what's next, and why

## Running locally

### Backend

```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Runs on `http://localhost:8000`. Defaults to local SQLite; copy `.env.example` to `.env` to point `DATABASE_URL` at Postgres instead (see `backend/README.md`). Check it's up: `curl http://localhost:8000/health`.

### App

```bash
cd app
flutter pub get
flutter run
```

Point it at a non-default backend host/port with:

```bash
flutter run --dart-define=AGRISHIELD_API_BASE_URL=http://<host>:8000
```

The app's own default (`http://10.0.2.2:8000`) is the special alias an Android emulator uses for its host machine — pass `--dart-define` explicitly when running on desktop/web (e.g. `flutter run -d chrome`) or against a physical device over USB (use your machine's LAN IP there, not `10.0.2.2`).

Full details, including what's mocked vs. real: [`app/README.md`](app/README.md) and [`backend/README.md`](backend/README.md).
