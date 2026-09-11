"""Citizen Science Crowdsourced Ground Reports API Endpoints."""
from typing import List, Optional
from fastapi import APIRouter, Query
from app.schemas.advisory import CitizenReportCreate, CitizenReportResponse
from app.services.citizen_service import citizen_service

router = APIRouter()


@router.get("/citizen", response_model=List[CitizenReportResponse], summary="List Crowdsourced Weather Reports")
async def list_reports(
    latitude: Optional[float] = Query(None, ge=-90.0, le=90.0),
    longitude: Optional[float] = Query(None, ge=-180.0, le=180.0),
    radius_km: float = Query(100.0, ge=5.0, le=500.0)
):
    """Retrieve community ground observations (waterlogging, hailstorms, flash floods) within search radius."""
    return citizen_service.list_reports(lat=latitude, lon=longitude, radius_km=radius_km)


@router.post("/citizen", response_model=CitizenReportResponse, summary="Submit Citizen Weather Report")
async def create_report(report: CitizenReportCreate):
    """Submit a real-time ground observation with optional water depth and location."""
    return citizen_service.create_report(report)


@router.post("/citizen/{report_id}/upvote", response_model=Optional[CitizenReportResponse], summary="Upvote Ground Report")
async def upvote_report(report_id: str):
    """Confirm accuracy of an active ground report."""
    return citizen_service.upvote_report(report_id)
