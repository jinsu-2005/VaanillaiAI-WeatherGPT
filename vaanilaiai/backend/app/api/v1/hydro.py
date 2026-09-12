"""API routes for Central Water Commission (CWC) River Basin Flood Telemetry & Dam Reservoirs."""
from typing import Optional
from fastapi import APIRouter, Query
from app.schemas.hydro import CwcHydroOverviewResponse
from app.services.hydro_service import HydroService

router = APIRouter()


@router.get(
    "/overview",
    response_model=CwcHydroOverviewResponse,
    summary="Get CWC River Basin Hydrograph & Reservoir Telemetry",
    description="Retrieves live river water level gauge stations, warning/danger marks, and multi-purpose dam reservoir storage percentages.",
)
async def get_hydro_overview(
    latitude: float = Query(..., description="Latitude of user/location"),
    longitude: float = Query(..., description="Longitude of user/location"),
    location_name: str = Query("Location", description="Display name of location"),
    basin_name: Optional[str] = Query(None, description="Filter to specific river basin (e.g., Ganga, Brahmaputra, Cauvery)"),
):
    return HydroService.get_cwc_hydro_overview(
        latitude=latitude,
        longitude=longitude,
        location_name=location_name,
        basin_name=basin_name,
    )
