"""V2 Module 5 — market prices. Zimbabwe's Agricultural Marketing
Authority publishes real vegetable/horticultural prices across four
markets (Mbare, Sakubva, Chipadze, Renkini), but there is no public
machine-readable feed for them — so this endpoint deliberately returns
an empty list with the source note instead of inventing numbers
(docs/roadmap/V2_INTELLIGENCE_LAYER.md: grain prices are a named gap,
not a guess). Fill in _SNAPSHOT from a dated AMA bulletin when the
pilot needs one, or point this at a scraper — never hardcode guesses.
"""
from fastapi import APIRouter

from ..schemas import PriceSnapshot, PricesOut

router = APIRouter(prefix="/prices", tags=["prices"])

# Dated snapshot entries go here, e.g.:
# PriceSnapshot(commodity="Tomatoes", market="Mbare",
#               price_usd_per_kg=0.80, observed="2026-09-20", source="AMA bulletin")
_SNAPSHOT: list[PriceSnapshot] = []

_SOURCE = (
    "Zimbabwe Agricultural Marketing Authority (vegetables/horticulture only; "
    "Mbare, Sakubva, Chipadze, Renkini). No machine-readable feed exists, so "
    "this returns a dated snapshot — empty until the pilot team enters one."
)


@router.get("/vegetables", response_model=PricesOut)
def vegetable_prices():
    return PricesOut(prices=_SNAPSHOT, data_source=_SOURCE)
