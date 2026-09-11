"""Pydantic schemas for Weather Data Contracts and Provenance."""
from datetime import datetime, timezone
from enum import Enum
from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field
from app.schemas.alert import DisasterAlertResponse


class DataSourceType(str, Enum):
    DIRECT_OBSERVATION = "DIRECT_OBSERVATION"      # Direct AWS/IMD Station on-site
    NEARBY_STATION = "NEARBY_STATION"              # Nearest official IMD observation station
    NWP_MODEL_GFS = "NWP_MODEL_GFS"                # NOAA/NCEP Global Forecast System
    NWP_MODEL_ECMWF = "NWP_MODEL_ECMWF"            # European Centre for Medium-Range Weather Forecasts (High-Res)
    IMD_OFFICIAL = "IMD_OFFICIAL"                  # IMD Official District/Nowcast Bulletin


class WeatherProvenance(BaseModel):
    source_type: DataSourceType
    provider_name: str
    station_name: Optional[str] = None
    station_distance_km: Optional[float] = None
    model_resolution: Optional[str] = None
    forecast_confidence: float = Field(0.95, ge=0.0, le=1.0, description="Confidence score 0.0 - 1.0")
    last_updated: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))


class AirQualityData(BaseModel):
    aqi: int = Field(..., description="Indian Air Quality Index equivalent")
    pm2_5: float = Field(..., description="PM2.5 (ug/m3)")
    pm10: float = Field(..., description="PM10 (ug/m3)")
    no2: Optional[float] = None
    so2: Optional[float] = None
    o3: Optional[float] = None
    co: Optional[float] = None
    category: str = Field(..., description="Good, Moderate, Poor, Very Poor, Severe")
    color_hex: str = "#48BB78"


class CurrentWeather(BaseModel):
    temperature: float = Field(..., description="Temperature in Celsius")
    feels_like: float = Field(..., description="Apparent temperature in Celsius")
    humidity: int = Field(..., ge=0, le=100, description="Relative humidity in percentage")
    dew_point: Optional[float] = None
    pressure: float = Field(..., description="Atmospheric pressure in hPa")
    wind_speed: float = Field(..., description="Wind speed in km/h")
    wind_direction: int = Field(..., ge=0, le=360, description="Wind direction in degrees")
    wind_gusts: Optional[float] = None
    precipitation: float = Field(0.0, description="Precipitation in mm (last hour)")
    rain: float = Field(0.0, description="Rain in mm")
    cloud_cover: int = Field(..., ge=0, le=100, description="Total cloud cover %")
    visibility: float = Field(..., description="Visibility in meters")
    uv_index: float = Field(..., ge=0.0, description="UV Index")
    weather_code: int = Field(..., description="WMO Weather interpretation code")
    condition_text: str = Field(..., description="Human readable condition description")
    condition_icon: str = Field("sunny", description="Icon identifier for UI")
    is_day: bool = True
    provenance: WeatherProvenance


class HourlyForecastItem(BaseModel):
    time: str = Field(..., description="ISO 8601 timestamp string")
    temperature: float
    feels_like: float
    precipitation_probability: int = Field(0, ge=0, le=100)
    precipitation: float = 0.0
    rain: float = 0.0
    weather_code: int
    condition_text: str
    condition_icon: str
    wind_speed: float
    wind_direction: int
    humidity: int
    uv_index: float = 0.0
    is_day: bool = True


class DailyForecastItem(BaseModel):
    date: str = Field(..., description="YYYY-MM-DD format")
    temp_max: float
    temp_min: float
    precipitation_sum: float
    precipitation_probability_max: int
    rain_sum: float
    wind_speed_max: float
    wind_direction_dominant: int
    uv_index_max: float
    weather_code: int
    condition_text: str
    condition_icon: str
    sunrise: str
    sunset: str


class WeatherForecastResponse(BaseModel):
    location_name: str
    district: Optional[str] = None
    state: Optional[str] = None
    latitude: float
    longitude: float
    elevation: Optional[float] = None
    current: CurrentWeather
    hourly: List[HourlyForecastItem]
    daily: List[DailyForecastItem]
    air_quality: Optional[AirQualityData] = None
    active_warnings: List[DisasterAlertResponse] = []
    uncertainty_notes: Optional[str] = None
    fusion_metadata: Dict[str, Any] = {}
