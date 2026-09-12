"""Pydantic schemas for IMD Sub-Divisional Monsoon Teleconnections and Long-Range Forecasts."""
from typing import List, Dict
from pydantic import BaseModel, Field


class SubDivisionalMonsoonStatus(BaseModel):
    sub_division_code: str
    name: str
    state: str
    actual_rainfall_mm: float
    normal_rainfall_mm: float
    departure_percentage: float
    departure_category: str  # Large Excess, Excess, Normal, Deficient, Large Deficient, No Rain
    departure_color: str  # Blue, Light Blue, Green, Red, Yellow
    soil_moisture_index: float = Field(..., ge=0.0, le=1.0, description="Soil moisture saturation 0.0 to 1.0")
    drought_risk_level: str = "Normal"  # Normal, Mild Drought, Moderate Drought, Severe Drought
    is_user_sub_division: bool = False


class OceanicTeleconnectionIndex(BaseModel):
    index_code: str
    name: str
    current_value: float
    unit: str
    phase: str
    impact_on_monsoon: str  # Favorable, Neutral, Adverse
    mechanism_summary: str


class SeasonalForecastOutlook(BaseModel):
    season_name: str
    onset_status: str
    prob_below_normal_pct: int
    prob_normal_pct: int
    prob_above_normal_pct: int
    official_lrf_verdict: str


class MonsoonIntelligenceResponse(BaseModel):
    latitude: float
    longitude: float
    location_name: str
    user_sub_division: SubDivisionalMonsoonStatus
    teleconnections: List[OceanicTeleconnectionIndex] = []
    seasonal_outlook: SeasonalForecastOutlook
    all_sub_divisions: List[SubDivisionalMonsoonStatus] = []
    adaptation_directives: List[str] = []
    vernacular_advisories: Dict[str, str] = Field(default_factory=dict)
    provenance_authority: str = "IMD Climate Services & NCMRWF Coupled Teleconnection Modeling"
    last_updated: str
