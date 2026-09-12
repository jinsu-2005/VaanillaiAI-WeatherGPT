"""Unit tests for IMD RSMC Tropical Cyclone Track, Storm Surge & Dvorak T-Number Intensity Engine."""
import pytest
from app.services.cyclone_service import cyclone_service


def test_dvorak_intensity_calculations():
    """Verify Dvorak T-number physics and IMD categorization."""
    # Test Depression range (T1.5)
    t15 = cyclone_service.calculate_dvorak_intensity(1.5)
    assert t15.intensity_code == "D"
    assert t15.t_number == 1.5
    assert t15.central_pressure_hpa > 1000.0
    assert t15.pressure_deficit_hpa > 0

    # Test Severe Cyclonic Storm (T3.5)
    t35 = cyclone_service.calculate_dvorak_intensity(3.5)
    assert t35.intensity_code == "SCS"
    assert t35.max_sustained_wind_kt >= 48.0
    assert t35.max_sustained_wind_kmh >= 89.0

    # Test Very Severe Cyclonic Storm (T4.5)
    t45 = cyclone_service.calculate_dvorak_intensity(4.5)
    assert t45.intensity_code == "VSCS"
    assert t45.max_sustained_wind_kmh >= 118.0

    # Test Super Cyclonic Storm (T6.5)
    t65 = cyclone_service.calculate_dvorak_intensity(6.5)
    assert t65.intensity_code == "SuCS"
    assert t65.max_sustained_wind_kt >= 120.0
    assert t65.pressure_deficit_hpa >= 70.0


def test_haversine_and_proximity():
    """Verify geodetic distance between Chennai and cyclone center."""
    # Chennai (13.0827, 80.2707) to Cyclone Michaung center (14.2, 80.3)
    dist = cyclone_service.haversine_distance(13.0827, 80.2707, 14.2, 80.3)
    assert 110.0 <= dist <= 140.0


@pytest.mark.asyncio
async def test_cyclone_tracker_endpoint(client):
    """Verify GET /api/v1/alerts/cyclone-tracker response schema and content."""
    resp = await client.get("/api/v1/alerts/cyclone-tracker?latitude=13.08&longitude=80.27")
    assert resp.status_code == 200
    data = resp.json()

    assert data["basin_status"] == "Active Cyclone Alert"
    assert data["active_systems_count"] >= 3
    assert "RSMC" in data["authority_disclaimer"]

    # Selected system
    sel = data["selected_system"]
    assert sel["name"] in ("MICHAUNG", "BIPARJOY", "DANA")
    assert sel["dvorak"]["t_number"] > 0
    assert sel["dvorak"]["central_pressure_hpa"] < 1010.0
    assert len(sel["track_points"]) >= 3
    assert sel["gale_radii"]["radius_34kt_ne_km"] > 0
    assert len(sel["storm_surge_forecasts"]) >= 1
    assert sel["evacuation"]["port_warning_signal"] in (8, 9, 10)

    # Multilingual bulletins
    assert "en" in sel["vernacular_bulletin"]
    assert "ta" in sel["vernacular_bulletin"]
    assert "hi" in sel["vernacular_bulletin"]
    assert "bn" in sel["vernacular_bulletin"]
    assert "or" in sel["vernacular_bulletin"]

    # Proximity
    assert data["nearest_system_distance_km"] is not None
    assert sel["distance_to_user_km"] is not None

    # Test selecting Biparjoy explicitly
    biparjoy_resp = await client.get("/api/v1/alerts/cyclone-tracker?system_id=biparjoy-2023")
    assert biparjoy_resp.status_code == 200
    b_data = biparjoy_resp.json()
    assert b_data["selected_system"]["name"] == "BIPARJOY"
    assert b_data["selected_system"]["basin"] == "Arabian Sea"
