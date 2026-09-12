"""API routes for NCMRWF & IMD Sub-Divisional Monsoon Teleconnections and Long-Range Forecast."""
from fastapi import APIRouter, Query
from app.schemas.monsoon import MonsoonIntelligenceResponse
from app.services.monsoon_service import MonsoonService

router = APIRouter()


@router.get(
    "/teleconnections",
    response_model=MonsoonIntelligenceResponse,
    summary="Get Monsoon Teleconnections & Sub-Divisional LRF",
    description="Retrieves oceanic teleconnections (ENSO Niño 3.4, IOD, MJO), 36 IMD meteorological sub-divisional rainfall departures, and seasonal forecast probabilities.",
)
async def get_monsoon_teleconnections(
    latitude: float = Query(..., description="Latitude of user/location"),
    longitude: float = Query(..., description="Longitude of user/location"),
    location_name: str = Query("Location", description="Display name of location"),
):
    return MonsoonService.get_monsoon_intelligence(
        latitude=latitude,
        longitude=longitude,
        location_name=location_name,
    )
