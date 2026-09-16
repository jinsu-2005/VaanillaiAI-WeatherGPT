from typing import Optional
from fastapi import APIRouter, Query

from app.schemas.solar_energy import SolarEnergyResponse
from app.services.solar_energy_service import SolarEnergyService

router = APIRouter()


@router.get(
    "/solar-energy",
    response_model=SolarEnergyResponse,
    summary="NISE, MNRE & IMD Solar Radiation, Photovoltaic (PV) Yield & Rooftop Solar Assessment",
    description=(
        "Provides Global Horizontal Irradiance (GHI), DNI, DHI, PV cell temperature, "
        "thermal efficiency derating, dust soiling loss, PM Surya Ghar rooftop solar generation, "
        "discom cost savings, and panel washing guidance across major Indian solar regions."
    ),
)
async def get_solar_energy_assessment(
    latitude: Optional[float] = Query(None, description="User latitude coordinate"),
    longitude: Optional[float] = Query(None, description="User longitude coordinate"),
    park_id: Optional[str] = Query(None, description="Specific solar park slug (e.g. bhadla_rajasthan, delhi_ncr_rooftop)"),
) -> SolarEnergyResponse:
    return SolarEnergyService.get_solar_energy_assessment(
        park_id=park_id,
        latitude=latitude,
        longitude=longitude,
    )
