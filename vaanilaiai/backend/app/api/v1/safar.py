"""API routes for IITM SAFAR & IMD AQEWS Air Quality and Atmospheric Dispersion Intelligence."""
from typing import Optional
from fastapi import APIRouter, Query
from app.schemas.safar import SafarAirQualityResponse
from app.services.safar_service import SafarService

router = APIRouter()


@router.get(
    "/safar",
    response_model=SafarAirQualityResponse,
    summary="Get IITM SAFAR & IMD AQEWS Air Quality Intelligence",
    description="Retrieves official CPCB 6-pollutant sub-indices, planetary boundary layer ventilation coefficient, stubble smoke tracking, and sensitive demographic medical guidance.",
)
async def get_safar_air_quality(
    latitude: float = Query(..., description="Latitude of user/station"),
    longitude: float = Query(..., description="Longitude of user/station"),
    location_name: str = Query("Location", description="Display location name"),
    city_code: Optional[str] = Query(None, description="Optional SAFAR city code (e.g., delhi, mumbai, pune, chennai)"),
):
    return SafarService.get_safar_air_quality(
        latitude=latitude,
        longitude=longitude,
        location_name=location_name,
        city_code=city_code,
    )
