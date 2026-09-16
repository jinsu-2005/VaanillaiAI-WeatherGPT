import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.services.marine_heatwave_service import marine_heatwave_service
from app.schemas.marine_heatwave import (
    CoralBleachingAlertLevel,
    MarineHeatwaveCategory,
)


def test_default_marine_heatwave_assessment():
    res = marine_heatwave_service.get_marine_heatwave_assessment()
    assert res.selected_sector.hotspot_id == "gulf_of_mannar_rameshwaram"
    assert res.selected_sector.state_or_ut == "Tamil Nadu"
    assert res.selected_sector.thermal_stress.degree_heating_weeks >= 8.0
    assert res.selected_sector.thermal_stress.bleaching_alert_level == CoralBleachingAlertLevel.ALERT_LEVEL_1
    assert res.selected_sector.heatwave.category == MarineHeatwaveCategory.CATEGORY_II_STRONG
    assert len(res.all_sectors) == 7
    # 5 vernacular bulletins
    for lang in ["en", "ta", "ml", "gu", "mr"]:
        assert lang in res.vernacular_bulletins
        assert len(res.vernacular_bulletins[lang]) > 20
    assert "INCOIS" in res.provenance


def test_specific_sector_lakshadweep():
    res = marine_heatwave_service.get_marine_heatwave_assessment(sector_id="lakshadweep_kavaratti")
    assert res.selected_sector.hotspot_id == "lakshadweep_kavaratti"
    assert res.selected_sector.thermal_stress.degree_heating_weeks > 12.0
    assert res.selected_sector.thermal_stress.bleaching_alert_level == CoralBleachingAlertLevel.ALERT_LEVEL_2
    assert res.selected_sector.heatwave.category == MarineHeatwaveCategory.CATEGORY_III_SEVERE
    assert "tuna" in res.selected_sector.heatwave.pelagic_fish_displacement.lower()
    # Check Tamil and Malayalam bulletins
    assert "பவளப்பாறை" in res.vernacular_bulletins["ta"] or "இன்கோயிஸ்" in res.vernacular_bulletins["ta"]
    assert "പവിഴപ്പുറ്റ്" in res.vernacular_bulletins["ml"] or "ഇൻകോയിസ്" in res.vernacular_bulletins["ml"]


def test_coastal_sea_fog_jnpt():
    res = marine_heatwave_service.get_marine_heatwave_assessment(sector_id="coastal_sea_fog_jnpt")
    assert res.selected_sector.hotspot_id == "coastal_sea_fog_jnpt"
    assert res.selected_sector.coastal_fog.is_fog_active is True
    assert res.selected_sector.coastal_fog.nautical_visibility_m <= 200.0
    assert res.selected_sector.coastal_fog.sea_air_temp_diff_c > 3.0
    assert "RADAR" in res.selected_sector.coastal_fog.vts_channel_status.upper()
    assert "DENSE ADVECTION" in res.vernacular_bulletins["en"]


def test_api_endpoint_marine_heatwave():
    client = TestClient(app)
    response = client.get("/api/v1/advisories/marine-heatwave?sector_id=andaman_havelock_swaraj")
    assert response.status_code == 200
    data = response.json()
    assert data["selected_sector"]["hotspot_id"] == "andaman_havelock_swaraj"
    assert data["selected_sector"]["thermal_stress"]["bleaching_alert_level"] == "BLEACHING_WARNING"
    assert data["selected_sector"]["heatwave"]["category"] == "CATEGORY_II_STRONG"
    assert len(data["vernacular_bulletins"]) == 5
