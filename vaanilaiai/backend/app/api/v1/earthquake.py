from typing import Optional
from fastapi import APIRouter, Query

from app.schemas.earthquake import EarthquakeResponse
from app.services.earthquake_service import EarthquakeService

router = APIRouter()


@router.get(
    "/earthquake",
    response_model=EarthquakeResponse,
    summary="NCS/IMD & NDMA National Earthquake Seismology, Fault-Line Proximity & Aftershock Probabilistic Assessment",
    description="Provides moment magnitude, Modified Mercalli Intensity (MMI), BIS IS:1893 seismic zone classification, Båth's Law aftershock probability, and NDMA structural vulnerability directives across India's seismotectonic provinces.",
)
async def get_earthquake_assessment(
    latitude: Optional[float] = Query(None, description="Current latitude coordinate"),
    longitude: Optional[float] = Query(None, description="Current longitude coordinate"),
    province_id: Optional[str] = Query(None, description="Specific seismotectonic province slug (e.g., ne_himalaya_sikkim_assam, kutch_saurashtra_gj)"),
) -> EarthquakeResponse:
    return EarthquakeService.get_earthquake_assessment(
        province_id=province_id,
        latitude=latitude,
        longitude=longitude,
    )
