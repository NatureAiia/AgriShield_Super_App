from datetime import datetime
from enum import Enum

from pydantic import BaseModel, ConfigDict


class FarmerIn(BaseModel):
    phone: str
    name: str
    location: str
    crop: str
    storage_hub: str

class FarmerUpdate(BaseModel):
    name: str | None = None
    location: str | None = None
    crop: str | None = None
    storage_hub: str | None = None


class FarmerOut(FarmerIn):
    model_config = ConfigDict(from_attributes=True)
    id: str
    created_at: datetime


class StorageReadingIn(BaseModel):
    farmer_id: str
    temperature_c: float
    humidity_percent: float
    co2_ppm: float = 420.0


class StorageReadingOut(StorageReadingIn):
    model_config = ConfigDict(from_attributes=True)
    id: str
    taken_at: datetime


class DiseaseScanSource(str, Enum):
    on_device = "on_device"
    server = "server"


class DiseaseScanIn(BaseModel):
    farmer_id: str
    likely_issue: str
    confidence: float
    source: DiseaseScanSource = DiseaseScanSource.on_device


class DiseaseScanOut(DiseaseScanIn):
    model_config = ConfigDict(from_attributes=True)
    id: str
    scanned_at: datetime


class DiseaseDiagnosisOut(BaseModel):
    """Response for the synchronous server-side diagnosis endpoint —
    distinct from DiseaseScanOut, which is the logged/synced record."""

    likely_issue: str
    advice: str


class CropRecommendationIn(BaseModel):
    nitrogen: float
    phosphorous: float
    potassium: float
    ph: float
    rainfall: float
    temperature: float
    humidity: float


class CropSuggestion(BaseModel):
    crop: str
    confidence: float


class CropRecommendationOut(BaseModel):
    """`crop` is the top pick (the field the app already reads); the
    rest is additive — ranked alternatives plus honesty flags."""
    crop: str
    suggestions: list[CropSuggestion] = []
    demo_only: bool = True
    data_source: str = ""
    limitations: str = ""


class FertilizerRecommendationIn(BaseModel):
    crop: str
    nitrogen: float
    phosphorous: float
    potassium: float


class FertilizerRecommendationOut(BaseModel):
    nutrient: str
    direction: str
    advice: str


class ZoneStatus(str, Enum):
    healthy = "healthy"
    stressed = "stressed"
    droughtRisk = "droughtRisk"


class SatelliteZoneOut(BaseModel):
    id: str
    status: ZoneStatus
    is_farmer_plot: bool = False


class AlertRequest(BaseModel):
    farmer: FarmerIn
    message: str


class AlertResult(BaseModel):
    sent: bool
    channel: str
    detail: str


class WeatherOut(BaseModel):
    temperature_c: float | None = None
    humidity_percent: float | None = None
    rain_mm_24h: float | None = None
    rain_probability_max: float | None = None
    advice: str = ""
    data_source: str = ""


class PriceSnapshot(BaseModel):
    commodity: str
    market: str
    price_usd_per_kg: float
    observed: str = ""
    source: str = ""


class PricesOut(BaseModel):
    prices: list[PriceSnapshot] = []
    data_source: str = ""


class ChatMessageIn(BaseModel):
    role: str  # "user" | "assistant"
    content: str


class ChatIn(BaseModel):
    message: str
    history: list[ChatMessageIn] = []


class ChatOut(BaseModel):
    reply: str = ""
    route: str | None = None
    route_label: str | None = None
    # Set to "ai_unavailable" when ANTHROPIC_API_KEY is unset or the AI
    # call failed — `reply` is then empty and the caller should fall back
    # to `route`/`route_label` alone (see routers/chat.py).
    code: str | None = None
