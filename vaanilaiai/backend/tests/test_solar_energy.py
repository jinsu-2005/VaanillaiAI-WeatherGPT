"""
Tests for NISE, MNRE & IMD Solar Radiation, Photovoltaic (PV) Yield
& Rooftop Solar Generation Forecasting Engine.
"""
import pytest
from fastapi.testclient import TestClient
from app.main import app


client = TestClient(app)


class TestSolarEnergyAPI:
    """Test solar energy assessment endpoint."""

    def test_solar_energy_default_assessment(self):
        """Test default solar energy assessment returns valid response."""
        response = client.get("/api/v1/advisories/solar-energy")
        assert response.status_code == 200
        data = response.json()
        assert "timestamp" in data
        assert "bulletin_number" in data
        assert "provenance" in data
        assert "NISE" in data["provenance"]
        assert "MNRE" in data["provenance"]
        assert "IMD" in data["provenance"]
        assert "national_solar_overview" in data
        assert "selected_sector" in data
        assert "all_sectors" in data
        assert "solar_physics_model" in data
        assert "vernacular_bulletins" in data
        assert data["is_offline_cached"] is False

    def test_solar_all_sectors_present(self):
        """Test that all 7 representative solar sectors are present."""
        response = client.get("/api/v1/advisories/solar-energy")
        data = response.json()
        assert len(data["all_sectors"]) == 7
        park_ids = [s["park_id"] for s in data["all_sectors"]]
        assert "bhadla_rajasthan" in park_ids
        assert "pavagada_karnataka" in park_ids
        assert "charanka_gujarat" in park_ids
        assert "rewa_madhya_pradesh" in park_ids
        assert "kurnool_andhra_pradesh" in park_ids
        assert "delhi_ncr_rooftop" in park_ids
        assert "kamuthi_tamil_nadu" in park_ids

    def test_solar_park_id_lookup(self):
        """Test lookup by specific park_id."""
        response = client.get(
            "/api/v1/advisories/solar-energy",
            params={"park_id": "delhi_ncr_rooftop"},
        )
        assert response.status_code == 200
        data = response.json()
        selected = data["selected_sector"]
        assert selected["park_id"] == "delhi_ncr_rooftop"
        assert "Delhi-NCR" in selected["park_name"]
        assert selected["soiling_advisory"]["cleaning_recommended"] is True

    def test_solar_coordinate_proximity(self):
        """Test coordinate-based nearest park selection (Haversine)."""
        # Coordinates near Jodhpur / Phalodi, Rajasthan -> Bhadla
        response = client.get(
            "/api/v1/advisories/solar-energy",
            params={"latitude": 26.28, "longitude": 73.02},
        )
        assert response.status_code == 200
        data = response.json()
        assert data["selected_sector"]["park_id"] == "bhadla_rajasthan"

    def test_solar_irradiance_physics(self):
        """Test physical irradiance components."""
        response = client.get(
            "/api/v1/advisories/solar-energy",
            params={"park_id": "bhadla_rajasthan"},
        )
        data = response.json()
        irr = data["selected_sector"]["irradiance"]
        assert irr["ghi_wm2"] > 900.0
        assert irr["dni_wm2"] > 800.0
        assert irr["dhi_wm2"] > 100.0
        assert 0.0 <= irr["solar_zenith_angle_deg"] <= 90.0
        assert 0.5 <= irr["clearness_index_kt"] <= 1.0

    def test_solar_pv_performance(self):
        """Test PV cell temperature and derating performance."""
        response = client.get(
            "/api/v1/advisories/solar-energy",
            params={"park_id": "pavagada_karnataka"},
        )
        data = response.json()
        pv = data["selected_sector"]["pv_performance"]
        assert pv["pv_cell_temperature_c"] > pv["ambient_temperature_c"]
        assert pv["temperature_derating_pct"] < 0.0  # Thermal penalty
        assert 75.0 <= pv["performance_ratio_pct"] <= 85.0
        assert pv["specific_yield_kwh_per_kwp"] >= 5.0

    def test_soiling_and_cleaning_advisory(self):
        """Test particulate soiling metrics and washing guidance."""
        response = client.get(
            "/api/v1/advisories/solar-energy",
            params={"park_id": "delhi_ncr_rooftop"},
        )
        data = response.json()
        soil = data["selected_sector"]["soiling_advisory"]
        assert soil["soiling_loss_pct"] > 10.0
        assert soil["cleaning_recommended"] is True
        assert soil["cleaning_urgency"] == "URGENT_CLEANING_REQUIRED"
        assert len(soil["optimal_cleaning_window"]) > 0

    def test_rooftop_economics_scaling(self):
        """Test PM Surya Ghar rooftop solar capacity economics."""
        response = client.get(
            "/api/v1/advisories/solar-energy",
            params={"park_id": "pavagada_karnataka"},
        )
        data = response.json()
        econ = data["selected_sector"]["rooftop_economics"]
        assert len(econ) == 5  # 1, 2, 3, 5, 10 kWp
        # 3 kWp typical household
        sys_3kw = next(e for e in econ if e["capacity_kwp"] == 3.0)
        assert sys_3kw["daily_generation_kwh"] > 12.0
        assert sys_3kw["monthly_generation_kwh"] > 350.0
        assert sys_3kw["monthly_savings_inr"] > 2500.0
        assert sys_3kw["co2_offset_kg_per_month"] > 250.0

    def test_hourly_forecast_profile(self):
        """Test hourly generation daylight profile."""
        response = client.get(
            "/api/v1/advisories/solar-energy",
            params={"park_id": "charanka_gujarat"},
        )
        data = response.json()
        hourly = data["selected_sector"]["hourly_forecast"]
        assert len(hourly) == 13
        assert hourly[0]["hour"] == "06:00"
        assert hourly[-1]["hour"] == "18:00"
        # Noon generation should be peak
        noon = next(h for h in hourly if h["hour"] == "12:00")
        assert noon["ghi_wm2"] >= max(h["ghi_wm2"] for h in hourly) - 1.0
