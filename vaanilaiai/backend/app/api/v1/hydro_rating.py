"""FastAPI router for IMD & CWC National Flood Forecasting,
Hydrological Rating Curve & Embankment Breach Telemetry Engine (HYDRO-RATING).
"""

from typing import Optional
from fastapi import APIRouter, Query
from app.schemas.hydro_rating import HydroRatingResponse
from app.services.hydro_rating_service import HydroRatingService

router = APIRouter(tags=["CWC Flood Forecasting & Hydrological Rating Curves"])


@router.get(
    "/rating-curve",
    response_model=HydroRatingResponse,
    summary="Get CWC flood forecasting, stage-discharge rating curve & embankment breach telemetry",
    description=(
        "Returns non-linear stage-discharge rating curve computations (Q = a(h - h0)^b), "
        "Manning open-channel conveyance velocity, levee freeboard margin safety, exit hydraulic "
        "gradient piping instability risk (FS = icrit / i), Gumbel flood frequency recurrence "
        "intervals, and 7-language riparian evacuation bulletins across major Indian river basins."
    ),
)
async def get_hydro_rating(
    basin_id: Optional[str] = Query(
        default=None,
        description="Optional slug for river basin gauge station (e.g. 'kosi_baltara', 'brahmaputra_pandu')",
    ),
    lat: Optional[float] = Query(
        default=None,
        ge=-90.0,
        le=90.0,
        description="Optional latitude for nearest river gauge lookup",
    ),
    lon: Optional[float] = Query(
        default=None,
        ge=-180.0,
        le=180.0,
        description="Optional longitude for nearest river gauge lookup",
    ),
) -> HydroRatingResponse:
    """Retrieve operational hydrological rating curve and embankment telemetry."""
    return HydroRatingService.get_assessment(basin_id=basin_id, lat=lat, lon=lon)
