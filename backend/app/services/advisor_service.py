"""AGRITEX advisor hub — no real extension-officer directory is
integrated yet (this would need a data-sharing agreement with
Zimbabwe's Department of Agricultural, Technical and Extension
Services), so this returns clearly-labeled placeholder roles rather
than inventing real people's names or phone numbers. Swap `_ADVISORS`
for a real directory feed once one exists — nothing else changes.
"""
from ..schemas import AdvisorOut

_SOURCE = (
    "No AGRITEX officer directory is integrated yet — these are placeholder "
    "roles for the request/dispatch flow, not real contacts. Replace "
    "_ADVISORS with a real district directory feed when one is available."
)

_ADVISORS: list[AdvisorOut] = [
    AdvisorOut(id="placeholder-1", name="District AGRITEX Officer", role="Extension Officer", district="Your district", phone=""),
    AdvisorOut(id="placeholder-2", name="Crop Health Specialist", role="Research Specialist", district="Provincial office", phone=""),
]


def list_advisors() -> tuple[list[AdvisorOut], str]:
    return _ADVISORS, _SOURCE
