from datetime import datetime
from enum import Enum

from pydantic import BaseModel, ConfigDict


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
