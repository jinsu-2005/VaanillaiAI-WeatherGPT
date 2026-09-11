"""Weather service managing caching, fusion, and high-resolution forecast delivery."""
import logging
from datetime import datetime, timedelta, timezone
from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
from app.core.config import settings
from app.models.weather_cache import WeatherCache
from app.providers.fusion import WeatherFusionEngine
from app.schemas.weather import WeatherForecastResponse, CurrentWeather

logger = logging.getLogger(__name__)


class WeatherService:
    """Core weather service with intelligent caching and multi-model normalization."""

    def __init__(self):
        self.fusion_engine = WeatherFusionEngine()

    async def get_weather(
        self,
        lat: float,
        lon: float,
        location_name: str = "Location",
        district: Optional[str] = None,
        state: Optional[str] = None,
        days: int = 7,
        db: Optional[AsyncSession] = None
    ) -> WeatherForecastResponse:
        """Fetch unified weather forecast with caching."""
        cache_key = f"weather_forecast_{round(lat, 4)}_{round(lon, 4)}_{days}"
        now = datetime.now(timezone.utc)

        # Check DB Cache if session provided
        if db is not None:
            try:
                stmt = select(WeatherCache).where(
                    WeatherCache.cache_key == cache_key,
                    WeatherCache.expires_at > now
                )
                res = await db.execute(stmt)
                cached = res.scalars().first()
                if cached and cached.payload:
                    logger.debug(f"Returning cached forecast for key {cache_key}")
                    return WeatherForecastResponse.model_validate(cached.payload)
            except Exception as e:
                logger.warning(f"Error reading weather cache: {e}")

        # Fetch live data via Fusion Engine
        forecast = await self.fusion_engine.fuse_forecast(
            lat=lat,
            lon=lon,
            location_name=location_name,
            district=district,
            state=state,
            days=days
        )

        # Store into cache
        if db is not None:
            try:
                expires = now + timedelta(seconds=settings.CACHE_TTL_WEATHER)
                # Remove expired entries for this key
                await db.execute(delete(WeatherCache).where(WeatherCache.cache_key == cache_key))
                entry = WeatherCache(
                    cache_key=cache_key,
                    data_type="forecast",
                    payload=forecast.model_dump(mode="json"),
                    expires_at=expires
                )
                db.add(entry)
                await db.flush()
            except Exception as e:
                logger.warning(f"Error saving to weather cache: {e}")

        return forecast


weather_service = WeatherService()
