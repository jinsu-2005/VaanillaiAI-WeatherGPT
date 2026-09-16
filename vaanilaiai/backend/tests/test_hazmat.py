import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app
from app.services.hazmat_service import HazmatService
from app.schemas.hazmat import (
    PasquillStabilityClass,
    ToxicGasSpecies,
    HazmatReleaseSeverity,
)


def test_hazmat_service_default():
    assessment = HazmatService.get_assessment()
    assert assessment is not None
    assert assessment.selected_cluster.cluster_id == "dahej_pcpir_gujarat"
    assert assessment.selected_cluster.state == "Gujarat"
    assert assessment.selected_cluster.active_gas_profile.species == ToxicGasSpecies.CHLORINE_CL2
    assert assessment.selected_cluster.active_gas_profile.chemical_formula == "Cl2"
    assert assessment.selected_cluster.atmospheric_telemetry.pasquill_stability_class == PasquillStabilityClass.CLASS_E_SLIGHTLY_STABLE
    assert assessment.selected_cluster.dispersion_metrics.severity_tier == HazmatReleaseSeverity.SIGNIFICANT_TANK_LEAK
    assert assessment.selected_cluster.dispersion_metrics.centerline_peak_concentration_ppm >= 40.0
    assert assessment.selected_cluster.emergency_protocol.water_spray_curtain_recommended is True
    assert len(assessment.all_clusters) == 7
    assert "en" in assessment.vernacular_bulletins
    assert "gu" in assessment.vernacular_bulletins
    assert "દહેજ" in assessment.vernacular_bulletins["gu"]


def test_hazmat_service_by_id_and_gas_species():
    assessment = HazmatService.get_assessment(cluster_id="manali_industrial_corridor_chennai")
    assert assessment.selected_cluster.cluster_id == "manali_industrial_corridor_chennai"
    assert assessment.selected_cluster.state == "Tamil Nadu"
    assert assessment.selected_cluster.active_gas_profile.species == ToxicGasSpecies.AMMONIA_NH3
    assert assessment.selected_cluster.active_gas_profile.vapor_density_air_ratio < 1.0  # NH3 is lighter than air
    assert "ta" in assessment.vernacular_bulletins
    assert "மணலி" in assessment.vernacular_bulletins["ta"]

    # Test filtering by gas species
    h2s_assessment = HazmatService.get_assessment(gas_species="HYDROGEN_SULFIDE_H2S")
    assert h2s_assessment.selected_cluster.cluster_id == "visakhapatnam_pharma_city"
    assert h2s_assessment.selected_cluster.active_gas_profile.chemical_formula == "H2S"


def test_hazmat_geodetic_nearest_cluster():
    # Coordinates near Mumbai / Navi Mumbai (19.03°N, 73.02°E)
    assessment = HazmatService.get_assessment(latitude=19.03, longitude=73.02)
    assert assessment.selected_cluster.cluster_id == "rasayani_taloja_midc"
    assert assessment.selected_cluster.state == "Maharashtra"
    assert assessment.selected_cluster.active_gas_profile.species == ToxicGasSpecies.PHOSGENE_COCL2
    assert assessment.selected_cluster.dispersion_metrics.initial_isolation_zone_m >= 500.0


@pytest.mark.asyncio
async def test_api_hazmat_endpoint():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.get("/api/v1/alerts/hazmat-dispersion?cluster_id=vapi_chemical_estate")
        assert response.status_code == 200
        data = response.json()
        assert data["selected_cluster"]["cluster_id"] == "vapi_chemical_estate"
        assert data["selected_cluster"]["active_gas_profile"]["chemical_formula"] == "SO2"
        assert data["selected_cluster"]["dispersion_metrics"]["centerline_peak_concentration_ppm"] == 42.0
        assert "provenance" in data
        assert "CPCB" in data["provenance"]
