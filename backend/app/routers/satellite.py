from fastapi import APIRouter

from .. import schemas
from ..services import satellite_service

router = APIRouter(prefix="/satellite", tags=["satellite"])


@router.get("/zones", response_model=list[schemas.SatelliteZoneOut])
def get_zones():
    return satellite_service.get_zones()
