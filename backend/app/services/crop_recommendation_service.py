"""V2 Module 6 prototype — ML crop suggestion alongside the rule-based
planting-window advice (docs/roadmap/V2_INTELLIGENCE_LAYER.md).

Trained at first use from the public Kaggle "Crop Recommendation
Dataset" (atharvaingle/crop-recommendation-dataset, bundled in
app/data/). The model is never loaded from a pickle — it is refit from
the CSV so there's no untrusted binary in the repo.

Said plainly: the dataset is India-oriented, has exactly 100 rows per
crop (balanced/likely augmented, not raw field records), and misses key
Zimbabwean crops (sorghum, wheat, tobacco, groundnuts, soybeans). Every
response carries demo_only=True until a local, validated dataset exists.
"""
import csv
from functools import lru_cache
from pathlib import Path

from sklearn.ensemble import RandomForestClassifier

from ..schemas import CropRecommendationIn, CropRecommendationOut, CropSuggestion

_DATA_PATH = Path(__file__).resolve().parent.parent / "data" / "crop_recommendation.csv"
_FEATURES = ["N", "P", "K", "temperature", "humidity", "ph", "rainfall"]

DATA_SOURCE = "Kaggle Crop Recommendation Dataset (atharvaingle), India-oriented"
LIMITATIONS = (
    "Demo only — not validated for Zimbabwe. Missing sorghum, wheat, tobacco, "
    "groundnuts and soybeans; needs a soil test for N/P/K and pH. Use alongside "
    "the FAO crop calendar and an extension officer, not instead of them."
)


@lru_cache(maxsize=1)
def _model() -> RandomForestClassifier:
    with _DATA_PATH.open(newline="") as f:
        rows = list(csv.DictReader(f))
    x = [[float(r[c]) for c in _FEATURES] for r in rows]
    y = [r["label"] for r in rows]
    model = RandomForestClassifier(n_estimators=100, random_state=42)
    model.fit(x, y)
    return model


def recommend(payload: CropRecommendationIn, top_n: int = 3) -> CropRecommendationOut:
    model = _model()
    features = [[
        payload.nitrogen, payload.phosphorus, payload.potassium,
        payload.temperature_c, payload.humidity_percent, payload.ph, payload.rainfall_mm,
    ]]
    probs = model.predict_proba(features)[0]
    ranked = sorted(zip(model.classes_, probs), key=lambda p: p[1], reverse=True)[:top_n]
    return CropRecommendationOut(
        suggestions=[CropSuggestion(crop=str(c), confidence=round(float(p), 3)) for c, p in ranked],
        data_source=DATA_SOURCE,
        limitations=LIMITATIONS,
    )
