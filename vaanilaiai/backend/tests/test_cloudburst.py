import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.services.cloudburst_service import CloudburstService
from app.schemas.cloudburst import (
    CloudburstCategory,
    LandslideRiskTier,
    FlashFloodStage,
)


def test_cloudburst_service_default():
    assessment = CloudburstService.get_assessment()
    assert assessment is not None
    assert assessment.selected_catchment.catchment_id == "kedarnath_mandakini"
    assert assessment.selected_catchment.elevation_m == 3584
    assert assessment.selected_catchment.orographic_precipitation.cloudburst_category == CloudburstCategory.CLOUDBURST
    assert assessment.selected_catchment.orographic_precipitation.rain_rate_mm_hr >= 100.0
    assert assessment.selected_catchment.slope_stability.factor_of_safety < 1.0
    assert assessment.selected_catchment.slope_stability.landslide_risk_tier == LandslideRiskTier.CRITICAL_IMMINENT_FAILURE
    assert assessment.selected_catchment.hydrodynamics.flash_flood_stage == FlashFloodStage.CATASTROPHIC_DEBRIS_FLOW
    assert len(assessment.all_catchments) == 7
    assert "en" in assessment.vernacular_bulletins
    assert "hi" in assessment.vernacular_bulletins
    assert "मंदाकिनी" in assessment.vernacular_bulletins["hi"]


def test_cloudburst_service_by_id():
    assessment = CloudburstService.get_assessment(catchment_id="wayanad_vythiri_meppadi")
    assert assessment.selected_catchment.catchment_id == "wayanad_vythiri_meppadi"
    assert assessment.selected_catchment.state == "Kerala"
    assert assessment.selected_catchment.orographic_precipitation.accumulated_24h_mm == 372.0
    assert assessment.selected_catchment.slope_stability.factor_of_safety == 0.78
    assert "ml" in assessment.vernacular_bulletins
    assert "ചൂരൽമല" in assessment.vernacular_bulletins["ml"]


def test_cloudburst_geodetic_nearest_catchment():
    # Coordinates near Nilgiris / Ooty (11.41°N, 76.70°E)
    assessment = CloudburstService.get_assessment(latitude=11.41, longitude=76.70)
    assert assessment.selected_catchment.catchment_id == "nilgiris_coonoor_ooty"
    assert assessment.selected_catchment.state == "Tamil Nadu"
    assert "ta" in assessment.vernacular_bulletins
    assert "நீலகிரி" in assessment.vernacular_bulletins["ta"]


@pytest.mark.asyncio
async def test_api_cloudburst_endpoint():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.get("/api/v1/alerts/cloudburst?catchment_id=kullu_manali_beas")
        assert response.status_code == 200
        data = response.json()
        assert data["selected_catchment"]["catchment_id"] == "kullu_manali_beas"
        assert data["selected_catchment"]["mountain_range"] == "Pir Panjal & Higher Himalayas"
        assert data["selected_catchment"]["orographic_precipitation"]["rain_rate_mm_hr"] == 104.0
        assert data["selected_catchment"]["slope_stability"]["factor_of_safety"] == 0.91
        assert "Solang" in data["vernacular_bulletins"]["en"]
        assert "provenance" in data
