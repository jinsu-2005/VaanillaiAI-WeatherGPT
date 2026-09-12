"""Agri-Met, Marine, Crop Stage, and Travel Decision Support Advisory Endpoints."""
from typing import Optional
from fastapi import APIRouter, Query
from app.schemas.advisory import (
    AgricultureAdvisoryResponse,
    TravelAdvisoryResponse,
    MarineAdvisoryResponse,
    CropStageAdvisoryRequest,
    CropStageAdvisoryResponse,
    DistrictAgrometBulletinResponse,
    UrbanFloodRiskResponse,
)
from app.services.advisory_service import advisory_service

router = APIRouter()


@router.get("/agriculture", response_model=AgricultureAdvisoryResponse, summary="Get Agricultural Advisory")
async def get_agriculture_advisory(
    latitude: float = Query(..., ge=-90.0, le=90.0),
    longitude: float = Query(..., ge=-180.0, le=180.0),
    location_name: str = Query("Location"),
    district: Optional[str] = Query(None)
):
    """Retrieve agro-meteorological guidance on pesticide spraying windows, irrigation advice, and heat stress."""
    return await advisory_service.get_agriculture_advisory(
        lat=latitude,
        lon=longitude,
        location_name=location_name,
        district=district
    )


@router.post("/crop-stage", response_model=CropStageAdvisoryResponse, summary="Get Stage-Specific Crop Phenology Advisory")
async def get_crop_stage_advisory(request: CropStageAdvisoryRequest):
    """Retrieve ICAR-GKMS aligned stage-specific advisory (sowing, tillering, flowering, harvesting) for major Indian crops."""
    return await advisory_service.get_crop_stage_advisory(
        crop_type=request.crop_type,
        growth_stage=request.growth_stage,
        lat=request.latitude,
        lon=request.longitude,
        location_name=request.location_name
    )


@router.get("/marine", response_model=MarineAdvisoryResponse, summary="Get INCOIS Marine & Port Advisory")
async def get_marine_advisory(
    latitude: float = Query(..., ge=-90.0, le=90.0),
    longitude: float = Query(..., ge=-180.0, le=180.0),
    location_name: str = Query("Coastal Waters")
):
    """Retrieve ocean state forecast, wave height, swell period, PFZ, and IMD port warning flags."""
    return await advisory_service.get_marine_advisory(
        lat=latitude,
        lon=longitude,
        location_name=location_name
    )


@router.get("/travel", response_model=TravelAdvisoryResponse, summary="Get Travel Advisory")
async def get_travel_advisory(
    latitude: float = Query(..., ge=-90.0, le=90.0),
    longitude: float = Query(..., ge=-180.0, le=180.0),
    location_name: str = Query("Location"),
    district: Optional[str] = Query(None)
):
    """Retrieve travel safety index, road conditions, visibility hazard, and transit guidance."""
    return await advisory_service.get_travel_advisory(
        lat=latitude,
        lon=longitude,
        location_name=location_name,
        district=district
    )


@router.get("/agromet-bulletin", response_model=DistrictAgrometBulletinResponse, summary="Get District Agromet Bulletin (GKMS)")
async def get_district_agromet_bulletin(
    latitude: float = Query(..., ge=-90.0, le=90.0),
    longitude: float = Query(..., ge=-180.0, le=180.0),
    district: Optional[str] = Query(None),
    state: Optional[str] = Query(None),
    language: str = Query("en", description="Language code: en, ta, hi")
):
    """Retrieve official-aligned ICAR-IMD Gramin Krishi Mausam Seva (GKMS) 5-day District Agromet Bulletin."""
    return await advisory_service.get_district_agromet_bulletin(
        lat=latitude,
        lon=longitude,
        district=district,
        state=state,
        language=language
    )


@router.get("/urban-flood", response_model=UrbanFloodRiskResponse, summary="Get Urban Flood & Waterlogging Risk Index")
async def get_urban_flood_risk(
    latitude: float = Query(..., ge=-90.0, le=90.0),
    longitude: float = Query(..., ge=-180.0, le=180.0),
    location_name: str = Query("City Zone"),
    district: Optional[str] = Query(None)
):
    """Retrieve micro-catchment waterlogging risk score, street pooling depth, underpass status, and commuter directives."""
    return await advisory_service.get_urban_flood_risk(
        lat=latitude,
        lon=longitude,
        location_name=location_name,
        district=district
    )


