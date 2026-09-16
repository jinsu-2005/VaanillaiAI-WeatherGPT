import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.services.avalanche_snow_service import avalanche_snow_service
from app.schemas.avalanche_snow import (
    AvalancheDangerLevel,
    WdIntensity,
    PassTransitStatus,
    WeakLayerType,
)


def test_default_avalanche_assessment():
    """Verify default assessment returns valid structure, snow physics, and 5 languages."""
    res = avalanche_snow_service.get_avalanche_assessment()
    assert res is not None
    assert res.selected_sector is not None
    assert len(res.all_sectors) == 8
    assert res.western_disturbance.intensity == WdIntensity.INTENSE
    assert res.western_disturbance.subtropical_jet_speed_kt >= 100.0
    assert res.selected_sector.snowpack.snow_water_equivalent_mm > 0

    # Verify multilingual bulletins
    assert "en" in res.vernacular_bulletins
    assert "hi" in res.vernacular_bulletins
    assert "ur" in res.vernacular_bulletins
    assert "pa" in res.vernacular_bulletins
    assert "bn" in res.vernacular_bulletins
    assert "DGRE" in res.vernacular_bulletins["en"]


def test_sector_lookup_by_id():
    """Verify specific sector lookup for Zoji La returns Red alert and closed pass."""
    res = avalanche_snow_service.get_avalanche_assessment(sector_id="zojila_dras")
    assert res.selected_sector.sector_id == "zojila_dras"
    assert res.selected_sector.danger_level == AvalancheDangerLevel.LEVEL_4_RED_HIGH_DANGER
    assert res.selected_sector.pass_status.status == PassTransitStatus.CLOSED_SNOW_CLEARING
    assert res.selected_sector.snowpack.primary_weak_layer == WeakLayerType.DEPTH_HOAR_FACETS
    assert res.selected_sector.snowpack.total_snowpack_depth_cm >= 200.0
    assert "NH-1" in res.selected_sector.pass_status.highway_code


def test_geodetic_nearest_sector():
    """Verify geodetic matching for coordinates in Himachal Pradesh."""
    # Near Manali / Rohtang (lat 32.35, lon 77.17)
    res = avalanche_snow_service.get_avalanche_assessment(latitude=32.35, longitude=77.17)
    assert res.selected_sector.state_or_ut == "Himachal Pradesh"
    assert res.selected_sector.sector_id in ["rohtang_atal_tunnel", "solang_upper_beas"]


@pytest.mark.asyncio
async def test_avalanche_api_endpoint():
    """Verify FastAPI GET /api/v1/avalanche/assessment endpoint returns 200 OK."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.get("/api/v1/avalanche/assessment?sector_id=badrinath_mana_pass")
        assert response.status_code == 200
        data = response.json()
        assert data["selected_sector"]["sector_id"] == "badrinath_mana_pass"
        assert data["selected_sector"]["danger_level"] == "LEVEL_4_RED_HIGH_DANGER"
        assert "western_disturbance" in data
        assert "provenance" in data
