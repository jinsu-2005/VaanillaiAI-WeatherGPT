from enum import Enum
from typing import List, Dict, Optional
from pydantic import BaseModel, Field


class WaveAlertTier(str, Enum):
    RED_WARNING = "RED_WARNING"        # Extreme wave threat (>4.0m) or deadly rip currents; water closed
    ORANGE_ALERT = "ORANGE_ALERT"      # High wave threat (2.5m - 4.0m); bathing strictly prohibited
    YELLOW_WATCH = "YELLOW_WATCH"      # Moderate waves (1.5m - 2.5m); swim only in designated zones
    GREEN_NORMAL = "GREEN_NORMAL"      # Calm sea state (<1.5m); low hazard, general swimming permitted


class LifeguardFlagStatus(str, Enum):
    DOUBLE_RED_PROHIBITED = "DOUBLE_RED_PROHIBITED"  # Beach closed, public water entry strictly forbidden
    RED_HIGH_HAZARD = "RED_HIGH_HAZARD"              # High hazard: rough surf and strong rip currents
    YELLOW_MEDIUM_HAZARD = "YELLOW_MEDIUM_HAZARD"    # Medium hazard: moderate surf and currents, caution
    GREEN_LOW_HAZARD = "GREEN_LOW_HAZARD"            # Low hazard: calm conditions, exercise standard care


class RipCurrentRiskLevel(str, Enum):
    HIGH_DEADLY = "HIGH_DEADLY"          # Dangerous seaward flow (>1.2 m/s), sweeps adult swimmers seaward
    MODERATE_CAUTION = "MODERATE_CAUTION"  # 0.5 - 1.2 m/s, dangerous for children and weak swimmers
    LOW_MINIMAL = "LOW_MINIMAL"          # <0.5 m/s, minimal seaward pull


class SeaStateWaveMetrics(BaseModel):
    significant_wave_height_m: float = Field(..., description="Significant wave height (Hs) in meters")
    maximum_wave_height_m: float = Field(..., description="Maximum expected wave height (Hmax) in meters")
    peak_wave_period_s: float = Field(..., description="Peak wave period (Tp) in seconds")
    mean_wave_direction_deg: float = Field(..., description="Mean wave propagation direction in degrees (0-360°)")
    wave_steepness_ratio: float = Field(..., description="Wave steepness ratio (Hs / Wavelength)")
    sea_surface_current_speed_knots: float = Field(..., description="Nearshore surface current velocity in knots")


class SwellSurgeKallakkadalMetrics(BaseModel):
    is_kallakkadal_active: bool = Field(..., description="Whether sudden long-period swell surge (Kallakkadal) is active")
    distant_source_basin: str = Field(..., description="Distant meteorological source basin driving the swell surge")
    swell_wave_period_s: float = Field(..., description="Swell wave period in seconds (e.g. 16-22s indicates distant southern ocean origin)")
    coastal_overwash_risk: str = Field(..., description="Risk of wave runup penetrating beyond high tide line")
    artisan_craft_anchoring_directive: str = Field(..., description="Instruction for beach-landed catamarans, vala boats, and FRP crafts")


class RipCurrentMetrics(BaseModel):
    risk_level: RipCurrentRiskLevel = Field(..., description="Rip current hazard classification")
    peak_rip_velocity_ms: float = Field(..., description="Estimated maximum seaward rip channel velocity in m/s")
    rip_channel_locations: List[str] = Field(..., description="Identified rip current channels along the beach frontage")
    rip_survival_instruction: str = Field(..., description="Critical emergency swimmer survival instruction if caught in a rip")


class BeachSafetyAndMaritimeDirectives(BaseModel):
    lifeguard_flag: LifeguardFlagStatus = Field(..., description="Beach lifeguard warning flag flown at towers")
    bathing_swimming_advisory: str = Field(..., description="Official advice for tourists, pilgrims, and sea bathers")
    water_sports_status: str = Field(..., description="Operational status of jet skis, parasailing, boat rides, and surfing")
    country_boat_catamaran_directive: str = Field(..., description="Operational directive for traditional artisanal fishermen")
    deep_sea_trawler_advisory: str = Field(..., description="Operational guidance for mechanized fishing vessels")
    active_lifeguard_towers_count: int = Field(..., description="Number of active coastal patrol lifeguard towers on duty")


class CoastalBeachSector(BaseModel):
    beach_id: str = Field(..., description="Unique slug for monitored beach or coastal hub")
    beach_name: str = Field(..., description="Public geographic name of tourist/pilgrim beach or fishing harbor")
    coastal_district: str = Field(..., description="District administrative zone")
    state: str = Field(..., description="State or Union Territory")
    water_body: str = Field(..., description="Connected sea or ocean basin (Arabian Sea / Bay of Bengal / Indian Ocean)")
    latitude: float = Field(..., description="Representative beach centroid latitude")
    longitude: float = Field(..., description="Representative beach centroid longitude")
    alert_tier: WaveAlertTier = Field(..., description="INCOIS wave threat tier")
    wave_metrics: SeaStateWaveMetrics = Field(..., description="Numerical wave physics telemetry")
    swell_surge: SwellSurgeKallakkadalMetrics = Field(..., description="Long-period swell surge (Kallakkadal) analysis")
    rip_current: RipCurrentMetrics = Field(..., description="Rip current hydrodynamics and channel locations")
    directives: BeachSafetyAndMaritimeDirectives = Field(..., description="Lifeguard, tourist, and fishermen directives")
    vernacular_broadcasts: Dict[str, str] = Field(..., description="Multilingual emergency marine advisories")


class OceanStateResponse(BaseModel):
    timestamp: str = Field(..., description="ISO 8601 generation timestamp")
    bulletin_number: str = Field(..., description="Official INCOIS Ocean State Forecast bulletin sequence")
    provenance: str = Field(..., description="Institutional provenance (INCOIS OSF & Beach Rip Current Warning System)")
    national_sea_state_synopsis: str = Field(..., description="National synoptic coastal ocean state overview")
    selected_beach: CoastalBeachSector = Field(..., description="Target evaluated beach or coastal harbor")
    all_beaches: List[CoastalBeachSector] = Field(..., description="Catalog of monitored Indian beaches and fishing hubs")
    numerical_model_wave_watch: str = Field(..., description="Wave modeling framework (WAVEWATCH-III + Nearshore SWAN)")
    vernacular_broadcasts: Dict[str, str] = Field(..., description="Localized emergency broadcasts")
    is_offline_cached: bool = Field(default=False, description="Whether response originated from offline cache")
