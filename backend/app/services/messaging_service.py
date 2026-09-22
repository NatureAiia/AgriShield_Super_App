"""Foundation — the one communication channel, Africa's Talking
(SMS/USSD/voice), reused by every part rather than each building its own
(docs/roadmap/README.md).

Real sending needs an Africa's Talking API key that isn't configured
(settings.africastalking_configured is False by default). send_alert()
logs the message instead in that case — good enough to prove the alert
pipeline end-to-end (phone triggers → backend "sends") without an actual
account, and it's the one function a real integration replaces.
"""
import logging

from ..config import settings
from ..schemas import AlertResult

logger = logging.getLogger("agrishield.messaging")


def send_alert(farmer_name: str, message: str) -> AlertResult:
    if settings.africastalking_configured:
        # TODO: call the Africa's Talking API once credentials are
        # configured — not implemented, since no account exists yet.
        raise NotImplementedError(
            "Africa's Talking integration not implemented — unset AFRICASTALKING_* to use the mock."
        )

    logger.info("[MOCK ALERT] to=%s message=%r", farmer_name, message)
    return AlertResult(sent=True, channel="mock-log", detail=f"Logged (not actually sent) to {farmer_name}")
