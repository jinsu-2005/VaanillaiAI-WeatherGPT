"""
Tests for NIWE (National Institute of Wind Energy) & IMD
National Wind Resource Assessment, Hub-Height Shear & Wind Farm Generation Forecasting Engine.
"""
import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.services.wind_energy_service import WindEnergyService

client = TestClient(app)


class TestWindEnergyAPI:
    """Test wind energy assessment API and physics service."""

    def test_default_wind_energy_endpoint(self):
        """Test default wind energy assessment returns HTTP 200 and all expected root keys."""
        response = client.get("/api/v1/advisories/wind-energy")
        assert response.status_code == 200
        data = response.json()
        assert "selected_corridor" in data
        assert "all_corridors" in data
        assert "bulletins" in data
        assert "offline_cached" in data
        assert "generated_at" in data
        assert data["offline_cached"] is False

    def test_all_seven_corridors_present(self):
        """Test all 7 iconic Indian wind energy corridors are present in summary catalog."""
        response = client.get("/api/v1/advisories/wind-energy")
        assert response.status_code == 200
        data = response.json()
        summaries = data["all_corridors"]
        assert len(summaries) == 7
        ids = [s["corridor_id"] for s in summaries]
        assert "muppandal_tamil_nadu" in ids
        assert "jaisalmer_rajasthan" in ids
        assert "brahmanvel_maharashtra" in ids
        assert "damanjodi_odisha" in ids
        assert "kayathar_tamil_nadu" in ids
        assert "kutch_gujarat" in ids
        assert "chitradurga_karnataka" in ids

    def test_muppandal_corridor_lookup(self):
        """Test Muppandal wind farm features high shear, excellent resource tier, and high CUF."""
        response = client.get(
            "/api/v1/advisories/wind-energy",
            params={"corridor_id": "muppandal_tamil_nadu"},
        )
        assert response.status_code == 200
        data = response.json()
        selected = data["selected_corridor"]
        assert selected["corridor_id"] == "muppandal_tamil_nadu"
        assert selected["state"] == "Tamil Nadu"
        assert selected["installed_capacity_mw"] == 1500.0
        assert selected["terrain_roughness_alpha"] == 0.20

        # Hub height profiles
        profiles = selected["hub_height_profiles"]
        assert len(profiles) == 7
        heights = [p["height_m"] for p in profiles]
        assert heights == [10, 50, 80, 100, 120, 140, 150]

        # Check shear increases speed with height
        v10 = profiles[0]["wind_speed_ms"]
        v100 = next(p["wind_speed_ms"] for p in profiles if p["height_m"] == 100)
        v150 = next(p["wind_speed_ms"] for p in profiles if p["height_m"] == 150)
        assert v10 < v100 < v150
        assert v100 >= 9.0  # Muppandal strong gap jet at 100m

        # Turbine profiles
        turbines = selected["turbine_profiles"]
        assert len(turbines) == 2
        assert turbines[0]["rated_power_mw"] == 2.0
        assert turbines[1]["rated_power_mw"] == 3.0
        assert turbines[1]["capacity_utilization_factor_pct"] >= 30.0

    def test_jaisalmer_desert_thermal_derating(self):
        """Test Jaisalmer desert wind park undergoes thermal air density thinning."""
        response = client.get(
            "/api/v1/advisories/wind-energy",
            params={"corridor_id": "jaisalmer_rajasthan"},
        )
        assert response.status_code == 200
        data = response.json()
        selected = data["selected_corridor"]
        air_density = selected["air_density"]

        assert selected["state"] == "Rajasthan"
        assert air_density["surface_temperature_c"] >= 35.0
        assert air_density["air_density_kgm3"] < 1.15  # Thin air in desert heat
        assert air_density["density_ratio"] < 0.95
        assert "kinetic flux penalty" in air_density["thermal_derating_note"]

    def test_damanjodi_high_altitude_and_shear(self):
        """Test Damanjodi hill corridor has elevated terrain, lower pressure, and alpha 0.22."""
        response = client.get(
            "/api/v1/advisories/wind-energy",
            params={"corridor_id": "damanjodi_odisha"},
        )
        assert response.status_code == 200
        data = response.json()
        selected = data["selected_corridor"]
        assert selected["elevation_m"] == 910.0
        assert selected["terrain_roughness_alpha"] == 0.22
        assert selected["air_density"]["surface_pressure_hpa"] < 950.0

    def test_power_law_speed_extrapolation_logic(self):
        """Direct unit test of Hellmann power law calculation."""
        v10 = 5.0
        alpha = 0.20
        v100 = WindEnergyService.calculate_power_law_speed(v10, 100, alpha)
        # 5.0 * (100 / 10)^0.20 = 5.0 * 10^0.20 = 5.0 * 1.5849 = 7.92
        assert abs(v100 - 7.92) <= 0.05

        v10_same = WindEnergyService.calculate_power_law_speed(v10, 10, alpha)
        assert v10_same == 5.0

    def test_turbine_operating_state_transitions(self):
        """Test turbine power curve correctly transitions across all operating states."""
        # Below cut-in (< 3.0 m/s)
        turb_cutin = WindEnergyService.evaluate_turbine_power(
            model_name="Test Turb",
            rated_mw=2.0,
            rotor_diam_m=100.0,
            hub_m=100,
            wind_speed_ms=2.5,
            air_density_kgm3=1.225,
            wake_loss_pct=7.0,
            bop_loss_pct=3.0,
            soiling_loss_pct=2.0,
        )
        assert turb_cutin.operating_state.value == "BELOW_CUT_IN"
        assert turb_cutin.gross_hourly_output_mw == 0.0
        assert turb_cutin.net_hourly_output_mw == 0.0

        # Partial load ramp (3.0 <= v < 11.5 m/s)
        turb_ramp = WindEnergyService.evaluate_turbine_power(
            model_name="Test Turb",
            rated_mw=2.0,
            rotor_diam_m=100.0,
            hub_m=100,
            wind_speed_ms=8.0,
            air_density_kgm3=1.225,
            wake_loss_pct=7.0,
            bop_loss_pct=3.0,
            soiling_loss_pct=2.0,
        )
        assert turb_ramp.operating_state.value == "PARTIAL_LOAD_RAMP"
        assert 0.0 < turb_ramp.net_hourly_output_mw < 2.0

        # Rated full load (11.5 <= v < 25.0 m/s)
        turb_rated = WindEnergyService.evaluate_turbine_power(
            model_name="Test Turb",
            rated_mw=2.0,
            rotor_diam_m=100.0,
            hub_m=100,
            wind_speed_ms=14.0,
            air_density_kgm3=1.225,
            wake_loss_pct=7.0,
            bop_loss_pct=3.0,
            soiling_loss_pct=2.0,
        )
        assert turb_rated.operating_state.value == "RATED_FULL_LOAD"
        assert turb_rated.gross_hourly_output_mw == 2.0
        # Net should apply losses: 2.0 * (1 - 0.07) * (1 - 0.03) * (1 - 0.02) = 2.0 * 0.93 * 0.97 * 0.98 ~ 1.768 MW
        assert 1.75 <= turb_rated.net_hourly_output_mw <= 1.80

        # Storm cut-out (>= 25.0 m/s)
        turb_cutout = WindEnergyService.evaluate_turbine_power(
            model_name="Test Turb",
            rated_mw=2.0,
            rotor_diam_m=100.0,
            hub_m=100,
            wind_speed_ms=26.0,
            air_density_kgm3=1.225,
            wake_loss_pct=7.0,
            bop_loss_pct=3.0,
            soiling_loss_pct=2.0,
        )
        assert turb_cutout.operating_state.value == "STORM_CUT_OUT"
        assert turb_cutout.gross_hourly_output_mw == 0.0
        assert turb_cutout.net_hourly_output_mw == 0.0

    def test_repowering_potential_multiplication(self):
        """Test repowering calculation produces substantial energy multiplier and carbon offset."""
        repower = WindEnergyService.compute_repowering_potential(
            legacy_kw=400.0,
            legacy_hub_m=45,
            modern_mw=3.0,
            modern_hub_m=140,
            v10=6.4,
            alpha=0.20,
        )
        assert repower.energy_yield_multiplier >= 2.2
        assert repower.co2_abatement_tons_yr >= 1000.0
        assert repower.repowering_priority in ["HIGH", "MODERATE", "OPTIMIZED"]

    def test_vernacular_bulletins_all_languages_present(self):
        """Test multi-lingual bulletins are synthesized in all 7 designated Indian languages."""
        response = client.get("/api/v1/advisories/wind-energy")
        assert response.status_code == 200
        data = response.json()
        bulletins = data["bulletins"]
        for lang in ["en", "ta", "hi", "gu", "mr", "kn", "od"]:
            assert lang in bulletins
            assert len(bulletins[lang]) > 30

    def test_geodetic_nearest_corridor_lookup(self):
        """Test coordinate lookup near Kutch returns kutch_gujarat corridor."""
        response = client.get(
            "/api/v1/advisories/wind-energy",
            params={"latitude": 23.2, "longitude": 69.7},
        )
        assert response.status_code == 200
        data = response.json()
        assert data["selected_corridor"]["corridor_id"] == "kutch_gujarat"
