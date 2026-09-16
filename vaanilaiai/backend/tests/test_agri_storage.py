"""Pytest test suite for IMD & ICAR Post-Harvest Mandi Weather Defense,
Grain Moisture & Open-Godown Spoilage Engine (AGRI-STORAGE).
"""

import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.schemas.agri_storage import (
    AgriStorageResponse,
    GrainMoistureState,
    MandiWeatherRiskTier,
    MycotoxinAflatoxinRisk,
    TarpaulinAlertStatus,
)
from app.services.agri_storage_service import AgriStorageService


@pytest.fixture
def client():
    """FastAPI TestClient fixture."""
    return TestClient(app)


def test_default_agri_storage_assessment():
    """Verify default assessment loads Khanna APMC Mandi in Punjab."""
    resp = AgriStorageService.get_agri_storage_assessment()
    assert isinstance(resp, AgriStorageResponse)
    assert resp.mandi.mandi_id == "KHANNA_APMC"
    assert resp.mandi.name == "Khanna APMC Grain Market"
    assert resp.mandi.district == "Ludhiana"
    assert resp.mandi.state == "Punjab"
    assert "Wheat" in resp.mandi.primary_commodities
    assert resp.mandi.daily_arrival_metric_tonnes == 18500.0
    assert len(resp.crop_hygroscopic_metrics) >= 2
    assert resp.open_yard_telemetry.yard_type_label is not None
    assert resp.fungal_mycotoxin_telemetry.fssai_limit_ug_per_kg == 15.0
    assert len(resp.monitored_mandis) == 7
    assert len(resp.vernacular_bulletins) == 7


def test_henderson_thompson_emc_physics():
    """Verify physical consistency of Henderson-Thompson EMC formulation."""
    # At low humidity (30%), EMC should be well below safe storage limits
    emc_dry_wheat = AgriStorageService.calculate_henderson_thompson_emc("Wheat", 25.0, 30.0)
    # At high humidity (85%), EMC should climb significantly
    emc_humid_wheat = AgriStorageService.calculate_henderson_thompson_emc("Wheat", 25.0, 85.0)

    assert emc_dry_wheat < emc_humid_wheat
    assert emc_dry_wheat < 11.0
    assert emc_humid_wheat > 14.0

    # Paddy should exhibit hygroscopic moisture uptake higher at elevated RH
    emc_paddy = AgriStorageService.calculate_henderson_thompson_emc("Paddy", 28.0, 80.0)
    assert emc_paddy > 13.0


def test_crop_moisture_state_evaluation():
    """Verify moisture risk classification thresholds."""
    # Wheat safe limit is 12.0%
    assert (
        AgriStorageService.evaluate_grain_moisture_state(10.0, 12.0)
        == GrainMoistureState.OPTIMAL_SAFE_DRY
    )
    assert (
        AgriStorageService.evaluate_grain_moisture_state(11.5, 12.0)
        == GrainMoistureState.ACCEPTABLE_STABLE
    )
    assert (
        AgriStorageService.evaluate_grain_moisture_state(13.2, 12.0)
        == GrainMoistureState.UNSAFE_ELEVATED_MOISTURE
    )
    assert (
        AgriStorageService.evaluate_grain_moisture_state(15.0, 12.0)
        == GrainMoistureState.PERILOUS_FERMENTATION_RISK
    )


def test_aflatoxin_mold_kinetics():
    """Verify Aspergillus flavus growth kinetics and FSSAI Aflatoxin B1 limits."""
    # Optimal conditions: 31°C and 85% RH -> high mold proliferation
    risk_hot_humid, mold_idx_high, ppb_high = AgriStorageService.evaluate_aflatoxin_risk(31.0, 85.0)
    assert risk_hot_humid in (
        MycotoxinAflatoxinRisk.HIGH_FUNGAL_PROLIFERATION,
        MycotoxinAflatoxinRisk.EXTREME_AFLATOXIN_OUTBREAK,
    )
    assert mold_idx_high > 5.0
    assert ppb_high > 12.0

    # Dry cool conditions: 15°C and 45% RH -> minimal risk
    risk_dry_cool, mold_idx_low, ppb_low = AgriStorageService.evaluate_aflatoxin_risk(15.0, 45.0)
    assert risk_dry_cool == MycotoxinAflatoxinRisk.MINIMAL_MYCOTOXIN_RISK
    assert mold_idx_low < 3.0
    assert ppb_low < 10.0


def test_karnal_apmc_specific_query():
    """Verify assessment for Karnal New Grain Market in Haryana."""
    resp = AgriStorageService.get_agri_storage_assessment(mandi_id="KARNAL_APMC")
    assert resp.mandi.mandi_id == "KARNAL_APMC"
    assert resp.mandi.state == "Haryana"
    assert "Paddy" in resp.mandi.primary_commodities
    assert resp.storage_directives.dunnage_pallet_height_recommendation_cm == 15.0
    assert resp.storage_directives.aeration_fan_schedule_recommendation is not None


def test_neemuch_apmc_oilseed_metrics():
    """Verify assessment for Neemuch Krishi Upaj Mandi with Soybean & Mustard."""
    resp = AgriStorageService.get_agri_storage_assessment(mandi_id="NEEMUCH_APMC")
    assert resp.mandi.mandi_id == "NEEMUCH_APMC"
    assert resp.mandi.state == "Madhya Pradesh"
    assert "Soybean" in resp.mandi.primary_commodities
    assert "Mustard" in resp.mandi.primary_commodities

    # Check that Soybean has safe limit of 10.0%
    soybean_metric = next(m for m in resp.crop_hygroscopic_metrics if m.crop_name == "Soybean")
    assert soybean_metric.safe_storage_limit_pct == 10.0


def test_nearest_mandi_geolocation():
    """Verify geolocation lookup finds closest APMC hub."""
    # Near Latur, Maharashtra: lat=18.4, lon=76.5
    resp = AgriStorageService.get_agri_storage_assessment(lat=18.41, lon=76.55)
    assert resp.mandi.mandi_id == "LATUR_APMC"
    assert resp.mandi.state == "Maharashtra"

    # Near Kota, Rajasthan: lat=25.2, lon=75.8
    resp_kota = AgriStorageService.get_agri_storage_assessment(lat=25.19, lon=75.82)
    assert resp_kota.mandi.mandi_id == "KOTA_BHAMASHAH"
    assert resp_kota.mandi.state == "Rajasthan"


def test_storage_directives_and_dunnage():
    """Verify engineering storage defense directives."""
    resp = AgriStorageService.get_agri_storage_assessment()
    directives = resp.storage_directives
    assert directives.tarpaulin_status in list(TarpaulinAlertStatus)
    assert directives.dunnage_pallet_height_recommendation_cm >= 15.0
    assert len(directives.recommended_actions) >= 3
    assert any("dunnage" in action.lower() for action in directives.recommended_actions)


def test_vernacular_bulletins_seven_languages():
    """Verify 7-language localized bulletins coverage."""
    resp = AgriStorageService.get_agri_storage_assessment(mandi_id="KHANNA_APMC")
    expected_langs = ["en", "hi", "pa", "mr", "te", "gu", "bn"]
    for lang in expected_langs:
        assert lang in resp.vernacular_bulletins
        bulletin = resp.vernacular_bulletins[lang]
        assert len(bulletin) > 20
        assert "Khanna" in bulletin or "ਖੰਨਾ" in bulletin or "खन्ना" in bulletin or "ఖన్నా" in bulletin or "খন্না" in bulletin or "ખન્ના" in bulletin or "Mandi" in bulletin or "मंडी" in bulletin or "ਮੰਡੀ" in bulletin


def test_api_v1_agri_storage_endpoint(client):
    """Verify GET /api/v1/advisories/agri-storage endpoint response via TestClient."""
    response = client.get("/api/v1/advisories/agri-storage?mandi_id=KHANNA_APMC")
    assert response.status_code == 200
    data = response.json()
    assert data["mandi"]["mandi_id"] == "KHANNA_APMC"
    assert data["overall_risk_tier"] in [
        "CRITICAL_SPOILAGE_RISK",
        "HIGH_MOISTURE_SURGE",
        "MODERATE_WEATHER_ALERT",
        "SAFE_STORAGE_OPTIMAL",
    ]
    assert "crop_hygroscopic_metrics" in data
    assert len(data["crop_hygroscopic_metrics"]) > 0
    assert "fungal_mycotoxin_telemetry" in data
    assert "open_yard_telemetry" in data
    assert "storage_directives" in data
    assert data["metadata"]["source_authority"] is not None

    # Test with coordinates
    geo_resp = client.get("/api/v1/advisories/agri-storage?lat=29.68&lon=76.99")
    assert geo_resp.status_code == 200
    geo_data = geo_resp.json()
    assert geo_data["mandi"]["mandi_id"] == "KARNAL_APMC"
