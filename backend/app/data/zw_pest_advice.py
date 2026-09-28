"""Zimbabwe-specific pest/disease treatment notes.

AgriShield's server-side diagnosis (disease_model_service.py) keys its
advice off the 38 PlantVillage class labels, whose text was written for
US crops and conditions. These notes sit alongside it: registered
chemicals actually sold in Zimbabwe, pre-harvest intervals, and the
organic/cultural options extension officers teach here (push-pull, wood
ash, mulching).

Treatment content ported from a reference Express demo
(NewAI-Farming-System) built for Marondera/Mashonaland East; label rates
change, so always confirm against current AGRITEX guidance before
spraying — these notes say *what* to ask for, not the dose.
"""

# Keyed by pest key. `crops` holds the words (English, ChiShona,
# isiNdebele) that map a farmer's message to this entry.
ZW_PEST_ADVICE = {
    "fall_armyworm": {
        "pest": "Fall Armyworm",
        "scientific": "Spodoptera frugiperda",
        "crops": ["maize", "chibage", "umumbu", "mealie"],
        "signs": "Ragged windowpane holes in the whorl leaves and coarse "
        "grain-like droppings (frass) inside the funnel. Early-stage larvae "
        "feed inside the growing whorl; left alone they stunt or kill the plant.",
        "treatments": [
            "Chemical: Emamectin Benzoate 5% SG or Belt Expert "
            "(Flubendiamide) applied directly into the maize whorl at the "
            "early vegetative stage.",
            "Organic/cultural: handpick caterpillars, or put clean dry sand "
            "or fine wood ash into the funnel to suffocate larvae.",
            "Prevent: intercrop with desmodium or silverleaf (push-pull) to "
            "deter egg-laying moths, and scout twice a week for egg batches.",
        ],
        "safety": "Wear gloves and a respirator mask. Do not spray in direct "
        "midday sun. Pre-harvest interval (PHI): 14 days.",
    },
    "tomato_early_blight": {
        "pest": "Tomato Early Blight",
        "scientific": "Alternaria solani",
        "crops": ["tomato", "tomatoes", "madomasi", "amatamatisi"],
        "signs": "Concentric dark-brown rings (bullseye pattern) with yellow "
        "halos on the lower, older leaves. Spreads fast in warm, humid "
        "weather via soil splash.",
        "treatments": [
            "Chemical: Copper Oxychloride 85% WP or Mancozeb 80% WP every "
            "7 to 10 days in humid weather.",
            "Cultural: prune lower branches up to 30 cm off the ground and "
            "stake plants for airflow.",
            "Prevent: thick dry-grass mulch around stems to stop soil splash.",
        ],
        "safety": "Full protective equipment. Pre-harvest interval (PHI): "
        "7 days.",
    },
    "tobacco_aphids": {
        "pest": "Tobacco Aphids (Bushy Top vector)",
        "scientific": "Myzus persicae",
        "crops": ["tobacco", "fodya", "ugwayi"],
        "signs": "Dense colonies of small green insects under leaves, sticky "
        "honeydew, and curling leaves. Aphids spread Bushy Top Virus.",
        "treatments": [
            "Chemical: Confidor (Imidacloprid 200 SL) or Actara "
            "(Thiamethoxam) at label rates.",
            "Organic: neem-oil spray or potassium-soap solution for mild "
            "colonies.",
            "Prevent: destroy old seedbeds and volunteer tobacco stalks "
            "within about 1 km.",
        ],
        "safety": "Toxic to bees — spray late afternoon when pollinators are "
        "inactive.",
    },
    "sorghum_shoot_fly": {
        "pest": "Sorghum Shoot Fly",
        "scientific": "Atherigona soccata",
        "crops": ["sorghum", "mapfunde", "amabele"],
        "signs": "Central shoot of young seedlings wilts and dries "
        "(deadheart). Maggots bore into the growing point early in the season.",
        "treatments": [
            "Chemical: seed dressing with Imidacloprid before planting.",
            "Cultural: raise the seeding rate by about 15% and thin out "
            "damaged seedlings.",
            "Prevent: plant at the same time as neighbours so staggered "
            "crops do not carry the pest along.",
        ],
        "safety": "Chemical seed dressings need strict glove handling. Keep "
        "treated seed away from livestock.",
    },
    "maize_northern_leaf_blight": {
        "pest": "Northern Corn Leaf Blight",
        "scientific": "Exserohilum turcicum",
        "crops": ["maize", "chibage", "umumbu", "mealie"],
        "signs": "Long cigar-shaped grey-green lesions that turn tan, "
        "starting on lower leaves. Severe on susceptible hybrids in wet seasons.",
        "treatments": [
            "Chemical: Azoxystrobin + Difenoconazole (Amistar Top) at the "
            "first lesions.",
            "Cultural: rotate with legumes (soybeans/groundnuts) to break "
            "the disease cycle.",
            "Prevent: plant resistant hybrids certified for Highveld/Middleveld.",
        ],
        "safety": "Wear PPE. Pre-harvest interval (PHI): 21 days.",
    },
}

# PlantVillage model labels that get a Zimbabwe treatment note appended
# to the server-side diagnosis (see disease_model_service.py).
LABEL_OVERLAY = {
    "Corn_(maize)___Northern_Leaf_Blight": "maize_northern_leaf_blight",
    "Tomato___Early_blight": "tomato_early_blight",
}


def format_entry(entry: dict) -> str:
    """One plain-text block: signs, then numbered treatments, then safety."""
    lines = [
        f"{entry['pest']} ({entry['scientific']}). {entry['signs']}",
        "",
        *[
            f"{i}. {treatment}"
            for i, treatment in enumerate(entry["treatments"], start=1)
        ],
        "",
        f"Safety: {entry['safety']}",
    ]
    return "\n".join(lines)


def overlay_for_label(label: str) -> str | None:
    """Zimbabwe treatment note for a PlantVillage model label, if we have one."""
    key = LABEL_OVERLAY.get(label)
    if key is None:
        return None
    entry = ZW_PEST_ADVICE[key]
    return "Zimbabwe treatment note:\n" + format_entry(entry)


def lookup_crop(text: str) -> dict | None:
    """First pest entry whose crop words appear in `text` (case-insensitive)."""
    lowered = text.lower()
    for entry in ZW_PEST_ADVICE.values():
        if any(crop in lowered for crop in entry["crops"]):
            return entry
    return None
