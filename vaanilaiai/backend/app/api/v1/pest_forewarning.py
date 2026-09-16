"""API endpoints for IMD Agro-Climatic Zone Crop Pest & Disease Forewarning Engine."""
from typing import Optional
from fastapi import APIRouter, Query
from app.schemas.pest_forewarning import PestForewarningResponse
from app.services.pest_forewarning_service import PestForewarningService

router = APIRouter()


@router.get("/pest-forewarning", response_model=PestForewarningResponse, summary="Get Agro-Climatic Zone Pest & Disease Forewarning")
async def get_pest_forewarning(
    latitude: Optional[float] = Query(None, ge=-90.0, le=90.0, description="Observer latitude in decimal degrees"),
    longitude: Optional[float] = Query(None, ge=-180.0, le=180.0, description="Observer longitude in decimal degrees"),
    zone_id: Optional[int] = Query(None, ge=1, le=15, description="Official Indian Agro-Climatic Zone ID (1-15)"),
    temperature_c: Optional[float] = Query(None, description="Optional observed or nowcast temperature in °C"),
    relative_humidity_pct: Optional[float] = Query(None, ge=0.0, le=100.0, description="Optional observed or nowcast relative humidity %"),
):
    """
    Retrieve authentic IMD GKMS & ICAR-NCIPM epidemiological crop pathogen and insect vector early warnings,
    including Wallin's Potato Late Blight Severity, Mustard Aphid thermal GDD, Rice Blast leaf wetness duration,
    Economic Threshold Levels (ETL), and dual bio-control/chemical spray prescriptions.
    """
    return PestForewarningService.get_pest_forewarning(
        latitude=latitude,
        longitude=longitude,
        zone_id=zone_id,
        observed_t_c=temperature_c,
        observed_rh_pct=relative_humidity_pct,
    )
