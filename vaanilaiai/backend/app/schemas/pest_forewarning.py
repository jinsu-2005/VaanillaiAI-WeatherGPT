from typing import List, Optional, Dict
from enum import Enum
from pydantic import BaseModel, Field


class PestRiskLevel(str, Enum):
    LOW = "LOW"
    MODERATE = "MODERATE"
    HIGH = "HIGH"
    CRITICAL = "CRITICAL"


class EpidemicCondition(str, Enum):
    FAVORABLE = "FAVORABLE"
    MARGINAL = "MARGINAL"
    UNFAVORABLE = "UNFAVORABLE"


class CausalAgentType(str, Enum):
    FUNGAL = "FUNGAL"
    INSECT_VECTOR = "INSECT_VECTOR"
    BACTERIAL = "BACTERIAL"
    VIRAL = "VIRAL"


class MicroclimateTelemetry(BaseModel):
    temperature_c: float = Field(..., description="Observed/forecast mean temperature in °C")
    relative_humidity_pct: float = Field(..., description="Surface relative humidity percentage")
    leaf_wetness_hours: float = Field(..., description="Estimated consecutive hours of dew / canopy leaf wetness")
    cloud_cover_oktas: int = Field(..., description="Cloudiness in oktas (0=clear, 8=overcast)")
    growing_degree_days_base5: float = Field(..., description="Thermal accumulation in GDD above base 5°C")
    consecutive_favorable_days: int = Field(..., description="Number of consecutive days satisfying infection criteria")


class PestDiseaseAlertItem(BaseModel):
    id: str = Field(..., description="Unique alert identifier")
    name: str = Field(..., description="Common disease or pest name (e.g. Potato Late Blight)")
    scientific_name: str = Field(..., description="Taxonomic binomial nomenclature (e.g. Phytophthora infestans)")
    target_crop: str = Field(..., description="Primary economic host crop")
    causal_agent: CausalAgentType = Field(..., description="Category of pathogen or pest")
    risk_level: PestRiskLevel = Field(..., description="Current epidemiological risk rating")
    epidemic_condition: EpidemicCondition = Field(..., description="Favorable weather status")
    favorable_microclimate_rule: str = Field(..., description="Specific physical criteria (e.g. RH >= 90% for >= 10h, Temp 10-24°C)")
    economic_threshold_level: str = Field(..., description="Official ICAR Economic Threshold Level (ETL) triggering intervention")
    pre_symptomatic_forewarning: str = Field(..., description="Early warning forecast before visible field symptoms appear")
    organic_biocontrol_directive: str = Field(..., description="Eco-friendly biological control protocol (NSKE, Trichoderma, Pseudomonas)")
    chemical_emergency_directive: str = Field(..., description="Targeted fungicidal / systemic pesticide spray directive if ETL is crossed")


class AgroClimaticZoneInfo(BaseModel):
    zone_id: int = Field(..., description="Official ICAR / Planning Commission zone number (1-15)")
    zone_name: str = Field(..., description="Zone geographical designation (e.g. Upper Gangetic Plains Region)")
    key_states: List[str] = Field(..., description="States and Union Territories encompassing this zone")
    dominant_crops: List[str] = Field(..., description="Principal Kharif and Rabi crops cultivated in this zone")
    typical_pest_threats: List[str] = Field(..., description="Major historically prevalent agro-pathogens")


class PestForewarningResponse(BaseModel):
    zone: AgroClimaticZoneInfo = Field(..., description="Resolved Agro-Climatic Zone metadata")
    location_name: str = Field(..., description="Observer geocoded or selected station location")
    latitude: float = Field(..., description="Latitude")
    longitude: float = Field(..., description="Longitude")
    timestamp: str = Field(..., description="Bulletin issuance timestamp in ISO-8601")
    highest_risk_level: PestRiskLevel = Field(..., description="Peak epidemic severity among tracked pests")
    summary_headline: str = Field(..., description="Executive crop protection headline")
    telemetry: MicroclimateTelemetry = Field(..., description="Current microclimate and leaf wetness telemetry")
    alerts: List[PestDiseaseAlertItem] = Field(..., description="Detailed disease and insect vector early warning items")
    ipm_calendar_actions: List[str] = Field(..., description="Weekly preventative Integrated Pest Management (IPM) measures")
    multilingual_bulletins: Dict[str, str] = Field(..., description="Bilingual farmer directives keyed by language code")
    all_zones: List[AgroClimaticZoneInfo] = Field(..., description="Directory of India's 15 Agro-Climatic Zones")
    provenance_disclaimer: str = Field(
        default="Epidemiological models calibrated from ICAR-NCIPM & IMD Gramin Krishi Mausam Seva (GKMS) Agromet Advisory Guidelines. Zero synthetic fabrication.",
        description="Official operational provenance statement"
    )
