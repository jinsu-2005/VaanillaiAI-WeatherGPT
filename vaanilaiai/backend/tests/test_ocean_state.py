import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.services.ocean_state_service import OceanStateService
from app.schemas.ocean_state import (
    WaveAlertTier,
    LifeguardFlagStatus,
    RipCurrentRiskLevel,
)


def test_ocean_state_service_default():
    assessment = OceanStateService.get_ocean_state_assessment()
    assert assessment is not None
    assert assessment.selected_beach.beach_id == "puri_golden_beach_or"
    assert assessment.selected_beach.state == "Odisha"
    assert assessment.selected_beach.alert_tier == WaveAlertTier.ORANGE_ALERT
    assert assessment.selected_beach.wave_metrics.significant_wave_height_m == 3.20
    assert assessment.selected_beach.wave_metrics.maximum_wave_height_m == 5.40
    assert assessment.selected_beach.rip_current.risk_level == RipCurrentRiskLevel.HIGH_DEADLY
    assert assessment.selected_beach.rip_current.peak_rip_velocity_ms == 1.45
    assert assessment.selected_beach.directives.lifeguard_flag == LifeguardFlagStatus.RED_HIGH_HAZARD
    assert len(assessment.all_beaches) == 7
    assert "en" in assessment.vernacular_broadcasts
    assert "or" in assessment.vernacular_broadcasts
    assert "ପୁରୀ" in assessment.vernacular_broadcasts["or"]


def test_ocean_state_service_by_id_kovalam():
    assessment = OceanStateService.get_ocean_state_assessment(beach_id="kovalam_vizhinjam_kl")
    assert assessment.selected_beach.beach_id == "kovalam_vizhinjam_kl"
    assert assessment.selected_beach.state == "Kerala"
    assert assessment.selected_beach.alert_tier == WaveAlertTier.RED_WARNING
    assert assessment.selected_beach.swell_surge.is_kallakkadal_active is True
    assert assessment.selected_beach.wave_metrics.peak_wave_period_s == 18.5
    assert assessment.selected_beach.directives.lifeguard_flag == LifeguardFlagStatus.DOUBLE_RED_PROHIBITED
    assert "ml" in assessment.vernacular_broadcasts
    assert "കള്ളക്കടൽ" in assessment.vernacular_broadcasts["ml"]


def test_ocean_state_geodetic_nearest_sector():
    # Near Panaji / Calangute Goa (15.54°N, 73.76°E)
    assessment = OceanStateService.get_ocean_state_assessment(latitude=15.54, longitude=73.76)
    assert assessment.selected_beach.beach_id == "baga_calangute_beach_ga"
    assert assessment.selected_beach.state == "Goa"
    assert assessment.selected_beach.alert_tier == WaveAlertTier.ORANGE_ALERT
    assert assessment.selected_beach.rip_current.peak_rip_velocity_ms == 1.35
    assert "mr" in assessment.vernacular_broadcasts
    assert "बागा" in assessment.vernacular_broadcasts["mr"]


@pytest.mark.asyncio
async def test_api_ocean_state_endpoint():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.get("/api/v1/alerts/ocean-state?beach_id=marina_elliots_beach_tn")
        assert response.status_code == 200
        data = response.json()
        assert data["selected_beach"]["beach_id"] == "marina_elliots_beach_tn"
        assert data["selected_beach"]["state"] == "Tamil Nadu"
        assert data["selected_beach"]["alert_tier"] == "YELLOW_WATCH"
        assert "ta" in data["vernacular_broadcasts"]
        assert "மெரினா" in data["vernacular_broadcasts"]["ta"]
