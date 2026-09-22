from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from .. import models, schemas
from ..database import get_db

router = APIRouter(prefix="/scans", tags=["scans"])


@router.post("", response_model=schemas.DiseaseScanOut)
def log_scan(payload: schemas.DiseaseScanIn, db: Session = Depends(get_db)):
    """Part 2 sync endpoint — the disease check itself runs on-device
    offline; this just records the result once the phone is back online."""
    scan = models.DiseaseScan(**payload.model_dump())
    db.add(scan)
    db.commit()
    db.refresh(scan)
    return scan


@router.get("/{farmer_id}", response_model=list[schemas.DiseaseScanOut])
def list_scans(farmer_id: str, db: Session = Depends(get_db)):
    return (
        db.query(models.DiseaseScan)
        .filter(models.DiseaseScan.farmer_id == farmer_id)
        .order_by(models.DiseaseScan.scanned_at.desc())
        .all()
    )
