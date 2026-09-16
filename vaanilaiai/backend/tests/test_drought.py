import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.services.drought_service import drought_service
from app.schemas.drought import DroughtSeverity, CgwbGroundwaterCategory


def test_default_drought_assessment():
    res = drought_service.get_drought_assessment()
    assert res.selected_hotspot.hotspot_id == "marathwada_latur"
    assert res.selected_hotspot.state == "Maharashtra"
    assert res.selected_hotspot.meteorological.spi_3 < -1.5
    assert res.selected_hotspot.meteorological.rainfall_departure_lpa_pct < -40.0
    assert res.selected_hotspot.soil_moisture.root_zone_soil_moisture_pct > 0.0
    assert res.selected_hotspot.groundwater.aquifer_category == CgwbGroundwaterCategory.OVER_EXPLOITED
    assert "Soybean" in res.selected_hotspot.primary_crops
    assert len(res.all_hotspots) == 7
    # 5 vernacular bulletins
    for lang in ["en", "hi", "mr", "te", "kn"]:
        assert lang in res.vernacular_bulletins
        assert len(res.vernacular_bulletins[lang]) > 20
    assert "IMD" in res.provenance


def test_specific_hotspot_anantapur():
    res = drought_service.get_drought_assessment(hotspot_id="rayalaseema_anantapur")
    assert res.selected_hotspot.hotspot_id == "rayalaseema_anantapur"
    assert res.selected_hotspot.severity == DroughtSeverity.EMERGENCY_EXTREME_DROUGHT
    assert res.selected_hotspot.soil_moisture.crop_water_stress_index > 0.85
    assert res.selected_hotspot.groundwater.stage_of_extraction_pct > 120.0
    assert "Groundnut" in res.selected_hotspot.primary_crops[0]
    # Check Telugu bulletin
    te_bulletin = res.vernacular_bulletins["te"]
    assert "కరువు" in te_bulletin or "రైతులకు" in te_bulletin


def test_geodetic_nearest_matching():
    # Near Rajkot, Gujarat (22.3, 70.8)
    res = drought_service.get_drought_assessment(latitude=22.30, longitude=70.80)
    assert res.selected_hotspot.hotspot_id == "saurashtra_rajkot"
    assert res.selected_hotspot.state == "Gujarat"
    assert res.selected_hotspot.groundwater.stage_of_extraction_pct == 98.0


def test_api_endpoint_drought_assessment():
    client = TestClient(app)
    response = client.get("/api/v1/advisories/drought-assessment?hotspot_id=bundelkhand_jhansi")
    assert response.status_code == 200
    data = response.json()
    assert data["selected_hotspot"]["hotspot_id"] == "bundelkhand_jhansi"
    assert data["selected_hotspot"]["severity"] == "WARNING_SEVERE_DROUGHT"
    assert "Chickpea" in data["selected_hotspot"]["primary_crops"][0]
    assert data["selected_hotspot"]["groundwater"]["depth_to_water_table_m_bgl"] == 19.4
    assert len(data["vernacular_bulletins"]) == 5
