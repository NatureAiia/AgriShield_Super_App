import random
from datetime import datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from .. import models, schemas
from ..database import get_db

router = APIRouter(prefix="/auth", tags=["auth"])

_OTP_TTL = timedelta(minutes=10)


@router.post("/request-otp", response_model=schemas.OtpRequestOut)
def request_otp(payload: schemas.OtpRequestIn, db: Session = Depends(get_db)):
    """Foundation — phone-number sign-in. No SMS credentials exist yet
    (see app/models.py's OtpCode docstring), so the generated code is
    returned directly instead of being texted."""
    code = f"{random.randint(0, 9999):04d}"
    db.add(models.OtpCode(phone=payload.phone, code=code))
    db.commit()
    return schemas.OtpRequestOut(code=code)


@router.post("/verify-otp", response_model=schemas.OtpVerifyOut)
def verify_otp(payload: schemas.OtpVerifyIn, db: Session = Depends(get_db)):
    cutoff = datetime.utcnow() - _OTP_TTL
    otp = (
        db.query(models.OtpCode)
        .filter(
            models.OtpCode.phone == payload.phone,
            models.OtpCode.code == payload.code,
            models.OtpCode.consumed.is_(False),
            models.OtpCode.created_at >= cutoff,
        )
        .order_by(models.OtpCode.created_at.desc())
        .first()
    )
    if otp is None:
        raise HTTPException(status_code=400, detail="Invalid or expired code")

    otp.consumed = True
    db.commit()

    farmer = db.query(models.Farmer).filter(models.Farmer.phone == payload.phone).first()
    return schemas.OtpVerifyOut(verified=True, farmer=farmer)
