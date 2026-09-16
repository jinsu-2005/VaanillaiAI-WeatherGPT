from typing import Optional
from fastapi import APIRouter, Query

from app.schemas.livestock_heat_stress import LivestockHeatStressResponse
from app.services.livestock_heat_stress_service import LivestockHeatStressService

router = APIRouter()


@router.get(
    "/livestock-heat-stress",
    response_model=LivestockHeatStressResponse,
    summary="ICAR-NDRI & IMD Dairy Livestock Microclimate & Temperature-Humidity Index (THI) Assessment",
    description="Provides real-time Thom/NRC Temperature-Humidity Index (THI), Black Globe Humidity Index (BGTHI), species-specific physiological thermal stress (Murrah buffalo, HF crossbred, Indigenous Zebu), projected milk yield deficit, and veterinary cooling directives across India's dairy corridors.",
)
async def get_livestock_heat_stress_assessment(
    latitude: Optional[float] = Query(None, description="Current latitude coordinate"),
    longitude: Optional[float] = Query(None, description="Current longitude coordinate"),
    basin_id: Optional[str] = Query(None, description="Specific dairy corridor basin slug (e.g., karnal_kurukshetra_hr, anand_kheda_amul_gj)"),
) -> LivestockHeatStressResponse:
    return LivestockHeatStressService.get_livestock_heat_stress_assessment(
        basin_id=basin_id,
        latitude=latitude,
        longitude=longitude,
    )
