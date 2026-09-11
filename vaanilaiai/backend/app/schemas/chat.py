"""Pydantic schemas for Conversational AI Chat and Tool-Execution Payloads."""
from datetime import datetime, timezone
from typing import List, Optional, Dict, Any, Union
from pydantic import BaseModel, Field, ConfigDict
from app.schemas.alert import DisasterAlertResponse


class ChatQueryRequest(BaseModel):
    query: str = Field(..., min_length=1, description="User's natural language weather question")
    session_id: Optional[str] = Field(None, description="Unique conversation session UUID")
    user_id: Optional[int] = Field(None, description="Optional authenticated user ID")
    language: str = Field("en", description="Target language ('en', 'ta', 'hi')")
    latitude: Optional[float] = Field(None, ge=-90.0, le=90.0)
    longitude: Optional[float] = Field(None, ge=-180.0, le=180.0)
    location_name: Optional[str] = Field(None, description="Optional contextual location hint")


class WeatherCardSummary(BaseModel):
    location_name: str = "Location"
    temperature: float = 0.0
    feels_like: float = 0.0
    condition_text: str = "Clear"
    condition_icon: str = "01d"
    humidity: int = 50
    wind_speed: float = 0.0
    rain_probability: int = 0
    uv_index: float = 0.0
    source_type: str = "NWP_MODEL"


class ChatQueryResponse(BaseModel):
    session_id: str
    response_text: str
    language: str
    intent: Optional[str] = None
    detected_location: Optional[str] = None
    weather_card: Optional[WeatherCardSummary] = None
    active_alerts: List[DisasterAlertResponse] = []
    advisory_summary: Optional[str] = None
    citations: List[str] = []
    tools_used: List[str] = []
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))


class ChatHistoryItem(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    role: str
    content: str
    language: str
    tool_calls: Optional[List[Any]] = None
    weather_context: Optional[Dict[str, Any]] = None
    grounded_citations: Optional[List[str]] = None
    created_at: datetime


class VoiceQueryResponse(BaseModel):
    transcribed_text: str
    detected_language: str
    chat_response: ChatQueryResponse
    audio_base64: Optional[str] = None
