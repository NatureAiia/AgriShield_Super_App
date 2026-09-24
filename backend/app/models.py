"""SQLAlchemy models — V1 scope only.

Deliberately smaller than prototype/schema.sql's sketch: this backend
implements the Foundation + Parts 1-3 (docs/roadmap/V1_HACKATHON_DEMO.md).
insurance_policies and bnpl_loans from the prototype schema are V3-only and
gated on real partners that don't exist yet (see
docs/roadmap/V3_ECOSYSTEM_FINANCE_MARKET.md) — they don't belong in a V1
backend and aren't included here.
"""
import uuid
from datetime import datetime

from sqlalchemy import DateTime, Float, ForeignKey, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .database import Base


def _uuid() -> str:
    return str(uuid.uuid4())


class Farmer(Base):
    __tablename__ = "farmers"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=_uuid)
    name: Mapped[str] = mapped_column(String, nullable=False)
    location: Mapped[str] = mapped_column(String, nullable=False)
    crop: Mapped[str] = mapped_column(String, nullable=False)
    storage_hub: Mapped[str] = mapped_column(String, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    storage_readings: Mapped[list["StorageReading"]] = relationship(back_populates="farmer")
    disease_scans: Mapped[list["DiseaseScan"]] = relationship(back_populates="farmer")


class StorageReading(Base):
    """Part 1 — one reading from the solar sensor box.

    co2_ppm follows the vision doc's OPIsystems citation (§5.2): temperature,
    dampness, and CO2 are the three real signals used to catch spoiling
    grain early, since rotting/infested grain breathes out extra CO2 before
    anything is visible.
    """

    __tablename__ = "storage_readings"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=_uuid)
    farmer_id: Mapped[str] = mapped_column(String, ForeignKey("farmers.id"))
    temperature_c: Mapped[float] = mapped_column(Float, nullable=False)
    humidity_percent: Mapped[float] = mapped_column(Float, nullable=False)
    co2_ppm: Mapped[float] = mapped_column(Float, nullable=False, default=420.0)
    taken_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    farmer: Mapped["Farmer"] = relationship(back_populates="storage_readings")


class DiseaseScan(Base):
    """Part 2 — one disease-check result. `source` distinguishes the
    original on-device offline check (logged when the phone next syncs)
    from V2's server-side diagnosis (backend/app/services/disease_model_service.py),
    which both write to this same table."""

    __tablename__ = "disease_scans"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=_uuid)
    farmer_id: Mapped[str] = mapped_column(String, ForeignKey("farmers.id"))
    likely_issue: Mapped[str] = mapped_column(String, nullable=False)
    confidence: Mapped[float] = mapped_column(Float, nullable=False)
    source: Mapped[str] = mapped_column(String, nullable=False, default="on_device")
    scanned_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    farmer: Mapped["Farmer"] = relationship(back_populates="disease_scans")
