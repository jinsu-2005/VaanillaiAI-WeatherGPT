from typing import Optional
from fastapi import APIRouter, Query

from app.schemas.forest_fire import ForestFireResponse
from app.services.forest_fire_service import ForestFireService

router = APIRouter()


@router.get(
    "/forest-fire",
    response_model=ForestFireResponse,
    summary="FSI Van Agni & ISRO Forest Fire Early Warning",
    description="Provides real-time Canadian Fire Weather Index (FWI) components, MODIS/VIIRS satellite thermal anomalies, fire spread physics, and wildlife sanctuary protection directives.",
)
async def get_forest_fire_assessment(
    latitude: Optional[float] = Query(None, description="Current latitude coordinate"),
    longitude: Optional[float] = Query(None, description="Current longitude coordinate"),
    zone_id: Optional[str] = Query(None, description="Specific forest reserve zone slug (e.g. similipal_tiger_reserve, uttarakhand_garhwal_pine)"),
) -> ForestFireResponse:
    return ForestFireService.get_assessment(
        latitude=latitude,
        longitude=longitude,
        zone_id=zone_id,
    )
