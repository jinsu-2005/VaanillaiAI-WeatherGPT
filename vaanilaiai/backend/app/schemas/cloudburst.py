from enum import Enum
from typing import List, Dict, Optional
from pydantic import BaseModel, Field


class CloudburstCategory(str, Enum):
    NORMAL_RAIN = "NORMAL_RAIN"
    HEAVY_OROGRAPHIC = "HEAVY_OROGRAPHIC"
    MINI_CLOUDBURST = "MINI_CLOUDBURST"
    CLOUDBURST = "CLOUDBURST"


class LandslideRiskTier(str, Enum):
    LOW_STABLE = "LOW_STABLE"
    MODERATE_WATCH = "MODERATE_WATCH"
    HIGH_WARNING = "HIGH_WARNING"
    CRITICAL_IMMINENT_FAILURE = "CRITICAL_IMMINENT_FAILURE"


class FlashFloodStage(str, Enum):
    NORMAL_FLOW = "NORMAL_FLOW"
    BANKFULL_STAGE = "BANKFULL_STAGE"
    TORRENTIAL_SURGE = "TORRENTIAL_SURGE"
    CATASTROPHIC_DEBRIS_FLOW = "CATASTROPHIC_DEBRIS_FLOW"


class OrographicPrecipitationTelemetry(BaseModel):
    rain_rate_mm_hr: float = Field(..., description="Current localized rain rate in mm/hr")
    accumulated_3h_mm: float = Field(..., description="3-hour cumulative orographic rainfall in mm")
    accumulated_24h_mm: float = Field(..., description="24-hour cumulative rainfall in mm")
    condensation_level_m: float = Field(..., description="Orographic Lifted Condensation Level (LCL) in meters")
    cloud_top_height_km: float = Field(..., description="Convective cloud top height in km")
    radar_reflectivity_dbz: float = Field(..., description="Doppler radar core reflectivity in dBZ")
    cloudburst_category: CloudburstCategory = Field(..., description="IMD Cloudburst categorization tier")


class SlopeStabilityMetrics(BaseModel):
    slope_angle_degrees: float = Field(..., description="Mean slope steepness angle in degrees")
    ari_3day_mm: float = Field(..., description="GSI 3-day Antecedent Rainfall Index in mm")
    ari_15day_mm: float = Field(..., description="GSI 15-day Antecedent Rainfall Index in mm")
    pore_water_pressure_ratio: float = Field(..., description="Soil pore-water pressure saturation ratio (0.0 to 1.0)")
    factor_of_safety: float = Field(..., description="Slope stability Factor of Safety (FS < 1.0 indicates failure)")
    landslide_risk_tier: LandslideRiskTier = Field(..., description="GSI Landslide Warning Tier")


class DebrisFlowHydrodynamics(BaseModel):
    peak_discharge_m3_s: float = Field(..., description="Peak catchment runoff discharge rate in m^3/s")
    debris_slurry_volume_m3: float = Field(..., description="Estimated boulder-mud slurry volume in m^3")
    boulder_velocity_m_s: float = Field(..., description="Debris surge front velocity in m/s")
    bridge_scour_threat: str = Field(..., description="Bridge pier and culvert hydrodynamic scour hazard level")
    flash_flood_stage: FlashFloodStage = Field(..., description="Catchment flash flood stage")


class MountainSafetyDirectives(BaseModel):
    evacuation_order: str = Field(..., description="Immediate civilian evacuation protocol")
    pilgrimage_transit_advisory: str = Field(..., description="Guidance for high-altitude pilgrims (Char Dham, Sabarimala)")
    ghat_road_transit_status: str = Field(..., description="Mountain highway/ghat pass status (NHAI / PWD / BRO)")
    plantation_worker_protocol: str = Field(..., description="Safety directives for valley slope and tea estate workers")


class MountainCatchmentHotspot(BaseModel):
    catchment_id: str = Field(..., description="Unique slug for mountain valley catchment")
    catchment_name: str = Field(..., description="Official catchment or valley name")
    mountain_range: str = Field(..., description="Mountain system (Himalayas, Western Ghats Sahyadri, Nilgiris)")
    state: str = Field(..., description="State or Union Territory")
    elevation_m: int = Field(..., description="Mean valley bottom/settlement elevation in meters")
    latitude: float = Field(..., description="Latitude coordinate")
    longitude: float = Field(..., description="Longitude coordinate")
    dominant_lithology: str = Field(..., description="Bedrock and overburden lithology (e.g. Granitic Gneiss, Weathered Basalt, Schist)")
    orographic_precipitation: OrographicPrecipitationTelemetry = Field(..., description="Rain rate and radar metrics")
    slope_stability: SlopeStabilityMetrics = Field(..., description="GSI slope geotechnical metrics")
    hydrodynamics: DebrisFlowHydrodynamics = Field(..., description="Catchment discharge and debris flow metrics")
    directives: MountainSafetyDirectives = Field(..., description="Actionable disaster mitigation directives")
    bulletins: Dict[str, str] = Field(..., description="Localized emergency warnings in EN, HI, ML, MR, TA")


class CloudburstResponse(BaseModel):
    timestamp: str = Field(..., description="Assessment UTC timestamp")
    selected_catchment: MountainCatchmentHotspot = Field(..., description="Currently selected or nearest mountain catchment")
    all_catchments: List[MountainCatchmentHotspot] = Field(..., description="All monitored Western Ghats and Himalayan catchments")
    vernacular_bulletins: Dict[str, str] = Field(..., description="Localized emergency bulletins in EN, HI, ML, MR, TA")
    bulletin_number: str = Field(..., description="Official IMD Mountain Met & GSI NLEWS Bulletin reference")
    provenance: str = Field(default="IMD Mountain Meteorology Division & Geological Survey of India (GSI) NLEWS")
    is_offline_cached: bool = Field(default=False, description="Whether data was served from offline cache")
