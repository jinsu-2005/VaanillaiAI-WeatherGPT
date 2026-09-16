from enum import Enum
from typing import List, Dict, Optional
from pydantic import BaseModel, Field


class SoilTextureClass(str, Enum):
    BLACK_COTTON_VERTISOL = "BLACK_COTTON_VERTISOL"
    INDO_GANGETIC_ALLUVIAL = "INDO_GANGETIC_ALLUVIAL"
    RED_SANDY_ALFISOL = "RED_SANDY_ALFISOL"
    COASTAL_ALLUVIAL_LOAM = "COASTAL_ALLUVIAL_LOAM"
    LATERITIC_LOAM = "LATERITIC_LOAM"


class CropWaterStressTier(str, Enum):
    OPTIMAL_TURGOR = "OPTIMAL_TURGOR"        # CWSI < 0.2: No water stress, full transpiration
    MILD_STRESS = "MILD_STRESS"              # CWSI 0.2 - 0.4: Early stomatal constriction, monitor
    MODERATE_DEFICIT = "MODERATE_DEFICIT"    # CWSI 0.4 - 0.7: Stomatal closure, yield deficit imminent
    SEVERE_DROUGHT_STRESS = "SEVERE_DROUGHT_STRESS"  # CWSI > 0.7: Permanent wilting damage


class SoilMoistureProfile(BaseModel):
    topsoil_10cm_pct: float = Field(..., description="Volumetric water content in topsoil (0-10 cm) percentage")
    root_zone_40cm_pct: float = Field(..., description="Volumetric water content in primary root-zone (10-40 cm) percentage")
    subsoil_100cm_pct: float = Field(..., description="Volumetric water content in subsoil storage (40-100 cm) percentage")
    field_capacity_pct: float = Field(..., description="Soil Field Capacity (FC) volumetric percentage")
    wilting_point_pct: float = Field(..., description="Permanent Wilting Point (PWP) volumetric percentage")
    relative_available_soil_moisture_pct: float = Field(..., description="Relative Available Soil Moisture (RASM = (theta - PWP)/(FC - PWP) * 100)")


class EvapotranspirationMetrics(BaseModel):
    reference_et0_mm_day: float = Field(..., description="FAO-56 Penman-Monteith reference evapotranspiration (ET0) in mm/day")
    crop_coefficient_kc: float = Field(..., description="Current crop phenological coefficient (Kc)")
    actual_etc_mm_day: float = Field(..., description="Actual crop evapotranspiration (ETc = Kc * ET0) in mm/day")
    canopy_temperature_c: float = Field(..., description="Infrared radiometric crop canopy temperature in Celsius")
    ambient_air_temperature_c: float = Field(..., description="Surface ambient dry-bulb air temperature in Celsius")
    canopy_air_temp_departure_c: float = Field(..., description="Canopy-to-air temperature differential (Tc - Ta) in Celsius")
    crop_water_stress_index_cwsi: float = Field(..., description="Jackson-Idso empirical Crop Water Stress Index (0.0 to 1.0)")


class PrecisionIrrigationDirective(BaseModel):
    recommended_irrigation_depth_mm: float = Field(..., description="Net supplemental irrigation requirement in mm")
    drip_run_time_hours: float = Field(..., description="Recommended pressurized drip / micro-sprinkler run duration in hours")
    critical_growth_stage: str = Field(..., description="Current vulnerable phenological stage (e.g. Boll Formation, Flowering)")
    anti_transpirant_spray: str = Field(..., description="Recommended foliar spray to reduce stomatal transpiration losses")
    mulch_recommendation: str = Field(..., description="In-situ organic or plastic soil moisture conservation mulching advice")
    intercultivation_tillage: str = Field(..., description="Soil capillary break and weed moisture competition directive")


class AgroClimaticZone(BaseModel):
    zone_id: str = Field(..., description="Unique slug for the agro-climatic zone")
    zone_name: str = Field(..., description="Public title of the agricultural tract")
    state: str = Field(..., description="State jurisdiction")
    district: str = Field(..., description="District jurisdiction")
    primary_crop: str = Field(..., description="Dominant cultivated crop in the tract")
    growth_stage: str = Field(..., description="Current phenological crop stage")
    latitude: float = Field(..., description="Representative centroid latitude")
    longitude: float = Field(..., description="Representative centroid longitude")
    soil_texture: SoilTextureClass = Field(..., description="Predominant soil taxonomic textural class")
    stress_tier: CropWaterStressTier = Field(..., description="Crop water stress severity classification")
    soil_moisture: SoilMoistureProfile = Field(..., description="Multi-depth soil volumetric water dynamics")
    evapotranspiration: EvapotranspirationMetrics = Field(..., description="FAO-56 ET and thermal infrared canopy metrics")
    irrigation_directives: PrecisionIrrigationDirective = Field(..., description="Precision water management and agronomic directives")
    localized_bulletins: Dict[str, str] = Field(..., description="Multilingual agricultural advisory bulletins")


class CropWaterStressResponse(BaseModel):
    timestamp: str = Field(..., description="ISO 8601 generation timestamp")
    bulletin_number: str = Field(..., description="Official ICAR-CRIDA/IMD Agromet bulletin identifier")
    provenance: str = Field(..., description="Institutional provenance (ICAR-CRIDA / IMD Division of Agricultural Meteorology)")
    selected_zone: AgroClimaticZone = Field(..., description="Target evaluated agro-climatic zone")
    all_zones: List[AgroClimaticZone] = Field(..., description="Catalog of monitored national agro-climatic tracts")
    vernacular_bulletins: Dict[str, str] = Field(..., description="Multilingual crop protection directives")
    is_offline_cached: bool = Field(default=False, description="Whether data originated from offline cache")
