"""Chat's keyword router — no AI call, so it works even when
ANTHROPIC_API_KEY is unset or the AI call fails (see ai_advice_service.py
and routers/chat.py). Ported concept from Sebastian's src/lib/intent.ts:
an ordered list of (pattern, route, label) tuples, first match wins,
mapped to AgriShield's own suites instead of Sebastian's.
"""
import re
from dataclasses import dataclass


@dataclass
class RouteMatch:
    route: str
    label: str


# Order matters — more specific phrasing (e.g. "mold") is checked before
# the broad "storage" catch-all it would otherwise also match.
_ROUTES: list[tuple[re.Pattern, str, str]] = [
    (re.compile(r"\b(mold|mould|rot|smell|shelf life|cooler|cool box|zeer|temperature|humid|co2|store|storage|grain bag|pics bag)\b"),
     "storage", "Storage Sensor"),
    (re.compile(r"\b(leaf|leaves|disease|pest|blight|spots?|wilt|scan|sick plant|yellowing)\b"),
     "disease_scan", "Disease Scan"),
    (re.compile(r"\b(satellite|field map|zone|ndvi|drought|plot health|from space)\b"),
     "satellite", "Satellite Map"),
    (re.compile(r"\b(fertili[sz]er|nitrogen|phosphor|potassium|which crop|what to plant|soil ph|recommend)\b"),
     "recommendations", "Recommend"),
    (re.compile(r"\b(weather|rain|forecast|planting time|is it going to rain)\b"),
     "weather", "Weather"),
    (re.compile(r"\b(price|prices|sell|market|afford|how much (is|for)|cost of)\b"),
     "prices", "Prices"),
]


def local_intent(text: str) -> RouteMatch | None:
    lowered = text.lower()
    for pattern, route, label in _ROUTES:
        if pattern.search(lowered):
            return RouteMatch(route=route, label=label)
    return None
