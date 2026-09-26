"""Vercel serverless entry point.

Vercel's Python runtime serves `api/index.py` and expects the ASGI app in
the `app` variable. The real app lives in app/main.py; this shim just
re-exports it. Runs lite automatically (requirements-ml.txt isn't
installed on Vercel — see requirements.txt header and app/main.py).
"""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from app.main import app  # noqa: E402,F401
