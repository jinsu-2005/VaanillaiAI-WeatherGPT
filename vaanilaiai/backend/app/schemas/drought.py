from enum import Enum
from typing import List, Dict, Optional
from pydantic import BaseModel, Field


class DroughtSeverity(str, Enum):
    NORMAL_NEAR_NORMAL = "NORMAL_NEAR_NORMAL"
    WATCH_MILD_DROUGHT = "WATCH_MILD_DROUGHT"
    ALERT_MODERATE_DROUGHT = "ALERT_MODERATE_DROUGHT"
    WARNING_SEVERE_DROUGHT = "WARNING_SEVERE_DROUGHT"
    EMERGENCY_EXTREME_DROUGHT = "EMERGENCY_EXTREME_DROUGHT"


class CgwbGroundwaterCategory(str, Enum):
    SAFE = "SAFE"
    SEMI_CRITICAL = "SEMI_CRITICAL"
    CRITICAL = "CRITICAL"
    OVER_EXPLOITED = "OVER_EXPLOITED"


class BorewellYieldTrend(str, Enum):
    STABLE = "STABLE"
    DECLINING = "DECLINING"
    DEPLETED = "DEPLETED"


class MeteorologicalDroughtIndices(BaseModel):
    spi_1: float = Field(..., description="1-Month Standardized Precipitation Index for short-term soil moisture recharge")
    spi_3: float = Field(..., description="3-Month Standardized Precipitation Index for agricultural seasonal drought")
    spi_6: float = Field(..., description="6-Month Standardized Precipitation Index for hydrological drought")
    rainfall_departure_lpa_pct: float = Field(..., description="Rainfall departure percentage from Long Period Average (LPA)")
    consecutive_dry_days: int = Field(..., description="Consecutive dry days with rainfall < 2.5 mm")
    drought_stage_verdict: str = Field(..., description="Official IMD meteorological drought classification")


class SoilMoistureStress(BaseModel):
    root_zone_soil_moisture_pct: float = Field(..., description="Current Root Zone Soil Moisture (0-60 cm) percentage")
    field_capacity_pct: float = Field(..., description="Soil field capacity percentage")
    permanent_wilting_point_pct: float = Field(..., description="Permanent wilting point percentage")
    available_water_capacity_mm: float = Field(..., description="Plant-available soil water capacity in mm")
    smdi: float = Field(..., description="Soil Moisture Deficit Index on -4.0 to +4.0 scale")
    crop_water_stress_index: float = Field(..., description="Crop Water Stress Index (CWSI) from 0.0 (no stress) to 1.0 (extreme stress)")
    stress_level: str = Field(..., description="Qualitative soil stress rating (Optimal, Moderate, Severe, Critical)")


class GroundwaterAquiferStatus(BaseModel):
    depth_to_water_table_m_bgl: float = Field(..., description="Piezometric water table depth in meters below ground level (m bgl)")
    stage_of_extraction_pct: float = Field(..., description="CGWB Stage of Ground Water Extraction (SOE %)")
    aquifer_category: CgwbGroundwaterCategory = Field(..., description="CGWB block classification")
    annual_recharge_potential_mcm: float = Field(..., description="Annual natural recharge potential in Million Cubic Meters")
    borewell_yield_trend: BorewellYieldTrend = Field(..., description="Borewell yield sustainability trend")
    irrigation_rationing_status: str = Field(..., description="Water conservation & power supply rationing advisory")


class AgronomicDroughtDirectives(BaseModel):
    crop_stage_advisory: str = Field(..., description="Critical phenological crop stage protective guidance")
    irrigation_scheduling: str = Field(..., description="Deficit irrigation / drip-fertigation interval advice")
    moisture_conservation: str = Field(..., description="Mulching, anti-transpirants, and conservation tillage")
    contingency_crop_switch: str = Field(..., description="Short-duration or drought-hardy contingency crops")
    livestock_fodder_advisory: str = Field(..., description="Silage, fodder bank, and cattle drinking water provisions")


class DroughtHotspot(BaseModel):
    hotspot_id: str = Field(..., description="Unique slug for drought-prone tract")
    district_name: str = Field(..., description="District and agro-climatic corridor name")
    state: str = Field(..., description="Indian State")
    latitude: float = Field(..., description="Latitude coordinate")
    longitude: float = Field(..., description="Longitude coordinate")
    agro_climatic_subzone: str = Field(..., description="Planning Commission Agro-Climatic Subzone")
    primary_crops: List[str] = Field(..., description="Dominant rainfed crops under stress")
    severity: DroughtSeverity = Field(..., description="Overall integrated drought severity")
    meteorological: MeteorologicalDroughtIndices = Field(..., description="IMD SPI and rainfall departure telemetry")
    soil_moisture: SoilMoistureStress = Field(..., description="Root zone soil moisture and SMDI metrics")
    groundwater: GroundwaterAquiferStatus = Field(..., description="CGWB aquifer status and SOE %")
    agronomic_directives: AgronomicDroughtDirectives = Field(..., description="ICAR-CRIDA drought mitigation guidance")


class AgriculturalDroughtResponse(BaseModel):
    timestamp: str = Field(..., description="Assessment UTC timestamp")
    selected_hotspot: DroughtHotspot = Field(..., description="Currently selected or nearest drought hotspot")
    all_hotspots: List[DroughtHotspot] = Field(..., description="Directory of all monitored drought-prone rainfed tracts")
    vernacular_bulletins: Dict[str, str] = Field(..., description="Localized emergency drought bulletins in EN, HI, MR, TE, KN")
    bulletin_number: str = Field(..., description="Official IMD Agromet & CGWB bulletin reference code")
    provenance: str = Field(default="IMD Agricultural Meteorology, Central Ground Water Board (CGWB) & ICAR-CRIDA")
    is_offline_cached: bool = Field(default=False, description="Whether data was served from local cache")
