from enum import Enum
from typing import List, Dict, Optional
from pydantic import BaseModel, Field


class SurgeThreatTier(str, Enum):
    EMERGENCY_RED = "EMERGENCY_RED"        # Catastrophic surge >2.5m, severe dyke breach, mandatory cyclone shelter evacuation
    WARNING_ORANGE = "WARNING_ORANGE"      # Severe surge 1.2m-2.5m, embankment overtopping, saltwater ingress, lock sluices
    WATCH_YELLOW = "WATCH_YELLOW"          # Moderate surge 0.5m-1.2m, high astronomical spring tide alignment
    NORMAL_GREEN = "NORMAL_GREEN"          # Astronomical tide within normal tidal prism, surge residual <0.5m


class TidalPhaseType(str, Enum):
    SPRING_HIGH_TIDE = "SPRING_HIGH_TIDE"  # Syzygy (New/Full Moon) - maximum gravitational pull
    NEAP_HIGH_TIDE = "NEAP_HIGH_TIDE"      # Quadrature - moderate tidal height
    FLOOD_TIDE = "FLOOD_TIDE"              # Incoming rising tide
    EBB_TIDE = "EBB_TIDE"                  # Outgoing receding tide
    SPRING_LOW_TIDE = "SPRING_LOW_TIDE"


class CyclonicForcingParameters(BaseModel):
    cyclone_name: str = Field(..., description="Designated cyclone or tropical depression name")
    imd_classification: str = Field(..., description="IMD cyclonic intensity scale classification")
    sustained_wind_speed_kmh: float = Field(..., description="Maximum sustained wind speed in km/h (10-min average)")
    central_pressure_hpa: float = Field(..., description="Estimated central atmospheric sea-level pressure in hPa")
    forward_speed_kmh: float = Field(..., description="Cyclone translation / forward movement velocity in km/h")
    landfall_point: str = Field(..., description="Projected or observed coastal landfall location")
    distance_to_landfall_km: float = Field(..., description="Distance between cyclone center and sector coastline in km")


class HydrodynamicComponents(BaseModel):
    astronomical_tide_m: float = Field(..., description="Astronomical predicted tide level above Chart Datum (CD) in meters")
    storm_surge_peak_m: float = Field(..., description="Wind stress and inverted barometer meteorological surge anomaly in meters")
    wave_setup_m: float = Field(..., description="Radiation stress sea level elevation from breaking surf waves in meters")
    total_water_level_m: float = Field(..., description="Coupled Total Water Level (TWL = Tide + Surge + Wave Setup) in meters")
    coastal_embankment_crest_m: float = Field(..., description="Elevation of coastal dyke, earthen bund, or seawall above CD in meters")
    overtopping_depth_m: float = Field(..., description="Depth of water spilling over coastal protection structures in meters")
    freeboard_margin_m: float = Field(..., description="Remaining barrier height safety margin above peak TWL in meters")
    peak_surge_window_utc: str = Field(..., description="Anticipated critical inundation time window in UTC")


class TidalBoreMetrics(BaseModel):
    bore_phenomenon_active: bool = Field(..., description="Whether a tidal bore wave is generated in the funnel-shaped estuary")
    bore_height_m: float = Field(..., description="Height of the leading tidal bore wavefront in meters")
    bore_propagation_speed_kmh: float = Field(..., description="Upriver propagation velocity of the tidal bore in km/h")
    upstream_penetration_km: float = Field(..., description="Distance inland the tidal bore travels against river discharge in km")
    river_basin_name: str = Field(..., description="Estuarine river system subject to bore phenomenon")
    bore_safety_advisory: str = Field(..., description="Specific caution for country boats, jetties, and riverbank settlements")


class SalineInundationMetrics(BaseModel):
    max_inland_intrusion_km: float = Field(..., description="Maximum horizontal saltwater ingress distance inland from coastline in km")
    estimated_inundated_area_sq_km: float = Field(..., description="Projected coastal area submerged by saline surge waters in sq km")
    surge_water_salinity_ppt: float = Field(..., description="Salinity of floodwaters in parts per thousand (PPT / PSU)")
    embankment_breaches_reported: int = Field(..., description="Number of reported or simulated embankment fractures/breaches")
    paddy_aquaculture_contamination_risk: str = Field(..., description="Risk assessment for agricultural topsoil and freshwater fishponds")


class CoastalInfrastructureDirectives(BaseModel):
    sluice_gate_action: str = Field(..., description="Operational order for irrigation/drainage sluices and flap gates")
    storm_surge_barrier_status: str = Field(..., description="Status of major coastal storm surge barriers and barrage gates")
    cyclone_shelter_mobilization: str = Field(..., description="Disaster management directive for multi-purpose cyclone shelters")
    marine_craft_harbor_directive: str = Field(..., description="Mandatory safety action for fishing boats, trawlers, and barges")
    drinking_water_well_sealing_order: str = Field(..., description="Public health directive to prevent saline contamination of tube wells")
    designated_shelters: List[str] = Field(..., description="Identified cyclone and tidal surge shelters in the sector")


class EstuarySurgeSector(BaseModel):
    sector_id: str = Field(..., description="Unique slug for coastal estuary/delta sector")
    sector_name: str = Field(..., description="Public geographic name of coastal estuary sector")
    state: str = Field(..., description="Indian Coastal State or Union Territory")
    water_body: str = Field(..., description="Connected ocean basin, gulf, or bay")
    latitude: float = Field(..., description="Representative centroid latitude")
    longitude: float = Field(..., description="Representative centroid longitude")
    threat_tier: SurgeThreatTier = Field(..., description="INCOIS-IMD storm surge threat classification")
    tidal_phase: TidalPhaseType = Field(..., description="Prevailing astronomical tidal cycle")
    cyclonic_forcing: CyclonicForcingParameters = Field(..., description="Atmospheric and cyclone forcing telemetry")
    hydrodynamics: HydrodynamicComponents = Field(..., description="Coupled Total Water Level numerical breakdown")
    tidal_bore: TidalBoreMetrics = Field(..., description="Estuarine tidal bore dynamics and upriver wave tracking")
    inundation: SalineInundationMetrics = Field(..., description="Saline water ingress and soil salinization risk")
    directives: CoastalInfrastructureDirectives = Field(..., description="Civil protection, sluice gate, and shelter directives")
    vernacular_bulletins: Dict[str, str] = Field(..., description="Localized emergency warnings in English, Hindi, and regional language")


class StormSurgeResponse(BaseModel):
    timestamp: str = Field(..., description="ISO 8601 generation timestamp")
    bulletin_number: str = Field(..., description="Official INCOIS-IMD coastal inundation bulletin sequence")
    provenance: str = Field(..., description="Institutional source (INCOIS / IMD ADCIRC-SWAN Numerical Storm Surge Model)")
    national_coastal_threat_summary: str = Field(..., description="National synoptic overview of storm surge & tidal inundation")
    selected_sector: EstuarySurgeSector = Field(..., description="Evaluated coastal estuary sector")
    all_sectors: List[EstuarySurgeSector] = Field(..., description="All monitored coastal estuaries and tidal deltas")
    numerical_model_coupling: str = Field(..., description="Details of coupled hydrodynamic numerical modeling system")
    vernacular_bulletins: Dict[str, str] = Field(..., description="Multi-lingual emergency coastal advisory broadcasts")
    is_offline_cached: bool = Field(default=False, description="Whether response originated from offline cache")
