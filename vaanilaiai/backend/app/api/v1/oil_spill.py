from typing import Optional
from fastapi import APIRouter, Query

from app.schemas.oil_spill import OilSpillResponse
from app.services.oil_spill_service import OilSpillService

router = APIRouter()
_service = OilSpillService()


@router.get(
    "/oil-spill",
    response_model=OilSpillResponse,
    summary="INCOIS & Indian Coast Guard Marine Oil Spill Trajectory & Coastal Ecology Engine",
    description=(
        "Calculates coupled ocean-current and wind-drift advection vectors (3% leeway), Fay's 3-regime surface spreading, "
        "chemical weathering & mousse emulsification, coastal Environmental Sensitivity Index (ESI 1-10) protection, "
        "and Indian Coast Guard National Oil Spill Disaster Contingency Plan (NOS-DCP) Tier 1/2/3 response directives "
        "across 7 critical Indian maritime corridors."
    ),
)
async def get_oil_spill_assessment(
    corridor_id: Optional[str] = Query(
        None,
        description="Unique corridor slug (e.g. gulf_of_kutch_vadinar, mumbai_harbour_uran, gulf_of_mannar_pamban)",
    ),
    latitude: Optional[float] = Query(None, description="User or vessel latitude coordinate"),
    longitude: Optional[float] = Query(None, description="User or vessel longitude coordinate"),
) -> OilSpillResponse:
    return _service.get_oil_spill_assessment(
        corridor_id=corridor_id,
        latitude=latitude,
        longitude=longitude,
    )
