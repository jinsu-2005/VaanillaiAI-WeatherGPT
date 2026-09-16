"""Tests for IITM & IMD Lightning Flash Density, Total Lightning (IC vs CG),
Thunderstorm Cell Lifecycle & Severe Downburst Nowcasting Engine.
"""
import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.services.lightning_cell_service import lightning_cell_service

client = TestClient(app)


class TestLightningCellAPI:
    """Test lightning cell and downburst nowcasting API."""

    def test_default_assessment(self):
        """Test default corridor lookup returns valid response with all required fields."""
        response = client.get("/api/v1/alerts/lightning-density")
        assert response.status_code == 200
        data = response.json()
        assert "corridor" in data
        assert "threat_tier" in data
        assert "cell_stage" in data
        assert "total_lightning" in data
        assert "lightning_jump" in data
        assert "downburst_risk" in data
        assert "radar_echo" in data
        assert "climatology" in data
        assert "ndma_guidelines" in data
        assert "vernacular_bulletins" in data
        assert data["is_offline_fallback"] is False

    def test_mayurbhanj_corridor_telemetry(self):
        """Test Mayurbhanj corridor features extreme threat, jump detection, and hail core."""
        response = client.get("/api/v1/alerts/lightning-density", params={"corridor_id": "mayurbhanj_odisha"})
        assert response.status_code == 200
        data = response.json()
        assert data["corridor"]["id"] == "mayurbhanj_odisha"
        assert data["threat_tier"] == "EXTREME"
        assert data["cell_stage"] == "MATURE_SUPERCELL"
        # Total Lightning
        tl = data["total_lightning"]
        assert tl["total_flash_rate_per_min"] >= 60.0
        assert tl["is_positive_cg_hazard"] is True
        assert tl["peak_stroke_current_ka"] >= 100.0
        # Lightning Jump
        lj = data["lightning_jump"]
        assert lj["jump_detected"] is True
        assert lj["jump_severity"] == "CRITICAL"
        assert lj["lead_time_minutes"] == 25
        # Downburst
        db = data["downburst_risk"]
        assert db["estimated_gust_speed_kmh"] > 90.0
        assert db["microburst_category"] == "SEVERE_WET_MICROBURST"
        # Dual-Pol Radar
        re = data["radar_echo"]
        assert re["hydrometeor_classification"] == "GRAUPEL_HAIL_CORE"
        assert re["hail_core_aloft_detected"] is True

    def test_brahmaputra_corridor_lookup(self):
        """Test Brahmaputra valley corridor returns severe tier and strong jump."""
        response = client.get("/api/v1/alerts/lightning-density", params={"corridor_id": "brahmaputra_assam"})
        assert response.status_code == 200
        data = response.json()
        assert data["corridor"]["id"] == "brahmaputra_assam"
        assert data["threat_tier"] == "SEVERE"
        assert data["lightning_jump"]["jump_detected"] is True
        assert data["lightning_jump"]["jump_severity"] == "STRONG"

    def test_malnad_dissipating_cell(self):
        """Test Malnad corridor displays dissipating cold pool and positive anvil bolts."""
        response = client.get("/api/v1/alerts/lightning-density", params={"corridor_id": "malnad_karnataka"})
        assert response.status_code == 200
        data = response.json()
        assert data["cell_stage"] == "DISSIPATING_COLD_POOL"
        assert data["lightning_jump"]["jump_detected"] is False
        assert data["total_lightning"]["positive_cg_percentage"] >= 20.0
        assert data["total_lightning"]["is_positive_cg_hazard"] is True

    def test_haversine_coordinate_routing(self):
        """Test geographic coordinate near Kolkata routes to Gangetic Bengal corridor."""
        response = client.get(
            "/api/v1/alerts/lightning-density",
            params={"latitude": 22.55, "longitude": 88.35}
        )
        assert response.status_code == 200
        data = response.json()
        assert data["corridor"]["id"] == "gangetic_bengal"
        assert "West Bengal" in data["corridor"]["state"]

    def test_downburst_velocity_math(self):
        """Test Downburst velocity formula V_burst = 2.4 * sqrt(DCAPE)."""
        # For DCAPE = 1280.0 J/kg: sqrt(1280) = 35.777, 2.4 * 35.777 = 85.86 m/s -> 309.1 km/h
        v = lightning_cell_service._calculate_downburst_velocity(100.0)
        # sqrt(100) = 10, 2.4 * 10 = 24 m/s * 3.6 = 86.4 km/h
        assert v == 86.4

    def test_lightning_jump_thresholds(self):
        """Test Gatlin-Goodman thresholds for delta flash rate."""
        detected, sev, lead, prob = lightning_cell_service._evaluate_lightning_jump(16.0)
        assert detected is True
        assert sev == "CRITICAL"
        assert lead == 25
        assert prob >= 90.0

        detected, sev, lead, prob = lightning_cell_service._evaluate_lightning_jump(2.0)
        assert detected is False
        assert sev == "NONE"

    def test_ndma_safety_rules(self):
        """Test NDMA agricultural guidelines contain crucial survival guidance."""
        guidelines = lightning_cell_service._generate_ndma_guidelines()
        assert "71%" in guidelines.anti_tree_warning
        assert "crouch" in guidelines.lightning_crouch_posture.lower()
        assert "sickle" in guidelines.metal_implement_prohibition.lower()
        assert "NO RESIDUAL ELECTRIC CHARGE" in guidelines.cpr_resuscitation_guideline

    def test_multilingual_bulletins(self):
        """Test generation of bulletins in 7 Indian regional languages."""
        response = client.get("/api/v1/alerts/lightning-density", params={"corridor_id": "mayurbhanj_odisha"})
        data = response.json()
        b = data["vernacular_bulletins"]
        for lang in ["en", "hi", "od", "bn", "te", "mr", "as"]:
            assert lang in b
            assert len(b[lang]) > 20

    def test_offline_fallback(self):
        """Test resilient offline fallback model."""
        fb = lightning_cell_service.get_offline_fallback(location_name="Rourkela")
        assert fb.is_offline_fallback is True
        assert "Rourkela" in fb.corridor.name
        assert fb.threat_tier is not None
        assert fb.total_lightning.total_flash_rate_per_min > 0
