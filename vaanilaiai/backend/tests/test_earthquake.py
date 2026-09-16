"""
Tests for NCS/IMD & NDMA National Earthquake Seismology, Fault-Line Proximity
& Aftershock Probabilistic Engine.
"""
import pytest
from fastapi.testclient import TestClient
from app.main import app


client = TestClient(app)


class TestEarthquakeAPI:
    """Test earthquake seismology assessment endpoint."""

    def test_earthquake_default_assessment(self):
        """Test default earthquake assessment returns valid response."""
        response = client.get("/api/v1/alerts/earthquake")
        assert response.status_code == 200
        data = response.json()
        assert "timestamp" in data
        assert "bulletin_number" in data
        assert "provenance" in data
        assert "NCS" in data["provenance"]
        assert "NDMA" in data["provenance"]
        assert "national_seismicity_synopsis" in data
        assert "selected_province" in data
        assert "all_provinces" in data
        assert "seismological_model" in data
        assert "vernacular_bulletins" in data
        assert data["is_offline_cached"] is False

    def test_earthquake_all_provinces_present(self):
        """Test that all 7 seismotectonic provinces are returned."""
        response = client.get("/api/v1/alerts/earthquake")
        data = response.json()
        assert len(data["all_provinces"]) == 7
        province_ids = [p["province_id"] for p in data["all_provinces"]]
        assert "nw_himalaya_jk_hp" in province_ids
        assert "ne_himalaya_sikkim_assam" in province_ids
        assert "kutch_saurashtra_gj" in province_ids
        assert "delhi_ncr_igp" in province_ids
        assert "andaman_nicobar_subduction" in province_ids
        assert "koyna_deccan_mh" in province_ids
        assert "uttarakhand_garhwal_uk" in province_ids

    def test_earthquake_province_id_lookup(self):
        """Test province-based lookup by specific province_id."""
        response = client.get(
            "/api/v1/alerts/earthquake",
            params={"province_id": "ne_himalaya_sikkim_assam"},
        )
        assert response.status_code == 200
        data = response.json()
        selected = data["selected_province"]
        assert selected["province_id"] == "ne_himalaya_sikkim_assam"
        assert "Sikkim" in selected["province_name"]
        assert selected["alert_tier"] == "RED_DEVASTATING"

    def test_earthquake_coordinate_proximity(self):
        """Test coordinate-based nearest province selection (Haversine)."""
        # Coordinates near Bhuj, Gujarat — should resolve to kutch_saurashtra_gj
        response = client.get(
            "/api/v1/alerts/earthquake",
            params={"latitude": 23.25, "longitude": 69.67},
        )
        assert response.status_code == 200
        data = response.json()
        assert data["selected_province"]["province_id"] == "kutch_saurashtra_gj"

    def test_earthquake_source_parameters(self):
        """Test earthquake source parameters are scientifically valid."""
        response = client.get(
            "/api/v1/alerts/earthquake",
            params={"province_id": "nw_himalaya_jk_hp"},
        )
        data = response.json()
        source = data["selected_province"]["source_parameters"]
        assert source["moment_magnitude_mw"] == 6.2
        assert source["local_magnitude_ml"] == 6.0
        assert source["focal_depth_km"] == 12.5
        assert source["fault_mechanism"] == "REVERSE_THRUST"
        assert 0 <= source["fault_plane_strike_deg"] <= 360
        assert source["rupture_length_km"] > 0

    def test_earthquake_mmi_assessment(self):
        """Test Modified Mercalli Intensity assessment."""
        response = client.get(
            "/api/v1/alerts/earthquake",
            params={"province_id": "ne_himalaya_sikkim_assam"},
        )
        data = response.json()
        mmi = data["selected_province"]["mmi_assessment"]
        assert mmi["epicentral_mmi"] == "IX"
        assert mmi["felt_radius_km"] == 620.0
        assert "Violent" in mmi["perceived_shaking"]
        assert mmi["did_you_feel_it_reports"] > 0

    def test_earthquake_aftershock_probability(self):
        """Test Båth's Law and Reasenberg-Jones aftershock prediction."""
        response = client.get(
            "/api/v1/alerts/earthquake",
            params={"province_id": "ne_himalaya_sikkim_assam"},
        )
        data = response.json()
        aftershock = data["selected_province"]["aftershock_outlook"]
        # Båth's Law: largest aftershock ≈ Mw_main - 1.2
        main_mw = data["selected_province"]["source_parameters"]["moment_magnitude_mw"]
        expected_bath = main_mw - 1.2
        assert abs(aftershock["bath_law_largest_aftershock_mw"] - expected_bath) < 0.5
        assert 0.8 <= aftershock["modified_omori_p_value"] <= 1.5
        assert 0 <= aftershock["reasenberg_jones_24h_probability_pct"] <= 100
        assert aftershock["expected_aftershocks_7_day"] > 0

    def test_earthquake_bis_seismic_zone(self):
        """Test BIS IS:1893 seismic zone classification."""
        response = client.get(
            "/api/v1/alerts/earthquake",
            params={"province_id": "delhi_ncr_igp"},
        )
        data = response.json()
        directives = data["selected_province"]["structural_directives"]
        assert directives["bis_seismic_zone"] == "ZONE_IV"
        assert directives["design_pga_g"] == 0.24
        assert len(directives["ndma_dos"]) > 0
        assert len(directives["ndma_donts"]) > 0

    def test_earthquake_zone_v_classification(self):
        """Test Zone V classification for highest seismicity provinces."""
        zone_v_provinces = [
            "nw_himalaya_jk_hp",
            "ne_himalaya_sikkim_assam",
            "kutch_saurashtra_gj",
            "andaman_nicobar_subduction",
            "uttarakhand_garhwal_uk",
        ]
        for prov_id in zone_v_provinces:
            response = client.get(
                "/api/v1/alerts/earthquake",
                params={"province_id": prov_id},
            )
            data = response.json()
            zone = data["selected_province"]["structural_directives"]["bis_seismic_zone"]
            assert zone == "ZONE_V", f"Expected ZONE_V for {prov_id}, got {zone}"

    def test_earthquake_vernacular_alerts(self):
        """Test multilingual vernacular alerts are populated."""
        response = client.get(
            "/api/v1/alerts/earthquake",
            params={"province_id": "koyna_deccan_mh"},
        )
        data = response.json()
        alerts = data["selected_province"]["vernacular_alerts"]
        assert "en" in alerts
        assert "hi" in alerts
        assert "mr" in alerts  # Marathi for Maharashtra

    def test_earthquake_alert_tier_red(self):
        """Test RED_DEVASTATING alert tier attributes."""
        response = client.get(
            "/api/v1/alerts/earthquake",
            params={"province_id": "ne_himalaya_sikkim_assam"},
        )
        data = response.json()
        assert data["selected_province"]["alert_tier"] == "RED_DEVASTATING"
        assert "CRITICAL" in data["national_seismicity_synopsis"]

    def test_earthquake_alert_tier_green(self):
        """Test GREEN_LIGHT alert tier for minor tremors."""
        response = client.get(
            "/api/v1/alerts/earthquake",
            params={"province_id": "delhi_ncr_igp"},
        )
        data = response.json()
        assert data["selected_province"]["alert_tier"] == "GREEN_LIGHT"
        assert data["selected_province"]["source_parameters"]["moment_magnitude_mw"] < 5.0

    def test_earthquake_andaman_tsunami_nexus(self):
        """Test Andaman subduction zone with tsunami awareness content."""
        response = client.get(
            "/api/v1/alerts/earthquake",
            params={"province_id": "andaman_nicobar_subduction"},
        )
        data = response.json()
        selected = data["selected_province"]
        assert "Andaman Trench" in selected["dominant_fault_system"]
        # Verify tsunami-related NDMA directives exist for coastal seismic zone
        dos_text = " ".join(selected["structural_directives"]["ndma_dos"])
        assert "tsunami" in dos_text.lower() or "higher ground" in dos_text.lower()

    def test_earthquake_bulletin_number_format(self):
        """Test bulletin number follows NCS reference format."""
        response = client.get("/api/v1/alerts/earthquake")
        data = response.json()
        assert data["bulletin_number"].startswith("NCS/IMD-SEIS/")
