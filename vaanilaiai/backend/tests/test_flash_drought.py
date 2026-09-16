"""Pytest test suite for IMD & CWC Flash Drought, Rapid Soil Desiccation
& Atmospheric Evaporative Demand Engine (FLASH-DROUGHT).
"""

import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.schemas.flash_drought import (
    AtmosphericEvaporativeDemandTier,
    CropPhenologyVulnerability,
    FlashDroughtIntensityTier,
    FlashDroughtResponse,
    SoilDesiccationVelocity,
)
from app.services.flash_drought_service import FlashDroughtService


@pytest.fixture
def client():
    """FastAPI TestClient fixture."""
    return TestClient(app)


def test_default_flash_drought_assessment():
    """Verify default assessment loads Vidarbha Agro-Ecological Hotspot in Maharashtra."""
    resp = FlashDroughtService.get_flash_drought_assessment()
    assert isinstance(resp, FlashDroughtResponse)
    assert resp.hotspot.hotspot_id == "VIDARBHA_HOTSPOT"
    assert resp.hotspot.name == "Vidarbha Agro-Ecological Hotspot"
    assert resp.hotspot.state == "Maharashtra"
    assert "Soybean" in resp.hotspot.primary_kharif_crops
    assert resp.hotspot.irrigation_coverage_pct == 14.5
    assert resp.atmospheric_demand.reference_evapotranspiration_e0_mm_day > 0.0
    assert resp.atmospheric_demand.vapor_pressure_deficit_kpa > 0.0
    assert resp.soil_desiccation.rootzone_moisture_10_40cm_pct > 0.0
    assert len(resp.monitored_hotspots) == 7
    assert len(resp.vernacular_bulletins) == 7


def test_penman_monteith_e0_physics():
    """Verify physical consistency of FAO-56 Penman-Monteith evaporative demand."""
    # Under hot, windy, arid conditions: 40°C, 25% RH, 5 m/s wind, 25 MJ/m2/day rad
    e0_hot, vpd_hot = FlashDroughtService.calculate_penman_monteith_e0(40.0, 25.0, 5.0, 25.0)
    # Under mild, humid conditions: 26°C, 80% RH, 2 m/s wind, 18 MJ/m2/day rad
    e0_cool, vpd_cool = FlashDroughtService.calculate_penman_monteith_e0(26.0, 80.0, 2.0, 18.0)

    assert e0_hot > e0_cool
    assert vpd_hot > vpd_cool
    assert vpd_hot > 2.0  # Acute vapor pressure deficit
    assert e0_hot > 6.0   # Extreme atmospheric evaporative demand


def test_eddi_tier_classification():
    """Verify Evaporative Demand Drought Index standardized classification."""
    assert (
        FlashDroughtService.classify_eddi_tier(2.2)
        == AtmosphericEvaporativeDemandTier.EXTREME_EVAPORATIVE_DEMAND
    )
    assert (
        FlashDroughtService.classify_eddi_tier(1.7)
        == AtmosphericEvaporativeDemandTier.SEVERE_EVAPORATIVE_DEMAND
    )
    assert (
        FlashDroughtService.classify_eddi_tier(1.2)
        == AtmosphericEvaporativeDemandTier.MODERATE_EVAPORATIVE_DEMAND
    )
    assert (
        FlashDroughtService.classify_eddi_tier(0.7)
        == AtmosphericEvaporativeDemandTier.ABNORMAL_EVAPORATIVE_DEMAND
    )
    assert (
        FlashDroughtService.classify_eddi_tier(0.2)
        == AtmosphericEvaporativeDemandTier.NORMAL_EVAPORATIVE_DEMAND
    )


def test_soil_desiccation_velocity_classification():
    """Verify root-zone soil moisture desiccation velocity tiers."""
    assert (
        FlashDroughtService.classify_desiccation_velocity(9.5)
        == SoilDesiccationVelocity.CRITICAL_EXPLOSIVE
    )
    assert (
        FlashDroughtService.classify_desiccation_velocity(6.2)
        == SoilDesiccationVelocity.ACCELERATED_HIGH
    )
    assert (
        FlashDroughtService.classify_desiccation_velocity(3.5)
        == SoilDesiccationVelocity.MODERATE_STEADY
    )
    assert (
        FlashDroughtService.classify_desiccation_velocity(1.8)
        == SoilDesiccationVelocity.NORMAL_DRAINAGE
    )


def test_rayalaseema_groundnut_vulnerability():
    """Verify Rayalaseema basin dryland groundnut pegging vulnerability."""
    resp = FlashDroughtService.get_flash_drought_assessment(hotspot_id="RAYALASEEMA_BASIN")
    assert resp.hotspot.hotspot_id == "RAYALASEEMA_BASIN"
    assert resp.hotspot.state == "Andhra Pradesh"
    assert "Groundnut" in resp.hotspot.primary_kharif_crops
    assert "Red Sandy Loams" in resp.hotspot.soil_type
    assert resp.crop_vulnerability.primary_crop == "Groundnut"
    assert (
        resp.crop_vulnerability.vulnerability_tier
        == CropPhenologyVulnerability.CRITICAL_REPRODUCTIVE_SUSCEPTIBILITY
    )
    assert resp.crop_vulnerability.damage_multiplier >= 2.0


def test_marathwada_cotton_stress():
    """Verify Marathwada rainfed basin cotton phenological stress."""
    resp = FlashDroughtService.get_flash_drought_assessment(hotspot_id="MARATHWADA_HOTSPOT")
    assert resp.hotspot.hotspot_id == "MARATHWADA_HOTSPOT"
    assert "Cotton" in resp.hotspot.primary_kharif_crops
    assert resp.crop_vulnerability.primary_crop == "Cotton"
    assert "Square" in resp.crop_vulnerability.current_growth_stage


def test_nearest_hotspot_geolocation():
    """Verify geolocation lookup finds closest vulnerable rainfed hotspot."""
    # Near Rajkot, Saurashtra: lat=22.3, lon=70.8
    resp_saurashtra = FlashDroughtService.get_flash_drought_assessment(lat=22.31, lon=70.81)
    assert resp_saurashtra.hotspot.hotspot_id == "SAURASHTRA_PENINSULA"
    assert resp_saurashtra.hotspot.state == "Gujarat"

    # Near Vijayapura, Karnataka: lat=16.8, lon=75.7
    resp_karnataka = FlashDroughtService.get_flash_drought_assessment(lat=16.82, lon=75.72)
    assert resp_karnataka.hotspot.hotspot_id == "NORTH_INTERIOR_KARNATAKA"
    assert resp_karnataka.hotspot.state == "Karnataka"


def test_rapid_intensification_and_directives():
    """Verify rapid intensification flag and ICAR-CRIDA agronomic directives."""
    resp = FlashDroughtService.get_flash_drought_assessment(hotspot_id="VIDARBHA_HOTSPOT")
    directives = resp.directives
    assert len(directives.actionable_bullet_points) >= 4
    assert (
        "KNO3" in directives.anti_transpirant_spray_recommendation
        or "Kaolin" in directives.anti_transpirant_spray_recommendation
    )
    assert "nocturnal" in directives.micro_irrigation_pulse_schedule.lower()
    assert "mulch" in directives.mulching_directive.lower()


def test_vernacular_bulletins_seven_languages():
    """Verify 7-language localized bulletins coverage."""
    resp = FlashDroughtService.get_flash_drought_assessment(hotspot_id="VIDARBHA_HOTSPOT")
    expected_langs = ["en", "hi", "mr", "te", "kn", "gu", "bn"]
    for lang in expected_langs:
        assert lang in resp.vernacular_bulletins
        bulletin = resp.vernacular_bulletins[lang]
        assert len(bulletin) > 30
        assert "EDDI" in bulletin or "सूखा" in bulletin or "दुष्काळ" in bulletin or "కరువు" in bulletin or "ಬರ" in bulletin or "ખરા" in bulletin


def test_api_v1_flash_drought_endpoint(client):
    """Verify GET /api/v1/advisories/flash-drought endpoint response via TestClient."""
    response = client.get("/api/v1/advisories/flash-drought?hotspot_id=VIDARBHA_HOTSPOT")
    assert response.status_code == 200
    data = response.json()
    assert data["hotspot"]["hotspot_id"] == "VIDARBHA_HOTSPOT"
    assert data["overall_intensity_tier"] in [
        "EXTREME_FLASH_DROUGHT",
        "SEVERE_FLASH_DROUGHT",
        "MODERATE_FLASH_DROUGHT",
        "FLASH_DROUGHT_WATCH",
        "NORMAL_MOISTURE_REGIME",
    ]
    assert "atmospheric_demand" in data
    assert "soil_desiccation" in data
    assert "crop_vulnerability" in data
    assert "directives" in data
    assert data["metadata"]["source_authority"] is not None

    # Test with coordinates
    geo_resp = client.get("/api/v1/advisories/flash-drought?lat=14.68&lon=77.60")
    assert geo_resp.status_code == 200
    geo_data = geo_resp.json()
    assert geo_data["hotspot"]["hotspot_id"] == "RAYALASEEMA_BASIN"
