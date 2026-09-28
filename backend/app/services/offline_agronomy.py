"""Offline multilingual agronomy answers — the chat fallback that works
with no AI key, no connection beyond the backend, and no new dependency.

When ANTHROPIC_API_KEY is unset (or the AI call fails), routers/chat.py
answers from here instead of returning an empty reply. English, ChiShona
(`sn`) and isiNdebele (`nr`) share one intent set; pest answers come from
the same Zimbabwe treatment notes (data/zw_pest_advice.py) the
server-side diagnosis uses, so there is a single source of truth.

Deliberately never states prices: AgriShield has no live market feed,
so price questions get an honest pointer to the Prices screen instead of
a guessed number.

Agronomy content (rates, hybrids, planting windows) ported from a
reference Express demo built for Mashonaland East; confirm against
current AGRITEX guidance before treating it as prescription.
"""
from ..data import zw_pest_advice
import re

_EN = "en"
_SN = "sn"
_NR = "nr"

_GREETING_SN = (
    "Mhoro! Ndinokubatsira nezvekurima: mhando dzembeu, nguva yekudyara, "
    "kudzora Fall Armyworm, fetereza yePfumvudza, kana mamiriro ekupfapfaidza."
)
_GREETING_NR = (
    "Salibonani! Ngingakusiza ngezikhatshi zokuhlanyela, ukulawula izibungu, "
    "umvundiso we-Intwasa, kumbe isimo sokufafaza."
)
_GREETING_EN = (
    "Hello! I can help with seed choices, planting time, pest control, "
    "fertilizer, and spraying weather. What are you growing?"
)

_FERTILIZER = {
    _EN: "For maize (Regions II & III): Compound D at planting — about 300 "
    "kg/ha, or one bottle-cap per Pfumvudza basin. Top-dress with Ammonium "
    "Nitrate (AN) when the maize is knee-high (4–6 weeks after emergence), "
    "ideally into moist soil.",
    _SN: "Panyaya yefetereza yechibage (Region II & III): isai Compound D "
    "(kapu imwe pachiguri chePfumvudza) panguva yekudyara. Kana chibage "
    "chava pamabvi (mavhiki 4–6 mushure mekumera), isai Ammonium Nitrate "
    "(AN) muvhu nyoro.",
    _NR: "Nge general fertilizer ngaphansi kwe-Intwasa/Pfumvudza: faka "
    "i-Compound D (isivalo sebhodlela emgodini ngamunye) lapho uhlanyela. "
    "Nxa umumbu usufika emadolweni (emavikini a-4–6 ngemva kokuvela), faka "
    "i-Ammonium Nitrate (AN) emhlabathini omanzi.",
}

_SEED = {
    _EN: "For Region II (Marondera, Mazowe): medium-to-late hybrids like "
    "Seed Co SC 637, SC 719, or PAN 53 (7–10 t/ha potential). Plant after "
    "25–30 mm of effective rain, usually late November to early December.",
    _SN: "KuMashonaland (Region II): dyarai mbeu dzakaita se SC 637, SC 719, "
    "kana PAN 53. Dyarai panongonaya mvura inokwana 25–30 mm, pakati "
    "paMbudzi naZvita.",
    _NR: "ESifundeni II (Marondera, Mazowe): hlanyela inzalo ezinjenge SC 637, "
    "SC 719, kumbe PAN 53. Hlanyela ngemva kwemvula eneleyo engu-25–30 mm, "
    "phakathi kukaNovemba noDisemba.",
}

_SPRAY = {
    _EN: "Spray early morning (06:00–09:00) or late afternoon: wind below "
    "15 km/h, rain chance below 40%, and below 30°C — otherwise the chemical "
    "drifts, washes off, or evaporates. Check the Weather screen before you mix.",
    _SN: "Pfapfaidzai mangwanani (06:00–09:00) kana manheru: mhepo iri pasi "
    "pe 15 km/h, mukana wemvura uri pasi pe 40%, uye tembiricha iri pasi pe "
    "30°C. Tarisai mamiriro ekunze musati masanganisa mushonga.",
    _NR: "Fafaza ekuseni (06:00–09:00) kumbe ntambama: umoya ungaphansi kwe "
    "15 km/h, ithuba lemvula lingaphansi kuka-40%, lokushisa kungaphansi "
    "kuka-30°C. Hlola isimo sezulu ngaphambi kokuxuba umuthi.",
}

_NO_PRICES = {
    _EN: "I don't have live market prices in the app yet — the Prices "
    "screen shows the latest dated snapshot when the team enters one. For "
    "today's trade, confirm at the market (Mbare, Sakubva, Renkini) or the "
    "GMB depot before you travel.",
    _SN: "Handina mitengo yemusika iripo parizvino — chidzitiro cheMitengo "
    "chinoratidza zvichangoburwa kana zvapinzwa. Simbisai pamusika (Mbare, "
    "Sakubva, Renkini) kana kuGMB musati mafamba.",
    _NR: "Kakunawo amanani emakethe aphilayo okwakhathesi — ikhasi "
    "leMakethe likhombisa okuseduze nxa sekufakiwe. Qinisekisa emakethe "
    "(Mbare, Sakubva, Renkini) kumbe e-GMB ngaphambi kokuhamba.",
}

# Language markers: words that strongly suggest the farmer wrote in
# ChiShona or isiNdebele. Checked before the English keywords.
_SN_MARKERS = [
    "mbeu", "chibage", "fetereza", "mupfudze", "mutengo", "musika",
    "mvura", "makonye", "mhoro", "kudyara", "mhesvi", "zvipfukuto",
    "dota", "mushonga", "kudzora", "nguva", "rinhi", "chii",
]
_NR_MARKERS = [
    "umumbu", "umvundiso", "intengo", "imakethe", "isibungu", "sibungu",
    "salibonani", "hlanyela", "inhlanyelo", "ukuhlanyela", "faka", "umuthi",
    "isimo", "khona",
]


def detect_language(message: str, explicit: str | None = None) -> str:
    """`explicit` ('en'/'sn'/'nr', e.g. from the app's language picker)
    wins; otherwise guess from marker words, defaulting to English."""
    if explicit in (_EN, _SN, _NR):
        return explicit
    lowered = (message or "").lower()
    if any(marker in lowered for marker in _NR_MARKERS):
        return _NR
    if any(marker in lowered for marker in _SN_MARKERS):
        return _SN
    return _EN


def _has_any(lowered: str, words: list[str]) -> bool:
    return any(word in lowered for word in words)


def _has_word(lowered: str, words: list[str]) -> bool:
    """Whole-word match — so 'hi' the greeting never fires on 'chibage'."""
    return any(re.search(r"\b" + re.escape(word) + r"\b", lowered) for word in words)


def answer(message: str, language: str | None = None) -> str | None:
    """Best offline answer, or None when nothing matches (the router then
    falls back to the route label alone, as before)."""
    lang = detect_language(message, explicit=language)
    lowered = (message or "").lower()

    if _has_word(lowered, ["hello", "hi", "mhoro", "salibonani", "help", "rubatsiro", "usizo"]):
        return {_EN: _GREETING_EN, _SN: _GREETING_SN, _NR: _GREETING_NR}[lang]

    if _has_any(
        lowered,
        ["fertiliz", "fertilis", "compound", "top dress", "top-dress",
         "nitrogen", "phosphor", "potassium", "pfumvudza", "intwasa",
         "fetereza", "mupfudze", "umvundiso", "an ", " ammonium"],
    ):
        return _FERTILIZER[lang]

    pest = zw_pest_advice.lookup_crop(lowered)
    if pest is not None or _has_any(
        lowered,
        ["armyworm", "pest", "worm", "blight", "disease", "sick",
         "makonye", "mhesvi", "zvipfukuto", "isibungu", "sibungu",
         "spots", "wilt", "yellowing"],
    ):
        if pest is None:
            pest = zw_pest_advice.ZW_PEST_ADVICE["fall_armyworm"]
        return zw_pest_advice.format_entry(pest)

    if _has_any(
        lowered,
        ["plant", "seed", "variety", "hybrid", "sow", "when to", "suit", "soil",
         "mbeu", "kudyara", "hlanyela", "inhlanyelo", "rinhi"],
    ):
        return _SEED[lang]

    if _has_any(
        lowered,
        ["spray", "weather", "rain", "wind", "forecast",
         "mvura", "imvula", "isimo", "pfapfaidza", "fafaza"],
    ):
        return _SPRAY[lang]

    if _has_any(
        lowered,
        ["price", "market", "sell", "cost", "how much",
         "mutengo", "musika", "intengo", "imakethe", "mbare",
         "renkini", "sakubva", "gmb"],
    ):
        return _NO_PRICES[lang]

    return None
