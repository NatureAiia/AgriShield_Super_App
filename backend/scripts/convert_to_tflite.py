"""One-time conversion: AgriLite-FL's original PyTorch leaf-disease
checkpoint -> ONNX -> TFLite, so the backend can run it with the
lightweight `ai-edge-litert` runtime instead of torch/torchvision
(https://github.com/marknature/AgriLite-FL, GPLv3 for the original
checkpoint/architecture).

This script's own dependencies (torch, onnx, onnx2tf, tensorflow) are
conversion-time only — none of them belong in backend/requirements.txt,
which only needs `ai-edge-litert` to run the resulting .tflite file.
Install them separately to re-run this: `pip install torch onnx onnx2tf
tensorflow`.

Verified after conversion (see the assertion at the bottom): identical
top-1 prediction and ~1.5e-5 max logit difference against the original
PyTorch model on a test image, before the .pth checkpoint was dropped
from the repo.

Run from backend/, with the original plant_disease_model.pth temporarily
placed at app/data/: `python scripts/convert_to_tflite.py`
"""
import shutil
import subprocess
import sys
from pathlib import Path

import numpy as np
import torch
import torch.nn as nn

_SCRIPTS_DIR = Path(__file__).resolve().parent
_DATA_DIR = _SCRIPTS_DIR.parent / "app" / "data"
_PTH_PATH = _DATA_DIR / "plant_disease_model.pth"
_TFLITE_OUT = _DATA_DIR / "plant_disease_model.tflite"
_WORK_DIR = _SCRIPTS_DIR / "_tflite_conversion_work"

DISEASE_CLASSES_COUNT = 38  # see disease_model_service.DISEASE_CLASSES


def _conv_block(in_channels: int, out_channels: int, pool: bool = False) -> nn.Sequential:
    layers = [
        nn.Conv2d(in_channels, out_channels, kernel_size=3, padding=1),
        nn.BatchNorm2d(out_channels),
        nn.ReLU(inplace=True),
    ]
    if pool:
        layers.append(nn.MaxPool2d(4))
    return nn.Sequential(*layers)


class ResNet9(nn.Module):
    """Must match AgriLite-FL's utils/model.py exactly for the checkpoint
    to load — duplicated here (rather than imported) so this script has
    no import-time dependency on the rest of the app package."""

    def __init__(self, in_channels: int, num_diseases: int):
        super().__init__()
        self.conv1 = _conv_block(in_channels, 64)
        self.conv2 = _conv_block(64, 128, pool=True)
        self.res1 = nn.Sequential(_conv_block(128, 128), _conv_block(128, 128))
        self.conv3 = _conv_block(128, 256, pool=True)
        self.conv4 = _conv_block(256, 512, pool=True)
        self.res2 = nn.Sequential(_conv_block(512, 512), _conv_block(512, 512))
        self.classifier = nn.Sequential(nn.MaxPool2d(4), nn.Flatten(), nn.Linear(512, num_diseases))

    def forward(self, xb):
        out = self.conv1(xb)
        out = self.conv2(out)
        out = self.res1(out) + out
        out = self.conv3(out)
        out = self.conv4(out)
        out = self.res2(out) + out
        return self.classifier(out)


def main() -> None:
    if not _PTH_PATH.exists():
        raise SystemExit(
            f"{_PTH_PATH} not found — place AgriLite-FL's original "
            "plant_disease_model.pth there before running this script."
        )

    _WORK_DIR.mkdir(exist_ok=True)
    onnx_path = _WORK_DIR / "plant_disease_model.onnx"

    model = ResNet9(3, DISEASE_CLASSES_COUNT)
    model.load_state_dict(torch.load(_PTH_PATH, map_location="cpu"))
    model.eval()

    dummy = torch.randn(1, 3, 256, 256)  # fixed 256x256 input — see disease_model_service._INPUT_SIZE
    torch.onnx.export(
        model, dummy, str(onnx_path),
        input_names=["input"], output_names=["output"],
        opset_version=13, dynamic_axes=None, dynamo=False,
    )
    print(f"wrote {onnx_path}")

    subprocess.run(
        [sys.executable, "-m", "onnx2tf", "-i", str(onnx_path), "-o", str(_WORK_DIR / "tflite_out")],
        check=True,
    )

    float32_tflite = _WORK_DIR / "tflite_out" / "plant_disease_model_float32.tflite"
    shutil.copy(float32_tflite, _TFLITE_OUT)
    print(f"wrote {_TFLITE_OUT}")

    _verify(model, _TFLITE_OUT)
    shutil.rmtree(_WORK_DIR)


def _verify(torch_model: "ResNet9", tflite_path: Path) -> None:
    """Sanity check: same input, same predicted class, near-identical logits."""
    from ai_edge_litert.interpreter import Interpreter

    rng = np.random.default_rng(42)
    sample = rng.random((1, 256, 256, 3), dtype=np.float32)  # NHWC, matches disease_model_service

    with torch.no_grad():
        torch_out = torch_model(torch.from_numpy(sample).permute(0, 3, 1, 2)).numpy()[0]

    interp = Interpreter(model_path=str(tflite_path))
    interp.allocate_tensors()
    in_details = interp.get_input_details()[0]
    out_details = interp.get_output_details()[0]
    interp.set_tensor(in_details["index"], sample.astype(in_details["dtype"]))
    interp.invoke()
    tflite_out = interp.get_tensor(out_details["index"])[0]

    assert np.argmax(torch_out) == np.argmax(tflite_out), "TFLite conversion changed the predicted class"
    max_diff = float(np.max(np.abs(torch_out - tflite_out)))
    print(f"verified: same top-1 prediction, max logit diff {max_diff:.2e}")


if __name__ == "__main__":
    main()
