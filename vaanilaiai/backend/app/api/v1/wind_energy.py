from typing import Optional
from fastapi import APIRouter, Query

from app.schemas.wind_energy import WindEnergyResponse
from app.services.wind_energy_service import WindEnergyService

router = APIRouter()


@router.get(
    "/wind-energy",
    response_model=WindEnergyResponse,
    summary="NIWE, MNRE & IMD National Wind Resource Assessment, Hub-Height Shear & Wind Farm Forecasting",
    description=(
        "Provides power-law hub-height shear extrapolation (10m to 150m), Wind Power Density (WPD), "
        "thermal-barometric air density corrections, utility turbine power curve generation (2.0 MW vs 3.0 MW), "
        "wake losses, Capacity Utilization Factor (CUF %), and repowering feasibility across 7 Indian wind energy corridors."
    ),
)
async def get_wind_energy_assessment(
    latitude: Optional[float] = Query(None, description="User latitude coordinate"),
    longitude: Optional[float] = Query(None, description="User longitude coordinate"),
    corridor_id: Optional[str] = Query(None, description="Specific wind corridor slug (e.g. muppandal_tamil_nadu, jaisalmer_rajasthan)"),
) -> WindEnergyResponse:
    return WindEnergyService.get_assessment(
        corridor_id=corridor_id,
        latitude=latitude,
        longitude=longitude,
    )
