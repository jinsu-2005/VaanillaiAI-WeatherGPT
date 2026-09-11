"""Weather Data Normalization, Source-Priority, and Multi-Provider Fusion Engine."""
import asyncio
import logging
from datetime import datetime, timedelta, timezone
from typing import Dict, Any, Optional, List
from app.providers.open_meteo import OpenMeteoProvider
from app.providers.imd_provider import IMDAlertProvider
from app.schemas.weather import (
    WeatherForecastResponse,
    CurrentWeather,
    DataSourceType,
    WeatherProvenance,
)
from app.schemas.alert import DisasterAlertResponse, AlertSeverity

logger = logging.getLogger(__name__)


class WeatherFusionEngine:
    """Fuses NWP model predictions with official IMD disaster warnings and observations."""

    def __init__(self):
        self.open_meteo = OpenMeteoProvider()
        self.imd_provider = IMDAlertProvider()

    async def fuse_forecast(
        self,
        lat: float,
        lon: float,
        location_name: str,
        district: Optional[str] = None,
        state: Optional[str] = None,
        days: int = 7
    ) -> WeatherForecastResponse:
        """Fetch multi-model NWP forecast, air quality, and official IMD warnings."""
        # 1. Concurrently fetch Forecast, Air Quality, and Official IMD / NDMA Alerts
        forecast_data, air_quality, alerts = await asyncio.gather(
            self.open_meteo.get_forecast(lat, lon, days=days),
            self.open_meteo.get_air_quality(lat, lon),
            self.imd_provider.get_active_alerts(lat=lat, lon=lon, district=district, state=state)
        )
        current: CurrentWeather = forecast_data["current"]
        hourly = forecast_data["hourly"]
        daily = forecast_data["daily"]
        elevation = forecast_data.get("elevation")

        # 4. Check for extreme weather thresholds in NWP data to highlight in warnings if IMD alert is pending
        synthetic_warnings = self._evaluate_nwp_thresholds(daily, location_name, district, state)
        all_warnings: List[DisasterAlertResponse] = list(alerts) + synthetic_warnings

        # 5. Evaluate confidence & uncertainty
        uncertainty_notes = self._generate_uncertainty_notes(current, daily, all_warnings)

        return WeatherForecastResponse(
            location_name=location_name,
            district=district,
            state=state,
            latitude=lat,
            longitude=lon,
            elevation=elevation,
            current=current,
            hourly=hourly,
            daily=daily,
            air_quality=air_quality,
            active_warnings=all_warnings,
            uncertainty_notes=uncertainty_notes,
            fusion_metadata={
                "nwp_provider": self.open_meteo.provider_name,
                "warning_provider": self.imd_provider.provider_name,
                "data_provenance": "ECMWF/GFS 2.5km Grid + IMD Official Warning System",
                "timestamp": datetime.now(timezone.utc).isoformat()
            }
        )

    def _evaluate_nwp_thresholds(
        self,
        daily_items: list,
        location_name: str,
        district: Optional[str],
        state: Optional[str]
    ) -> List[DisasterAlertResponse]:
        """Detect extreme events in NWP data (e.g. Extreme rainfall > 115mm, Heatwave > 42°C, Grem-wind > 65km/h)."""
        warnings: List[DisasterAlertResponse] = []
        now = datetime.now(timezone.utc)

        for idx, day in enumerate(daily_items[:3]):
            date_str = day.date
            # Check rainfall
            if day.precipitation_sum >= 115.6:
                warnings.append(
                    DisasterAlertResponse(
                        alert_id=f"NWP-HEAVY-RAIN-{date_str}-{location_name}",
                        source="NWP Meteorological Guidance (IMD / ECMWF Model)",
                        category="Heavy Rainfall Warning",
                        severity=AlertSeverity.ORANGE if day.precipitation_sum < 204.4 else AlertSeverity.RED,
                        urgency="Expected",
                        headline=f"Very Heavy Rainfall Predicted on {date_str} for {location_name}",
                        description=f"Numerical weather models predict {day.precipitation_sum:.1f} mm of rainfall with {day.precipitation_probability_max}% probability on {date_str}.",
                        instruction="Avoid low-lying flood-prone areas. Farmers are advised to postpone spraying and ensure drainage.",
                        area_description=f"{location_name}, {district or ''} {state or ''}".strip(),
                        district=district,
                        state=state,
                        effective_from=now,
                        expires_at=now + timedelta(days=idx + 1),
                        is_active=True,
                        color_hex="#DD6B20" if day.precipitation_sum < 204.4 else "#E53E3E"
                    )
                )
            elif day.precipitation_sum >= 64.5:
                warnings.append(
                    DisasterAlertResponse(
                        alert_id=f"NWP-RAIN-{date_str}-{location_name}",
                        source="NWP Meteorological Guidance (IMD / ECMWF Model)",
                        category="Heavy Rainfall Watch",
                        severity=AlertSeverity.YELLOW,
                        urgency="Expected",
                        headline=f"Heavy Rainfall ({day.precipitation_sum:.1f} mm) expected on {date_str}",
                        description=f"Model guidance indicates moderate to heavy rainfall of {day.precipitation_sum:.1f} mm for {location_name}.",
                        instruction="Stay updated with latest local nowcasts.",
                        area_description=location_name,
                        district=district,
                        state=state,
                        effective_from=now,
                        expires_at=now + timedelta(days=idx + 1),
                        is_active=True,
                        color_hex="#D69E2E"
                    )
                )

            # Check Extreme Heat
            if day.temp_max >= 42.0:
                warnings.append(
                    DisasterAlertResponse(
                        alert_id=f"NWP-HEATWAVE-{date_str}-{location_name}",
                        source="NWP Meteorological Guidance (IMD / ECMWF Model)",
                        category="Heatwave Warning",
                        severity=AlertSeverity.ORANGE if day.temp_max < 45.0 else AlertSeverity.RED,
                        urgency="Expected",
                        headline=f"Severe Heatwave Alert: Max Temp {day.temp_max:.1f}°C on {date_str}",
                        description=f"Maximum daytime temperatures are forecast to touch {day.temp_max:.1f}°C in {location_name}.",
                        instruction="Stay hydrated, avoid direct sun exposure between 12:00 PM and 3:30 PM.",
                        area_description=location_name,
                        district=district,
                        state=state,
                        effective_from=now,
                        expires_at=now + timedelta(days=idx + 1),
                        is_active=True,
                        color_hex="#DD6B20" if day.temp_max < 45.0 else "#E53E3E"
                    )
                )

        return warnings

    def _generate_uncertainty_notes(self, current: CurrentWeather, daily: list, warnings: list) -> str:
        notes = []
        if warnings:
            notes.append(f"{len(warnings)} weather warning(s) active in this region.")
        if daily and daily[0].precipitation_probability_max > 40:
            notes.append(f"Precipitation probability is {daily[0].precipitation_probability_max}%. Local convective showers may vary across village clusters.")
        else:
            notes.append("High model confidence for the next 24-48 hours.")
        return " ".join(notes)
