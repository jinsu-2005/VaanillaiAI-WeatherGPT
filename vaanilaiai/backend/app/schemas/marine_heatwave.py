from enum import Enum
from typing import List, Dict, Optional
from pydantic import BaseModel, Field


class CoralBleachingAlertLevel(str, Enum):
    NO_STRESS = "NO_STRESS"
    BLEACHING_WATCH = "BLEACHING_WATCH"
    BLEACHING_WARNING = "BLEACHING_WARNING"
    ALERT_LEVEL_1 = "ALERT_LEVEL_1"
    ALERT_LEVEL_2 = "ALERT_LEVEL_2"


class MarineHeatwaveCategory(str, Enum):
    CATEGORY_I_MODERATE = "CATEGORY_I_MODERATE"
    CATEGORY_II_STRONG = "CATEGORY_II_STRONG"
    CATEGORY_III_SEVERE = "CATEGORY_III_SEVERE"
    CATEGORY_IV_EXTREME = "CATEGORY_IV_EXTREME"


class SeaFogRiskTier(str, Enum):
    NO_FOG = "NO_FOG"
    LIGHT_HAZE = "LIGHT_HAZE"
    MODERATE_SEA_FOG = "MODERATE_SEA_FOG"
    DENSE_ADVECTION_FOG = "DENSE_ADVECTION_FOG"


class ThermalStressMetrics(BaseModel):
    sea_surface_temp_c: float = Field(..., description="Observed Sea Surface Temperature (SST) in °C")
    climatological_mmm_c: float = Field(..., description="Maximum Monthly Mean (MMM) SST baseline in °C")
    sst_anomaly_c: float = Field(..., description="SST anomaly departure from climatology in °C")
    coral_hotspot_c: float = Field(..., description="Coral HotSpot thermal surplus above MMM in °C")
    degree_heating_weeks: float = Field(..., description="Degree Heating Weeks (DHW) accumulation in °C-weeks")
    bleaching_alert_level: CoralBleachingAlertLevel = Field(..., description="INCOIS / NOAA Coral Reef Watch bleaching tier")


class MarineHeatwaveTelemetry(BaseModel):
    category: MarineHeatwaveCategory = Field(..., description="Hobday et al. Marine Heatwave category (I to IV)")
    duration_days: int = Field(..., description="Continuous days above 90th percentile MHW threshold")
    peak_anomaly_c: float = Field(..., description="Peak temperature surge during current MHW event in °C")
    depth_penetration_m: float = Field(..., description="Effective warm water layer depth in meters")
    pelagic_fish_displacement: str = Field(..., description="Pelagic fish migration advisory (Tuna, Sardines, Mackerel)")


class CoastalSeaFogTelemetry(BaseModel):
    is_fog_active: bool = Field(..., description="Whether coastal advection sea fog is currently detected")
    sea_air_temp_diff_c: float = Field(..., description="Air-Sea thermal gradient (T_air - SST in °C)")
    nautical_visibility_m: float = Field(..., description="Marine nautical optical visibility in meters")
    marine_inversion_height_m: float = Field(..., description="Marine boundary layer thermal inversion cap in meters")
    vts_channel_status: str = Field(..., description="Port Vessel Traffic Service (VTS) navigation status")


class MarineConservationDirectives(BaseModel):
    reef_protection_notice: str = Field(..., description="Ecological protection directive for fragile corals")
    diving_tourism_advisory: str = Field(..., description="Scuba diving, snorkeling, and boat anchor guidance")
    artisanal_fisher_guidance: str = Field(..., description="Guidance for artisanal fishers on baitfish and deep-water lines")
    artificial_shading_status: str = Field(..., description="Shade cloth, nursery restoration, and coral cooling measures")


class MarineHotspotSector(BaseModel):
    hotspot_id: str = Field(..., description="Unique slug for coral reef or maritime corridor")
    sector_name: str = Field(..., description="Official sector name")
    maritime_zone: str = Field(..., description="Maritime basin (Gulf of Mannar, Arabian Sea, Bay of Bengal, Andaman Sea)")
    state_or_ut: str = Field(..., description="Coastal State or Union Territory")
    latitude: float = Field(..., description="Latitude coordinate")
    longitude: float = Field(..., description="Longitude coordinate")
    reef_type: str = Field(..., description="Reef morphology (Fringing Reef, Atoll, Patch Reef, Macro-tidal Intertidal)")
    dominant_coral_taxa: List[str] = Field(..., description="Dominant coral genera (Acropora, Porites, Favia, Pocillopora)")
    thermal_stress: ThermalStressMetrics = Field(..., description="SST and Degree Heating Weeks telemetry")
    heatwave: MarineHeatwaveTelemetry = Field(..., description="Marine Heatwave categorization metrics")
    coastal_fog: CoastalSeaFogTelemetry = Field(..., description="Coastal advection sea fog telemetry")
    directives: MarineConservationDirectives = Field(..., description="Ecological and artisanal economic guidance")


class MarineHeatwaveResponse(BaseModel):
    timestamp: str = Field(..., description="Assessment UTC timestamp")
    selected_sector: MarineHotspotSector = Field(..., description="Currently selected or nearest marine sector")
    all_sectors: List[MarineHotspotSector] = Field(..., description="Directory of all monitored reef and port corridors")
    vernacular_bulletins: Dict[str, str] = Field(..., description="Localized emergency bulletins in EN, TA, ML, GU, MR")
    bulletin_number: str = Field(..., description="Official INCOIS & MoES Marine Heatwave Bulletin reference")
    provenance: str = Field(default="INCOIS Ocean State Forecast, MoES Marine Living Resources & Coral Reef Watch")
    is_offline_cached: bool = Field(default=False, description="Whether data was served from offline cache")
