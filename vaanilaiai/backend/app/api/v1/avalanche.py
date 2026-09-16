from typing import Optional
from fastapi import APIRouter, Query

from app.schemas.avalanche_snow import AvalancheSnowResponse
from app.services.avalanche_snow_service import avalanche_snow_service

router = APIRouter()


@router.get(
    "/assessment",
    response_model=AvalancheSnowResponse,
    summary="Get Himalayan Western Disturbance, Snowpack & Avalanche Early Warning Assessment",
    description=(
        "Retrieves operational avalanche hazard ratings (DGRE 5-stage scale), cryospheric snowpack "
        "physics (SWE, fresh snowfall, weak layer mechanics), Border Roads Organisation (BRO) mountain pass "
        "transit statuses, and high-altitude pilgrim/trekker safety advisories."
    ),
)
async def get_avalanche_snow_assessment(
    latitude: Optional[float] = Query(None, description="User or observatory latitude"),
    longitude: Optional[float] = Query(None, description="User or observatory longitude"),
    sector_id: Optional[str] = Query(None, description="Target Himalayan sector ID"),
) -> AvalancheSnowResponse:
    return avalanche_snow_service.get_avalanche_assessment(
        latitude=latitude, longitude=longitude, sector_id=sector_id
    )
