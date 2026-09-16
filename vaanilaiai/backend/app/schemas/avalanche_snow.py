from typing import List, Optional, Dict
from enum import Enum
from pydantic import BaseModel, Field


class AvalancheDangerLevel(str, Enum):
    LEVEL_1_LOW = "LEVEL_1_LOW"
    LEVEL_2_YELLOW_MODERATE = "LEVEL_2_YELLOW_MODERATE"
    LEVEL_3_ORANGE_DANGER = "LEVEL_3_ORANGE_DANGER"
    LEVEL_4_RED_HIGH_DANGER = "LEVEL_4_RED_HIGH_DANGER"
    LEVEL_5_BLACK_EXTREME = "LEVEL_5_BLACK_EXTREME"


class WdIntensity(str, Enum):
    NONE = "NONE"
    FEEBLE = "FEEBLE"
    MODERATE = "MODERATE"
    ACTIVE = "ACTIVE"
    INTENSE = "INTENSE"


class WeakLayerType(str, Enum):
    SURFACE_HOAR = "SURFACE_HOAR"
    DEPTH_HOAR_FACETS = "DEPTH_HOAR_FACETS"
    WIND_SLAB = "WIND_SLAB"
    RAIN_ON_SNOW = "RAIN_ON_SNOW"
    STABLE_ROUNDED_GRAINS = "STABLE_ROUNDED_GRAINS"


class PassTransitStatus(str, Enum):
    OPEN_NORMAL = "OPEN_NORMAL"
    CHAINS_MANDATORY = "CHAINS_MANDATORY"
    CONVOY_TIMED_ONE_WAY = "CONVOY_TIMED_ONE_WAY"
    CLOSED_SNOW_CLEARING = "CLOSED_SNOW_CLEARING"
    BLOCKED_AVALANCHE = "BLOCKED_AVALANCHE"


class WesternDisturbanceTelemetry(BaseModel):
    intensity: WdIntensity = Field(..., description="Intensity of active Western Disturbance")
    subtropical_jet_speed_kt: float = Field(..., description="Subtropical Westerly Jet speed at 200 hPa in knots")
    trough_500hpa_depth_dam: float = Field(..., description="500 hPa geopotential height trough depth in decameters")
    induced_cyclonic_circulation: str = Field(..., description="Location of low-level induced cyclonic circulation")
    moisture_source: str = Field(..., description="Primary oceanic and basin moisture feeds")
    freezing_level_m: float = Field(..., description="Zero-degree Celsius isotherm altitude in meters MSL")
    synoptic_summary: str = Field(..., description="Meteorological synopsis of the synoptic disturbance")


class SnowpackPhysics(BaseModel):
    total_snowpack_depth_cm: float = Field(..., description="Cumulative settled snowpack depth on ground in cm")
    fresh_snow_24h_cm: float = Field(..., description="Fresh snowfall accumulation over the last 24 hours in cm")
    snow_water_equivalent_mm: float = Field(..., description="Snow Water Equivalent (SWE) in mm")
    average_density_kg_m3: float = Field(..., description="Average bulk snowpack density in kg/m³")
    critical_slope_angle_deg: float = Field(..., description="Critical avalanche track / release slope angle in degrees")
    primary_weak_layer: WeakLayerType = Field(..., description="Primary failure plane weak layer identified in snow profile")
    weak_layer_depth_cm: float = Field(..., description="Depth of weak structural layer beneath surface in cm")
    aspect_hazard: str = Field(..., description="Hazardous slope exposures and aspects (e.g. North-East to East lee aspects)")


class MountainPassStatus(BaseModel):
    pass_name: str = Field(..., description="Strategic mountain pass name (e.g. Zoji La, Khardung La)")
    altitude_m: float = Field(..., description="Pass summit altitude in meters")
    altitude_ft: int = Field(..., description="Pass summit altitude in feet")
    highway_code: str = Field(..., description="National or state strategic highway code (e.g. NH-1, Leh-Manali Highway)")
    status: PassTransitStatus = Field(..., description="Current vehicle transit operational status")
    bro_operational_status: str = Field(..., description="Border Roads Organisation (BRO) clearance status update")
    bro_equipment_deployed: List[str] = Field(..., description="Active machinery (e.g. Snow Cutters, Dozers, Wheel Loaders)")
    chains_required: bool = Field(..., description="Whether metallic tire chains are mandatory for transit")


class HighAltitudeSafety(BaseModel):
    elevation_m: float = Field(..., description="Target altitude in meters")
    ams_risk: str = Field(..., description="Acute Mountain Sickness risk rating (e.g. High above 3,500m)")
    hypothermia_risk: str = Field(..., description="Cold injury & hypothermia risk rating")
    bps_gear_mandatory: bool = Field(..., description="Whether Beacon, Probe, and Shovel are required for backcountry travel")
    travel_advisory: str = Field(..., description="Operational travel guidance for civilians, tourists, and pilgrims")
    emergency_helpline: str = Field(..., description="Emergency contact number for mountain rescue and BRO assistance")


class HimalayanSector(BaseModel):
    sector_id: str = Field(..., description="Unique sector identifier")
    sector_name: str = Field(..., description="Himalayan monitoring sector name")
    mountain_range: str = Field(..., description="Primary mountain range (e.g. Pir Panjal, Great Himalaya, Zanskar)")
    state_or_ut: str = Field(..., description="Indian State or Union Territory")
    latitude: float = Field(..., description="Sector centroid latitude")
    longitude: float = Field(..., description="Sector centroid longitude")
    base_elevation_m: float = Field(..., description="Base valley elevation in meters")
    peak_elevation_m: float = Field(..., description="Peak mountain ridge elevation in meters")
    danger_level: AvalancheDangerLevel = Field(..., description="DGRE 5-stage avalanche danger level")
    danger_rating_text: str = Field(..., description="Descriptive danger classification text")
    snowpack: SnowpackPhysics = Field(..., description="Cryospheric snowpack physical properties")
    pass_status: MountainPassStatus = Field(..., description="Associated BRO mountain pass status")
    safety: HighAltitudeSafety = Field(..., description="High-altitude safety directives")


class AvalancheSnowResponse(BaseModel):
    timestamp: str = Field(..., description="ISO-8601 generation timestamp")
    selected_sector: HimalayanSector = Field(..., description="Active or nearest Himalayan sector")
    all_sectors: List[HimalayanSector] = Field(..., description="All monitored Himalayan alpine sectors")
    western_disturbance: WesternDisturbanceTelemetry = Field(..., description="Synoptic Western Disturbance telemetry")
    vernacular_bulletins: Dict[str, str] = Field(..., description="Multilingual emergency bulletins (EN, HI, UR, PA, BN)")
    dgre_advisory_bulletin_no: str = Field(..., description="DGRE / IMD joint bulletin operational reference number")
    provenance: str = Field(..., description="Data provenance attribution (IMD Mountain Weather & DRDO DGRE)")
