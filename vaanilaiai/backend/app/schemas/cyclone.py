"""Pydantic schemas for IMD RSMC Tropical Cyclone Track, Storm Surge & Dvorak T-Number Intensity."""
from typing import List, Dict, Optional
from pydantic import BaseModel, Field


class DvorakTelemetry(BaseModel):
    t_number: float = Field(..., description="Dvorak T-number (T1.0 to T8.0 in 0.5 increments)")
    ci_number: float = Field(..., description="Current Intensity (CI) number")
    central_pressure_hpa: float = Field(..., description="Estimated central sea level pressure in hPa")
    pressure_deficit_hpa: float = Field(..., description="Central pressure deficit ΔP = 1010 - Pc (hPa)")
    max_sustained_wind_kt: float = Field(..., description="Maximum sustained surface wind in knots (3-min average)")
    max_sustained_wind_kmh: float = Field(..., description="Maximum sustained wind in km/h")
    gust_speed_kmh: float = Field(..., description="Peak gust wind speed in km/h")
    intensity_stage: str = Field(..., description="IMD Cyclone Intensity Classification (e.g. Very Severe Cyclonic Storm)")
    intensity_code: str = Field(..., description="Standard acronym: D, DD, CS, SCS, VSCS, ESCS, SuCS")


class GaleWindRadii(BaseModel):
    radius_34kt_ne_km: float = Field(..., description="34-knot (62 km/h) gale wind radius in NE quadrant (km)")
    radius_34kt_se_km: float = Field(..., description="34-knot gale wind radius in SE quadrant (km)")
    radius_34kt_sw_km: float = Field(..., description="34-knot gale wind radius in SW quadrant (km)")
    radius_34kt_nw_km: float = Field(..., description="34-knot gale wind radius in NW quadrant (km)")
    radius_50kt_ne_km: float = Field(..., description="50-knot (92 km/h) storm wind radius in NE quadrant (km)")
    radius_50kt_se_km: float = Field(..., description="50-knot storm wind radius in SE quadrant (km)")
    radius_50kt_sw_km: float = Field(..., description="50-knot storm wind radius in SW quadrant (km)")
    radius_50kt_nw_km: float = Field(..., description="50-knot storm wind radius in NW quadrant (km)")
    radius_64kt_ne_km: float = Field(..., description="64-knot (118 km/h) hurricane wind radius in NE quadrant (km)")
    radius_64kt_se_km: float = Field(..., description="64-knot hurricane wind radius in SE quadrant (km)")
    radius_64kt_sw_km: float = Field(..., description="64-knot hurricane wind radius in SW quadrant (km)")
    radius_64kt_nw_km: float = Field(..., description="64-knot hurricane wind radius in NW quadrant (km)")


class CycloneTrackPoint(BaseModel):
    forecast_hour: int = Field(..., description="Forecast timeline hour offset: -12, -6, 0 (Current), +6, +12, +24, +48, +72")
    timestamp_iso: str
    latitude: float
    longitude: float
    stage_code: str
    stage_name: str
    central_pressure_hpa: float
    max_wind_kmh: float
    status: str = Field(..., description="Past, Current, Forecast")
    cone_of_uncertainty_km: float = Field(..., description="Cone of track uncertainty radius in km")


class StormSurgeInundation(BaseModel):
    coastal_district: str
    astronomical_tide_m: float = Field(..., description="Astronomical high tide height in meters")
    peak_surge_m: float = Field(..., description="Peak meteorological storm surge height above tide (m)")
    total_water_level_m: float = Field(..., description="Total water level = Tide + Surge (m)")
    inland_inundation_km: float = Field(..., description="Estimated seawater penetration distance inland (km)")
    surge_risk_tier: str = Field(..., description="Low, Moderate, High, Catastrophic")
    surge_warning_note: str


class EvacuationDirective(BaseModel):
    red_zone_action: str = Field(..., description="Action for coastal zone < 5 km from high tide line")
    orange_zone_action: str = Field(..., description="Action for coastal zone 5 to 15 km inland")
    yellow_zone_action: str = Field(..., description="Action for zone > 15 km inland")
    port_warning_signal: int = Field(..., description="Official IMD Port Warning Signal number (1 to 11)")
    port_signal_meaning: str
    shelters_active_count: int


class CycloneSystem(BaseModel):
    system_id: str
    name: str
    basin: str = Field(..., description="Bay of Bengal or Arabian Sea")
    is_active: bool = True
    warning_stage: str = Field(..., description="Stage 1: Pre-Cyclone Watch, Stage 2: Cyclone Alert, Stage 3: Cyclone Warning, Stage 4: Post-Landfall Outlook")
    stage_color_hex: str
    dvorak: DvorakTelemetry
    current_latitude: float
    current_longitude: float
    movement_direction: str
    movement_speed_kmh: float
    distance_to_user_km: Optional[float] = None
    projected_landfall_location: str
    projected_landfall_time: str
    landfall_eta_hours: Optional[float] = None
    track_points: List[CycloneTrackPoint] = []
    gale_radii: GaleWindRadii
    storm_surge_forecasts: List[StormSurgeInundation] = []
    evacuation: EvacuationDirective
    vernacular_bulletin: Dict[str, str] = {}


class CycloneTrackerResponse(BaseModel):
    basin_status: str = Field(..., description="Active Cyclone Alert or Basin Vigilance - Normal")
    active_systems_count: int
    selected_system: CycloneSystem
    available_systems: List[CycloneSystem] = []
    nearest_system_distance_km: Optional[float] = None
    basin_readiness_summary: str
    rsmc_bulletin_no: str
    issued_at: str
    authority_disclaimer: str
