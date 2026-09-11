"""Test health check endpoint."""
import pytest


@pytest.mark.asyncio
async def test_health_check(client):
    response = await client.get("/api/v1/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "VaanilaiAI" in data["service"]
    assert "open_meteo" in data["providers"]
