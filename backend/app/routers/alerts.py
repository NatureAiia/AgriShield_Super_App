from fastapi import APIRouter

from .. import schemas
from ..services import messaging_service

router = APIRouter(prefix="/alerts", tags=["alerts"])


@router.post("/send", response_model=schemas.AlertResult)
def send_alert(payload: schemas.AlertRequest):
    return messaging_service.send_alert(farmer_name=payload.farmer.name, message=payload.message)
