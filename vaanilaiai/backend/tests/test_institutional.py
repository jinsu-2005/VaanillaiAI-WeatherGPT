"""Tests for Institutional Meteorological Enhancements: Marine, Crop, Lightning, Vision, and Citizen Science."""
import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app


@pytest.mark.asyncio
async def test_marine_advisory():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        resp = await client.get("/api/v1/advisories/marine?latitude=13.0827&longitude=80.2707&location_name=Chennai")
        assert resp.status_code == 200
        data = resp.json()
        assert "sea_condition" in data
        assert "significant_wave_height_m" in data
        assert "potential_fishing_zone_status" in data
        assert "port_warning_signal_number" in data


@pytest.mark.asyncio
async def test_crop_stage_advisory():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        payload = {
            "crop_type": "Paddy/Rice",
            "growth_stage": "Flowering",
            "latitude": 8.1833,
            "longitude": 77.4119,
            "location_name": "Nagercoil"
        }
        resp = await client.post("/api/v1/advisories/crop-stage", json=payload)
        assert resp.status_code == 200
        data = resp.json()
        assert data["crop_type"] == "Paddy/Rice"
        assert "irrigation_directive" in data
        assert "pest_disease_alert" in data


@pytest.mark.asyncio
async def test_lightning_alert():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        resp = await client.get("/api/v1/alerts/lightning?latitude=13.0827&longitude=80.2707&location_name=Chennai")
        assert resp.status_code == 200
        data = resp.json()
        assert "threat_level" in data
        assert "nearest_strike_km" in data
        assert "safety_rule_30_30" in data


@pytest.mark.asyncio
async def test_citizen_reports_flow():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # 1. List reports
        list_resp = await client.get("/api/v1/reports/citizen?latitude=13.0827&longitude=80.2707")
        assert list_resp.status_code == 200
        reports = list_resp.json()
        assert len(reports) > 0

        # 2. Create new report
        new_report = {
            "report_type": "Waterlogging",
            "severity": "Moderate",
            "water_depth_inches": 8.5,
            "description": "Localized water logging near signal junction.",
            "latitude": 13.0827,
            "longitude": 80.2707,
            "location_name": "Anna Salai",
            "reporter_role": "Citizen Meteorologist"
        }
        create_resp = await client.post("/api/v1/reports/citizen", json=new_report)
        assert create_resp.status_code == 200
        created = create_resp.json()
        report_id = created["id"]
        assert created["water_depth_inches"] == 8.5

        # 3. Upvote report
        upvote_resp = await client.post(f"/api/v1/reports/citizen/{report_id}/upvote")
        assert upvote_resp.status_code == 200
        assert upvote_resp.json()["upvotes"] == 2


@pytest.mark.asyncio
async def test_sky_analysis_base64():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        # 1x1 transparent PNG encoded in base64
        sample_b64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
        payload = {
            "image_base64": sample_b64,
            "location_name": "Chennai"
        }
        resp = await client.post("/api/v1/vision/analyze-sky-base64", json=payload)
        assert resp.status_code == 200
        data = resp.json()
        assert "cloud_genus" in data
        assert "squall_risk_level" in data
        assert "actionable_verdict" in data
