"""Chat's keyword router — no AI call, so it works even when
ANTHROPIC_API_KEY is unset or the AI call fails (see ai_advice_service.py
and routers/chat.py). Ported concept from Sebastian's src/lib/intent.ts:
an ordered list of (pattern, route, label) tuples, first match wins,
mapped to AgriShield's own suites instead of Sebastian's.

Matches English, ChiShona and isiNdebele keywords — the offline
agronomy answers (offline_agronomy.py) reply in the same language the
farmer wrote in. Two passes: English whole-word regexes first, then
ChiShona/isiNdebele substring stems (Bantu prefixes defeat \b, and the
substring pass orders prices/disease above crop words).
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
    (re.compile(r"\b(mold|mould|rot|smells?|shelf life|cooler|cool box|zeer|temperature|humid|co2|store|storage|grain bag|pics bag)\b"),
     "storage", "Storage Sensor"),
    (re.compile(r"\b(leaf|leaves|disease|pest|armyworm|worm|blight|spots?|wilt|scan|sick plant|yellowing)\b"),
     "disease_scan", "Disease Scan"),
    (re.compile(r"\b(satellite|field map|zone|ndvi|drought|plot health|from space)\b"),
     "satellite", "Satellite Map"),
    (re.compile(r"\b(fertili[sz]er|nitrogen|phosphor|potassium|which crop|what to plant|suits|soil|recommend|compound|top dress)\b"),
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
    for keyword, route, label in _SN_NR_KEYWORDS:
        if keyword in lowered:
            return RouteMatch(route=route, label=label)
    return None


# ChiShona / isiNdebele keywords, matched as substrings on purpose: Bantu
# verb prefixes ("Nginga-", "uku-", "e-", "ku-") mean the bare stem rarely
# appears as a standalone \b word ("Ngingahlanyela" contains "hlanyela"
# but has no word boundary before it; "eRenkini" none before the R).
# These stems are distinctive enough that substring matching is safe —
# none of them occur in ordinary English text.
#
# Order matters: prices and disease beat crop words, so a message naming
# both a crop and a market ("Yimalini umumbu eRenkini?") routes to prices.
_SN_NR_KEYWORDS: list[tuple[str, str, str]] = [
    ("mutengo", "prices", "Prices"),
    ("intengo", "prices", "Prices"),
    ("musika", "prices", "Prices"),
    ("imakethe", "prices", "Prices"),
    ("mbare", "prices", "Prices"),
    ("renkini", "prices", "Prices"),
    ("sakubva", "prices", "Prices"),
    ("gmb", "prices", "Prices"),
    ("makonye", "disease_scan", "Disease Scan"),
    ("mhesvi", "disease_scan", "Disease Scan"),
    ("zvipfukuto", "disease_scan", "Disease Scan"),
    ("sibungu", "disease_scan", "Disease Scan"),
    ("mvura", "weather", "Weather"),
    ("imvula", "weather", "Weather"),
    ("mbeu", "recommendations", "Recommend"),
    ("kudyara", "recommendations", "Recommend"),
    ("hlanyela", "recommendations", "Recommend"),
    ("inhlanyelo", "recommendations", "Recommend"),
    ("fetereza", "recommendations", "Recommend"),
    ("mupfudze", "recommendations", "Recommend"),
    ("umvundiso", "recommendations", "Recommend"),
    ("pfumvudza", "recommendations", "Recommend"),
    ("intwasa", "recommendations", "Recommend"),
    ("chibage", "recommendations", "Recommend"),
    ("umumbu", "recommendations", "Recommend"),
    ("dura", "storage", "Storage Sensor"),
]
