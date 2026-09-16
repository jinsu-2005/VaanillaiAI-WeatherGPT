from typing import List, Optional, Dict
from enum import Enum
from pydantic import BaseModel, Field


class ColdWaveSeverity(str, Enum):
    NONE = "NONE"
    COLD_DAY = "COLD_DAY"
    COLD_WAVE = "COLD_WAVE"
    SEVERE_COLD_WAVE = "SEVERE_COLD_WAVE"


class GroundFrostRisk(str, Enum):
    NONE = "NONE"
    LIGHT = "LIGHT"
    MODERATE = "MODERATE"
    SEVERE = "SEVERE"


class HypothermiaRisk(str, Enum):
    LOW = "LOW"
    ELEVATED = "ELEVATED"
    HIGH = "HIGH"
    EXTREME = "EXTREME"


class CropVulnerabilityItem(BaseModel):
    crop_name: str = Field(..., description="Name of the Rabi crop (e.g. Mustard, Potato, Wheat)")
    critical_stage: str = Field(..., description="Current physiological stage (e.g. Siliqua formation, Flowering)")
    injury_mechanism: str = Field(..., description="Physiological freeze injury mechanism")
    yield_loss_risk_pct: int = Field(..., description="Estimated potential yield loss percentage without mitigation")
    countermeasures: List[str] = Field(..., description="Field-level agronomic countermeasures (irrigation, smudge, chemical)")


class NocturnalCoolingPhysics(BaseModel):
    t_air_min: float = Field(..., description="Stevenson screen minimum air temperature in °C at 1.5m")
    t_normal_min: float = Field(..., description="Climatological normal minimum temperature in °C")
    departure_c: float = Field(..., description="Departure from climatological normal in °C")
    t_grass_min: float = Field(..., description="Grass minimum temperature at 5cm height in °C")
    sky_cover_oktas: int = Field(..., description="Nocturnal cloud cover in oktas (0=clear, 8=overcast)")
    wind_speed_kmh: float = Field(..., description="Surface wind speed in km/h")
    dew_point_c: float = Field(..., description="Surface dew-point temperature in °C")
    wind_chill_c: float = Field(..., description="Wind chill equivalent temperature in °C")
    net_radiation_loss_wm2: float = Field(..., description="Nocturnal net terrestrial radiation loss in W/m²")


class UrbanShelterAdvisory(BaseModel):
    night_shelter_activated: bool = Field(..., description="Whether municipal Rain Basera / night shelter protocol is active")
    hypothermia_risk: HypothermiaRisk = Field(..., description="Risk of hypothermia for unsheltered populations")
    recommended_clothing_layers: int = Field(..., description="Recommended insulating clothing layers for outdoor activity")
    livestock_protection_rules: List[str] = Field(..., description="Animal husbandry shelter and cold stress mitigation directives")


class ColdwaveStation(BaseModel):
    station_id: str = Field(..., description="Observatory WMO/IMD identifier")
    station_name: str = Field(..., description="Station or district name")
    state: str = Field(..., description="Indian State or Union Territory")
    latitude: float = Field(..., description="Station latitude")
    longitude: float = Field(..., description="Station longitude")
    elevation_m: float = Field(..., description="Elevation above mean sea level in meters")
    is_hill_station: bool = Field(..., description="True if station elevation >= 1000m or designated hill station")
    t_min: float = Field(..., description="Observed/nowcast minimum temperature in °C")
    t_grass: float = Field(..., description="Grass minimum temperature in °C")
    cold_wave_severity: ColdWaveSeverity = Field(..., description="Current cold wave classification")
    frost_risk: GroundFrostRisk = Field(..., description="Ground frost risk rating")


class ColdWaveResponse(BaseModel):
    station_id: str = Field(..., description="Selected observatory identifier")
    station_name: str = Field(..., description="Observatory location name")
    state: str = Field(..., description="State or Union Territory")
    latitude: float = Field(..., description="Latitude")
    longitude: float = Field(..., description="Longitude")
    elevation_m: float = Field(..., description="Station elevation in meters")
    is_hill_station: bool = Field(..., description="Whether hill station criteria apply")
    timestamp: str = Field(..., description="Assessment issuance timestamp in ISO-8601")
    
    # Severity Classifications
    cold_wave_severity: ColdWaveSeverity = Field(..., description="IMD Cold Wave classification")
    ground_frost_risk: GroundFrostRisk = Field(..., description="Ground frost formation risk")
    summary_headline: str = Field(..., description="Executive summary of cold conditions")
    
    # Physics & Micro-climate Telemetry
    physics: NocturnalCoolingPhysics = Field(..., description="Detailed boundary layer thermal radiation metrics")
    
    # Agronomic Vulnerability
    rabi_crop_advisories: List[CropVulnerabilityItem] = Field(..., description="Crop-by-crop damage risk and mitigation protocols")
    
    # Social & Urban Directives
    urban_shelter: UrbanShelterAdvisory = Field(..., description="Urban night shelter and public health guidance")
    
    # Multilingual Vernacular Directives
    multilingual_bulletins: Dict[str, str] = Field(..., description="Bilingual emergency advisories keyed by language code")
    
    # Corridor Hubs
    monitoring_stations: List[ColdwaveStation] = Field(..., description="Network of active northern belt cold monitoring stations")
    
    # Provenance
    provenance_disclaimer: str = Field(
        default="Official criteria derived from IMD Severe Weather Warning Guidelines & ICAR-CRIDA Rabi Crop Agro-Advisory Directives. Zero synthetic fabrication.",
        description="Official operational provenance citation"
    )
