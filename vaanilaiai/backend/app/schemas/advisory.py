"""Pydantic schemas for Agricultural, Marine, Travel, Lightning, Vision, and Citizen Decision-Support Advisories."""
from typing import List, Optional
from pydantic import BaseModel, Field


class AgricultureAdvisoryResponse(BaseModel):
    location_name: str
    district: Optional[str] = None
    date: str
    spraying_suitability: str = Field(..., description="Favorable, Risky, or Unfavorable")
    spraying_reason: str
    suitable_spraying_hours: List[str] = []
    irrigation_advice: str
    rain_risk_24h_mm: float
    rain_risk_level: str = "Low"  # Low, Moderate, High, Severe
    heat_stress_level: str = "Normal"  # Normal, Moderate, Severe
    pest_disease_risk: str = "Low"
    crop_specific_tips: List[str] = []
    official_disclaimer: str = "Advisory generated based on meteorological conditions and IMD agro-met guidelines. Verify with local Krishi Vigyan Kendra (KVK) for specialized crop operations."


class CropStageAdvisoryRequest(BaseModel):
    crop_type: str = Field("Paddy/Rice", description="Paddy/Rice, Wheat, Cotton, Groundnut, Sugarcane, Maize, Mustard, Vegetables")
    growth_stage: str = Field("Vegetative", description="Sowing, Vegetative, Flowering, Grain Filling, Harvesting")
    latitude: float
    longitude: float
    location_name: str = "Location"


class CropStageAdvisoryResponse(BaseModel):
    crop_type: str
    growth_stage: str
    location_name: str
    stage_vulnerability: str  # Low, Moderate, High, Critical
    water_requirement_status: str
    irrigation_directive: str
    chemical_spraying_directive: str
    pest_disease_alert: str
    harvest_logistics_advice: Optional[str] = None
    action_items: List[str] = []


class TravelAdvisoryResponse(BaseModel):
    location_name: str
    district: Optional[str] = None
    date: str
    overall_suitability: str = Field(..., description="Good, Caution, or Hazardous")
    travel_risk_score: int = Field(..., ge=0, le=100, description="0 = Perfectly Safe, 100 = Hazardous")
    road_safety_condition: str
    visibility_condition: str
    visibility_meters: float
    wind_hazard_level: str
    flight_disruption_risk: str  # Low, Moderate, High
    warnings_summary: Optional[str] = None
    safety_recommendations: List[str] = []


class MarineAdvisoryResponse(BaseModel):
    location_name: str
    coastal_region: str
    date: str
    sea_condition: str  # Calm, Moderate, Rough, Very Rough, Squally
    sea_condition_color: str  # Green, Yellow, Orange, Red
    significant_wave_height_m: float
    swell_period_seconds: float
    coastal_wind_knots: int
    coastal_wind_kmh: float
    wind_gusts_kmh: float
    wind_direction_deg: int
    wind_direction_cardinal: str
    sea_surface_temperature_c: float
    chlorophyll_a_mg_m3: float
    potential_fishing_zone_status: str  # High Potential, Moderate, Low, Inactive
    pfz_bearing_direction: str
    pfz_distance_nautical_miles: float
    deep_sea_navigation_safe: bool
    fishermen_warning_text: str
    port_warning_signal_number: int  # 1 to 11
    port_warning_signal_name: str
    port_warning_signal_description: str
    tide_high_time: str
    tide_high_height_m: float
    tide_low_time: str
    tide_low_height_m: float
    official_authority: str = "INCOIS (Indian National Centre for Ocean Information Services) & IMD Marine Division"


class LightningAlertResponse(BaseModel):
    location_name: str
    threat_level: str  # Safe, Moderate, High, Severe
    nearest_strike_km: float
    strikes_last_30m: int
    strike_trend: str  # Increasing, Steady, Decreasing
    cape_thunderstorm_index_j_kg: float
    sound_rumble_audible: bool
    safety_rule_30_30: str
    field_safety_guidance: List[str] = []
    last_updated: str


class SkyAnalysisResponse(BaseModel):
    cloud_genus: str  # Cumulonimbus, Nimbostratus, Altocumulus, Cirrus, Stratocumulus, Clear Sky
    cloud_description: str
    cloud_coverage_percentage: int
    rain_onset_estimated_minutes: Optional[int] = None  # e.g. 20-40 mins
    squall_risk_level: str  # None, Low, Moderate, Severe
    confidence_score: float
    actionable_verdict: str
    vernacular_summary: str


class CitizenReportCreate(BaseModel):
    report_type: str = Field(..., description="Waterlogging, Hailstorm, Tree Fall / Squall, Flooding, Heavy Rain")
    severity: str = Field("Moderate", description="Low, Moderate, High, Severe")
    water_depth_inches: Optional[float] = None
    description: str
    latitude: float
    longitude: float
    location_name: str
    photo_url: Optional[str] = None
    reporter_role: str = "Citizen"


class CitizenReportResponse(BaseModel):
    id: str
    report_type: str
    severity: str
    water_depth_inches: Optional[float] = None
    description: str
    latitude: float
    longitude: float
    location_name: str
    photo_url: Optional[str] = None
    reporter_role: str
    upvotes: int = 0
    created_at: str
