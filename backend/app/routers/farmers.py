from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from .. import models, schemas
from ..database import get_db

router = APIRouter(prefix="/farmers", tags=["farmers"])


@router.post("", response_model=schemas.FarmerOut)
def create_farmer(payload: schemas.FarmerIn, db: Session = Depends(get_db)):
    farmer = models.Farmer(**payload.model_dump())
    db.add(farmer)
    db.commit()
    db.refresh(farmer)
    return farmer


@router.get("/{farmer_id}", response_model=schemas.FarmerOut)
def get_farmer(farmer_id: str, db: Session = Depends(get_db)):
    farmer = db.get(models.Farmer, farmer_id)
    if farmer is None:
        raise HTTPException(status_code=404, detail="Farmer not found")
    return farmer


@router.get("", response_model=list[schemas.FarmerOut])
def list_farmers(db: Session = Depends(get_db)):
    return db.query(models.Farmer).all()
