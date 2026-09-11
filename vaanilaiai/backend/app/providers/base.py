"""Base Weather Provider interface."""
from abc import ABC, abstractmethod
from typing import Dict, Any, Optional, List
from app.schemas.weather import CurrentWeather, AirQualityData, HourlyForecastItem, DailyForecastItem
from app.schemas.alert import DisasterAlertResponse


class BaseWeatherProvider(ABC):
    """Abstract base class for all meteorological data providers."""

    @property
    @abstractmethod
    def provider_name(self) -> str:
        """Name of the provider."""
        pass

    @abstractmethod
    async def get_current_weather(self, lat: float, lon: float) -> CurrentWeather:
        """Fetch current weather observation or high-resolution model estimate."""
        pass

    @abstractmethod
    async def get_forecast(
        self,
        lat: float,
        lon: float,
        days: int = 7
    ) -> Dict[str, Any]:
        """Fetch hourly and multi-day forecasts."""
        pass

    @abstractmethod
    async def get_air_quality(self, lat: float, lon: float) -> Optional[AirQualityData]:
        """Fetch air quality data if supported."""
        pass

    @abstractmethod
    async def get_historical_weather(
        self,
        lat: float,
        lon: float,
        start_date: str,
        end_date: str
    ) -> Dict[str, Any]:
        """Fetch historical meteorological archive data."""
        pass


class BaseAlertProvider(ABC):
    """Abstract base class for disaster and warning providers."""

    @property
    @abstractmethod
    def provider_name(self) -> str:
        pass

    @abstractmethod
    async def get_active_alerts(
        self,
        lat: Optional[float] = None,
        lon: Optional[float] = None,
        district: Optional[str] = None,
        state: Optional[str] = None
    ) -> List[DisasterAlertResponse]:
        """Fetch active disaster warnings."""
        pass
