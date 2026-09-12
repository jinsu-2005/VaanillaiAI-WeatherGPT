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


@pytest.mark.asyncio
async def test_stream_alerts_endpoint(client):
    """Verify Server-Sent Events alert stream connection."""
    async with client.stream("GET", "/api/v1/alerts/stream?district=Chennai&max_events=1") as response:
        assert response.status_code == 200
        assert "text/event-stream" in response.headers.get("content-type", "")
        # Read the first event chunk
        first_chunk = ""
        async for line in response.aiter_lines():
            if line:
                first_chunk += line + "\n"
            if "event: alert_snapshot" in first_chunk and "data:" in first_chunk:
                break
        assert "event: alert_snapshot" in first_chunk
        await response.aclose()


@pytest.mark.asyncio
async def test_get_imd_sop_matrix(client):
    """Verify retrieval of IMD 4-color warning matrix and NDMA SOP guidelines."""
    response = await client.get("/api/v1/alerts/sop")
    assert response.status_code == 200
    data = response.json()

    assert "warning_stages" in data
    assert len(data["warning_stages"]) == 4
    stage_codes = [s["code"] for s in data["warning_stages"]]
    assert "Green" in stage_codes
    assert "Yellow" in stage_codes
    assert "Orange" in stage_codes
    assert "Red" in stage_codes

    assert "hazard_sops" in data
    assert len(data["hazard_sops"]) >= 5
    hazard_ids = [h["hazard_id"] for h in data["hazard_sops"]]
    assert "cyclone" in hazard_ids
    assert "heavy_rainfall_flood" in hazard_ids
    assert "thunderstorm_lightning" in hazard_ids
    assert "heatwave" in hazard_ids
    assert "dense_fog_coldwave" in hazard_ids

    # Check structure of a hazard SOP
    cyclone = next(h for h in data["hazard_sops"] if h["hazard_id"] == "cyclone")
    assert len(cyclone["immediate_actions"]) >= 3
    assert len(cyclone["dos"]) >= 3
    assert len(cyclone["donts"]) >= 3
    assert len(cyclone["vulnerable_guidance"]) > 0

    assert "emergency_contacts" in data
    assert len(data["emergency_contacts"]) >= 5
    phone_numbers = [c["phone_number"] for c in data["emergency_contacts"]]
    assert "112" in phone_numbers
    assert "1078" in phone_numbers
    assert "1070" in phone_numbers
    assert "1077" in phone_numbers
    assert "108" in phone_numbers


@pytest.mark.asyncio
async def test_get_imd_sop_hazard_filter(client):
    """Verify hazard-specific filtering of SOP matrix."""
    response = await client.get("/api/v1/alerts/sop?hazard=thunderstorm_lightning")
    assert response.status_code == 200
    data = response.json()

    assert len(data["hazard_sops"]) == 1
    sop = data["hazard_sops"][0]
    assert sop["hazard_id"] == "thunderstorm_lightning"
    assert "30-30" in str(sop["immediate_actions"]) or "30-30" in str(sop["dos"])


@pytest.mark.asyncio
async def test_get_lightning_alert_damini(client):
    """Verify Damini lightning strike telemetry, flash-to-bang calculation, and vernacular advice."""
    lat = 13.0827
    lon = 80.2707
    response = await client.get(f"/api/v1/alerts/lightning?latitude={lat}&longitude={lon}&location_name=Chennai")
    assert response.status_code == 200
    data = response.json()

    assert data["location_name"] == "Chennai"
    assert "threat_level" in data
    assert data["threat_level"] in ["Safe", "Moderate", "High", "Severe"]
    assert "nearest_strike_km" in data
    assert data["flash_to_bang_delay_seconds"] >= 0.0
    assert "cape_thunderstorm_index_j_kg" in data
    assert "cape_stability_verdict" in data
    assert "safety_rule_30_30" in data
    assert "shelter_30min_guidance" in data
    assert "vernacular_directives" in data
    assert "ta" in data["vernacular_directives"]
    assert "hi" in data["vernacular_directives"]
    assert "en" in data["vernacular_directives"]
    assert len(data["field_safety_guidance"]) >= 4

