"""Pydantic schemas for IMD & ICAR Post-Harvest Mandi Weather Defense,
Grain Moisture & Open-Godown Spoilage Engine (AGRI-STORAGE).
"""

from enum import Enum
from typing import Dict, List, Optional
from pydantic import BaseModel, Field


class MandiWeatherRiskTier(str, Enum):
    """Mandi open-yard and godown weather risk assessment tier."""
    CRITICAL_SPOILAGE_RISK = "CRITICAL_SPOILAGE_RISK"
    HIGH_MOISTURE_SURGE = "HIGH_MOISTURE_SURGE"
    MODERATE_WEATHER_ALERT = "MODERATE_WEATHER_ALERT"
    SAFE_STORAGE_OPTIMAL = "SAFE_STORAGE_OPTIMAL"


class GrainMoistureState(str, Enum):
    """Grain hygroscopic equilibrium and moisture content safety state."""
    PERILOUS_FERMENTATION_RISK = "PERILOUS_FERMENTATION_RISK"
    UNSAFE_ELEVATED_MOISTURE = "UNSAFE_ELEVATED_MOISTURE"
    ACCEPTABLE_STABLE = "ACCEPTABLE_STABLE"
    OPTIMAL_SAFE_DRY = "OPTIMAL_SAFE_DRY"


class MycotoxinAflatoxinRisk(str, Enum):
    """Aspergillus flavus/parasiticus proliferation and aflatoxin B1 risk tier."""
    EXTREME_AFLATOXIN_OUTBREAK = "EXTREME_AFLATOXIN_OUTBREAK"
    HIGH_FUNGAL_PROLIFERATION = "HIGH_FUNGAL_PROLIFERATION"
    MODERATE_MONITORING_REQUIRED = "MODERATE_MONITORING_REQUIRED"
    MINIMAL_MYCOTOXIN_RISK = "MINIMAL_MYCOTOXIN_RISK"


class TarpaulinAlertStatus(str, Enum):
    """Protective HDPE tarpaulin (tirpal) deployment status for open yards."""
    IMMEDIATE_TIRPAL_DEPLOYMENT = "IMMEDIATE_TIRPAL_DEPLOYMENT"
    HIGH_PRIORITY_PREPOSITIONING = "HIGH_PRIORITY_PREPOSITIONING"
    STANDBY_MONITORING = "STANDBY_MONITORING"
    NO_DEPLOYMENT_NEEDED = "NO_DEPLOYMENT_NEEDED"


class CropHygroscopicMetrics(BaseModel):
    """Hygroscopic equilibrium and moisture metrics for a stored crop."""
    crop_name: str = Field(..., description="Agricultural commodity name (e.g. Wheat, Paddy, Soybean)")
    current_moisture_content_pct: float = Field(
        ..., description="Current grain moisture content in percentage wet basis (% w.b.)"
    )
    equilibrium_moisture_content_pct: float = Field(
        ..., description="Equilibrium Moisture Content (EMC) calculated via Henderson-Thompson equation"
    )
    safe_storage_limit_pct: float = Field(
        ..., description="Maximum recommended moisture percentage for safe prolonged storage"
    )
    moisture_surplus_deficit_pct: float = Field(
        ..., description="Difference between current moisture and safe threshold (positive = surplus/unsafe)"
    )
    moisture_state: GrainMoistureState = Field(
        ..., description="Moisture classification state based on safe storage limits"
    )
    henderson_thompson_k: float = Field(..., description="Henderson-Thompson empirical constant K")
    henderson_thompson_c: float = Field(..., description="Henderson-Thompson temperature constant C")
    henderson_thompson_n: float = Field(..., description="Henderson-Thompson empirical exponent N")


class OpenMandiYardTelemetry(BaseModel):
    """Open plinth, drying floor, and auction yard physical weather telemetry."""
    yard_type_label: str = Field(
        ..., description="Yard enclosure category (e.g. Covered Auction Shed, Open Plinth / CAP, Concrete Drying Yard)"
    )
    surface_inundation_risk_pct: float = Field(
        ..., description="Probability of yard surface waterlogging / plinth submergence (0 - 100%)"
    )
    forecast_rain_24h_mm: float = Field(
        ..., description="Forecasted 24-hour cumulative precipitation in mm"
    )
    forecast_hail_probability_pct: float = Field(
        ..., description="Forecasted probability of hailstorm impact on open yards (0 - 100%)"
    )
    wind_gust_kmh: float = Field(
        ..., description="Forecasted peak wind gusts capable of dislodging tarpaulin covers in km/h"
    )
    dunnage_pallet_elevation_cm: float = Field(
        ..., description="Current stack elevation above floor via wooden dunnage crates in cm"
    )
    waterlogging_clearance_hours: float = Field(
        ..., description="Estimated hours required for yard drainage system to clear standing water"
    )


class FungalMycotoxinTelemetry(BaseModel):
    """Bio-hazard telemetry for fungal mold proliferation and aflatoxin synthesis."""
    aflatoxin_b1_risk_level: MycotoxinAflatoxinRisk = Field(
        ..., description="Aflatoxin B1 fungal proliferation danger tier"
    )
    optimal_growth_temp_range: str = Field(
        ..., description="Optimal fungal temperature range (e.g. 25°C - 37°C)"
    )
    ambient_temp_c: float = Field(..., description="Ambient temperature in degrees Celsius")
    relative_humidity_pct: float = Field(..., description="Ambient relative humidity in percent")
    mold_spore_incubation_index: float = Field(
        ..., description="Calculated mold spore incubation index (0.0 - 10.0 scale)"
    )
    fssai_limit_ug_per_kg: float = Field(
        ..., description="FSSAI statutory food safety maximum permissible Aflatoxin B1 limit (15 µg/kg)"
    )
    projected_aflatoxin_ppb: float = Field(
        ..., description="Projected Aflatoxin B1 concentration under current microclimate in µg/kg (ppb)"
    )


class MandiStorageDirectives(BaseModel):
    """Operational engineering directives for mandi supervisors and warehousemen."""
    tarpaulin_status: TarpaulinAlertStatus = Field(
        ..., description="HDPE tarpaulin deployment directive"
    )
    dunnage_pallet_height_recommendation_cm: float = Field(
        ..., description="Mandatory minimum dunnage elevation to break floor capillary moisture wicking (cm)"
    )
    aeration_fan_schedule_recommendation: str = Field(
        ..., description="Silo/godown forced aeration fan operational window directive"
    )
    open_platform_evacuation_needed: bool = Field(
        ..., description="Flag indicating urgent need to evacuate grain heaps from open plinths to covered sheds"
    )
    recommended_actions: List[str] = Field(
        ..., description="Bullet point actionable steps for APMC mandi administrators and farmers"
    )


class MandiHub(BaseModel):
    """Detailed geographical and operational profile of an APMC grain mandi."""
    mandi_id: str = Field(..., description="Unique mandi identifier (e.g. KHANNA_APMC)")
    name: str = Field(..., description="Formal commercial name of the grain mandi")
    district: str = Field(..., description="District location")
    state: str = Field(..., description="State location")
    latitude: float = Field(..., description="Latitude coordinate")
    longitude: float = Field(..., description="Longitude coordinate")
    primary_commodities: List[str] = Field(..., description="Main grains and agricultural commodities traded")
    daily_arrival_metric_tonnes: float = Field(..., description="Peak daily grain arrival volume in metric tonnes")
    storage_capacity_metric_tonnes: float = Field(
        ..., description="Total warehouse / silo storage capacity in metric tonnes"
    )
    open_plinth_pct: float = Field(
        ..., description="Percentage of storage volume held in open Cover and Plinth (CAP) storage"
    )


class MandiSummary(BaseModel):
    """Concise status summary for regional mandi monitoring dashboard."""
    mandi_id: str = Field(..., description="Mandi identifier")
    name: str = Field(..., description="Mandi name")
    state: str = Field(..., description="State")
    risk_tier: MandiWeatherRiskTier = Field(..., description="Current weather risk classification")
    predominant_crop: str = Field(..., description="Key crop assessed")
    current_ambient_rh_pct: float = Field(..., description="Ambient relative humidity in percent")
    tarpaulin_status: TarpaulinAlertStatus = Field(..., description="Tarpaulin alert status")


class AgriStorageResponse(BaseModel):
    """Comprehensive API response for IMD & ICAR Mandi Storage & Grain Moisture Defense."""
    mandi: MandiHub = Field(..., description="Target mandi telemetry and profile")
    assessment_timestamp: str = Field(..., description="ISO 8601 timestamp of storage advisory generation")
    overall_risk_tier: MandiWeatherRiskTier = Field(
        ..., description="Aggregate mandi weather defense tier"
    )
    ambient_temperature_c: float = Field(..., description="Current ambient temperature in deg C")
    ambient_relative_humidity_pct: float = Field(..., description="Current ambient relative humidity in percent")
    weather_condition: str = Field(..., description="Current weather descriptor (e.g. Thunderstorm Approaching)")
    crop_hygroscopic_metrics: List[CropHygroscopicMetrics] = Field(
        ..., description="Hygroscopic grain equilibrium metrics across major commodities"
    )
    open_yard_telemetry: OpenMandiYardTelemetry = Field(
        ..., description="Auction yard drainage, inundation, and wind gust telemetry"
    )
    fungal_mycotoxin_telemetry: FungalMycotoxinTelemetry = Field(
        ..., description="Aflatoxin B1 bio-hazard and mold incubation metrics"
    )
    storage_directives: MandiStorageDirectives = Field(
        ..., description="Operational storage defense directives for mandi staff and farmers"
    )
    monitored_mandis: List[MandiSummary] = Field(
        ..., description="Network summary of key national APMC mandis monitored"
    )
    vernacular_bulletins: Dict[str, str] = Field(
        ..., description="7-language localized advisories (en, hi, pa, mr, te, gu, bn)"
    )
    metadata: Dict[str, str] = Field(
        ..., description="Provenance and institutional citation metadata"
    )
