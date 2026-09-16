from enum import Enum
from typing import Dict, List, Optional
from pydantic import BaseModel, Field


class GlofThreatTier(str, Enum):
    CRITICAL_RED_BREACH_IMMINENT = "CRITICAL_RED_BREACH_IMMINENT"
    HIGH_ORANGE_WARNING = "HIGH_ORANGE_WARNING"
    MODERATE_YELLOW_WATCH = "MODERATE_YELLOW_WATCH"
    LOW_GREEN_MONITOR = "LOW_GREEN_MONITOR"


class BreachTriggerMechanism(str, Enum):
    OVERTOPPING_ICE_AVALANCHE_SURGE = "OVERTOPPING_ICE_AVALANCHE_SURGE"
    INTERNAL_PIPING_SEEPAGE_COLLAPSE = "INTERNAL_PIPING_SEEPAGE_COLLAPSE"
    MORAINIC_SLOPE_SLUMPING = "MORAINIC_SLOPE_SLUMPING"
    STABLE_WATCH = "STABLE_WATCH"


class GlacialLakeMorphometry(BaseModel):
    surface_area_ha: float = Field(..., description="Lake surface area in hectares")
    surface_area_km2: float = Field(..., description="Lake surface area in square kilometers")
    mean_depth_m: float = Field(..., description="Estimated bathymetric mean depth in meters")
    max_depth_m: float = Field(..., description="Maximum bathymetric depth near moraine face in meters")
    water_volume_million_m3: float = Field(..., description="Total impounded water volume in million cubic meters")
    expansion_rate_10yr_pct: float = Field(..., description="10-year surface area expansion percentage from satellite SAR")
    satellite_sensor_provenance: str = Field(..., description="Earth observation platform (e.g. Sentinel-1 SAR / RISAT-1A / Cartosat)")


class MoraineDamGeotechnics(BaseModel):
    crest_elevation_m: float = Field(..., description="Moraine dam crest elevation in meters MSL")
    dam_height_m: float = Field(..., description="Moraine dam structural height above valley base in meters")
    crest_width_to_height_ratio: float = Field(..., description="Width-to-height ratio (Wm / Hm; < 2.0 indicates acute instability)")
    freeboard_height_m: float = Field(..., description="Freeboard height between lake surface and dam crest in meters")
    permafrost_degradation_pct: float = Field(..., description="Moraine core ice permafrost thaw degradation index %")
    hydraulic_piping_index: float = Field(..., description="Ratio of hydraulic gradient to critical piping gradient (i / i_crit)")
    stability_status: str = Field(..., description="Geotechnical assessment summary (e.g. Acute piping risk, Marginally stable)")


class BreachHydrodynamics(BaseModel):
    peak_outflow_discharge_m3_s: float = Field(..., description="Peak breach discharge rate Qp in cubic meters per second")
    breach_formation_time_hours: float = Field(..., description="Estimated breach channel development duration in hours")
    total_breach_volume_million_m3: float = Field(..., description="Total flood surge volume released in million cubic meters")
    wave_propagation_speed_kmh: float = Field(..., description="Downstream surge wave front celerity in km/h")
    trigger_mechanism: BreachTriggerMechanism = Field(..., description="Primary breach trigger mechanism")


class DownstreamImpactNode(BaseModel):
    node_name: str = Field(..., description="Name of settlement, bridge, or hydropower infrastructure")
    distance_km: float = Field(..., description="Distance downstream from moraine dam in kilometers")
    wave_arrival_eta_min: int = Field(..., description="Estimated flood wave front arrival time (ETA) in minutes")
    peak_surge_depth_m: float = Field(..., description="Projected peak flood stage height above normal riverbed in meters")
    infrastructure_alert: str = Field(..., description="Infrastructure status and emergency actions (e.g. Barrage radial gates flush)")
    evacuation_zone_elevation_m: float = Field(..., description="Minimum vertical evacuation height above current riverbed in meters")


class GlacialLakeCorridor(BaseModel):
    lake_id: str = Field(..., description="Unique slug identifier for the glacial lake")
    lake_name: str = Field(..., description="Official name of the glacial lake")
    river_basin: str = Field(..., description="Primary river catchment basin (e.g. Teesta, Mandakini, Chandra, Sutlej)")
    state: str = Field(..., description="Indian State or Union Territory")
    latitude: float = Field(..., description="Latitude coordinate")
    longitude: float = Field(..., description="Longitude coordinate")
    elevation_m: float = Field(..., description="Lake altitude above mean sea level in meters")
    threat_tier: GlofThreatTier = Field(..., description="NDMA early warning categorization tier")
    morphometry: GlacialLakeMorphometry = Field(..., description="Lake physical dimensions, volume, and expansion telemetry")
    moraine_geotechnics: MoraineDamGeotechnics = Field(..., description="Moraine dam structural and geotechnical stability parameters")
    breach_hydrodynamics: BreachHydrodynamics = Field(..., description="Breach outflow discharge and wave kinematics")
    downstream_impact_timeline: List[DownstreamImpactNode] = Field(..., description="Cascading downstream impact nodes with ETAs")
    ndma_safety_directives: List[str] = Field(..., description="NDMA mountain community and infrastructure emergency directives")


class LakeSummary(BaseModel):
    lake_id: str
    lake_name: str
    river_basin: str
    state: str
    elevation_m: float
    threat_tier: GlofThreatTier
    surface_area_ha: float
    volume_million_m3: float
    peak_discharge_m3_s: float
    earliest_eta_min: int


class GlofResponse(BaseModel):
    selected_lake: GlacialLakeCorridor = Field(..., description="Comprehensive GLOF telemetry for the selected lake")
    all_lakes: List[LakeSummary] = Field(..., description="Catalog of 7 vulnerable Himalayan glacial lakes")
    bulletins: Dict[str, str] = Field(..., description="Multi-lingual emergency bulletins in 7 Himalayan & regional languages")
    offline_cached: bool = Field(default=False, description="Flag indicating if served from offline baseline")
    generated_at: str = Field(..., description="ISO 8601 generation timestamp")
