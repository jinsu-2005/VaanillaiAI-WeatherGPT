from typing import Optional
from fastapi import APIRouter, Query
from app.schemas.potential_fishing_zone import PfzResponse
from app.services.potential_fishing_zone_service import PotentialFishingZoneService

router = APIRouter()


@router.get(
    "/potential-fishing-zone",
    response_model=PfzResponse,
    summary="INCOIS & CMFRI Potential Fishing Zone (PFZ) & Marine Fuel Engine",
    description=(
        "Returns satellite-derived ocean color chlorophyll-a concentration, sea surface temperature thermal fronts, "
        "navigational compass vectoring, artisanal diesel fuel conservation metrics, and CMFRI marine protected area (MPA) "
        "exclusion boundaries across 7 Indian coastal fishing sectors."
    ),
)
async def get_potential_fishing_zone(
    sector_id: Optional[str] = Query(
        None,
        description="Fishing sector slug (kochi_malabar, veraval_saurashtra, sassoon_dock_konkan, mangalore_malpe, tuticorin_mannar, visakhapatnam_kakinada, paradeep_gahirmatha)",
    ),
    latitude: Optional[float] = Query(None, description="Vessel or harbor latitude for nearest coastal sector geodetic resolution"),
    longitude: Optional[float] = Query(None, description="Vessel or harbor longitude for nearest coastal sector geodetic resolution"),
    craft_type: Optional[str] = Query(
        None,
        description="Fishing craft category: TRADITIONAL_MOTORIZED_FRP, MECHANIZED_TRAWLER_INBOARD, DEEP_SEA_TUNA_LONGLINER",
    ),
) -> PfzResponse:
    """Retrieve Potential Fishing Zone vectoring, ocean color telemetry, and fuel savings."""
    return PotentialFishingZoneService.get_sector(
        sector_id=sector_id,
        latitude=latitude,
        longitude=longitude,
        craft_type=craft_type,
    )
