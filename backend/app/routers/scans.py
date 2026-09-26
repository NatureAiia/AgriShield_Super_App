import os

from fastapi import APIRouter, Depends, HTTPException, UploadFile
from sqlalchemy.orm import Session

from .. import models, schemas
from ..database import get_db

router = APIRouter(prefix="/scans", tags=["scans"])

# The server-side diagnosis model needs numpy/ai-edge-litert/Pillow, which
# shared hosting often can't install — so this one route is compiled out
# when AGRISHIELD_LITE=1 (see backend/requirements-cpanel.txt). Scan
# *logging* below stays: history works in lite mode, diagnosis doesn't.
if os.getenv("AGRISHIELD_LITE") != "1":

    @router.post("/diagnose", response_model=schemas.DiseaseDiagnosisOut)
    async def diagnose(file: UploadFile):
        """V2 addition — a server-side second opinion using AgriLite-FL's
        PyTorch model (docs/roadmap/V2_INTELLIGENCE_LAYER.md), alongside
        Part 1's original on-device TFLite check. Returns a diagnosis only;
        POST the result to `/scans` with source="server" to log it, same as
        the on-device flow does."""
        from ..services import disease_model_service  # lazy: heavy deps

        image_bytes = await file.read()
        try:
            label, advice = disease_model_service.diagnose(image_bytes)
        except Exception as exc:
            raise HTTPException(status_code=422, detail=f"Could not diagnose image: {exc}") from exc
        return schemas.DiseaseDiagnosisOut(likely_issue=label, advice=advice)


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
