"""NDMA Sachet OASIS CAP-XML Alert Service with ETag Change Detection & HTTP 304 Caching.

Complies with the NDMA Sachet 'CAP XML Feed Integration Guide for Agencies':
- Sends 'If-None-Match' with previously stored ETag.
- Handles HTTP 304 Not Modified by returning cached XML payload.
- Handles HTTP 200 OK by updating ETag and cached XML content.
- Parses OASIS CAP v1.2 XML specifications (<cap:alert>, <cap:info>, bilingual English & vernacular).
"""
import asyncio
import logging
import re
import xml.etree.ElementTree as ET
from datetime import datetime, timezone, timedelta
from typing import Dict, List, Optional, Tuple
import httpx
from app.core.config import settings
from app.schemas.alert import DisasterAlertResponse, AlertSeverity

logger = logging.getLogger(__name__)

# CAP v1.2 XML Namespaces
CAP_NAMESPACES = {
    "cap": "urn:oasis:names:tc:emergency:cap:1.2",
}

SEVERITY_COLORS = {
    AlertSeverity.RED: "#E53E3E",
    AlertSeverity.ORANGE: "#DD6B20",
    AlertSeverity.YELLOW: "#D69E2E",
    AlertSeverity.GREEN: "#38A169",
}


class SachetETagEntry:
    """Represents a cached CAP XML file with its ETag."""
    def __init__(self, etag: str, xml_content: str, last_checked: datetime):
        self.etag: str = etag
        self.xml_content: str = xml_content
        self.last_checked: datetime = last_checked


class CapAlertService:
    """Service to consume NDMA Sachet CAP XML feed with RFC 7232 ETag conditional requests."""

    def __init__(self):
        # identifier -> SachetETagEntry
        self._cache: Dict[str, SachetETagEntry] = {}
        # Concurrency semaphore to avoid overwhelming Sachet servers
        self._semaphore = asyncio.Semaphore(5)

    @property
    def cached_identifiers_count(self) -> int:
        return len(self._cache)

    def get_cached_etag(self, identifier: str) -> Optional[str]:
        entry = self._cache.get(identifier)
        return entry.etag if entry else None

    async def fetch_cap_xml(
        self,
        identifier: str,
        client: Optional[httpx.AsyncClient] = None
    ) -> Optional[str]:
        """Fetch CAP XML for a given identifier utilizing ETag and HTTP 304 caching."""
        clean_id = identifier.strip()
        if not clean_id:
            return None

        url = f"{settings.NDMA_SACHET_XML_URL}?identifier={clean_id}"
        headers = {
            "User-Agent": "VaanilaiAI/1.0 (MoES IMD Disaster Management Platform; Agency Consumer)",
            "Accept": "application/xml, text/xml, */*",
        }

        cached_entry = self._cache.get(clean_id)
        if cached_entry and cached_entry.etag:
            # Sachet Integration Guide STEP 2: Send saved ETag
            headers["If-None-Match"] = cached_entry.etag

        async def _do_fetch(http_c: httpx.AsyncClient) -> Optional[str]:
            try:
                resp = await http_c.get(url, headers=headers, timeout=10.0)
                
                # STEP 2b: HTTP 304 Not Modified -> Use cached XML
                if resp.status_code == 304:
                    logger.debug(f"Sachet CAP XML 304 Not Modified for {clean_id} (using cached content).")
                    if cached_entry:
                        cached_entry.last_checked = datetime.now(timezone.utc)
                        return cached_entry.xml_content
                    return None

                # STEP 1 & 2a: HTTP 200 OK -> New or modified content
                if resp.status_code == 200:
                    xml_text = resp.text
                    new_etag = resp.headers.get("etag") or resp.headers.get("ETag") or ""
                    # Store in cache
                    self._cache[clean_id] = SachetETagEntry(
                        etag=new_etag,
                        xml_content=xml_text,
                        last_checked=datetime.now(timezone.utc)
                    )
                    logger.debug(f"Sachet CAP XML 200 OK for {clean_id} (new ETag: {new_etag}).")
                    return xml_text

                logger.warning(f"Sachet CAP XML returned HTTP {resp.status_code} for {clean_id}")
                # Fallback to cached if available
                return cached_entry.xml_content if cached_entry else None
            except Exception as e:
                logger.warning(f"Error fetching CAP XML for {clean_id}: {e}")
                return cached_entry.xml_content if cached_entry else None

        async with self._semaphore:
            if client:
                return await _do_fetch(client)
            else:
                async with httpx.AsyncClient() as new_client:
                    return await _do_fetch(new_client)

    def parse_cap_xml(
        self,
        xml_text: str,
        identifier_fallback: str = ""
    ) -> Optional[DisasterAlertResponse]:
        """Parse OASIS CAP v1.2 XML string into DisasterAlertResponse with vernacular support."""
        if not xml_text or not xml_text.strip():
            return None

        try:
            # Strip namespaces or parse with namespace handling
            root = ET.fromstring(xml_text)
            
            # Helper to find tag with or without namespace
            def find_text(element: ET.Element, tag: str, default: str = "") -> str:
                # Try with cap namespace
                el = element.find(f"cap:{tag}", CAP_NAMESPACES)
                if el is not None and el.text:
                    return el.text.strip()
                # Try without namespace
                el = element.find(tag)
                if el is not None and el.text:
                    return el.text.strip()
                # Try finding across all namespaces
                for child in element:
                    if child.tag.endswith(tag) and child.text:
                        return child.text.strip()
                return default

            # Top level alert attributes
            alert_id = find_text(root, "identifier", identifier_fallback)
            sender = find_text(root, "sender", "NDMA Sachet")
            sent_str = find_text(root, "sent", "")

            # Find all <info> blocks (often en-IN and vernacular hi-IN / ta-IN)
            infos = root.findall("cap:info", CAP_NAMESPACES)
            if not infos:
                infos = root.findall("info")
            if not infos:
                infos = [child for child in root if child.tag.endswith("info")]

            if not infos:
                logger.warning("No <info> block found in CAP XML")
                return None

            # Separate English and vernacular info blocks
            en_info = None
            vernacular_info = None

            for info in infos:
                lang = find_text(info, "language", "").lower()
                if "en" in lang:
                    en_info = info
                else:
                    vernacular_info = info

            # Primary info block is English if available, otherwise first info
            primary_info = en_info if en_info is not None else infos[0]

            category = find_text(primary_info, "category", "Meteorological")
            event = find_text(primary_info, "event", "Weather Advisory")
            urgency = find_text(primary_info, "urgency", "Immediate")
            severity_str = find_text(primary_info, "severity", "Moderate").lower()
            sender_name = find_text(primary_info, "senderName", sender)
            headline = find_text(primary_info, "headline", f"{event} Warning")
            description = find_text(primary_info, "description", "")
            instruction = find_text(primary_info, "instruction", "")

            effective_str = find_text(primary_info, "effective", sent_str)
            expires_str = find_text(primary_info, "expires", "")

            # Parse timestamps
            effective_dt = self._parse_iso_timestamp(effective_str)
            expires_dt = self._parse_iso_timestamp(expires_str)
            if not expires_dt:
                expires_dt = effective_dt + timedelta(hours=24)

            # Map Severity
            if "extreme" in severity_str or "red" in severity_str:
                severity = AlertSeverity.RED
            elif "severe" in severity_str or "orange" in severity_str:
                severity = AlertSeverity.ORANGE
            elif "moderate" in severity_str or "yellow" in severity_str:
                severity = AlertSeverity.YELLOW
            else:
                severity = AlertSeverity.GREEN

            # Area information
            area_el = primary_info.find("cap:area", CAP_NAMESPACES)
            if area_el is None:
                area_el = primary_info.find("area")
            if area_el is None:
                for c in primary_info:
                    if c.tag.endswith("area"):
                        area_el = c
                        break

            area_desc = find_text(area_el, "areaDesc", "Affected Region") if area_el is not None else "Affected Region"
            
            # Extract district & state from areaDesc if formatted e.g. "Chennai, Tamil Nadu"
            district = None
            state = None
            if "," in area_desc:
                parts = [p.strip() for p in area_desc.split(",")]
                district = parts[0]
                if len(parts) > 1:
                    state = parts[1]
            else:
                district = area_desc

            # Vernacular details
            vernacular_headline = None
            vernacular_language = None
            if vernacular_info is not None:
                v_head = find_text(vernacular_info, "headline", "")
                v_desc = find_text(vernacular_info, "description", "")
                vernacular_headline = v_head or v_desc[:120] if v_desc else None
                vernacular_language = find_text(vernacular_info, "language", "")

            # Polygon URL endpoint
            polygon_url = f"{settings.NDMA_SACHET_POLYGON_URL}?identifier={alert_id}"

            return DisasterAlertResponse(
                alert_id=alert_id,
                source=f"NDMA Sachet • {sender_name}",
                category=event or category,
                severity=severity,
                urgency=urgency,
                headline=headline,
                description=description or f"CAP Alert issued for {area_desc}.",
                instruction=instruction or "Follow directives from State & District Disaster Management Authorities.",
                area_description=area_desc,
                district=district,
                state=state,
                effective_from=effective_dt,
                expires_at=expires_dt,
                is_active=True,
                color_hex=SEVERITY_COLORS.get(severity, "#E53E3E"),
                cap_identifier=alert_id,
                polygon_url=polygon_url,
                vernacular_headline=vernacular_headline,
                vernacular_language=vernacular_language,
                sender_org=sender_name,
            )
        except Exception as e:
            logger.error(f"Failed to parse OASIS CAP XML for {identifier_fallback}: {e}")
            return None

    def _parse_iso_timestamp(self, ts_str: str) -> datetime:
        """Parse ISO 8601 or common timestamp formats."""
        if not ts_str:
            return datetime.now(timezone.utc)
        
        # Clean string
        clean_ts = ts_str.strip()
        try:
            # Handle ISO formats like 2026-09-11T12:00:00+05:30
            return datetime.fromisoformat(clean_ts)
        except Exception:
            pass

        # Try common Indian format e.g. "Sat Sep 12 00:42:00 IST 2026"
        try:
            # Remove "IST " if present
            cleaned = re.sub(r"\s+IST\s+", " ", clean_ts)
            dt = datetime.strptime(cleaned, "%a %b %d %H:%M:%S %Y")
            # Assign +05:30 offset
            return dt.replace(tzinfo=timezone(timedelta(hours=5, minutes=30)))
        except Exception:
            pass

        return datetime.now(timezone.utc)


cap_alert_service = CapAlertService()
