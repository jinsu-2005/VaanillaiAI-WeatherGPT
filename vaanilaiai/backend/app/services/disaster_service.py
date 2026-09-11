"""Disaster Management and Severe Weather Warning Service."""
import logging
from typing import List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.alert import DisasterAlert
from app.providers.imd_provider import IMDAlertProvider
from app.schemas.alert import DisasterAlertResponse, AlertSummary, AlertSeverity

logger = logging.getLogger(__name__)


class DisasterService:
    """Disaster warning aggregator and risk evaluator for MoES/IMD disaster management."""

    def __init__(self):
        self.imd_provider = IMDAlertProvider()

    async def get_active_alerts(
        self,
        lat: Optional[float] = None,
        lon: Optional[float] = None,
        district: Optional[str] = None,
        state: Optional[str] = None,
        db: Optional[AsyncSession] = None
    ) -> AlertSummary:
        """Fetch active alerts and compute regional severity."""
        alerts: List[DisasterAlertResponse] = []

        # 1. Fetch live CAP / IMD alerts
        live_alerts = await self.imd_provider.get_active_alerts(lat=lat, lon=lon, district=district, state=state)
        alerts.extend(live_alerts)

        # 2. Check DB for persisted emergency warnings if available
        if db is not None:
            try:
                stmt = select(DisasterAlert).where(DisasterAlert.is_active == True)
                if district:
                    stmt = stmt.where(DisasterAlert.district.ilike(f"%{district}%"))
                res = await db.execute(stmt)
                db_alerts = res.scalars().all()
                for dba in db_alerts:
                    # avoid duplicate alert_id
                    if not any(a.alert_id == dba.alert_id for a in alerts):
                        alerts.append(DisasterAlertResponse.model_validate(dba))
            except Exception as e:
                logger.warning(f"Error querying DB for alerts: {e}")

        # Compute highest severity
        highest_severity = AlertSeverity.GREEN
        for a in alerts:
            if a.severity == AlertSeverity.RED:
                highest_severity = AlertSeverity.RED
                break
            elif a.severity == AlertSeverity.ORANGE and highest_severity != AlertSeverity.RED:
                highest_severity = AlertSeverity.ORANGE
            elif a.severity == AlertSeverity.YELLOW and highest_severity not in (AlertSeverity.RED, AlertSeverity.ORANGE):
                highest_severity = AlertSeverity.YELLOW

        return AlertSummary(
            total_active_alerts=len(alerts),
            highest_severity=highest_severity,
            alerts=alerts
        )


disaster_service = DisasterService()
