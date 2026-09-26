"""cPanel Passenger entry point (Tremhost shared hosting).

cPanel's "Setup Python App" asks for a startup file — point it here.
Passenger imports ``application`` from this file; the FastAPI app itself
lives in app/main.py and needs no changes for Passenger.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))

from app.main import app as application  # noqa: E402,F401
