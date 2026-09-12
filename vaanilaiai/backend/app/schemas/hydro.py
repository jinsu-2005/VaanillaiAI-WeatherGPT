"""Pydantic schemas for Central Water Commission (CWC) River Basin Flood Early Warning & Dam Reservoir Hydro-Telemetry."""
from typing import List, Optional, Dict
from pydantic import BaseModel, Field


class RiverGaugeStation(BaseModel):
    station_code: str
    name: str
    river: str
    basin: str
    state: str
    latitude: float
    longitude: float
    current_level_m: float
    warning_level_m: float
    danger_level_m: float
    highest_flood_level_m: float
    trend: str = "Steady"  # Rising, Steady, Falling
    flood_stage: str = "Normal"  # Normal, Warning, Danger, Extreme
    distance_km: Optional[float] = None


class DamReservoirStatus(BaseModel):
    reservoir_code: str
    name: str
    river: str
    basin: str
    state: str
    latitude: float
    longitude: float
    full_reservoir_level_m: float
    current_level_m: float
    live_storage_capacity_tmc: float
    current_storage_tmc: float
    storage_percent: float
    inflow_cusecs: float
    outflow_cusecs: float
    spillway_gates_open: int = 0
    spillway_status: str = "Closed"  # Closed, Controlled Discharge, Heavy Inflow Spillage
    downstream_alert: str = "Normal operational discharge. No riparian flood threat."
    distance_km: Optional[float] = None


class RiverBasinSummary(BaseModel):
    basin_name: str
    major_rivers: List[str] = []
    total_stations: int = 0
    stations_in_danger: int = 0
    stations_in_warning: int = 0
    high_capacity_dams_count: int = 0
    synoptic_flood_risk: str = "Low"  # Low, Moderate, High, Severe


class CwcHydroOverviewResponse(BaseModel):
    latitude: float
    longitude: float
    location_name: str
    selected_basin: str
    available_basins: List[str] = []
    nearest_gauge_station: Optional[RiverGaugeStation] = None
    nearest_reservoir: Optional[DamReservoirStatus] = None
    basin_summary: RiverBasinSummary
    gauge_stations: List[RiverGaugeStation] = []
    reservoirs: List[DamReservoirStatus] = []
    downstream_directives: List[str] = []
    vernacular_riparian_alerts: Dict[str, str] = Field(default_factory=dict)
    provenance_authority: str = "Central Water Commission (CWC) & Ministry of Jal Shakti Hydro-Telemetry"
    last_updated: str
