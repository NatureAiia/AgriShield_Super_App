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
    wind_speed_kph: float | None = None
    advice: str = ""
    # Chemical-spraying suitability (services/spray_advisory.py): a plain
    # status plus the one-line reason it was picked — never spray timing
    # advice without saying why.
    spray_status: str = ""
    spray_reason: str = ""
    data_source: str = ""


class DailyForecastOut(BaseModel):
    date: str
    temperature_max_c: float | None = None
    rain_probability_max: float | None = None
    wind_speed_max_kph: float | None = None
    spray_status: str = ""
    spray_reason: str = ""


class ForecastOut(BaseModel):
    days: list[DailyForecastOut] = []
    data_source: str = ""


class AdvisorOut(BaseModel):
    id: str
    name: str
    role: str
    district: str
    phone: str


class AdvisorsOut(BaseModel):
    advisors: list[AdvisorOut] = []
    data_source: str = ""


class AdvisorRequestType(str, Enum):
    farm_visit = "farm_visit"
    disease_escalation = "disease_escalation"
    consultation = "consultation"


class AdvisorRequestIn(BaseModel):
    farmer_id: str
    advisor_id: str | None = None
    request_type: AdvisorRequestType
    notes: str = ""


class AdvisorRequestOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: str
    ticket: str
    status: str
    request_type: str
    created_at: datetime


class ActivityStatus(str, Enum):
    pending = "pending"
    completed = "completed"


class ActivityIn(BaseModel):
    farmer_id: str
    title: str
    notes: str = ""
    scheduled_for: datetime
    source: str = "manual"


class ActivityOut(ActivityIn):
    model_config = ConfigDict(from_attributes=True)
    id: str
    status: ActivityStatus
    created_at: datetime


class DroughtStatusOut(BaseModel):
    risk_level: str
    drought_zone_fraction: float
    stressed_zone_fraction: float
    reason: str
    data_source: str = ""


class DroughtReportIn(BaseModel):
    farmer_id: str
    district: str
    risk_level: str
    notes: str = ""


class DroughtReportOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: str
    district: str
    risk_level: str
    ticket: str
    status: str
    created_at: datetime


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
