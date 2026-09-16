from enum import Enum
from typing import Dict, List, Optional
from pydantic import BaseModel, Field


class UhiSeverityLevel(str, Enum):
    LOW_NEGLIGIBLE = "LOW_NEGLIGIBLE"          # Delta T < 2.0°C; minimal urban canopy thermal divergence
    MODERATE_ELEVATED = "MODERATE_ELEVATED"    # 2.0°C <= Delta T < 4.0°C; noticeable surface overheating
    HIGH_SEVERE = "HIGH_SEVERE"                # 4.0°C <= Delta T < 6.0°C; severe concrete/asphalt heat retention
    CRITICAL_EXTREME = "CRITICAL_EXTREME"      # Delta T >= 6.0°C; extreme sensible heat storage, acute heat stress


class CanopyUrbanMorphology(str, Enum):
    HIGH_DENSITY_CONCRETE_CORE = "HIGH_DENSITY_CONCRETE_CORE"  # Dense mid/high-rise core, narrow street canyons, minimal vegetation
    COMMERCIAL_GLASS_CANYON = "COMMERCIAL_GLASS_CANYON"        # Glass/steel curtain towers, intense HVAC waste heat rejection
    INDUSTRIAL_ASPHALT_ZONE = "INDUSTRIAL_ASPHALT_ZONE"        # Expansive impervious blacktop, tin/sheet metal warehouses
    INFORMAL_SETTLEMENT_TIN_ROOF = "INFORMAL_SETTLEMENT_TIN_ROOF"  # High density, corrugated uninsulated tin roofs, extreme indoor trap
    PERI_URBAN_RESIDENTIAL = "PERI_URBAN_RESIDENTIAL"          # Mixed residential, partial tree canopy, intermediate thermal storage


class CoolRoofMaterialType(str, Enum):
    HIGH_ALBEDO_ELASTOMERIC_WHITE = "HIGH_ALBEDO_ELASTOMERIC_WHITE"  # SRI 104, solar reflectance 0.85, thermal emittance 0.90
    REFLECTIVE_CERAMIC_TILES = "REFLECTIVE_CERAMIC_TILES"            # SRI 85, solar reflectance 0.75, thermal emittance 0.88
    SLAKED_LIME_WASH = "SLAKED_LIME_WASH"                            # SRI 78, solar reflectance 0.72, thermal emittance 0.85 (Traditional Low-cost)
    STANDARD_CONCRETE_UNCOATED = "STANDARD_CONCRETE_UNCOATED"        # SRI 20, solar reflectance 0.30, thermal emittance 0.85 (Base baseline)
    CORRUGATED_GALVANIZED_TIN = "CORRUGATED_GALVANIZED_TIN"          # SRI 12, solar reflectance 0.20, thermal emittance 0.25 (Severe heat trap)


class SurfaceThermalTelemetry(BaseModel):
    lst_urban_celsius: float = Field(..., description="Radiometric Land Surface Temperature in urban core in °C")
    lst_rural_baseline_celsius: float = Field(..., description="Reference rural/peri-urban baseline LST in °C")
    uhi_thermal_anomaly_delta_c: float = Field(..., description="Urban Heat Island thermal anomaly Delta T = T_urban - T_rural")
    canopy_air_temp_celsius: float = Field(..., description="2-meter ambient canopy air temperature in °C")
    tropical_night_min_temp_celsius: float = Field(..., description="Nocturnal minimum temperature T_min in °C")
    tropical_night_flag: bool = Field(..., description="True if T_min >= 25.0°C (impairing human nocturnal physiological recovery)")
    severe_tropical_night_flag: bool = Field(..., description="True if T_min >= 28.0°C (acute nocturnal cardiovascular stress)")


class BiophysicalCanopyMetrics(BaseModel):
    impervious_surface_fraction_pct: float = Field(..., ge=0.0, le=100.0, description="Percentage of built impervious surface (asphalt, concrete, roof)")
    ndvi_urban_core: float = Field(..., ge=-1.0, le=1.0, description="Normalized Difference Vegetation Index in urban core")
    ndvi_rural_baseline: float = Field(..., ge=-1.0, le=1.0, description="Reference rural baseline NDVI")
    vegetation_cooling_deficit_delta_c: float = Field(..., description="Calculated evapotranspirative cooling loss due to depleted vegetation")
    sky_view_factor_svf: float = Field(..., ge=0.0, le=1.0, description="Sky View Factor (0-1) reflecting urban street canyon openness")
    anthropogenic_heat_flux_w_m2: float = Field(..., description="Anthropogenic waste heat flux Q_F from vehicles, HVAC, and power in W/m²")


class CoolRoofSimulation(BaseModel):
    roof_material: CoolRoofMaterialType = Field(..., description="Evaluated roofing surface material")
    solar_reflectance_index_sri: int = Field(..., description="Solar Reflectance Index (ASTM E1980 / ECBC / NDMA scale)")
    solar_reflectance_alpha: float = Field(..., description="Solar reflectance fraction (0-1)")
    thermal_emittance_epsilon: float = Field(..., description="Thermal emittance fraction (0-1)")
    surface_temperature_celsius: float = Field(..., description="Peak afternoon roof surface temperature under 1000 W/m² irradiance")
    surface_temp_reduction_delta_c: float = Field(..., description="Cooling drop compared to standard uncoated concrete/tin roof")
    indoor_cooling_benefit_delta_c: float = Field(..., description="Estimated indoor air temperature reduction in °C")
    ac_energy_load_reduction_pct: float = Field(..., description="Estimated percentage reduction in cooling air conditioning load")
    ndma_cool_roof_compliant: bool = Field(..., description="True if material satisfies NDMA / ECBC standard of SRI >= 78")


class MicroclimateHotspot(BaseModel):
    hotspot_id: str = Field(..., description="Unique identifier for local urban hotspot")
    hotspot_name: str = Field(..., description="Neighborhood or commercial node name")
    morphology: CanopyUrbanMorphology = Field(..., description="Urban morphology classification")
    lst_celsius: float = Field(..., description="Peak Land Surface Temperature in °C")
    thermal_anomaly_delta_c: float = Field(..., description="Localized thermal anomaly above rural baseline")
    vulnerability_rank: str = Field(..., description="Vulnerability level (e.g. VERY_HIGH, HIGH, MODERATE)")
    cooling_shelter_distance_m: int = Field(..., description="Distance in meters to nearest public cool space or shaded park")


class MunicipalUhiDirectives(BaseModel):
    cool_roof_policy_status: str = Field(..., description="Status of municipal/state Cool Roof mandate (e.g. ACTIVE_MANDATORY, PILOT_VOLUNTARY)")
    cool_roof_target_sq_meters: int = Field(..., description="Annual municipal cool roof coating deployment target in m²")
    urban_forestry_corridor_km: float = Field(..., description="Planned linear green buffer / tree canopy corridor in km")
    transit_misting_stations_count: int = Field(..., description="Number of operational evaporative misting stations at busy bus/metro stops")
    construction_heat_shift_enforced: bool = Field(..., description="Mandatory shift of strenuous outdoor construction away from 12:00-16:00")
    public_pyaus_drinking_water_points: int = Field(..., description="Operational free drinking water kiosks (Pyaus) across wards")
    emergency_cooling_shelters_active: int = Field(..., description="Active air-conditioned / shaded civic cooling centers")


class UrbanHeatIslandCorridor(BaseModel):
    corridor_id: str = Field(..., description="Unique slug for monitored megacity")
    city_name: str = Field(..., description="Official metropolitan name")
    state: str = Field(..., description="State or Union Territory")
    latitude: float = Field(..., description="City center latitude")
    longitude: float = Field(..., description="City center longitude")
    climate_zone: str = Field(..., description="National Building Code / IMD climate classification (e.g. Composite, Warm-Humid, Hot-Dry)")
    dominant_morphology: CanopyUrbanMorphology = Field(..., description="Prevailing canopy morphology")
    threat_level: UhiSeverityLevel = Field(..., description="Current Urban Heat Island severity classification")
    surface_telemetry: SurfaceThermalTelemetry = Field(..., description="Satellite radiometric & air thermal telemetry")
    biophysical_metrics: BiophysicalCanopyMetrics = Field(..., description="Impervious cover, NDVI deficit, and anthropogenic heat flux")
    cool_roof_simulation: CoolRoofSimulation = Field(..., description="Cool roof albedo mitigation simulation")
    hotspots: List[MicroclimateHotspot] = Field(..., description="Identified microclimate heat pockets")
    directives: MunicipalUhiDirectives = Field(..., description="Municipal and NDMA urban heat mitigation directives")
    vernacular_bulletins: Dict[str, str] = Field(..., description="Multilingual emergency urban heat advisories")


class CorridorSummary(BaseModel):
    corridor_id: str
    city_name: str
    state: str
    threat_level: UhiSeverityLevel
    uhi_thermal_anomaly_delta_c: float
    lst_urban_celsius: float
    tropical_night_flag: bool


class UrbanHeatIslandResponse(BaseModel):
    corridor_id: str
    city_name: str
    state: str
    current_corridor: UrbanHeatIslandCorridor
    all_corridors: List[CorridorSummary]
    last_updated_utc: str
    data_source: str
