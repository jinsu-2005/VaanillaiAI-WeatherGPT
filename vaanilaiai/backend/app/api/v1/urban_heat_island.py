from typing import Optional
from fastapi import APIRouter, Query
from app.schemas.urban_heat_island import UrbanHeatIslandResponse
from app.services.urban_heat_island_service import UrbanHeatIslandService

router = APIRouter()


@router.get(
    "/urban-heat-island",
    response_model=UrbanHeatIslandResponse,
    summary="IMD & NDMA Urban Heat Island (UHI) & Cool Roof Albedo Engine",
    description=(
        "Returns radiometric land surface temperature (LST in °C) anomaly against rural baseline, "
        "nocturnal tropical night (T_min >= 25°C) stress metrics, biophysical impervious surface fraction, "
        "NDMA/ECBC Cool Roof simulation (SRI >= 78), and municipal heat mitigation directives across 7 Indian megacities."
    ),
)
async def get_urban_heat_island(
    corridor_id: Optional[str] = Query(
        None,
        description="Megacity identifier (delhi_ncr, ahmedabad_amc, mumbai_mmr, bengaluru_bbmp, hyderabad_ghmc, chennai_gcc, kolkata_kmc)",
    ),
    latitude: Optional[float] = Query(None, description="Current user latitude for automatic nearest megacity geodetic resolution"),
    longitude: Optional[float] = Query(None, description="Current user longitude for automatic nearest megacity geodetic resolution"),
    roof_type: Optional[str] = Query(
        None,
        description="Cool roof material type: HIGH_ALBEDO_ELASTOMERIC_WHITE, REFLECTIVE_CERAMIC_TILES, SLAKED_LIME_WASH, STANDARD_CONCRETE_UNCOATED, CORRUGATED_GALVANIZED_TIN",
    ),
) -> UrbanHeatIslandResponse:
    """Evaluate Urban Heat Island surface thermal anomaly and Cool Roof mitigation."""
    return UrbanHeatIslandService.get_corridor(
        corridor_id=corridor_id,
        latitude=latitude,
        longitude=longitude,
        roof_type=roof_type,
    )
