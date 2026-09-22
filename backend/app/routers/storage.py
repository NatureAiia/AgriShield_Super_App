from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from .. import models, schemas
from ..database import get_db

router = APIRouter(prefix="/storage", tags=["storage"])


@router.post("/readings", response_model=schemas.StorageReadingOut)
def log_reading(payload: schemas.StorageReadingIn, db: Session = Depends(get_db)):
    """Part 1 sync endpoint — the phone stores readings locally first
    (offline-first) and syncs them here once a connection returns."""
    reading = models.StorageReading(**payload.model_dump())
    db.add(reading)
    db.commit()
    db.refresh(reading)
    return reading


@router.get("/readings/{farmer_id}", response_model=list[schemas.StorageReadingOut])
def list_readings(farmer_id: str, db: Session = Depends(get_db)):
    return (
        db.query(models.StorageReading)
        .filter(models.StorageReading.farmer_id == farmer_id)
        .order_by(models.StorageReading.taken_at.desc())
        .all()
    )
