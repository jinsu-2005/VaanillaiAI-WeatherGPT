"""FastAPI router for IMD, INCOIS & CGWB Coastal Estuarine Saltwater Intrusion,
Tidal Prism & Groundwater Salinization Engine (SALTWATER-TIDE).
"""

from typing import Optional
from fastapi import APIRouter, Query
from app.schemas.saltwater_intrusion import SaltwaterIntrusionResponse
from app.services.saltwater_intrusion_service import SaltwaterIntrusionService

router = APIRouter(tags=["Coastal Salinity & Estuarine Hydrology"])


@router.get(
    "/saltwater-intrusion",
    response_model=SaltwaterIntrusionResponse,
    summary="Get coastal estuarine saline wedge penetration, aquifer lens & salinization telemetry",
    description=(
        "Returns Ghyben-Herzberg coastal aquifer freshwater lens depth (z = 40 * hf), "
        "two-layer estuarine saline wedge penetration distance (Lwedge in km), groundwater "
        "mineralization (EC, TDS, SAR), tidal prism phase, and ICAR-CSSRI halophytic agricultural "
        "and sluice gate operational directives across India's coastal deltaic regions."
    ),
)
async def get_saltwater_intrusion(
    zone_id: Optional[str] = Query(
        default=None,
        description="Optional slug for coastal estuarine zone (e.g. 'sundarbans_delta', 'cauvery_delta')",
    ),
    lat: Optional[float] = Query(
        default=None,
        ge=-90.0,
        le=90.0,
        description="Optional latitude for nearest coastal zone lookup",
    ),
    lon: Optional[float] = Query(
        default=None,
        ge=-180.0,
        le=180.0,
        description="Optional longitude for nearest coastal zone lookup",
    ),
) -> SaltwaterIntrusionResponse:
    """Retrieve operational coastal saltwater intrusion and aquifer salinization assessment."""
    return SaltwaterIntrusionService.get_assessment(zone_id=zone_id, lat=lat, lon=lon)
