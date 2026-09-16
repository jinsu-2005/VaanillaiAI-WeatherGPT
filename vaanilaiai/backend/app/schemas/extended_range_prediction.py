from enum import Enum
from typing import Dict, List, Optional
from pydantic import BaseModel, Field


class MonsoonSpellState(str, Enum):
    ACTIVE_SURGE = "ACTIVE_SURGE"                      # Vigorous monsoon, trough south of normal, heavy widespread rain
    NORMAL_MONSOON = "NORMAL_MONSOON"                  # Normal seasonal rainfall, balanced distribution
    WEAK_MONSOON = "WEAK_MONSOON"                      # Subdued rainfall, weak southwesterly flow
    BREAK_MONSOON_CRITICAL = "BREAK_MONSOON_CRITICAL"  # Trough at Himalayan foothills, rain deficit in plains, flood in hills
    POST_BREAK_REVIVAL = "POST_BREAK_REVIVAL"          # Convective pulse reviving from Bay of Bengal / south


class BsisoMode(str, Enum):
    BSISO_1_CANONICAL_30_60D = "BSISO_1_CANONICAL_30_60D"        # Canonical 30-60 day intra-seasonal northward propagation
    BSISO_2_QUASI_BIWEEKLY_10_20D = "BSISO_2_QUASI_BIWEEKLY_10_20D"  # Quasi-biweekly 10-20 day mode associated with monsoon depressions


class MjoConvectivePhase(str, Enum):
    PHASE_1_WESTERN_HEMISPHERE = "PHASE_1_WESTERN_HEMISPHERE"
    PHASE_2_INDIAN_OCEAN_DEVELOPING = "PHASE_2_INDIAN_OCEAN_DEVELOPING"  # Enhanced convection in western Indian Ocean
    PHASE_3_INDIAN_OCEAN_ACTIVE = "PHASE_3_INDIAN_OCEAN_ACTIVE"          # Peak convection across central/eastern Indian Ocean
    PHASE_4_MARITIME_CONTINENT_WEST = "PHASE_4_MARITIME_CONTINENT_WEST"
    PHASE_5_MARITIME_CONTINENT_EAST = "PHASE_5_MARITIME_CONTINENT_EAST"
    PHASE_6_WESTERN_PACIFIC = "PHASE_6_WESTERN_PACIFIC"                  # Suppressed over Indian Ocean
    PHASE_7_CENTRAL_PACIFIC = "PHASE_7_CENTRAL_PACIFIC"                  # Strongly suppressed over Indian Ocean
    PHASE_8_EAST_PACIFIC = "PHASE_8_EAST_PACIFIC"                        # Trough shifted northward


class RainfallDepartureTier(str, Enum):
    LARGE_EXCESS = "LARGE_EXCESS"        # >= +60% departure from LPA
    EXCESS = "EXCESS"                    # +20% to +59% departure from LPA
    NORMAL = "NORMAL"                    # -19% to +19% departure from LPA
    DEFICIENT = "DEFICIENT"              # -59% to -20% departure from LPA
    LARGE_DEFICIENT = "LARGE_DEFICIENT"  # <= -60% departure from LPA
    NO_RAIN = "NO_RAIN"                  # -100% departure from LPA


class AgriculturalStressLevel(str, Enum):
    NONE_OPTIMAL = "NONE_OPTIMAL"
    WATCH_SLIGHT_MOISTURE_STRESS = "WATCH_SLIGHT_MOISTURE_STRESS"
    WARNING_PROLONGED_DRY_SPELL = "WARNING_PROLONGED_DRY_SPELL"
    ALERT_CRITICAL_CONTINGENCY = "ALERT_CRITICAL_CONTINGENCY"


class WeeklyErpForecast(BaseModel):
    week_number: int = Field(..., ge=1, le=4, description="Forecast week (Week 1 to 4)")
    date_range_label: str = Field(..., description="Calendar interval label (e.g. Days 1–7: 12–18 Sep)")
    rainfall_lpa_departure_pct: float = Field(..., description="Rainfall departure as percentage from Long Period Average (LPA)")
    departure_tier: RainfallDepartureTier = Field(..., description="IMD rainfall departure classification tier")
    rainfall_forecast_mm: float = Field(..., ge=0.0, description="Predicted cumulative rainfall for the week in mm")
    normal_lpa_rainfall_mm: float = Field(..., ge=0.0, description="Climatological normal LPA rainfall in mm")
    max_temp_anomaly_c: float = Field(..., description="Weekly mean maximum temperature anomaly in °C")
    min_temp_anomaly_c: float = Field(..., description="Weekly mean minimum temperature anomaly in °C")
    heatwave_coldwave_probability_pct: float = Field(..., ge=0.0, le=100.0, description="Probability of extreme heatwave or coldwave")
    monsoon_spell_state: MonsoonSpellState = Field(..., description="Predominant monsoon spell state for the week")


class IntraSeasonalPulseTelemetry(BaseModel):
    bsiso_mode: BsisoMode = Field(..., description="Dominant Boreal Summer Intra-Seasonal Oscillation mode")
    bsiso_active_phase: int = Field(..., ge=1, le=8, description="Current BSISO phase (1 to 8)")
    bsiso_amplitude: float = Field(..., ge=0.0, description="BSISO amplitude index (>1.0 indicates strong active pulse)")
    northward_propagation_speed_deg_per_day: float = Field(..., description="Northward propagation speed in degrees latitude per day")
    mjo_phase: MjoConvectivePhase = Field(..., description="Equatorial Madden-Julian Oscillation convective phase")
    mjo_amplitude: float = Field(..., ge=0.0, description="Wheeler-Hendon MJO amplitude index")
    findlater_jet_speed_kt: float = Field(..., description="Low-level Somali/Findlater cross-equatorial jet speed in knots at 850 hPa")
    monsoon_trough_position_latitude: float = Field(..., description="Latitudinal axis of monsoon trough in degrees North")
    break_spell_risk: bool = Field(..., description="True if atmospheric dynamics favor severe break monsoon development")


class IcarDistrictContingency(BaseModel):
    stress_level: AgriculturalStressLevel = Field(..., description="Evaluated crop water stress level")
    sowing_window_status: str = Field(..., description="Agromet status of the kharif/rabi sowing window")
    contingency_crop_alternatives: List[str] = Field(..., description="Recommended alternative short-duration or drought-hardy crops")
    irrigation_mitigation_directive: str = Field(..., description="Life-saving irrigation guidance from farm ponds / Amrit Sarovars")
    in_situ_moisture_conservation: str = Field(..., description="On-farm soil moisture preservation practice (BBF, mulching, ridge-furrow)")
    standing_crop_intervention: str = Field(..., description="Protective foliar sprays, dust mulching or population thinning advice")


class ErpZone(BaseModel):
    zone_id: str = Field(..., description="Unique slug for the agro-climatic sub-divisional zone")
    zone_name: str = Field(..., description="Representative agro-climatic zone title")
    state: str = Field(..., description="Associated Indian State or Region")
    sub_division_name: str = Field(..., description="Official IMD Meteorological Sub-Division")
    latitude: float = Field(..., description="Representative centroid latitude")
    longitude: float = Field(..., description="Representative centroid longitude")
    dominant_crops: List[str] = Field(..., description="Principal agricultural crops grown in the zone")
    four_week_forecast: List[WeeklyErpForecast] = Field(..., description="4-week sequential MME extended range prediction")
    intra_seasonal_pulse: IntraSeasonalPulseTelemetry = Field(..., description="Intra-seasonal oscillation dynamics (BSISO/MJO)")
    agricultural_contingency: IcarDistrictContingency = Field(..., description="ICAR-CRIDA district contingency directives")
    vernacular_bulletins: Dict[str, str] = Field(..., description="Multilingual agro-meteorological bulletins")


class ErpZoneSummary(BaseModel):
    zone_id: str
    zone_name: str
    state: str
    sub_division_name: str
    current_monsoon_spell: MonsoonSpellState
    week1_departure_pct: float
    week2_departure_pct: float
    contingency_alert_active: bool


class ErpResponse(BaseModel):
    zone_id: str
    zone_name: str
    state: str
    current_zone: ErpZone
    all_zones: List[ErpZoneSummary]
    mme_model_consensus_pct: float = Field(..., description="Consensus percentage between IITM CFSv2 and NCMRWF NCUM-ER")
    last_updated_utc: str
    data_source: str
