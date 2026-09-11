"""Test agricultural and travel advisory endpoints."""
import pytest


@pytest.mark.asyncio
async def test_agriculture_advisory(client):
    lat = 11.0168
    lon = 76.9558
    response = await client.get(f"/api/v1/advisories/agriculture?latitude={lat}&longitude={lon}&location_name=Coimbatore")
    assert response.status_code == 200
    data = response.json()
    assert "spraying_suitability" in data
    assert data["spraying_suitability"] in ["Favorable", "Risky", "Unfavorable"]
    assert "spraying_reason" in data
    assert "irrigation_advice" in data
    assert "rain_risk_24h_mm" in data


@pytest.mark.asyncio
async def test_travel_advisory(client):
    lat = 19.0760
    lon = 72.8777
    response = await client.get(f"/api/v1/advisories/travel?latitude={lat}&longitude={lon}&location_name=Mumbai")
    assert response.status_code == 200
    data = response.json()
    assert "overall_suitability" in data
    assert data["overall_suitability"] in ["Good", "Caution", "Hazardous"]
    assert "travel_risk_score" in data
    assert 0 <= data["travel_risk_score"] <= 100
    assert "visibility_condition" in data
