import random

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from .. import models, schemas
from ..database import get_db
from ..services import drought_service, satellite_service

router = APIRouter(prefix="/drought", tags=["drought"])

_SOURCE = (
    "Aggregated from Part 3's district satellite zones (Sentinel-2/GEE — "
    "mocked until GEE_SERVICE_ACCOUNT_JSON is configured, see satellite_service.py). "
    "A district-level early signal, not a confirmed drought declaration."
)


def _new_ticket() -> str:
    return f"DRT-{random.randint(100000, 999999)}"


@router.get("/status", response_model=schemas.DroughtStatusOut)
def drought_status():
    zones = satellite_service.get_zones()
    assessment = drought_service.assess(zones)
    return schemas.DroughtStatusOut(
        risk_level=assessment.risk_level,
        drought_zone_fraction=assessment.drought_zone_fraction,
        stressed_zone_fraction=assessment.stressed_zone_fraction,
        reason=assessment.reason,
        data_source=_SOURCE,
    )


@router.post("/report", response_model=schemas.DroughtReportOut)
def report_drought(payload: schemas.DroughtReportIn, db: Session = Depends(get_db)):
    """Logs a drought escalation and hands back a ticket — there's no
    real government/civil-protection dispatch behind this yet, same as
    the AGRITEX advisor hub's request flow."""
    report = models.DroughtReport(
        farmer_id=payload.farmer_id,
        district=payload.district,
        risk_level=payload.risk_level,
        notes=payload.notes,
        ticket=_new_ticket(),
    )
    db.add(report)
    db.commit()
    db.refresh(report)
    return report
