from typing import Optional
from fastapi import APIRouter, Query
from app.schemas.marine_heatwave import MarineHeatwaveResponse
from app.services.marine_heatwave_service import marine_heatwave_service

router = APIRouter()


@router.get(
    "/marine-heatwave",
    response_model=MarineHeatwaveResponse,
    summary="INCOIS Marine Heatwave, Coral Bleaching & Coastal Sea Fog Assessment",
    description=(
        "Retrieves operational oceanographic thermal stress telemetry, Degree Heating Weeks (DHW), "
        "Marine Heatwave (MHW) categorization (Hobday et al.), coral bleaching alert levels, "
        "coastal advection sea fog risk for ports, and 5-language vernacular coastal directives."
    ),
)
async def get_marine_heatwave_assessment(
    latitude: Optional[float] = Query(None, description="User latitude for geodetic nearest marine sector matching"),
    longitude: Optional[float] = Query(None, description="User longitude for geodetic nearest marine sector matching"),
    sector_id: Optional[str] = Query(None, description="Optional specific marine sector ID (e.g., gulf_of_mannar_rameshwaram, lakshadweep_kavaratti)"),
) -> MarineHeatwaveResponse:
    return marine_heatwave_service.get_marine_heatwave_assessment(
        latitude=latitude,
        longitude=longitude,
        sector_id=sector_id,
    )
