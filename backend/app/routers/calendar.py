from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from .. import models, schemas
from ..database import get_db

router = APIRouter(prefix="/calendar", tags=["calendar"])


@router.get("/{farmer_id}", response_model=list[schemas.ActivityOut])
def list_activities(farmer_id: str, db: Session = Depends(get_db)):
    return (
        db.query(models.Activity)
        .filter(models.Activity.farmer_id == farmer_id)
        .order_by(models.Activity.scheduled_for.asc())
        .all()
    )


@router.post("", response_model=schemas.ActivityOut)
def create_activity(payload: schemas.ActivityIn, db: Session = Depends(get_db)):
    activity = models.Activity(**payload.model_dump())
    db.add(activity)
    db.commit()
    db.refresh(activity)
    return activity


@router.patch("/{activity_id}/toggle", response_model=schemas.ActivityOut)
def toggle_activity(activity_id: str, db: Session = Depends(get_db)):
    activity = db.query(models.Activity).filter(models.Activity.id == activity_id).first()
    if activity is None:
        raise HTTPException(status_code=404, detail="Activity not found")
    activity.status = "completed" if activity.status == "pending" else "pending"
    db.commit()
    db.refresh(activity)
    return activity


@router.delete("/{activity_id}")
def delete_activity(activity_id: str, db: Session = Depends(get_db)):
    activity = db.query(models.Activity).filter(models.Activity.id == activity_id).first()
    if activity is None:
        raise HTTPException(status_code=404, detail="Activity not found")
    db.delete(activity)
    db.commit()
    return {"ok": True}
