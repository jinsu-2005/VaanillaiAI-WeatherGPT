"""Test historical climate comparison and trend endpoints."""
import pytest


@pytest.mark.asyncio
async def test_compare_climate_years(client):
    lat = 28.6139
    lon = 77.2090
    response = await client.get(f"/api/v1/climate/compare?latitude={lat}&longitude={lon}&location_name=Delhi&year_1=2022&year_2=2023")
    assert response.status_code == 200
    data = response.json()
    assert data["year_1"] == 2022
    assert data["year_2"] == 2023
    assert "rainfall_difference_mm" in data
    assert "temperature_difference_c" in data
    assert "climate_summary" in data
    assert len(data["year_1_stats"]["monthly_stats"]) == 12
