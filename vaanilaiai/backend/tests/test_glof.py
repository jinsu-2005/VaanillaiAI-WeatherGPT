"""
Tests for NRSC-ISRO, CWC & NDMA Himalayan Glacial Lake Outburst Flood (GLOF)
& Moraine Dam Breach Early Warning Engine.
"""
import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.services.glof_service import GlofService

client = TestClient(app)


class TestGlofAPI:
    """Test GLOF early warning and hydrodynamics API."""

    def test_default_glof_assessment(self):
        """Test default GLOF assessment returns HTTP 200 and all expected root keys."""
        response = client.get("/api/v1/alerts/glof")
        assert response.status_code == 200
        data = response.json()
        assert "selected_lake" in data
        assert "all_lakes" in data
        assert "bulletins" in data
        assert "offline_cached" in data
        assert "generated_at" in data
        assert data["offline_cached"] is False

    def test_all_seven_lakes_present(self):
        """Test all 7 high-risk Himalayan glacial lakes are cataloged."""
        response = client.get("/api/v1/alerts/glof")
        assert response.status_code == 200
        data = response.json()
        lakes = data["all_lakes"]
        assert len(lakes) == 7
        ids = [l["lake_id"] for l in lakes]
        assert "south_lhonak_sikkim" in ids
        assert "shako_cho_sikkim" in ids
        assert "chorabari_uttarakhand" in ids
        assert "ghepan_gath_himachal" in ids
        assert "chamoli_ronti_uttarakhand" in ids
        assert "pareechu_himachal" in ids
        assert "dibang_cluster_arunachal" in ids

    def test_south_lhonak_critical_red_threat(self):
        """Test South Lhonak lake features CRITICAL_RED tier, Teesta basin, and Chungthang gate alert."""
        response = client.get(
            "/api/v1/alerts/glof",
            params={"lake_id": "south_lhonak_sikkim"},
        )
        assert response.status_code == 200
        data = response.json()
        selected = data["selected_lake"]
        assert selected["lake_id"] == "south_lhonak_sikkim"
        assert selected["state"] == "Sikkim"
        assert selected["river_basin"] == "Teesta River Basin"
        assert selected["elevation_m"] == 5200.0
        assert selected["threat_tier"] == "CRITICAL_RED_BREACH_IMMINENT"

        # Morphometry
        morph = selected["morphometry"]
        assert morph["surface_area_ha"] == 168.0
        assert morph["water_volume_million_m3"] > 50.0
        assert "Sentinel-1" in morph["satellite_sensor_provenance"]

        # Geotechnics
        geo = selected["moraine_geotechnics"]
        assert geo["crest_width_to_height_ratio"] < 2.0  # Acute instability
        assert geo["hydraulic_piping_index"] >= 1.0  # Critical piping

        # Hydrodynamics
        hydro = selected["breach_hydrodynamics"]
        assert hydro["peak_outflow_discharge_m3_s"] > 3500.0
        assert hydro["wave_propagation_speed_kmh"] >= 40.0

        # Downstream timeline
        nodes = selected["downstream_impact_timeline"]
        assert len(nodes) >= 4
        assert "Teesta-III Chungthang Dam" in nodes[0]["node_name"]
        assert "RADIAL GATES" in nodes[0]["infrastructure_alert"]
        assert nodes[0]["wave_arrival_eta_min"] <= 120

    def test_chorabari_kedarnath_corridor(self):
        """Test Chorabari lake has Mandakini basin, Kedarnath sanctuary complex node, and short ETA."""
        response = client.get(
            "/api/v1/alerts/glof",
            params={"lake_id": "chorabari_uttarakhand"},
        )
        assert response.status_code == 200
        data = response.json()
        selected = data["selected_lake"]
        assert selected["river_basin"] == "Mandakini River Basin"
        assert selected["state"] == "Uttarakhand"
        nodes = selected["downstream_impact_timeline"]
        assert "Kedarnath Temple Sanctuary Complex" in nodes[0]["node_name"]
        assert nodes[0]["wave_arrival_eta_min"] <= 10
        assert "DEFENSE WALL" in nodes[0]["infrastructure_alert"]

    def test_ghepan_gath_himachal_piping(self):
        """Test Ghepan Gath lake in Lahaul & Spiti features Chandra river and Atal Tunnel approach alert."""
        response = client.get(
            "/api/v1/alerts/glof",
            params={"lake_id": "ghepan_gath_himachal"},
        )
        assert response.status_code == 200
        data = response.json()
        selected = data["selected_lake"]
        assert selected["state"] == "Himachal Pradesh"
        assert "Chandra" in selected["river_basin"]
        assert selected["moraine_geotechnics"]["hydraulic_piping_index"] > 0.90
        nodes = selected["downstream_impact_timeline"]
        assert any("Atal Tunnel" in n["node_name"] for n in nodes)

    def test_moraine_breach_hydrodynamics_scaling(self):
        """Direct unit test of lake volume and Costa/Froehlich peak discharge calculations."""
        # 100 ha, 30m depth -> 30 million m3
        vol = GlofService.calculate_lake_volume(100.0, 30.0)
        assert vol == 30.0

        # Costa scaling: Qp = 0.72 * (30 * 10^6)^0.53 ~ 6,560 m3/s
        qp = GlofService.calculate_peak_breach_discharge(vol)
        assert 5000.0 < qp < 8000.0

    def test_wave_eta_calculation(self):
        """Direct test of downstream surge wave arrival time calculation."""
        # 60 km at 40 km/h -> 1.5 hours = 90 min
        eta = GlofService.calculate_wave_eta_min(60.0, 40.0)
        assert eta == 90

    def test_moraine_geotechnical_indicators(self):
        """Test moraine stability parameters for Dibang vs South Lhonak."""
        raw_lhonak = GlofService.GLACIAL_LAKES_DB["south_lhonak_sikkim"]
        raw_dibang = GlofService.GLACIAL_LAKES_DB["dibang_cluster_arunachal"]

        # Lhonak width/height ratio < 2.0 (narrow crest, high risk)
        assert raw_lhonak["crest_width_to_height"] < 2.0
        # Dibang width/height ratio > 2.0 (broad moraine, stable)
        assert raw_dibang["crest_width_to_height"] > 2.0

    def test_vernacular_bulletins_all_languages_present(self):
        """Test multi-lingual bulletins are synthesized in all 7 Himalayan & regional languages."""
        response = client.get("/api/v1/alerts/glof")
        assert response.status_code == 200
        data = response.json()
        bulletins = data["bulletins"]
        for lang in ["en", "hi", "ne", "bo", "pa", "bn", "as"]:
            assert lang in bulletins
            assert len(bulletins[lang]) > 30

    def test_geodetic_nearest_lake_lookup(self):
        """Test coordinate lookup near North Sikkim returns south_lhonak_sikkim."""
        response = client.get(
            "/api/v1/alerts/glof",
            params={"latitude": 27.92, "longitude": 88.21},
        )
        assert response.status_code == 200
        data = response.json()
        assert data["selected_lake"]["lake_id"] == "south_lhonak_sikkim"
