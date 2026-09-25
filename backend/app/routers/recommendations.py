from fastapi import APIRouter, HTTPException

from .. import schemas
from ..services import recommendation_service

router = APIRouter(prefix="/recommendations", tags=["recommendations"])


@router.post("/crop", response_model=schemas.CropRecommendationOut)
def crop_recommendation(payload: schemas.CropRecommendationIn):
    inputs = dict(
        nitrogen=payload.nitrogen,
        phosphorous=payload.phosphorous,
        potassium=payload.potassium,
        ph=payload.ph,
        rainfall=payload.rainfall,
        temperature=payload.temperature,
        humidity=payload.humidity,
    )
    crop = recommendation_service.recommend_crop(**inputs)
    return schemas.CropRecommendationOut(
        crop=crop,
        suggestions=[
            schemas.CropSuggestion(crop=c, confidence=p)
            for c, p in recommendation_service.crop_suggestions(**inputs)
        ],
        data_source=recommendation_service.CROP_DATA_SOURCE,
        limitations=recommendation_service.CROP_LIMITATIONS,
    )


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
