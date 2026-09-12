"""Pydantic schemas for IITM SAFAR & IMD AQEWS Air Quality and Atmospheric Dispersion."""
from typing import List, Dict, Optional
from pydantic import BaseModel, Field


class PollutantMetric(BaseModel):
    pollutant_code: str  # pm2_5, pm10, no2, so2, co, o3
    name: str
    concentration: float
    unit: str  # µg/m³ or mg/m³
    cpcb_sub_index: int
    sub_index_category: str  # Good, Satisfactory, Moderate, Poor, Very Poor, Severe
    cpcb_safe_limit: float
    is_dominant_pollutant: bool = False


class AtmosphericDispersionIndex(BaseModel):
    mixing_layer_height_m: float = Field(..., description="Planetary boundary layer / mixing depth in meters")
    surface_wind_speed_kmh: float = Field(..., description="10m surface wind speed in km/h")
    ventilation_coefficient_m2s: float = Field(..., description="Ventilation coefficient = mixing_height * wind_speed (m²/s)")
    dispersion_category: str = Field(..., description="Good, Moderate, Poor, Critical")
    inversion_risk: str = Field(..., description="None, Mild Inversion, Severe Night Inversion")
    physical_dispersion_summary: str


class StubbleBiomassSmokeTelemetry(BaseModel):
    active_fire_count_regional: int
    fire_radiative_power_mw: float
    transport_wind_direction: str
    transboundary_pm25_contribution_pct: float
    agrarian_smoke_impact_level: str  # Low, Moderate, High, Extreme


class SafarAqiForecastDay(BaseModel):
    forecast_day: str  # Tomorrow, Day After
    date: str
    predicted_aqi: int
    category: str
    primary_driver: str


class DemographicHealthAdvisory(BaseModel):
    demographic_group: str  # Asthma / COPD, Cardiac / Heart, Elderly & Children, Outdoor Workers, Morning Joggers
    vulnerability_risk_level: str  # Low, Caution, High, Severe
    actionable_guidance: str
    recommended_protective_measures: List[str] = []


class SafarAirQualityResponse(BaseModel):
    latitude: float
    longitude: float
    location_name: str
    selected_city_code: Optional[str] = None
    overall_aqi: int
    cpcb_category: str
    category_color_hex: str
    dominant_pollutant: str
    pollutants: List[PollutantMetric] = []
    atmospheric_dispersion: AtmosphericDispersionIndex
    stubble_biomass_smoke: StubbleBiomassSmokeTelemetry
    aqi_forecast: List[SafarAqiForecastDay] = []
    demographic_advisories: List[DemographicHealthAdvisory] = []
    vernacular_health_guidance: Dict[str, str] = Field(default_factory=dict)
    monitoring_stations: List[str] = []
    provenance_authority: str = "IITM SAFAR & IMD AQEWS High-Resolution Dispersion Modeling"
    last_updated: str
