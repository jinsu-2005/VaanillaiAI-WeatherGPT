import secrets
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
    
    # Gemini AI Configuration with Model Hierarchy & Key Failover Pool
    GEMINI_API_KEY: str = ""
    GEMINI_API_KEYS: str = ""
    GEMINI_API_KEY_1: str = ""
    GEMINI_API_KEY_2: str = ""

    def get_api_keys(self) -> List[str]:
        """Return list of distinct configured Gemini API keys for failover & rotation."""
        keys: List[str] = []
        if self.GEMINI_API_KEYS:
            for k in self.GEMINI_API_KEYS.split(","):
                k = k.strip()
                if k and k not in keys:
                    keys.append(k)
        for explicit_key in [self.GEMINI_API_KEY_1, self.GEMINI_API_KEY_2, self.GEMINI_API_KEY]:
            explicit_key = explicit_key.strip()
            if explicit_key and explicit_key not in keys:
                keys.append(explicit_key)
        return keys

    GEMINI_MODEL: str = "gemini-3.1-flash-lite"
    GEMINI_FALLBACK_MODEL: str = "gemini-3.5-flash-lite"
    
    # Priority list of all free models for user tier (Highest quota and verified responsive first)
    AVAILABLE_FREE_MODELS: List[str] = [
        "gemini-3.1-flash-lite",         # 15 RPM / 500 RPD - Ultra-fast (1.0s latency)
        "gemini-3.5-flash-lite",         # 15 RPM / 500 RPD - High quota execution
        "gemini-3.8-flash",              # 5 RPM / 20 RPD - High reasoning
        "gemini-3.6-flash",              # 5 RPM / 20 RPD - Standard responsive flash
        "gemini-3.5-flash",              # 5 RPM / 20 RPD - Stable flash fallback
        "gemma-4-26b-a4b-it",            # 30 RPM / 14.4K RPD - High throughput open model
    ]

    # Voice Response & Live Audio Models
    GEMINI_TTS_MODEL: str = "gemini-3.1-flash-tts-preview"
    GEMINI_TTS_FALLBACK: str = "gemini-2.5-flash-preview-tts"
    LIVE_VOICE_MODEL: str = "gemini-3.1-flash-live-preview"
    LIVE_VOICE_FALLBACK: str = "gemini-2.5-flash-native-audio-latest"

    # External Meteorological APIs
    OPEN_METEO_FORECAST_URL: str = "https://api.open-meteo.com/v1/forecast"
    OPEN_METEO_GEOCODING_URL: str = "https://geocoding-api.open-meteo.com/v1/search"
    OPEN_METEO_ARCHIVE_URL: str = "https://archive-api.open-meteo.com/v1/archive"
    OPEN_METEO_AIR_QUALITY_URL: str = "https://air-quality-api.open-meteo.com/v1/air-quality"
    
    # IMD / NDMA Disaster Alert Feeds
    NDMA_SACHET_ALERTS_URL: str = "https://sachet.ndma.gov.in/cap_public_website/FetchAllAlertDetails"
    NDMA_SACHET_XML_URL: str = "https://sachet.ndma.gov.in/cap_public_website/FetchXMLFile"
    NDMA_SACHET_POLYGON_URL: str = "https://sachet.ndma.gov.in/cap_public_website/FetchPolygonXMLFile"
    IMD_MAUSAM_BASE_URL: str = "https://mausam.imd.gov.in/api"

    # Indian API (Station ID Directory & Fallbacks)
    INDIAN_API_BASE_URL: str = "https://weather.indianapi.in"
    INDIAN_API_KEY: str = "sk-live-WksZv4DFkDu0jSNkHE3nUoGb0AJkJ8KDULVj4hL7"

    # Cache TTL (seconds)
    CACHE_TTL_WEATHER: int = 900       # 15 mins
    CACHE_TTL_FORECAST: int = 3600     # 1 hour
    CACHE_TTL_ALERTS: int = 600        # 10 mins
    CACHE_TTL_GEOCODING: int = 86400   # 24 hours

    # Languages
    SUPPORTED_LANGUAGES: List[str] = ["en", "ta", "hi"]
    DEFAULT_LANGUAGE: str = "en"

    # Security, CORS & Auth
    SECRET_KEY: str = ""
    ALLOWED_ORIGINS: str = ""
    FIREBASE_PROJECT_ID: str = "vaanilaiai"
    REDIS_URL: str = ""

    def get_secret_key(self) -> str:
        """Return configured SECRET_KEY or generate a secure ephemeral key."""
        if self.SECRET_KEY and self.SECRET_KEY.strip():
            return self.SECRET_KEY.strip()
        # Ephemeral secure random key for development
        return "dev_" + secrets.token_hex(32)

    def get_cors_origins(self) -> List[str]:
        """Return list of allowed CORS origins from environment."""
        if self.ALLOWED_ORIGINS and self.ALLOWED_ORIGINS.strip():
            if self.ALLOWED_ORIGINS.strip() == "*":
                return ["*"]
            return [origin.strip() for origin in self.ALLOWED_ORIGINS.split(",") if origin.strip()]
        # Default safe development & local web origins
        return [
            "http://localhost:3000",
            "http://localhost:8000",
            "http://localhost:8080",
            "http://127.0.0.1:8000",
            "http://127.0.0.1:3000",
            "https://vaanilai-ai-backend.onrender.com",
            "https://vaanilaiai.web.app",
        ]


settings = Settings()
