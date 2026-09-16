from typing import Optional
from fastapi import APIRouter, Query

from app.schemas.crop_water_stress import CropWaterStressResponse
from app.services.crop_water_stress_service import CropWaterStressService

router = APIRouter()


@router.get(
    "/crop-water-stress",
    response_model=CropWaterStressResponse,
    summary="ICAR-CRIDA & IMD Crop Water Stress Index (CWSI) & Soil Moisture Alert",
    description="Provides multi-depth volumetric soil moisture (0-10cm, 10-40cm, 40-100cm), FAO-56 Penman-Monteith evapotranspiration, infrared canopy-to-air temperature departures, and precision deficit irrigation directives across India's agro-climatic zones.",
)
async def get_crop_water_stress_assessment(
    latitude: Optional[float] = Query(None, description="Current latitude coordinate"),
    longitude: Optional[float] = Query(None, description="Current longitude coordinate"),
    zone_id: Optional[str] = Query(None, description="Specific agro-climatic zone slug (e.g. vidarbha_cotton_vertisol, punjab_wheat_rice_alluvium)"),
) -> CropWaterStressResponse:
    return CropWaterStressService.get_assessment(
        latitude=latitude,
        longitude=longitude,
        zone_id=zone_id,
    )
