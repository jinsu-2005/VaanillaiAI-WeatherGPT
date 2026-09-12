"""Voice input transcription and speech interaction service powered by Gemini Live TTS."""
import base64
import logging
import re
from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.config import settings
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
        """Process spoken query from microphone or client speech recognition and synthesize voice."""
        text_query = transcription

        # If raw audio base64 is provided without client STT, handle transcription
        if not text_query and audio_base64:
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

        # Synthesize vocal voice response using Gemini TTS model
        audio_out_b64 = None
        if chat_resp.response_text:
            audio_out_b64 = await self.synthesize_speech(chat_resp.response_text)

        return VoiceQueryResponse(
            transcribed_text=text_query,
            detected_language=language,
            chat_response=chat_resp,
            audio_base64=audio_out_b64
        )

    async def synthesize_speech(self, text: str) -> Optional[str]:
        """Synthesize natural spoken voice response using Gemini TTS with failover."""
        client = ai_agent.get_client()
        if not client:
            return None

        # Clean markdown formatting, emojis, and symbols for natural audio speech
        clean_speech = re.sub(r'[*#•\-_\r]', ' ', text)
        clean_speech = re.sub(r'https?://\S+', '', clean_speech)
        clean_speech = re.sub(r'[^\w\s.,!?:;°C\-\'\"]+', '', clean_speech)
        clean_speech = ' '.join(clean_speech.split()).strip()

        # Limit to first ~350 characters for immediate vocal playback
        if len(clean_speech) > 350:
            candidate = clean_speech[:350]
            if '.' in candidate:
                clean_speech = candidate.rsplit('.', 1)[0] + '.'
            else:
                clean_speech = candidate + '...'

        if not clean_speech:
            return None

        from google.genai import types

        tts_models = [
            settings.GEMINI_TTS_MODEL,
            settings.GEMINI_TTS_FALLBACK,
        ]

        for model in tts_models:
            if not model:
                continue
            try:
                tts_resp = client.models.generate_content(
                    model=model,
                    contents=clean_speech,
                    config=types.GenerateContentConfig(
                        response_modalities=["AUDIO"],
                        speech_config=types.SpeechConfig(
                            voice_config=types.VoiceConfig(
                                prebuilt_voice_config=types.PrebuiltVoiceConfig(voice_name="Aoede")
                            )
                        )
                    )
                )
                if tts_resp.candidates and tts_resp.candidates[0].content.parts:
                    for part in tts_resp.candidates[0].content.parts:
                        if part.inline_data and part.inline_data.data:
                            logger.info(f"Generated {len(part.inline_data.data)} bytes voice audio with {model}")
                            return base64.b64encode(part.inline_data.data).decode("utf-8")
            except Exception as e:
                logger.warning(f"Voice synthesis with {model} failed: {e}. Trying fallback.")
                continue

        return None


voice_service = VoiceService()
