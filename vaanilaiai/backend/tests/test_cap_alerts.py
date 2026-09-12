"""Unit and integration tests for NDMA Sachet OASIS CAP-XML service & IMD Station Catalog."""
import pytest
from unittest.mock import AsyncMock, patch, MagicMock
from datetime import datetime, timezone
import httpx
from app.services.cap_alert_service import CapAlertService, SachetETagEntry
from app.schemas.alert import AlertSeverity
from app.services.location_service import location_service


SAMPLE_CAP_XML = """<?xml version="1.0" encoding="UTF-8"?>
<cap:alert xmlns:cap="urn:oasis:names:tc:emergency:cap:1.2">
  <cap:identifier>NDMA-IN-TN-2026-09-001</cap:identifier>
  <cap:sender>tnsdma@tn.gov.in</cap:sender>
  <cap:sent>2026-09-12T00:30:00+05:30</cap:sent>
  <cap:status>Actual</cap:status>
  <cap:msgType>Alert</cap:msgType>
  <cap:scope>Public</cap:scope>
  <cap:info>
    <cap:language>en-IN</cap:language>
    <cap:category>Met</cap:category>
    <cap:event>Heavy Rainfall</cap:event>
    <cap:urgency>Immediate</cap:urgency>
    <cap:severity>Severe</cap:severity>
    <cap:certainty>Observed</cap:certainty>
    <cap:senderName>Tamil Nadu State Disaster Management Authority</cap:senderName>
    <cap:headline>Red Alert: Torrential Deluge Expected in Coastal Districts</cap:headline>
    <cap:description>Very heavy to extremely heavy rainfall with localized inundation and squally winds up to 65 km/h.</cap:description>
    <cap:instruction>Move to designated cyclone/flood shelters. Avoid underpasses and coastal roads.</cap:instruction>
    <cap:area>
      <cap:areaDesc>Chennai, Tamil Nadu</cap:areaDesc>
    </cap:area>
  </cap:info>
  <cap:info>
    <cap:language>ta-IN</cap:language>
    <cap:category>Met</cap:category>
    <cap:event>கனமழை எச்சரிக்கை</cap:event>
    <cap:urgency>Immediate</cap:urgency>
    <cap:severity>Severe</cap:severity>
    <cap:headline>சிவப்பு எச்சரிக்கை: மிகக் கடுமையான கனமழை எதிர்பார்க்கப்படுகிறது</cap:headline>
    <cap:description>சென்னை மற்றும் புறநகர் பகுதிகளில் அதி தீவிர மழை பொழிய வாய்ப்புள்ளது.</cap:description>
  </cap:info>
</cap:alert>
"""


@pytest.mark.asyncio
async def test_cap_xml_parsing():
    """Verify standard OASIS CAP v1.2 XML parsing with vernacular bilingual extraction."""
    service = CapAlertService()
    parsed = service.parse_cap_xml(SAMPLE_CAP_XML, identifier_fallback="fallback-id")

    assert parsed is not None
    assert parsed.alert_id == "NDMA-IN-TN-2026-09-001"
    assert parsed.severity == AlertSeverity.ORANGE  # Severe maps to Orange/Red
    assert "Red Alert" in parsed.headline
    assert parsed.district == "Chennai"
    assert parsed.state == "Tamil Nadu"
    assert "cyclone/flood shelters" in parsed.instruction
    assert parsed.polygon_url is not None
    assert "FetchPolygonXMLFile" in parsed.polygon_url
    assert parsed.vernacular_headline is not None
    assert "சிவப்பு எச்சரிக்கை" in parsed.vernacular_headline
    assert parsed.vernacular_language == "ta-IN"


@pytest.mark.asyncio
async def test_cap_service_etag_and_304_caching():
    """Verify Sachet Agency Guide: STEP 1 (200 OK + store ETag) and STEP 2 (If-None-Match -> 304)."""
    service = CapAlertService()
    identifier = "NDMA-TEST-001"

    mock_client = AsyncMock()

    # Step 1: Initial fetch returns 200 OK with ETag
    resp_200 = MagicMock()
    resp_200.status_code = 200
    resp_200.text = SAMPLE_CAP_XML
    resp_200.headers = {"etag": '"etag-hash-v1"'}

    mock_client.get.return_value = resp_200

    content_1 = await service.fetch_cap_xml(identifier, client=mock_client)
    assert content_1 == SAMPLE_CAP_XML
    assert service.get_cached_etag(identifier) == '"etag-hash-v1"'
    assert service.cached_identifiers_count == 1

    # Verify first call had NO If-None-Match header
    first_call_args = mock_client.get.call_args
    assert "If-None-Match" not in first_call_args.kwargs["headers"]

    # Step 2: Second fetch returns 304 Not Modified
    resp_304 = MagicMock()
    resp_304.status_code = 304
    resp_304.text = ""  # Empty body on 304
    resp_304.headers = {}

    mock_client.get.return_value = resp_304

    content_2 = await service.fetch_cap_xml(identifier, client=mock_client)
    # Must return cached XML from client-side cache
    assert content_2 == SAMPLE_CAP_XML

    # Verify second call included If-None-Match: "etag-hash-v1"
    second_call_args = mock_client.get.call_args
    assert second_call_args.kwargs["headers"]["If-None-Match"] == '"etag-hash-v1"'


def test_imd_station_catalog_loaded():
    """Verify 697 Indian City IMD/WMO station ID directory is ingested and queryable."""
    assert len(location_service._stations) >= 500
    # Test specific key stations
    assert location_service.match_station_id("Port blair") == "43333"
    assert location_service.match_station_id("Chennai") in ("43278", "43279")

    # Test find_imd_stations search
    matches = location_service.find_imd_stations("Delhi", limit=5)
    assert len(matches) > 0
    assert any("delhi" in m.city_name.lower() for m in matches)
