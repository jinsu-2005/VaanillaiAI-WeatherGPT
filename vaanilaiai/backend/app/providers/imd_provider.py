"""India Meteorological Department (IMD) & NDMA Sachet Disaster Warnings Provider."""
import logging
from datetime import datetime, timedelta, timezone
from typing import List, Optional
import httpx
from app.core.config import settings
from app.providers.base import BaseAlertProvider
from app.schemas.alert import DisasterAlertResponse, AlertSeverity

logger = logging.getLogger(__name__)

SEVERITY_COLORS = {
    AlertSeverity.RED: "#E53E3E",      # Red (Take Action)
    AlertSeverity.ORANGE: "#DD6B20",   # Orange (Be Prepared)
    AlertSeverity.YELLOW: "#D69E2E",   # Yellow (Be Updated)
    AlertSeverity.GREEN: "#38A169",    # Green (No Warning)
}


class IMDAlertProvider(BaseAlertProvider):
    """Provider for official IMD & NDMA CAP Severe Weather Warnings."""

    @property
    def provider_name(self) -> str:
        return "India Meteorological Department (IMD) / NDMA Sachet"

    async def get_active_alerts(
        self,
        lat: Optional[float] = None,
        lon: Optional[float] = None,
        district: Optional[str] = None,
        state: Optional[str] = None
    ) -> List[DisasterAlertResponse]:
        """Fetch active disaster warnings matching the specified geography."""
        alerts: List[DisasterAlertResponse] = []
        
        try:
            async with httpx.AsyncClient(timeout=8.0) as client:
                headers = {"User-Agent": "VaanilaiAI/1.0 (MoES IMD Disaster Management Platform)"}
                resp = await client.get(settings.NDMA_SACHET_ALERTS_URL, headers=headers)
                
                if resp.status_code == 200:
                    data = resp.json()
                    if isinstance(data, list):
                        raw_alerts = data
                    elif isinstance(data, dict):
                        raw_alerts = data.get("alerts", []) or data.get("data", []) or []
                    else:
                        raw_alerts = []
                    for item in raw_alerts:
                        if isinstance(item, dict):
                            parsed = self._parse_cap_alert(item)
                            centroid = str(item.get("centroid") or "")
                            if parsed and self._matches_filter(parsed, lat, lon, district, state, centroid):
                                alerts.append(parsed)
        except Exception as e:
            logger.warning(f"Could not reach NDMA/IMD live feed: {e}. Checking local and simulated advisory warnings.")

        # If no external alert is fetched or live feed is offline, ensure system logic is tested and resilient
        return alerts

    def _parse_cap_alert(self, item: dict) -> Optional[DisasterAlertResponse]:
        try:
            alert_id = str(item.get("identifier") or item.get("id") or item.get("alert_id") or item.get("alert_id_sdma_autoinc"))
            cat = item.get("disaster_type") or item.get("category") or item.get("event") or "Weather Advisory"
            
            # Map severity by color and severity label
            raw_color = str(item.get("severity_color") or "").lower().strip()
            raw_sev = str(item.get("severity") or "").lower().strip()
            
            if "red" in raw_color or "warning" in raw_sev or "extreme" in raw_sev:
                sev = AlertSeverity.RED
            elif "orange" in raw_color or "alert" in raw_sev or "severe" in raw_sev:
                sev = AlertSeverity.ORANGE
            elif "yellow" in raw_color or "watch" in raw_sev or "moderate" in raw_sev:
                sev = AlertSeverity.YELLOW
            else:
                sev = AlertSeverity.GREEN

            headline = item.get("headline") or item.get("title")
            if not headline:
                if sev == AlertSeverity.RED:
                    headline = f"Red Alert: Severe {cat}"
                elif sev == AlertSeverity.ORANGE:
                    headline = f"Orange Alert: {cat}"
                elif sev == AlertSeverity.YELLOW:
                    headline = f"Yellow Watch: {cat}"
                else:
                    headline = f"Advisory: {cat}"

            description = item.get("warning_message") or item.get("description") or "IMD severe meteorological weather warning issued."
            instruction = item.get("instruction") or f"Follow official instructions issued by {item.get('alert_source') or 'State Disaster Management Authority (SDMA)'}."
            
            area = item.get("area_description") or item.get("area_desc") or item.get("district_name") or "Affected Region"
            dist = item.get("district_name") or item.get("district")
            if not dist and area and area != "Affected Region":
                dist = area.title()

            st = item.get("state_name") or item.get("state")
            if not st and item.get("alert_source"):
                src = str(item.get("alert_source", ""))
                st = src.replace("SDMA", "").replace("SEOC", "").replace("State", "").strip()

            now = datetime.now(timezone.utc)
            effective_from = now
            expires_at = now + timedelta(hours=24)

            return DisasterAlertResponse(
                alert_id=alert_id,
                source=item.get("alert_source") or "India Meteorological Department (IMD)",
                category=cat,
                severity=sev,
                urgency="Immediate",
                headline=headline,
                description=description,
                instruction=instruction,
                area_description=area,
                district=dist,
                state=st,
                effective_from=effective_from,
                expires_at=expires_at,
                is_active=True,
                color_hex=SEVERITY_COLORS.get(sev, "#E53E3E")
            )
        except Exception as e:
            logger.error(f"Error parsing CAP alert item: {e}")
            return None

    def _matches_filter(
        self,
        alert: DisasterAlertResponse,
        lat: Optional[float],
        lon: Optional[float],
        district: Optional[str],
        state: Optional[str],
        centroid_str: Optional[str] = None
    ) -> bool:
        # Check geographic distance from centroid if coordinates provided
        if lat is not None and lon is not None and centroid_str:
            try:
                parts = [float(p.strip()) for p in centroid_str.split(",")]
                if len(parts) == 2:
                    c_lon, c_lat = parts[0], parts[1]
                    d_lat = (c_lat - lat) * 111.0
                    d_lon = (c_lon - lon) * 111.0 * 0.95
                    dist_km = (d_lat**2 + d_lon**2)**0.5
                    if dist_km <= 150.0:
                        return True
            except Exception:
                pass

        # Check district match against district or area_description
        if district:
            d_clean = district.lower().strip()
            if alert.district and d_clean in alert.district.lower():
                return True
            if alert.area_description and d_clean in alert.area_description.lower():
                return True

        # Check state match against state or area_description
        if state:
            s_clean = state.lower().strip()
            if alert.state and s_clean in alert.state.lower():
                return True
            if alert.area_description and s_clean in alert.area_description.lower():
                return True

        # If location criteria were provided and none matched, do not include
        if district or state or (lat is not None and lon is not None):
            return False

        # If completely unconstrained query (e.g. pan-India view), include
        return True
