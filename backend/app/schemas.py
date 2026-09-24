from datetime import datetime
from enum import Enum

from pydantic import BaseModel, ConfigDict, Field


class FarmerIn(BaseModel):
    name: str
    location: str
    crop: str
    storage_hub: str


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


class DiseaseScanIn(BaseModel):
    farmer_id: str
    likely_issue: str
    confidence: float


class DiseaseScanOut(DiseaseScanIn):
    model_config = ConfigDict(from_attributes=True)
    id: str
    scanned_at: datetime


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


class CropRecommendationIn(BaseModel):
    """Soil values need a soil test (N/P/K on the dataset's own scale, pH);
    climate values can come from Module 4 weather / Part 3 satellite."""
    nitrogen: float = Field(ge=0, le=200)
    phosphorus: float = Field(ge=0, le=200)
    potassium: float = Field(ge=0, le=250)
    temperature_c: float = Field(ge=-10, le=55)
    humidity_percent: float = Field(ge=0, le=100)
    ph: float = Field(ge=0, le=14)
    rainfall_mm: float = Field(ge=0, le=500)


class CropSuggestion(BaseModel):
    crop: str
    confidence: float


class CropRecommendationOut(BaseModel):
    suggestions: list[CropSuggestion]
    demo_only: bool = True
    data_source: str
    limitations: str
