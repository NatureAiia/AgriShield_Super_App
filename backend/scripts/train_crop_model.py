"""Retrains app/data/crop_recommendation_model.pkl.

AgriLite-FL's own shipped RandomForest.pkl
(https://github.com/marknature/AgriLite-FL, GPLv3) was pickled with
scikit-learn 0.23.2 (2020) and fails to unpickle on current scikit-learn
— the internal tree node-array format changed and raises a ValueError on
load. Rather than pin an ancient scikit-learn, this retrains a fresh
model from the same public training data AgriLite-FL used
(Data-processed/crop_recommendation.csv there — the standard Kaggle
"Crop Recommendation Dataset", copied here as
crop_recommendation_training_data.csv), at 99.1% held-out accuracy with
20 estimators on the last retrain.

Run from backend/: `python scripts/train_crop_model.py`
"""
import pickle
from pathlib import Path

import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
from sklearn.model_selection import train_test_split

_SCRIPTS_DIR = Path(__file__).resolve().parent
_OUT_PATH = _SCRIPTS_DIR.parent / "app" / "data" / "crop_recommendation_model.pkl"

# Column order matches recommendation_service.recommend_crop exactly —
# changing it here requires changing that function too.
FEATURE_COLUMNS = ["N", "P", "K", "ph", "rainfall", "temperature", "humidity"]


def main() -> None:
    df = pd.read_csv(_SCRIPTS_DIR / "crop_recommendation_training_data.csv")
    X = df[FEATURE_COLUMNS]
    y = df["label"]

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )

    model = RandomForestClassifier(n_estimators=20, random_state=42)
    model.fit(X_train, y_train)

    accuracy = accuracy_score(y_test, model.predict(X_test))
    print(f"held-out accuracy: {accuracy:.4f}")

    with open(_OUT_PATH, "wb") as f:
        pickle.dump(model, f)
    print(f"wrote {_OUT_PATH}")


if __name__ == "__main__":
    main()
