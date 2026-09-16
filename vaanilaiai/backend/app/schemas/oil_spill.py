from enum import Enum
from typing import Dict, List, Optional
from pydantic import BaseModel, Field


class SpillSeverityTier(str, Enum):
    TIER_1_LOCAL_PORT = "TIER_1_LOCAL_PORT"              # < 700 tonnes; Local port authority / oil handling facility
    TIER_2_REGIONAL_COAST_GUARD = "TIER_2_REGIONAL_COAST_GUARD"  # 700 - 10,000 tonnes; Regional ICG & State Disaster Authority
    TIER_3_NATIONAL_NOSDCP = "TIER_3_NATIONAL_NOSDCP"    # > 10,000 tonnes; National Contingency Plan activated by DG ICG


class OilTypeClassification(str, Enum):
    LIGHT_REFINED_DIESEL = "LIGHT_REFINED_DIESEL"        # HSD / Gas Oil; high evaporation (50-70%), rapid dispersion
    MEDIUM_CRUDE_ARABIAN_LIGHT = "MEDIUM_CRUDE_ARABIAN_LIGHT"  # API 33-35°; moderate evaporation, rapid emulsification
    HEAVY_BUNKER_FUEL_FO180 = "HEAVY_BUNKER_FUEL_FO180"  # Heavy fuel oil; low evaporation (<15%), persistent tar mats
    CONDENSATE = "CONDENSATE"                            # Very light; explosive flammability, rapid vaporization (>80%)


class BonnAppearanceCode(str, Enum):
    CODE_1_SHEEN = "CODE_1_SHEEN"                        # Thickness: 0.04 - 0.30 µm; Silver/grey sheen
    CODE_2_RAINBOW = "CODE_2_RAINBOW"                    # Thickness: 0.30 - 5.0 µm; Rainbow colors
    CODE_3_METALLIC = "CODE_3_METALLIC"                  # Thickness: 5.0 - 50 µm; Metallic sheen reflecting sea surface
    CODE_4_DISCONTINUOUS_TRUE = "CODE_4_DISCONTINUOUS_TRUE"  # Thickness: 50 - 200 µm; Discontinuous true oil color
    CODE_5_CONTINUOUS_TRUE = "CODE_5_CONTINUOUS_TRUE"    # Thickness: > 200 µm; Continuous dark/brown true color


class HydrodynamicDriftVector(BaseModel):
    surface_current_speed_knots: float = Field(..., description="Surface ocean tidal & residual current speed in knots")
    surface_current_direction_deg: float = Field(..., description="Surface current propagation direction (0-360°)")
    wind_speed_10m_knots: float = Field(..., description="10-meter marine surface wind speed in knots")
    wind_direction_deg: float = Field(..., description="Wind blowing from direction (0-360°)")
    net_drift_speed_knots: float = Field(..., description="Combined advective drift speed (Current + 3% Wind Leeway)")
    net_drift_direction_deg: float = Field(..., description="Resultant trajectory azimuth angle with Coriolis deflection")
    stokes_drift_knots: float = Field(..., description="Wave-induced Stokes drift contribution")


class TrajectoryWaypoint(BaseModel):
    time_horizon_hours: int = Field(..., description="Hours from spill initiation (+6h, +12h, +24h, +48h, +72h)")
    latitude: float = Field(..., description="Estimated slick centroid latitude")
    longitude: float = Field(..., description="Estimated slick centroid longitude")
    distance_traveled_km: float = Field(..., description="Total cumulative displacement in kilometers")
    slick_area_km2: float = Field(..., description="Projected surface slick area in square kilometers")
    slick_thickness_microns: float = Field(..., description="Average oil slick thickness in microns")
    appearance_code: BonnAppearanceCode = Field(..., description="Projected Bonn Agreement Appearance Code")
    shoreline_hit_risk: str = Field(..., description="Risk of shoreline stranding (e.g. HIGH_IMMINENT, LOW_OFFSHORE)")


class FaySpreadingMetrics(BaseModel):
    current_regime: str = Field(..., description="Active Fay spreading regime (Gravity-Inertia, Gravity-Viscous, or Viscous-Surface Tension)")
    slick_radius_meters: float = Field(..., description="Estimated circular slick radius in meters")
    slick_area_km2: float = Field(..., description="Total ocean surface coverage in square kilometers")
    average_thickness_microns: float = Field(..., description="Mean oil film thickness in microns")
    bonn_code: BonnAppearanceCode = Field(..., description="Current Bonn Agreement Appearance Code")
    thick_core_area_pct: float = Field(..., description="Percentage of slick holding 90% of oil volume in thick patches")


class WeatheringKinetics(BaseModel):
    evaporated_fraction_pct: float = Field(..., description="Percentage of spilled volume evaporated into atmosphere")
    emulsified_water_fraction_pct: float = Field(..., description="Water-in-oil emulsion content % (mousse formation)")
    emulsion_viscosity_cst: float = Field(..., description="Dynamic kinematic viscosity in centistokes (cSt)")
    viscosity_increase_factor: float = Field(..., description="Multiplication factor over initial crude viscosity")
    natural_dispersion_fraction_pct: float = Field(..., description="Percentage naturally dispersed into water column")
    sedimentation_sinking_risk: str = Field(..., description="Risk of sand/sediment agglomeration and sinking")
    flash_point_celsius: float = Field(..., description="Current safety flash point of weathered slick in °C")


class SensitiveHabitatNode(BaseModel):
    habitat_id: str = Field(..., description="Unique slug for sensitive coastal habitat")
    habitat_name: str = Field(..., description="Name of marine national park, mangrove, or sanctuary")
    ecosystem_type: str = Field(..., description="Ecosystem category (e.g. Coral Reefs, Mangrove Swamp, Turtle Rookery)")
    esi_rating: int = Field(..., ge=1, le=10, description="Environmental Sensitivity Index rating (1-10; 10=Most vulnerable)")
    distance_from_slick_km: float = Field(..., description="Current distance from slick leading edge in kilometers")
    estimated_impact_eta_hours: int = Field(..., description="Estimated hours before slick reaches habitat perimeter")
    priority_protection_rank: str = Field(..., description="Priority tier (e.g. PRIORITY_1_IMMEDIATE_DEFENSE)")
    boom_defense_plan: str = Field(..., description="Targeted containment/exclusion boom layout strategy")


class IcgContainmentDirectives(BaseModel):
    nosdcp_activation_level: SpillSeverityTier = Field(..., description="NOS-DCP Tier mobilization level")
    lead_response_authority: str = Field(..., description="Responsible agency (e.g. Indian Coast Guard District HQ)")
    containment_boom_type: str = Field(..., description="Recommended boom (e.g. Offshore Curtain Boom / Shore-Sealing Boom)")
    recommended_boom_length_meters: float = Field(..., description="Required boom deployment length in meters")
    maximum_towing_speed_knots: float = Field(..., description="Towing speed cap to prevent vortex entrainment (0.75 kt)")
    skimmer_selection: str = Field(..., description="Optimal mechanical skimmer type (e.g. Oleophilic Brush/Drum vs Weir)")
    chemical_dispersant_clearance: str = Field(..., description="CPCB/ICG clearance status for Type-II/III dispersant spraying")
    dispersant_restrictions: str = Field(..., description="Rules: Depth >20m, distance >5 km offshore, no coral lagoons")
    coast_guard_emergency_no: str = Field(default="1554", description="Indian Coast Guard Maritime Search & Rescue Hotline")


class OilSpillCorridor(BaseModel):
    corridor_id: str = Field(..., description="Unique slug identifier for maritime corridor")
    corridor_name: str = Field(..., description="Name of coastal sector, port, or marine national park")
    state_or_ut: str = Field(..., description="Indian State or Union Territory")
    latitude: float = Field(..., description="Incident origin latitude")
    longitude: float = Field(..., description="Incident origin longitude")
    spill_volume_tonnes: float = Field(..., description="Total oil volume spilled in metric tonnes")
    oil_type: OilTypeClassification = Field(..., description="Classification of spilled hydrocarbon")
    severity_tier: SpillSeverityTier = Field(..., description="NOS-DCP emergency severity tier")
    drift_vector: HydrodynamicDriftVector = Field(..., description="Coupled ocean current and wind drift kinematics")
    trajectory_waypoints: List[TrajectoryWaypoint] = Field(..., description="Sequential trajectory points (+6h to +72h)")
    fay_spreading: FaySpreadingMetrics = Field(..., description="Slick area and thickness spreading metrics")
    weathering: WeatheringKinetics = Field(..., description="Evaporation and emulsification kinetics")
    sensitive_habitats: List[SensitiveHabitatNode] = Field(..., description="Downstream vulnerable ecosystems and ESI ratings")
    icg_directives: IcgContainmentDirectives = Field(..., description="Indian Coast Guard NOS-DCP operational directives")


class CorridorSummary(BaseModel):
    corridor_id: str
    corridor_name: str
    state_or_ut: str
    severity_tier: SpillSeverityTier
    oil_type: OilTypeClassification
    spill_volume_tonnes: float
    slick_area_km2: float
    nearest_habitat_eta_hours: int


class OilSpillResponse(BaseModel):
    selected_corridor: OilSpillCorridor = Field(..., description="Comprehensive oil spill telemetry for selected sector")
    all_corridors: List[CorridorSummary] = Field(..., description="Catalog of 7 vulnerable Indian coastal maritime corridors")
    bulletins: Dict[str, str] = Field(..., description="Emergency maritime coastal bulletins in 7 Indian coastal languages")
    offline_cached: bool = Field(default=False, description="Whether data is served from calibrated offline baseline")
    generated_at: str = Field(..., description="ISO 8601 generation timestamp")
