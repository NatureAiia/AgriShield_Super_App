"""V2 Module 6 prototype — crop recommendation endpoint."""
import os

os.environ["DATABASE_URL"] = "sqlite:///:memory:"

from fastapi.testclient import TestClient  # noqa: E402

from app.main import app  # noqa: E402

client = TestClient(app)

# First row of the bundled dataset (labelled "rice").
RICE_LIKE = {
    "nitrogen": 90, "phosphorus": 42, "potassium": 43, "temperature_c": 20.88,
    "humidity_percent": 82.0, "ph": 6.5, "rainfall_mm": 202.9,
}


def test_recommend_crop_top3_with_honesty_flags():
    r = client.post("/recommendations/crop", json=RICE_LIKE)
    assert r.status_code == 200
    body = r.json()
    assert body["demo_only"] is True
    assert "not validated for Zimbabwe" in body["limitations"]
    assert len(body["suggestions"]) == 3
    assert body["suggestions"][0]["crop"] == "rice"
    confidences = [s["confidence"] for s in body["suggestions"]]
    assert confidences == sorted(confidences, reverse=True)


def test_recommend_crop_rejects_out_of_range_ph():
    r = client.post("/recommendations/crop", json={**RICE_LIKE, "ph": 15})
    assert r.status_code == 422
