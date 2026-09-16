"""Pydantic schemas for IMD & CWC National Flood Forecasting,
Hydrological Rating Curve & Embankment Breach Telemetry Engine (HYDRO-RATING).
"""

from enum import Enum
from typing import Dict, List, Optional
from pydantic import BaseModel, Field


class CwcFloodStageTier(str, Enum):
    """CWC 4-Tier flood stage benchmark classification."""
    NORMAL_FLOW = "NORMAL_FLOW"                 # Stage < Warning Level
    ABOVE_NORMAL = "ABOVE_NORMAL"               # Warning - 0.5m <= Stage < Warning Level
    WARNING_STAGE = "WARNING_STAGE"             # Warning Level <= Stage < Danger Level (Amber Alert)
    DANGER_STAGE = "DANGER_STAGE"               # Danger Level <= Stage < HFL (Red Alert)
    UNPRECEDENTED_FLOOD = "UNPRECEDENTED_FLOOD" # Stage >= Highest Flood Level (HFL Exceeded)


class FreeboardSafetyMarginTier(str, Enum):
    """Levee crest freeboard margin safety tier."""
    OPTIMAL_FREEBOARD = "OPTIMAL_FREEBOARD"             # Margin > 1.50 meters
    REDUCED_MARGIN = "REDUCED_MARGIN"                   # 0.75m < Margin <= 1.50 meters
    OVERTOPPING_THREAT = "OVERTOPPING_THREAT"           # 0.00m < Margin <= 0.75 meters
    CREST_OVERTOPPING_BREACH = "CREST_OVERTOPPING_BREACH" # Margin <= 0.00 meters (Direct breach/spill)


class EmbankmentPipingRiskTier(str, Enum):
    """Exit hydraulic gradient backward erosion / piping risk tier."""
    SAFE_STABLE = "SAFE_STABLE"                         # FS >= 2.50
    PIPING_WATCH = "PIPING_WATCH"                       # 1.80 <= FS < 2.50
    HIGH_SANDBOIL_RISK = "HIGH_SANDBOIL_RISK"           # 1.20 <= FS < 1.80 (Sand boils likely)
    IMMINENT_COLLAPSE_BREACH = "IMMINENT_COLLAPSE_BREACH" # FS < 1.20 (Critical piping instability)


class GumbelFloodReturnPeriod(str, Enum):
    """Gumbel Extreme Value Type-I (EV1) flood recurrence interval."""
    LESS_THAN_10_YEAR = "LESS_THAN_10_YEAR"   # Ordinary seasonal peak
    TEN_YEAR_FLOOD = "TEN_YEAR_FLOOD"         # 10-year recurrence interval
    TWENTY_FIVE_YEAR_FLOOD = "TWENTY_FIVE_YEAR_FLOOD" # 25-year recurrence interval
    FIFTY_YEAR_FLOOD = "FIFTY_YEAR_FLOOD"     # 50-year recurrence interval
    HUNDRED_YEAR_RECORD = "HUNDRED_YEAR_RECORD" # 100-year historic flood recurrence


class HydrologicalRatingCurveTelemetry(BaseModel):
    """Non-linear stage-discharge rating curve and Manning open-channel conveyance."""
    stage_height_m: float = Field(..., description="Current river water surface stage in meters above MSL")
    zero_flow_datum_h0_m: float = Field(..., description="Zero-flow gauge datum / riverbed invert elevation (h0 in m MSL)")
    effective_head_m: float = Field(..., description="Effective water head above gauge datum (h - h0 in meters)")
    rating_coefficient_a: float = Field(..., description="Calibrated rating curve conveyance coefficient a")
    hydraulic_exponent_b: float = Field(..., description="Hydraulic cross-sectional geometry exponent b")
    computed_discharge_cumecs: float = Field(..., description="Instantaneous discharge Q in cubic meters/sec (cumecs)")
    wetted_cross_section_area_m2: float = Field(..., description="Wetted cross-sectional flow area A in square meters")
    hydraulic_radius_m: float = Field(..., description="Hydraulic radius Rh = A / P in meters")
    manning_roughness_n: float = Field(..., description="Manning's channel roughness coefficient n")
    channel_energy_slope: float = Field(..., description="Longitudinal bed energy slope S0 (e.g. 0.00025)")
    mean_flow_velocity_mps: float = Field(..., description="Cross-sectional mean flow velocity V = Q / A in m/s")


class EmbankmentStructuralSafetyMetrics(BaseModel):
    """River embankment / levee crest freeboard and seepage piping stability."""
    embankment_crest_level_m: float = Field(..., description="Elevation of levee/embankment crest in m MSL")
    countryside_toe_level_m: float = Field(..., description="Elevation of countryside embankment toe in m MSL")
    freeboard_margin_m: float = Field(..., description="Net freeboard margin (crest - stage) in meters")
    freeboard_tier: FreeboardSafetyMarginTier = Field(..., description="Freeboard margin safety classification")
    seepage_path_length_m: float = Field(..., description="Effective hydraulic seepage path length L in meters")
    exit_hydraulic_gradient: float = Field(..., description="Exit hydraulic gradient i = Delta_h / L")
    critical_hydraulic_gradient: float = Field(..., description="Critical flotation hydraulic gradient icrit")
    piping_factor_of_safety: float = Field(..., description="Factor of Safety against piping FS = icrit / i")
    piping_risk_tier: EmbankmentPipingRiskTier = Field(..., description="Piping and sand-boil risk tier")
    sand_boil_detected: bool = Field(..., description="Whether active sand boils or pinhole piping have been reported")


class CwcBenchmarkLevels(BaseModel):
    """CWC official gauge station flood benchmark levels in meters above MSL."""
    zero_flow_datum_m: float = Field(..., description="Gauge datum level (0.00m gauge mark) in m MSL")
    warning_level_m: float = Field(..., description="CWC Official Warning Level in m MSL")
    danger_level_m: float = Field(..., description="CWC Official Danger Level in m MSL")
    highest_flood_level_hfl_m: float = Field(..., description="Historic Highest Flood Level (HFL) in m MSL")
    hfl_record_year: int = Field(..., description="Year of recorded Highest Flood Level")
    embankment_crest_m: float = Field(..., description="Top of levee / flood wall crest in m MSL")


class GumbelFrequencyAnalysis(BaseModel):
    """Gumbel EV1 flood frequency distribution and recurrence thresholds."""
    discharge_10yr_cumecs: float = Field(..., description="10-year return period flood discharge Q10 (cumecs)")
    discharge_25yr_cumecs: float = Field(..., description="25-year return period flood discharge Q25 (cumecs)")
    discharge_50yr_cumecs: float = Field(..., description="50-year return period flood discharge Q50 (cumecs)")
    discharge_100yr_cumecs: float = Field(..., description="100-year return period flood discharge Q100 (cumecs)")
    current_return_period: GumbelFloodReturnPeriod = Field(..., description="Estimated recurrence category of current flow")
    annual_exceedance_probability_pct: float = Field(..., description="Annual probability of exceeding current peak flow (%)")


class RiparianDefenseDirectives(BaseModel):
    """CWC & NDMA operational riparian flood protection and evacuation directives."""
    flood_warning_color: str = Field(..., description="Hex color code for active CWC flood warning stage")
    evacuation_urgency_level: str = Field(..., description="NDMA evacuation advisory urgency (e.g. Immediate, Advisory, Standby)")
    embankment_patrol_frequency: str = Field(..., description="Recommended levee inspection patrol frequency")
    piping_countermeasure_directive: str = Field(..., description="Emergency action for sand boil / backward erosion remediation")
    riparian_safety_protocol: str = Field(..., description="Riparian zone population protection directive")
    drinking_water_sanitation_advisory: str = Field(..., description="Water disinfection and sanitation protocol")


class RiverBasinHydroStation(BaseModel):
    """Telemetry, rating curve, and embankment stability for a specific river basin station."""
    station_id: str = Field(..., description="Unique slug for river gauge station (e.g. 'kosi_baltara')")
    station_name: str = Field(..., description="Display name of CWC gauge site (e.g. 'Baltara Gauge Station')")
    river_name: str = Field(..., description="River name (e.g. 'Kosi River')")
    state_name: str = Field(..., description="Indian State (e.g. 'Bihar')")
    latitude: float = Field(..., description="Latitude coordinate")
    longitude: float = Field(..., description="Longitude coordinate")
    cwc_division: str = Field(..., description="CWC Regional Office / Hydrological Division")
    flood_stage_tier: CwcFloodStageTier = Field(..., description="Active CWC flood stage classification")
    benchmarks: CwcBenchmarkLevels = Field(..., description="CWC benchmark elevation thresholds")
    rating_curve: HydrologicalRatingCurveTelemetry = Field(..., description="Rating curve telemetry and flow hydraulics")
    embankment_safety: EmbankmentStructuralSafetyMetrics = Field(..., description="Embankment structural integrity metrics")
    gumbel_frequency: GumbelFrequencyAnalysis = Field(..., description="Gumbel flood frequency recurrence estimates")
    directives: RiparianDefenseDirectives = Field(..., description="NDMA & CWC flood mitigation directives")


class BasinSummary(BaseModel):
    """Concise summary of monitored river basin gauge station."""
    station_id: str
    station_name: str
    river_name: str
    state_name: str
    stage_height_m: float
    danger_level_m: float
    flood_stage_tier: CwcFloodStageTier
    freeboard_margin_m: float
    piping_risk_tier: EmbankmentPipingRiskTier


class HydroRatingResponse(BaseModel):
    """Root API response payload for CWC Flood Forecasting & Hydrological Rating Curves."""
    timestamp: str = Field(..., description="ISO-8601 UTC timestamp of hydrological telemetry generation")
    active_station: RiverBasinHydroStation = Field(..., description="Detailed telemetry for active gauge station")
    all_stations: List[BasinSummary] = Field(..., description="Summaries of all 7 monitored national river basins")
    vernacular_bulletins: Dict[str, str] = Field(
        ..., description="7-Language riparian emergency bulletins (EN, HI, AS, BN, OD, TE, GU)"
    )
    dataSource: str = Field(
        default="Central Water Commission (CWC Flood Forecast Network) & IMD Hydromet Division",
        description="Official institutional provenance"
    )
