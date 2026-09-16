from enum import Enum
from typing import List, Dict, Optional
from pydantic import BaseModel, Field


class PasquillStabilityClass(str, Enum):
    CLASS_A_EXTREMELY_UNSTABLE = "CLASS_A_EXTREMELY_UNSTABLE"
    CLASS_B_MODERATELY_UNSTABLE = "CLASS_B_MODERATELY_UNSTABLE"
    CLASS_C_SLIGHTLY_UNSTABLE = "CLASS_C_SLIGHTLY_UNSTABLE"
    CLASS_D_NEUTRAL = "CLASS_D_NEUTRAL"
    CLASS_E_SLIGHTLY_STABLE = "CLASS_E_SLIGHTLY_STABLE"
    CLASS_F_MODERATELY_STABLE = "CLASS_F_MODERATELY_STABLE"


class ToxicGasSpecies(str, Enum):
    CHLORINE_CL2 = "CHLORINE_CL2"
    AMMONIA_NH3 = "AMMONIA_NH3"
    SULFUR_DIOXIDE_SO2 = "SULFUR_DIOXIDE_SO2"
    HYDROGEN_SULFIDE_H2S = "HYDROGEN_SULFIDE_H2S"
    BENZENE_C6H6 = "BENZENE_C6H6"
    PHOSGENE_COCL2 = "PHOSGENE_COCL2"


class HazmatReleaseSeverity(str, Enum):
    MINOR_FUGITIVE_EMISSION = "MINOR_FUGITIVE_EMISSION"
    CONTROLLED_FLARING = "CONTROLLED_FLARING"
    SIGNIFICANT_TANK_LEAK = "SIGNIFICANT_TANK_LEAK"
    CATASTROPHIC_VESSEL_RUPTURE = "CATASTROPHIC_VESSEL_RUPTURE"


class AtmosphericDispersionTelemetry(BaseModel):
    wind_speed_m_s: float = Field(..., description="10m surface wind speed in m/s")
    wind_direction_degrees: float = Field(..., description="Wind azimuth in degrees")
    wind_direction_cardinal: str = Field(..., description="Cardinal wind direction (e.g. WSW, NE)")
    pasquill_stability_class: PasquillStabilityClass = Field(..., description="Pasquill-Gifford atmospheric stability class")
    mixing_height_m: float = Field(..., description="Planetary boundary layer mixing depth in meters")
    ambient_temp_c: float = Field(..., description="Ambient air temperature in Celsius")
    relative_humidity_pct: float = Field(..., description="Ambient relative humidity percentage")
    solar_radiation_w_m2: float = Field(..., description="Solar irradiance insolation flux in W/m2")
    inversion_layer_present: bool = Field(..., description="Presence of nocturnal thermal radiation inversion cap")


class GasToxicityProfile(BaseModel):
    species: ToxicGasSpecies = Field(..., description="Chemical gas identifier")
    common_name: str = Field(..., description="Common chemical name")
    chemical_formula: str = Field(..., description="Chemical molecular formula")
    cas_number: str = Field(..., description="Chemical Abstracts Service (CAS) registry number")
    molecular_weight_g_mol: float = Field(..., description="Molecular weight in g/mol")
    vapor_density_air_ratio: float = Field(..., description="Vapor density relative to air (Air=1.0; >1 settles, <1 rises)")
    odor_threshold_ppm: float = Field(..., description="Olfactory perception threshold in ppm")
    aegl_1_ppm: float = Field(..., description="EPA AEGL-1 60-min threshold in ppm (noticeable irritation)")
    aegl_2_ppm: float = Field(..., description="EPA AEGL-2 60-min threshold in ppm (irreversible/serious health effects)")
    aegl_3_ppm: float = Field(..., description="EPA AEGL-3 60-min threshold in ppm (life-threatening health effects)")
    idlh_ppm: float = Field(..., description="NIOSH Immediately Dangerous to Life or Health in ppm")


class PlumeDispersionMetrics(BaseModel):
    release_rate_kg_s: float = Field(..., description="Continuous source gas mass release rate in kg/s")
    release_height_m: float = Field(..., description="Physical emission release stack/valve height in meters")
    centerline_peak_concentration_ppm: float = Field(..., description="Estimated ground-level peak plume concentration in ppm")
    protective_action_distance_km: float = Field(..., description="Downwind Protective Action Distance (PAD) to AEGL-2 boundary in km")
    initial_isolation_zone_m: float = Field(..., description="Immediate Initial Isolation Zone (IIZ) evacuation radius in meters")
    plume_width_1km_m: float = Field(..., description="Horizontal crosswind Gaussian plume width at 1 km downwind in meters")
    transit_time_buffer_min: float = Field(..., description="Plume advective arrival transit time to nearest sensitive boundary in minutes")
    severity_tier: HazmatReleaseSeverity = Field(..., description="CPCB/NDMA Chemical Release Hazard Severity Tier")


class EmergencyResponseProtocol(BaseModel):
    crosswind_escape_direction: str = Field(..., description="Crosswind escape trajectory instruction relative to wind vector")
    shelter_in_place_directives: str = Field(..., description="Shelter-in-place seal steps and air intake shutdown protocol")
    recommended_ppe: str = Field(..., description="Personal protective equipment specification for emergency responders")
    medical_countermeasures: str = Field(..., description="Clinical triage and antidote protocol")
    water_spray_curtain_recommended: bool = Field(..., description="Whether a water fog curtain / deluge spray can absorb or knockdown the plume")


class IndustrialChemicalCluster(BaseModel):
    cluster_id: str = Field(..., description="Unique slug for the industrial chemical cluster")
    cluster_name: str = Field(..., description="Public title of the industrial chemical estate")
    state: str = Field(..., description="State jurisdiction")
    district: str = Field(..., description="District jurisdiction")
    latitude: float = Field(..., description="Latitude coordinate")
    longitude: float = Field(..., description="Longitude coordinate")
    major_industrial_sectors: List[str] = Field(..., description="Major chemical and petrochemical sectors operating in the cluster")
    active_gas_profile: GasToxicityProfile = Field(..., description="Monitored chemical gas profile")
    atmospheric_telemetry: AtmosphericDispersionTelemetry = Field(..., description="Localized micrometeorological dispersion conditions")
    dispersion_metrics: PlumeDispersionMetrics = Field(..., description="Gaussian plume dispersion footprint")
    emergency_protocol: EmergencyResponseProtocol = Field(..., description="CPCB/NDMA life-saving action protocol")
    sensitive_downwind_receptors: List[str] = Field(..., description="Key vulnerable downstream communities or infrastructure")
    localized_bulletins: Dict[str, str] = Field(..., description="Multilingual emergency directives (EN, HI, TA, GU, TE)")


class HazmatDispersionResponse(BaseModel):
    timestamp: str = Field(..., description="ISO 8601 generation timestamp")
    bulletin_number: str = Field(..., description="Official IMD-CPCB chemical nowcast bulletin identifier")
    provenance: str = Field(..., description="Regulatory provenance standard (CPCB / IMD / NDMA)")
    selected_cluster: IndustrialChemicalCluster = Field(..., description="Evaluated chemical corridor")
    all_clusters: List[IndustrialChemicalCluster] = Field(..., description="Catalog of all monitored chemical PCPIR corridors")
    vernacular_bulletins: Dict[str, str] = Field(..., description="Vernacular bulletins in EN, HI, TA, GU, TE")
    is_offline_cached: bool = Field(default=False, description="Whether response originated from client offline cache")
