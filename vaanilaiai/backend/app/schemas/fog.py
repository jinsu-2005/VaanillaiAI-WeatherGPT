"""Pydantic schemas for IMD FogPass, Highway Safety & Aviation Low-Visibility Nowcasting."""
from datetime import datetime, timezone
from enum import Enum
from typing import Dict, List, Optional
from pydantic import BaseModel, Field, ConfigDict


class VisibilityTier(str, Enum):
    CLEAR = "Clear"                       # > 1000m
    SHALLOW_FOG = "Shallow Fog"           # 500 - 1000m
    MODERATE_FOG = "Moderate Fog"         # 200 - 499m
    DENSE_FOG = "Dense Fog"               # 50 - 199m
    VERY_DENSE_FOG = "Very Dense Fog"     # < 50m


class RvrCategory(str, Enum):
    NORMAL = "Normal Operations"                  # > 550m
    CAT_I = "CAT I (Standard ILS)"               # 550 - 799m
    CAT_II = "CAT II (Low Visibility)"           # 300 - 549m
    CAT_IIIA = "CAT IIIA (Precision Touchdown)"  # 175 - 299m
    CAT_IIIB = "CAT IIIB (Blind Autoland)"       # 50 - 174m
    CAT_IIIC = "CAT IIIC (Airport Shutdown)"     # < 50m


class HighwaySafetyAdvisory(BaseModel):
    expressway_name: str = Field(..., description="Major highway or corridor identifier")
    advised_speed_kmh: int = Field(..., description="Maximum advised safe vehicular speed in fog")
    normal_speed_limit_kmh: int = Field(default=100, description="Statutory expressway speed limit")
    following_distance_multiplier: str = Field(..., description="Safe headway distance directive")
    hazard_lights_directive: str = Field(..., description="NHAI headlight and hazard flasher rule")
    pileup_risk_level: str = Field(..., description="Low, Moderate, High, Severe")
    nearest_layby_parking: str = Field(..., description="Safe truck lay-by, wayside amenity, or toll plaza")
    action_summary: str = Field(..., description="Key life-safety driving rule")


class RailwayFogPassTelemetry(BaseModel):
    fogpass_active: bool = Field(default=True, description="Locomotive GPS FogPass device operational")
    locomotive_speed_cap_kmh: int = Field(default=60, description="Mandatory Railway Board fog speed restriction")
    rail_corridor: str = Field(..., description="Northern / East Central Railway high-density trunk route")
    signal_visibility: str = Field(..., description="Visual acquisition distance of color-light aspect")
    expected_delay_bracket: str = Field(..., description="Passenger and freight timetable disruption bracket")
    detonator_rule_active: bool = Field(default=False, description="Station detonator fog-signal placement requirement")


class FogPhysicsMetrics(BaseModel):
    air_temperature_c: float = Field(..., description="Dry bulb ambient temperature")
    dew_point_c: float = Field(..., description="Dew-point temperature")
    dew_point_depression_c: float = Field(..., description="T - Td temperature deficit")
    relative_humidity_percent: float = Field(..., description="Relative humidity in surface boundary layer")
    surface_wind_speed_kmh: float = Field(..., description="10m surface wind speed")
    radiation_inversion_intensity: str = Field(..., description="Thermal nocturnal inversion assessment")
    fog_type: str = Field(..., description="Radiation Fog, Advection Fog, or Nil")
    formation_onset_time: str = Field(..., description="Expected fog formation onset window (e.g. 02:30 IST)")
    dissipation_expected_time: str = Field(..., description="Solar thermal convective lifting window (e.g. 10:00 IST)")


class CorridorStation(BaseModel):
    station_id: str = Field(..., description="IMD / WMO Station ID")
    station_name: str = Field(..., description="City or observatory name")
    state: str = Field(..., description="Indian State / Union Territory")
    latitude: float
    longitude: float
    visibility_meters: int
    visibility_tier: VisibilityTier
    rvr_category: RvrCategory
    is_airport: bool = True
    distance_km: Optional[float] = None


class FogNowcastResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    location_name: str
    latitude: float
    longitude: float
    visibility_meters: int
    visibility_tier: VisibilityTier
    severity_color_hex: str = Field("#38A169", description="Color code matching visibility level")
    rvr_status: RvrCategory
    rvr_alert_summary: str
    physics: FogPhysicsMetrics
    highway_advisory: HighwaySafetyAdvisory
    railway_fogpass: RailwayFogPassTelemetry
    corridor_stations: List[CorridorStation]
    vernacular_advisories: Dict[str, str] = Field(default_factory=dict)
    source_provenance: str = Field(
        default="IMD Winter Fog Experiment (WiFEX) & MoRTH / NHAI Highway Safety Protocol"
    )
    generated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
