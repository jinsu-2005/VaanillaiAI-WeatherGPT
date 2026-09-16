import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.services.coldwave_service import ColdWaveService
from app.schemas.coldwave import ColdWaveSeverity, GroundFrostRisk, HypothermiaRisk, ColdWaveResponse

client = TestClient(app)


def test_cold_wave_assessment_service_default():
    """Verify default cold wave assessment output structure and domain integrity."""
    resp = ColdWaveService.get_cold_wave_assessment()
    assert isinstance(resp, ColdWaveResponse)
    assert resp.station_id == "CHURU_RJ"
    assert resp.cold_wave_severity in [ColdWaveSeverity.COLD_WAVE, ColdWaveSeverity.SEVERE_COLD_WAVE]
    assert resp.physics.t_grass_min < resp.physics.t_air_min
    assert resp.physics.net_radiation_loss_wm2 > 0
    assert len(resp.rabi_crop_advisories) >= 4
    assert "en" in resp.multilingual_bulletins
    assert "hi" in resp.multilingual_bulletins
    assert "pa" in resp.multilingual_bulletins
    assert "bn" in resp.multilingual_bulletins
    assert "ur" in resp.multilingual_bulletins
    assert len(resp.monitoring_stations) >= 6


def test_cold_wave_physics_and_classification():
    """Verify physical formulas for Stefan-Boltzmann cooling, wind chill, and IMD criteria."""
    # 1. Stefan-Boltzmann nocturnal cooling
    # Clear sky (0 oktas), calm wind (2 km/h): strong depression
    t_grass_clear, rad_clear = ColdWaveService.calculate_stefan_boltzmann_cooling(3.0, 0, 2.0)
    assert t_grass_clear < 0.0  # Ground frost forms
    assert rad_clear >= 60.0

    # Overcast sky (8 oktas), windy (20 km/h): radiation loss choked & wind mixed
    t_grass_overcast, rad_overcast = ColdWaveService.calculate_stefan_boltzmann_cooling(3.0, 8, 20.0)
    assert t_grass_overcast > t_grass_clear
    assert rad_overcast < rad_clear

    # 2. Wind Chill Index
    # T=2°C, V=15 km/h -> WCI should be well below 2°C
    wci = ColdWaveService.calculate_wind_chill(2.0, 15.0)
    assert wci < 0.0

    # 3. IMD Plains Criteria
    # Actual T_min <= 2.0°C -> SEVERE_COLD_WAVE
    sev_severe = ColdWaveService.classify_cold_wave(1.5, 9.0, is_hill_station=False)
    assert sev_severe == ColdWaveSeverity.SEVERE_COLD_WAVE

    # Actual T_min 3.5°C -> COLD_WAVE
    sev_cold = ColdWaveService.classify_cold_wave(3.5, 9.0, is_hill_station=False)
    assert sev_cold == ColdWaveSeverity.COLD_WAVE

    # Normal 12°C, actual 6.0°C -> departure -6.0°C -> COLD_WAVE
    sev_dep = ColdWaveService.classify_cold_wave(6.0, 12.0, is_hill_station=False)
    assert sev_dep == ColdWaveSeverity.COLD_WAVE

    # 4. Hills Criteria (elev >= 1000m)
    # T_min = -5.0°C, normal = -0.5°C -> departure -4.5°C -> COLD_WAVE
    sev_hill = ColdWaveService.classify_cold_wave(-5.0, -0.5, is_hill_station=True)
    assert sev_hill == ColdWaveSeverity.COLD_WAVE

    # 5. Ground Frost Risk
    assert ColdWaveService.classify_ground_frost(-4.5) == GroundFrostRisk.SEVERE
    assert ColdWaveService.classify_ground_frost(-2.5) == GroundFrostRisk.MODERATE
    assert ColdWaveService.classify_ground_frost(-0.8) == GroundFrostRisk.LIGHT
    assert ColdWaveService.classify_ground_frost(1.2) == GroundFrostRisk.NONE


def test_station_lookup_and_proximity():
    """Verify station lookup by station_id and coordinates."""
    # Lookup by station_id
    resp_srinagar = ColdWaveService.get_cold_wave_assessment(station_id="SRINAGAR_JK")
    assert resp_srinagar.station_id == "SRINAGAR_JK"
    assert resp_srinagar.is_hill_station is True
    assert resp_srinagar.physics.t_air_min < 0.0

    # Lookup by coordinates near Hisar (29.15, 75.72)
    resp_coords = ColdWaveService.get_cold_wave_assessment(latitude=29.2, longitude=75.8)
    assert resp_coords.station_id == "HISAR_HR"


def test_api_coldwave_endpoint():
    """Verify HTTP GET /api/v1/coldwave/assessment endpoint."""
    response = client.get("/api/v1/coldwave/assessment?station_id=CHURU_RJ")
    assert response.status_code == 200
    data = response.json()
    assert data["station_id"] == "CHURU_RJ"
    assert "cold_wave_severity" in data
    assert "ground_frost_risk" in data
    assert "physics" in data
    assert "rabi_crop_advisories" in data
    assert "urban_shelter" in data
    assert "multilingual_bulletins" in data
    assert "monitoring_stations" in data
