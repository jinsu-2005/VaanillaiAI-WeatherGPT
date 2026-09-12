"""Test suite for IITM SAFAR & IMD AQEWS Air Quality and Atmospheric Dispersion Intelligence."""
import pytest
from app.services.safar_service import SafarService


@pytest.mark.asyncio
async def test_get_safar_air_quality_endpoint(client):
    """Verify retrieval of SAFAR 6-pollutant spectrum and atmospheric dispersion."""
    params = {
        "latitude": 28.6139,
        "longitude": 77.2090,
        "location_name": "New Delhi",
    }
    response = await client.get("/api/v1/air-quality/safar", params=params)
    assert response.status_code == 200
    data = response.json()

    assert data["location_name"] == "New Delhi"
    assert data["overall_aqi"] > 0
    assert data["cpcb_category"] in ("Good", "Satisfactory", "Moderate", "Poor", "Very Poor", "Severe")
    assert len(data["category_color_hex"]) == 7
    assert data["dominant_pollutant"] in ("PM2.5", "PM10", "NO2", "SO2", "CO", "O3")

    # Verify 6 pollutants
    assert len(data["pollutants"]) == 6
    codes = [p["pollutant_code"] for p in data["pollutants"]]
    assert "pm2_5" in codes
    assert "pm10" in codes
    assert "no2" in codes
    assert "so2" in codes
    assert "co" in codes
    assert "o3" in codes

    # Exactly one dominant pollutant
    dominant_count = sum(1 for p in data["pollutants"] if p["is_dominant_pollutant"])
    assert dominant_count == 1

    # Verify Atmospheric Dispersion
    disp = data["atmospheric_dispersion"]
    assert disp["mixing_layer_height_m"] > 0
    assert disp["surface_wind_speed_kmh"] > 0
    assert disp["ventilation_coefficient_m2s"] > 0
    assert disp["dispersion_category"] in ("Good", "Moderate", "Poor", "Critical")
    assert disp["inversion_risk"] in ("None", "Mild Inversion", "Severe Night Inversion")

    # Verify Stubble / Biomass Smoke Telemetry
    stubble = data["stubble_biomass_smoke"]
    assert stubble["active_fire_count_regional"] >= 0
    assert stubble["fire_radiative_power_mw"] >= 0
    assert stubble["transboundary_pm25_contribution_pct"] >= 0

    # Verify 72h Forecast
    assert len(data["aqi_forecast"]) == 2
    assert data["aqi_forecast"][0]["forecast_day"] == "Tomorrow"
    assert data["aqi_forecast"][1]["forecast_day"] == "Day After"

    # Verify Demographic Health Advisories
    assert len(data["demographic_advisories"]) >= 4
    groups = [d["demographic_group"] for d in data["demographic_advisories"]]
    assert any("Asthma" in g for g in groups)
    assert any("Cardiac" in g for g in groups)

    # Verify Vernacular Guidance
    assert "en" in data["vernacular_health_guidance"]
    assert "ta" in data["vernacular_health_guidance"]
    assert "hi" in data["vernacular_health_guidance"]
    assert "pa" in data["vernacular_health_guidance"]
    assert "bn" in data["vernacular_health_guidance"]

    # Verify Monitoring Stations
    assert len(data["monitoring_stations"]) >= 3


@pytest.mark.asyncio
async def test_get_safar_air_quality_city_filter(client):
    """Verify city_code parameter maps directly to specified metro hub."""
    params = {
        "latitude": 19.0760,
        "longitude": 72.8777,
        "location_name": "Mumbai",
        "city_code": "mumbai",
    }
    response = await client.get("/api/v1/air-quality/safar", params=params)
    assert response.status_code == 200
    data = response.json()

    assert data["selected_city_code"] == "mumbai"
    assert any("BKC" in st for st in data["monitoring_stations"])
    assert any("Colaba" in st for st in data["monitoring_stations"])


def test_cpcb_sub_index_calculation_logic():
    """Verify CPCB piecewise linear interpolation and breakpoint math."""
    # PM2.5: 0-30 -> 0-50
    idx, cat = SafarService.calculate_cpcb_sub_index("pm2_5", 15.0)
    assert idx == 25
    assert cat == "Good"

    # PM2.5: 31-60 -> 51-100
    idx, cat = SafarService.calculate_cpcb_sub_index("pm2_5", 45.0)
    assert 70 <= idx <= 80
    assert cat == "Satisfactory"

    # PM2.5: 61-90 -> 101-200
    idx, cat = SafarService.calculate_cpcb_sub_index("pm2_5", 75.0)
    assert 145 <= idx <= 155
    assert cat == "Moderate"

    # PM2.5: 91-120 -> 201-300
    idx, cat = SafarService.calculate_cpcb_sub_index("pm2_5", 105.0)
    assert 240 <= idx <= 260
    assert cat == "Poor"

    # PM2.5: 121-250 -> 301-400
    idx, cat = SafarService.calculate_cpcb_sub_index("pm2_5", 185.0)
    assert 345 <= idx <= 355
    assert cat == "Very Poor"

    # PM2.5: > 250 -> 401-500
    idx, cat = SafarService.calculate_cpcb_sub_index("pm2_5", 350.0)
    assert 435 <= idx <= 445
    assert cat == "Severe"

    # Ventilation Coefficient & Dispersion Category
    vc, disp, inv, _ = SafarService.calculate_ventilation_coefficient(400.0, 7.2)  # 7.2 km/h = 2 m/s -> vc = 800 m2/s
    assert vc == 800.0
    assert disp == "Critical"
    assert inv in ("None", "Mild Inversion", "Severe Night Inversion")

    vc_good, disp_good, _, _ = SafarService.calculate_ventilation_coefficient(1200.0, 21.6)  # 21.6 km/h = 6 m/s -> vc = 7200 m2/s
    assert vc_good == 7200.0
    assert disp_good == "Good"
