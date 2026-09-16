from typing import Optional
from fastapi import APIRouter, Query

from app.schemas.glof import GlofResponse
from app.services.glof_service import GlofService

router = APIRouter()


@router.get(
    "/glof",
    response_model=GlofResponse,
    summary="NRSC-ISRO, CWC & NDMA Himalayan Glacial Lake Outburst Flood (GLOF) Early Warning",
    description=(
        "Provides satellite SAR glacial lake expansion monitoring, moraine dam geotechnical piping and overtopping stability, "
        "peak breach outflow discharge (Qp), downstream flood wave propagation velocities and ETAs, hydropower barrage "
        "gate triggers, and multi-lingual mountain evacuation directives across 7 vulnerable Himalayan glacial lakes."
    ),
)
async def get_glof_assessment(
    latitude: Optional[float] = Query(None, description="User latitude coordinate"),
    longitude: Optional[float] = Query(None, description="User longitude coordinate"),
    lake_id: Optional[str] = Query(None, description="Specific glacial lake slug (e.g. south_lhonak_sikkim, chorabari_uttarakhand)"),
) -> GlofResponse:
    return GlofService.get_assessment(
        lake_id=lake_id,
        latitude=latitude,
        longitude=longitude,
    )
