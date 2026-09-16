"""Pytest suite for IMD & CWC National Flood Forecasting,
Hydrological Rating Curve & Embankment Breach Telemetry Engine (HYDRO-RATING).
"""

import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.services.hydro_rating_service import HydroRatingService

client = TestClient(app)


def test_default_hydro_rating_assessment():
    """Verify default assessment returns Baltara gauge station on Kosi river."""
    response = client.get("/api/v1/hydro/rating-curve")
    assert response.status_code == 200
    data = response.json()

    assert "active_station" in data
    assert "all_stations" in data
    assert "vernacular_bulletins" in data
    assert "Central Water Commission" in data["dataSource"]

    active = data["active_station"]
    assert active["station_id"] == "kosi_baltara"
    assert active["river_name"] == "Kosi River"
    assert active["state_name"] == "Bihar"
    assert active["benchmarks"]["warning_level_m"] == 33.85
    assert active["benchmarks"]["danger_level_m"] == 34.75
    assert active["benchmarks"]["highest_flood_level_hfl_m"] == 36.40


def test_explicit_basin_query():
    """Verify querying explicit basin_id returns expected basin metrics."""
    response = client.get("/api/v1/hydro/rating-curve?basin_id=brahmaputra_pandu")
    assert response.status_code == 200
    data = response.json()

    active = data["active_station"]
    assert active["station_id"] == "brahmaputra_pandu"
    assert active["river_name"] == "Brahmaputra River"
    assert active["state_name"] == "Assam"
    assert active["embankment_safety"]["sand_boil_detected"] is True
    assert active["benchmarks"]["hfl_record_year"] == 2004


def test_nearest_coordinates_lookup():
    """Verify geodetic lookup locates Delhi Yamuna Old Railway Bridge."""
    response = client.get("/api/v1/hydro/rating-curve?lat=28.65&lon=77.23")
    assert response.status_code == 200
    data = response.json()

    active = data["active_station"]
    assert active["station_id"] == "yamuna_delhi"
    assert active["river_name"] == "Yamuna River"
    assert active["state_name"] == "Delhi NCR"


def test_rating_curve_discharge_positive():
    """Verify rating curve discharge Q = a(h - h0)^b is positive and mathematically sound."""
    assessment = HydroRatingService.get_assessment(basin_id="kosi_baltara")
    station = assessment.active_station
    rc = station.rating_curve

    assert rc.computed_discharge_cumecs > 0
    assert rc.stage_height_m > rc.zero_flow_datum_h0_m
    assert rc.effective_head_m == pytest.approx(rc.stage_height_m - rc.zero_flow_datum_h0_m, rel=1e-2)
    assert rc.mean_flow_velocity_mps > 0
    assert rc.manning_roughness_n > 0


def test_embankment_freeboard_calculation():
    """Verify embankment freeboard margin crest - stage and tier consistency."""
    assessment = HydroRatingService.get_assessment(basin_id="godavari_dowleswaram")
    station = assessment.active_station
    emb = station.embankment_safety
    bench = station.benchmarks

    expected_freeboard = round(bench.embankment_crest_m - rc_stage(station), 2)
    assert emb.freeboard_margin_m == expected_freeboard
    assert emb.freeboard_tier in [
        "OPTIMAL_FREEBOARD",
        "REDUCED_MARGIN",
        "OVERTOPPING_THREAT",
        "CREST_OVERTOPPING_BREACH",
    ]


def rc_stage(station):
    return station.rating_curve.stage_height_m


def test_piping_factor_of_safety_and_gradient():
    """Verify piping exit gradient i = Delta_h / L and Factor of Safety FS = icrit / i."""
    assessment = HydroRatingService.get_assessment(basin_id="ganga_farakka")
    station = assessment.active_station
    emb = station.embankment_safety

    assert emb.seepage_path_length_m > 0
    assert emb.exit_hydraulic_gradient > 0
    assert emb.piping_factor_of_safety > 0
    assert emb.piping_risk_tier in [
        "SAFE_STABLE",
        "PIPING_WATCH",
        "HIGH_SANDBOIL_RISK",
        "IMMINENT_COLLAPSE_BREACH",
    ]


def test_cwc_benchmark_levels_hierarchy():
    """Verify logical elevation hierarchy of CWC benchmarks."""
    for sid in HydroRatingService.STATIONS_CATALOG:
        assessment = HydroRatingService.get_assessment(basin_id=sid)
        b = assessment.active_station.benchmarks
        assert b.zero_flow_datum_m < b.warning_level_m
        assert b.warning_level_m < b.danger_level_m
        assert b.danger_level_m < b.highest_flood_level_hfl_m
        assert b.highest_flood_level_hfl_m < b.embankment_crest_m


def test_gumbel_frequency_monotonicity():
    """Verify Gumbel EV1 flood discharges increase with recurrence intervals."""
    assessment = HydroRatingService.get_assessment(basin_id="narmada_golden_bridge")
    g = assessment.active_station.gumbel_frequency
    assert g.discharge_10yr_cumecs < g.discharge_25yr_cumecs
    assert g.discharge_25yr_cumecs < g.discharge_50yr_cumecs
    assert g.discharge_50yr_cumecs < g.discharge_100yr_cumecs
    assert 0.0 < g.annual_exceedance_probability_pct <= 100.0


def test_vernacular_bulletins_seven_languages():
    """Verify 7 Indian language riparian bulletins are generated."""
    response = client.get("/api/v1/hydro/rating-curve?basin_id=mahanadi_mundali")
    assert response.status_code == 200
    bulletins = response.json()["vernacular_bulletins"]

    expected_langs = ["EN", "HI", "AS", "BN", "OD", "TE", "GU"]
    for lang in expected_langs:
        assert lang in bulletins
        assert len(bulletins[lang]) > 30


def test_invalid_coordinate_validation():
    """Verify out-of-range latitude/longitude returns 422."""
    response = client.get("/api/v1/hydro/rating-curve?lat=120.0&lon=77.0")
    assert response.status_code == 422
