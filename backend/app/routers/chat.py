""""Ask AgriShield" — a farmer types a question in plain language and
gets routed to the right suite, with a conversational reply on top when
ANTHROPIC_API_KEY is configured. Concept ported from Sebastian's
src/app/api/chat/route.ts (POST /api/chat, ok/error/ai_unavailable
contract), simplified to one router (advice_router.py) that runs
whether or not the AI is available, since it's the part farmers can
always rely on."""
from fastapi import APIRouter

from ..schemas import ChatIn, ChatOut
from ..services import advice_router, ai_advice_service, offline_agronomy

router = APIRouter(prefix="/chat", tags=["chat"])


@router.post("", response_model=ChatOut)
def chat(payload: ChatIn):
    match = advice_router.local_intent(payload.message)
    route = match.route if match else None
    route_label = match.label if match else None

    try:
        reply = ai_advice_service.ask(
            payload.message,
            [{"role": m.role, "content": m.content} for m in payload.history],
        )
        return ChatOut(reply=reply, route=route, route_label=route_label)
    except ai_advice_service.AIUnavailable:
        # Still useful without the AI: the offline agronomy engine answers
        # common questions in English/ChiShona/isiNdebele, and the keyword
        # router alone tells the farmer which suite answers the rest.
        reply = offline_agronomy.answer(payload.message, payload.language) or ""
        code = None if reply else "ai_unavailable"
        return ChatOut(reply=reply, route=route, route_label=route_label, code=code)
