import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.services.convective_storm_service import convective_storm_service
from app.schemas.convective_storm import (
    StormPhenomenonType,
    ConvectiveWarningStage,
)


def test_default_convective_storm_assessment():
    """Verify default assessment returns valid structure, thermodynamics, and 5 languages."""
    res = convective_storm_service.get_convective_storm_assessment()
    assert res is not None
    assert res.selected_hotspot is not None
    assert len(res.all_hotspots) == 7
    assert res.selected_hotspot.phenomenon == StormPhenomenonType.KALBAISHAKHI_NORWESTER
    assert res.selected_hotspot.warning_stage == ConvectiveWarningStage.STAGE_4_RED_SEVERE_WARNING
    assert res.selected_hotspot.thermodynamics.cape_j_kg >= 2500.0
    assert res.selected_hotspot.thermodynamics.lifted_index_c <= -5.0
    assert res.selected_hotspot.density_current.gust_front_speed_kmh >= 80.0

    # Verify multilingual bulletins
    assert "en" in res.vernacular_bulletins
    assert "hi" in res.vernacular_bulletins
    assert "bn" in res.vernacular_bulletins
    assert "or" in res.vernacular_bulletins
    assert "as" in res.vernacular_bulletins
    assert "IMD" in res.vernacular_bulletins["en"]


def test_haboob_hotspot_lookup():
    """Verify Bikaner Thar Desert lookup returns Haboob dust storm dynamics."""
    res = convective_storm_service.get_convective_storm_assessment(hotspot_id="bikaner_thar_desert")
    assert res.selected_hotspot.hotspot_id == "bikaner_thar_desert"
    assert res.selected_hotspot.phenomenon == StormPhenomenonType.HABOOB_ANDHI_DUST_STORM
    assert res.selected_hotspot.warning_stage == ConvectiveWarningStage.STAGE_4_RED_SEVERE_WARNING
    assert res.selected_hotspot.density_current.dust_wall_height_m >= 2000.0
    assert res.selected_hotspot.density_current.pm10_surge_ug_m3 >= 1500.0
    assert res.selected_hotspot.density_current.minimum_visibility_m <= 50.0


def test_geodetic_nearest_hotspot():
    """Verify geodetic matching for coordinates near Delhi."""
    res = convective_storm_service.get_convective_storm_assessment(latitude=28.60, longitude=77.20)
    assert res.selected_hotspot.hotspot_id == "delhi_ncr_convective"
    assert res.selected_hotspot.state == "Delhi NCR"


@pytest.mark.asyncio
async def test_convective_storm_api_endpoint():
    """Verify FastAPI GET /api/v1/alerts/convective-storm endpoint returns 200 OK."""
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.get("/api/v1/alerts/convective-storm?hotspot_id=guwahati_brahmaputra")
        assert response.status_code == 200
        data = response.json()
        assert data["selected_hotspot"]["hotspot_id"] == "guwahati_brahmaputra"
        assert data["selected_hotspot"]["state"] == "Assam"
        assert "thermodynamics" in data["selected_hotspot"]
        assert "density_current" in data["selected_hotspot"]
        assert "provenance" in data
