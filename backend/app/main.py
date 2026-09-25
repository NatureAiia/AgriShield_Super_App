from fastapi import FastAPI

from . import models
from .database import Base, engine
from .routers import alerts, farmers, recommendations, satellite, scans, storage

Base.metadata.create_all(bind=engine)

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
app.include_router(recommendations.router)


@app.get("/health")
def health():
    return {"status": "ok"}
