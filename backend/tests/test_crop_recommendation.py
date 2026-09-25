"""Module 9 crop recommendation — ranked suggestions and honesty flags
layered on top of the single `crop` answer the app already reads."""
import os

os.environ["DATABASE_URL"] = "sqlite:///:memory:"

from fastapi.testclient import TestClient  # noqa: E402

from app.main import app  # noqa: E402

client = TestClient(app)

# First row of the training data (labelled "rice").
RICE_LIKE = {
    "nitrogen": 90, "phosphorous": 42, "potassium": 43, "ph": 6.5,
    "rainfall": 202.9, "temperature": 20.88, "humidity": 82.0,
}


def test_crop_recommendation_top3_with_honesty_flags():
    r = client.post("/recommendations/crop", json=RICE_LIKE)
    assert r.status_code == 200
    body = r.json()
    assert body["crop"] == "rice"
    assert body["demo_only"] is True
    assert "not validated for Zimbabwe" in body["limitations"]
    assert len(body["suggestions"]) == 3
    assert body["suggestions"][0]["crop"] == body["crop"]
    confidences = [s["confidence"] for s in body["suggestions"]]
    assert confidences == sorted(confidences, reverse=True)
