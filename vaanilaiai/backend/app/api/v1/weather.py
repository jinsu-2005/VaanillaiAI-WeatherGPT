"""Weather Forecast and Observation Endpoints."""
from typing import Optional, List
from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.schemas.weather import WeatherForecastResponse, CurrentWeather, HourlyForecastItem
from app.services.weather_service import weather_service

router = APIRouter()


@router.get("/forecast", response_model=WeatherForecastResponse, summary="Get Full Weather Forecast")
async def get_forecast(
    latitude: float = Query(..., ge=-90.0, le=90.0, description="Latitude in decimal degrees"),
    longitude: float = Query(..., ge=-180.0, le=180.0, description="Longitude in decimal degrees"),
    location_name: str = Query("Location", description="Display name of town, village or city"),
    district: Optional[str] = Query(None, description="District name"),
    state: Optional[str] = Query(None, description="State name"),
    days: int = Query(7, ge=1, le=14, description="Forecast horizon in days"),
    db: AsyncSession = Depends(get_db)
):
    """Retrieve multi-day coordinate-level NWP forecast fused with official IMD disaster warnings."""
    return await weather_service.get_weather(
        lat=latitude,
        lon=longitude,
        location_name=location_name,
        district=district,
        state=state,
        days=days,
        db=db
    )


@router.get("/current", response_model=CurrentWeather, summary="Get Current Weather")
async def get_current_weather(
    latitude: float = Query(..., ge=-90.0, le=90.0),
    longitude: float = Query(..., ge=-180.0, le=180.0),
    location_name: str = Query("Location"),
    db: AsyncSession = Depends(get_db)
):
    """Retrieve real-time conditions with data provenance."""
    forecast = await weather_service.get_weather(
        lat=latitude,
        lon=longitude,
        location_name=location_name,
        days=1,
        db=db
    )
    return forecast.current


@router.get("/hourly", response_model=List[HourlyForecastItem], summary="Get Hourly Forecast")
async def get_hourly_forecast(
    latitude: float = Query(..., ge=-90.0, le=90.0),
    longitude: float = Query(..., ge=-180.0, le=180.0),
    hours: int = Query(24, ge=1, le=48),
    db: AsyncSession = Depends(get_db)
):
    """Retrieve hourly meteorological parameters (temperature, rain prob, wind, UV)."""
    forecast = await weather_service.get_weather(
        lat=latitude,
        lon=longitude,
        days=2,
        db=db
    )
    return forecast.hourly[:hours]
