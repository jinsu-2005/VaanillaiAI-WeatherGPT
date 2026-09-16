from typing import Optional
from fastapi import APIRouter, Query

from app.schemas.lightning_cell import LightningCellResponse
from app.services.lightning_cell_service import lightning_cell_service

router = APIRouter()


@router.get(
    "/lightning-density",
    response_model=LightningCellResponse,
    summary="IITM & IMD Lightning Flash Density, Cell Lifecycle & Downburst Nowcasting",
    description=(
        "Provides total lightning rate (IC vs CG), Gatlin-Goodman Lightning Jump downburst nowcasts, "
        "Doppler dual-pol radar hydrometeor classification, and NDMA agricultural field safety directives."
    ),
)
async def get_lightning_density_assessment(
    corridor_id: Optional[str] = Query(None, description="Hotspot corridor ID (e.g., mayurbhanj_odisha, gangetic_bengal)"),
    latitude: Optional[float] = Query(None, description="Observer latitude"),
    longitude: Optional[float] = Query(None, description="Observer longitude"),
    language: str = Query("en", description="Target language code (en, hi, od, bn, te, mr, as)"),
) -> LightningCellResponse:
    return await lightning_cell_service.get_assessment(
        corridor_id=corridor_id,
        latitude=latitude,
        longitude=longitude,
        language=language,
    )
