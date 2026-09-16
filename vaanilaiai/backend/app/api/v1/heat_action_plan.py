from typing import Optional
from fastapi import APIRouter, Query

from app.schemas.heat_action_plan import HeatActionPlanResponse
from app.services.heat_action_plan_service import HeatActionPlanService

router = APIRouter()


@router.get(
    "/heat-action-plan",
    response_model=HeatActionPlanResponse,
    summary="NDMA & IMD National Heat Action Plan (HAP) & Solar UV Alert",
    description="Provides real-time municipal color-coded heat triggers (Yellow/Orange/Red), Global Solar UV Index photobiology, cool roof SRI, and occupational labor protection directives.",
)
async def get_heat_action_plan_assessment(
    latitude: Optional[float] = Query(None, description="Current latitude coordinate"),
    longitude: Optional[float] = Query(None, description="Current longitude coordinate"),
    zone_id: Optional[str] = Query(None, description="Specific heatwave hotspot zone slug (e.g. phalodi_churu_thar, ahmedabad_metropolitan)"),
) -> HeatActionPlanResponse:
    return HeatActionPlanService.get_assessment(
        latitude=latitude,
        longitude=longitude,
        zone_id=zone_id,
    )
