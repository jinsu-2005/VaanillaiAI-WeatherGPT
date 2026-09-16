import pytest
from fastapi.testclient import TestClient

from app.main import app
from app.schemas.potential_fishing_zone import (
    PfzProductivityTier,
    PelagicSpeciesGroup,
    FishingCraftType,
    PfzResponse,
)
from app.services.potential_fishing_zone_service import PotentialFishingZoneService


@pytest.fixture
def client():
    return TestClient(app)


def test_get_potential_fishing_zone_default():
    """Default invocation should return Kochi / Malabar sector with OPTIMAL_HIGH_YIELD productivity."""
    resp = PotentialFishingZoneService.get_sector()
    assert isinstance(resp, PfzResponse)
    assert resp.sector_id == "kochi_malabar"
    assert "Kochi" in resp.sector_name
    assert resp.current_sector.ocean_color.productivity_tier == PfzProductivityTier.OPTIMAL_HIGH_YIELD
    assert resp.current_sector.ocean_color.chlorophyll_a_mg_m3 == 1.85
    assert resp.current_sector.primary_species == PelagicSpeciesGroup.SMALL_PELAGICS_SARDINE_MACKEREL


def test_navigational_vector_bearing():
    """Navigational vector must have valid true bearing, compass direction, and bathymetry."""
    resp = PotentialFishingZoneService.get_sector(sector_id="kochi_malabar")
    nav = resp.current_sector.navigational_vector
    assert 0 <= nav.true_bearing_degrees <= 360
    assert nav.compass_direction == "SW"
    assert nav.distance_nautical_miles == 25.0
    assert nav.distance_kilometers > 40.0
    assert nav.target_depth_fathoms == 28
    assert nav.target_depth_meters > 50.0


def test_ocean_color_telemetry():
    """Verify chlorophyll-a concentration, diffuse attenuation k490, and bloom presence."""
    resp = PotentialFishingZoneService.get_sector(sector_id="veraval_saurashtra")
    oc = resp.current_sector.ocean_color
    assert oc.chlorophyll_a_mg_m3 == 2.10
    assert oc.phytoplankton_bloom_active is True
    assert oc.harmful_algal_bloom_risk is False
    assert oc.diffuse_attenuation_k490 > 0


def test_thermal_front_telemetry():
    """Verify sea surface temperature, horizontal thermal gradient, and cyclonic eddy structure."""
    resp = PotentialFishingZoneService.get_sector(sector_id="tuticorin_mannar")
    tf = resp.current_sector.thermal_front
    assert 25.0 <= tf.sea_surface_temp_celsius <= 32.0
    assert tf.sst_gradient_deg_c_per_km >= 0.50
    assert "TUNA" in tf.thermal_front_type
    assert tf.sea_surface_height_anomaly_cm < 0


def test_fuel_savings_frp_motorized():
    """Traditional FRP motorized boats must register realistic diesel savings and CO2 offsets."""
    resp = PotentialFishingZoneService.get_sector(
        sector_id="kochi_malabar",
        craft_type="TRADITIONAL_MOTORIZED_FRP",
    )
    fs = resp.current_sector.fuel_savings
    assert fs.craft_type == FishingCraftType.TRADITIONAL_MOTORIZED_FRP
    assert fs.scouting_time_reduction_pct == 45.0
    assert fs.diesel_saved_liters >= 30.0
    assert fs.rupee_fuel_cost_savings_inr >= 2500.0
    assert fs.carbon_emission_reduction_kg_co2 >= 80.0


def test_fuel_savings_mechanized_trawler():
    """Mechanized trawlers must demonstrate multi-hundred liter fuel conservation."""
    resp = PotentialFishingZoneService.get_sector(
        sector_id="veraval_saurashtra",
        craft_type="MECHANIZED_TRAWLER_INBOARD",
    )
    fs = resp.current_sector.fuel_savings
    assert fs.craft_type == FishingCraftType.MECHANIZED_TRAWLER_INBOARD
    assert fs.scouting_time_reduction_pct == 50.0
    assert fs.diesel_saved_liters >= 300.0
    assert fs.rupee_fuel_cost_savings_inr >= 25000.0
    assert fs.carbon_emission_reduction_kg_co2 >= 800.0


def test_ecological_conservation_and_mpa():
    """Verify MPA proximity tracking, turtle buffer restrictions, and CMFRI MLS guidelines."""
    resp = PotentialFishingZoneService.get_sector(sector_id="paradeep_gahirmatha")
    con = resp.current_sector.conservation
    assert "Gahirmatha" in con.nearest_mpa_name
    assert con.distance_to_mpa_boundary_km == 12.0
    assert con.mpa_buffer_violation_risk == "PROXIMITY_ALERT"
    assert "MLS" in con.minimum_legal_size_advisory
    assert "TED" in con.artisanal_exclusive_zone_status


def test_nearest_sector_geodetic_lookup():
    """Nearest neighbor lookup should correctly resolve fishing harbor coordinates."""
    # Near Veraval (Dwarka/Porbandar area)
    resp_v = PotentialFishingZoneService.get_sector(latitude=21.1, longitude=70.1)
    assert resp_v.sector_id == "veraval_saurashtra"

    # Near Visakhapatnam
    resp_viz = PotentialFishingZoneService.get_sector(latitude=17.7, longitude=83.3)
    assert resp_viz.sector_id == "visakhapatnam_kakinada"

    # Near Paradeep
    resp_par = PotentialFishingZoneService.get_sector(latitude=20.25, longitude=86.7)
    assert resp_par.sector_id == "paradeep_gahirmatha"


def test_all_7_coastal_sectors_present():
    """All 7 critical coastal fishing sectors must be present in all_sectors summary."""
    resp = PotentialFishingZoneService.get_sector()
    assert len(resp.all_sectors) == 7
    sector_ids = {s.sector_id for s in resp.all_sectors}
    assert sector_ids == {
        "kochi_malabar",
        "veraval_saurashtra",
        "sassoon_dock_konkan",
        "mangalore_malpe",
        "tuticorin_mannar",
        "visakhapatnam_kakinada",
        "paradeep_gahirmatha",
    }


def test_fastapi_endpoint_integration(client):
    """FastAPI endpoint GET /api/v1/advisories/potential-fishing-zone must return 200 with complete payload."""
    response = client.get(
        "/api/v1/advisories/potential-fishing-zone?sector_id=tuticorin_mannar&craft_type=DEEP_SEA_TUNA_LONGLINER"
    )
    assert response.status_code == 200
    data = response.json()
    assert data["sector_id"] == "tuticorin_mannar"
    assert data["current_sector"]["primary_species"] == "LARGE_PELAGICS_TUNA_SEERFISH"
    assert data["current_sector"]["fuel_savings"]["craft_type"] == "DEEP_SEA_TUNA_LONGLINER"
    assert data["current_sector"]["fuel_savings"]["diesel_saved_liters"] >= 400.0

    # Check 8-language coastal vernacular bulletins
    bulletins = data["current_sector"]["vernacular_bulletins"]
    for lang in ["en", "ml", "ta", "te", "gu", "mr", "bn", "od"]:
        assert lang in bulletins
        assert len(bulletins[lang]) > 20
