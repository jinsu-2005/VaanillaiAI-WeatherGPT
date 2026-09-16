"""API endpoints for IMD FogPass, Highway Safety & Aviation Low-Visibility Nowcasting."""
from typing import Optional
from fastapi import APIRouter, Query
from app.schemas.fog import FogNowcastResponse
from app.services.fog_service import fog_service

router = APIRouter()


@router.get("/nowcast", response_model=FogNowcastResponse, summary="Get IMD FogPass & Highway/Aviation Low-Visibility Nowcast")
async def get_fog_nowcast(
    latitude: Optional[float] = Query(None, ge=-90.0, le=90.0, description="Observer latitude in decimal degrees"),
    longitude: Optional[float] = Query(None, ge=-180.0, le=180.0, description="Observer longitude in decimal degrees"),
    location_name: str = Query("Indo-Gangetic Corridor", description="City or highway name"),
    station_id: Optional[str] = Query(None, description="Optional IMD / WMO station ID (e.g. 42182 for Delhi IGI)"),
):
    """Retrieve physical visibility nowcasting, Runway Visual Range (RVR ILS CAT-I/II/III), NHAI expressway speed limits, and Indian Railways FogPass alerts."""
    return await fog_service.get_fog_nowcast(
        lat=latitude,
        lon=longitude,
        location_name=location_name,
        station_id=station_id,
    )
