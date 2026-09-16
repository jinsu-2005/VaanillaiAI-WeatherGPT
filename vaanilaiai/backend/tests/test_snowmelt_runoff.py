"""Pytest test suite for IMD, CWC & DGRE Himalayan Snowmelt Runoff,
Snow Cover Area (SCA) & Glacial Hydrology Engine (SNOWMELT-HYDRO).
"""

import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.schemas.snowmelt_runoff import (
    HydropowerInflowStatus,
    SnowmeltRegime,
    SnowmeltRunoffResponse,
)
from app.services.snowmelt_runoff_service import SnowmeltRunoffService


@pytest.fixture
def client():
    """FastAPI TestClient fixture."""
    return TestClient(app)


def test_get_default_snowmelt_assessment():
    """Verify default assessment loads Satluj Basin & Bhakra Reservoir."""
    resp = SnowmeltRunoffService.get_assessment()
    assert isinstance(resp, SnowmeltRunoffResponse)
    assert resp.basin_id == "satluj_bhakra"
    assert resp.basin_name == "Satluj Basin & Bhakra Reservoir Catchment"
    assert resp.state == "Himachal Pradesh"
    assert resp.current_basin.current_regime == SnowmeltRegime.SEASONAL_SNOWMELT_SURGE
    assert len(resp.current_basin.elevation_bands) == 4
    assert resp.current_basin.elevation_bands[0].band_id == "ZONE_A"
    assert resp.current_basin.elevation_bands[3].band_id == "ZONE_D"
    assert resp.current_basin.cryosphere_telemetry.freezing_level_isotherm_m == 4620.0
    assert resp.current_basin.runoff_metrics.daily_discharge_cumecs == 1420.0
    assert resp.current_basin.runoff_metrics.snowmelt_fraction_pct == 64.5
    assert len(resp.current_basin.hydropower_inflows) == 2
    assert resp.current_basin.hydropower_inflows[0].dam_name == "Bhakra Dam (Gobind Sagar)"
    assert len(resp.all_basins) == 7


def test_get_bhagirathi_tehri_assessment():
    """Verify Tehri Dam & Gangotri glacial ablation dynamics."""
    resp = SnowmeltRunoffService.get_assessment(basin_id="bhagirathi_tehri")
    assert resp.basin_id == "bhagirathi_tehri"
    assert resp.current_basin.current_regime == SnowmeltRegime.GLACIAL_ABLATION_PEAK
    assert resp.current_basin.runoff_metrics.daily_discharge_cumecs == 890.0
    assert resp.current_basin.cryosphere_telemetry.equilibrium_line_altitude_m == 5100.0
    assert resp.current_basin.hydropower_inflows[0].dam_name == "Tehri Dam Hydro Complex"
    assert resp.current_basin.hydropower_inflows[0].installed_capacity_mw == 2400.0
    assert "Gangotri" in resp.current_basin.riparian_safety_advisory


def test_get_chenab_baglihar_assessment():
    """Verify Chenab basin Zanskar snowmelt with Baglihar & Salal dams."""
    resp = SnowmeltRunoffService.get_assessment(basin_id="chenab_baglihar")
    assert resp.basin_id == "chenab_baglihar"
    assert resp.state == "Jammu & Kashmir"
    assert resp.current_basin.runoff_metrics.daily_discharge_cumecs == 1180.0
    assert resp.current_basin.runoff_metrics.snowmelt_fraction_pct == 68.0
    assert len(resp.current_basin.hydropower_inflows) == 2
    assert resp.current_basin.hydropower_inflows[0].dam_name == "Baglihar Hydroelectric Project"
    assert resp.current_basin.hydropower_inflows[1].dam_name == "Salal Dam"


def test_get_beas_pong_assessment():
    """Verify Beas basin Rohtang/Dhauladhar snowmelt into Pong reservoir."""
    resp = SnowmeltRunoffService.get_assessment(basin_id="beas_pong")
    assert resp.basin_id == "beas_pong"
    assert resp.current_basin.runoff_metrics.daily_discharge_cumecs == 740.0
    assert resp.current_basin.hydropower_inflows[0].dam_name == "Pong Dam (Maharana Pratap Sagar)"
    assert resp.current_basin.hydropower_inflows[0].daily_storage_gain_mcm == 42.0


def test_get_jhelum_uri_assessment():
    """Verify Jhelum & Kishanganga HEP run-of-the-river snowmelt."""
    resp = SnowmeltRunoffService.get_assessment(basin_id="jhelum_uri")
    assert resp.basin_id == "jhelum_uri"
    assert resp.current_basin.runoff_metrics.daily_discharge_cumecs == 580.0
    assert resp.current_basin.hydropower_inflows[0].dam_name == "Uri-I Hydroelectric Power Plant"
    assert resp.current_basin.hydropower_inflows[1].dam_name == "Kishanganga HEP"


def test_get_teesta_v_assessment():
    """Verify Teesta basin rain-on-snow event and spillway discharge warning."""
    resp = SnowmeltRunoffService.get_assessment(basin_id="teesta_v")
    assert resp.basin_id == "teesta_v"
    assert resp.current_basin.current_regime == SnowmeltRegime.RAIN_ON_SNOW_BURST
    assert resp.current_basin.runoff_metrics.daily_discharge_cumecs == 960.0
    assert resp.current_basin.hydropower_inflows[0].inflow_status == HydropowerInflowStatus.SPILLWAY_DISCHARGE_WARNING
    assert "Singtam" in resp.current_basin.riparian_safety_advisory


def test_get_subansiri_assessment():
    """Verify Subansiri Lower HEP and Tibetan plateau snowmelt surge."""
    resp = SnowmeltRunoffService.get_assessment(basin_id="subansiri_lower")
    assert resp.basin_id == "subansiri_lower"
    assert resp.current_basin.runoff_metrics.daily_discharge_cumecs == 2150.0
    assert resp.current_basin.hydropower_inflows[0].installed_capacity_mw == 2000.0
    assert "Dhemaji" in resp.current_basin.riparian_safety_advisory


def test_invalid_basin_id_fallback():
    """Verify unknown basin slug gracefully falls back to Satluj."""
    resp = SnowmeltRunoffService.get_assessment(basin_id="unknown_himalayan_basin_xyz")
    assert resp.basin_id == "satluj_bhakra"
    assert resp.state == "Himachal Pradesh"


def test_multilingual_bulletins():
    """Verify bulletins exist for all 7 Himalayan languages."""
    resp = SnowmeltRunoffService.get_assessment(basin_id="satluj_bhakra")
    bulletins = resp.current_basin.vernacular_bulletins
    for lang in ["en", "hi", "pa", "ne", "ks", "bn", "bo"]:
        assert lang in bulletins
        assert len(bulletins[lang]) > 20
    assert "भाखड़ा" in bulletins["hi"]
    assert "ਭਾਖੜਾ" in bulletins["pa"]


def test_api_endpoint_via_testclient(client):
    """Test FastAPI GET /api/v1/hydro/snowmelt-runoff endpoint."""
    response = client.get("/api/v1/hydro/snowmelt-runoff?basin_id=bhagirathi_tehri")
    assert response.status_code == 200
    data = response.json()
    assert data["basin_id"] == "bhagirathi_tehri"
    assert data["basin_name"] == "Bhagirathi & Alaknanda Basin (Tehri Dam Catchment)"
    assert len(data["current_basin"]["elevation_bands"]) == 4
    assert data["current_basin"]["cryosphere_telemetry"]["snow_line_altitude_m"] == 3950.0
    assert data["current_basin"]["hydropower_inflows"][0]["dam_name"] == "Tehri Dam Hydro Complex"
    assert len(data["all_basins"]) == 7
