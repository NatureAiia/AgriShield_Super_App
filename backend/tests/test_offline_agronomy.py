"""Offline multilingual chat + Zimbabwe pest notes.

Pure unit tests (no DB) plus one /chat endpoint test with the Anthropic
call stubbed out, so the offline fallback is exercised deterministically.
Run with: pytest (after `pip install -r requirements-dev.txt`).
"""
import os

os.environ["DATABASE_URL"] = "sqlite:///:memory:"

from fastapi.testclient import TestClient  # noqa: E402

from app.data import zw_pest_advice  # noqa: E402
from app.main import app  # noqa: E402
from app.services import advice_router, ai_advice_service, offline_agronomy  # noqa: E402

client = TestClient(app)


def test_detect_language_defaults_english():
    assert offline_agronomy.detect_language("When should I plant maize?") == "en"


def test_detect_language_shona_and_ndebele():
    assert offline_agronomy.detect_language("Ndingadyara mbeu rinhi?") == "sn"
    assert offline_agronomy.detect_language("Ngingahlanyela nini umumbu?") == "nr"


def test_explicit_language_wins():
    assert offline_agronomy.detect_language("mutengo", explicit="en") == "en"


def test_answer_fertilizer_english():
    reply = offline_agronomy.answer("How much Compound D per hectare?")
    assert reply is not None
    assert "Compound D" in reply


def test_answer_fertilizer_shona():
    reply = offline_agronomy.answer("Ndiudze nezve fetereza yechibage")
    assert reply is not None
    assert "Compound D" in reply


def test_answer_armyworm_uses_zw_treatments():
    reply = offline_agronomy.answer("Fall armyworm is eating my maize")
    assert reply is not None
    assert "Emamectin Benzoate" in reply
    assert "14 days" in reply


def test_answer_prices_never_invents_numbers():
    for message in (
        "What is the maize price?",
        "Mutengo wechibage nhasi?",
        "Yimalini umumbu eRenkini?",
    ):
        reply = offline_agronomy.answer(message)
        assert reply is not None
        assert "220" not in reply  # honesty: no guessed prices, ever


def test_answer_unknown_returns_none():
    assert offline_agronomy.answer("What is the capital of France?") is None


def test_zw_overlay_for_known_labels():
    overlay = zw_pest_advice.overlay_for_label("Tomato___Early_blight")
    assert overlay is not None
    assert "Mancozeb" in overlay
    overlay = zw_pest_advice.overlay_for_label("Corn_(maize)___Northern_Leaf_Blight")
    assert overlay is not None
    assert "Amistar Top" in overlay


def test_zw_overlay_unknown_label_returns_none():
    assert zw_pest_advice.overlay_for_label("Apple___Apple_scab") is None


def test_router_shona_and_ndebele_intents():
    assert advice_router.local_intent("Ndingadyara mbeu rinhi?").route == "recommendations"
    assert advice_router.local_intent("Mutengo wechibage?").route == "prices"
    assert advice_router.local_intent("Mvura ichanaya rinhi?").route == "weather"
    assert advice_router.local_intent("Makonye ari mudura rechibage").route == "disease_scan"


def test_chat_falls_back_to_offline_reply(monkeypatch):
    def _no_ai(message, history):
        raise ai_advice_service.AIUnavailable("no key")

    monkeypatch.setattr(ai_advice_service, "ask", _no_ai)
    r = client.post("/chat", json={"message": "Makonye ari kuchibage changu"})
    assert r.status_code == 200
    body = r.json()
    assert body["route"] == "disease_scan"
    assert "Emamectin Benzoate" in body["reply"]
    assert body["code"] is None  # answered offline, not ai_unavailable


def test_chat_still_ai_unavailable_when_nothing_matches(monkeypatch):
    def _no_ai(message, history):
        raise ai_advice_service.AIUnavailable("no key")

    monkeypatch.setattr(ai_advice_service, "ask", _no_ai)
    r = client.post("/chat", json={"message": "What is the capital of France?"})
    assert r.status_code == 200
    body = r.json()
    assert body["reply"] == ""
    assert body["code"] == "ai_unavailable"
