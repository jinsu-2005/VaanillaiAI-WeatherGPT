from typing import Optional
from fastapi import APIRouter, Query

from app.schemas.ocean_state import OceanStateResponse
from app.services.ocean_state_service import OceanStateService

router = APIRouter()


@router.get(
    "/ocean-state",
    response_model=OceanStateResponse,
    summary="INCOIS Ocean State Forecast (OSF), Swell Surge & Rip Current Warning",
    description="Delivers coupled WAVEWATCH-III and Nearshore SWAN numerical wave telemetry, tracking significant wave height (Hs), long-period swell surges (Kallakkadal), coastal beach rip current velocities, lifeguard flags, and maritime safety directives.",
)
async def get_ocean_state_assessment(
    latitude: Optional[float] = Query(None, description="Current latitude coordinate"),
    longitude: Optional[float] = Query(None, description="Current longitude coordinate"),
    beach_id: Optional[str] = Query(None, description="Specific monitored beach or harbor slug (e.g. puri_golden_beach_or, kovalam_vizhinjam_kl)"),
) -> OceanStateResponse:
    return OceanStateService.get_ocean_state_assessment(
        latitude=latitude,
        longitude=longitude,
        beach_id=beach_id,
    )
