from enum import Enum
from typing import Dict, List, Optional
from pydantic import BaseModel, Field


class WindResourceTier(str, Enum):
    OUTSTANDING = "OUTSTANDING"  # WPD >= 500 W/m2 (v >= 8.0 m/s)
    EXCELLENT = "EXCELLENT"      # 400 <= WPD < 500 W/m2 (7.5 - 8.0 m/s)
    GOOD = "GOOD"                # 300 <= WPD < 400 W/m2 (7.0 - 7.5 m/s)
    MODERATE = "MODERATE"        # 250 <= WPD < 300 W/m2 (6.4 - 7.0 m/s)
    MARGINAL = "MARGINAL"        # 200 <= WPD < 250 W/m2 (5.6 - 6.4 m/s)
    POOR = "POOR"                # WPD < 200 W/m2 (v < 5.6 m/s)


class TurbineOperatingState(str, Enum):
    BELOW_CUT_IN = "BELOW_CUT_IN"            # v < 3.0 m/s
    PARTIAL_LOAD_RAMP = "PARTIAL_LOAD_RAMP"  # 3.0 <= v < 11.5 m/s
    RATED_FULL_LOAD = "RATED_FULL_LOAD"      # 11.5 <= v < 25.0 m/s
    STORM_CUT_OUT = "STORM_CUT_OUT"          # v >= 25.0 m/s


class HubHeightWindVector(BaseModel):
    height_m: int = Field(..., description="Hub height above ground level in meters (10, 50, 80, 100, 120, 140, 150)")
    wind_speed_ms: float = Field(..., description="Extrapolated wind speed in m/s")
    wind_speed_kmh: float = Field(..., description="Extrapolated wind speed in km/h")
    wind_power_density_wm2: float = Field(..., description="Wind Power Density (WPD) in W/m^2")
    wind_direction_deg: float = Field(..., description="Wind direction in degrees (0-360)")
    cardinal_direction: str = Field(..., description="16-point cardinal direction string (e.g. WSW, SW)")
    resource_tier: WindResourceTier = Field(..., description="NIWE Wind Resource Classification Tier at this height")


class AtmosphericAirDensityProfile(BaseModel):
    surface_temperature_c: float = Field(..., description="Surface ambient temperature in deg C")
    surface_pressure_hpa: float = Field(..., description="Surface atmospheric pressure in hPa")
    air_density_kgm3: float = Field(..., description="Actual air density at hub height in kg/m^3")
    standard_density_kgm3: float = Field(default=1.225, description="Standard atmospheric air density at sea level in kg/m^3")
    density_ratio: float = Field(..., description="Ratio of actual to standard density (rho / rho_0)")
    thermal_derating_note: str = Field(..., description="Explanation of aerodynamic density impact on turbine thrust and energy capture")


class WeibullParameters(BaseModel):
    shape_k: float = Field(..., description="Weibull dimensionless shape parameter k (typically 1.8 - 2.4 in Indian wind regimes)")
    scale_c_ms: float = Field(..., description="Weibull scale parameter c in m/s")
    annual_mean_speed_ms: float = Field(..., description="Annual mean climatological wind speed in m/s")


class TurbineGenerationProfile(BaseModel):
    model_name: str = Field(..., description="Turbine model identifier and OEM class")
    rated_power_mw: float = Field(..., description="Nameplate rated electrical capacity in MW")
    rotor_diameter_m: float = Field(..., description="Rotor swept diameter in meters")
    hub_height_m: int = Field(..., description="Tower hub centerline height in meters")
    cut_in_speed_ms: float = Field(default=3.0, description="Cut-in wind speed in m/s")
    rated_speed_ms: float = Field(default=11.5, description="Rated wind speed in m/s")
    cut_out_speed_ms: float = Field(default=25.0, description="Storm cut-out shutdown wind speed in m/s")
    operating_state: TurbineOperatingState = Field(..., description="Current aerodynamic operational state")
    gross_hourly_output_mw: float = Field(..., description="Gross aerodynamic electrical output in MW")
    wake_loss_pct: float = Field(..., description="Array wake turbulence loss percentage (typically 6.0 - 8.5%)")
    bop_electrical_loss_pct: float = Field(..., description="Balance of Plant, collector grid and transformer losses %")
    blade_soiling_loss_pct: float = Field(..., description="Blade roughness, dust, and insect contamination loss %")
    net_hourly_output_mw: float = Field(..., description="Net delivered grid-injected power in MW")
    daily_generation_mwh: float = Field(..., description="Expected 24-hour total energy generation in MWh")
    capacity_utilization_factor_pct: float = Field(..., description="Plant Capacity Utilization Factor (CUF %)")


class RepoweringPotential(BaseModel):
    legacy_turbine_rating_kw: float = Field(..., description="Legacy turbine capacity in kW (e.g. 350-500 kW at 40m)")
    modern_turbine_rating_mw: float = Field(..., description="Modern repowered turbine capacity in MW (e.g. 2.7-3.0 MW at 140m)")
    energy_yield_multiplier: float = Field(..., description="Factor of increase in annual generation from modern repowering")
    co2_abatement_tons_yr: float = Field(..., description="Additional carbon abatement in metric tons CO2 per annum")
    repowering_priority: str = Field(..., description="NIWE repowering priority designation (HIGH, MODERATE, OPTIMIZED)")


class HourlyWindForecast(BaseModel):
    hour: str = Field(..., description="Timestamp hour (e.g. 00:00, 03:00, ...)")
    wind_speed_100m_ms: float = Field(..., description="Forecasted 100m hub-height wind speed in m/s")
    wind_direction_deg: float = Field(..., description="Forecasted wind direction in degrees")
    expected_net_mw: float = Field(..., description="Projected net farm generation in MW")
    cuf_pct: float = Field(..., description="Hourly plant Capacity Utilization Factor (CUF %)")


class WindParkCorridor(BaseModel):
    corridor_id: str = Field(..., description="Unique slug identifier for the wind energy corridor")
    corridor_name: str = Field(..., description="Name of the wind park or regional complex")
    state: str = Field(..., description="Indian State or Union Territory")
    installed_capacity_mw: float = Field(..., description="Current installed wind capacity in MW")
    latitude: float = Field(..., description="Latitude coordinate")
    longitude: float = Field(..., description="Longitude coordinate")
    elevation_m: float = Field(..., description="Terrain altitude above mean sea level in meters")
    terrain_roughness_alpha: float = Field(..., description="Hellmann wind shear power-law exponent alpha (0.12 - 0.24)")
    resource_tier: WindResourceTier = Field(..., description="Resource classification at primary reference hub height")
    surface_wind_10m_ms: float = Field(..., description="Surface 10m meteorological wind speed in m/s")
    surface_wind_dir_deg: float = Field(..., description="Surface wind direction in degrees")
    air_density: AtmosphericAirDensityProfile = Field(..., description="Atmospheric air density parameters and derating")
    weibull: WeibullParameters = Field(..., description="Climatological Weibull probability parameters")
    hub_height_profiles: List[HubHeightWindVector] = Field(..., description="Wind speed and WPD across 50m, 80m, 100m, 120m, 140m, 150m")
    turbine_profiles: List[TurbineGenerationProfile] = Field(..., description="Generation metrics for standard 2.0 MW vs advanced 3.0 MW machines")
    repowering: RepoweringPotential = Field(..., description="Repowering feasibility and energy multiplication metrics")
    hourly_forecast: List[HourlyWindForecast] = Field(..., description="24-hour wind speed and power generation curve")


class CorridorSummary(BaseModel):
    corridor_id: str
    corridor_name: str
    state: str
    installed_capacity_mw: float
    resource_tier: WindResourceTier
    reference_speed_100m_ms: float
    reference_wpd_100m_wm2: float
    cuf_pct: float


class WindEnergyResponse(BaseModel):
    selected_corridor: WindParkCorridor = Field(..., description="Full telemetry and assessment for the selected wind park")
    all_corridors: List[CorridorSummary] = Field(..., description="Summary catalog of all 7 Indian wind energy corridors")
    bulletins: Dict[str, str] = Field(..., description="Operational and grid dispatch bulletins in 7 regional languages")
    offline_cached: bool = Field(default=False, description="Flag indicating whether data was served from offline fallback")
    generated_at: str = Field(..., description="ISO 8601 generation timestamp")
