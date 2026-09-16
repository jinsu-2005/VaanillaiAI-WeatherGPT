import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.services.crop_water_stress_service import CropWaterStressService
from app.schemas.crop_water_stress import (
    SoilTextureClass,
    CropWaterStressTier,
)


def test_crop_water_stress_service_default():
    assessment = CropWaterStressService.get_assessment()
    assert assessment is not None
    assert assessment.selected_zone.zone_id == "vidarbha_cotton_vertisol"
    assert assessment.selected_zone.state == "Maharashtra"
    assert assessment.selected_zone.soil_texture == SoilTextureClass.BLACK_COTTON_VERTISOL
    assert assessment.selected_zone.stress_tier == CropWaterStressTier.MODERATE_DEFICIT
    assert assessment.selected_zone.evapotranspiration.crop_water_stress_index_cwsi == 0.68
    assert assessment.selected_zone.evapotranspiration.canopy_air_temp_departure_c == 2.4
    assert assessment.selected_zone.soil_moisture.relative_available_soil_moisture_pct == 22.5
    assert assessment.selected_zone.irrigation_directives.recommended_irrigation_depth_mm == 35.0
    assert len(assessment.all_zones) == 7
    assert "en" in assessment.vernacular_bulletins
    assert "mr" in assessment.vernacular_bulletins
    assert "कापूस" in assessment.vernacular_bulletins["mr"]


def test_crop_water_stress_service_by_id():
    assessment = CropWaterStressService.get_assessment(zone_id="punjab_wheat_rice_alluvium")
    assert assessment.selected_zone.zone_id == "punjab_wheat_rice_alluvium"
    assert assessment.selected_zone.state == "Punjab"
    assert assessment.selected_zone.stress_tier == CropWaterStressTier.OPTIMAL_TURGOR
    assert assessment.selected_zone.evapotranspiration.crop_water_stress_index_cwsi == 0.18
    assert assessment.selected_zone.evapotranspiration.canopy_air_temp_departure_c == -1.8
    assert assessment.selected_zone.soil_moisture.relative_available_soil_moisture_pct == 81.0
    assert "pa" in assessment.vernacular_bulletins
    assert "ਕਣਕ" in assessment.vernacular_bulletins["pa"]


def test_crop_water_stress_geodetic_nearest_zone():
    # Coordinates near Thanjavur / Tiruvarur, Tamil Nadu (10.75°N, 79.15°E)
    assessment = CropWaterStressService.get_assessment(latitude=10.75, longitude=79.15)
    assert assessment.selected_zone.zone_id == "cauvery_delta_paddy_wetland"
    assert assessment.selected_zone.state == "Tamil Nadu"
    assert assessment.selected_zone.stress_tier == CropWaterStressTier.MILD_STRESS
    assert assessment.selected_zone.evapotranspiration.crop_water_stress_index_cwsi == 0.22
    assert "ta" in assessment.vernacular_bulletins
    assert "சம்பா" in assessment.vernacular_bulletins["ta"]


@pytest.mark.asyncio
async def test_api_crop_water_stress_endpoint():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.get("/api/v1/advisories/crop-water-stress?zone_id=saurashtra_groundnut_belt")
        assert response.status_code == 200
        data = response.json()
        assert data["selected_zone"]["zone_id"] == "saurashtra_groundnut_belt"
        assert data["selected_zone"]["state"] == "Gujarat"
        assert data["selected_zone"]["primary_crop"] == "Groundnut (Arachis hypogaea)"
        assert data["selected_zone"]["stress_tier"] == "MODERATE_DEFICIT"
        assert data["selected_zone"]["evapotranspiration"]["crop_water_stress_index_cwsi"] == 0.62
        assert "provenance" in data
        assert "ICAR" in data["provenance"]
