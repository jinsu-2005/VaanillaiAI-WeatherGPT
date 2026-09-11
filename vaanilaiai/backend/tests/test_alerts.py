"""Test disaster warning endpoints."""
import pytest


@pytest.mark.asyncio
async def test_get_active_alerts(client):
    response = await client.get("/api/v1/alerts/active?district=Chennai")
    assert response.status_code == 200
    data = response.json()
    assert "total_active_alerts" in data
    assert "highest_severity" in data
    assert "alerts" in data
    assert isinstance(data["alerts"], list)
