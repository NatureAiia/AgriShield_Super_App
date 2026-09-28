"""Drought early-warning — aggregates Part 3's district satellite zones
(still a mock grid until GEE credentials exist, see satellite_service.py)
into one district-level risk level, so a farmer or AGRITEX officer gets
one plain answer instead of reading a grid of colored squares themselves.

This is a real aggregation over whatever satellite_service returns —
mock zones today, the real Sentinel-2 pull once GEE is configured — not
a separate guess layered on top.
"""
from dataclasses import dataclass

from ..schemas import SatelliteZoneOut, ZoneStatus

_SEVERE_THRESHOLD = 0.30  # >=30% of zones in droughtRisk
_MODERATE_THRESHOLD = 0.10  # >=10%


@dataclass
class DroughtStatus:
    risk_level: str  # "None" | "Watch" | "Moderate" | "Severe"
    drought_zone_fraction: float
    stressed_zone_fraction: float
    reason: str


def assess(zones: list[SatelliteZoneOut]) -> DroughtStatus:
    if not zones:
        return DroughtStatus(risk_level="Unknown", drought_zone_fraction=0.0, stressed_zone_fraction=0.0,
                              reason="No satellite zones available.")

    total = len(zones)
    drought = sum(1 for z in zones if z.status == ZoneStatus.droughtRisk)
    stressed = sum(1 for z in zones if z.status == ZoneStatus.stressed)
    drought_fraction = drought / total
    stressed_fraction = stressed / total

    if drought_fraction >= _SEVERE_THRESHOLD:
        level = "Severe"
        reason = f"{drought * 100 // total if total else 0}% of monitored zones show drought stress — widespread, act now."
    elif drought_fraction >= _MODERATE_THRESHOLD:
        level = "Moderate"
        reason = f"{drought} of {total} monitored zones show drought risk — worth watching closely."
    elif drought > 0 or stressed_fraction >= _MODERATE_THRESHOLD:
        level = "Watch"
        reason = "A few zones show early stress — not yet widespread drought."
    else:
        level = "None"
        reason = "No drought signal in the monitored zones right now."

    return DroughtStatus(
        risk_level=level,
        drought_zone_fraction=drought_fraction,
        stressed_zone_fraction=stressed_fraction,
        reason=reason,
    )
