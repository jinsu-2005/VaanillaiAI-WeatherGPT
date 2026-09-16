import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.services.livestock_heat_stress_service import LivestockHeatStressService
from app.schemas.livestock_heat_stress import (
    LivestockStressTier,
    AnimalSpeciesBreedCategory,
)


def test_livestock_heat_stress_service_default():
    assessment = LivestockHeatStressService.get_livestock_heat_stress_assessment()
    assert assessment is not None
    assert assessment.selected_basin.basin_id == "karnal_kurukshetra_hr"
    assert assessment.selected_basin.state == "Haryana"
    assert assessment.selected_basin.stress_tier == LivestockStressTier.MODERATE_STRESS
    assert assessment.selected_basin.microclimate.dry_bulb_temperature_c == 41.5
    assert assessment.selected_basin.microclimate.relative_humidity_pct == 58.0
    assert assessment.selected_basin.microclimate.temperature_humidity_index_thi == 87.2
    assert len(assessment.selected_basin.species_profiles) >= 3
    
    # Check Murrah Buffalo profile
    murrah = next(
        p for p in assessment.selected_basin.species_profiles
        if p.species_category == AnimalSpeciesBreedCategory.MURRAH_WATER_BUFFALO
    )
    assert murrah.breed_name == "Murrah Water Buffalo"
    assert murrah.respiration_rate_bpm == 78
    assert murrah.estimated_milk_yield_drop_pct == 22.0
    
    assert len(assessment.all_basins) == 7
    assert "en" in assessment.vernacular_bulletins
    assert "hi" in assessment.vernacular_bulletins
    assert "pa" in assessment.vernacular_bulletins


def test_livestock_heat_stress_service_by_id_anand():
    assessment = LivestockHeatStressService.get_livestock_heat_stress_assessment(basin_id="anand_mehsana_gj")
    assert assessment.selected_basin.basin_id == "anand_mehsana_gj"
    assert assessment.selected_basin.state == "Gujarat"
    assert assessment.selected_basin.stress_tier == LivestockStressTier.MODERATE_STRESS
    assert assessment.selected_basin.microclimate.temperature_humidity_index_thi == 85.8
    assert assessment.selected_basin.directives.water_requirement_liters_per_animal == 130.0
    assert "gu" in assessment.vernacular_bulletins
    assert "આણંદ" in assessment.vernacular_bulletins["gu"]


def test_livestock_heat_stress_geodetic_nearest_sector():
    # Near Kolhapur/Sangli MH (16.70°N, 74.24°E)
    assessment = LivestockHeatStressService.get_livestock_heat_stress_assessment(latitude=16.70, longitude=74.24)
    assert assessment.selected_basin.basin_id == "kolhapur_sangli_mh"
    assert assessment.selected_basin.state == "Maharashtra"
    assert assessment.selected_basin.stress_tier == LivestockStressTier.MODERATE_STRESS
    assert "mr" in assessment.vernacular_bulletins
    assert "गोकुळ" in assessment.vernacular_bulletins["mr"]


@pytest.mark.asyncio
async def test_api_livestock_heat_stress_endpoint():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.get("/api/v1/advisories/livestock-heat-stress?basin_id=salem_erode_tn")
        assert response.status_code == 200
        data = response.json()
        assert data["selected_basin"]["basin_id"] == "salem_erode_tn"
        assert data["selected_basin"]["state"] == "Tamil Nadu"
        assert "ta" in data["vernacular_bulletins"]
        assert "ஆவின்" in data["vernacular_bulletins"]["ta"]
