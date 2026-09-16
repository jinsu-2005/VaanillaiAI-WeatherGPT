from enum import Enum
from typing import List, Dict, Optional
from pydantic import BaseModel, Field


class FireDangerRatingTier(str, Enum):
    LOW = "LOW"
    MODERATE = "MODERATE"
    HIGH = "HIGH"
    VERY_HIGH = "VERY_HIGH"
    EXTREME = "EXTREME"


class ForestBiomeType(str, Enum):
    CHIR_PINE_CONIFEROUS = "CHIR_PINE_CONIFEROUS"
    DRY_DECIDUOUS_SAL = "DRY_DECIDUOUS_SAL"
    DRY_DECIDUOUS_TEAK = "DRY_DECIDUOUS_TEAK"
    BAMBOO_BRAKES = "BAMBOO_BRAKES"
    SHOLA_GRASSLAND_MOSAIC = "SHOLA_GRASSLAND_MOSAIC"
    THORN_SCRUB = "THORN_SCRUB"


class SatelliteSensor(str, Enum):
    SNPP_VIIRS_375M = "SNPP_VIIRS_375M"
    NOAA20_VIIRS_375M = "NOAA20_VIIRS_375M"
    MODIS_TERRA_1KM = "MODIS_TERRA_1KM"
    MODIS_AQUA_1KM = "MODIS_AQUA_1KM"


class FireWeatherIndices(BaseModel):
    ffmc_fine_fuel_moisture: float = Field(..., description="Fine Fuel Moisture Code (0-101; tracks surface litter ignition potential)")
    dmc_duff_moisture: float = Field(..., description="Duff Moisture Code (organic decomposition layer moisture)")
    dc_drought_code: float = Field(..., description="Drought Code (deep organic layers and heavy dead wood deficit)")
    isi_initial_spread_index: float = Field(..., description="Initial Spread Index (rate of fire spread coupled to 10m wind)")
    bui_buildup_index: float = Field(..., description="Buildup Index (total fuel available for combustion)")
    fwi_fire_weather_index: float = Field(..., description="Fire Weather Index (frontal fire line intensity in kW/m)")
    danger_tier: FireDangerRatingTier = Field(..., description="FSI Van Agni 2.0 Fire Danger Rating Tier")


class ActiveThermalAnomaly(BaseModel):
    sensor: SatelliteSensor = Field(..., description="Satellite sensor detecting active fire pixel")
    detection_timestamp: str = Field(..., description="ISO 8601 thermal anomaly acquisition timestamp")
    latitude: float = Field(..., description="Thermal anomaly latitude")
    longitude: float = Field(..., description="Thermal anomaly longitude")
    brightness_temp_kelvin: float = Field(..., description="Middle-infrared brightness temperature in Kelvin (T4/I4)")
    fire_radiative_power_mw: float = Field(..., description="Fire Radiative Power in Megawatts (MW)")
    confidence_pct: float = Field(..., description="Detection confidence percentage")


class FireBehaviorMetrics(BaseModel):
    estimated_rate_of_spread_m_hr: float = Field(..., description="Forward flame front rate of spread in meters/hour")
    flame_length_m: float = Field(..., description="Mean continuous flame length in meters")
    fireline_intensity_kw_m: float = Field(..., description="Byram's fireline intensity in kW/meter")
    crown_fire_risk: bool = Field(..., description="Whether ground fire is transitioning to tree canopy crown fire")
    spot_fire_probability_pct: float = Field(..., description="Probability of lofted airborne ember spotting ignition (%)")


class ForestryProtectionDirectives(BaseModel):
    ranger_deployment_alert: str = Field(..., description="State Forest Department and Van Samiti action level")
    firebreak_clearance_width_m: float = Field(..., description="Required counter-fire break line clearance width in meters")
    wildlife_corridor_status: str = Field(..., description="Sanctuary wildlife migration corridor and waterhole safety status")
    tribal_ntfp_collection_directive: str = Field(..., description="Non-Timber Forest Produce gathering restrictions for fringe villages")
    aerial_water_bombing_standby: bool = Field(..., description="Whether IAF Bambi Bucket / NDRF helicopter water drop is on standby")


class ForestFireZoneHotspot(BaseModel):
    zone_id: str = Field(..., description="Unique slug for the forest zone")
    zone_name: str = Field(..., description="Public name of the forest division")
    state: str = Field(..., description="State jurisdiction")
    reserve_name: str = Field(..., description="National park, tiger reserve or biosphere name")
    latitude: float = Field(..., description="Centroid latitude")
    longitude: float = Field(..., description="Centroid longitude")
    biome_type: ForestBiomeType = Field(..., description="Dominant ecological forest biome")
    indices: FireWeatherIndices = Field(..., description="Canadian FWI System indices")
    active_thermal_hotspots: List[ActiveThermalAnomaly] = Field(..., description="Satellite detected thermal fire pixels")
    total_frp_mw: float = Field(..., description="Cumulative Fire Radiative Power in Megawatts")
    behavior: FireBehaviorMetrics = Field(..., description="Estimated fire physics and spread behavior")
    directives: ForestryProtectionDirectives = Field(..., description="Forest ranger and village safety directives")
    localized_bulletins: Dict[str, str] = Field(..., description="Vernacular forestry bulletins (EN, HI, KN, OR, TA)")


class ForestFireResponse(BaseModel):
    timestamp: str = Field(..., description="ISO 8601 generation timestamp")
    bulletin_number: str = Field(..., description="Official FSI-ISRO forest fire bulletin identifier")
    provenance: str = Field(..., description="Institutional provenance (FSI Van Agni 2.0 / ISRO Bhuvan / IMD)")
    selected_zone: ForestFireZoneHotspot = Field(..., description="Target forest fire hotspot")
    all_zones: List[ForestFireZoneHotspot] = Field(..., description="Catalog of all monitored eco-sensitive forest zones")
    vernacular_bulletins: Dict[str, str] = Field(..., description="Multilingual emergency forestry bulletins")
    is_offline_cached: bool = Field(default=False, description="Whether response originated from offline storage")
