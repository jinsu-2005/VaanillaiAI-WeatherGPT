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


@pytest.mark.asyncio
async def test_district_agromet_bulletin(client):
    lat = 10.7870
    lon = 79.1378
    district = "Thanjavur"
    state = "Tamil Nadu"
    response = await client.get(
        f"/api/v1/advisories/agromet-bulletin?latitude={lat}&longitude={lon}&district={district}&state={state}&language=en"
    )
    assert response.status_code == 200
    data = response.json()
    assert data["district"] == district
    assert data["state"] == state
    assert "GKMS" in data["bulletin_number"]
    assert "TNAU" in data["amfu_center"] or "AMFU" in data["amfu_center"]
    assert len(data["five_day_forecast"]) == 5
    for day in data["five_day_forecast"]:
        assert 0 <= day["cloud_cover_octa"] <= 8
        assert day["rainfall_mm"] >= 0.0
        assert len(day["day_name"]) > 0
    assert len(data["general_farm_advisories"]) >= 1
    assert len(data["crop_advisories"]) >= 3
    assert any("paddy" in c["crop_name"].lower() or "rice" in c["crop_name"].lower() for c in data["crop_advisories"])
    assert len(data["livestock_advisories"]) >= 2
    assert "ICAR-IMD" in data["provenance_disclaimer"]


@pytest.mark.asyncio
async def test_urban_flood_risk(client):
    lat = 13.0827
    lon = 80.2707
    location_name = "Chennai Central"
    response = await client.get(
        f"/api/v1/advisories/urban-flood?latitude={lat}&longitude={lon}&location_name={location_name}&district=Chennai"
    )
    assert response.status_code == 200
    data = response.json()
    assert data["location_name"] == location_name
    assert "risk_score" in data
    assert 0 <= data["risk_score"] <= 100
    assert data["risk_tier"] in ["Low", "Moderate", "High", "Severe"]
    assert data["estimated_water_depth_inches"] >= 0.0
    assert data["drain_capacity_mm_h"] == 20.0
    assert "underpass_status" in data
    assert "two_wheeler_directive" in data
    assert "car_directive" in data
    assert len(data["critical_vulnerable_hotspots"]) >= 2


@pytest.mark.asyncio
async def test_incois_marine_advisory_coastal(client):
    lat = 13.0827
    lon = 80.2707
    response = await client.get(f"/api/v1/advisories/marine?latitude={lat}&longitude={lon}&location_name=Chennai")
    assert response.status_code == 200
    data = response.json()
    assert data["is_coastal_location"] is True
    assert "Coromandel" in data["coastal_sector_name"]
    assert "kallakkadal_surge_risk" in data
    assert data["kallakkadal_surge_risk"] in ["None", "Watch", "Warning", "Severe Kallakkadal Event"]
    assert "vessel_category_directives" in data
    assert "non_motorized_artisanal" in data["vessel_category_directives"]
    assert "motorized_boats" in data["vessel_category_directives"]
    assert "deep_sea_mechanized" in data["vessel_category_directives"]
    assert "vernacular_coastal_directives" in data
    assert "ta" in data["vernacular_coastal_directives"]
    assert "ml" in data["vernacular_coastal_directives"]
    assert data["significant_wave_height_m"] > 0.0
    assert data["swell_period_seconds"] > 0.0
    assert 0 <= data["port_warning_signal_number"] <= 11


@pytest.mark.asyncio
async def test_incois_marine_advisory_inland(client):
    lat = 28.6139
    lon = 77.2090
    response = await client.get(f"/api/v1/advisories/marine?latitude={lat}&longitude={lon}&location_name=New+Delhi")
    assert response.status_code == 200
    data = response.json()
    assert data["is_coastal_location"] is False
    assert "Inland" in data["sea_condition"]
    assert data["kallakkadal_surge_risk"] == "None"
    assert data["significant_wave_height_m"] == 0.0
