"""Disaster and Severe Weather Warning Endpoints."""
from typing import Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.schemas.alert import AlertSummary
from app.schemas.advisory import LightningAlertResponse
from app.services.disaster_service import disaster_service
from app.services.advisory_service import advisory_service

router = APIRouter()


@router.get("/active", response_model=AlertSummary, summary="Get Active Disaster Warnings")
async def get_active_alerts(
    latitude: Optional[float] = Query(None, ge=-90.0, le=90.0),
    longitude: Optional[float] = Query(None, ge=-180.0, le=180.0),
    district: Optional[str] = Query(None, description="District name"),
    state: Optional[str] = Query(None, description="State name"),
    db: AsyncSession = Depends(get_db)
):
    """Retrieve active color-coded disaster warnings (Heavy Rain, Cyclone, Heatwave, Lightning) from IMD / NDMA."""
    return await disaster_service.get_active_alerts(
        lat=latitude,
        lon=longitude,
        district=district,
        state=state,
        db=db
    )


@router.get("/lightning", response_model=LightningAlertResponse, summary="Get Real-Time Lightning Threat & Damini Alert")
async def get_lightning_alert(
    latitude: float = Query(..., ge=-90.0, le=90.0),
    longitude: float = Query(..., ge=-180.0, le=180.0),
    location_name: str = Query("Location")
):
    """Retrieve lightning strike proximity, CAPE thunderstorm index, and 30-30 farmer safety directives."""
    return await advisory_service.get_lightning_alert(
        lat=latitude,
        lon=longitude,
        location_name=location_name
    )


@router.get("/district/{district_name}", response_model=AlertSummary, summary="Get District Disaster Alerts")
async def get_district_alerts(
    district_name: str,
    db: AsyncSession = Depends(get_db)
):
    """Fetch warnings specifically targeting an Indian administrative district."""
    return await disaster_service.get_active_alerts(district=district_name, db=db)
