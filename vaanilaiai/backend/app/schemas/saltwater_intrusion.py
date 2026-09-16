"""Pydantic schemas for IMD, INCOIS & CGWB Coastal Estuarine Saltwater Intrusion,
Tidal Prism & Groundwater Salinization Engine (SALTWATER-TIDE).
"""

from enum import Enum
from typing import Dict, List, Optional
from pydantic import BaseModel, Field


class SalinitySeverityTier(str, Enum):
    """Water mineralization and salinity stress classification."""
    NORMAL_FRESHWATER = "NORMAL_FRESHWATER"               # EC < 750 uS/cm, Salinity < 0.5 ppt
    SLIGHT_SALINE_STRESS = "SLIGHT_SALINE_STRESS"         # 750 <= EC < 1500 uS/cm, Salinity 0.5-1.0 ppt
    MODERATE_BRACKISH_INGRESS = "MODERATE_BRACKISH_INGRESS" # 1500 <= EC < 3000 uS/cm, Salinity 1.0-2.5 ppt
    SEVERE_SALINE_CONTAMINATION = "SEVERE_SALINE_CONTAMINATION" # 3000 <= EC < 6000 uS/cm, Salinity 2.5-5.0 ppt
    HYPERSALINE_SEAWATER_INCURSION = "HYPERSALINE_SEAWATER_INCURSION" # EC >= 6000 uS/cm, Salinity >= 5.0 ppt


class TidalPrismPhase(str, Enum):
    """Astronomical spring/neap tidal cycle phase."""
    SPRING_HIGH_TIDE = "SPRING_HIGH_TIDE"     # Maximum tidal range, peak inland push
    SPRING_EBB_TIDE = "SPRING_EBB_TIDE"       # Rapid flushing, seaward retreat
    NEAP_HIGH_TIDE = "NEAP_HIGH_TIDE"         # Moderate tidal range
    NEAP_LOW_TIDE = "NEAP_LOW_TIDE"           # Minimum tidal dispersion


class AquiferVulnerabilityTier(str, Enum):
    """Ghyben-Herzberg coastal aquifer freshwater lens stability."""
    SAFE_CONFINED_LENS = "SAFE_CONFINED_LENS"           # hf >= +1.5m, z >= 60m
    VULNERABLE_THINNING = "VULNERABLE_THINNING"         # +0.75m <= hf < +1.5m, z = 30-60m
    ACTIVE_SALINE_UPCONING = "ACTIVE_SALINE_UPCONING"   # 0.0m <= hf < +0.75m, z = 0-30m
    CRITICAL_AQUIFER_CONTAMINATION = "CRITICAL_AQUIFER_CONTAMINATION" # hf < 0.0m (Head below sea level)


class EstuarineSalineWedgeTelemetry(BaseModel):
    """Two-layer estuarine saline wedge hydrodynamics and tidal prism metrics."""
    estuary_name: str = Field(..., description="Name of tidal river estuary or lagoon")
    river_mouth_distance_km: float = Field(..., description="Monitoring station distance from open sea (km)")
    saline_wedge_length_km: float = Field(..., description="Current inland penetration distance of saline wedge (km)")
    upstream_freshwater_discharge_cumecs: float = Field(
        ..., description="Upstream freshwater river discharge Qfresh (m3/s)"
    )
    estuary_channel_depth_m: float = Field(..., description="Mean estuarine water depth H0 (meters)")
    densimetric_froude_number: float = Field(..., description="Densimetric Froude number F0")
    surface_salinity_ppt: float = Field(..., description="Surface water salinity in parts per thousand (ppt or PSU)")
    bottom_bed_salinity_ppt: float = Field(..., description="Dense bottom wedge bed salinity in ppt")
    astronomical_tidal_range_m: float = Field(..., description="Peak-to-trough tidal elevation amplitude (meters)")
    tidal_prism_phase: TidalPrismPhase = Field(..., description="Active astronomical tidal phase")
    tidal_prism_volume_million_m3: float = Field(..., description="Estuarine tidal prism exchange volume (10^6 m3)")


class GhybenHerzbergAquiferMetrics(BaseModel):
    """Ghyben-Herzberg coastal aquifer hydrostatic freshwater lens and mineralization."""
    freshwater_piezometric_head_m_msl: float = Field(
        ..., description="Freshwater water table head above Mean Sea Level hf (m MSL)"
    )
    theoretical_freshwater_lens_depth_m: float = Field(
        ..., description="Ghyben-Herzberg calculated lens depth z = 40 * hf (meters below MSL)"
    )
    measured_saline_interface_depth_m: float = Field(
        ..., description="Geophysically logged saline water interface depth (meters below ground level)"
    )
    saline_upconing_velocity_cm_week: float = Field(
        ..., description="Vertical upward migration rate of saline interface (cm/week)"
    )
    aquifer_vulnerability_tier: AquiferVulnerabilityTier = Field(
        ..., description="Aquifer freshwater lens health classification"
    )
    electrical_conductivity_us_cm: float = Field(
        ..., description="Groundwater Electrical Conductivity (EC in uS/cm at 25 deg C)"
    )
    total_dissolved_solids_mg_l: float = Field(
        ..., description="Total Dissolved Solids (TDS in mg/L or ppm, approx 0.64 * EC)"
    )
    sodium_adsorption_ratio_sar: float = Field(
        ..., description="Sodium Adsorption Ratio (SAR) quantifying sodicity hazard"
    )
    chloride_concentration_mg_l: float = Field(
        ..., description="Chloride (Cl-) ion concentration in mg/L (BIS 10500 limit: 250 mg/L)"
    )


class CoastalAgricultureDirectives(BaseModel):
    """ICAR-CSSRI and CGWB operational coastal farming and groundwater protection directives."""
    sluice_flap_gate_status: str = Field(
        ..., description="Tidal regulator/sluice gate operation state (OPEN / CLOSED / PARTIAL)"
    )
    sluice_closure_timing_notice: str = Field(
        ..., description="Operational timing for sluice gate closure ahead of high spring tide"
    )
    borewell_pumping_limit_hours: float = Field(
        ..., description="Maximum recommended daily groundwater pumping hours to avert upconing"
    )
    recommended_salt_tolerant_crops: List[str] = Field(
        ..., description="ICAR-CSSRI verified halophytic and saline-tolerant crop cultivars"
    )
    gypsum_amendment_dosage_tons_ha: float = Field(
        ..., description="Soil agricultural gypsum (CaSO4.2H2O) dosage in tons/ha to lower SAR"
    )
    potable_ro_membrane_alert: str = Field(
        ..., description="Guidance for coastal RO desalination plants and drinking water intakes"
    )
    irrigation_suitability_advice: str = Field(
        ..., description="Direct agronomic irrigation guidance for local farmers"
    )


class CoastalEstuarineZone(BaseModel):
    """Complete hydro-salinity telemetry for a monitored coastal delta or estuary."""
    zone_id: str = Field(..., description="Unique slug for coastal zone (e.g. 'sundarbans_delta')")
    zone_name: str = Field(..., description="Name of coastal estuarine belt (e.g. 'Sundarbans Estuarine Delta')")
    coastal_district: str = Field(..., description="District name (e.g. 'South 24 Parganas')")
    state_name: str = Field(..., description="Indian Coastal State (e.g. 'West Bengal')")
    latitude: float = Field(..., description="Geographic latitude coordinate")
    longitude: float = Field(..., description="Geographic longitude coordinate")
    coastal_body_type: str = Field(..., description="Body classification (Tidal Delta, Estuary, Lagoon, Backwaters)")
    salinity_severity: SalinitySeverityTier = Field(..., description="Active salinity severity tier")
    estuarine_wedge: EstuarineSalineWedgeTelemetry = Field(..., description="Two-layer estuarine wedge mechanics")
    aquifer_metrics: GhybenHerzbergAquiferMetrics = Field(..., description="Ghyben-Herzberg freshwater lens data")
    directives: CoastalAgricultureDirectives = Field(..., description="ICAR-CSSRI & CGWB mitigation directives")


class CoastalZoneSummary(BaseModel):
    """Concise metadata for coastal zone selector chip."""
    zone_id: str
    zone_name: str
    state_name: str
    saline_wedge_length_km: float
    surface_salinity_ppt: float
    salinity_severity: SalinitySeverityTier
    aquifer_vulnerability_tier: AquiferVulnerabilityTier
    sluice_flap_gate_status: str


class SaltwaterIntrusionResponse(BaseModel):
    """Root API response payload for Coastal Estuarine Saltwater Intrusion & Groundwater Salinization Engine."""
    timestamp: str = Field(..., description="ISO-8601 UTC timestamp of salinity assessment")
    active_zone: CoastalEstuarineZone = Field(..., description="Comprehensive telemetry for active coastal zone")
    all_zones: List[CoastalZoneSummary] = Field(..., description="Summaries of all 7 monitored coastal zones")
    vernacular_bulletins: Dict[str, str] = Field(
        ..., description="7-Language coastal emergency bulletins (EN, HI, BN, TA, TE, ML, GU)"
    )
    dataSource: str = Field(
        default="INCOIS Ocean State Forecast, Central Ground Water Board (CGWB) & ICAR-CSSRI",
        description="Official institutional provenance"
    )
