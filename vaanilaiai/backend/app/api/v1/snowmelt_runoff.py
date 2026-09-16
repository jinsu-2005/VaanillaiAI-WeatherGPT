"""FastAPI router for IMD, CWC & DGRE Himalayan Snowmelt Runoff,
Snow Cover Area (SCA) & Glacial Hydrology Engine (SNOWMELT-HYDRO).
"""

from typing import Optional
from fastapi import APIRouter, Query
from app.schemas.snowmelt_runoff import SnowmeltRunoffResponse
from app.services.snowmelt_runoff_service import SnowmeltRunoffService

router = APIRouter(tags=["Himalayan Snowmelt Hydrology"])


@router.get(
    "/snowmelt-runoff",
    response_model=SnowmeltRunoffResponse,
    summary="Get Himalayan snowmelt runoff, snow cover area (SCA) & hydropower inflow assessment",
    description=(
        "Returns Martinec-Rango SRM snowmelt discharge rates, elevation zonal degree-day "
        "melting volumes, cryospheric snow line & freezing level isotherms, downstream dam "
        "inflow telemetry (Bhakra, Tehri, Salal, Pong, Uri, Teesta, Subansiri), and 7-language "
        "vernacular mountain catchment bulletins."
    ),
)
async def get_snowmelt_runoff(
    basin_id: Optional[str] = Query(
        default=None,
        description="Optional slug for Himalayan catchment (e.g. 'satluj_bhakra', 'bhagirathi_tehri')",
    )
) -> SnowmeltRunoffResponse:
    """Retrieve operational snowmelt runoff and glacial hydrology metrics."""
    return SnowmeltRunoffService.get_assessment(basin_id=basin_id)
