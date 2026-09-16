from typing import List, Optional, Dict
from enum import Enum
from pydantic import BaseModel, Field


class StormPhenomenonType(str, Enum):
    KALBAISHAKHI_NORWESTER = "KALBAISHAKHI_NORWESTER"
    HABOOB_ANDHI_DUST_STORM = "HABOOB_ANDHI_DUST_STORM"
    SEVERE_SQUALL_LINE = "SEVERE_SQUALL_LINE"
    HAILSTORM_SUPERCELL = "HAILSTORM_SUPERCELL"
    GUST_FRONT_MICROBURST = "GUST_FRONT_MICROBURST"


class ConvectiveWarningStage(str, Enum):
    STAGE_1_GREEN_WATCH = "STAGE_1_GREEN_WATCH"
    STAGE_2_YELLOW_ALERT = "STAGE_2_YELLOW_ALERT"
    STAGE_3_ORANGE_WARNING = "STAGE_3_ORANGE_WARNING"
    STAGE_4_RED_SEVERE_WARNING = "STAGE_4_RED_SEVERE_WARNING"


class ThermodynamicInstability(BaseModel):
    cape_j_kg: float = Field(..., description="Convective Available Potential Energy in J/kg")
    lifted_index_c: float = Field(..., description="Lifted Index (LI) in °C")
    k_index_c: float = Field(..., description="George's K-Index in °C")
    total_totals_c: float = Field(..., description="Total Totals Index (TT) in °C")
    sweat_index: float = Field(..., description="Severe Weather Threat Index (SWEAT)")
    bulk_wind_shear_0_6km_kt: float = Field(..., description="0-6 km Deep-Layer Bulk Wind Shear in knots")
    cin_j_kg: float = Field(..., description="Convective Inhibition (CIN) in J/kg")


class HaboobDensityCurrent(BaseModel):
    gust_front_speed_kmh: float = Field(..., description="Leading gust front speed in km/h")
    dust_wall_height_m: float = Field(..., description="Haboob particulate wall vertical height in meters")
    minimum_visibility_m: float = Field(..., description="Minimum horizontal visibility drop in meters")
    pm10_surge_ug_m3: float = Field(..., description="Peak PM10 airborne particulate concentration in µg/m³")
    cold_pool_temp_drop_c: float = Field(..., description="Sudden temperature drop behind the cold-pool front in °C")
    downdraft_spread_direction: str = Field(..., description="Primary propagation direction of convective density current")


class AviationGridImpact(BaseModel):
    microburst_risk: str = Field(..., description="Low-Level Wind Shear (LLWS) and microburst threat level")
    power_grid_risk: str = Field(..., description="Transmission tower line trip and structural oscillation risk")
    airport_alert: str = Field(..., description="Aviation ground handling and runway crosswind advisory")
    structural_damage_risk: str = Field(..., description="Risk of tin roof blow-off, hoarding collapse, and uprooted trees")


class ConvectiveStormHotspot(BaseModel):
    hotspot_id: str = Field(..., description="Unique hotspot identifier")
    hotspot_name: str = Field(..., description="Monitoring convective corridor name")
    state: str = Field(..., description="Indian State or Union Territory")
    latitude: float = Field(..., description="Corridor centroid latitude")
    longitude: float = Field(..., description="Corridor centroid longitude")
    phenomenon: StormPhenomenonType = Field(..., description="Primary severe convective phenomenon")
    warning_stage: ConvectiveWarningStage = Field(..., description="IMD Convective Warning Stage")
    headline: str = Field(..., description="Executive alert headline")
    thermodynamics: ThermodynamicInstability = Field(..., description="Thermodynamic atmospheric sounding indices")
    density_current: HaboobDensityCurrent = Field(..., description="Cold-pool gust front and Haboob dynamics")
    aviation_grid: AviationGridImpact = Field(..., description="Aviation and power infrastructure impacts")
    radar_reflectivity_dbz: float = Field(..., description="Peak Doppler radar core reflectivity in dBZ")
    nowcast_validity_hours: int = Field(..., description="Nowcast validity window in hours (usually 3h)")


class ConvectiveStormResponse(BaseModel):
    timestamp: str = Field(..., description="ISO-8601 generation timestamp")
    selected_hotspot: ConvectiveStormHotspot = Field(..., description="Active or nearest severe storm hotspot")
    all_hotspots: List[ConvectiveStormHotspot] = Field(..., description="All monitored pre-monsoon convective hotspots")
    vernacular_bulletins: Dict[str, str] = Field(..., description="Multilingual bulletins (EN, HI, BN, OR, AS)")
    imd_bulletin_reference: str = Field(..., description="IMD SWFDP bulletin operational reference number")
    provenance: str = Field(..., description="Official provenance attribution (IMD & NCMRWF)")
