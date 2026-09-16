import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.services.heat_action_plan_service import HeatActionPlanService
from app.schemas.heat_action_plan import (
    HapTriggerAlertTier,
    UvIndexCategory,
)


def test_heat_action_plan_service_default():
    assessment = HeatActionPlanService.get_assessment()
    assert assessment is not None
    assert assessment.selected_zone.zone_id == "phalodi_churu_thar"
    assert assessment.selected_zone.state == "Rajasthan"
    assert assessment.selected_zone.alert_tier == HapTriggerAlertTier.EXTREME_HEAT_RED
    assert assessment.selected_zone.thermal_metrics.max_temp_c == 49.8
    assert assessment.selected_zone.thermal_metrics.departure_c == 7.8
    assert assessment.selected_zone.uv_metrics.uv_index == 13.5
    assert assessment.selected_zone.uv_metrics.uv_category == UvIndexCategory.EXTREME
    assert assessment.selected_zone.municipal_directives.cool_roof_initiative_active is True
    assert assessment.selected_zone.municipal_directives.emergency_cooling_ice_bath_ready is True
    assert len(assessment.all_zones) == 7
    assert "en" in assessment.vernacular_bulletins
    assert "hi" in assessment.vernacular_bulletins
    assert "फलोदी" in assessment.vernacular_bulletins["hi"]


def test_heat_action_plan_service_by_id():
    assessment = HeatActionPlanService.get_assessment(zone_id="ahmedabad_metropolitan")
    assert assessment.selected_zone.zone_id == "ahmedabad_metropolitan"
    assert assessment.selected_zone.state == "Gujarat"
    assert assessment.selected_zone.alert_tier == HapTriggerAlertTier.SEVERE_HEAT_ALERT_ORANGE
    assert assessment.selected_zone.thermal_metrics.max_temp_c == 44.2
    assert assessment.selected_zone.municipal_directives.active_pyau_water_stations == 420
    assert "gu" in assessment.vernacular_bulletins
    assert "અમદાવાદ" in assessment.vernacular_bulletins["gu"]


def test_heat_action_plan_geodetic_nearest_zone():
    # Coordinates near Titlagarh / Bolangir, Odisha (20.30°N, 83.15°E)
    assessment = HeatActionPlanService.get_assessment(latitude=20.30, longitude=83.15)
    assert assessment.selected_zone.zone_id == "titlagarh_jharsuguda_belt"
    assert assessment.selected_zone.state == "Odisha"
    assert assessment.selected_zone.alert_tier == HapTriggerAlertTier.EXTREME_HEAT_RED
    assert "or" in assessment.vernacular_bulletins
    assert "ଟିଟିଲାଗଡ଼" in assessment.vernacular_bulletins["or"]


@pytest.mark.asyncio
async def test_api_heat_action_plan_endpoint():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.get("/api/v1/alerts/heat-action-plan?zone_id=ramagundam_hyderabad_deccan")
        assert response.status_code == 200
        data = response.json()
        assert data["selected_zone"]["zone_id"] == "ramagundam_hyderabad_deccan"
        assert data["selected_zone"]["state"] == "Telangana"
        assert data["selected_zone"]["alert_tier"] == "SEVERE_HEAT_ALERT_ORANGE"
        assert data["selected_zone"]["thermal_metrics"]["max_temp_c"] == 44.8
        assert data["selected_zone"]["uv_metrics"]["uv_category"] == "EXTREME"
        assert "provenance" in data
        assert "NDMA" in data["provenance"]
