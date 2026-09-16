"""FastAPI router for IMD & CWC Flash Drought, Rapid Soil Desiccation
& Atmospheric Evaporative Demand Engine (FLASH-DROUGHT).
"""

from typing import Optional
from fastapi import APIRouter, Query
from app.schemas.flash_drought import FlashDroughtResponse
from app.services.flash_drought_service import FlashDroughtService

router = APIRouter(tags=["Flash Drought & Atmospheric Evaporative Demand"])


@router.get(
    "/flash-drought",
    response_model=FlashDroughtResponse,
    summary="Get IMD & CWC Flash Drought, Soil Desiccation & EDDI Assessment",
    description=(
        "Returns FAO-56 Penman-Monteith atmospheric evaporative demand (E0), Evaporative "
        "Demand Drought Index (EDDI), 2-depth soil volumetric water content (VWC), desiccation "
        "velocity (percentiles/week), rapid intensification detection, phenological crop "
        "vulnerability, ICAR-CRIDA anti-transpirant / pulse irrigation directives, and 7-language "
        "vernacular bulletins."
    ),
)
async def get_flash_drought(
    hotspot_id: Optional[str] = Query(
        default=None,
        description="Optional hotspot identifier (e.g. 'VIDARBHA_HOTSPOT', 'MARATHWADA_HOTSPOT', 'RAYALASEEMA_BASIN')",
    ),
    lat: Optional[float] = Query(
        default=None,
        description="Optional latitude to locate nearest rainfed flash drought hotspot",
    ),
    lon: Optional[float] = Query(
        default=None,
        description="Optional longitude to locate nearest rainfed flash drought hotspot",
    ),
) -> FlashDroughtResponse:
    """Retrieve operational flash drought, soil moisture desiccation, and EDDI telemetry."""
    return FlashDroughtService.get_flash_drought_assessment(hotspot_id=hotspot_id, lat=lat, lon=lon)
