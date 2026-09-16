from typing import Optional
from fastapi import APIRouter, Query
from app.schemas.drought import AgriculturalDroughtResponse
from app.services.drought_service import drought_service

router = APIRouter()


@router.get(
    "/drought-assessment",
    response_model=AgriculturalDroughtResponse,
    summary="IMD & CGWB Agricultural Drought, Soil Moisture Stress & Groundwater Vulnerability Assessment",
    description=(
        "Retrieves multi-tier drought telemetry integrating IMD Standardized Precipitation Index (SPI-1, SPI-3, SPI-6), "
        "Root Zone Soil Moisture (RZSM %), Crop Water Stress Index (CWSI), Central Ground Water Board (CGWB) Stage of "
        "Ground Water Extraction (SOE %), aquifer vulnerability, ICAR-CRIDA agronomic mitigation directives, and 5-language "
        "vernacular bulletins (English, Hindi, Marathi, Telugu, Kannada)."
    ),
)
async def get_drought_assessment(
    latitude: Optional[float] = Query(None, description="User latitude for geodetic nearest rainfed tract matching"),
    longitude: Optional[float] = Query(None, description="User longitude for geodetic nearest rainfed tract matching"),
    hotspot_id: Optional[str] = Query(None, description="Optional specific drought hotspot ID (e.g., marathwada_latur, rayalaseema_anantapur)"),
) -> AgriculturalDroughtResponse:
    return drought_service.get_drought_assessment(
        latitude=latitude,
        longitude=longitude,
        hotspot_id=hotspot_id,
    )
