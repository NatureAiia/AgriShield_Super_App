"""Part 3 — district satellite view.

Real implementation pulls Sentinel-2 imagery via Google Earth Engine
(docs/roadmap/V1_HACKATHON_DEMO.md), which needs a GEE service-account
credential that isn't configured (settings.gee_configured is False by
default). get_zones() returns a fixed mock grid in that case, matching
the same shape the Flutter app's MockSatelliteService falls back to
locally when the backend itself is unreachable — so the map screen
degrades the same way whether it's this mock or total offline.
"""
from ..config import settings
from ..schemas import SatelliteZoneOut, ZoneStatus

_MOCK_STATUSES = [
    ZoneStatus.healthy, ZoneStatus.healthy, ZoneStatus.stressed,
    ZoneStatus.healthy, ZoneStatus.droughtRisk, ZoneStatus.stressed,
    ZoneStatus.healthy, ZoneStatus.healthy, ZoneStatus.healthy,
]


def get_zones(farmer_plot_index: int = 4) -> list[SatelliteZoneOut]:
    if settings.gee_configured:
        # TODO: real Earth Engine pull once a service account is
        # configured — not implemented, since no credential exists yet.
        raise NotImplementedError("GEE integration not implemented — unset GEE_SERVICE_ACCOUNT_JSON to use the mock.")

    return [
        SatelliteZoneOut(id=f"zone-{i}", status=status, is_farmer_plot=(i == farmer_plot_index))
        for i, status in enumerate(_MOCK_STATUSES)
    ]
