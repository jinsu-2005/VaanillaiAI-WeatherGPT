"""Pydantic schemas for IMD, CWC & DGRE Himalayan Snowmelt Runoff,
Snow Cover Area (SCA) & Glacial Hydrology Engine (SNOWMELT-HYDRO).
"""

from enum import Enum
from typing import Dict, List, Optional
from pydantic import BaseModel, Field


class SnowmeltRegime(str, Enum):
    """Dominant cryospheric runoff regime for the Himalayan catchment."""
    SEASONAL_SNOWMELT_SURGE = "SEASONAL_SNOWMELT_SURGE"
    GLACIAL_ABLATION_PEAK = "GLACIAL_ABLATION_PEAK"
    TRANSITIONAL_FREEZE_THAW = "TRANSITIONAL_FREEZE_THAW"
    BASEFLOW_DOMINATED = "BASEFLOW_DOMINATED"
    RAIN_ON_SNOW_BURST = "RAIN_ON_SNOW_BURST"


class SnowCoverTier(str, Enum):
    """Satellite-derived snow cover area (SCA) extent tier."""
    HYPER_GLACIATED = "HYPER_GLACIATED"          # > 75% SCA
    EXTENSIVE_SNOWPACK = "EXTENSIVE_SNOWPACK"      # 50% - 75% SCA
    MODERATE_RECEDING = "MODERATE_RECEDING"        # 25% - 50% SCA
    ISOLATED_PATCHES = "ISOLATED_PATCHES"          # 10% - 25% SCA
    MINIMAL_SNOWLINE = "MINIMAL_SNOWLINE"          # < 10% SCA


class HydropowerInflowStatus(str, Enum):
    """Inflow operating status for downstream hydroelectric storage dams."""
    OPTIMAL_GENERATION_SURGE = "OPTIMAL_GENERATION_SURGE"
    SPILLWAY_DISCHARGE_WARNING = "SPILLWAY_DISCHARGE_WARNING"
    NORMAL_STORAGE_FILL = "NORMAL_STORAGE_FILL"
    LEAN_DISCHARGE_CAUTION = "LEAN_DISCHARGE_CAUTION"
    SEDIMENT_FLUSHING_ALERT = "SEDIMENT_FLUSHING_ALERT"


class ElevationZonalBand(BaseModel):
    """Hypsometric elevation band metrics for the Martinec-Rango SRM."""
    band_id: str = Field(..., description="Band identifier (e.g. ZONE_A, ZONE_B)")
    elevation_range_label: str = Field(..., description="Elevation range (e.g. 2000m - 3000m AMSL)")
    elevation_min_m: float = Field(..., description="Minimum elevation of band in meters AMSL")
    elevation_max_m: float = Field(..., description="Maximum elevation of band in meters AMSL")
    zonal_area_sq_km: float = Field(..., description="Surface area of the elevation zone in sq km")
    snow_cover_area_pct: float = Field(..., description="Snow-covered area fraction in percent (0 - 100%)")
    mean_temperature_c: float = Field(..., description="Lapse-rate adjusted mean degree-day temperature in deg C")
    degree_day_factor_cm_per_deg_c_day: float = Field(
        ..., description="Degree-Day Factor (DDF) in cm / (deg C * day)"
    )
    daily_melt_volume_mcm: float = Field(
        ..., description="Calculated daily snowmelt water volume in Million Cubic Meters (MCM)"
    )


class SnowpackCryosphereTelemetry(BaseModel):
    """Cryospheric snowpack and atmospheric freezing level telemetry."""
    snow_line_altitude_m: float = Field(
        ..., description="Current Snow Line Altitude (SLA) in meters AMSL"
    )
    equilibrium_line_altitude_m: float = Field(
        ..., description="Glacial Equilibrium Line Altitude (ELA) in meters AMSL"
    )
    freezing_level_isotherm_m: float = Field(
        ..., description="Atmospheric 0 deg C Freezing Level Isotherm in meters AMSL"
    )
    basin_snow_water_equivalent_mm: float = Field(
        ..., description="Catchment-wide average Snow Water Equivalent (SWE) in mm"
    )
    fresh_snow_24h_cm: float = Field(
        ..., description="Fresh solid snowfall received in the last 24 hours in cm"
    )
    satellite_ndsi_coverage_pct: float = Field(
        ..., description="Satellite Normalized Difference Snow Index (NDSI) valid pixel coverage"
    )


class CatchmentRunoffMetrics(BaseModel):
    """Hydrological streamflow runoff and diurnal surge telemetry."""
    daily_discharge_cumecs: float = Field(
        ..., description="Daily average river discharge rate in cubic meters per second (cumecs)"
    )
    snowmelt_fraction_pct: float = Field(
        ..., description="Proportion of total streamflow originating from snow/ice melt (0 - 100%)"
    )
    rainfall_contribution_pct: float = Field(
        ..., description="Proportion of total streamflow originating from liquid rainfall (0 - 100%)"
    )
    baseflow_contribution_pct: float = Field(
        ..., description="Proportion of total streamflow originating from groundwater baseflow (0 - 100%)"
    )
    peak_diurnal_hour_ist: str = Field(
        ..., description="Expected hour of peak diurnal melt wave arrival (e.g. 18:00 IST)"
    )
    peak_diurnal_discharge_cumecs: float = Field(
        ..., description="Projected peak discharge during late-afternoon diurnal wave in cumecs"
    )
    diurnal_discharge_amplitude_pct: float = Field(
        ..., description="Percentage variation between daily minimum and maximum diurnal discharge"
    )


class DownstreamHydropowerInflow(BaseModel):
    """Hydroelectric dam inflow and multi-purpose reservoir storage telemetry."""
    dam_name: str = Field(..., description="Major dam / reservoir facility name")
    river_basin: str = Field(..., description="Himalayan river system (e.g. Satluj, Bhagirathi)")
    installed_capacity_mw: float = Field(..., description="Installed power generation capacity in MW")
    live_inflow_cumecs: float = Field(..., description="Live reservoir inflow in cumecs")
    generation_capacity_utilized_pct: float = Field(
        ..., description="Current turbine dispatch utilization percentage"
    )
    daily_storage_gain_mcm: float = Field(
        ..., description="Daily reservoir storage volume accretion in Million Cubic Meters"
    )
    spillway_clearance_margin_m: float = Field(
        ..., description="Freeboard margin to Full Reservoir Level (FRL) crest in meters"
    )
    inflow_status: HydropowerInflowStatus = Field(
        ..., description="Operational status of reservoir inflows"
    )


class SnowmeltBasin(BaseModel):
    """Complete hydro-meteorological model for a Himalayan snowmelt catchment."""
    basin_id: str = Field(..., description="Unique slug identifier (e.g. satluj_bhakra)")
    basin_name: str = Field(..., description="Full catchment name")
    state: str = Field(..., description="State or Union Territory")
    mountain_range: str = Field(..., description="Primary mountain range (e.g. Greater Himalaya, Pir Panjal)")
    drainage_area_sq_km: float = Field(..., description="Total catchment drainage area in sq km")
    current_regime: SnowmeltRegime = Field(..., description="Active runoff regime")
    elevation_bands: List[ElevationZonalBand] = Field(..., description="Hypsometric SRM elevation zones")
    cryosphere_telemetry: SnowpackCryosphereTelemetry = Field(..., description="Snowpack & freezing level telemetry")
    runoff_metrics: CatchmentRunoffMetrics = Field(..., description="Streamflow and diurnal surge metrics")
    hydropower_inflows: List[DownstreamHydropowerInflow] = Field(..., description="Downstream dam facilities")
    riparian_safety_advisory: str = Field(..., description="Downstream flood and riverbed safety advisory")
    vernacular_bulletins: Dict[str, str] = Field(
        ..., description="Regional bulletins across 7 Himalayan mountain languages"
    )


class BasinSummary(BaseModel):
    """Concise catchment summary for horizontal switcher chips."""
    basin_id: str = Field(..., description="Basin identifier")
    basin_name: str = Field(..., description="Basin name")
    state: str = Field(..., description="State or UT")
    river_system: str = Field(..., description="Parent river system")
    daily_discharge_cumecs: float = Field(..., description="Discharge rate in cumecs")
    snowmelt_fraction_pct: float = Field(..., description="Snowmelt percentage")
    inflow_status: HydropowerInflowStatus = Field(..., description="Inflow status")


class SnowmeltRunoffResponse(BaseModel):
    """Top-level response payload for the Himalayan Snowmelt Runoff Engine."""
    basin_id: str = Field(..., description="Selected basin identifier")
    basin_name: str = Field(..., description="Selected basin name")
    state: str = Field(..., description="Selected state")
    current_basin: SnowmeltBasin = Field(..., description="Detailed catchment assessment")
    all_basins: List[BasinSummary] = Field(..., description="List of all monitored Himalayan catchments")
    last_updated_utc: str = Field(..., description="ISO 8601 timestamp of data generation")
    data_source: str = Field(..., description="Institutional attribution (IMD, CWC, DRDO-DGRE, NRSC-ISRO)")
