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
    """Also the Foundation's sign-up/sign-in identity: phone is unique, and
    signing in is just looking a farmer up by phone (see
    app/routers/farmers.py's /by-phone/{phone}) — no password or code, on
    purpose, to keep this a one-step, low-friction flow for a demo."""

    __tablename__ = "farmers"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=_uuid)
    phone: Mapped[str] = mapped_column(String, unique=True, nullable=False, index=True)
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


class AdvisorRequest(Base):
    """AGRITEX advisor hub — a farmer's request for a farm visit, a
    disease escalation, or a general consultation. No real extension-
    officer directory is integrated yet (services/advisor_service.py
    returns a labeled placeholder list), so this only logs the request
    and hands back a ticket; there's no real dispatch behind it, same
    honesty convention as MessagingService's mock alert channel."""

    __tablename__ = "advisor_requests"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=_uuid)
    farmer_id: Mapped[str] = mapped_column(String, ForeignKey("farmers.id"))
    advisor_id: Mapped[str | None] = mapped_column(String, nullable=True)
    request_type: Mapped[str] = mapped_column(String, nullable=False)
    notes: Mapped[str] = mapped_column(String, nullable=False, default="")
    ticket: Mapped[str] = mapped_column(String, nullable=False, unique=True)
    status: Mapped[str] = mapped_column(String, nullable=False, default="submitted")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class Activity(Base):
    """Spraying & activity calendar — a scheduled farm task (usually a
    spray triggered by a disease diagnosis, but any farm activity fits).
    Persisted per farmer so the calendar and the home dashboard's
    "next activity" card can both read it."""

    __tablename__ = "activities"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=_uuid)
    farmer_id: Mapped[str] = mapped_column(String, ForeignKey("farmers.id"))
    title: Mapped[str] = mapped_column(String, nullable=False)
    notes: Mapped[str] = mapped_column(String, nullable=False, default="")
    scheduled_for: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    status: Mapped[str] = mapped_column(String, nullable=False, default="pending")
    source: Mapped[str] = mapped_column(String, nullable=False, default="manual")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)


class DroughtReport(Base):
    """Drought early-warning escalation — a farmer (or, later, an AGRITEX
    officer) flags a district's satellite-derived drought risk level up
    to government/civil-protection contacts. No real government channel
    is integrated yet (services/drought_service.py only aggregates the
    still-mocked satellite feed), so this only logs the report and hands
    back a ticket, same honesty convention as AdvisorRequest."""

    __tablename__ = "drought_reports"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=_uuid)
    farmer_id: Mapped[str] = mapped_column(String, ForeignKey("farmers.id"))
    district: Mapped[str] = mapped_column(String, nullable=False)
    risk_level: Mapped[str] = mapped_column(String, nullable=False)
    notes: Mapped[str] = mapped_column(String, nullable=False, default="")
    ticket: Mapped[str] = mapped_column(String, nullable=False, unique=True)
    status: Mapped[str] = mapped_column(String, nullable=False, default="submitted")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
