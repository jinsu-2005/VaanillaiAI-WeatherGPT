import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.services.storm_surge_service import StormSurgeService
from app.schemas.storm_surge import (
    SurgeThreatTier,
    TidalPhaseType,
)


def test_storm_surge_service_default():
    assessment = StormSurgeService.get_storm_surge_assessment()
    assert assessment is not None
    assert assessment.selected_sector.sector_id == "sundarbans_wb"
    assert assessment.selected_sector.threat_tier == SurgeThreatTier.EMERGENCY_RED
    assert assessment.selected_sector.tidal_phase == TidalPhaseType.SPRING_HIGH_TIDE
    assert assessment.selected_sector.hydrodynamics.total_water_level_m == 7.60
    assert assessment.selected_sector.hydrodynamics.overtopping_depth_m == 1.40
    assert assessment.selected_sector.tidal_bore.bore_phenomenon_active is True
    assert assessment.selected_sector.tidal_bore.bore_height_m == 2.20
    assert assessment.selected_sector.inundation.max_inland_intrusion_km == 4.80
    assert assessment.selected_sector.inundation.embankment_breaches_reported == 5
    assert len(assessment.all_sectors) == 7
    assert "en" in assessment.vernacular_bulletins
    assert "bn" in assessment.vernacular_bulletins
    assert "সুন্দরবন" in assessment.vernacular_bulletins["bn"]


def test_storm_surge_service_by_id():
    assessment = StormSurgeService.get_storm_surge_assessment(sector_id="paradeep_mahanadi_or")
    assert assessment.selected_sector.sector_id == "paradeep_mahanadi_or"
    assert assessment.selected_sector.state == "Odisha"
    assert assessment.selected_sector.threat_tier == SurgeThreatTier.EMERGENCY_RED
    assert assessment.selected_sector.hydrodynamics.total_water_level_m == 6.80
    assert assessment.selected_sector.inundation.estimated_inundated_area_sq_km == 142.0
    assert "or" in assessment.vernacular_bulletins
    assert "ମହାନଦୀ" in assessment.vernacular_bulletins["or"]


def test_storm_surge_geodetic_nearest_sector():
    # Near Bhavnagar / Gulf of Khambhat (21.75°N, 72.30°E)
    assessment = StormSurgeService.get_storm_surge_assessment(latitude=21.75, longitude=72.30)
    assert assessment.selected_sector.sector_id == "gulf_of_khambhat_gj"
    assert assessment.selected_sector.state == "Gujarat"
    assert assessment.selected_sector.threat_tier == SurgeThreatTier.WARNING_ORANGE
    assert assessment.selected_sector.tidal_bore.bore_height_m == 2.70
    assert "gu" in assessment.vernacular_bulletins
    assert "ખંભાત" in assessment.vernacular_bulletins["gu"]


@pytest.mark.asyncio
async def test_api_storm_surge_endpoint():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.get("/api/v1/alerts/storm-surge?sector_id=alappuzha_kuttanad_kl")
        assert response.status_code == 200
        data = response.json()
        assert data["selected_sector"]["sector_id"] == "alappuzha_kuttanad_kl"
        assert data["selected_sector"]["state"] == "Kerala"
        assert data["selected_sector"]["threat_tier"] == "WATCH_YELLOW"
        assert "ml" in data["vernacular_bulletins"]
        assert "തണ്ണീർമുക്കം" in data["vernacular_bulletins"]["ml"]
