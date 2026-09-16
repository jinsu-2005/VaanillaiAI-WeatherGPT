import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.services.forest_fire_service import ForestFireService
from app.schemas.forest_fire import (
    FireDangerRatingTier,
    ForestBiomeType,
)


def test_forest_fire_service_default():
    assessment = ForestFireService.get_assessment()
    assert assessment is not None
    assert assessment.selected_zone.zone_id == "uttarakhand_garhwal_pine"
    assert assessment.selected_zone.state == "Uttarakhand"
    assert assessment.selected_zone.biome_type == ForestBiomeType.CHIR_PINE_CONIFEROUS
    assert assessment.selected_zone.indices.danger_tier == FireDangerRatingTier.VERY_HIGH
    assert assessment.selected_zone.indices.fwi_fire_weather_index == 38.6
    assert assessment.selected_zone.behavior.crown_fire_risk is True
    assert len(assessment.all_zones) == 7
    assert "en" in assessment.vernacular_bulletins
    assert "hi" in assessment.vernacular_bulletins
    assert "चीड़" in assessment.vernacular_bulletins["hi"]


def test_forest_fire_service_by_id():
    assessment = ForestFireService.get_assessment(zone_id="similipal_tiger_reserve")
    assert assessment.selected_zone.zone_id == "similipal_tiger_reserve"
    assert assessment.selected_zone.state == "Odisha"
    assert assessment.selected_zone.indices.danger_tier == FireDangerRatingTier.EXTREME
    assert assessment.selected_zone.indices.fwi_fire_weather_index == 48.5
    assert assessment.selected_zone.total_frp_mw > 200.0
    assert "or" in assessment.vernacular_bulletins
    assert "ଶିମିଳିପାଳ" in assessment.vernacular_bulletins["or"]


def test_forest_fire_geodetic_nearest_zone():
    # Coordinates near Bandipur / Mysore border (11.70°N, 76.65°E)
    assessment = ForestFireService.get_assessment(latitude=11.70, longitude=76.65)
    assert assessment.selected_zone.zone_id == "bandipur_nagarhole_nilgiri"
    assert assessment.selected_zone.state == "Karnataka"
    assert assessment.selected_zone.indices.danger_tier == FireDangerRatingTier.HIGH
    assert "kn" in assessment.vernacular_bulletins
    assert "ಬಂಡೀಪುರ" in assessment.vernacular_bulletins["kn"]


@pytest.mark.asyncio
async def test_api_forest_fire_endpoint():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.get("/api/v1/alerts/forest-fire?zone_id=similipal_tiger_reserve")
        assert response.status_code == 200
        data = response.json()
        assert data["selected_zone"]["zone_id"] == "similipal_tiger_reserve"
        assert data["selected_zone"]["indices"]["danger_tier"] == "EXTREME"
        assert data["selected_zone"]["indices"]["fwi_fire_weather_index"] == 48.5
        assert "provenance" in data
        assert "Van Agni" in data["provenance"]
