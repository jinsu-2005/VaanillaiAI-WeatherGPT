from typing import Optional
from fastapi import APIRouter, Depends, Body, WebSocket
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.schemas.chat import VoiceQueryResponse, LiveSessionInitResponse, LiveSessionInitRequest
from app.services.voice_service import voice_service

router = APIRouter()


@router.websocket("/live")
async def live_voice_websocket(
    websocket: WebSocket,
    language: str = "en",
    latitude: Optional[float] = None,
    longitude: Optional[float] = None,
    location_name: Optional[str] = None,
    db: AsyncSession = Depends(get_db)
):
    """Bidirectional streaming WebSocket endpoint connecting Flutter client to Gemini Live API."""
    await voice_service.handle_live_websocket(
        websocket=websocket,
        language=language,
        latitude=latitude,
        longitude=longitude,
        location_name=location_name,
        db=db
    )


@router.post("/init", response_model=LiveSessionInitResponse, summary="Initialize Gemini Live Voice Session & Converse First")
async def init_live_voice(
    payload: LiveSessionInitRequest = Body(default_factory=LiveSessionInitRequest),
    db: AsyncSession = Depends(get_db)
):
    """Initialize Gemini Live session, configure voice system prompts, and proactively converse first with a spoken briefing."""
    return await voice_service.initialize_live_session(
        language=payload.language,
        latitude=payload.latitude,
        longitude=payload.longitude,
        location_name=payload.location_name,
        session_id=payload.session_id,
        db=db
    )


@router.post("/query", response_model=VoiceQueryResponse, summary="Process Spoken Weather Query")
async def voice_query(
    audio_base64: Optional[str] = Body(None, description="Base64 encoded audio"),
    transcription: Optional[str] = Body(None, description="Speech-to-text transcript if already transcribed"),
    language: str = Body("en", description="'en', 'ta', or 'hi'"),
    latitude: Optional[float] = Body(None),
    longitude: Optional[float] = Body(None),
    location_name: Optional[str] = Body(None),
    session_id: Optional[str] = Body(None),
    db: AsyncSession = Depends(get_db)
):
    """Process voice audio/transcription query and return grounded conversational response with optional synthesized TTS audio."""
    return await voice_service.process_voice_query(
        audio_base64=audio_base64,
        transcription=transcription,
        language=language,
        latitude=latitude,
        longitude=longitude,
        location_name=location_name,
        session_id=session_id,
        db=db
    )
