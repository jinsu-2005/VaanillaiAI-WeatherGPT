import pytest
from httpx import ASGITransport, AsyncClient

from app.main import app
from app.schemas.oil_spill import BonnAppearanceCode, OilTypeClassification, SpillSeverityTier
from app.services.oil_spill_service import OilSpillService


@pytest.fixture
def oil_spill_service():
    return OilSpillService()


@pytest.mark.asyncio
async def test_api_default_oil_spill_endpoint():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get("/api/v1/alerts/oil-spill")
    assert response.status_code == 200
    data = response.json()
    assert "selected_corridor" in data
    assert "all_corridors" in data
    assert "bulletins" in data
    assert data["selected_corridor"]["corridor_id"] == "gulf_of_kutch_vadinar"
    assert len(data["all_corridors"]) == 7


@pytest.mark.asyncio
async def test_api_specific_corridor_mumbai():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        response = await ac.get("/api/v1/alerts/oil-spill?corridor_id=mumbai_harbour_uran")
    assert response.status_code == 200
    data = response.json()
    corridor = data["selected_corridor"]
    assert corridor["corridor_id"] == "mumbai_harbour_uran"
    assert corridor["state_or_ut"] == "Maharashtra"
    assert corridor["oil_type"] == OilTypeClassification.HEAVY_BUNKER_FUEL_FO180.value
    assert corridor["severity_tier"] == SpillSeverityTier.TIER_2_REGIONAL_COAST_GUARD.value
    assert corridor["spill_volume_tonnes"] == 1200.0


def test_tier_3_national_spill_andaman(oil_spill_service):
    res = oil_spill_service.get_oil_spill_assessment(corridor_id="andaman_malacca_corridor")
    corridor = res.selected_corridor
    assert corridor.severity_tier == SpillSeverityTier.TIER_3_NATIONAL_NOSDCP
    assert corridor.spill_volume_tonnes == 12500.0
    assert corridor.icg_directives.recommended_boom_length_meters >= 5000.0
    assert "APPROVED" in corridor.icg_directives.chemical_dispersant_clearance


def test_sensitive_habitats_esi(oil_spill_service):
    res = oil_spill_service.get_oil_spill_assessment(corridor_id="gahirmatha_olive_ridley")
    corridor = res.selected_corridor
    assert len(corridor.sensitive_habitats) >= 2
    turtle_node = corridor.sensitive_habitats[0]
    assert "Olive Ridley" in turtle_node.habitat_name
    assert turtle_node.esi_rating == 10
    assert turtle_node.estimated_impact_eta_hours > 0
    assert "exclusion" in turtle_node.boom_defense_plan.lower() or "boom" in turtle_node.boom_defense_plan.lower()


def test_hydrodynamic_drift_vector(oil_spill_service):
    res = oil_spill_service.get_oil_spill_assessment(corridor_id="gulf_of_kutch_vadinar")
    drift = res.selected_corridor.drift_vector
    assert drift.surface_current_speed_knots > 0
    assert drift.wind_speed_10m_knots > 0
    assert drift.net_drift_speed_knots > 0
    assert 0.0 <= drift.net_drift_direction_deg <= 360.0
    assert drift.stokes_drift_knots >= 0.1


def test_fay_spreading_regimes(oil_spill_service):
    res = oil_spill_service.get_oil_spill_assessment(corridor_id="gulf_of_kutch_vadinar")
    spreading = res.selected_corridor.fay_spreading
    assert "REGIME" in spreading.current_regime
    assert spreading.slick_radius_meters > 1000.0
    assert spreading.slick_area_km2 > 5.0
    assert spreading.average_thickness_microns > 0
    assert spreading.bonn_code in [
        BonnAppearanceCode.CODE_3_METALLIC,
        BonnAppearanceCode.CODE_4_DISCONTINUOUS_TRUE,
        BonnAppearanceCode.CODE_5_CONTINUOUS_TRUE,
    ]


def test_chemical_weathering_emulsification(oil_spill_service):
    res = oil_spill_service.get_oil_spill_assessment(corridor_id="mumbai_harbour_uran")
    weathering = res.selected_corridor.weathering
    assert weathering.evaporated_fraction_pct > 5.0
    assert weathering.emulsified_water_fraction_pct > 30.0
    assert weathering.emulsion_viscosity_cst > 10000.0
    assert weathering.viscosity_increase_factor >= 10.0
    assert weathering.flash_point_celsius > 50.0


def test_icg_containment_directives(oil_spill_service):
    res = oil_spill_service.get_oil_spill_assessment(corridor_id="sundarbans_hooghly")
    icg = res.selected_corridor.icg_directives
    assert icg.maximum_towing_speed_knots == 0.75
    assert icg.recommended_boom_length_meters >= 1000.0
    assert icg.coast_guard_emergency_no == "1554"
    assert "PROHIBITED" in icg.chemical_dispersant_clearance


def test_vernacular_bulletins_seven_languages(oil_spill_service):
    res = oil_spill_service.get_oil_spill_assessment(corridor_id="gulf_of_mannar_pamban")
    bulletins = res.bulletins
    for lang in ["en", "ta", "bn", "ml", "gu", "mr", "od"]:
        assert lang in bulletins
        assert len(bulletins[lang]) > 20
        assert "1554" in bulletins[lang]


def test_geodetic_nearest_corridor_resolution(oil_spill_service):
    # Latitude ~9.95, Longitude ~76.25 is right next to Cochin (vembanad_cochin)
    res = oil_spill_service.get_oil_spill_assessment(latitude=9.95, longitude=76.25)
    assert res.selected_corridor.corridor_id == "vembanad_cochin"

    # Latitude ~20.70, Longitude ~87.00 is right next to Gahirmatha (gahirmatha_olive_ridley)
    res_od = oil_spill_service.get_oil_spill_assessment(latitude=20.70, longitude=87.00)
    assert res_od.selected_corridor.corridor_id == "gahirmatha_olive_ridley"
