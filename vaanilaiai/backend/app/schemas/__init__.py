"""Schemas export."""
from app.schemas.location import (
    LocationCoordinates,
    LocationSearchResult,
    SavedLocationCreate,
    SavedLocationResponse,
)
from app.schemas.alert import (
    AlertSeverity,
    DisasterAlertResponse,
    AlertSummary,
)
from app.schemas.weather import (
    DataSourceType,
    WeatherProvenance,
    AirQualityData,
    CurrentWeather,
    HourlyForecastItem,
    DailyForecastItem,
    WeatherForecastResponse,
)
from app.schemas.advisory import (
    AgricultureAdvisoryResponse,
    TravelAdvisoryResponse,
)
from app.schemas.climate import (
    MonthlyClimateStats,
    YearlyClimateStats,
    ClimateComparisonResponse,
    ClimateTrendResponse,
)
from app.schemas.chat import (
    ChatQueryRequest,
    ChatQueryResponse,
    WeatherCardSummary,
    ChatHistoryItem,
    VoiceQueryResponse,
)

__all__ = [
    "LocationCoordinates",
    "LocationSearchResult",
    "SavedLocationCreate",
    "SavedLocationResponse",
    "AlertSeverity",
    "DisasterAlertResponse",
    "AlertSummary",
    "DataSourceType",
    "WeatherProvenance",
    "AirQualityData",
    "CurrentWeather",
    "HourlyForecastItem",
    "DailyForecastItem",
    "WeatherForecastResponse",
    "AgricultureAdvisoryResponse",
    "TravelAdvisoryResponse",
    "MonthlyClimateStats",
    "YearlyClimateStats",
    "ClimateComparisonResponse",
    "ClimateTrendResponse",
    "ChatQueryRequest",
    "ChatQueryResponse",
    "WeatherCardSummary",
    "ChatHistoryItem",
    "VoiceQueryResponse",
]
