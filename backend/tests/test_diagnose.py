"""Server leaf diagnosis (open-source AgriLite-FL ResNet9, PlantVillage).
Skipped automatically where the ML extras (requirements-ml.txt) aren't
installed, since the route is compiled out there."""
import io

import pytest

pytest.importorskip("ai_edge_litert")
from PIL import Image, ImageDraw  # noqa: E402
from fastapi.testclient import TestClient  # noqa: E402

from app.main import app  # noqa: E402

client = TestClient(app)


def _leaf_jpeg() -> bytes:
    im = Image.new("RGB", (300, 300), (30, 60, 30))
    ImageDraw.Draw(im).ellipse((30, 80, 270, 220), fill=(70, 140, 50))
    buf = io.BytesIO()
    im.save(buf, format="JPEG")
    return buf.getvalue()


def test_diagnose_returns_structured_result():
    r = client.post("/scans/diagnose", files={"file": ("leaf.jpg", _leaf_jpeg(), "image/jpeg")})
    assert r.status_code == 200
    body = r.json()
    assert body["likely_issue"] and body["advice"]
    assert 0 < body["confidence"] <= 1
    assert isinstance(body["treatment"], list)
    assert isinstance(body["healthy"], bool)
    assert body["crop"] and body["disease"]


def test_diagnose_rejects_non_image():
    r = client.post("/scans/diagnose", files={"file": ("x.jpg", b"not an image", "image/jpeg")})
    assert r.status_code == 422
