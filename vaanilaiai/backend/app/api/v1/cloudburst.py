from typing import Optional
from fastapi import APIRouter, Query

from app.schemas.cloudburst import CloudburstResponse
from app.services.cloudburst_service import CloudburstService

router = APIRouter()


@router.get(
    "/cloudburst",
    response_model=CloudburstResponse,
    summary="Western Ghats & Himalayan Orographic Cloudburst & Landslide Nowcast",
    description="Provides real-time nowcasting of localized cloudbursts, GSI slope stability Factor of Safety, debris flow volumes, and mountain transit safety.",
)
async def get_cloudburst_assessment(
    latitude: Optional[float] = Query(None, description="Current latitude coordinate"),
    longitude: Optional[float] = Query(None, description="Current longitude coordinate"),
    catchment_id: Optional[str] = Query(None, description="Specific mountain catchment ID"),
) -> CloudburstResponse:
    return CloudburstService.get_assessment(
        latitude=latitude,
        longitude=longitude,
        catchment_id=catchment_id,
    )
