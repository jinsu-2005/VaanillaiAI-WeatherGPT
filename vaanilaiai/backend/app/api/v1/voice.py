"""Voice interaction and speech query endpoints."""
from typing import Optional
from fastapi import APIRouter, Depends, Body
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.schemas.chat import VoiceQueryResponse
from app.services.voice_service import voice_service

router = APIRouter()


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
    """Process voice audio/transcription query and return grounded conversational response."""
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
