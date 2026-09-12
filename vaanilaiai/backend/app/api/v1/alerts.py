import asyncio
from datetime import datetime, timezone
from typing import Optional
from fastapi import APIRouter, Depends, Query, Request
from fastapi.responses import StreamingResponse
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.schemas.alert import AlertSummary, IMDSOPResponse
from app.schemas.advisory import LightningAlertResponse
from app.schemas.cyclone import CycloneTrackerResponse
from app.services.disaster_service import disaster_service
from app.services.advisory_service import advisory_service
from app.services.cyclone_service import cyclone_service

router = APIRouter()


@router.get("/cyclone-tracker", response_model=CycloneTrackerResponse, summary="Get IMD RSMC Tropical Cyclone Track & Storm Surge Telemetry")
async def get_cyclone_tracker(
    latitude: Optional[float] = Query(None, ge=-90.0, le=90.0, description="User latitude for distance & proximity calculation"),
    longitude: Optional[float] = Query(None, ge=-180.0, le=180.0, description="User longitude for distance & proximity calculation"),
    system_id: Optional[str] = Query(None, description="Optional cyclone system ID (e.g. michaung-2023, biparjoy-2023, dana-2024)")
):
    """Retrieve authentic RSMC New Delhi tropical cyclone tracks, Dvorak T-number intensity, and storm surge inundation models."""
    return cyclone_service.get_cyclone_telemetry(
        user_lat=latitude,
        user_lon=longitude,
        system_id=system_id
    )


@router.get("/sop", response_model=IMDSOPResponse, summary="Get IMD Warning Matrix & NDMA Standard Operating Procedures")
async def get_imd_sop(
    hazard: Optional[str] = Query(None, description="Optional hazard filter (cyclone, heavy_rainfall_flood, thunderstorm_lightning, heatwave, dense_fog_coldwave)"),
    state: Optional[str] = Query(None, description="Optional state filter")
):
    """Retrieve official IMD 4-stage color warning criteria, NDMA hazard SOPs (Do's & Don'ts), and emergency contacts."""
    return disaster_service.get_imd_sop_matrix(hazard=hazard, state=state)


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


@router.get("/stream", summary="Live Alert Stream (Server-Sent Events)")
async def stream_alerts(
    request: Request,
    district: Optional[str] = Query(None, description="Optional district filter"),
    state: Optional[str] = Query(None, description="Optional state filter"),
    max_events: Optional[int] = Query(None, description="Max events to stream before closing (useful for testing or batch sync)"),
    db: AsyncSession = Depends(get_db),
):
    """Server-Sent Events (SSE) stream delivering real-time disaster alert updates."""
    async def event_generator():
        alerts = await disaster_service.get_active_alerts(district=district, state=state, db=db)
        yield f"event: alert_snapshot\ndata: {alerts.model_dump_json()}\n\n"
        events_sent = 1
        if max_events is not None and events_sent >= max_events:
            return

        while not await request.is_disconnected():
            await asyncio.sleep(15)
            yield f"event: ping\ndata: {{\"timestamp\": \"{datetime.now(timezone.utc).isoformat()}\"}}\n\n"
            events_sent += 1
            if max_events is not None and events_sent >= max_events:
                break

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )

