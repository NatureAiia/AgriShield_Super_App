"""Server-side leaf-disease diagnosis — an alternative to Part 2's
on-device TFLite checker, for phones that can't run the on-device model
or as a heavier second opinion. Ported from AgriLite-FL's app/app.py
(`predict_image`) and app/utils/model.py's ResNet9 architecture
(https://github.com/marknature/AgriLite-FL, GPLv3), then converted from
the original PyTorch checkpoint to TFLite (PyTorch -> ONNX -> onnx2tf ->
.tflite, see scripts/convert_to_tflite.py) so this backend only needs
the lightweight `ai-edge-litert` runtime instead of torch/torchvision —
~18MB installed vs. torch+torchvision's several hundred MB+. Verified
against the original PyTorch model before the .pth was dropped from the
repo: identical top-1 prediction, max output logit difference ~6e-6.
"""
import io
import re
from functools import lru_cache
from pathlib import Path

import numpy as np
from ai_edge_litert.interpreter import Interpreter
from PIL import Image, ImageOps

from ..data.disease_advice import DISEASE_ADVICE
from ..data.zw_pest_advice import overlay_for_label

_DATA_DIR = Path(__file__).resolve().parent.parent / "data"
_MODEL_PATH = _DATA_DIR / "plant_disease_model.tflite"

# Order matches the model's output layer exactly — it was trained against
# this exact class ordering (PlantVillage), not looked up by name.
DISEASE_CLASSES = [
    "Apple___Apple_scab", "Apple___Black_rot", "Apple___Cedar_apple_rust", "Apple___healthy",
    "Blueberry___healthy",
    "Cherry_(including_sour)___Powdery_mildew", "Cherry_(including_sour)___healthy",
    "Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot", "Corn_(maize)___Common_rust_",
    "Corn_(maize)___Northern_Leaf_Blight", "Corn_(maize)___healthy",
    "Grape___Black_rot", "Grape___Esca_(Black_Measles)",
    "Grape___Leaf_blight_(Isariopsis_Leaf_Spot)", "Grape___healthy",
    "Orange___Haunglongbing_(Citrus_greening)",
    "Peach___Bacterial_spot", "Peach___healthy",
    "Pepper,_bell___Bacterial_spot", "Pepper,_bell___healthy",
    "Potato___Early_blight", "Potato___Late_blight", "Potato___healthy",
    "Raspberry___healthy",
    "Soybean___healthy",
    "Squash___Powdery_mildew",
    "Strawberry___Leaf_scorch", "Strawberry___healthy",
    "Tomato___Bacterial_spot", "Tomato___Early_blight", "Tomato___Late_blight",
    "Tomato___Leaf_Mold", "Tomato___Septoria_leaf_spot",
    "Tomato___Spider_mites Two-spotted_spider_mite", "Tomato___Target_Spot",
    "Tomato___Tomato_Yellow_Leaf_Curl_Virus", "Tomato___Tomato_mosaic_virus", "Tomato___healthy",
]

# The model graph was traced/converted at a fixed 256x256 input — unlike
# the original PyTorch code's aspect-preserving `Resize(256)` (which only
# actually worked for already-square photos, since the architecture's
# final MaxPool2d(4) requires an exact 4x4 feature map to reach the
# Linear layer), this resizes directly to 256x256 so any input photo
# produces a valid fixed-size tensor.
_INPUT_SIZE = (256, 256)


@lru_cache(maxsize=1)
def _interpreter() -> Interpreter:
    interp = Interpreter(model_path=str(_MODEL_PATH))
    interp.allocate_tensors()
    return interp


def _run_model(image_bytes: bytes) -> np.ndarray:
    """Returns class probabilities (softmax over the model's logits)."""
    image = Image.open(io.BytesIO(image_bytes))
    image = ImageOps.exif_transpose(image)  # phone photos: respect rotation
    image = image.convert("RGB").resize(_INPUT_SIZE)
    array = np.asarray(image, dtype=np.float32) / 255.0  # HWC, matches ToTensor()'s [0,1] scaling
    array = np.expand_dims(array, axis=0)  # -> NHWC (TFLite's layout, vs. PyTorch's NCHW)

    interp = _interpreter()
    input_details = interp.get_input_details()[0]
    output_details = interp.get_output_details()[0]
    interp.set_tensor(input_details["index"], array.astype(input_details["dtype"]))
    interp.invoke()
    logits = interp.get_tensor(output_details["index"])[0].astype(np.float64)
    exp = np.exp(logits - logits.max())
    return exp / exp.sum()


def diagnose(image_bytes: bytes) -> tuple[str, str]:
    """Returns (disease_label, advice_text). Raises on unparseable images —
    the router is responsible for turning that into a 4xx."""
    probs = _run_model(image_bytes)
    label = DISEASE_CLASSES[int(np.argmax(probs))]
    advice = DISEASE_ADVICE[label]
    overlay = overlay_for_label(label)
    if overlay is not None:
        advice = advice + "\n\n" + overlay
    return label, advice


def pretty_label(label: str) -> tuple[str, str]:
    """'Corn_(maize)___Common_rust_' -> ('Maize', 'Common rust')."""
    crop, _, disease = label.partition("___")
    crop = crop.replace("_", " ").replace(",", "").strip()
    crop = {"Corn (maize)": "Maize", "Cherry (including sour)": "Cherry", "Pepper bell": "Bell pepper"}.get(crop, crop)
    disease = disease.replace("_", " ").strip()
    if disease.lower() == "healthy":
        disease = "Healthy"
    disease = disease[:1].upper() + disease[1:]
    return crop, disease


def _split_advice(text: str) -> tuple[list[str], list[str]]:
    """Splits AgriLite-FL's plain-text advice into (causes, treatment)
    lists of numbered points. Anything unrecognised lands in treatment, so
    no advice is ever dropped."""
    causes: list[str] = []
    treatment: list[str] = []
    bucket = None
    for raw in text.split("\n"):
        line = raw.strip()
        if not line or line.startswith(("Crop:", "Crop :", "Disease:")):
            continue
        low = line.lower()
        if low.startswith("cause of disease"):
            bucket = causes
            continue
        if low.startswith("how to prevent"):
            bucket = treatment
            continue
        line = re.sub(r"^(\d+|[a-z])[.)]\s*", "", line).strip()
        if line:
            (bucket if bucket is not None else treatment).append(line)
    return causes, treatment


# Below this top-1 probability the photo is probably blurry, not a leaf,
# or a crop/disease the model was never trained on.
LOW_CONFIDENCE = 0.70


def diagnose_detailed(image_bytes: bytes) -> dict:
    """Full result for the app: best match with confidence, the next two
    possibilities, and the advice split into causes / what to do, plus the
    Zimbabwe-specific note where one exists."""
    probs = _run_model(image_bytes)
    order = np.argsort(probs)[::-1]
    best = DISEASE_CLASSES[int(order[0])]
    crop, disease = pretty_label(best)
    advice = DISEASE_ADVICE[best]
    causes, treatment = _split_advice(advice)
    overlay = overlay_for_label(best)
    confidence = float(probs[order[0]])
    alternatives = []
    for idx in order[1:4]:
        c, d = pretty_label(DISEASE_CLASSES[int(idx)])
        p = float(probs[idx])
        if p >= 0.03:
            alternatives.append({"crop": c, "disease": d, "confidence": round(p, 4)})
    return {
        "likely_issue": f"{crop} — {disease}",
        "advice": advice + ("\n\n" + overlay if overlay else ""),
        "label": best,
        "crop": crop,
        "disease": disease,
        "healthy": best.endswith("___healthy"),
        "confidence": round(confidence, 4),
        "low_confidence": confidence < LOW_CONFIDENCE,
        "causes": causes,
        "treatment": treatment,
        "local_note": overlay,
        "alternatives": alternatives,
        "model": "AgriLite-FL ResNet9 · PlantVillage (38 classes, 14 crops) · open source, GPLv3",
    }
