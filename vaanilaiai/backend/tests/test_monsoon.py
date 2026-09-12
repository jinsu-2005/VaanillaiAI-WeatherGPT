"""Test suite for NCMRWF & IMD Sub-Divisional Monsoon Teleconnections and Long-Range Forecasts."""
import pytest
from app.services.monsoon_service import MonsoonService


@pytest.mark.asyncio
async def test_get_monsoon_teleconnections_endpoint(client):
    """Verify retrieval of oceanic teleconnections and sub-divisional rainfall departures."""
    params = {
        "latitude": 13.0827,
        "longitude": 80.2707,
        "location_name": "Chennai",
    }
    response = await client.get("/api/v1/monsoon/teleconnections", params=params)
    assert response.status_code == 200
    data = response.json()

    assert data["location_name"] == "Chennai"
    assert data["user_sub_division"] is not None
    assert "Tamil Nadu" in data["user_sub_division"]["name"]
    assert data["user_sub_division"]["is_user_sub_division"] is True
    assert data["user_sub_division"]["departure_category"] in (
        "Large Excess", "Excess", "Normal", "Deficient", "Large Deficient"
    )

    # Check 3 macro teleconnection indices
    assert len(data["teleconnections"]) == 3
    enso = next((t for t in data["teleconnections"] if t["index_code"] == "enso_nino34"), None)
    assert enso is not None
    assert enso["current_value"] == -0.65
    assert "La Niña" in enso["phase"]
    assert enso["impact_on_monsoon"] == "Favorable"

    iod = next((t for t in data["teleconnections"] if t["index_code"] == "iod_dmi"), None)
    assert iod is not None
    assert iod["current_value"] == 0.48
    assert "Positive IOD" in iod["phase"]

    mjo = next((t for t in data["teleconnections"] if t["index_code"] == "mjo_convective"), None)
    assert mjo is not None
    assert mjo["current_value"] == 3.0

    # Check seasonal outlook probabilities (must sum close to 100)
    outlook = data["seasonal_outlook"]
    assert outlook["prob_below_normal_pct"] + outlook["prob_normal_pct"] + outlook["prob_above_normal_pct"] == 100
    assert "Normal to Above-Normal" in outlook["official_lrf_verdict"]

    # Check all 36 IMD sub-divisions are present
    assert len(data["all_sub_divisions"]) == 36
    user_sd_count = sum(1 for sd in data["all_sub_divisions"] if sd["is_user_sub_division"])
    assert user_sd_count == 1

    # Check adaptation directives and vernacular guidance
    assert len(data["adaptation_directives"]) >= 3
    assert "ta" in data["vernacular_advisories"]
    assert "hi" in data["vernacular_advisories"]
    assert "mr" in data["vernacular_advisories"]
    assert "bn" in data["vernacular_advisories"]


@pytest.mark.asyncio
async def test_get_monsoon_teleconnections_western_india(client):
    """Verify detection for Konkan & Goa and rainfall departures."""
    params = {
        "latitude": 18.9220,
        "longitude": 72.8347,
        "location_name": "Mumbai",
    }
    response = await client.get("/api/v1/monsoon/teleconnections", params=params)
    assert response.status_code == 200
    data = response.json()

    assert data["user_sub_division"]["name"] == "Konkan & Goa"
    assert data["user_sub_division"]["normal_rainfall_mm"] == 2910.0
    assert data["user_sub_division"]["actual_rainfall_mm"] == 3150.0
    assert data["user_sub_division"]["soil_moisture_index"] > 0.85


def test_monsoon_departure_and_drought_logic():
    """Verify official IMD departure categorization boundaries and drought thresholds."""
    # Large Excess: >= +60%
    dep, cat, col = MonsoonService._calculate_departure(160.0, 100.0)
    assert dep == 60.0
    assert cat == "Large Excess"
    assert col == "Blue"

    # Excess: +20% to +59%
    dep, cat, col = MonsoonService._calculate_departure(130.0, 100.0)
    assert dep == 30.0
    assert cat == "Excess"
    assert col == "Light Blue"

    # Normal: -19% to +19%
    dep, cat, col = MonsoonService._calculate_departure(95.0, 100.0)
    assert dep == -5.0
    assert cat == "Normal"
    assert col == "Green"

    # Deficient: -20% to -59%
    dep, cat, col = MonsoonService._calculate_departure(70.0, 100.0)
    assert dep == -30.0
    assert cat == "Deficient"
    assert col == "Red"

    # Large Deficient: <= -60%
    dep, cat, col = MonsoonService._calculate_departure(35.0, 100.0)
    assert dep == -65.0
    assert cat == "Large Deficient"
    assert col == "Yellow"

    # Drought Risk checks
    assert MonsoonService._get_drought_risk(-55.0, 0.35) == "Severe Drought"
    assert MonsoonService._get_drought_risk(-30.0, 0.45) == "Moderate Drought"
    assert MonsoonService._get_drought_risk(-18.0, 0.60) == "Mild Drought"
    assert MonsoonService._get_drought_risk(5.0, 0.70) == "Normal"
