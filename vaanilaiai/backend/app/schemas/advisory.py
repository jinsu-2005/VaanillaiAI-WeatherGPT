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
    coastal_sector_name: str = "Indian Peninsular Waters"
    is_coastal_location: bool = True
    date: str
    sea_condition: str  # Calm, Moderate, Rough, Very Rough, Squally
    sea_condition_color: str  # Green, Yellow, Orange, Red
    significant_wave_height_m: float
    swell_height_m: float = 0.0
    swell_period_seconds: float
    swell_direction_cardinal: str = "SSW"
    kallakkadal_surge_risk: str = "None"  # None, Watch, Warning, Severe Kallakkadal Event
    kallakkadal_explanation: Optional[str] = None
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
    vessel_category_directives: dict = Field(default_factory=dict)
    fishermen_warning_text: str
    vernacular_coastal_directives: dict = Field(default_factory=dict)
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
    flash_to_bang_delay_seconds: float = 0.0
    strikes_last_30m: int
    strike_trend: str  # Increasing, Steady, Decreasing
    cape_thunderstorm_index_j_kg: float
    cape_stability_verdict: str = "Stable"
    sound_rumble_audible: bool
    safety_rule_30_30: str
    shelter_30min_guidance: str = "Remain inside safe shelter for at least 30 minutes following the last observed thunderclap."
    vernacular_directives: dict = Field(default_factory=dict)
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


class AgrometDayForecast(BaseModel):
    date: str
    day_name: str
    rainfall_mm: float
    temp_max_c: float
    temp_min_c: float
    humidity_morning_pct: int
    humidity_evening_pct: int
    wind_speed_kmh: float
    wind_direction_cardinal: str
    cloud_cover_octa: int = Field(..., ge=0, le=8, description="Cloud cover in oktas (0=clear sky, 8=overcast)")


class CropAgrometAdvisory(BaseModel):
    crop_name: str
    stage: str
    risk_level: str = "Normal"  # Normal, Watch, Alert, Warning
    advisory_text: str
    pest_disease_advisory: Optional[str] = None
    recommended_intervention: Optional[str] = None


class LivestockAdvisory(BaseModel):
    livestock_type: str  # Dairy Cattle & Buffaloes, Poultry, Sheep & Goats
    risk_level: str = "Normal"  # Normal, Watch, Alert
    management_advice: str
    vaccination_or_disease_alert: Optional[str] = None


class DistrictAgrometBulletinResponse(BaseModel):
    district: str
    state: str
    bulletin_number: str
    issue_date: str
    valid_from: str
    valid_until: str
    amfu_center: str
    synoptic_weather_summary: str
    five_day_forecast: List[AgrometDayForecast] = []
    general_farm_advisories: List[str] = []
    crop_advisories: List[CropAgrometAdvisory] = []
    livestock_advisories: List[LivestockAdvisory] = []
    provenance_disclaimer: str = "Prepared in accordance with ICAR-IMD Gramin Krishi Mausam Seva (GKMS) agro-meteorological protocols. Refreshed for district-level farm planning."


class UrbanFloodRiskResponse(BaseModel):
    location_name: str
    district: Optional[str] = None
    risk_score: int = Field(..., ge=0, le=100, description="0=Safe, 100=Severe inundation")
    risk_tier: str = Field(..., description="Low, Moderate, High, or Severe")
    estimated_water_depth_inches: float
    peak_rain_rate_mm_h: float
    three_hour_rain_mm: float
    drain_capacity_mm_h: float = 20.0
    drain_surplus_mm_h: float
    underpass_status: str
    two_wheeler_directive: str
    car_directive: str
    pedestrian_directive: str
    summary_text: str
    critical_vulnerable_hotspots: List[str] = []
    nearby_citizen_reports_count: int = 0
    last_updated: str


