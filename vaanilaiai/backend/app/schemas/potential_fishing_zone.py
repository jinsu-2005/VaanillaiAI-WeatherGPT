from enum import Enum
from typing import Dict, List, Optional
from pydantic import BaseModel, Field


class PfzProductivityTier(str, Enum):
    OPTIMAL_HIGH_YIELD = "OPTIMAL_HIGH_YIELD"          # Chl-a 0.8-3.0 mg/m³, strong SST front; prime pelagic foraging
    MODERATE_SECONDARY = "MODERATE_SECONDARY"          # Chl-a 0.3-0.8 mg/m³, diffuse frontal zone; fair pelagic abundance
    MARGINAL_DIFFUSE = "MARGINAL_DIFFUSE"              # Chl-a 0.1-0.3 mg/m³, weak gradient; scattered shoals
    UNSUITABLE_OLIGOTROPHIC = "UNSUITABLE_OLIGOTROPHIC"  # Chl-a < 0.1 mg/m³ or HAB event; barren or hypoxic


class PelagicSpeciesGroup(str, Enum):
    SMALL_PELAGICS_SARDINE_MACKEREL = "SMALL_PELAGICS_SARDINE_MACKEREL"    # Indian Oil Sardine, Indian Mackerel, Anchovy
    LARGE_PELAGICS_TUNA_SEERFISH = "LARGE_PELAGICS_TUNA_SEERFISH"          # Yellowfin Tuna, Skipjack, Seer Fish (King Mackerel), Barracuda
    DEMERSAL_CEPHALOPODS_SQUID_CUTTLEFISH = "DEMERSAL_CEPHALOPODS_SQUID_CUTTLEFISH"  # Squid, Cuttlefish, Threadfin Bream, Croaker
    ESTUARINE_PLUME_HILSA_POMFRET = "ESTUARINE_PLUME_HILSA_POMFRET"        # Hilsa Shad, Silver Pomfret, Bombay Duck, Ribbonfish


class FishingCraftType(str, Enum):
    TRADITIONAL_MOTORIZED_FRP = "TRADITIONAL_MOTORIZED_FRP"        # 8-10m FRP boat with Outboard Motor (OBM), 1-2 day trip
    MECHANIZED_TRAWLER_INBOARD = "MECHANIZED_TRAWLER_INBOARD"      # 14-20m wooden/steel hull Inboard Motor (IBM), 3-7 day trip
    DEEP_SEA_TUNA_LONGLINER = "DEEP_SEA_TUNA_LONGLINER"            # 22-28m multi-day deep-sea vessel, 10-15 day trip


class OceanColorTelemetry(BaseModel):
    chlorophyll_a_mg_m3: float = Field(..., description="Surface chlorophyll-a concentration in mg/m³ via Oceansat-3/MODIS")
    productivity_tier: PfzProductivityTier = Field(..., description="Primary biological productivity classification")
    diffuse_attenuation_k490: float = Field(..., description="Diffuse attenuation coefficient at 490nm (water clarity / turbidity)")
    phytoplankton_bloom_active: bool = Field(..., description="True if sustained phytoplankton bloom is actively foraging pelagics")
    harmful_algal_bloom_risk: bool = Field(..., description="True if toxic or hypoxic dinoflagellate / red-tide risk is present")


class ThermalFrontTelemetry(BaseModel):
    sea_surface_temp_celsius: float = Field(..., description="Radiometric sea surface temperature in °C")
    sst_gradient_deg_c_per_km: float = Field(..., description="Horizontal thermal gradient delta SST / km across boundary")
    thermal_front_type: str = Field(..., description="Oceanographic thermal front classification")
    mesoscale_eddy_type: str = Field(..., description="Cyclonic (upwelling) or anticyclonic (convergence) eddy structure")
    sea_surface_height_anomaly_cm: float = Field(..., description="Sea Surface Height Anomaly (SSHA) in cm")


class NavigationalVector(BaseModel):
    landing_harbour_name: str = Field(..., description="Reference fish landing center or fishing harbour (FLC)")
    true_bearing_degrees: int = Field(..., ge=0, le=360, description="Navigational azimuth heading in degrees from true North")
    compass_direction: str = Field(..., description="16-point cardinal bearing (e.g. WSW, SW, ENE)")
    distance_nautical_miles: float = Field(..., description="Great-circle distance in nautical miles (nm)")
    distance_kilometers: float = Field(..., description="Distance in kilometers")
    centroid_latitude: float = Field(..., description="Target PFZ polygon centroid latitude")
    centroid_longitude: float = Field(..., description="Target PFZ polygon centroid longitude")
    target_depth_fathoms: int = Field(..., description="Water column bathymetry in fathoms")
    target_depth_meters: float = Field(..., description="Water column depth in meters")


class EconomicFuelSavings(BaseModel):
    craft_type: FishingCraftType = Field(..., description="Evaluated marine fishing craft category")
    scouting_time_reduction_pct: float = Field(..., description="Percentage of searching/scouting time saved by direct vectoring")
    diesel_saved_liters: float = Field(..., description="Estimated diesel fuel saved per voyage in liters")
    rupee_fuel_cost_savings_inr: float = Field(..., description="Estimated operational trip cost savings in Indian Rupees (INR)")
    carbon_emission_reduction_kg_co2: float = Field(..., description="CO2 carbon emission reduction in kg (2.68 kg CO2 / L diesel)")


class EcologicalConservationBoundary(BaseModel):
    nearest_mpa_name: str = Field(..., description="Nearest designated Marine Protected Area or biosphere sanctuary")
    distance_to_mpa_boundary_km: float = Field(..., description="Distance in km to boundary of sensitive ecological zone")
    mpa_buffer_violation_risk: str = Field(..., description="Status (e.g. SAFE_OUTSIDE_BUFFER, PROXIMITY_ALERT, NO_FISHING_ZONE)")
    minimum_legal_size_advisory: str = Field(..., description="CMFRI Minimum Legal Size (MLS) guidance to prevent juvenile catch")
    artisanal_exclusive_zone_status: str = Field(..., description="Territorial waters zoning (0-5 km exclusive for artisanal canoes)")


class PfzSector(BaseModel):
    sector_id: str = Field(..., description="Unique slug for coastal fishing sector")
    sector_name: str = Field(..., description="Regional fishing harbor cluster name")
    state: str = Field(..., description="Coastal State or Union Territory")
    coastal_sea: str = Field(..., description="Arabian Sea, Bay of Bengal, or Indian Ocean")
    primary_species: PelagicSpeciesGroup = Field(..., description="Dominant targeted commercial fish species")
    ocean_color: OceanColorTelemetry = Field(..., description="Chlorophyll-a and ocean color telemetry")
    thermal_front: ThermalFrontTelemetry = Field(..., description="SST front and mesoscale eddy telemetry")
    navigational_vector: NavigationalVector = Field(..., description="Compass bearing and range from base harbor")
    fuel_savings: EconomicFuelSavings = Field(..., description="Artisanal diesel fuel conservation metrics")
    conservation: EcologicalConservationBoundary = Field(..., description="CMFRI ecological boundaries and MPA protection")
    vernacular_bulletins: Dict[str, str] = Field(..., description="Multilingual coastal fisherman advisories")


class SectorSummary(BaseModel):
    sector_id: str
    sector_name: str
    state: str
    productivity_tier: PfzProductivityTier
    primary_species: PelagicSpeciesGroup
    compass_direction: str
    distance_nm: float


class PfzResponse(BaseModel):
    sector_id: str
    sector_name: str
    state: str
    current_sector: PfzSector
    all_sectors: List[SectorSummary]
    last_updated_utc: str
    data_source: str
