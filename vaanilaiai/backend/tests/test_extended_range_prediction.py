from fastapi.testclient import TestClient
import pytest
from app.main import app

client = TestClient(app)


def test_get_extended_range_default_zone():
    """Test retrieving default zone (Vidarbha / Central India)."""
    response = client.get("/api/v1/monsoon/extended-range")
    assert response.status_code == 200
    data = response.json()

    assert data["zone_id"] == "vidarbha_central_rainfed"
    assert "Central India" in data["zone_name"]
    assert data["state"] == "Maharashtra"
    assert len(data["all_zones"]) == 7
    assert data["mme_model_consensus_pct"] >= 80.0
    assert "CFSv2" in data["data_source"]


def test_get_extended_range_specific_zone():
    """Test retrieving a specific zone (Eastern Gangetic Rice Basin)."""
    response = client.get("/api/v1/monsoon/extended-range?zone_id=eastern_gangetic_rice_basin")
    assert response.status_code == 200
    data = response.json()

    assert data["zone_id"] == "eastern_gangetic_rice_basin"
    assert data["state"] == "Bihar"
    current = data["current_zone"]
    assert "Kharif Paddy" in current["dominant_crops"][0]
    # Week 1 has Large Excess due to foothill convergence
    w1 = current["four_week_forecast"][0]
    assert w1["rainfall_lpa_departure_pct"] == 65.0
    assert w1["departure_tier"] == "LARGE_EXCESS"


def test_four_week_sequence_and_departure_tiers():
    """Test that every zone has a 4-week chronological forecast with valid departure tiers."""
    response = client.get("/api/v1/monsoon/extended-range?zone_id=konkan_malabar_coastal")
    assert response.status_code == 200
    data = response.json()
    forecast = data["current_zone"]["four_week_forecast"]

    assert len(forecast) == 4
    for idx, week in enumerate(forecast, start=1):
        assert week["week_number"] == idx
        assert "Week " in week["date_range_label"]
        assert week["rainfall_forecast_mm"] >= 0.0
        assert week["normal_lpa_rainfall_mm"] > 0.0
        assert week["departure_tier"] in [
            "LARGE_EXCESS",
            "EXCESS",
            "NORMAL",
            "DEFICIENT",
            "LARGE_DEFICIENT",
            "NO_RAIN",
        ]


def test_intra_seasonal_pulse_telemetry():
    """Test BSISO and MJO pulse tracking parameters."""
    response = client.get("/api/v1/monsoon/extended-range?zone_id=vidarbha_central_rainfed")
    assert response.status_code == 200
    pulse = response.json()["current_zone"]["intra_seasonal_pulse"]

    assert pulse["bsiso_mode"] in ["BSISO_1_CANONICAL_30_60D", "BSISO_2_QUASI_BIWEEKLY_10_20D"]
    assert 1 <= pulse["bsiso_active_phase"] <= 8
    assert pulse["bsiso_amplitude"] > 0.0
    assert pulse["northward_propagation_speed_deg_per_day"] > 0.0
    assert "PHASE_" in pulse["mjo_phase"]
    assert pulse["findlater_jet_speed_kt"] > 0.0
    assert 10.0 <= pulse["monsoon_trough_position_latitude"] <= 35.0


def test_break_monsoon_detection():
    """Test break monsoon condition when trough shifts to Himalayan foothills."""
    response = client.get("/api/v1/monsoon/extended-range?zone_id=vidarbha_central_rainfed")
    assert response.status_code == 200
    current = response.json()["current_zone"]
    pulse = current["intra_seasonal_pulse"]

    assert pulse["break_spell_risk"] is True
    assert pulse["monsoon_trough_position_latitude"] >= 28.0
    assert current["four_week_forecast"][0]["monsoon_spell_state"] == "BREAK_MONSOON_CRITICAL"


def test_icar_crida_contingency_directives():
    """Test ICAR-CRIDA district agricultural contingency advice generation."""
    response = client.get("/api/v1/monsoon/extended-range?zone_id=vidarbha_central_rainfed")
    assert response.status_code == 200
    contingency = response.json()["current_zone"]["agricultural_contingency"]

    assert contingency["stress_level"] == "WARNING_PROLONGED_DRY_SPELL"
    assert len(contingency["contingency_crop_alternatives"]) >= 2
    assert "Amrit Sarovar" in contingency["irrigation_mitigation_directive"] or "farm pond" in contingency["irrigation_mitigation_directive"].lower()
    assert "Broad Bed Furrow" in contingency["in_situ_moisture_conservation"] or "mulch" in contingency["in_situ_moisture_conservation"].lower()
    assert "KNO3" in contingency["standing_crop_intervention"] or "Potassium Nitrate" in contingency["standing_crop_intervention"]


def test_multilingual_bulletin_availability():
    """Test availability of bulletins across 8 regional Indian languages."""
    response = client.get("/api/v1/monsoon/extended-range?zone_id=vidarbha_central_rainfed")
    assert response.status_code == 200
    bulletins = response.json()["current_zone"]["vernacular_bulletins"]

    for lang in ["en", "hi", "mr", "te", "pa", "bn", "gu", "kn"]:
        assert lang in bulletins
        assert len(bulletins[lang]) > 20


def test_geodetic_nearest_zone_resolution():
    """Test matching coordinates to Punjab/Indo-Gangetic Breadbasket."""
    # Coordinates near Ludhiana, Punjab
    response = client.get("/api/v1/monsoon/extended-range?latitude=30.90&longitude=75.85")
    assert response.status_code == 200
    data = response.json()
    assert data["zone_id"] == "indo_gangetic_breadbasket"
    assert data["state"] == "Punjab"


def test_geodetic_southern_resolution():
    """Test matching coordinates to Southern Peninsular Semi-Arid Millet Belt."""
    # Coordinates near Hyderabad, Telangana
    response = client.get("/api/v1/monsoon/extended-range?latitude=17.38&longitude=78.48")
    assert response.status_code == 200
    data = response.json()
    assert data["zone_id"] == "southern_peninsular_millet"
    assert data["state"] == "Telangana"


def test_all_zones_summary_structure():
    """Test the structure and content of all_zones summary list."""
    response = client.get("/api/v1/monsoon/extended-range")
    assert response.status_code == 200
    all_zones = response.json()["all_zones"]

    assert len(all_zones) == 7
    for z in all_zones:
        assert "zone_id" in z
        assert "zone_name" in z
        assert "state" in z
        assert "sub_division_name" in z
        assert "current_monsoon_spell" in z
        assert "week1_departure_pct" in z
        assert "week2_departure_pct" in z
        assert isinstance(z["contingency_alert_active"], bool)
