from fastapi import APIRouter

from .. import schemas
from ..services import crop_recommendation_service

router = APIRouter(prefix="/recommendations", tags=["recommendations"])


@router.post("/crop", response_model=schemas.CropRecommendationOut)
def recommend_crop(payload: schemas.CropRecommendationIn):
    """V2 Module 6 prototype — top-3 crop suggestions from soil and
    climate inputs. Demo dataset; see the response's `limitations`."""
    return crop_recommendation_service.recommend(payload)
