import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.schemas.urban_heat_island import (
    UhiSeverityLevel,
    CoolRoofMaterialType,
    UrbanHeatIslandResponse,
)
from app.services.urban_heat_island_service import UrbanHeatIslandService


@pytest.fixture
def client():
    return TestClient(app)


def test_get_urban_heat_island_default():
    """Default invocation should return Delhi-NCR with CRITICAL_EXTREME severity."""
    resp = UrbanHeatIslandService.get_corridor()
    assert isinstance(resp, UrbanHeatIslandResponse)
    assert resp.corridor_id == "delhi_ncr"
    assert resp.city_name == "Delhi-NCR"
    assert resp.current_corridor.threat_level == UhiSeverityLevel.CRITICAL_EXTREME
    assert resp.current_corridor.surface_telemetry.uhi_thermal_anomaly_delta_c == 6.8
    assert resp.current_corridor.surface_telemetry.lst_urban_celsius == 48.5
    assert resp.current_corridor.surface_telemetry.lst_rural_baseline_celsius == 41.7


def test_tropical_night_classification():
    """Delhi nocturnal min of 29.8°C must trigger both tropical and severe tropical night flags."""
    resp = UrbanHeatIslandService.get_corridor(corridor_id="delhi_ncr")
    telemetry = resp.current_corridor.surface_telemetry
    assert telemetry.tropical_night_min_temp_celsius == 29.8
    assert telemetry.tropical_night_flag is True
    assert telemetry.severe_tropical_night_flag is True


def test_bengaluru_moderate_night():
    """Bengaluru nocturnal min of 23.8°C should not trigger tropical night (<25°C)."""
    resp = UrbanHeatIslandService.get_corridor(corridor_id="bengaluru_bbmp")
    telemetry = resp.current_corridor.surface_telemetry
    assert telemetry.tropical_night_min_temp_celsius == 23.8
    assert telemetry.tropical_night_flag is False
    assert telemetry.severe_tropical_night_flag is False
    assert resp.current_corridor.threat_level == UhiSeverityLevel.HIGH_SEVERE


def test_cool_roof_simulation_elastomeric():
    """High-albedo elastomeric white coating must satisfy NDMA SRI >= 78 and yield cooling drops."""
    resp = UrbanHeatIslandService.get_corridor(
        corridor_id="ahmedabad_amc",
        roof_type="HIGH_ALBEDO_ELASTOMERIC_WHITE",
    )
    sim = resp.current_corridor.cool_roof_simulation
    assert sim.roof_material == CoolRoofMaterialType.HIGH_ALBEDO_ELASTOMERIC_WHITE
    assert sim.solar_reflectance_index_sri == 104
    assert sim.surface_temp_reduction_delta_c == 22.5
    assert sim.indoor_cooling_benefit_delta_c == -3.5
    assert sim.ac_energy_load_reduction_pct == 24.5
    assert sim.ndma_cool_roof_compliant is True


def test_cool_roof_simulation_uncoated_concrete():
    """Standard uncoated concrete must fail NDMA SRI threshold (SRI 20 < 78)."""
    resp = UrbanHeatIslandService.get_corridor(
        corridor_id="delhi_ncr",
        roof_type="STANDARD_CONCRETE_UNCOATED",
    )
    sim = resp.current_corridor.cool_roof_simulation
    assert sim.roof_material == CoolRoofMaterialType.STANDARD_CONCRETE_UNCOATED
    assert sim.solar_reflectance_index_sri == 20
    assert sim.surface_temp_reduction_delta_c == 0.0
    assert sim.ndma_cool_roof_compliant is False


def test_cool_roof_simulation_corrugated_tin():
    """Corrugated tin roofs must exhibit extreme surface temperatures (67.5°C) and non-compliance."""
    resp = UrbanHeatIslandService.get_corridor(
        corridor_id="mumbai_mmr",
        roof_type="CORRUGATED_GALVANIZED_TIN",
    )
    sim = resp.current_corridor.cool_roof_simulation
    assert sim.roof_material == CoolRoofMaterialType.CORRUGATED_GALVANIZED_TIN
    assert sim.surface_temperature_celsius == 67.5
    assert sim.solar_reflectance_index_sri == 12
    assert sim.ndma_cool_roof_compliant is False


def test_biophysical_canopy_metrics():
    """Verify impervious fraction, NDVI deficit, and anthropogenic heat flux calculations."""
    resp = UrbanHeatIslandService.get_corridor(corridor_id="mumbai_mmr")
    bio = resp.current_corridor.biophysical_metrics
    assert bio.impervious_surface_fraction_pct == 91.0
    assert bio.ndvi_urban_core < bio.ndvi_rural_baseline
    assert bio.vegetation_cooling_deficit_delta_c > 0
    assert bio.anthropogenic_heat_flux_w_m2 == 88.0
    assert 0.0 <= bio.sky_view_factor_svf <= 1.0


def test_nearest_corridor_geodetic_lookup():
    """Nearest neighbor geodetics should accurately route coordinates to correct metropolitan cluster."""
    # Near Mumbai (Navi Mumbai)
    resp_mum = UrbanHeatIslandService.get_corridor(latitude=19.03, longitude=73.02)
    assert resp_mum.corridor_id == "mumbai_mmr"

    # Near Hyderabad (Secunderabad)
    resp_hyd = UrbanHeatIslandService.get_corridor(latitude=17.44, longitude=78.50)
    assert resp_hyd.corridor_id == "hyderabad_ghmc"

    # Near Kolkata (Howrah)
    resp_kol = UrbanHeatIslandService.get_corridor(latitude=22.59, longitude=88.31)
    assert resp_kol.corridor_id == "kolkata_kmc"


def test_all_7_megacities_present():
    """All 7 Indian megacities must be present in all_corridors summary with hotspots and directives."""
    resp = UrbanHeatIslandService.get_corridor()
    assert len(resp.all_corridors) == 7
    city_ids = {c.corridor_id for c in resp.all_corridors}
    assert city_ids == {
        "delhi_ncr",
        "ahmedabad_amc",
        "mumbai_mmr",
        "bengaluru_bbmp",
        "hyderabad_ghmc",
        "chennai_gcc",
        "kolkata_kmc",
    }
    # Check hotspots in current corridor
    assert len(resp.current_corridor.hotspots) >= 3
    # Check municipal directives
    assert resp.current_corridor.directives.public_pyaus_drinking_water_points > 100


def test_fastapi_endpoint_integration(client):
    """FastAPI endpoint GET /api/v1/advisories/urban-heat-island must return 200 with complete payload."""
    response = client.get("/api/v1/advisories/urban-heat-island?corridor_id=chennai_gcc&roof_type=SLAKED_LIME_WASH")
    assert response.status_code == 200
    data = response.json()
    assert data["corridor_id"] == "chennai_gcc"
    assert data["current_corridor"]["city_name"] == "Chennai GCC"
    assert data["current_corridor"]["cool_roof_simulation"]["roof_material"] == "SLAKED_LIME_WASH"
    assert data["current_corridor"]["cool_roof_simulation"]["solar_reflectance_index_sri"] == 78
    assert data["current_corridor"]["cool_roof_simulation"]["ndma_cool_roof_compliant"] is True

    # Check multilingual vernacular bulletins
    bulletins = data["current_corridor"]["vernacular_bulletins"]
    for lang in ["en", "hi", "gu", "mr", "kn", "ta", "bn"]:
        assert lang in bulletins
        assert len(bulletins[lang]) > 20
