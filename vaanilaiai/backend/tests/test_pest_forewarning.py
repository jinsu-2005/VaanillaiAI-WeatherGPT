import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.services.pest_forewarning_service import PestForewarningService
from app.schemas.pest_forewarning import (
    PestRiskLevel,
    EpidemicCondition,
    PestForewarningResponse,
)

client = TestClient(app)


def test_pest_forewarning_service_default():
    """Verify default pest forewarning assessment schema, microclimate telemetry, and non-empty alerts."""
    resp = PestForewarningService.get_pest_forewarning()
    assert isinstance(resp, PestForewarningResponse)
    assert resp.zone.zone_id == 6  # Trans-Gangetic Plains
    assert len(resp.alerts) >= 5
    assert len(resp.all_zones) == 15
    assert resp.highest_risk_level in [PestRiskLevel.HIGH, PestRiskLevel.CRITICAL]
    assert "en" in resp.multilingual_bulletins
    assert "hi" in resp.multilingual_bulletins
    assert "pa" in resp.multilingual_bulletins
    assert "te" in resp.multilingual_bulletins
    assert "ta" in resp.multilingual_bulletins
    assert len(resp.ipm_calendar_actions) >= 4


def test_epidemiological_models_physics():
    """Verify mathematical & biological infection thresholds across major crop pathogens."""
    # 1. Wallin's Potato Late Blight
    # Conducive: 16°C, RH 92%, Leaf Wetness 12h -> CRITICAL
    risk_plb, cond_plb, _ = PestForewarningService.evaluate_potato_late_blight(16.0, 92.0, 12.0)
    assert risk_plb == PestRiskLevel.CRITICAL
    assert cond_plb == EpidemicCondition.FAVORABLE

    # Hostile: 32°C, RH 45%, Leaf Wetness 1h -> LOW
    risk_plb_dry, cond_plb_dry, _ = PestForewarningService.evaluate_potato_late_blight(32.0, 45.0, 1.0)
    assert risk_plb_dry == PestRiskLevel.LOW
    assert cond_plb_dry == EpidemicCondition.UNFAVORABLE

    # 2. Mustard Aphid Thermal Degree-Day Model
    # Overcast, foggy, 14°C, RH 85%, GDD 190 -> CRITICAL
    risk_aphid, cond_aphid, _ = PestForewarningService.evaluate_mustard_aphid(14.0, 85.0, 6, 195.0)
    assert risk_aphid == PestRiskLevel.CRITICAL
    assert cond_aphid == EpidemicCondition.FAVORABLE

    # 3. Rice Blast
    # 24°C, RH 90%, Leaf Wetness 11h -> CRITICAL
    risk_blast, cond_blast, _ = PestForewarningService.evaluate_rice_blast(24.0, 90.0, 11.0)
    assert risk_blast == PestRiskLevel.CRITICAL
    assert cond_blast == EpidemicCondition.FAVORABLE

    # 4. Cotton Whitefly Aridity Model
    # Hot & dry: 34°C, RH 50% -> HIGH
    risk_wf, cond_wf, _ = PestForewarningService.evaluate_cotton_whitefly(34.0, 50.0)
    assert risk_wf == PestRiskLevel.HIGH
    assert cond_wf == EpidemicCondition.FAVORABLE


def test_agro_climatic_zone_resolution():
    """Verify lookup by zone_id and coordinate proximity across India's 15 zones."""
    # Lookup by explicit zone_id
    zone_1 = PestForewarningService.match_zone(zone_id=1)
    assert zone_1["zone_name"] == "Western Himalayan Region"
    assert "Apple" in zone_1["dominant_crops"]

    zone_12 = PestForewarningService.match_zone(zone_id=12)
    assert zone_12["zone_name"] == "West Coast Plains and Ghats Region"
    assert "Coconut" in zone_12["dominant_crops"]

    # Lookup by coordinates near Kerala (10.5, 76.2)
    resp_kerala = PestForewarningService.get_pest_forewarning(latitude=10.5, longitude=76.2)
    assert resp_kerala.zone.zone_id == 12

    # Lookup by coordinates near Western Himalayas (32.5, 75.8)
    resp_himalayas = PestForewarningService.get_pest_forewarning(latitude=32.5, longitude=75.8)
    assert resp_himalayas.zone.zone_id == 1


def test_api_pest_forewarning_endpoint():
    """Verify HTTP GET /api/v1/advisories/pest-forewarning."""
    response = client.get("/api/v1/advisories/pest-forewarning?zone_id=3")
    assert response.status_code == 200
    data = response.json()
    assert data["zone"]["zone_id"] == 3
    assert data["zone"]["zone_name"] == "Lower Gangetic Plains Region"
    assert "alerts" in data
    assert len(data["alerts"]) >= 5
    assert "telemetry" in data
    assert "ipm_calendar_actions" in data
    assert "multilingual_bulletins" in data
