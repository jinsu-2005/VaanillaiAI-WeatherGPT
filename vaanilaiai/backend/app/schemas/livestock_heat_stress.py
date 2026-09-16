from enum import Enum
from typing import List, Dict, Optional
from pydantic import BaseModel, Field


class LivestockStressTier(str, Enum):
    NORMAL_COMFORT = "NORMAL_COMFORT"          # THI < 72: Optimal rumination & full milk potential
    MILD_STRESS = "MILD_STRESS"                # THI 72 - 78: Elevated respiration, mild intake reduction (5-10%)
    MODERATE_STRESS = "MODERATE_STRESS"        # THI 79 - 88: Open-mouth panting, salivation, milk drop 15-25%
    SEVERE_EMERGENCY = "SEVERE_EMERGENCY"      # THI > 88: Heat prostration, recumbency, high mortality risk


class AnimalSpeciesBreedCategory(str, Enum):
    MURRAH_WATER_BUFFALO = "MURRAH_WATER_BUFFALO"          # Dark skin, low sweat gland density, requires wallowing
    CROSSBRED_HF_JERSEY = "CROSSBRED_HF_JERSEY"            # High metabolic heat from high yield, lowest heat tolerance
    INDIGENOUS_ZEBU_CATTLE = "INDIGENOUS_ZEBU_CATTLE"      # Gir, Sahiwal, Kankrej, Ongole: high heat tolerance
    INDIGENOUS_SMALL_RUMINANTS = "INDIGENOUS_SMALL_RUMINANTS"  # Goats and sheep


class MicroclimateBiometeorology(BaseModel):
    dry_bulb_temperature_c: float = Field(..., description="Ambient air temperature (Tdb) in Celsius")
    relative_humidity_pct: float = Field(..., description="Ambient relative humidity (RH) in percentage")
    dew_point_temperature_c: float = Field(..., description="Calculated dew point temperature in Celsius")
    wind_speed_ms: float = Field(..., description="Airflow velocity inside or outside animal shed in m/s")
    solar_radiation_wm2: float = Field(..., description="Incident solar irradiance in W/m2")
    temperature_humidity_index_thi: float = Field(..., description="Calculated Thom/NRC Temperature-Humidity Index")
    black_globe_humidity_index_bgthi: float = Field(..., description="Black Globe Humidity Index incorporating radiant heat")


class SpeciesVulnerabilityProfile(BaseModel):
    species_category: AnimalSpeciesBreedCategory = Field(..., description="Livestock category")
    breed_name: str = Field(..., description="Specific prominent breed name")
    respiration_rate_bpm: int = Field(..., description="Respiration rate in breaths per minute (normal 20-30)")
    rectal_temperature_c: float = Field(..., description="Estimated core body temperature in Celsius (normal ~38.5°C)")
    estimated_milk_yield_drop_pct: float = Field(..., description="Projected daily milk production decline percentage")
    dry_matter_intake_reduction_pct: float = Field(..., description="Percentage reduction in feed dry matter consumption")
    conception_rate_penalty_pct: float = Field(..., description="Estimated depression in artificial insemination conception rate")


class FarmShelterAndNutritionDirectives(BaseModel):
    shed_cooling_protocol: str = Field(..., description="Specific micro-misting, fogger, and ceiling fan operation schedule")
    wallowing_pond_recommendation: str = Field(..., description="Wallowing and water soaking protocol for water buffaloes")
    water_requirement_liters_per_animal: float = Field(..., description="Daily potable water requirement per milch animal in liters")
    dietary_ration_adjustment: str = Field(..., description="Nutritional buffering, night-time feeding, and bypass fat directives")
    grazing_curfew_hours: str = Field(..., description="Restricted daytime hours prohibiting open-sun grazing")
    veterinary_emergency_signs: List[str] = Field(..., description="Warning symptoms requiring immediate veterinary intervention")


class DairyCorridorBasin(BaseModel):
    basin_id: str = Field(..., description="Unique slug for dairy production basin")
    basin_name: str = Field(..., description="Public geographic name of dairy corridor")
    state: str = Field(..., description="State or Union Territory")
    prominent_dairy_cluster: str = Field(..., description="Associated dairy cooperative federation or research hub")
    latitude: float = Field(..., description="Representative centroid latitude")
    longitude: float = Field(..., description="Representative centroid longitude")
    stress_tier: LivestockStressTier = Field(..., description="Current bio-meteorological thermal stress level")
    microclimate: MicroclimateBiometeorology = Field(..., description="Calculated microclimate and THI indices")
    species_profiles: List[SpeciesVulnerabilityProfile] = Field(..., description="Impact breakdown across dairy animal breeds")
    directives: FarmShelterAndNutritionDirectives = Field(..., description="Veterinary management and feeding directives")
    vernacular_bulletins: Dict[str, str] = Field(..., description="Multilingual livestock bulletins in regional languages")


class LivestockHeatStressResponse(BaseModel):
    timestamp: str = Field(..., description="ISO 8601 generation timestamp")
    bulletin_number: str = Field(..., description="Official ICAR-NDRI & IMD advisory bulletin identifier")
    provenance: str = Field(..., description="Institutional source (ICAR-NDRI & IMD Livestock Weather Division)")
    national_pastoral_summary: str = Field(..., description="Synoptic overview of dairy heat stress across Indian agro-climatic zones")
    selected_basin: DairyCorridorBasin = Field(..., description="Target evaluated dairy corridor")
    all_basins: List[DairyCorridorBasin] = Field(..., description="Catalog of monitored Indian dairy production basins")
    bioclimatic_model: str = Field(..., description="Thermal bioclimatic index formula and references")
    vernacular_bulletins: Dict[str, str] = Field(..., description="Multilingual emergency veterinary advisory bulletins")
    is_offline_cached: bool = Field(default=False, description="Whether response originated from offline cache")
