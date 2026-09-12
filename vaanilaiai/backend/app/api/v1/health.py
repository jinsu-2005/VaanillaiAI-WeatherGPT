"""Health and system telemetry endpoints."""
from datetime import datetime, timezone
import httpx
from fastapi import APIRouter
from app.core.config import settings

router = APIRouter()


@router.get("/health", summary="System Health Check")
async def health_check():
    """Health check endpoint verifying backend status and real upstream provider reachability."""
    open_meteo_status = "unknown"
    try:
        async with httpx.AsyncClient(timeout=4.0) as client:
            resp = await client.get(
                settings.OPEN_METEO_FORECAST_URL,
                params={"latitude": 8.18, "longitude": 77.41, "current": "temperature_2m"},
            )
            open_meteo_status = (
                "operational"
                if resp.status_code == 200
                else f"degraded (HTTP {resp.status_code})"
            )
    except Exception:
        open_meteo_status = "unreachable"

    overall_status = "healthy" if open_meteo_status == "operational" else "degraded"

    return {
        "status": overall_status,
        "service": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "providers": {
            "open_meteo": open_meteo_status,
            "gemini_ai": (
                "configured"
                if settings.GEMINI_API_KEY
                else "offline_rule_engine_mode"
            ),
        },
        "supported_languages": settings.SUPPORTED_LANGUAGES,
    }
