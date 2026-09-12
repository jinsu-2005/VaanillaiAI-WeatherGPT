"""API v1 router configuration."""
from fastapi import APIRouter
from app.api.v1 import (
    health,
    weather,
    locations,
    alerts,
    advisories,
    climate,
    chat,
    voice,
    vision,
    reports,
    hydro,
    monsoon,
    safar,
)

api_router = APIRouter()

api_router.include_router(health.router, tags=["Health"])
api_router.include_router(weather.router, prefix="/weather", tags=["Weather & Forecast"])
api_router.include_router(locations.router, prefix="/locations", tags=["Locations & Geocoding"])
api_router.include_router(alerts.router, prefix="/alerts", tags=["Disaster & Warnings"])
api_router.include_router(advisories.router, prefix="/advisories", tags=["Decision Support Advisories"])
api_router.include_router(climate.router, prefix="/climate", tags=["Historical Climate"])
api_router.include_router(chat.router, prefix="/chat", tags=["Conversational AI"])
api_router.include_router(voice.router, prefix="/voice", tags=["Voice Interaction"])
api_router.include_router(vision.router, prefix="/vision", tags=["Multimodal Vision AI"])
api_router.include_router(reports.router, prefix="/reports", tags=["Citizen Science & Ground Truth"])
api_router.include_router(hydro.router, prefix="/hydro", tags=["CWC River Basin & Dam Hydro-Telemetry"])
api_router.include_router(monsoon.router, prefix="/monsoon", tags=["Monsoon & Teleconnections"])
api_router.include_router(safar.router, prefix="/air-quality", tags=["Air Quality & Atmospheric Dispersion"])

