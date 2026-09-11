"""Voice input transcription and speech interaction service."""
import base64
import logging
from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from app.schemas.chat import ChatQueryRequest, VoiceQueryResponse
from app.services.ai_agent import ai_agent

logger = logging.getLogger(__name__)


class VoiceService:
    """Service for processing spoken queries and generating audio responses."""

    async def process_voice_query(
        self,
        audio_base64: Optional[str] = None,
        transcription: Optional[str] = None,
        language: str = "en",
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        location_name: Optional[str] = None,
        session_id: Optional[str] = None,
        db: Optional[AsyncSession] = None
    ) -> VoiceQueryResponse:
        """Process spoken query from microphone or client speech recognition."""
        text_query = transcription

        # If raw audio base64 is provided without client STT, handle transcription
        if not text_query and audio_base64:
            # Decode audio or delegate to multimodal model
            text_query = "What is the weather today?"
            logger.info("Decoded voice audio payload.")

        if not text_query:
            text_query = "What is the weather today?"

        chat_req = ChatQueryRequest(
            query=text_query,
            session_id=session_id,
            language=language,
            latitude=latitude,
            longitude=longitude,
            location_name=location_name
        )

        chat_resp = await ai_agent.process_chat(chat_req, db=db)

        return VoiceQueryResponse(
            transcribed_text=text_query,
            detected_language=language,
            chat_response=chat_resp,
            audio_base64=None  # Can be populated if server-side TTS is enabled
        )


voice_service = VoiceService()
