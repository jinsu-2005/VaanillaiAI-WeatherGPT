from typing import Optional
from fastapi import APIRouter, Query
from app.schemas.extended_range_prediction import ErpResponse
from app.services.extended_range_prediction_service import ExtendedRangePredictionService

router = APIRouter()


@router.get(
    "/extended-range",
    response_model=ErpResponse,
    summary="IMD, NCMRWF & IITM Extended Range Prediction (ERP) & Intra-Seasonal Pulse",
    description=(
        "Returns multi-model ensemble (MME) 4-week rainfall Long Period Average (LPA) departure forecasts, "
        "temperature anomalies, Boreal Summer Intra-Seasonal Oscillation (BSISO) & Madden-Julian Oscillation (MJO) "
        "convective phase telemetry, active vs break spell classifications, and ICAR-CRIDA district contingency plans."
    ),
)
async def get_extended_range_prediction(
    zone_id: Optional[str] = Query(
        None,
        description="Agro-climatic zone slug (vidarbha_central_rainfed, indo_gangetic_breadbasket, eastern_gangetic_rice_basin, southern_peninsular_millet, konkan_malabar_coastal, northeastern_brahmaputra_fluvial, western_arid_coarse_grain)",
    ),
    latitude: Optional[float] = Query(None, description="Farm or district centroid latitude for nearest geodetic zone matching"),
    longitude: Optional[float] = Query(None, description="Farm or district centroid longitude for nearest geodetic zone matching"),
    language: str = Query("en", description="Vernacular bulletin language: en, hi, mr, te, pa, bn, gu, kn"),
) -> ErpResponse:
    """Retrieve 4-week Extended Range Prediction, BSISO/MJO dynamics, and ICAR contingency directives."""
    return ExtendedRangePredictionService.get_extended_range_assessment(
        zone_id=zone_id,
        latitude=latitude,
        longitude=longitude,
        language=language,
    )
