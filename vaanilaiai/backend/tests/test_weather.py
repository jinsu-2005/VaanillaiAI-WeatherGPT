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
