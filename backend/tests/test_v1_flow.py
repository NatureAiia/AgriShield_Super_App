"""End-to-end check of the V1 flow: create a farmer, sync a storage
reading and a disease scan, fetch the mock satellite zones, and trigger a
mock alert. Run with: pytest (after `pip install -r requirements-dev.txt`).
"""
import os

os.environ["DATABASE_URL"] = "sqlite:///:memory:"

from fastapi.testclient import TestClient  # noqa: E402

from app.main import app  # noqa: E402

client = TestClient(app)


def test_health():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json() == {"status": "ok"}


def test_v1_flow():
    r = client.post(
        "/farmers",
        json={"name": "Tendai Moyo", "location": "Harare South", "crop": "Maize", "storage_hub": "Mbare Collection Point"},
    )
    assert r.status_code == 200
    farmer = r.json()

    r = client.post(
        "/storage/readings",
        json={"farmer_id": farmer["id"], "temperature_c": 31.5, "humidity_percent": 68.0, "co2_ppm": 1350.0},
    )
    assert r.status_code == 200
    assert r.json()["co2_ppm"] == 1350.0

    r = client.get(f"/storage/readings/{farmer['id']}")
    assert r.status_code == 200
    assert len(r.json()) == 1

    r = client.post(
        "/scans",
        json={"farmer_id": farmer["id"], "likely_issue": "Maize Northern Leaf Blight", "confidence": 0.94},
    )
    assert r.status_code == 200

    r = client.get("/satellite/zones")
    assert r.status_code == 200
    zones = r.json()
    assert len(zones) == 9
    assert any(z["is_farmer_plot"] for z in zones)

    r = client.post(
        "/alerts/send",
        json={"farmer": {k: farmer[k] for k in ("name", "location", "crop", "storage_hub")}, "message": "14 hours left"},
    )
    assert r.status_code == 200
    assert r.json()["sent"] is True
