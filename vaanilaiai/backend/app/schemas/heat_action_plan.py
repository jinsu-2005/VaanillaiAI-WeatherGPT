from enum import Enum
from typing import List, Dict, Optional
from pydantic import BaseModel, Field


class HapTriggerAlertTier(str, Enum):
    NORMAL_GREEN = "NORMAL_GREEN"
    HEAT_ALERT_YELLOW = "HEAT_ALERT_YELLOW"
    SEVERE_HEAT_ALERT_ORANGE = "SEVERE_HEAT_ALERT_ORANGE"
    EXTREME_HEAT_RED = "EXTREME_HEAT_RED"


class UvIndexCategory(str, Enum):
    LOW = "LOW"
    MODERATE = "MODERATE"
    HIGH = "HIGH"
    VERY_HIGH = "VERY_HIGH"
    EXTREME = "EXTREME"


class HeatwaveThermalMetrics(BaseModel):
    max_temp_c: float = Field(..., description="Forecast / current maximum surface air temperature in Celsius")
    normal_temp_c: float = Field(..., description="Climatological normal maximum temperature for the period in Celsius")
    departure_c: float = Field(..., description="Temperature departure departure from normal (+4.5°C alert, +6.5°C severe)")
    consecutive_heatwave_days: int = Field(..., description="Number of consecutive days exceeding heatwave thresholds")
    relative_humidity_pct: float = Field(..., description="Midday ambient relative humidity percentage")
    wet_bulb_temp_c: float = Field(..., description="Stull's estimated wet-bulb temperature in Celsius")
    night_min_temp_c: float = Field(..., description="Nocturnal minimum temperature in Celsius (nocturnal heat load)")


class SolarUvRadiationMetrics(BaseModel):
    uv_index: float = Field(..., description="Global Solar Ultraviolet Index (UVI) at solar noon")
    uv_category: UvIndexCategory = Field(..., description="WHO / IMD UV radiation hazard category")
    peak_uv_hour: str = Field(..., description="Diurnal time window of maximum solar irradiance (e.g. 11:30 - 15:00)")
    ozone_column_du: float = Field(..., description="Total atmospheric column ozone in Dobson Units (DU)")
    minimal_erythemal_dose_rate_med_hr: float = Field(..., description="Minimal Erythemal Dose accumulation rate (MED/hr)")
    time_to_sunburn_minutes: int = Field(..., description="Estimated time to erythema / sunburn for unprotected skin in minutes")
    recommended_spf: int = Field(..., description="Dermatologically recommended broad-spectrum SPF rating")


class MunicipalHeatDirectives(BaseModel):
    cool_roof_initiative_active: bool = Field(..., description="Whether municipal Cool Roof SRI reflective coating program is active")
    solar_reflectance_index_sri: float = Field(..., description="Mean Solar Reflectance Index of treated cool roofs (target >= 78)")
    bocw_labor_work_suspension_hours: str = Field(..., description="Mandatory construction labor work halt window under BOCW Act")
    active_pyau_water_stations: int = Field(..., description="Number of municipal public drinking water kiosks (Pyaus) operating")
    hospital_heatstroke_beds: int = Field(..., description="Dedicated rapid cooling emergency hospital beds with ice baths")
    emergency_cooling_ice_bath_ready: bool = Field(..., description="Whether whole-body immersion ice bath units are ready in emergency wards")
    ors_distribution_booths: int = Field(..., description="Number of public Oral Rehydration Salt (ORS) distribution centers active")


class HeatActionHotspotZone(BaseModel):
    zone_id: str = Field(..., description="Unique slug for the heatwave hotspot")
    zone_name: str = Field(..., description="Public title of the municipal / arid corridor")
    state: str = Field(..., description="State jurisdiction")
    district: str = Field(..., description="District jurisdiction")
    latitude: float = Field(..., description="Centroid latitude")
    longitude: float = Field(..., description="Centroid longitude")
    alert_tier: HapTriggerAlertTier = Field(..., description="NDMA / Municipal Heat Action Plan color-coded trigger tier")
    thermal_metrics: HeatwaveThermalMetrics = Field(..., description="Heatwave temperature and thermal stress parameters")
    uv_metrics: SolarUvRadiationMetrics = Field(..., description="Solar UV radiation and photobiological exposure limits")
    municipal_directives: MunicipalHeatDirectives = Field(..., description="Urban resilience, worker protection, and medical readiness")
    vulnerable_demographics: List[str] = Field(..., description="Key vulnerable community segments at risk")
    localized_bulletins: Dict[str, str] = Field(..., description="Multilingual heat health advisories (EN, HI, GU, TE, OR)")


class HeatActionPlanResponse(BaseModel):
    timestamp: str = Field(..., description="ISO 8601 generation timestamp")
    bulletin_number: str = Field(..., description="Official NDMA-IMD Heat Action Plan bulletin reference")
    provenance: str = Field(..., description="Institutional provenance (NDMA / IMD / State Disaster Management Authorities)")
    selected_zone: HeatActionHotspotZone = Field(..., description="Target evaluated heatwave hotspot")
    all_zones: List[HeatActionHotspotZone] = Field(..., description="Catalog of monitored national heatwave corridors")
    vernacular_bulletins: Dict[str, str] = Field(..., description="Multilingual public health directives")
    is_offline_cached: bool = Field(default=False, description="Whether data originated from offline cache")
