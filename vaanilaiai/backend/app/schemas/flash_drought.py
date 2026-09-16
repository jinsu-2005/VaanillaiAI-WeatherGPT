"""Pydantic schemas for IMD & CWC Flash Drought, Rapid Soil Desiccation
& Atmospheric Evaporative Demand Engine (FLASH-DROUGHT).
"""

from enum import Enum
from typing import Dict, List, Optional
from pydantic import BaseModel, Field


class FlashDroughtIntensityTier(str, Enum):
    """Flash drought rapid onset and intensification severity tier."""
    EXTREME_FLASH_DROUGHT = "EXTREME_FLASH_DROUGHT"       # Drop > 30 percentiles in 2 weeks
    SEVERE_FLASH_DROUGHT = "SEVERE_FLASH_DROUGHT"         # Drop 20-30 percentiles in 2 weeks
    MODERATE_FLASH_DROUGHT = "MODERATE_FLASH_DROUGHT"     # Drop 10-20 percentiles in 2 weeks
    FLASH_DROUGHT_WATCH = "FLASH_DROUGHT_WATCH"           # Rapid dry-down detected (<10 percentiles)
    NORMAL_MOISTURE_REGIME = "NORMAL_MOISTURE_REGIME"     # Stable soil moisture replenishment


class AtmosphericEvaporativeDemandTier(str, Enum):
    """Evaporative Demand Drought Index (EDDI) atmospheric thirst tier."""
    EXTREME_EVAPORATIVE_DEMAND = "EXTREME_EVAPORATIVE_DEMAND"   # EDDI >= +2.0 (ED4)
    SEVERE_EVAPORATIVE_DEMAND = "SEVERE_EVAPORATIVE_DEMAND"     # +1.5 <= EDDI < +2.0 (ED3)
    MODERATE_EVAPORATIVE_DEMAND = "MODERATE_EVAPORATIVE_DEMAND" # +1.0 <= EDDI < +1.5 (ED2)
    ABNORMAL_EVAPORATIVE_DEMAND = "ABNORMAL_EVAPORATIVE_DEMAND" # +0.5 <= EDDI < +1.0 (ED1)
    NORMAL_EVAPORATIVE_DEMAND = "NORMAL_EVAPORATIVE_DEMAND"     # EDDI < +0.5 (ED0)


class SoilDesiccationVelocity(str, Enum):
    """Rate of root-zone soil moisture depletion per week."""
    CRITICAL_EXPLOSIVE = "CRITICAL_EXPLOSIVE"   # > 8.0 percentiles/week or > 2.5% VWC/day
    ACCELERATED_HIGH = "ACCELERATED_HIGH"       # 5.0 - 8.0 percentiles/week
    MODERATE_STEADY = "MODERATE_STEADY"         # 2.5 - 5.0 percentiles/week
    NORMAL_DRAINAGE = "NORMAL_DRAINAGE"         # < 2.5 percentiles/week


class CropPhenologyVulnerability(str, Enum):
    """Vulnerability rating based on active crop reproductive/vegetative stage."""
    CRITICAL_REPRODUCTIVE_SUSCEPTIBILITY = "CRITICAL_REPRODUCTIVE_SUSCEPTIBILITY" # Flowering / Pegging / Silking
    HIGH_VEGETATIVE_STRESS = "HIGH_VEGETATIVE_STRESS"                             # Rapid elongation / Square formation
    MODERATE_ESTABLISHMENT_RISK = "MODERATE_ESTABLISHMENT_RISK"                 # Early seedling / Germination
    LOW_MATURITY_RESILIENCE = "LOW_MATURITY_RESILIENCE"                           # Physiological maturity


class AtmosphericEvaporativeDemandTelemetry(BaseModel):
    """Penman-Monteith atmospheric evaporative demand and vapor pressure deficit."""
    reference_evapotranspiration_e0_mm_day: float = Field(
        ..., description="FAO-56 Penman-Monteith daily atmospheric evaporative demand (E0 in mm/day)"
    )
    eddi_2week: float = Field(
        ..., description="2-Week Evaporative Demand Drought Index (standardized z-score anomaly)"
    )
    eddi_4week: float = Field(
        ..., description="4-Week Evaporative Demand Drought Index (standardized z-score anomaly)"
    )
    evaporative_demand_tier: AtmosphericEvaporativeDemandTier = Field(
        ..., description="Standardized atmospheric evaporative demand classification"
    )
    vapor_pressure_deficit_kpa: float = Field(
        ..., description="Atmospheric Vapor Pressure Deficit (VPD = es - ea) in kPa"
    )
    air_temperature_max_c: float = Field(
        ..., description="Maximum daytime air temperature at 2m height in deg C"
    )
    temp_max_departure_c: float = Field(
        ..., description="Maximum temperature departure above normal climatology in deg C"
    )
    solar_radiation_mj_m2_day: float = Field(
        ..., description="Incident solar net surface radiation in MJ / (m^2 * day)"
    )
    wind_speed_2m_ms: float = Field(
        ..., description="Surface wind speed at 2m height in m/s"
    )


class SoilMoistureDesiccationMetrics(BaseModel):
    """2-depth volumetric soil moisture and rapid dry-down telemetry."""
    topsoil_moisture_0_10cm_pct: float = Field(
        ..., description="Current topsoil volumetric water content (0-10 cm) in % VWC"
    )
    rootzone_moisture_10_40cm_pct: float = Field(
        ..., description="Current root-zone volumetric water content (10-40 cm) in % VWC"
    )
    rootzone_percentile: float = Field(
        ..., description="Current root-zone soil moisture percentile relative to 30-year climatology (0-100)"
    )
    percentile_drop_14days: float = Field(
        ..., description="Total drop in soil moisture percentile over the preceding 14 days"
    )
    desiccation_rate_pct_per_day: float = Field(
        ..., description="Daily soil moisture depletion velocity in % VWC drop per day"
    )
    desiccation_velocity: SoilDesiccationVelocity = Field(
        ..., description="Categorical rating of soil moisture loss velocity"
    )
    evaporative_stress_index_esi: float = Field(
        ..., description="Evaporative Stress Index (ESI = ET / PET) ratio (0.00 to 1.00)"
    )
    consecutive_rainless_days: int = Field(
        ..., description="Consecutive rainless days (< 2.5 mm rainfall) during current dry spell"
    )


class CropPhenologyVulnerabilityIndex(BaseModel):
    """Crop stage sensitivity and yield penalty assessment."""
    primary_crop: str = Field(..., description="Dominant regional crop (e.g. Soybean, Cotton, Groundnut)")
    current_growth_stage: str = Field(
        ..., description="Current phenological stage (e.g. R1-R2 Early Flowering, Pegging)"
    )
    vulnerability_tier: CropPhenologyVulnerability = Field(
        ..., description="Vulnerability level based on moisture sensitivity"
    )
    yield_loss_risk_pct: float = Field(
        ..., description="Projected yield reduction percentage if flash drought continues unmitigated"
    )
    damage_multiplier: float = Field(
        ..., description="Biophysical sensitivity weight for the current phenological phase (1.0 - 2.5x)"
    )
    transpirational_stress_label: str = Field(
        ..., description="Stomatal closure and canopy wilt state descriptor"
    )


class FlashDroughtDirectives(BaseModel):
    """Emergency agronomic rescue and water conservation directives."""
    anti_transpirant_spray_recommendation: str = Field(
        ..., description="Foliar anti-transpirant / chemical rescue formulation (e.g. 1% KNO3, Kaolin)"
    )
    mulching_directive: str = Field(
        ..., description="Residue or dust mulching protocol to break capillary soil pore evaporation"
    )
    micro_irrigation_pulse_schedule: str = Field(
        ..., description="Deficit pulse drip/sprinkler window to minimize midday evaporative loss"
    )
    salvage_action: str = Field(
        ..., description="Inter-row thinning, intercropping, or emergency fodder harvest contingency"
    )
    actionable_bullet_points: List[str] = Field(
        ..., description="Actionable directives for farmers, extension officers, and irrigation engineers"
    )


class FlashDroughtHotspot(BaseModel):
    """Geographic, edaphic, and agronomic profile of a vulnerable flash drought zone."""
    hotspot_id: str = Field(..., description="Unique hotspot identifier (e.g. VIDARBHA_HOTSPOT)")
    name: str = Field(..., description="Common geographic name of the hotspot region")
    districts: List[str] = Field(..., description="Key administrative districts encompassed")
    state: str = Field(..., description="State location")
    latitude: float = Field(..., description="Center latitude coordinate")
    longitude: float = Field(..., description="Center longitude coordinate")
    soil_type: str = Field(..., description="Dominant soil classification (e.g. Deep Black Vertisols, Red Sandy Loam)")
    primary_kharif_crops: List[str] = Field(..., description="Major rainfed Kharif crops cultivated")
    irrigation_coverage_pct: float = Field(..., description="Percentage of net sown area with assured irrigation")


class HotspotSummary(BaseModel):
    """Concise status summary for regional flash drought network monitoring."""
    hotspot_id: str = Field(..., description="Hotspot identifier")
    name: str = Field(..., description="Region name")
    state: str = Field(..., description="State")
    intensity_tier: FlashDroughtIntensityTier = Field(..., description="Current flash drought severity")
    eddi_2week: float = Field(..., description="2-Week EDDI index value")
    rootzone_percentile: float = Field(..., description="Root-zone moisture percentile")
    primary_crop: str = Field(..., description="Main crop assessed")


class FlashDroughtResponse(BaseModel):
    """Comprehensive API response for IMD & CWC Flash Drought & Rapid Soil Desiccation Engine."""
    hotspot: FlashDroughtHotspot = Field(..., description="Target hotspot geographic and soil profile")
    assessment_timestamp: str = Field(..., description="ISO 8601 timestamp of flash drought assessment")
    overall_intensity_tier: FlashDroughtIntensityTier = Field(
        ..., description="Aggregate flash drought onset and intensification severity"
    )
    rapid_intensification_detected: bool = Field(
        ..., description="Flag indicating rapid intensification criteria met (drop >= 2 tiers in <= 20 days)"
    )
    atmospheric_demand: AtmosphericEvaporativeDemandTelemetry = Field(
        ..., description="Atmospheric evaporative thirst, Penman-Monteith E0, and EDDI metrics"
    )
    soil_desiccation: SoilMoistureDesiccationMetrics = Field(
        ..., description="2-depth soil volumetric water content, depletion velocity, and ESI ratio"
    )
    crop_vulnerability: CropPhenologyVulnerabilityIndex = Field(
        ..., description="Phenological growth stage vulnerability and yield impact assessment"
    )
    directives: FlashDroughtDirectives = Field(
        ..., description="Actionable ICAR-CRIDA agronomic mitigation and pulse irrigation protocols"
    )
    monitored_hotspots: List[HotspotSummary] = Field(
        ..., description="Network summary of key vulnerable rainfed agricultural hotspots across India"
    )
    vernacular_bulletins: Dict[str, str] = Field(
        ..., description="7-language localized advisories (en, hi, mr, te, kn, gu, bn)"
    )
    metadata: Dict[str, str] = Field(
        ..., description="Institutional provenance, formulations, and citation metadata"
    )
