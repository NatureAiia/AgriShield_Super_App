"""Crop + fertilizer recommendation — ported from AgriLite-FL's
app/app.py `crop_prediction`/`fert_recommend` routes and
app/utils/fertilizer.py (https://github.com/marknature/AgriLite-FL,
GPLv3), reworked into plain data/JSON instead of server-rendered HTML.

crop_recommendation_model.pkl is a scikit-learn RandomForestClassifier
trained on N/P/K/pH/rainfall/temperature/humidity -> crop name.
AgriLite-FL's own shipped pickle was saved with scikit-learn 0.23.2
(2020) and fails to unpickle on current scikit-learn (tree node-array
format changed) — this one is retrained from the same public training
data (AgriLite-FL's Data-processed/crop_recommendation.csv, the
standard Kaggle "Crop Recommendation Dataset") instead, 99.1% held-out
accuracy with 20 estimators. Loaded once at import time.
"""
import pickle
from functools import lru_cache
from pathlib import Path

import pandas as pd

from ..data.fertilizer_advice import FERTILIZER_ADVICE

_DATA_DIR = Path(__file__).resolve().parent.parent / "data"


@lru_cache(maxsize=1)
def _crop_model():
    with open(_DATA_DIR / "crop_recommendation_model.pkl", "rb") as f:
        return pickle.load(f)


@lru_cache(maxsize=1)
def _fertilizer_table() -> pd.DataFrame:
    return pd.read_csv(_DATA_DIR / "fertilizer.csv")


def recommend_crop(
    nitrogen: float,
    phosphorous: float,
    potassium: float,
    ph: float,
    rainfall: float,
    temperature: float,
    humidity: float,
) -> str:
    """Column names/order must match training (scripts/train_crop_model.py)
    exactly — scikit-learn checks the DataFrame's column names against
    what the model was fit on and warns (or errors) on a mismatch."""
    columns = ["N", "P", "K", "ph", "rainfall", "temperature", "humidity"]
    row = [[nitrogen, phosphorous, potassium, ph, rainfall, temperature, humidity]]
    prediction = _crop_model().predict(pd.DataFrame(row, columns=columns))
    return str(prediction[0])


CROP_DATA_SOURCE = "Kaggle Crop Recommendation Dataset (via AgriLite-FL), India-oriented"
CROP_LIMITATIONS = (
    "Demo only — not validated for Zimbabwe. Missing sorghum, wheat, tobacco, "
    "groundnuts and soybeans; needs a soil test for N/P/K and pH. Use alongside "
    "the FAO crop calendar and an extension officer, not instead of them."
)


def crop_suggestions(
    nitrogen: float,
    phosphorous: float,
    potassium: float,
    ph: float,
    rainfall: float,
    temperature: float,
    humidity: float,
    top_n: int = 3,
) -> list[tuple[str, float]]:
    """Top-N crops with the model's class probability, highest first —
    lets the app show alternatives and how sure the model is, not just
    one bare answer."""
    columns = ["N", "P", "K", "ph", "rainfall", "temperature", "humidity"]
    row = [[nitrogen, phosphorous, potassium, ph, rainfall, temperature, humidity]]
    model = _crop_model()
    probs = model.predict_proba(pd.DataFrame(row, columns=columns))[0]
    ranked = sorted(zip(model.classes_, probs), key=lambda p: p[1], reverse=True)[:top_n]
    return [(str(c), round(float(p), 3)) for c, p in ranked]


def recommend_fertilizer(crop: str, nitrogen: float, phosphorous: float, potassium: float) -> dict:
    df = _fertilizer_table()
    rows = df[df["Crop"].str.lower() == crop.lower()]
    if rows.empty:
        raise ValueError(f"No fertilizer reference data for crop '{crop}'")
    row = rows.iloc[0]

    n_delta = row["N"] - nitrogen
    p_delta = row["P"] - phosphorous
    k_delta = row["K"] - potassium
    deltas = {"N": n_delta, "P": p_delta, "K": k_delta}
    nutrient = max(deltas, key=lambda k: abs(deltas[k]))
    delta = deltas[nutrient]

    # delta < 0 means the farmer's value exceeds the crop's ideal (too
    # high); delta > 0 means it falls short (too low). Mirrors
    # AgriLite-FL's fert_recommend route exactly. Keys are NHigh/Nlow,
    # PHigh/Plow, KHigh/Klow.
    key = f"{nutrient}High" if delta < 0 else f"{nutrient}low"

    return {
        "nutrient": nutrient,
        "direction": "high" if delta < 0 else "low",
        "advice": FERTILIZER_ADVICE[key],
    }
