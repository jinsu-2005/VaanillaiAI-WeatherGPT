from typing import Optional
from fastapi import APIRouter, Query

from app.schemas.hazmat import HazmatDispersionResponse
from app.services.hazmat_service import HazmatService

router = APIRouter()


@router.get(
    "/hazmat-dispersion",
    response_model=HazmatDispersionResponse,
    summary="CPCB & IMD Industrial Hazmat Plume Dispersion Nowcast",
    description="Provides real-time atmospheric dispersion modeling, Gaussian plume footprint, AEGL exposure levels, and emergency response directives for chemical industrial corridors.",
)
async def get_hazmat_dispersion_assessment(
    latitude: Optional[float] = Query(None, description="Current latitude coordinate"),
    longitude: Optional[float] = Query(None, description="Current longitude coordinate"),
    cluster_id: Optional[str] = Query(None, description="Industrial chemical cluster slug (e.g. dahej_pcpir_gujarat, manali_industrial_corridor_chennai)"),
    gas_species: Optional[str] = Query(None, description="Specific toxic gas species (e.g. CHLORINE_CL2, AMMONIA_NH3)"),
) -> HazmatDispersionResponse:
    return HazmatService.get_assessment(
        latitude=latitude,
        longitude=longitude,
        cluster_id=cluster_id,
        gas_species=gas_species,
    )
