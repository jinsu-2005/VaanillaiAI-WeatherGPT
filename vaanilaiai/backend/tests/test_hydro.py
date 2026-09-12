"""Test suite for Central Water Commission (CWC) River Basin & Dam Hydro-Telemetry."""
import pytest


@pytest.mark.asyncio
async def test_get_hydro_overview_endpoint(client):
    """Verify CWC river hydrograph and reservoir telemetry retrieval."""
    params = {
        "latitude": 25.3076,
        "longitude": 83.0104,
        "location_name": "Varanasi",
    }
    response = await client.get("/api/v1/hydro/overview", params=params)
    assert response.status_code == 200
    data = response.json()

    assert data["location_name"] == "Varanasi"
    assert data["selected_basin"] == "Ganga"
    assert "available_basins" in data
    assert len(data["available_basins"]) >= 7

    # Check nearest gauge station
    nearest = data["nearest_gauge_station"]
    assert nearest is not None
    assert "Varanasi" in nearest["name"]
    assert nearest["river"] == "Ganga"
    assert nearest["distance_km"] < 15.0
    assert nearest["flood_stage"] in ("Normal", "Warning", "Danger", "Extreme")
    assert nearest["current_level_m"] > 0
    assert nearest["warning_level_m"] > 0
    assert nearest["danger_level_m"] > nearest["warning_level_m"]

    # Check basin summary
    summary = data["basin_summary"]
    assert summary["basin_name"] == "Ganga"
    assert summary["total_stations"] >= 3
    assert len(summary["major_rivers"]) >= 1

    # Check reservoirs
    assert len(data["reservoirs"]) >= 1
    tehri = next((r for r in data["reservoirs"] if "Tehri" in r["name"]), None)
    if tehri:
        assert tehri["storage_percent"] > 0
        assert tehri["full_reservoir_level_m"] == 830.0

    # Check directives and multilingual alerts
    assert len(data["downstream_directives"]) >= 2
    assert "hi" in data["vernacular_riparian_alerts"]
    assert "ta" in data["vernacular_riparian_alerts"]
    assert "bn" in data["vernacular_riparian_alerts"]


@pytest.mark.asyncio
async def test_get_hydro_overview_basin_filter(client):
    """Verify basin filtering for Cauvery basin."""
    params = {
        "latitude": 10.8282,
        "longitude": 78.6868,
        "location_name": "Tiruchirappalli",
        "basin_name": "Cauvery",
    }
    response = await client.get("/api/v1/hydro/overview", params=params)
    assert response.status_code == 200
    data = response.json()

    assert data["selected_basin"] == "Cauvery"
    assert data["basin_summary"]["basin_name"] == "Cauvery"

    # All returned stations should belong to Cauvery
    for station in data["gauge_stations"]:
        assert station["basin"] == "Cauvery"

    # All returned dams should belong to Cauvery
    for dam in data["reservoirs"]:
        assert dam["basin"] == "Cauvery"

    mettur_dam = next((d for d in data["reservoirs"] if "Mettur" in d["name"]), None)
    assert mettur_dam is not None
    assert mettur_dam["spillway_status"] in ("Closed", "Controlled Discharge", "Heavy Inflow Spillage")


@pytest.mark.asyncio
async def test_get_hydro_overview_brahmaputra(client):
    """Verify Brahmaputra basin hydrograph telemetry and high flood marks."""
    params = {
        "latitude": 26.1833,
        "longitude": 91.6833,
        "location_name": "Guwahati",
    }
    response = await client.get("/api/v1/hydro/overview", params=params)
    assert response.status_code == 200
    data = response.json()

    assert data["selected_basin"] == "Brahmaputra"
    nearest = data["nearest_gauge_station"]
    assert nearest is not None
    assert "Guwahati" in nearest["name"]
    assert nearest["river"] == "Brahmaputra"
    assert nearest["highest_flood_level_m"] == 51.46
