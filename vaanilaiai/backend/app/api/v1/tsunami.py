from typing import Optional
from fastapi import APIRouter, Query

from app.schemas.tsunami import TsunamiWarningResponse
from app.services.tsunami_service import TsunamiService

router = APIRouter()


@router.get(
    "/tsunami-warning",
    response_model=TsunamiWarningResponse,
    summary="INCOIS Indian Tsunami Early Warning Centre (ITEWS) Alert",
    description="Provides real-time seismic tsunamigenic triggers, DART tsunameter buoys, coastal tide gauge sea-level anomalies, wave arrival travel times, and vertical evacuation directives across India's coastline.",
)
async def get_tsunami_warning_assessment(
    latitude: Optional[float] = Query(None, description="Current latitude coordinate"),
    longitude: Optional[float] = Query(None, description="Current longitude coordinate"),
    sector_id: Optional[str] = Query(None, description="Specific coastal sector slug (e.g. andaman_nicobar_islands, tamil_nadu_coromandel_coast)"),
) -> TsunamiWarningResponse:
    return TsunamiService.get_assessment(
        latitude=latitude,
        longitude=longitude,
        sector_id=sector_id,
    )
