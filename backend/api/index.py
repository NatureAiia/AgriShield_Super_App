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

# Vercel debug marker: proves this exact file is what Vercel serves, and
# dumps every registered route to the Runtime Logs at cold start. Remove
# once the production 404s are resolved.
try:
    _paths = sorted({getattr(r, "path", "?") for r in app.routes})
    print("AgriShield routes:", _paths, flush=True)
except Exception as e:  # pragma: no cover
    print("AgriShield route dump failed:", e, flush=True)


@app.get("/api/ping")
def vercel_ping():
    return {
        "pong": True,
        "routes": sorted({getattr(r, "path", "?") for r in app.routes}),
    }
