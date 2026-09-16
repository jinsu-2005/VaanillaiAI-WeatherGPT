"""Pytest suite for IMD, INCOIS & CGWB Coastal Estuarine Saltwater Intrusion,
Tidal Prism & Groundwater Salinization Engine (SALTWATER-TIDE).
"""

import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.services.saltwater_intrusion_service import SaltwaterIntrusionService

client = TestClient(app)


def test_default_saltwater_intrusion_assessment():
    """Verify default assessment returns Sundarbans Estuarine Delta in West Bengal."""
    response = client.get("/api/v1/coastal/saltwater-intrusion")
    assert response.status_code == 200
    data = response.json()

    assert "active_zone" in data
    assert "all_zones" in data
    assert "vernacular_bulletins" in data
    assert "INCOIS Ocean State Forecast" in data["dataSource"]

    active = data["active_zone"]
    assert active["zone_id"] == "sundarbans_delta"
    assert active["coastal_district"] == "South 24 Parganas"
    assert active["state_name"] == "West Bengal"
    assert active["estuarine_wedge"]["estuary_name"] == "Matla & Bidyadhari Estuary"
    assert active["estuarine_wedge"]["saline_wedge_length_km"] > 0


def test_explicit_zone_query():
    """Verify querying explicit zone_id returns expected coastal telemetry."""
    response = client.get("/api/v1/coastal/saltwater-intrusion?zone_id=cauvery_delta")
    assert response.status_code == 200
    data = response.json()

    active = data["active_zone"]
    assert active["zone_id"] == "cauvery_delta"
    assert active["coastal_district"] == "Nagapattinam"
    assert active["state_name"] == "Tamil Nadu"
    assert active["aquifer_metrics"]["freshwater_piezometric_head_m_msl"] == -0.40
    assert active["aquifer_metrics"]["aquifer_vulnerability_tier"] == "CRITICAL_AQUIFER_CONTAMINATION"


def test_nearest_coordinates_lookup():
    """Verify geodetic lookup locates Vembanad Lagoon & Kuttanad Polders."""
    response = client.get("/api/v1/coastal/saltwater-intrusion?lat=9.62&lon=76.38")
    assert response.status_code == 200
    data = response.json()

    active = data["active_zone"]
    assert active["zone_id"] == "vembanad_kuttanad"
    assert active["state_name"] == "Kerala"
    assert "Pokkali" in active["directives"]["recommended_salt_tolerant_crops"][0]


def test_ghyben_herzberg_lens_calculation():
    """Verify Ghyben-Herzberg lens calculation z = 40 * hf."""
    assessment = SaltwaterIntrusionService.get_assessment(zone_id="sundarbans_delta")
    aq = assessment.active_zone.aquifer_metrics

    hf = aq.freshwater_piezometric_head_m_msl
    expected_z = round(40.0 * hf, 2)
    assert aq.theoretical_freshwater_lens_depth_m == expected_z

    # Test sub-sea level head in Cauvery
    cauvery = SaltwaterIntrusionService.get_assessment(zone_id="cauvery_delta")
    assert cauvery.active_zone.aquifer_metrics.theoretical_freshwater_lens_depth_m == 0.0


def test_estuarine_saline_wedge_length():
    """Verify estuarine saline wedge penetration distance and Froude number validity."""
    assessment = SaltwaterIntrusionService.get_assessment(zone_id="khambhat_narmada")
    wedge = assessment.active_zone.estuarine_wedge

    assert wedge.saline_wedge_length_km > 0
    assert wedge.densimetric_froude_number > 0
    assert wedge.bottom_bed_salinity_ppt > wedge.surface_salinity_ppt
    assert wedge.astronomical_tidal_range_m == 7.80


def test_tds_electrical_conductivity_ratio():
    """Verify TDS is approx 0.64 * EC as per standard water mineralization chemistry."""
    for zid in SaltwaterIntrusionService.COASTAL_ZONES:
        assessment = SaltwaterIntrusionService.get_assessment(zone_id=zid)
        aq = assessment.active_zone.aquifer_metrics
        assert aq.total_dissolved_solids_mg_l == pytest.approx(0.64 * aq.electrical_conductivity_us_cm, rel=1e-2)


def test_salinity_severity_tier_categorization():
    """Verify salinity severity tier categorization based on EC thresholds."""
    khambhat = SaltwaterIntrusionService.get_assessment(zone_id="khambhat_narmada")
    assert khambhat.active_zone.salinity_severity == "HYPERSALINE_SEAWATER_INCURSION"

    goa = SaltwaterIntrusionService.get_assessment(zone_id="goa_zuari")
    assert goa.active_zone.salinity_severity == "SLIGHT_SALINE_STRESS"


def test_sluice_gate_directive_and_crops():
    """Verify agricultural directives, sluice gate operations, and crop lists."""
    assessment = SaltwaterIntrusionService.get_assessment(zone_id="sundarbans_delta")
    directives = assessment.active_zone.directives

    assert directives.sluice_flap_gate_status in ["OPEN", "CLOSED", "PARTIAL"]
    assert len(directives.recommended_salt_tolerant_crops) >= 2
    assert directives.gypsum_amendment_dosage_tons_ha > 0
    assert directives.borewell_pumping_limit_hours > 0


def test_vernacular_bulletins_seven_coastal_languages():
    """Verify 7 Indian coastal language emergency bulletins are generated."""
    response = client.get("/api/v1/coastal/saltwater-intrusion?zone_id=sundarbans_delta")
    assert response.status_code == 200
    bulletins = response.json()["vernacular_bulletins"]

    expected_langs = ["EN", "HI", "BN", "TA", "TE", "ML", "GU"]
    for lang in expected_langs:
        assert lang in bulletins
        assert len(bulletins[lang]) > 30


def test_invalid_coordinate_validation():
    """Verify out-of-range coordinates return 422 Unprocessable Entity."""
    response = client.get("/api/v1/coastal/saltwater-intrusion?lat=-100.0&lon=77.0")
    assert response.status_code == 422
