import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.services.tsunami_service import TsunamiService
from app.schemas.tsunami import (
    TsunamiAlertTier,
    TsunamigenicSubductionZone,
)


def test_tsunami_service_default():
    assessment = TsunamiService.get_assessment()
    assert assessment is not None
    assert assessment.selected_sector.sector_id == "andaman_nicobar_islands"
    assert assessment.selected_sector.alert_tier == TsunamiAlertTier.WARNING_RED
    assert assessment.selected_sector.seismic_source.moment_magnitude_mw == 8.4
    assert assessment.selected_sector.seismic_source.subduction_zone == TsunamigenicSubductionZone.ANDAMAN_SUMATRA_TRENCH
    assert assessment.selected_sector.wave_metrics.maximum_expected_wave_amplitude_m == 4.2
    assert assessment.selected_sector.wave_metrics.time_to_first_wave_minutes == 28
    assert len(assessment.selected_sector.dart_buoys) == 2
    assert assessment.selected_sector.dart_buoys[0].buoy_id == "BPR-TB02"
    assert assessment.selected_sector.dart_buoys[0].is_event_mode_triggered is True
    assert len(assessment.selected_sector.tide_gauges) == 2
    assert len(assessment.all_sectors) == 7
    assert "en" in assessment.vernacular_bulletins
    assert "ta" in assessment.vernacular_bulletins
    assert "சுனாமி" in assessment.vernacular_bulletins["ta"]


def test_tsunami_service_by_id():
    assessment = TsunamiService.get_assessment(sector_id="tamil_nadu_coromandel_coast")
    assert assessment.selected_sector.sector_id == "tamil_nadu_coromandel_coast"
    assert assessment.selected_sector.state == "Tamil Nadu & Puducherry"
    assert assessment.selected_sector.alert_tier == TsunamiAlertTier.WARNING_RED
    assert assessment.selected_sector.wave_metrics.maximum_expected_wave_amplitude_m == 2.8
    assert assessment.selected_sector.wave_metrics.time_to_first_wave_minutes == 115
    assert assessment.selected_sector.evacuation_directives.vertical_evacuation_altitude_m == 15.0
    assert "ta" in assessment.vernacular_bulletins
    assert "நாகப்பட்டினம்" in assessment.vernacular_bulletins["ta"]


def test_tsunami_geodetic_nearest_sector():
    # Coordinates near Kochi / Alappuzha, Kerala (9.95°N, 76.25°E)
    assessment = TsunamiService.get_assessment(latitude=9.95, longitude=76.25)
    assert assessment.selected_sector.sector_id == "kerala_malabar_coast"
    assert assessment.selected_sector.state == "Kerala"
    assert assessment.selected_sector.alert_tier == TsunamiAlertTier.ALERT_ORANGE
    assert "ml" in assessment.vernacular_bulletins
    assert "സുനാമി" in assessment.vernacular_bulletins["ml"]


@pytest.mark.asyncio
async def test_api_tsunami_endpoint():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.get("/api/v1/alerts/tsunami-warning?sector_id=lakshadweep_archipelago")
        assert response.status_code == 200
        data = response.json()
        assert data["selected_sector"]["sector_id"] == "lakshadweep_archipelago"
        assert data["selected_sector"]["state"] == "Lakshadweep (UT)"
        assert data["selected_sector"]["alert_tier"] == "ALERT_ORANGE"
        assert data["selected_sector"]["wave_metrics"]["maximum_expected_wave_amplitude_m"] == 1.2
        assert "provenance" in data
        assert "INCOIS" in data["provenance"]
        assert "ITEWS" in data["provenance"]
