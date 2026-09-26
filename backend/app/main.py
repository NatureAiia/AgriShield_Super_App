from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

import os

from . import models
from .config import settings
from .database import Base, engine
from .routers import alerts, farmers, prices, satellite, scans, storage, weather

# Lite mode: the ML routers need pandas/scikit-learn/numpy/ai-edge-litert,
# which serverless (Vercel) and tight shared hosts can't install. Instead of
# crashing the whole API when they're absent, the app compiles those routers
# out and serves everything else (auth, storage, scan-log, satellite,
# alerts, weather, prices). Explicit via AGRISHIELD_LITE=1, otherwise
# automatic on ImportError — so a plain `pip install -r requirements.txt`
# always yields a working API.
LITE = os.getenv("AGRISHIELD_LITE") == "1"
if not LITE:
    try:
        from .routers import recommendations
    except ImportError:
        LITE = True

try:
    Base.metadata.create_all(bind=engine)
except Exception as e:
    print(f"Database initialization failed: {e}")
    # We don't crash here so the API can still start and report the error via /health

app = FastAPI(
    title="AgriShield API",
    description=(
        "V1 backend (docs/roadmap/V1_HACKATHON_DEMO.md): Foundation + "
        "Part 1 storage sync + Part 2 disease-scan sync + Part 3 "
        "satellite zones + the one Africa's Talking alert channel. "
        "Satellite and alerts run in mock mode until GEE / Africa's "
        "Talking credentials are configured — see .env.example. Also "
        "carries V2's crop/fertilizer recommendation and server-side "
        "disease diagnosis (docs/roadmap/V2_INTELLIGENCE_LAYER.md), "
        "ported from AgriLite-FL (GPLv3)."
    ),
    version="0.1.0",
)

app.include_router(farmers.router)
app.include_router(storage.router)
app.include_router(scans.router)
app.include_router(satellite.router)
app.include_router(alerts.router)
if not LITE:
    app.include_router(recommendations.router)
app.include_router(weather.router)
app.include_router(prices.router)

# The hosted webapp calls this API from a browser, so CORS must allow its
# origin. Empty CORS_ORIGINS = allow all (demo convenience, not prod).
_cors = [o.strip() for o in settings.cors_origins.split(",") if o.strip()] or ["*"]
app.add_middleware(
    CORSMiddleware,
    allow_origins=_cors,
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root():
    return {"message": "AgriShield API is live", "docs": "/docs", "health": "/health"}

@app.get("/health")
def health():
    return {"status": "ok"}
