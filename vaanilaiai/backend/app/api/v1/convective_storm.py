from typing import Optional
from fastapi import APIRouter, Query

from app.schemas.convective_storm import ConvectiveStormResponse
from app.services.convective_storm_service import convective_storm_service

router = APIRouter()


@router.get(
    "/convective-storm",
    response_model=ConvectiveStormResponse,
    summary="Get IMD Severe Thunderstorm, Kalbaishakhi & Haboob Dust Storm Nowcast",
    description=(
        "Retrieves operational thermodynamic instability indices (CAPE, Lifted Index, K-Index, Total Totals), "
        "cold-pool Haboob density current dynamics (gust front speed, dust wall height, visibility drops), "
        "aviation microburst warnings, power grid risk ratings, and vernacular 5-language bulletins."
    ),
)
async def get_convective_storm_nowcast(
    latitude: Optional[float] = Query(None, description="User or observatory latitude"),
    longitude: Optional[float] = Query(None, description="User or observatory longitude"),
    hotspot_id: Optional[str] = Query(None, description="Convective hotspot ID (e.g. kolkata_gangetic_wb, bikaner_thar_desert)"),
) -> ConvectiveStormResponse:
    return convective_storm_service.get_convective_storm_assessment(
        latitude=latitude, longitude=longitude, hotspot_id=hotspot_id
    )
