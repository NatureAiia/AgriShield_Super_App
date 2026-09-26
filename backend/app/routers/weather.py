"""V2 Module 4 — weather. Real Open-Meteo pulls (free, no key at this
tier), wrapped in a thin swappable layer so Modules 4-5 never lock the
app to one provider (docs/roadmap/V2_INTELLIGENCE_LAYER.md).

Uses only the stdlib (urllib) — no new dependency for one GET endpoint.
"""
import json
import urllib.parse
import urllib.request

from fastapi import APIRouter, HTTPException

from ..schemas import WeatherOut

router = APIRouter(prefix="/weather", tags=["weather"])

_OPEN_METEO = "https://api.open-meteo.com/v1/forecast"
_SOURCE = "Open-Meteo (free tier, no key), forecast for the given lat/lon"


def _advice(temp_c: float | None, rain_24h: float | None, rain_prob: float | None) -> str:
    if rain_24h is not None and rain_24h >= 5:
        return "Rain expected in the next day — a good time to plant, and keep harvested grain dry."
    if rain_prob is not None and rain_prob >= 60:
        return "Rain likely in the next day — a good time to plant; cover stored grain."
    if temp_c is not None and temp_c >= 30:
        return "Hot and dry ahead — check stored grain for heat and mold, and soil moisture in the field."
    return "No extremes in the next day — keep scouting weekly."


@router.get("/current", response_model=WeatherOut)
def current_weather(lat: float, lon: float):
    """Current conditions + 24h outlook for any location (Zimbabwe: Harare
    is roughly lat=-17.82, lon=31.05)."""
    params = urllib.parse.urlencode({
        "latitude": lat,
        "longitude": lon,
        "current": "temperature_2m,relative_humidity_2m,precipitation",
        "daily": "precipitation_sum,precipitation_probability_max",
        "timezone": "auto",
        "forecast_days": 2,
    })
    req = urllib.request.Request(f"{_OPEN_METEO}?{params}", headers={"User-Agent": "AgriShield/0.1"})
    try:
        with urllib.request.urlopen(req, timeout=8) as resp:
            data = json.load(resp)
    except Exception as exc:
        raise HTTPException(status_code=502, detail=f"Weather provider unreachable: {exc}") from exc
    try:
        cur = data.get("current", {})
        daily = data.get("daily", {})
        rain_24h = (daily.get("precipitation_sum") or [None])[0]
        rain_prob = (daily.get("precipitation_probability_max") or [None])[0]
        temp_c = cur.get("temperature_2m")
        return WeatherOut(
            temperature_c=temp_c,
            humidity_percent=cur.get("relative_humidity_2m"),
            rain_mm_24h=rain_24h,
            rain_probability_max=rain_prob,
            advice=_advice(temp_c, rain_24h, rain_prob),
            data_source=_SOURCE,
        )
    except Exception as exc:
        raise HTTPException(status_code=502, detail=f"Unexpected weather response: {exc}") from exc
