"""Citizen Weather Science & Crowdsourced Ground Observation Service."""
import math
import uuid
from datetime import datetime
from typing import List, Optional
from app.schemas.advisory import CitizenReportCreate, CitizenReportResponse


class CitizenService:
    """Manages crowdsourced ground truth observations (waterlogging, hailstorms, flash floods)."""

    def __init__(self):
        self._reports: List[CitizenReportResponse] = []
        self._seed_reports()

    def _seed_reports(self):
        """Seed realistic initial ground observations across Indian urban and rural zones."""
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        self._reports.extend([
            CitizenReportResponse(
                id=str(uuid.uuid4()),
                report_type="Waterlogging",
                severity="High",
                water_depth_inches=14.0,
                description="Subway waterlogged under railway bridge. Light vehicles getting stranded.",
                latitude=13.0827,
                longitude=80.2707,
                location_name="Chennai Central",
                photo_url=None,
                reporter_role="Disaster Volunteer",
                upvotes=18,
                created_at=now
            ),
            CitizenReportResponse(
                id=str(uuid.uuid4()),
                report_type="Tree Fall / Squall",
                severity="Moderate",
                water_depth_inches=None,
                description="Banyan branch fallen across 2-lane road due to sudden pre-monsoon thunderstorm wind.",
                latitude=8.1833,
                longitude=77.4119,
                location_name="Nagercoil Town",
                photo_url=None,
                reporter_role="Citizen",
                upvotes=9,
                created_at=now
            ),
            CitizenReportResponse(
                id=str(uuid.uuid4()),
                report_type="Hailstorm",
                severity="Moderate",
                water_depth_inches=None,
                description="Intense hail shower observed (marble-sized stones) for 8 minutes.",
                latitude=28.6139,
                longitude=77.2090,
                location_name="New Delhi",
                photo_url=None,
                reporter_role="Citizen Meteorologist",
                upvotes=27,
                created_at=now
            ),
            CitizenReportResponse(
                id=str(uuid.uuid4()),
                report_type="Waterlogging",
                severity="Severe",
                water_depth_inches=22.0,
                description="Severe storm-water drain backflow on arterial road. Traffic diverted.",
                latitude=19.0760,
                longitude=72.8777,
                location_name="Mumbai Dadar TT",
                photo_url=None,
                reporter_role="Citizen",
                upvotes=42,
                created_at=now
            ),
        ])

    def create_report(self, data: CitizenReportCreate) -> CitizenReportResponse:
        """Add new crowdsourced citizen weather report."""
        rep = CitizenReportResponse(
            id=str(uuid.uuid4()),
            report_type=data.report_type,
            severity=data.severity,
            water_depth_inches=data.water_depth_inches,
            description=data.description,
            latitude=data.latitude,
            longitude=data.longitude,
            location_name=data.location_name,
            photo_url=data.photo_url,
            reporter_role=data.reporter_role,
            upvotes=1,
            created_at=datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        )
        self._reports.insert(0, rep)
        return rep

    def list_reports(
        self,
        lat: Optional[float] = None,
        lon: Optional[float] = None,
        radius_km: float = 100.0
    ) -> List[CitizenReportResponse]:
        """Return citizen reports, optionally filtered by distance in km."""
        if lat is None or lon is None:
            return self._reports

        filtered = []
        for r in self._reports:
            # Haversine distance
            dlat = math.radians(r.latitude - lat)
            dlon = math.radians(r.longitude - lon)
            a = math.sin(dlat / 2)**2 + math.cos(math.radians(lat)) * math.cos(math.radians(r.latitude)) * math.sin(dlon / 2)**2
            c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
            dist = 6371.0 * c
            if dist <= radius_km:
                filtered.append(r)

        # If too few within strict radius, return all recent
        return filtered if filtered else self._reports[:10]

    def upvote_report(self, report_id: str) -> Optional[CitizenReportResponse]:
        """Upvote / confirm ground report accuracy."""
        for r in self._reports:
            if r.id == report_id:
                r.upvotes += 1
                return r
        return None


citizen_service = CitizenService()
