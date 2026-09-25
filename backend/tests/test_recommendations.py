"""Checks V2's crop/fertilizer recommendation and server-side disease
diagnosis endpoints (docs/roadmap/V2_INTELLIGENCE_LAYER.md), ported from
AgriLite-FL. Run with: pytest (after `pip install -r requirements.txt`).
"""
import io
import os

os.environ["DATABASE_URL"] = "sqlite:///:memory:"

from fastapi.testclient import TestClient  # noqa: E402
from PIL import Image  # noqa: E402

from app.main import app  # noqa: E402

client = TestClient(app)


def test_crop_recommendation():
    r = client.post(
        "/recommendations/crop",
        json={
            "nitrogen": 90, "phosphorous": 42, "potassium": 43,
            "ph": 6.5, "rainfall": 200, "temperature": 25, "humidity": 80,
        },
    )
    assert r.status_code == 200
    assert isinstance(r.json()["crop"], str) and r.json()["crop"]


def test_fertilizer_recommendation_for_known_crop():
    r = client.post(
        "/recommendations/fertilizer",
        json={"crop": "maize", "nitrogen": 10, "phosphorous": 10, "potassium": 10},
    )
    assert r.status_code == 200
    body = r.json()
    assert body["nutrient"] in {"N", "P", "K"}
    assert body["direction"] in {"high", "low"}
    assert body["advice"]


def test_fertilizer_recommendation_for_unknown_crop():
    r = client.post(
        "/recommendations/fertilizer",
        json={"crop": "not-a-real-crop", "nitrogen": 10, "phosphorous": 10, "potassium": 10},
    )
    assert r.status_code == 422


def test_disease_diagnosis():
    buf = io.BytesIO()
    Image.new("RGB", (256, 256), color=(60, 140, 60)).save(buf, format="JPEG")
    buf.seek(0)

    r = client.post("/scans/diagnose", files={"file": ("leaf.jpg", buf, "image/jpeg")})
    assert r.status_code == 200
    body = r.json()
    assert body["likely_issue"]
    assert body["advice"]


def test_disease_diagnosis_rejects_non_image():
    r = client.post("/scans/diagnose", files={"file": ("not-image.txt", io.BytesIO(b"hello"), "text/plain")})
    assert r.status_code == 422
