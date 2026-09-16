from enum import Enum
from typing import List, Dict, Optional
from pydantic import BaseModel, Field


class TsunamiAlertTier(str, Enum):
    WARNING_RED = "WARNING_RED"          # Evacuate coastal areas immediately to elevated ground
    ALERT_ORANGE = "ALERT_ORANGE"        # High wave threat, vessels move to deep sea, avoid beaches
    WATCH_YELLOW = "WATCH_YELLOW"        # Low wave threat, ports and fishermen standby, monitor gauges
    THREAT_PASSED_GREEN = "THREAT_PASSED_GREEN"  # All clear issued by INCOIS


class TsunamigenicSubductionZone(str, Enum):
    ANDAMAN_SUMATRA_TRENCH = "ANDAMAN_SUMATRA_TRENCH"
    MAKRAN_SUBDUCTION_ZONE = "MAKRAN_SUBDUCTION_ZONE"
    SUNDA_JAVA_TRENCH = "SUNDA_JAVA_TRENCH"
    CHAGOS_LACCADIVE_RIDGE = "CHAGOS_LACCADIVE_RIDGE"


class SeismicSourceParameters(BaseModel):
    moment_magnitude_mw: float = Field(..., description="Moment magnitude of tsunamigenic earthquake (Mw)")
    focal_depth_km: float = Field(..., description="Earthquake hypocentral depth in km (shallow <60km tsunamigenic)")
    epicenter_latitude: float = Field(..., description="Epicenter latitude coordinate")
    epicenter_longitude: float = Field(..., description="Epicenter longitude coordinate")
    origin_time_utc: str = Field(..., description="Earthquake origin time in UTC ISO 8601")
    subduction_zone: TsunamigenicSubductionZone = Field(..., description="Geotectonic subduction trench origin")
    rupture_mechanism: str = Field(..., description="Fault rupture mechanism (e.g. Reverse Thrust, Strike-Slip)")


class DeepOceanDartBuoy(BaseModel):
    buoy_id: str = Field(..., description="Bottom Pressure Recorder / DART buoy identifier (e.g. BPR-TB01)")
    sea_basin: str = Field(..., description="Ocean basin location (Bay of Bengal / Arabian Sea / Andaman Sea)")
    latitude: float = Field(..., description="Moored buoy latitude")
    longitude: float = Field(..., description="Moored buoy longitude")
    water_depth_m: float = Field(..., description="Deep ocean mooring water depth in meters")
    pressure_anomaly_hpa: float = Field(..., description="Hydrostatic bottom pressure fluctuation in hPa")
    deep_ocean_wave_amplitude_cm: float = Field(..., description="Detected deep sea tsunami wave amplitude in centimeters")
    is_event_mode_triggered: bool = Field(..., description="Whether acoustic tsunameter has switched to 15-second high-rate telemetry")


class CoastalTideGaugeTelemetry(BaseModel):
    station_id: str = Field(..., description="INCOIS / Survey of India tide gauge station code")
    station_name: str = Field(..., description="Coastal port / island station name")
    observed_sea_level_m: float = Field(..., description="Total observed instantaneous sea level in meters")
    astronomical_tide_m: float = Field(..., description="Astronomical predicted tide level in meters")
    tsunami_residual_amplitude_m: float = Field(..., description="Tsunami sea surface height residual (Observed - Predicted) in meters")
    last_sample_time_utc: str = Field(..., description="Timestamp of latest gauge telemetry")


class CoastalTsunamiWaveMetrics(BaseModel):
    estimated_time_of_arrival_eta: str = Field(..., description="Estimated arrival time of first tsunami wave")
    time_to_first_wave_minutes: int = Field(..., description="Countdown minutes remaining until initial wave arrival")
    maximum_expected_wave_amplitude_m: float = Field(..., description="Expected peak crest-to-trough tsunami wave height at shore")
    deep_water_propagation_speed_kmh: float = Field(..., description="Deep ocean shallow-water wave speed c = sqrt(g*h) in km/h")
    estimated_inundation_distance_m: float = Field(..., description="Estimated horizontal coastal land penetration distance in meters")
    shoaling_amplification_factor: float = Field(..., description="Green's law shoaling wave height amplification ratio")


class EvacuationAndMaritimeDirectives(BaseModel):
    vertical_evacuation_altitude_m: float = Field(..., description="Recommended minimum vertical elevation above MSL (e.g. 15m)")
    horizontal_evacuation_distance_km: float = Field(..., description="Recommended minimum horizontal distance from coastline in km")
    deep_sea_vessel_directive: str = Field(..., description="Instruction for ships and fishing trawlers in harbors vs deep water")
    coastal_siren_network_status: str = Field(..., description="Status of NDMA / State coastal emergency siren warning network")
    port_cargo_operations_status: str = Field(..., description="Operational status of port gantry cranes, jetties, and berths")
    designated_safe_shelter_locations: List[str] = Field(..., description="Pre-identified multi-hazard cyclone/tsunami cyclone shelters")


class CoastalForecastSector(BaseModel):
    sector_id: str = Field(..., description="Unique slug for coastal administrative sector")
    sector_name: str = Field(..., description="Public name of coastal region")
    state: str = Field(..., description="State or Union Territory")
    key_coastal_nodes: List[str] = Field(..., description="Key coastal cities, ports, and islands included")
    latitude: float = Field(..., description="Representative centroid latitude")
    longitude: float = Field(..., description="Representative centroid longitude")
    alert_tier: TsunamiAlertTier = Field(..., description="INCOIS ITEWS tsunami alert tier")
    seismic_source: SeismicSourceParameters = Field(..., description="Primary tsunamigenic earthquake parameters")
    wave_metrics: CoastalTsunamiWaveMetrics = Field(..., description="Tsunami wave arrival, amplitude, and inundation calculations")
    dart_buoys: List[DeepOceanDartBuoy] = Field(..., description="Telemetry from offshore bottom pressure recorder buoys")
    tide_gauges: List[CoastalTideGaugeTelemetry] = Field(..., description="Telemetry from coastal radar tide gauge stations")
    evacuation_directives: EvacuationAndMaritimeDirectives = Field(..., description="Civil defense and maritime safety guidelines")
    localized_bulletins: Dict[str, str] = Field(..., description="Multilingual emergency bulletins (EN, HI, TA, TE, ML, BN, OR)")


class TsunamiWarningResponse(BaseModel):
    timestamp: str = Field(..., description="ISO 8601 generation timestamp")
    bulletin_number: str = Field(..., description="Official INCOIS ITEWS tsunami bulletin identifier")
    provenance: str = Field(..., description="Institutional provenance (INCOIS / MoES / NDMA ITEWS)")
    threat_status: str = Field(..., description="Overall national Indian Ocean tsunami alert status")
    selected_sector: CoastalForecastSector = Field(..., description="Target evaluated coastal sector")
    all_sectors: List[CoastalForecastSector] = Field(..., description="Catalog of monitored Indian Ocean coastal sectors")
    vernacular_bulletins: Dict[str, str] = Field(..., description="Multilingual coastal emergency broadcasts")
    is_offline_cached: bool = Field(default=False, description="Whether response originated from offline cache")
