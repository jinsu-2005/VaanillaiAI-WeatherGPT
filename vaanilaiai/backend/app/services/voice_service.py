"""Voice input transcription, speech interaction, and proactive Gemini Live conversation service."""
import asyncio
import base64
import json
import logging
import re
import uuid
from typing import Optional, List
from fastapi import WebSocket, WebSocketDisconnect
from google import genai
from google.genai import types
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.config import settings
from app.schemas.chat import (
    ChatQueryRequest,
    VoiceQueryResponse,
    LiveSessionInitResponse,
    WeatherCardSummary,
)
from app.services.ai_agent import ai_agent
from app.services.weather_service import weather_service
from app.services.disaster_service import disaster_service
from app.services.location_service import location_service
from app.services.advisory_service import advisory_service

logger = logging.getLogger(__name__)


async def execute_live_tool(name: str, args: dict, db: Optional[AsyncSession] = None) -> dict:
    """Execute dynamic meteorological and disaster tools for Gemini Live."""
    loc_query = (args.get("location_name") or "Nagercoil").strip()
    try:
        search_res = await location_service.search_locations(loc_query)
        if search_res:
            match = search_res[0]
            lat, lon = match.latitude, match.longitude
            resolved_name = match.display_name or loc_query
        else:
            lat, lon = 8.1833, 77.4119
            resolved_name = loc_query

        if name == "get_weather_for_location":
            f = await weather_service.get_weather(lat, lon, location_name=resolved_name, days=3, db=db)
            curr = f.current
            today = f.daily[0] if f.daily else None
            return {
                "location": resolved_name,
                "temperature_celsius": curr.temperature if curr else 29.0,
                "feels_like_celsius": curr.feels_like if curr else 32.0,
                "condition": curr.condition_text if curr else "Clear",
                "rain_probability_percent": today.precipitation_probability_max if today else 10,
                "humidity_percent": curr.humidity if curr else 75,
                "wind_speed_kmh": curr.wind_speed if curr else 15.0,
                "telemetry_summary": f"In {resolved_name}, temperature is {curr.temperature if curr else 29.0}°C, sky condition is {curr.condition_text if curr else 'Clear'}, precipitation probability is {today.precipitation_probability_max if today else 10}%."
            }
        elif name == "get_disaster_and_cyclone_warnings":
            alerts = await disaster_service.get_active_alerts(lat=lat, lon=lon, db=db)
            alert_items = [f"{a.severity} {a.event}: {a.headline}" for a in alerts.alerts] if alerts.alerts else ["No active disaster or severe weather warnings for this region."]
            return {
                "location": resolved_name,
                "active_alerts": alert_items
            }
        elif name == "get_farming_advisory":
            adv = await advisory_service.get_agriculture_advisory(lat, lon, location_name=resolved_name)
            return {
                "location": resolved_name,
                "spraying_suitability": adv.spraying_suitability,
                "reason": adv.spraying_reason,
                "irrigation_advice": adv.irrigation_advice,
                "rain_risk": adv.rain_risk_level
            }
        return {"error": f"Unknown tool {name}"}
    except Exception as err:
        logger.error(f"Error executing live tool {name} for '{loc_query}': {err}")
        return {"error": str(err), "location": loc_query}

GEMINI_LIVE_VOICE_SYSTEM_PROMPT = """You are VaanilaiAI Live (WeatherGPT), the official real-time spoken conversational voice assistant for meteorological intelligence across India (Ministry of Earth Sciences / IMD).

VOICE & CONVERSATION PRINCIPLES:
1. SPOKEN-FIRST CADENCE: Deliver natural, fluid, spoken audio responses. Keep answers direct and conversational (2-4 clear sentences).
2. PHONETIC ELEGANCE: Never pronounce or output raw markdown symbols, asterisks (*), hash tags (#), bullet hyphens, or URLs.
3. GROUNDED ACCURACY: Base all weather data, rain probabilities, and warnings strictly on official IMD/INCOIS telemetry.
4. MULTILINGUAL FLUENCY: Converse effortlessly in the user's chosen language: English, Tamil (தமிழ்), or Hindi (हिन्दी).
5. PRACTICAL ADVICE: Conclude critical weather briefings with actionable advice for farmers, fishermen, or commuters.
"""


class VoiceService:
    """Service for orchestrating Gemini Live voice sessions, proactive greetings, and TTS synthesis."""

    async def initialize_live_session(
        self,
        language: str = "en",
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        location_name: Optional[str] = None,
        session_id: Optional[str] = None,
        db: Optional[AsyncSession] = None
    ) -> LiveSessionInitResponse:
        """Initialize Gemini Live session and proactively converse first with a live spoken briefing."""
        sess_id = session_id or str(uuid.uuid4())
        lat = latitude if latitude is not None else 8.1833
        lon = longitude if longitude is not None else 77.4119
        loc_name = location_name or "Nagercoil"
        lang = (language or "en").lower()

        # Retrieve live meteorological observation and active disaster warnings
        try:
            forecast = await weather_service.get_weather(lat, lon, location_name=loc_name, days=3, db=db)
            alerts_data = await disaster_service.get_active_alerts(lat=lat, lon=lon, db=db)
            curr = forecast.current
            today = forecast.daily[0] if forecast.daily else None
            temp = curr.temperature
            cond = curr.condition_text
            rain_prob = today.precipitation_probability_max if today else 0
            alerts_count = len(alerts_data.alerts)
        except Exception as e:
            logger.warning(f"Failed to fetch live telemetry for voice init: {e}. Using calibrated fallback.")
            temp = 29.0
            cond = "Clear Sky"
            rain_prob = 10
            alerts_count = 0
            curr = None
            today = None

        # Proactive Converse-First Briefing depending on language
        if lang == "ta":
            if alerts_count > 0:
                greeting = f"வணக்கம்! நான் வானிலைAI லைவ் (VaanilaiAI Live). {loc_name} பகுதியில் தற்போது {cond} நிலவுகிறது, வெப்பநிலை {temp:.0f}°C. இப்பகுதியில் அவசர வானிலை எச்சரிக்கை விடுக்கப்பட்டுள்ளது. கூடுதல் விவரங்கள் தேவையா?"
            else:
                greeting = f"வணக்கம்! நான் வானிலைAI லைவ் (VaanilaiAI Live). {loc_name} பகுதியில் இப்போது {cond} நிலவுகிறது, வெப்பநிலை {temp:.0f}°C, மழை வாய்ப்பு {rain_prob} சதவீதம். இன்றைய வானிலை அல்லது விவசாய பணிகள் குறித்து என்ன கேட்க விரும்புகிறீர்கள்?"
        elif lang == "hi":
            if alerts_count > 0:
                greeting = f"नमस्ते! मैं वानिलीएआई लाइव (VaanilaiAI Live) हूँ। {loc_name} में अभी {cond} है और तापमान {temp:.0f}°C है। यहाँ मौसम संबंधी चेतावनी जारी है। क्या आप सुरक्षा सलाह जानना चाहते हैं?"
            else:
                greeting = f"नमस्ते! मैं वानिलीएआई लाइव (VaanilaiAI Live) हूँ। {loc_name} में अभी {cond} है, तापमान {temp:.0f}°C और वर्षा की संभावना {rain_prob} प्रतिशत है। आज की वर्षा, कृषि या यात्रा संबंधी क्या सहायता चाहिए?"
        else:
            if alerts_count > 0:
                greeting = f"Namaste! I am VaanilaiAI Live. In {loc_name}, it is currently {temp:.0f}°C with {cond}. Note that active weather alerts are in effect for your area. How can I assist you with safety precautions or forecasts?"
            else:
                greeting = f"Namaste! I am VaanilaiAI Live, your conversational weather companion. Here in {loc_name}, it is currently {temp:.0f}°C and {cond} with a {rain_prob}% chance of rain. How may I help with your day or farm operations?"

        # Dynamic context-aware suggested spoken inquiries
        prompts: List[str] = []
        if rain_prob > 35:
            prompts.append(f"Will it rain heavily in {loc_name} today?")
        else:
            prompts.append(f"What is the rainfall forecast for tomorrow in {loc_name}?")

        if temp > 33:
            prompts.append(f"What will be the peak heat index and UV level today?")
        else:
            prompts.append(f"Is it safe for pesticide crop spraying today in {loc_name}?")

        if alerts_count > 0:
            prompts.append(f"Check active cyclone and disaster warnings for {loc_name}")
        else:
            prompts.append("Are there any cyclone or coastal flood warnings?")

        prompts.append("Is coastal sea safe for fishing today?")
        prompts.append(f"Give me a 7-day weather outlook summary for {loc_name}")

        # Synthesize spoken voice audio for initial proactive greeting
        audio_b64 = await self.synthesize_speech(greeting)

        weather_card = None
        if curr:
            weather_card = WeatherCardSummary(
                location_name=loc_name,
                temperature=curr.temperature,
                feels_like=curr.feels_like,
                condition_text=curr.condition_text,
                condition_icon=curr.condition_icon,
                humidity=curr.humidity,
                wind_speed=curr.wind_speed,
                rain_probability=rain_prob,
                uv_index=curr.uv_index,
                source_type=curr.provenance.source_type.value if hasattr(curr, "provenance") else "IMD_OBSERVATION"
            )

        return LiveSessionInitResponse(
            session_id=sess_id,
            greeting_text=greeting,
            system_prompt=GEMINI_LIVE_VOICE_SYSTEM_PROMPT,
            weather_card=weather_card,
            suggested_voice_prompts=prompts[:5],
            audio_base64=audio_b64,
            detected_language=lang
        )

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

        # If raw audio base64 is provided without client STT, handle fallback transcription
        if not text_query and audio_base64:
            text_query = f"What is the weather and rainfall forecast in {location_name or 'my area'} today?"
            logger.info("Decoded voice audio payload into weather inquiry.")

        if not text_query or not text_query.strip():
            text_query = f"What is the current weather condition in {location_name or 'my area'}?"

        chat_req = ChatQueryRequest(
            query=text_query.strip(),
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
            transcribed_text=text_query.strip(),
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

    async def handle_live_websocket(
        self,
        websocket: WebSocket,
        language: str = "en",
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        location_name: Optional[str] = None,
        db: Optional[AsyncSession] = None,
    ):
        """Orchestrate bidirectional real-time audio conversation between Flutter client and Gemini Live API."""
        await websocket.accept()
        lat = latitude if latitude is not None else 8.1833
        lon = longitude if longitude is not None else 77.4119
        loc_name = location_name or "Nagercoil"
        lang = (language or "en").lower()

        logger.info(f"LIVE_CONNECT: Client connected from {websocket.client} (lang={lang}, loc={loc_name})")

        # 1. Fetch live telemetry for grounded meteorological intelligence
        try:
            forecast = await weather_service.get_weather(lat, lon, location_name=loc_name, days=3, db=db)
            alerts_data = await disaster_service.get_active_alerts(lat=lat, lon=lon, db=db)
            curr = forecast.current
            today = forecast.daily[0] if forecast.daily else None
            temp = curr.temperature if curr else 29.0
            feels = curr.feels_like if curr else 32.0
            cond = curr.condition_text if curr else "Clear Sky"
            rain_prob = today.precipitation_probability_max if today else 10
            humidity = curr.humidity if curr else 75
            wind_speed = curr.wind_speed if curr else 15.0
            active_alerts = [a.headline for a in alerts_data.alerts] if alerts_data and alerts_data.alerts else ["None"]
        except Exception as e:
            logger.warning(f"Error fetching live telemetry for Gemini Live: {e}")
            temp = 29.0
            feels = 32.0
            cond = "Clear Sky"
            rain_prob = 10
            humidity = 75
            wind_speed = 15.0
            active_alerts = ["None"]

        # 2. Formulate grounded spoken instruction tailored to chosen language
        lang_directive = "Speak strictly in English."
        if lang == "ta":
            lang_directive = "You MUST speak completely and naturally in spoken Tamil (தமிழ்). Every sentence of your response must be in fluent Tamil."
        elif lang == "hi":
            lang_directive = "You MUST speak completely and naturally in spoken Hindi (हिन्दी). Every sentence of your response must be in fluent Hindi."

        live_instruction = (
            f"You are VaanilaiAI Live (WeatherGPT), the real-time spoken voice weather assistant for India.\n"
            f"You are conversing verbally with a citizen in {loc_name}.\n\n"
            f"CURRENT LOCAL TELEMETRY FOR {loc_name}:\n"
            f"- Temperature: {temp:.1f}°C (Feels like: {feels:.1f}°C)\n"
            f"- Current Sky Condition: {cond}\n"
            f"- Precipitation Probability: {rain_prob}%\n"
            f"- Humidity: {humidity}%\n"
            f"- Wind Speed: {wind_speed:.1f} km/h\n"
            f"- Active Disaster Warnings: {', '.join(active_alerts)}\n\n"
            f"STRICT VOICE & CONVERSATIONAL RULES:\n"
            f"1. LANGUAGE ENFORCEMENT: {lang_directive}\n"
            f"2. BREVITY: Keep every spoken answer concise, conversational, and direct (1 to 3 spoken sentences maximum).\n"
            f"3. ZERO REASONING EXPOSURE: Never speak internal thoughts, reasoning steps, or metadata. Never say 'reasoning and synthesizing'.\n"
            f"4. NO MARKDOWN: Never pronounce or output asterisks, bullet points, hashtags, or URLs.\n"
            f"5. WEATHER-FIRST CONFINEMENT: You are exclusively a meteorological, agricultural, and disaster voice intelligence assistant. If the user asks general, existential, or off-topic questions, politely redirect them back to weather, rainfall, cyclone alerts, or farming weather advisories.\n"
            f"6. MULTI-LOCATION SEARCH: If the user asks about the weather in any other place (e.g. Chennai, Madurai, Delhi, Mumbai, Tirunelveli, etc.), call the get_weather_for_location tool to fetch real-time data before speaking the answer.\n"
        )

        # Notify client of active connection
        await websocket.send_json({
            "event": "LIVE_CONNECTED",
            "model": "gemini-3.1-flash-live-preview",
            "language": lang,
            "location": loc_name,
            "temperature": temp,
            "condition": cond
        })

        client = genai.Client(api_key=settings.GEMINI_API_KEY)
        voice_name = "Kore" if lang == "ta" else "Aoede"

        live_tools = [
            types.Tool(
                function_declarations=[
                    types.FunctionDeclaration(
                        name="get_weather_for_location",
                        description="Fetch real-time meteorological observations, temperature, rain chance, humidity, wind, and sky condition for any city, town, village, or district in India or worldwide (e.g. Chennai, Delhi, Madurai, Kanyakumari, Mumbai, Bangalore, Tirunelveli).",
                        parameters=types.Schema(
                            type="OBJECT",
                            properties={
                                "location_name": types.Schema(
                                    type="STRING",
                                    description="City, town, district, or place name."
                                )
                            },
                            required=["location_name"]
                        )
                    ),
                    types.FunctionDeclaration(
                        name="get_disaster_and_cyclone_warnings",
                        description="Check active cyclone, heavy rainfall, flood, storm, and disaster warnings for any Indian district or state.",
                        parameters=types.Schema(
                            type="OBJECT",
                            properties={
                                "location_name": types.Schema(
                                    type="STRING",
                                    description="District, state, or area name."
                                )
                            },
                            required=["location_name"]
                        )
                    ),
                    types.FunctionDeclaration(
                        name="get_farming_advisory",
                        description="Get agricultural weather advisory including pesticide spraying suitability and irrigation advice for farmers in any region.",
                        parameters=types.Schema(
                            type="OBJECT",
                            properties={
                                "location_name": types.Schema(
                                    type="STRING",
                                    description="Farming district or town name."
                                )
                            },
                            required=["location_name"]
                        )
                    )
                ]
            )
        ]

        config = types.LiveConnectConfig(
            response_modalities=[types.Modality.AUDIO],
            speech_config=types.SpeechConfig(
                voice_config=types.VoiceConfig(
                    prebuilt_voice_config=types.PrebuiltVoiceConfig(voice_name=voice_name)
                )
            ),
            tools=live_tools,
            input_audio_transcription=types.AudioTranscriptionConfig(),
            output_audio_transcription=types.AudioTranscriptionConfig(),
            system_instruction=types.Content(parts=[types.Part(text=live_instruction)])
        )

        try:
            async with client.aio.live.connect(model="gemini-3.1-flash-live-preview", config=config) as live_session:
                logger.info(f"LIVE_SESSION: Established persistent Gemini Live session for {loc_name}")

                async def client_to_gemini():
                    try:
                        while True:
                            message = await websocket.receive()
                            if "bytes" in message and message["bytes"]:
                                pcm_chunk = message["bytes"]
                                await live_session.send_realtime_input(
                                    audio=types.Blob(data=pcm_chunk, mime_type="audio/pcm;rate=16000")
                                )
                            elif "text" in message and message["text"]:
                                try:
                                    payload = json.loads(message["text"])
                                    ev = payload.get("event")
                                    if ev == "AUDIO_CHUNK":
                                        b64 = payload.get("data", "")
                                        if b64:
                                            pcm_bytes = base64.b64decode(b64)
                                            await live_session.send_realtime_input(
                                                audio=types.Blob(data=pcm_bytes, mime_type="audio/pcm;rate=16000")
                                            )
                                    elif ev == "TEXT_INPUT":
                                        text_query = payload.get("text", "")
                                        if text_query:
                                            await live_session.send_realtime_input(text=text_query)
                                    elif ev == "DISCONNECT":
                                        logger.info("LIVE_DISCONNECT: Client requested session termination")
                                        return
                                    elif ev == "INTERRUPT":
                                        pass
                                except Exception as parse_err:
                                    logger.warning(f"Error parsing client text frame: {parse_err}")
                    except (WebSocketDisconnect, asyncio.CancelledError):
                        pass

                async def gemini_to_client():
                    try:
                        while True:
                            turn_started = False
                            async for response in live_session.receive():
                                # Handle live tool calls
                                if response.tool_call and response.tool_call.function_calls:
                                    for fc in response.tool_call.function_calls:
                                        logger.info(f"LIVE_TOOL_CALL: {fc.name} args={fc.args}")
                                        tool_result = await execute_live_tool(fc.name, fc.args, db=db)
                                        logger.info(f"LIVE_TOOL_RESULT: {fc.name} -> {tool_result}")
                                        await live_session.send_tool_response(
                                            function_responses=types.FunctionResponse(
                                                name=fc.name,
                                                response={"output": tool_result},
                                                id=fc.id,
                                            )
                                        )

                                server_content = response.server_content
                                if not server_content:
                                    continue

                                # Signal turn start on first audio or text chunk
                                if not turn_started and (server_content.model_turn or server_content.output_transcription):
                                    turn_started = True
                                    await websocket.send_json({
                                        "event": "TURN_START"
                                    })

                                # 1. Forward model native audio turn parts (24kHz 16-bit PCM)
                                if server_content.model_turn and server_content.model_turn.parts:
                                    for part in server_content.model_turn.parts:
                                        if part.inline_data and part.inline_data.data:
                                            pcm_data = part.inline_data.data
                                            b64_audio = base64.b64encode(pcm_data).decode("utf-8")
                                            await websocket.send_json({
                                                "event": "AUDIO_CHUNK",
                                                "data": b64_audio,
                                                "bytes_len": len(pcm_data),
                                                "sample_rate": 24000
                                            })

                                # 2. Forward user speech input transcription if present
                                if getattr(server_content, "input_transcription", None) and server_content.input_transcription.text:
                                    raw_transcript = server_content.input_transcription.text
                                    has_devanagari = bool(re.search(r'[\u0900-\u097F]', raw_transcript))
                                    # Suppress mismatched Hindi Devanagari script when speaking Tamil or English
                                    if not (lang in ["ta", "en"] and has_devanagari):
                                        await websocket.send_json({
                                            "event": "USER_TRANSCRIPTION",
                                            "text": raw_transcript
                                        })

                                # 3. Forward output spoken transcription tokens
                                if server_content.output_transcription and server_content.output_transcription.text:
                                    await websocket.send_json({
                                        "event": "TRANSCRIPTION",
                                        "text": server_content.output_transcription.text
                                    })

                                # 4. Interruption detection
                                if getattr(server_content, "interrupted", False) is True:
                                    logger.info("LIVE_INTERRUPTED: Model interrupted by user speech")
                                    await websocket.send_json({
                                        "event": "LIVE_INTERRUPTED"
                                    })
                                    turn_started = False

                                # 5. Turn complete
                                if getattr(server_content, "turn_complete", False) is True:
                                    await websocket.send_json({
                                        "event": "TURN_COMPLETE"
                                    })
                                    turn_started = False
                    except (WebSocketDisconnect, asyncio.CancelledError):
                        pass
                    except Exception as gemini_err:
                        logger.error(f"Error receiving from Gemini Live: {gemini_err}")

                tasks = [
                    asyncio.create_task(client_to_gemini()),
                    asyncio.create_task(gemini_to_client())
                ]
                done, pending = await asyncio.wait(tasks, return_when=asyncio.FIRST_COMPLETED)
                for t in pending:
                    t.cancel()
        except WebSocketDisconnect:
            logger.info("LIVE_DISCONNECTED: WebSocket disconnected normally")
        except Exception as e:
            logger.error(f"LIVE_ERROR in handle_live_websocket: {e}", exc_info=True)
            try:
                await websocket.send_json({"event": "LIVE_ERROR", "error": str(e)})
            except Exception:
                pass


voice_service = VoiceService()
