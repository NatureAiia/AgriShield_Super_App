from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import or_
from sqlalchemy.orm import Session

from .. import models, schemas
from ..database import get_db

router = APIRouter(prefix="/farmers", tags=["farmers"])


@router.post("", response_model=schemas.FarmerOut)
def create_farmer(payload: schemas.FarmerIn, db: Session = Depends(get_db)):
    normalized_phone = payload.phone.lstrip('+')
    existing = db.query(models.Farmer).filter(
        or_(models.Farmer.phone == payload.phone, models.Farmer.phone == normalized_phone)
    ).first()
    if existing is not None:
        raise HTTPException(status_code=409, detail="A farmer already exists for this phone number")
    farmer = models.Farmer(**payload.model_dump())
    db.add(farmer)
    db.commit()
    db.refresh(farmer)
    return farmer


@router.get("/by-phone/{phone}", response_model=schemas.FarmerOut)
def get_farmer_by_phone(phone: str, db: Session = Depends(get_db)):
    """Sign-in: no password or code, just a phone-number lookup — see
    Farmer's docstring in app/models.py for why that's an intentional
    demo-scope tradeoff, not an oversight."""
    try:
        normalized_phone = phone.lstrip('+')
        farmer = db.query(models.Farmer).filter(
            or_(models.Farmer.phone == phone, models.Farmer.phone == normalized_phone)
        ).first()
        if farmer is None:
            raise HTTPException(status_code=404, detail="No account for this phone number")
        return farmer
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error fetching farmer by phone {phone}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Internal server error: {str(e)}")


@router.get("/{farmer_id}", response_model=schemas.FarmerOut)
def get_farmer(farmer_id: str, db: Session = Depends(get_db)):
    farmer = db.get(models.Farmer, farmer_id)
    if farmer is None:
        raise HTTPException(status_code=404, detail="Farmer not found")
    return farmer


@router.get("", response_model=list[schemas.FarmerOut])
def list_farmers(db: Session = Depends(get_db)):
    return db.query(models.Farmer).all()


@router.patch("/{farmer_id}", response_model=schemas.FarmerOut)
def update_farmer(farmer_id: str, payload: schemas.FarmerUpdate, db: Session = Depends(get_db)):
    farmer = db.get(models.Farmer, farmer_id)
    if farmer is None:
        raise HTTPException(status_code=404, detail="Farmer not found")
    
    update_data = payload.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(farmer, key, value)
    
    db.commit()
    db.refresh(farmer)
    return farmer
