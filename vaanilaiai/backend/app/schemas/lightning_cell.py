"""Pydantic models and schemas for IITM & IMD Lightning Flash Density,
Total Lightning (IC vs CG), Thunderstorm Cell Lifecycle & Severe Downburst Nowcasting Engine.
"""
from enum import Enum
from typing import Dict, List, Optional
from pydantic import BaseModel, Field


class LightningThreatTier(str, Enum):
    EXTREME = "EXTREME"
    SEVERE = "SEVERE"
    ELEVATED = "ELEVATED"
    MODERATE = "MODERATE"
    LOW = "LOW"


class CellLifecycleStage(str, Enum):
    DEVELOPING_CUMULUS = "DEVELOPING_CUMULUS"
    MATURE_SUPERCELL = "MATURE_SUPERCELL"
    DISSIPATING_COLD_POOL = "DISSIPATING_COLD_POOL"


class HydrometeorType(str, Enum):
    GRAUPEL_HAIL_CORE = "GRAUPEL_HAIL_CORE"
    RAIN_HAIL_MIXTURE = "RAIN_HAIL_MIXTURE"
    HEAVY_RAIN = "HEAVY_RAIN"
    ICE_CRYSTALS_SNOW = "ICE_CRYSTALS_SNOW"
    BIOLOGICAL_CLEAR_AIR = "BIOLOGICAL_CLEAR_AIR"


class TotalLightningTelemetry(BaseModel):
    """Real-time total lightning rate, partitioning, and polarity statistics."""
    total_flash_rate_per_min: float = Field(..., description="Total lightning flash rate (IC + CG) in flashes/min")
    intra_cloud_rate_per_min: float = Field(..., description="Intra-cloud (IC) flash rate in flashes/min")
    cloud_to_ground_rate_per_min: float = Field(..., description="Cloud-to-ground (CG) flash rate in flashes/min")
    ic_cg_ratio: float = Field(..., description="Ratio of IC to CG flashes (typically 3:1 to 10:1 during maturation)")
    positive_cg_percentage: float = Field(..., description="Percentage of CG strokes that are positive (+CG)")
    peak_stroke_current_ka: float = Field(..., description="Peak stroke current in kiloamperes (kA)")
    continuing_current_duration_ms: float = Field(..., description="Duration of continuing current in milliseconds")
    is_positive_cg_hazard: bool = Field(..., description="Flag indicating high-energy +CG strokes with extreme fire/fatality hazard")


class LightningJumpMetrics(BaseModel):
    """Gatlin-Goodman Lightning Jump Algorithm (LJA) metrics for severe nowcasting."""
    delta_flash_rate_per_min_sq: float = Field(..., description="Time derivative of total flash rate (flashes/min/min)")
    jump_detected: bool = Field(..., description="True if delta_flash_rate exceeds 10-15 flashes/min/min threshold")
    jump_severity: str = Field(..., description="Severity tier: CRITICAL, STRONG, MODERATE, or NONE")
    lead_time_minutes: int = Field(..., description="Advance nowcast lead time for ground hazards (15-30 mins)")
    severe_weather_probability_pct: float = Field(..., description="Probability of severe downburst or large hail at surface")


class DownburstMicroburstRisk(BaseModel):
    """Downdraft CAPE (DCAPE) and wet microburst wind velocity estimation."""
    dcape_j_kg: float = Field(..., description="Downdraft Convective Available Potential Energy in J/kg")
    estimated_gust_speed_kmh: float = Field(..., description="Estimated peak outflow gust velocity via V_burst = 2.4 * sqrt(DCAPE)")
    microburst_category: str = Field(..., description="Microburst category: SEVERE_WET_MICROBURST, MODERATE_DOWNBURST, or LIGHT_OUTFLOW")
    damage_potential: str = Field(..., description="Potential damage description (roof de-sheeting, tree snapping, power lines)")


class DopplerDualPolRadarEcho(BaseModel):
    """IMD Doppler Weather Radar (DWR) dual-polarization hydrometeor classification."""
    radar_station: str = Field(..., description="Reporting IMD Doppler Radar Station")
    reflectivity_zhh_dbz: float = Field(..., description="Horizontal reflectivity (Z_HH in dBZ)")
    differential_reflectivity_zdr_db: float = Field(..., description="Differential reflectivity (Z_DR in dB)")
    correlation_coeff_rho_hv: float = Field(..., description="Copolar correlation coefficient (rho_HV)")
    hydrometeor_classification: HydrometeorType = Field(..., description="Dual-pol classified hydrometeor aloft")
    hail_core_aloft_detected: bool = Field(..., description="True if graupel/hail core is detected in mixed-phase zone")


class ClimatologicalFlashDensity(BaseModel):
    """IITM Annual Climatological Lightning Flash Density and risk ranking."""
    district_name: str = Field(..., description="District name")
    state_name: str = Field(..., description="State name")
    annual_flash_density_per_sq_km: float = Field(..., description="Annual lightning flash density in flashes/km^2/year")
    national_hazard_percentile: float = Field(..., description="National percentile rank (0-100%)")
    climatological_tier: str = Field(..., description="EXTREME_CORRIDOR, HIGH_CORRIDOR, or MODERATE_CORRIDOR")
    five_year_trend: str = Field(..., description="Multi-year climatological trend in flash frequency")


class LightningHotspotCorridor(BaseModel):
    """High-risk Indian lightning hotspot corridor metadata."""
    id: str = Field(..., description="Corridor unique identifier")
    name: str = Field(..., description="Corridor common name")
    state: str = Field(..., description="State / Region")
    latitude: float = Field(..., description="Representative latitude")
    longitude: float = Field(..., description="Representative longitude")
    primary_driver: str = Field(..., description="Primary meteorological/orographic convective trigger")
    nearest_dwr_station: str = Field(..., description="Nearest IMD Doppler Weather Radar station")


class LightningSafetyGuidelines(BaseModel):
    """NDMA Lightning Safety Action Plan directives and life-safety guidelines."""
    anti_tree_warning: str = Field(..., description="Crucial warning against seeking shelter under trees (71% fatality factor)")
    lightning_crouch_posture: str = Field(..., description="Correct emergency open-field crouching technique")
    metal_implement_prohibition: str = Field(..., description="Guidance on dropping iron sickles, pipes, tractors, and wires")
    indoor_pucca_shelter_guidance: str = Field(..., description="Indoor shelter safety rules (plumbing, wiring, windows)")
    cpr_resuscitation_guideline: str = Field(..., description="Immediate CPR and first-aid instructions for strike victims")


class LightningCellResponse(BaseModel):
    """Complete response payload for IITM-IMD Lightning Flash Density & Cell Lifecycle Engine."""
    corridor: LightningHotspotCorridor = Field(..., description="Active or nearest lightning hotspot corridor")
    threat_tier: LightningThreatTier = Field(..., description="Overall lightning and downburst threat tier")
    cell_stage: CellLifecycleStage = Field(..., description="Thunderstorm cell convective lifecycle stage")
    nearest_cell_distance_km: float = Field(..., description="Distance to nearest active convective cell in km")
    cell_movement_heading_deg: float = Field(..., description="Cell movement vector heading azimuth in degrees")
    cell_speed_kmh: float = Field(..., description="Cell translation speed across ground in km/h")
    total_lightning: TotalLightningTelemetry = Field(..., description="Total lightning rate and partitioning")
    lightning_jump: LightningJumpMetrics = Field(..., description="Gatlin-Goodman Lightning Jump metrics")
    downburst_risk: DownburstMicroburstRisk = Field(..., description="DCAPE downburst wind risk assessment")
    radar_echo: DopplerDualPolRadarEcho = Field(..., description="Doppler dual-pol radar echo telemetry")
    climatology: ClimatologicalFlashDensity = Field(..., description="Climatological annual flash density")
    ndma_guidelines: LightningSafetyGuidelines = Field(..., description="NDMA agricultural field safety directives")
    vernacular_bulletins: Dict[str, str] = Field(..., description="Regional language safety alerts (en, hi, od, bn, te, mr, as)")
    timestamp: str = Field(..., description="Observation and analysis timestamp in ISO-8601 UTC")
    is_offline_fallback: bool = Field(False, description="Flag indicating offline synthetic baseline response")
