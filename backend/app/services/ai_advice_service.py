"""Conversational half of the "Ask AgriShield" chat feature — the AI
call the keyword router (advice_router.py) doesn't need. Concept ported
from Sebastian's src/lib/server/ai.ts (aiConfigured/AIUnavailable/
errorResponse pattern), wired to the real Anthropic Messages API rather
than Sebastian's Groq call.

Uses only the stdlib (urllib), same as weather.py — no new dependency
for one POST call.
"""
import json
import urllib.error
import urllib.request

from ..config import settings

_ANTHROPIC_MESSAGES_URL = "https://api.anthropic.com/v1/messages"
_ANTHROPIC_VERSION = "2023-06-01"

SYSTEM_PROMPT = (
    "You are AgriShield's assistant, helping a smallholder farmer in "
    "Zimbabwe. Keep answers short, plain, and practical — this may be "
    "read aloud or read on a small screen with a weak connection. Never "
    "claim you took an action (sent an alert, saved data, booked "
    "something) — you can only answer and suggest where in the app to "
    "go. Never invent prices, weather, or sensor readings; if you don't "
    "have real data, say so plainly rather than guessing. If the "
    "question is really about crop storage, disease, satellite field "
    "health, planting/fertilizer advice, weather, or market prices, say "
    "so briefly and let the app's own suggested link do the rest."
)


class AIUnavailable(Exception):
    """Raised when ANTHROPIC_API_KEY isn't set, or the API refuses/fails —
    routers/chat.py catches this and falls back to the keyword router
    alone, same as Sebastian's chat UI does on its ai_unavailable code."""


def configured() -> bool:
    return settings.anthropic_configured


def ask(message: str, history: list[dict]) -> str:
    """history: list of {"role": "user"|"assistant", "content": str},
    oldest first, NOT including `message` itself."""
    if not configured():
        raise AIUnavailable("ANTHROPIC_API_KEY is not set")

    # Trim like Sebastian's chat route (ai.ts / route.ts): bound both the
    # number of turns and each turn's length before it ever reaches the API.
    trimmed = [
        {"role": m["role"], "content": m["content"][:4000]}
        for m in history[-16:]
    ]
    trimmed.append({"role": "user", "content": message[:4000]})

    body = json.dumps({
        "model": settings.anthropic_model,
        "max_tokens": 512,
        "system": SYSTEM_PROMPT,
        "messages": trimmed,
    }).encode("utf-8")

    req = urllib.request.Request(
        _ANTHROPIC_MESSAGES_URL,
        data=body,
        method="POST",
        headers={
            "content-type": "application/json",
            "x-api-key": settings.anthropic_api_key,
            "anthropic-version": _ANTHROPIC_VERSION,
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=20) as resp:
            data = json.load(resp)
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        if exc.code == 401:
            raise AIUnavailable(f"Anthropic API key rejected: {detail}") from exc
        if exc.code == 429:
            raise AIUnavailable(f"Anthropic rate limit hit: {detail}") from exc
        if exc.code in (400, 404):
            raise AIUnavailable(f"Anthropic model/request rejected: {detail}") from exc
        raise AIUnavailable(f"Anthropic call failed ({exc.code}): {detail}") from exc
    except urllib.error.URLError as exc:
        raise AIUnavailable(f"Anthropic unreachable: {exc}") from exc

    try:
        parts = data["content"]
        return "".join(p.get("text", "") for p in parts if p.get("type") == "text").strip()
    except (KeyError, TypeError) as exc:
        raise AIUnavailable(f"Unexpected Anthropic response shape: {exc}") from exc
