"""Numerical Weather Prediction (NWP) Multi-Model Ensemble Comparison Service."""
import logging
from datetime import datetime, timedelta, timezone
from typing import Dict, Any, List, Optional
import httpx
from app.schemas.nwp import (
    NwpModelOutput,
    DailyNwpComparison,
    NwpModelMetadata,
    MultiModelComparisonResponse,
)

logger = logging.getLogger(__name__)

# Model Registry Metadata
NWP_MODELS_METADATA = [
    NwpModelMetadata(
        model_id="ecmwf_ifs025",
        full_name="ECMWF IFS (Integrated Forecasting System)",
        agency="European Centre for Medium-Range Weather Forecasts",
        country="European Union / United Kingdom",
        resolution="25 km (0.25° Grid)",
        primary_strength="Global benchmark for synoptic steering, tropical cyclogenesis, and medium-range pressure tracking.",
    ),
    NwpModelMetadata(
        model_id="gfs_seamless",
        full_name="NOAA GFS (Global Forecast System)",
        agency="National Centers for Environmental Prediction (NCEP / NOAA)",
        country="United States",
        resolution="25 km (0.25° Grid)",
        primary_strength="High 6-hourly cycle operational tempo and broad atmospheric dynamic balance.",
    ),
    NwpModelMetadata(
        model_id="icon_seamless",
        full_name="DWD ICON (Icosahedral Nonhydrostatic Model)",
        agency="Deutscher Wetterdienst (German Weather Service)",
        country="Germany",
        resolution="13 km Triangular Global Grid",
        primary_strength="Superior convective parameterization, complex terrain boundary-layer airflow, and moisture tracking.",
    ),
]


class NwpComparisonService:
    """Service to ingest, cross-evaluate, and calculate multi-model NWP consensus and spread."""

    def __init__(self):
        self.client = httpx.AsyncClient(timeout=12.0)

    async def get_multi_model_comparison(
        self,
        lat: float,
        lon: float,
        location_name: str = "Location",
        days: int = 5,
    ) -> MultiModelComparisonResponse:
        """Fetch and cross-compare ECMWF, GFS, and ICON forecasts."""
        days = min(max(days, 3), 7)
        url = "https://api.open-meteo.com/v1/forecast"
        params = {
            "latitude": round(lat, 4),
            "longitude": round(lon, 4),
            "daily": "precipitation_sum,temperature_2m_max,temperature_2m_min",
            "models": "ecmwf_ifs025,gfs_seamless,icon_seamless",
            "forecast_days": days,
            "timezone": "auto",
        }

        raw_data: Optional[Dict[str, Any]] = None
        elevation: Optional[float] = None

        try:
            resp = await self.client.get(url, params=params)
            if resp.status_code == 200:
                raw_data = resp.json()
                elevation = raw_data.get("elevation")
            else:
                logger.warning(f"Open-Meteo multi-model returned status {resp.status_code}")
        except Exception as exc:
            logger.warning(f"Error connecting to Open-Meteo multi-model API: {exc}")

        if not raw_data or "daily" not in raw_data:
            return self._build_offline_fallback(lat, lon, location_name, days)

        return self._process_nwp_payload(lat, lon, location_name, elevation, days, raw_data["daily"])

    def _process_nwp_payload(
        self,
        lat: float,
        lon: float,
        location_name: str,
        elevation: Optional[float],
        days: int,
        daily_dict: Dict[str, Any],
    ) -> MultiModelComparisonResponse:
        """Analyze raw model metrics, compute consensus, and construct the response."""
        times: List[str] = daily_dict.get("time", [])
        daily_comparisons: List[DailyNwpComparison] = []

        total_spread = 0.0
        divergent_days_count = 0

        for i, date_str in enumerate(times[:days]):
            try:
                dt = datetime.fromisoformat(date_str)
                day_name = dt.strftime("%A")
            except Exception:
                day_name = f"Day {i+1}"

            # Extract per-model values safely
            ecmwf_rain = float(daily_dict.get("precipitation_sum_ecmwf_ifs025", [0.0] * (i + 1))[i] or 0.0)
            ecmwf_tmax = float(daily_dict.get("temperature_2m_max_ecmwf_ifs025", [30.0] * (i + 1))[i] or 30.0)
            ecmwf_tmin = float(daily_dict.get("temperature_2m_min_ecmwf_ifs025", [24.0] * (i + 1))[i] or 24.0)

            gfs_rain = float(daily_dict.get("precipitation_sum_gfs_seamless", [0.0] * (i + 1))[i] or 0.0)
            gfs_tmax = float(daily_dict.get("temperature_2m_max_gfs_seamless", [30.0] * (i + 1))[i] or 30.0)
            gfs_tmin = float(daily_dict.get("temperature_2m_min_gfs_seamless", [24.0] * (i + 1))[i] or 24.0)

            icon_rain = float(daily_dict.get("precipitation_sum_icon_seamless", [0.0] * (i + 1))[i] or 0.0)
            icon_tmax = float(daily_dict.get("temperature_2m_max_icon_seamless", [30.0] * (i + 1))[i] or 30.0)
            icon_tmin = float(daily_dict.get("temperature_2m_min_icon_seamless", [24.0] * (i + 1))[i] or 24.0)

            models_map: Dict[str, NwpModelOutput] = {
                "ecmwf_ifs025": NwpModelOutput(
                    model_id="ecmwf_ifs025",
                    model_name="ECMWF IFS (0.25°)",
                    agency="ECMWF (Europe)",
                    resolution_km=25.0,
                    precipitation_mm=round(ecmwf_rain, 1),
                    temperature_max=round(ecmwf_tmax, 1),
                    temperature_min=round(ecmwf_tmin, 1),
                ),
                "gfs_seamless": NwpModelOutput(
                    model_id="gfs_seamless",
                    model_name="NOAA GFS (0.25°)",
                    agency="NOAA / NCEP (USA)",
                    resolution_km=25.0,
                    precipitation_mm=round(gfs_rain, 1),
                    temperature_max=round(gfs_tmax, 1),
                    temperature_min=round(gfs_tmin, 1),
                ),
                "icon_seamless": NwpModelOutput(
                    model_id="icon_seamless",
                    model_name="DWD ICON (13km)",
                    agency="DWD (Germany)",
                    resolution_km=13.0,
                    precipitation_mm=round(icon_rain, 1),
                    temperature_max=round(icon_tmax, 1),
                    temperature_min=round(icon_tmin, 1),
                ),
            }

            rains = [ecmwf_rain, gfs_rain, icon_rain]
            tmaxes = [ecmwf_tmax, gfs_tmax, icon_tmax]
            tmins = [ecmwf_tmin, gfs_tmin, icon_tmin]

            mean_rain = round(sum(rains) / len(rains), 1)
            min_rain = round(min(rains), 1)
            max_rain = round(max(rains), 1)
            spread = round(max_rain - min_rain, 1)
            mean_tmax = round(sum(tmaxes) / len(tmaxes), 1)
            mean_tmin = round(sum(tmins) / len(tmins), 1)

            total_spread += spread

            # Rate daily confidence & explain divergence
            if spread <= 4.0:
                day_confidence = "High"
                divergence_note = (
                    "Strong consensus: ECMWF, GFS, and ICON project consistent rainfall and thermal patterns."
                )
            elif spread <= 12.0:
                day_confidence = "Moderate"
                divergence_note = (
                    f"Moderate spread ({spread}mm): Differences in localized convection parameterization between models."
                )
            else:
                day_confidence = "Low"
                divergent_days_count += 1
                # Find max vs min model
                max_model = "ECMWF" if max_rain == ecmwf_rain else ("GFS" if max_rain == gfs_rain else "ICON")
                min_model = "ECMWF" if min_rain == ecmwf_rain else ("GFS" if min_rain == gfs_rain else "ICON")
                divergence_note = (
                    f"High model divergence ({spread}mm spread): {max_model} projects heavier rain ({max_rain}mm) "
                    f"while {min_model} predicts only {min_rain}mm. Exercise caution for outdoor scheduling."
                )

            daily_comparisons.append(
                DailyNwpComparison(
                    date=date_str,
                    day_name=day_name,
                    models=models_map,
                    consensus_rain_mean_mm=mean_rain,
                    consensus_rain_min_mm=min_rain,
                    consensus_rain_max_mm=max_rain,
                    rain_spread_mm=spread,
                    consensus_temp_max=mean_tmax,
                    consensus_temp_min=mean_tmin,
                    confidence=day_confidence,
                    divergence_note=divergence_note,
                )
            )

        # Calculate overall 5-day ensemble confidence
        avg_spread = total_spread / max(len(daily_comparisons), 1)
        if divergent_days_count >= 2 or avg_spread > 10.0:
            overall_confidence = "Low"
            overall_summary = (
                f"Significant multi-model divergence observed across {len(daily_comparisons)} forecast days. "
                "Atmospheric instability and varying convective schemes cause large rainfall spread between ECMWF and GFS. "
                "Monitor short-range updates and radar nowcasts closely."
            )
        elif divergent_days_count == 1 or avg_spread > 5.0:
            overall_confidence = "Moderate"
            overall_summary = (
                "Moderate agreement across major NWP models. General synoptic trends align well, "
                "with localized rainfall differences primarily around convective peak hours."
            )
        else:
            overall_confidence = "High"
            overall_summary = (
                "High multi-model agreement across ECMWF IFS, NOAA GFS, and DWD ICON. "
                "High forecasting confidence with narrow spread in both temperature and precipitation totals."
            )

        return MultiModelComparisonResponse(
            location_name=location_name,
            latitude=lat,
            longitude=lon,
            elevation=elevation,
            days_count=len(daily_comparisons),
            overall_confidence=overall_confidence,
            overall_summary=overall_summary,
            daily_comparisons=daily_comparisons,
            model_metadata=NWP_MODELS_METADATA,
        )

    def _build_offline_fallback(
        self, lat: float, lon: float, location_name: str, days: int
    ) -> MultiModelComparisonResponse:
        """Construct a synthetic fallback when upstream API is completely unreachable."""
        now = datetime.now(timezone.utc)
        daily_comparisons: List[DailyNwpComparison] = []

        for i in range(days):
            target_date = (now + timedelta(days=i)).date().isoformat()
            day_name = (now + timedelta(days=i)).strftime("%A")

            models_map = {
                "ecmwf_ifs025": NwpModelOutput(
                    model_id="ecmwf_ifs025",
                    model_name="ECMWF IFS (0.25°)",
                    agency="ECMWF (Europe)",
                    resolution_km=25.0,
                    precipitation_mm=2.0 + i * 1.5,
                    temperature_max=32.0,
                    temperature_min=25.0,
                ),
                "gfs_seamless": NwpModelOutput(
                    model_id="gfs_seamless",
                    model_name="NOAA GFS (0.25°)",
                    agency="NOAA / NCEP (USA)",
                    resolution_km=25.0,
                    precipitation_mm=1.0 + i * 0.8,
                    temperature_max=33.5,
                    temperature_min=26.0,
                ),
                "icon_seamless": NwpModelOutput(
                    model_id="icon_seamless",
                    model_name="DWD ICON (13km)",
                    agency="DWD (Germany)",
                    resolution_km=13.0,
                    precipitation_mm=3.5 + i * 1.2,
                    temperature_max=31.5,
                    temperature_min=24.5,
                ),
            }

            daily_comparisons.append(
                DailyNwpComparison(
                    date=target_date,
                    day_name=day_name,
                    models=models_map,
                    consensus_rain_mean_mm=round(2.2 + i * 1.2, 1),
                    consensus_rain_min_mm=round(1.0 + i * 0.8, 1),
                    consensus_rain_max_mm=round(3.5 + i * 1.2, 1),
                    rain_spread_mm=round(2.5 + i * 0.4, 1),
                    consensus_temp_max=32.3,
                    consensus_temp_min=25.2,
                    confidence="Moderate",
                    divergence_note="Offline baseline estimate: ECMWF, GFS, and ICON data unavailable. Showing synoptic normal.",
                )
            )

        return MultiModelComparisonResponse(
            location_name=location_name,
            latitude=lat,
            longitude=lon,
            elevation=0.0,
            days_count=days,
            overall_confidence="Moderate",
            overall_summary="NWP data currently operating in offline baseline mode. Reconnect to internet for real-time model runs.",
            daily_comparisons=daily_comparisons,
            model_metadata=NWP_MODELS_METADATA,
            provenance="Offline NWP Climatological Fallback",
        )


nwp_service = NwpComparisonService()
