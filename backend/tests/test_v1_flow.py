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
        json={
            "phone": "+263771234567",
            "name": "Tendai Moyo",
            "location": "Harare South",
            "crop": "Maize",
            "storage_hub": "Mbare Collection Point",
        },
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
        json={"farmer": {k: farmer[k] for k in ("phone", "name", "location", "crop", "storage_hub")}, "message": "14 hours left"},
    )
    assert r.status_code == 200
    assert r.json()["sent"] is True


def test_phone_otp_sign_up_and_sign_in():
    phone = "+263779998888"

    # A brand-new number: verify-otp succeeds but no farmer exists yet.
    r = client.post("/auth/request-otp", json={"phone": phone})
    assert r.status_code == 200
    code = r.json()["code"]

    r = client.post("/auth/verify-otp", json={"phone": phone, "code": code})
    assert r.status_code == 200
    body = r.json()
    assert body["verified"] is True
    assert body["farmer"] is None

    # A used code can't be replayed.
    r = client.post("/auth/verify-otp", json={"phone": phone, "code": code})
    assert r.status_code == 400

    # Complete sign-up with that verified phone.
    r = client.post(
        "/farmers",
        json={"phone": phone, "name": "Rudo Chikafu", "location": "Bulawayo", "crop": "Sorghum", "storage_hub": "Bulawayo Depot"},
    )
    assert r.status_code == 200

    # A second sign-up for the same phone is rejected.
    r = client.post(
        "/farmers",
        json={"phone": phone, "name": "Someone Else", "location": "X", "crop": "Y", "storage_hub": "Z"},
    )
    assert r.status_code == 409

    # Signing back in with that phone now returns the existing farmer.
    r = client.post("/auth/request-otp", json={"phone": phone})
    code = r.json()["code"]
    r = client.post("/auth/verify-otp", json={"phone": phone, "code": code})
    assert r.status_code == 200
    body = r.json()
    assert body["verified"] is True
    assert body["farmer"]["name"] == "Rudo Chikafu"

    # The wrong code is rejected.
    r = client.post("/auth/request-otp", json={"phone": phone})
    r = client.post("/auth/verify-otp", json={"phone": phone, "code": "0000"})
    assert r.status_code == 400
