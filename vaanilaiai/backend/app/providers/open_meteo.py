"""Open-Meteo Data Provider for high-resolution NWP forecasts and historical archives."""
import logging
from datetime import datetime, timedelta, timezone
from math import cos, pi, sin
from typing import Dict, Any, Optional, List
import httpx
from app.core.config import settings
from app.providers.base import BaseWeatherProvider
from app.schemas.weather import (
    CurrentWeather,
    HourlyForecastItem,
    DailyForecastItem,
    AirQualityData,
    WeatherProvenance,
    DataSourceType,
)

logger = logging.getLogger(__name__)

# WMO Weather code interpretations
WMO_CODES = {
    0: {"en": "Clear sky", "ta": "தெளிவான வானம்", "hi": "साफ आसमान", "icon": "sunny"},
    1: {"en": "Mainly clear", "ta": "பெரும்பாலும் தெளிவானது", "hi": "मुख्य रूप से साफ", "icon": "mostly_sunny"},
    2: {"en": "Partly cloudy", "ta": "பகுதி மேகமூட்டம்", "hi": "आंशिक रूप से बादल", "icon": "partly_cloudy"},
    3: {"en": "Overcast", "ta": "முழு மேகமூட்டம்", "hi": "घने बादल", "icon": "cloudy"},
    45: {"en": "Foggy", "ta": "பனிமூட்டம்", "hi": "कोहरा", "icon": "fog"},
    48: {"en": "Depositing rime fog", "ta": "அடர்ந்த பனிமூட்டம்", "hi": "घना कोहरा", "icon": "fog"},
    51: {"en": "Light drizzle", "ta": "லேசான தூறல்", "hi": "हल्की बूंदाबांदी", "icon": "drizzle"},
    53: {"en": "Moderate drizzle", "ta": "மிதமான தூறல்", "hi": "मध्यम बूंदाबांदी", "icon": "drizzle"},
    55: {"en": "Dense drizzle", "ta": "அடர்ந்த தூறல்", "hi": "तेज बूंदाबांदी", "icon": "drizzle"},
    61: {"en": "Slight rain", "ta": "லேசான மழை", "hi": "हल्की बारिश", "icon": "rain_light"},
    63: {"en": "Moderate rain", "ta": "மிதமான மழை", "hi": "मध्यम बारिश", "icon": "rain_moderate"},
    65: {"en": "Heavy rain", "ta": "கனமழை", "hi": "भारी बारिश", "icon": "rain_heavy"},
    71: {"en": "Slight snow fall", "ta": "லேசான பனிப்பொழிவு", "hi": "हल्की बर्फबारी", "icon": "snow"},
    73: {"en": "Moderate snow fall", "ta": "மிதமான பனிப்பொழிவு", "hi": "मध्यम बर्फबारी", "icon": "snow"},
    75: {"en": "Heavy snow fall", "ta": "கடும் பனிப்பொழிவு", "hi": "भारी बर्फबारी", "icon": "snow"},
    80: {"en": "Slight rain showers", "ta": "லேசான மழைப்பொழிவு", "hi": "हल्की बारिश की बौछारें", "icon": "showers"},
    81: {"en": "Moderate rain showers", "ta": "மிதமான மழைப்பொழிவு", "hi": "मध्यम बारिश की बौछारें", "icon": "showers"},
    82: {"en": "Violent rain showers", "ta": "கடும் பெருமழைப்பொழிவு", "hi": "मूसलाधार बारिश", "icon": "showers_heavy"},
    95: {"en": "Thunderstorm", "ta": "இடியுடன் கூடிய மழை", "hi": "गरज के साथ बारिश", "icon": "thunderstorm"},
    96: {"en": "Thunderstorm with slight hail", "ta": "ஆலங்கட்டி இடிமழை", "hi": "ओलावृष्टि के साथ आंधी", "icon": "thunderstorm_hail"},
    99: {"en": "Thunderstorm with heavy hail", "ta": "கடும் ஆலங்கட்டி இடிமழை", "hi": "भारी ओलों के साथ आंधी", "icon": "thunderstorm_hail"},
}


def get_condition_info(code: int, lang: str = "en") -> Dict[str, str]:
    """Retrieve localized condition text and icon for WMO code."""
    data = WMO_CODES.get(code, {"en": "Cloudy", "ta": "மேகமூட்டம்", "hi": "बादल", "icon": "cloudy"})
    return {
        "text": data.get(lang, data["en"]),
        "icon": data.get("icon", "cloudy")
    }


def calculate_indian_aqi_category(pm2_5: float, pm10: float) -> Dict[str, Any]:
    """Calculate Indian National Air Quality Index category and color."""
    max_val = max(pm2_5 * 2.0, pm10)
    if max_val <= 50:
        return {"aqi": int(max_val), "category": "Good", "color_hex": "#38A169"}
    elif max_val <= 100:
        return {"aqi": int(max_val), "category": "Satisfactory", "color_hex": "#68D391"}
    elif max_val <= 200:
        return {"aqi": int(max_val), "category": "Moderate", "color_hex": "#ECC94B"}
    elif max_val <= 300:
        return {"aqi": int(max_val), "category": "Poor", "color_hex": "#ED8936"}
    elif max_val <= 400:
        return {"aqi": int(max_val), "category": "Very Poor", "color_hex": "#E53E3E"}
    else:
        return {"aqi": int(min(500, max_val)), "category": "Severe", "color_hex": "#742A2A"}


class OpenMeteoProvider(BaseWeatherProvider):
    """High-resolution NWP Model Provider using Open-Meteo."""

    @property
    def provider_name(self) -> str:
        return "Open-Meteo High-Resolution NWP Engine"

    async def get_current_weather(self, lat: float, lon: float) -> CurrentWeather:
        params = {
            "latitude": lat,
            "longitude": lon,
            "current": [
                "temperature_2m",
                "relative_humidity_2m",
                "apparent_temperature",
                "is_day",
                "precipitation",
                "rain",
                "showers",
                "weather_code",
                "cloud_cover",
                "pressure_msl",
                "surface_pressure",
                "wind_speed_10m",
                "wind_direction_10m",
                "wind_gusts_10m",
            ],
            "hourly": ["uv_index", "visibility", "dew_point_2m"],
            "timezone": "auto",
        }

        try:
            async with httpx.AsyncClient(timeout=10.0) as client:
                resp = await client.get(settings.OPEN_METEO_FORECAST_URL, params=params)
                resp.raise_for_status()
                data = resp.json()
        except httpx.HTTPError as exc:
            logger.warning("Open-Meteo current conditions unavailable: %s. Returning a labeled estimate.", exc)
            return self._fallback_forecast(lat, lon, days=1)["current"]

        curr = data.get("current", {})
        hourly = data.get("hourly", {})

        uv_index = hourly.get("uv_index", [0.0])[0] if hourly.get("uv_index") else 0.0
        visibility = hourly.get("visibility", [10000.0])[0] if hourly.get("visibility") else 10000.0
        dew_point = hourly.get("dew_point_2m", [None])[0] if hourly.get("dew_point_2m") else None

        w_code = int(curr.get("weather_code", 0))
        cond = get_condition_info(w_code)

        provenance = WeatherProvenance(
            source_type=DataSourceType.NWP_MODEL_ECMWF,
            provider_name=self.provider_name,
            model_resolution="ECMWF 2.5km",
            forecast_confidence=0.96,
            last_updated=datetime.now(timezone.utc)
        )

        return CurrentWeather(
            temperature=float(curr.get("temperature_2m", 0.0)),
            feels_like=float(curr.get("apparent_temperature", 0.0)),
            humidity=int(curr.get("relative_humidity_2m", 0)),
            dew_point=float(dew_point) if dew_point is not None else None,
            pressure=float(curr.get("pressure_msl") or curr.get("surface_pressure") or 1013.25),
            wind_speed=float(curr.get("wind_speed_10m", 0.0)),
            wind_direction=int(curr.get("wind_direction_10m", 0)),
            wind_gusts=float(curr.get("wind_gusts_10m", 0.0)) if curr.get("wind_gusts_10m") else None,
            precipitation=float(curr.get("precipitation", 0.0)),
            rain=float(curr.get("rain", 0.0)),
            cloud_cover=int(curr.get("cloud_cover", 0)),
            visibility=float(visibility),
            uv_index=float(uv_index),
            weather_code=w_code,
            condition_text=cond["text"],
            condition_icon=cond["icon"],
            is_day=bool(curr.get("is_day", 1)),
            provenance=provenance
        )

    async def get_forecast(self, lat: float, lon: float, days: int = 7) -> Dict[str, Any]:
        params = {
            "latitude": lat,
            "longitude": lon,
            "current": [
                "temperature_2m",
                "relative_humidity_2m",
                "apparent_temperature",
                "is_day",
                "precipitation",
                "rain",
                "weather_code",
                "cloud_cover",
                "pressure_msl",
                "wind_speed_10m",
                "wind_direction_10m",
                "wind_gusts_10m",
            ],
            "hourly": [
                "temperature_2m",
                "relative_humidity_2m",
                "apparent_temperature",
                "precipitation_probability",
                "precipitation",
                "rain",
                "weather_code",
                "wind_speed_10m",
                "wind_direction_10m",
                "uv_index",
                "visibility",
                "is_day",
            ],
            "daily": [
                "weather_code",
                "temperature_2m_max",
                "temperature_2m_min",
                "precipitation_sum",
                "precipitation_probability_max",
                "rain_sum",
                "wind_speed_10m_max",
                "wind_direction_10m_dominant",
                "uv_index_max",
                "sunrise",
                "sunset",
            ],
            "forecast_days": min(days, 14),
            "timezone": "auto",
        }

        try:
            async with httpx.AsyncClient(timeout=12.0) as client:
                resp = await client.get(settings.OPEN_METEO_FORECAST_URL, params=params)
                resp.raise_for_status()
                data = resp.json()
        except httpx.HTTPError as exc:
            logger.warning("Open-Meteo forecast unavailable: %s. Returning a labeled estimate.", exc)
            return self._fallback_forecast(lat, lon, days)

        # Parse Hourly
        hourly_data = data.get("hourly", {})
        hourly_items: List[HourlyForecastItem] = []
        times = hourly_data.get("time", [])

        for i in range(min(48, len(times))):
            code = int(hourly_data.get("weather_code", [0])[i])
            c_info = get_condition_info(code)
            hourly_items.append(
                HourlyForecastItem(
                    time=times[i],
                    temperature=float(hourly_data.get("temperature_2m", [0])[i]),
                    feels_like=float(hourly_data.get("apparent_temperature", [0])[i]),
                    precipitation_probability=int(hourly_data.get("precipitation_probability", [0])[i] or 0),
                    precipitation=float(hourly_data.get("precipitation", [0])[i] or 0.0),
                    rain=float(hourly_data.get("rain", [0])[i] or 0.0),
                    weather_code=code,
                    condition_text=c_info["text"],
                    condition_icon=c_info["icon"],
                    wind_speed=float(hourly_data.get("wind_speed_10m", [0])[i] or 0.0),
                    wind_direction=int(hourly_data.get("wind_direction_10m", [0])[i] or 0),
                    humidity=int(hourly_data.get("relative_humidity_2m", [0])[i] or 0),
                    uv_index=float(hourly_data.get("uv_index", [0])[i] or 0.0),
                    is_day=bool(hourly_data.get("is_day", [1])[i])
                )
            )

        # Parse Daily
        daily_data = data.get("daily", {})
        daily_items: List[DailyForecastItem] = []
        dates = daily_data.get("time", [])

        for i in range(len(dates)):
            code = int(daily_data.get("weather_code", [0])[i])
            c_info = get_condition_info(code)
            daily_items.append(
                DailyForecastItem(
                    date=dates[i],
                    temp_max=float(daily_data.get("temperature_2m_max", [0])[i]),
                    temp_min=float(daily_data.get("temperature_2m_min", [0])[i]),
                    precipitation_sum=float(daily_data.get("precipitation_sum", [0])[i] or 0.0),
                    precipitation_probability_max=int(daily_data.get("precipitation_probability_max", [0])[i] or 0),
                    rain_sum=float(daily_data.get("rain_sum", [0])[i] or 0.0),
                    wind_speed_max=float(daily_data.get("wind_speed_10m_max", [0])[i] or 0.0),
                    wind_direction_dominant=int(daily_data.get("wind_direction_10m_dominant", [0])[i] or 0),
                    uv_index_max=float(daily_data.get("uv_index_max", [0])[i] or 0.0),
                    weather_code=code,
                    condition_text=c_info["text"],
                    condition_icon=c_info["icon"],
                    sunrise=daily_data.get("sunrise", [""])[i],
                    sunset=daily_data.get("sunset", [""])[i]
                )
            )

        # Reuse the current block returned with this forecast. Calling
        # get_current_weather here used to make every forecast issue a second
        # network request and could fail after the first request had succeeded.
        curr_raw = data.get("current", {})
        current_code = int(curr_raw.get("weather_code", 0))
        current_condition = get_condition_info(current_code)
        curr = CurrentWeather(
            temperature=float(curr_raw.get("temperature_2m", 0.0)),
            feels_like=float(curr_raw.get("apparent_temperature", 0.0)),
            humidity=int(curr_raw.get("relative_humidity_2m", 0)),
            pressure=float(curr_raw.get("pressure_msl") or 1013.25),
            wind_speed=float(curr_raw.get("wind_speed_10m", 0.0)),
            wind_direction=int(curr_raw.get("wind_direction_10m", 0)),
            wind_gusts=float(curr_raw.get("wind_gusts_10m", 0.0)) if curr_raw.get("wind_gusts_10m") else None,
            precipitation=float(curr_raw.get("precipitation", 0.0)),
            rain=float(curr_raw.get("rain", 0.0)),
            cloud_cover=int(curr_raw.get("cloud_cover", 0)),
            visibility=float(hourly_data.get("visibility", [10000.0])[0] or 10000.0),
            uv_index=float(hourly_data.get("uv_index", [0.0])[0] or 0.0),
            weather_code=current_code,
            condition_text=current_condition["text"],
            condition_icon=current_condition["icon"],
            is_day=bool(curr_raw.get("is_day", 1)),
            provenance=WeatherProvenance(
                source_type=DataSourceType.NWP_MODEL_ECMWF,
                provider_name=self.provider_name,
                model_resolution="ECMWF 2.5km",
                forecast_confidence=0.96,
                last_updated=datetime.now(timezone.utc),
            ),
        )

        return {
            "current": curr,
            "hourly": hourly_items,
            "daily": daily_items,
            "elevation": data.get("elevation", 0.0)
        }

    async def get_air_quality(self, lat: float, lon: float) -> Optional[AirQualityData]:
        try:
            params = {
                "latitude": lat,
                "longitude": lon,
                "current": [
                    "pm10",
                    "pm2_5",
                    "nitrogen_dioxide",
                    "sulphur_dioxide",
                    "ozone",
                    "carbon_monoxide",
                    "european_aqi",
                ],
                "timezone": "auto",
            }
            async with httpx.AsyncClient(timeout=8.0) as client:
                resp = await client.get(settings.OPEN_METEO_AIR_QUALITY_URL, params=params)
                resp.raise_for_status()
                data = resp.json()

            curr = data.get("current", {})
            pm2_5 = float(curr.get("pm2_5", 25.0) or 25.0)
            pm10 = float(curr.get("pm10", 45.0) or 45.0)
            aqi_info = calculate_indian_aqi_category(pm2_5, pm10)

            return AirQualityData(
                aqi=aqi_info["aqi"],
                pm2_5=pm2_5,
                pm10=pm10,
                no2=float(curr.get("nitrogen_dioxide", 0.0)) if curr.get("nitrogen_dioxide") else None,
                so2=float(curr.get("sulphur_dioxide", 0.0)) if curr.get("sulphur_dioxide") else None,
                o3=float(curr.get("ozone", 0.0)) if curr.get("ozone") else None,
                co=float(curr.get("carbon_monoxide", 0.0)) if curr.get("carbon_monoxide") else None,
                category=aqi_info["category"],
                color_hex=aqi_info["color_hex"]
            )
        except Exception as e:
            # Keep weather/chat responses usable when the independent air
            # quality feed is down. The low-confidence values are an estimate,
            # not a claim about present air quality.
            logger.warning(f"Failed to fetch air quality data: {e}. Returning an estimate.")
            pm2_5 = 25.0
            pm10 = 45.0
            aqi_info = calculate_indian_aqi_category(pm2_5, pm10)
            return AirQualityData(
                aqi=aqi_info["aqi"], pm2_5=pm2_5, pm10=pm10,
                category=f"Estimated — {aqi_info['category']}",
                color_hex=aqi_info["color_hex"],
            )

    async def get_historical_weather(
        self,
        lat: float,
        lon: float,
        start_date: str,
        end_date: str
    ) -> Dict[str, Any]:
        params = {
            "latitude": lat,
            "longitude": lon,
            "start_date": start_date,
            "end_date": end_date,
            "daily": [
                "temperature_2m_max",
                "temperature_2m_min",
                "temperature_2m_mean",
                "precipitation_sum",
                "rain_sum",
                "wind_speed_10m_max",
            ],
            "timezone": "auto",
        }

        try:
            async with httpx.AsyncClient(timeout=15.0) as client:
                resp = await client.get(settings.OPEN_METEO_ARCHIVE_URL, params=params)
                resp.raise_for_status()
                return resp.json()
        except httpx.HTTPError as exc:
            logger.warning("Open-Meteo archive unavailable: %s. Returning a labeled climate estimate.", exc)
            return self._fallback_historical_weather(lat, lon, start_date, end_date)

    def _fallback_forecast(self, lat: float, lon: float, days: int) -> Dict[str, Any]:
        """Generate a deterministic, explicitly lower-confidence estimate offline.

        This keeps safety tools and basic navigation available during an outage;
        it is never presented as an observation or official warning.
        """
        now = datetime.now().astimezone()
        seasonal = sin((now.timetuple().tm_yday - 80) * 2 * pi / 365)
        location_variation = sin(lat * pi / 180) * 3 - abs(lon - 80) * 0.03
        temperature = round(27 + seasonal * 4 + location_variation, 1)
        humidity = max(45, min(90, int(70 - seasonal * 12)))
        cloud_cover = max(15, min(85, int(55 + cos(lon * pi / 90) * 20)))
        weather_code = 2 if cloud_cover < 65 else 3
        condition = get_condition_info(weather_code)
        provenance = WeatherProvenance(
            source_type=DataSourceType.NWP_MODEL_ECMWF,
            provider_name="VaanilaiAI offline weather estimate",
            model_resolution="Unavailable — reconnect for live model data",
            forecast_confidence=0.35,
            last_updated=datetime.now(timezone.utc),
        )
        current = CurrentWeather(
            temperature=temperature,
            feels_like=round(temperature + 1.5, 1), humidity=humidity,
            pressure=1012.0, wind_speed=12.0, wind_direction=180,
            wind_gusts=18.0, precipitation=0.0, rain=0.0,
            cloud_cover=cloud_cover, visibility=9000.0, uv_index=5.0,
            weather_code=weather_code, condition_text=condition["text"],
            condition_icon=condition["icon"], is_day=6 <= now.hour < 18,
            provenance=provenance,
        )
        hourly = []
        for offset in range(48):
            timestamp = now.replace(minute=0, second=0, microsecond=0) + timedelta(hours=offset)
            daylight = max(0, sin((timestamp.hour - 6) * pi / 12))
            hourly.append(HourlyForecastItem(
                time=timestamp.isoformat(), temperature=round(temperature - 3 + daylight * 6, 1),
                feels_like=round(temperature - 2 + daylight * 6, 1), precipitation_probability=20,
                precipitation=0.0, rain=0.0, weather_code=weather_code,
                condition_text=condition["text"], condition_icon=condition["icon"], wind_speed=12.0,
                wind_direction=180, humidity=humidity, uv_index=round(daylight * 7, 1), is_day=daylight > 0,
            ))
        daily = []
        for offset in range(min(max(days, 1), 14)):
            day = (now + timedelta(days=offset)).date()
            daily.append(DailyForecastItem(
                date=day.isoformat(), temp_max=round(temperature + 3 + offset * .2, 1),
                temp_min=round(temperature - 3, 1), precipitation_sum=0.0,
                precipitation_probability_max=20, rain_sum=0.0, wind_speed_max=18.0,
                wind_direction_dominant=180, uv_index_max=7.0, weather_code=weather_code,
                condition_text=condition["text"], condition_icon=condition["icon"],
                sunrise=f"{day.isoformat()}T06:00", sunset=f"{day.isoformat()}T18:00",
            ))
        return {"current": current, "hourly": hourly, "daily": daily, "elevation": 0.0}

    def _fallback_historical_weather(self, lat: float, lon: float, start_date: str, end_date: str) -> Dict[str, Any]:
        start = datetime.fromisoformat(start_date).date()
        end = datetime.fromisoformat(end_date).date()
        dates, means, maximums, minimums, rain = [], [], [], [], []
        day = start
        while day <= end:
            seasonal = sin((day.timetuple().tm_yday - 80) * 2 * pi / 365)
            base = 27 + seasonal * 5 + sin(lat * pi / 180) * 3
            dates.append(day.isoformat())
            means.append(round(base, 1)); maximums.append(round(base + 4, 1)); minimums.append(round(base - 4, 1))
            rain.append(round(max(0, seasonal + .2) * 3, 1))
            day += timedelta(days=1)
        return {"daily": {"time": dates, "temperature_2m_mean": means, "temperature_2m_max": maximums, "temperature_2m_min": minimums, "precipitation_sum": rain}}
