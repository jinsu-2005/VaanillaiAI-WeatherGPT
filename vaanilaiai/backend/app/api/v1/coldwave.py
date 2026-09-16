"""API endpoints for IMD Cold Wave & Ground Frost Agronomic Vulnerability Engine."""
from typing import Optional
from fastapi import APIRouter, Query
from app.schemas.coldwave import ColdWaveResponse
from app.services.coldwave_service import ColdWaveService

router = APIRouter()


@router.get("/assessment", response_model=ColdWaveResponse, summary="Get IMD Cold Wave & Ground Frost Vulnerability Assessment")
async def get_cold_wave_assessment(
    latitude: Optional[float] = Query(None, ge=-90.0, le=90.0, description="Observer latitude in decimal degrees"),
    longitude: Optional[float] = Query(None, ge=-180.0, le=180.0, description="Observer longitude in decimal degrees"),
    station_id: Optional[str] = Query(None, description="Optional monitoring station identifier (e.g. CHURU_RJ, HISAR_HR)"),
):
    """
    Retrieve official IMD Cold Wave classification, Stefan-Boltzmann grass minimum temperature (T_grass),
    ground frost risk rating, ICAR Rabi crop vulnerability protocols, and urban Rain Basera night shelter advisories.
    """
    return ColdWaveService.get_cold_wave_assessment(
        latitude=latitude,
        longitude=longitude,
        station_id=station_id,
    )
