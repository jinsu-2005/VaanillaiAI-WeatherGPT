"""Test weather forecast and current condition endpoints."""
import pytest


@pytest.mark.asyncio
async def test_get_forecast(client):
    # Test for Nagercoil coordinates
    lat = 8.1833
    lon = 77.4119
    response = await client.get(f"/api/v1/weather/forecast?latitude={lat}&longitude={lon}&location_name=Nagercoil&days=3")
    assert response.status_code == 200
    data = response.json()
    assert data["location_name"] == "Nagercoil"
    assert "current" in data
    assert "temperature" in data["current"]
    assert "hourly" in data
    assert len(data["hourly"]) > 0
    assert "daily" in data
    assert len(data["daily"]) == 3
    assert data["current"]["provenance"]["source_type"] is not None


@pytest.mark.asyncio
async def test_get_current_weather(client):
    lat = 13.0827
    lon = 80.2707
    response = await client.get(f"/api/v1/weather/current?latitude={lat}&longitude={lon}&location_name=Chennai")
    assert response.status_code == 200
    data = response.json()
    assert "temperature" in data
    assert "humidity" in data
    assert "wind_speed" in data
    assert "condition_text" in data


@pytest.mark.asyncio
async def test_multi_model_comparison(client):
    lat = 13.0827
    lon = 80.2707
    response = await client.get(f"/api/v1/weather/multi-model-comparison?latitude={lat}&longitude={lon}&location_name=Chennai&days=4")
    assert response.status_code == 200
    data = response.json()
    assert data["location_name"] == "Chennai"
    assert data["days_count"] == 4
    assert data["overall_confidence"] in ["High", "Moderate", "Low"]
    assert len(data["daily_comparisons"]) == 4
    assert len(data["model_metadata"]) == 3

    # Verify per-day comparison structure
    first_day = data["daily_comparisons"][0]
    assert "ecmwf_ifs025" in first_day["models"]
    assert "gfs_seamless" in first_day["models"]
    assert "icon_seamless" in first_day["models"]
    assert first_day["consensus_rain_mean_mm"] >= 0.0
    assert first_day["rain_spread_mm"] >= 0.0
    assert first_day["confidence"] in ["High", "Moderate", "Low"]
    assert len(first_day["divergence_note"]) > 0


@pytest.mark.asyncio
async def test_satellite_radar_overview(client):
    # Test for Chennai coordinates
    lat = 13.0827
    lon = 80.2707
    response = await client.get(f"/api/v1/weather/satellite-radar?latitude={lat}&longitude={lon}&location_name=Chennai")
    assert response.status_code == 200
    data = response.json()

    # DWR Stations check
    assert len(data["dwr_stations"]) >= 15
    first_station = data["dwr_stations"][0]
    assert "station_id" in first_station
    assert "band" in first_station
    assert first_station["status"] == "Operational"

    # Nearest Radar check for Chennai
    nearest = data["nearest_dwr_station"]
    assert nearest is not None
    assert "Chennai" in nearest["name"]
    assert data["distance_to_nearest_radar_km"] is not None
    assert data["distance_to_nearest_radar_km"] < 50.0
    assert "100km Nowcast Range" in data["local_radar_coverage_status"]

    # MOSDAC Satellite Products check
    products = data["satellite_products"]
    assert len(products) == 4
    product_ids = [p["product_id"] for p in products]
    assert "insat3dr_tir1_ctt" in product_ids
    assert "insat3dr_wv" in product_ids
    assert "insat3dr_vis" in product_ids
    assert "insat3dr_rgb" in product_ids

    # Provenance attribution
    assert "ISRO MOSDAC" in data["data_provenance"]
    assert "IMD" in data["data_provenance"]

