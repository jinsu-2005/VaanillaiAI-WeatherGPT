"""FastAPI router for IMD & ICAR Post-Harvest Mandi Weather Defense,
Grain Moisture & Open-Godown Spoilage Engine (AGRI-STORAGE).
"""

from typing import Optional
from fastapi import APIRouter, Query
from app.schemas.agri_storage import AgriStorageResponse
from app.services.agri_storage_service import AgriStorageService

router = APIRouter(tags=["Mandi Grain Storage & Moisture Defense"])


@router.get(
    "/agri-storage",
    response_model=AgriStorageResponse,
    summary="Get IMD & ICAR Post-Harvest Mandi Weather Defense & Grain Moisture Assessment",
    description=(
        "Returns modified Henderson-Thompson Equilibrium Moisture Content (EMC) calculations, "
        "Aspergillus flavus / Aflatoxin B1 fungal bio-hazard kinetics, open-plinth yard "
        "waterlogging and wind risk telemetry, mandatory wooden dunnage pallet & HDPE tarpaulin "
        "(tirpal) directives, and 7-language localized advisories."
    ),
)
async def get_agri_storage(
    mandi_id: Optional[str] = Query(
        default=None,
        description="Optional APMC mandi identifier (e.g. 'KHANNA_APMC', 'KARNAL_APMC', 'NEEMUCH_APMC')",
    ),
    lat: Optional[float] = Query(
        default=None,
        description="Optional latitude to locate nearest APMC mandi hub",
    ),
    lon: Optional[float] = Query(
        default=None,
        description="Optional longitude to locate nearest APMC mandi hub",
    ),
) -> AgriStorageResponse:
    """Retrieve operational post-harvest mandi storage defense and grain moisture telemetry."""
    return AgriStorageService.get_agri_storage_assessment(mandi_id=mandi_id, lat=lat, lon=lon)
