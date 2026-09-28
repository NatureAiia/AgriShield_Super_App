"""Chemical-spraying suitability, adapted from the classic agronomy
spray-decision rules of thumb (avoid rain wash-off, wind drift, and
heat-driven evaporation/volatilization) — the same rule set every
extension-advisory tool in this space encodes, not a proprietary one.

Precedence matters: rain wash-off risk is checked first (it wastes the
whole application), then wind drift, then heat, so only genuinely clear
conditions read as "Optimal"."""
from dataclasses import dataclass

_WIND_DRIFT_THRESHOLD_KPH = 15.0
_RAIN_AVOID_PROBABILITY = 50.0
_RAIN_OPTIMAL_PROBABILITY = 40.0
_HEAT_THRESHOLD_C = 30.0


@dataclass
class SprayAdvice:
    status: str  # "Optimal" | "Avoid spraying" | "Caution — drift risk" | "Caution — high heat" | "Unknown"
    reason: str


def spray_advisory(
    temp_c: float | None,
    wind_speed_kph: float | None,
    rain_probability_max: float | None,
) -> SprayAdvice:
    if rain_probability_max is not None and rain_probability_max > _RAIN_AVOID_PROBABILITY:
        return SprayAdvice(
            status="Avoid spraying",
            reason=f"{rain_probability_max:.0f}% chance of rain — it would wash the chemical off before it works.",
        )
    if wind_speed_kph is not None and wind_speed_kph > _WIND_DRIFT_THRESHOLD_KPH:
        return SprayAdvice(
            status="Caution — drift risk",
            reason=f"Wind at {wind_speed_kph:.0f} km/h can carry spray off-target — consider waiting for calmer air.",
        )
    if temp_c is not None and temp_c > _HEAT_THRESHOLD_C:
        return SprayAdvice(
            status="Caution — high heat",
            reason=f"{temp_c:.0f}°C risks the spray evaporating before it's absorbed — early morning or evening is safer.",
        )
    if (
        wind_speed_kph is not None
        and wind_speed_kph <= _WIND_DRIFT_THRESHOLD_KPH
        and rain_probability_max is not None
        and rain_probability_max < _RAIN_OPTIMAL_PROBABILITY
    ):
        return SprayAdvice(status="Optimal", reason="Low wind and low rain chance — good conditions to spray.")
    return SprayAdvice(status="Unknown", reason="Not enough data to judge spraying conditions.")
