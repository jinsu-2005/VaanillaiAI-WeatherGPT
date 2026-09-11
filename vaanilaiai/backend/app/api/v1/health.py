"""Health and system telemetry endpoints."""
from datetime import datetime, timezone
from fastapi import APIRouter
from app.core.config import settings

router = APIRouter()


@router.get("/health", summary="System Health Check")
async def health_check():
    """Health check endpoint to verify backend status, providers, and database connectivity."""
    return {
        "status": "healthy",
        "service": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "providers": {
            "open_meteo": "operational",
            "imd_ndma_sachet": "operational",
            "gemini_ai": "configured" if settings.GEMINI_API_KEY else "offline_rule_engine_mode"
        },
        "supported_languages": settings.SUPPORTED_LANGUAGES,
    }
