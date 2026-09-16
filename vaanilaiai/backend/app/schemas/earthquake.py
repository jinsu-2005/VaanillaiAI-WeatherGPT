from enum import Enum
from typing import List, Dict, Optional
from pydantic import BaseModel, Field


class SeismicAlertTier(str, Enum):
    RED_DEVASTATING = "RED_DEVASTATING"       # M ≥ 7.0: Widespread collapse, aftershock sequence imminent
    ORANGE_DAMAGING = "ORANGE_DAMAGING"       # M 6.0 - 6.9: Significant structural damage, felt across hundreds of km
    YELLOW_MODERATE = "YELLOW_MODERATE"       # M 5.0 - 5.9: Non-structural damage, furniture displacement
    GREEN_LIGHT = "GREEN_LIGHT"               # M < 5.0: Widely felt but minor or no damage


class BisSeismicZone(str, Enum):
    ZONE_V = "ZONE_V"       # Very High Seismicity (IS:1893 PGA ≥ 0.36g) - NE India, J&K, Andaman
    ZONE_IV = "ZONE_IV"     # High Seismicity (PGA 0.24g) - NCR, Uttarakhand, Bihar, parts of Gujarat
    ZONE_III = "ZONE_III"   # Moderate Seismicity (PGA 0.16g) - Deccan margins, Central India
    ZONE_II = "ZONE_II"     # Low Seismicity (PGA 0.10g) - Stable interior Peninsular Shield


class FaultMechanism(str, Enum):
    REVERSE_THRUST = "REVERSE_THRUST"
    STRIKE_SLIP = "STRIKE_SLIP"
    NORMAL = "NORMAL"
    OBLIQUE = "OBLIQUE"


class EarthquakeSourceParameters(BaseModel):
    moment_magnitude_mw: float = Field(..., description="Moment magnitude (Mw) of the seismic event")
    local_magnitude_ml: float = Field(..., description="Richter local magnitude (ML) of the event")
    focal_depth_km: float = Field(..., description="Hypocentral depth in km (shallow <70km, intermediate 70-300, deep >300)")
    epicenter_latitude: float = Field(..., description="Epicenter latitude coordinate")
    epicenter_longitude: float = Field(..., description="Epicenter longitude coordinate")
    origin_time_utc: str = Field(..., description="Earthquake origin time in UTC ISO 8601")
    fault_mechanism: FaultMechanism = Field(..., description="Focal mechanism type (Reverse, Strike-Slip, Normal, Oblique)")
    fault_plane_strike_deg: float = Field(..., description="Strike azimuth of the rupture fault plane in degrees")
    rupture_length_km: float = Field(..., description="Estimated rupture length along fault in km")


class ModifiedMercalliIntensity(BaseModel):
    epicentral_mmi: str = Field(..., description="MMI intensity at epicenter (I-XII Roman numeral scale)")
    felt_radius_km: float = Field(..., description="Estimated macroseismic felt radius in km")
    perceived_shaking: str = Field(..., description="Qualitative shaking descriptor (e.g., Violent, Very Strong, Strong)")
    potential_damage: str = Field(..., description="Expected structural damage level")
    did_you_feel_it_reports: int = Field(..., description="Number of citizen felt reports (DYFI equivalent)")


class AftershockProbability(BaseModel):
    bath_law_largest_aftershock_mw: float = Field(..., description="Båth's Law predicted largest aftershock magnitude (Mw_main - 1.2)")
    modified_omori_p_value: float = Field(..., description="Modified Omori Law temporal decay exponent (p ≈ 1.0-1.3)")
    reasenberg_jones_24h_probability_pct: float = Field(..., description="Reasenberg-Jones 24-hour aftershock probability (M≥5)")
    expected_aftershocks_7_day: int = Field(..., description="Expected number of aftershocks ≥ M3 in next 7 days")
    coulomb_stress_transfer_direction: str = Field(..., description="Direction of static Coulomb stress transfer favoring triggered events")


class StructuralVulnerabilityDirectives(BaseModel):
    bis_seismic_zone: BisSeismicZone = Field(..., description="BIS IS:1893 seismic hazard zone classification")
    design_pga_g: float = Field(..., description="Design Peak Ground Acceleration in g for IS:1893 compliance")
    building_vulnerability_class: str = Field(..., description="NDMA building vulnerability classification (A-D)")
    post_quake_inspection_priority: str = Field(..., description="Structural inspection priority (Immediate/Within 24h/Routine)")
    soft_story_collapse_risk: str = Field(..., description="Soft-story stilt parking collapse risk assessment")
    masonry_infill_damage_risk: str = Field(..., description="URM (unreinforced masonry) infill wall out-of-plane failure risk")
    ndma_dos: List[str] = Field(..., description="NDMA earthquake safety DOs during and after shaking")
    ndma_donts: List[str] = Field(..., description="NDMA earthquake safety DON'Ts during and after shaking")


class SeismotectonicProvince(BaseModel):
    province_id: str = Field(..., description="Unique slug for seismotectonic province")
    province_name: str = Field(..., description="Public geological province name")
    state: str = Field(..., description="State or Union Territory")
    dominant_fault_system: str = Field(..., description="Major geological fault or plate boundary")
    latitude: float = Field(..., description="Representative centroid latitude")
    longitude: float = Field(..., description="Representative centroid longitude")
    alert_tier: SeismicAlertTier = Field(..., description="Current seismic alert tier")
    source_parameters: EarthquakeSourceParameters = Field(..., description="Source rupture parameters")
    mmi_assessment: ModifiedMercalliIntensity = Field(..., description="Macroseismic intensity assessment")
    aftershock_outlook: AftershockProbability = Field(..., description="Aftershock statistical outlook")
    structural_directives: StructuralVulnerabilityDirectives = Field(..., description="Structural and NDMA safety directives")
    vernacular_alerts: Dict[str, str] = Field(..., description="Multilingual earthquake safety alerts")


class EarthquakeResponse(BaseModel):
    timestamp: str = Field(..., description="ISO 8601 generation timestamp")
    bulletin_number: str = Field(..., description="Official NCS/IMD seismic bulletin identifier")
    provenance: str = Field(..., description="Institutional source (NCS/IMD Seismology Division & NDMA)")
    national_seismicity_synopsis: str = Field(..., description="Synoptic overview of current seismic activity across Indian plate")
    selected_province: SeismotectonicProvince = Field(..., description="Target evaluated seismotectonic province")
    all_provinces: List[SeismotectonicProvince] = Field(..., description="Catalog of monitored Indian seismotectonic provinces")
    seismological_model: str = Field(..., description="Magnitude-frequency and attenuation models referenced")
    vernacular_bulletins: Dict[str, str] = Field(..., description="Multilingual seismic emergency broadcasts")
    is_offline_cached: bool = Field(default=False, description="Whether response originated from offline cache")
