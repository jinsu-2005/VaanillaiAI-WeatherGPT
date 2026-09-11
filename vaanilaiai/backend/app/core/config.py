"""Application configuration via pydantic-settings."""
from typing import List, Any
from pydantic import field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore"
    )

    PROJECT_NAME: str = "VaanilaiAI (WeatherGPT)"
    API_V1_STR: str = "/api/v1"
    VERSION: str = "1.0.0"
    DEBUG: bool = False

    @field_validator("DEBUG", mode="before")
    @classmethod
    def parse_debug(cls, v: Any) -> bool:
        if isinstance(v, bool):
            return v
        if isinstance(v, str):
            return v.strip().lower() in ("true", "1", "yes", "debug")
        return bool(v)

    # Database
    DATABASE_URL: str = "sqlite+aiosqlite:///./vaanilai.db"
    
    # Gemini AI Configuration with Model Hierarchy
    GEMINI_API_KEY: str = ""
    GEMINI_MODEL: str = "gemini-3.1-flash-lite"
    GEMINI_FALLBACK_MODEL: str = "gemini-3.6-flash"
    
    # Priority list of all free models (Highest quota and verified responsive first)
    AVAILABLE_FREE_MODELS: List[str] = [
        "gemini-3.1-flash-lite",         # 15 RPM / 500 RPD - Ultra-fast (1.0s latency)
        "gemini-3.6-flash",              # Standard responsive flash
        "gemini-3.7-flash",              # High intelligence & reasoning
        "gemini-3.5-flash-lite",         # High quota execution
        "gemini-3.5-flash",              # Stable flash fallback
    ]

    # Live Voice Dialogue Models (Real-time bidirectional speech)
    LIVE_VOICE_MODEL: str = "gemini-3-flash-live"
    LIVE_VOICE_FALLBACK: str = "gemini-2.5-flash-native-audio-dialog"

    # External Meteorological APIs
    OPEN_METEO_FORECAST_URL: str = "https://api.open-meteo.com/v1/forecast"
    OPEN_METEO_GEOCODING_URL: str = "https://geocoding-api.open-meteo.com/v1/search"
    OPEN_METEO_ARCHIVE_URL: str = "https://archive-api.open-meteo.com/v1/archive"
    OPEN_METEO_AIR_QUALITY_URL: str = "https://air-quality-api.open-meteo.com/v1/air-quality"
    
    # IMD / NDMA Disaster Alert Feeds
    NDMA_SACHET_ALERTS_URL: str = "https://sachet.ndma.gov.in/cap_public_website/FetchAllAlertDetails"
    IMD_MAUSAM_BASE_URL: str = "https://mausam.imd.gov.in/api"

    # Cache TTL (seconds)
    CACHE_TTL_WEATHER: int = 900       # 15 mins
    CACHE_TTL_FORECAST: int = 3600     # 1 hour
    CACHE_TTL_ALERTS: int = 600        # 10 mins
    CACHE_TTL_GEOCODING: int = 86400   # 24 hours

    # Languages
    SUPPORTED_LANGUAGES: List[str] = ["en", "ta", "hi"]
    DEFAULT_LANGUAGE: str = "en"

    # Security & CORS
    CORS_ORIGINS: List[str] = ["*"]
    SECRET_KEY: str = "vaanilai-ai-meteorological-super-secret-key-2026"


settings = Settings()
