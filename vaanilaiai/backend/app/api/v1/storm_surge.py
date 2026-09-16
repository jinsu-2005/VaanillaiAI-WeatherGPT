from typing import Optional
from fastapi import APIRouter, Query

from app.schemas.storm_surge import StormSurgeResponse
from app.services.storm_surge_service import StormSurgeService

router = APIRouter()


@router.get(
    "/storm-surge",
    response_model=StormSurgeResponse,
    summary="INCOIS-IMD Coastal Storm Surge & Tidal Inundation Nowcast",
    description="Delivers coupled ADCIRC-SWAN numerical hydrodynamics computing Total Water Level (TWL), storm surge peak, astronomical tide, estuarine tidal bore propagation, saline intrusion distance, and coastal storm gate operation directives.",
)
async def get_storm_surge_assessment(
    latitude: Optional[float] = Query(None, description="Current latitude coordinate"),
    longitude: Optional[float] = Query(None, description="Current longitude coordinate"),
    sector_id: Optional[str] = Query(None, description="Specific coastal estuary sector slug (e.g. sundarbans_wb, paradeep_mahanadi_or)"),
) -> StormSurgeResponse:
    return StormSurgeService.get_storm_surge_assessment(
        latitude=latitude,
        longitude=longitude,
        sector_id=sector_id,
    )
