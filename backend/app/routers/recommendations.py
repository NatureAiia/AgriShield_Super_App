from fastapi import APIRouter, HTTPException

from .. import schemas
from ..services import recommendation_service

router = APIRouter(prefix="/recommendations", tags=["recommendations"])


@router.post("/crop", response_model=schemas.CropRecommendationOut)
def crop_recommendation(payload: schemas.CropRecommendationIn):
    crop = recommendation_service.recommend_crop(
        nitrogen=payload.nitrogen,
        phosphorous=payload.phosphorous,
        potassium=payload.potassium,
        ph=payload.ph,
        rainfall=payload.rainfall,
        temperature=payload.temperature,
        humidity=payload.humidity,
    )
    return schemas.CropRecommendationOut(crop=crop)


@router.post("/fertilizer", response_model=schemas.FertilizerRecommendationOut)
def fertilizer_recommendation(payload: schemas.FertilizerRecommendationIn):
    try:
        result = recommendation_service.recommend_fertilizer(
            crop=payload.crop,
            nitrogen=payload.nitrogen,
            phosphorous=payload.phosphorous,
            potassium=payload.potassium,
        )
    except ValueError as exc:
        raise HTTPException(status_code=422, detail=str(exc)) from exc
    return schemas.FertilizerRecommendationOut(**result)
