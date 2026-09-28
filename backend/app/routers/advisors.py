import random

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from .. import models, schemas
from ..database import get_db
from ..services import advisor_service

router = APIRouter(prefix="/advisors", tags=["advisors"])


def _new_ticket() -> str:
    return f"REQ-{random.randint(100000, 999999)}"


@router.get("", response_model=schemas.AdvisorsOut)
def list_advisors():
    advisors, source = advisor_service.list_advisors()
    return schemas.AdvisorsOut(advisors=advisors, data_source=source)


@router.post("/request", response_model=schemas.AdvisorRequestOut)
def request_advisor(payload: schemas.AdvisorRequestIn, db: Session = Depends(get_db)):
    """Logs the request and hands back a ticket — there's no real
    dispatch to an extension officer behind this yet (see
    services/advisor_service.py), same as MessagingService's mock alert
    channel until a real integration exists."""
    request = models.AdvisorRequest(
        farmer_id=payload.farmer_id,
        advisor_id=payload.advisor_id,
        request_type=payload.request_type.value,
        notes=payload.notes,
        ticket=_new_ticket(),
    )
    db.add(request)
    db.commit()
    db.refresh(request)
    return request
