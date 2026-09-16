from enum import Enum
from typing import Dict, List, Optional
from pydantic import BaseModel, Field


class SolarRadiationTier(str, Enum):
    EXCELLENT = "EXCELLENT"  # GHI > 850 W/m2
    GOOD = "GOOD"            # 650 <= GHI <= 850 W/m2
    MODERATE = "MODERATE"    # 450 <= GHI < 650 W/m2
    POOR = "POOR"            # GHI < 450 W/m2


class CleaningUrgency(str, Enum):
    ROUTINE = "ROUTINE"
    RECOMMENDED = "RECOMMENDED"
    URGENT_CLEANING_REQUIRED = "URGENT_CLEANING_REQUIRED"


class SolarIrradianceComponents(BaseModel):
    ghi_wm2: float = Field(..., description="Global Horizontal Irradiance in W/m^2")
    dni_wm2: float = Field(..., description="Direct Normal Irradiance in W/m^2")
    dhi_wm2: float = Field(..., description="Diffuse Horizontal Irradiance in W/m^2")
    solar_zenith_angle_deg: float = Field(..., description="Solar zenith angle in degrees")
    clearness_index_kt: float = Field(..., description="Clearness index kt (GHI / G0)")
    cloud_attenuation_pct: float = Field(..., description="Percentage irradiance loss due to cloud optical depth")


class PhotovoltaicPerformance(BaseModel):
    ambient_temperature_c: float = Field(..., description="Ambient dry bulb air temperature in deg C")
    pv_cell_temperature_c: float = Field(..., description="Operating photovoltaic cell temperature in deg C")
    temperature_derating_pct: float = Field(..., description="Thermal efficiency penalty percentage relative to STC 25 deg C")
    performance_ratio_pct: float = Field(..., description="Overall balance of system Performance Ratio (PR %)")
    specific_yield_kwh_per_kwp: float = Field(..., description="Specific daily electrical yield in kWh per kWp installed")


class SoilingAndCleaningAdvisory(BaseModel):
    soiling_loss_pct: float = Field(..., description="Estimated dust/particulate matter soiling transmission loss %")
    cleaning_recommended: bool = Field(..., description="Flag indicating if panel cleaning is advised")
    cleaning_urgency: CleaningUrgency = Field(..., description="Urgency of panel washing")
    next_rain_washout_forecast: str = Field(..., description="Expected natural precipitation washing advisory")
    optimal_cleaning_window: str = Field(..., description="Recommended time of day for panel washing (e.g. Early morning before sunrise)")


class HourlySolarForecast(BaseModel):
    hour: str = Field(..., description="Time of day (e.g. 06:00, 07:00, ...)")
    ghi_wm2: float = Field(..., description="Expected GHI in W/m^2")
    cell_temperature_c: float = Field(..., description="Expected PV cell temperature in deg C")
    estimated_generation_kwh_per_kwp: float = Field(..., description="Expected normalized generation in kWh/kWp")


class RooftopCapacityMetrics(BaseModel):
    capacity_kwp: float = Field(..., description="Installed PV capacity in kWp")
    daily_generation_kwh: float = Field(..., description="Expected daily energy output in kWh")
    monthly_generation_kwh: float = Field(..., description="Estimated monthly energy output in kWh")
    monthly_savings_inr: float = Field(..., description="Estimated monthly electricity bill savings in INR (₹)")
    co2_offset_kg_per_month: float = Field(..., description="Monthly greenhouse gas emissions avoided in kg CO2")


class SolarParkSector(BaseModel):
    park_id: str = Field(..., description="Unique slug identifier for the solar park or rooftop cluster")
    park_name: str = Field(..., description="Full name of the solar installation or regional cluster")
    state: str = Field(..., description="Indian State or Union Territory")
    installed_capacity_mw: float = Field(..., description="Installed or representative capacity in MWp")
    latitude: float = Field(..., description="Latitude coordinate")
    longitude: float = Field(..., description="Longitude coordinate")
    radiation_tier: SolarRadiationTier = Field(..., description="Solar resource classification")
    irradiance: SolarIrradianceComponents = Field(..., description="Detailed irradiance components (GHI, DNI, DHI)")
    pv_performance: PhotovoltaicPerformance = Field(..., description="PV cell temperature and yield performance")
    soiling_advisory: SoilingAndCleaningAdvisory = Field(..., description="Particulate dust soiling metrics and washing guidance")
    rooftop_economics: List[RooftopCapacityMetrics] = Field(..., description="Economic metrics across standard rooftop system sizes")
    hourly_forecast: List[HourlySolarForecast] = Field(..., description="Hourly daylight solar generation profile")
    vernacular_bulletins: Dict[str, str] = Field(..., description="Multilingual solar advisory bulletins")


class SolarEnergyResponse(BaseModel):
    timestamp: str = Field(..., description="ISO-8601 UTC timestamp")
    bulletin_number: str = Field(..., description="Official NISE/IMD bulletin identifier")
    provenance: str = Field(..., description="Data provenance attributing NISE, MNRE & IMD Solar Radiation Network")
    national_solar_overview: str = Field(..., description="Executive summary of national solar radiation and green grid conditions")
    selected_sector: SolarParkSector = Field(..., description="Currently selected solar sector or nearest park")
    all_sectors: List[SolarParkSector] = Field(..., description="Catalog of major Indian solar parks and corridors")
    solar_physics_model: str = Field(..., description="Description of underlying physical radiation and PV models")
    vernacular_bulletins: Dict[str, str] = Field(..., description="Localized solar advisories")
    is_offline_cached: bool = Field(False, description="Flag indicating offline cached data")
