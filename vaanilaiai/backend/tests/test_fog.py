"""Test suite for IMD FogPass, Highway Safety & Aviation Low-Visibility Nowcasting."""
import pytest
from app.services.fog_service import fog_service
from app.schemas.fog import VisibilityTier, RvrCategory


def test_visibility_physics_dense_fog():
    """Verify physical visibility calculation under nocturnal inversion conditions."""
    # Near-zero dew point depression and high humidity should yield dense fog
    vis, tier, fog_type = fog_service.calculate_visibility_physics(
        temp_c=10.2,
        dew_point_c=10.0,
        rh_percent=98.0,
        wind_kmh=3.0,
    )
    assert vis < 200
    assert tier in (VisibilityTier.VERY_DENSE_FOG, VisibilityTier.DENSE_FOG)
    assert "Radiation Fog" in fog_type


def test_visibility_physics_clear():
    """Verify physical visibility under dry and warm conditions."""
    vis, tier, fog_type = fog_service.calculate_visibility_physics(
        temp_c=28.0,
        dew_point_c=14.0,
        rh_percent=42.0,
        wind_kmh=12.0,
    )
    assert vis > 1000
    assert tier == VisibilityTier.CLEAR


def test_rvr_categories():
    """Verify ICAO/DGCA Runway Visual Range category mapping."""
    cat_iiic, _ = fog_service.get_rvr_category(35)
    assert cat_iiic == RvrCategory.CAT_IIIC

    cat_iiib, _ = fog_service.get_rvr_category(120)
    assert cat_iiib == RvrCategory.CAT_IIIB

    cat_iiia, _ = fog_service.get_rvr_category(220)
    assert cat_iiia == RvrCategory.CAT_IIIA

    cat_ii, _ = fog_service.get_rvr_category(400)
    assert cat_ii == RvrCategory.CAT_II

    cat_i, _ = fog_service.get_rvr_category(650)
    assert cat_i == RvrCategory.CAT_I

    normal, _ = fog_service.get_rvr_category(1500)
    assert normal == RvrCategory.NORMAL


@pytest.mark.asyncio
async def test_get_fog_nowcast_endpoint(client):
    """Verify GET /api/v1/fog/nowcast endpoint response contract."""
    params = {
        "latitude": 28.5665,
        "longitude": 77.1031,
        "location_name": "New Delhi (IGI Airport)",
    }
    response = await client.get("/api/v1/fog/nowcast", params=params)
    assert response.status_code == 200
    data = response.json()

    assert data["location_name"] == "New Delhi (IGI Airport)"
    assert data["visibility_meters"] > 0
    assert data["visibility_tier"] in [t.value for t in VisibilityTier]
    assert data["rvr_status"] in [r.value for r in RvrCategory]

    # Check physics
    physics = data["physics"]
    assert "dew_point_depression_c" in physics
    assert physics["dew_point_depression_c"] >= 0.0
    assert "relative_humidity_percent" in physics
    assert "surface_wind_speed_kmh" in physics

    # Check highway safety advisory
    hwy = data["highway_advisory"]
    assert hwy["advised_speed_kmh"] > 0
    assert hwy["advised_speed_kmh"] <= 100
    assert "hazard_lights_directive" in hwy
    assert hwy["pileup_risk_level"] in ("Low", "Moderate", "High", "Severe")

    # Check railway FogPass
    rail = data["railway_fogpass"]
    assert rail["locomotive_speed_cap_kmh"] in (60, 75, 130)
    assert "rail_corridor" in rail

    # Check corridor stations
    assert len(data["corridor_stations"]) >= 5
    first_station = data["corridor_stations"][0]
    assert "station_name" in first_station
    assert "visibility_meters" in first_station
    assert "distance_km" in first_station
    assert first_station["distance_km"] is not None

    # Check multilingual safety bulletins
    vernacular = data["vernacular_advisories"]
    assert "en" in vernacular
    assert "hi" in vernacular
    assert "pa" in vernacular
    assert "bn" in vernacular
    assert "ta" in vernacular
