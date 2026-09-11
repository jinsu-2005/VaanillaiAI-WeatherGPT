"""Historical Weather and Climate Analysis Endpoints."""
from fastapi import APIRouter, Query
from app.schemas.climate import ClimateComparisonResponse, ClimateTrendResponse
from app.services.climate_service import climate_service

router = APIRouter()


@router.get("/compare", response_model=ClimateComparisonResponse, summary="Compare Climate Across Two Years")
async def compare_climate_years(
    latitude: float = Query(..., ge=-90.0, le=90.0),
    longitude: float = Query(..., ge=-180.0, le=180.0),
    location_name: str = Query("Location"),
    year_1: int = Query(2022, ge=1950, le=2025),
    year_2: int = Query(2023, ge=1950, le=2025)
):
    """Compare annual rainfall, rainy days, and temperature anomalies between two years."""
    return await climate_service.compare_years(
        lat=latitude,
        lon=longitude,
        location_name=location_name,
        year_1=year_1,
        year_2=year_2
    )


@router.get("/trends", response_model=ClimateTrendResponse, summary="Get Multi-Year Climate Trends")
async def get_climate_trends(
    latitude: float = Query(..., ge=-90.0, le=90.0),
    longitude: float = Query(..., ge=-180.0, le=180.0),
    location_name: str = Query("Location"),
    start_year: int = Query(2018, ge=1950, le=2024),
    end_year: int = Query(2024, ge=1950, le=2024)
):
    """Compute multi-year warming rates and rainfall shift trends."""
    return await climate_service.get_multi_year_trends(
        lat=latitude,
        lon=longitude,
        location_name=location_name,
        start_year=start_year,
        end_year=end_year
    )
