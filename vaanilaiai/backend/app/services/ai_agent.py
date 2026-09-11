"""Conversational AI Weather Intelligence Engine powered by Gemini & Tool-Calling."""
import json
import logging
import re
import uuid
from datetime import datetime, timezone
from typing import Dict, Any, List, Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.core.config import settings
from app.models.chat import Conversation, ChatMessage
from app.schemas.chat import (
    ChatQueryRequest,
    ChatQueryResponse,
    WeatherCardSummary,
)
from app.schemas.alert import DisasterAlertResponse
from app.services.location_service import location_service
from app.services.weather_service import weather_service
from app.services.disaster_service import disaster_service
from app.services.advisory_service import advisory_service
from app.services.climate_service import climate_service

logger = logging.getLogger(__name__)

SYSTEM_PROMPT = """You are VaanilaiAI (WeatherGPT), the premier real-time conversational AI weather intelligence and disaster management assistant for India (Ministry of Earth Sciences / India Meteorological Department).

CORE PRINCIPLES (ZERO HALLUCINATION & CLEAN FORMATTING):
1. ACCURACY: Base all weather observations, forecasts, alerts, and advisories exclusively on official meteorological data.
2. FORMATTING RULES:
   - Respond in concise, beautifully structured sentences with clear bullet points.
   - NEVER output messy triple asterisks '***' or unformatted markdown headers like '###'.
   - Use clean bold formatting like '**Temperature**' and clear emojis (• 🌡️, • 🌧️, • 💨, • 🌾, • 🚨).
   - Highlight exact numerical parameters (°C, km/h, mm, %).
   - Always respond in the requested language (English, Tamil தமிழ், or Hindi हिन्दी).
3. TONE: Warm, expert, reassuring, and practical for common citizens, farmers, and disaster responders.
"""


class ConversationalAIAgent:
    """Conversational AI agent that orchestrates meteorological tools with Gemini."""

    def __init__(self):
        self.gemini_client = None
        self._init_client()

    def _init_client(self):
        if settings.GEMINI_API_KEY:
            try:
                from google import genai
                self.gemini_client = genai.Client(api_key=settings.GEMINI_API_KEY)
                return self.gemini_client
            except Exception as e:
                logger.warning(f"Could not initialize google-genai client: {e}")
                return None
        return None

    def _get_client(self):
        if self.gemini_client is None:
            return self._init_client()
        return self.gemini_client

    def clean_markdown(self, text: str) -> str:
        """Strip messy repetitive asterisks and clean formatting."""
        if not text:
            return ""
        # Replace ***bold italic*** or multiple asterisks with clean **bold**
        cleaned = re.sub(r'\*{3,}(.*?)\*{3,}', r'**\1**', text)
        # Replace any remaining dangling *** with **
        cleaned = cleaned.replace('***', '**')
        # Clean markdown headers (### Header -> Header)
        cleaned = re.sub(r'#{1,6}\s*', '', cleaned)
        return cleaned.strip()

    async def execute_tool(self, tool_name: str, args: Dict[str, Any], db: Optional[AsyncSession] = None) -> Dict[str, Any]:
        """Execute backend meteorological tool safely."""
        logger.info(f"Executing tool '{tool_name}' with args: {args}")
        try:
            if tool_name == "search_indian_location":
                query = args.get("query", "")
                locs = await location_service.search_locations(query)
                return {"results": [loc.model_dump(mode="json") for loc in locs]}

            elif tool_name == "get_current_weather":
                lat = float(args.get("latitude", 13.0827))
                lon = float(args.get("longitude", 80.2707))
                loc_name = args.get("location_name", "Location")
                forecast = await weather_service.get_weather(lat, lon, location_name=loc_name, days=1, db=db)
                return forecast.model_dump(mode="json")

            elif tool_name == "get_weather_forecast":
                lat = float(args.get("latitude", 13.0827))
                lon = float(args.get("longitude", 80.2707))
                loc_name = args.get("location_name", "Location")
                days = int(args.get("days", 7))
                forecast = await weather_service.get_weather(lat, lon, location_name=loc_name, days=days, db=db)
                return forecast.model_dump(mode="json")

            elif tool_name == "get_disaster_warnings":
                district = args.get("district")
                state = args.get("state")
                lat = float(args.get("latitude")) if args.get("latitude") is not None else None
                lon = float(args.get("longitude")) if args.get("longitude") is not None else None
                alerts_summary = await disaster_service.get_active_alerts(lat=lat, lon=lon, district=district, state=state, db=db)
                return alerts_summary.model_dump(mode="json")

            elif tool_name == "get_agricultural_advisory":
                lat = float(args.get("latitude", 13.0827))
                lon = float(args.get("longitude", 80.2707))
                loc_name = args.get("location_name", "Location")
                district = args.get("district")
                adv = await advisory_service.get_agriculture_advisory(lat, lon, location_name=loc_name, district=district)
                return adv.model_dump(mode="json")

            elif tool_name == "get_travel_advisory":
                lat = float(args.get("latitude", 13.0827))
                lon = float(args.get("longitude", 80.2707))
                loc_name = args.get("location_name", "Location")
                district = args.get("district")
                adv = await advisory_service.get_travel_advisory(lat, lon, location_name=loc_name, district=district)
                return adv.model_dump(mode="json")

            elif tool_name == "get_climate_history_comparison":
                lat = float(args.get("latitude", 13.0827))
                lon = float(args.get("longitude", 80.2707))
                loc_name = args.get("location_name", "Location")
                y1 = int(args.get("year_1", 2022))
                y2 = int(args.get("year_2", 2023))
                comp = await climate_service.compare_years(lat, lon, location_name=loc_name, year_1=y1, year_2=y2)
                return comp.model_dump(mode="json")

            else:
                return {"error": f"Unknown tool '{tool_name}'"}
        except Exception as e:
            logger.error(f"Error executing tool {tool_name}: {e}")
    async def _persist_chat(
        self,
        db: Optional[AsyncSession],
        session_id: str,
        query: str,
        resp_text: str,
        lang: str,
        loc_name: str,
        tools_used: List[str],
        citations: List[str]
    ) -> None:
        """Persist conversation and messages to SQLite database if session is active."""
        if db is not None:
            try:
                stmt = select(Conversation).where(Conversation.session_id == session_id)
                res = await db.execute(stmt)
                conv = res.scalars().first()
                if not conv:
                    conv = Conversation(
                        session_id=session_id,
                        title=f"{loc_name} - {query[:30]}",
                        language=lang
                    )
                    db.add(conv)
                    await db.flush()

                u_msg = ChatMessage(
                    conversation_id=conv.id,
                    role="user",
                    content=query,
                    language=lang
                )
                db.add(u_msg)

                a_msg = ChatMessage(
                    conversation_id=conv.id,
                    role="assistant",
                    content=resp_text,
                    language=lang,
                    tool_calls=tools_used,
                    grounded_citations=citations
                )
                db.add(a_msg)
                await db.flush()
                await db.commit()
            except Exception as e:
                logger.warning(f"Error persisting chat message: {e}")

    async def process_chat(
        self,
        request: ChatQueryRequest,
        db: Optional[AsyncSession] = None
    ) -> ChatQueryResponse:
        """Process user's natural language question and return grounded meteorological response."""
        session_id = request.session_id or str(uuid.uuid4())
        lang = request.language or "en"
        query = request.query.strip()

        # Resolve location context
        lat = request.latitude
        lon = request.longitude
        loc_name = request.location_name

        # If location_name is not provided, try to recover from session history
        if not loc_name and request.session_id and db is not None:
            try:
                stmt = select(Conversation).where(Conversation.session_id == request.session_id)
                res = await db.execute(stmt)
                conv = res.scalars().first()
                if conv and conv.title:
                    candidate_loc = conv.title.split(" - ")[0].strip()
                    if candidate_loc and candidate_loc not in ["Location", "Weather Query"]:
                        loc_name = candidate_loc
            except Exception as e:
                logger.warning(f"Error fetching location from conversation history: {e}")

        if (lat is None or lon is None or not loc_name) and query:
            search_res = await location_service.search_locations(query)
            if search_res:
                top_match = search_res[0]
                if lat is None or lon is None:
                    lat = top_match.latitude
                    lon = top_match.longitude
                if not loc_name:
                    loc_name = top_match.name

        # Default Indian coordinate fallback
        if lat is None or lon is None:
            lat = 8.1833
            lon = 77.4119
        
        if not loc_name:
            loc_name = "Nagercoil"

        # Try live Gemini models down the free priority ladder
        client = self._get_client()
        if client and settings.GEMINI_API_KEY:
            models_to_try: List[str] = []
            if settings.GEMINI_MODEL and settings.GEMINI_MODEL not in models_to_try:
                models_to_try.append(settings.GEMINI_MODEL)
            if settings.GEMINI_FALLBACK_MODEL and settings.GEMINI_FALLBACK_MODEL not in models_to_try:
                models_to_try.append(settings.GEMINI_FALLBACK_MODEL)
            for m in settings.AVAILABLE_FREE_MODELS:
                if m not in models_to_try:
                    models_to_try.append(m)

            for model_name in models_to_try:
                try:
                    ai_resp = await self._run_gemini_agent(
                        query=query,
                        lang=lang,
                        lat=lat,
                        lon=lon,
                        loc_name=loc_name,
                        session_id=session_id,
                        model_name=model_name,
                        client=client,
                        db=db
                    )
                    await self._persist_chat(
                        db=db,
                        session_id=session_id,
                        query=query,
                        resp_text=ai_resp.response_text,
                        lang=lang,
                        loc_name=loc_name,
                        tools_used=ai_resp.tools_used,
                        citations=ai_resp.citations
                    )
                    return ai_resp
                except Exception as e:
                    logger.warning(f"Model {model_name} failed: {e}. Trying next available free model.")
                    continue

        # Fallback to Grounded Deterministic Intelligence Engine
        ai_resp = await self._run_grounded_engine(query, lang, lat, lon, loc_name, session_id, db)
        await self._persist_chat(
            db=db,
            session_id=session_id,
            query=query,
            resp_text=ai_resp.response_text,
            lang=lang,
            loc_name=loc_name,
            tools_used=ai_resp.tools_used,
            citations=ai_resp.citations
        )
        return ai_resp

    async def _run_gemini_agent(
        self,
        query: str,
        lang: str,
        lat: float,
        lon: float,
        loc_name: str,
        session_id: str,
        model_name: str,
        client: Optional[Any] = None,
        db: Optional[AsyncSession] = None
    ) -> ChatQueryResponse:
        """Execute Gemini with Grounded Weather Data."""
        loc_name = loc_name or "Location"
        # Pre-fetch live meteorological telemetry
        forecast = await weather_service.get_weather(lat, lon, location_name=loc_name, days=7, db=db)
        alerts_data = await disaster_service.get_active_alerts(lat=lat, lon=lon, db=db)
        
        curr = forecast.current
        today = forecast.daily[0] if forecast.daily else None
        tomorrow = forecast.daily[1] if len(forecast.daily) > 1 else today

        aq_info = {}
        if forecast.air_quality:
            aq_info = {
                "aqi": forecast.air_quality.aqi,
                "category": forecast.air_quality.category,
                "pm2_5": f"{forecast.air_quality.pm2_5:.1f} µg/m³",
                "pm10": f"{forecast.air_quality.pm10:.1f} µg/m³"
            }

        context_data = {
            "location": loc_name,
            "latitude": lat,
            "longitude": lon,
            "current_weather": {
                "temperature": f"{curr.temperature:.1f}°C",
                "feels_like": f"{curr.feels_like:.1f}°C",
                "condition": curr.condition_text,
                "humidity": f"{curr.humidity}%",
                "wind_speed": f"{curr.wind_speed:.1f} km/h",
                "uv_index": curr.uv_index
            },
            "today_forecast": {
                "temp_min": f"{today.temp_min:.0f}°C" if today else f"{curr.temperature:.0f}°C",
                "temp_max": f"{today.temp_max:.0f}°C" if today else f"{curr.temperature:.0f}°C",
                "rain_probability": f"{today.precipitation_probability_max}%" if today else "0%",
                "rain_mm": f"{today.precipitation_sum:.1f} mm" if today else "0 mm",
                "condition": today.condition_text if today else curr.condition_text
            },
            "tomorrow_forecast": {
                "temp_min": f"{tomorrow.temp_min:.0f}°C" if tomorrow else f"{curr.temperature:.0f}°C",
                "temp_max": f"{tomorrow.temp_max:.0f}°C" if tomorrow else f"{curr.temperature:.0f}°C",
                "rain_probability": f"{tomorrow.precipitation_probability_max}%" if tomorrow else "0%",
                "rain_mm": f"{tomorrow.precipitation_sum:.1f} mm" if tomorrow else "0 mm",
                "condition": tomorrow.condition_text if tomorrow else curr.condition_text
            },
            "air_quality": aq_info,
            "active_disaster_alerts": [a.model_dump(mode="json") for a in alerts_data.alerts]
        }

        history_snippet = ""
        if db is not None and session_id:
            try:
                stmt = (
                    select(ChatMessage)
                    .join(Conversation)
                    .where(Conversation.session_id == session_id)
                    .order_by(ChatMessage.created_at.desc())
                    .limit(6)
                )
                res = await db.execute(stmt)
                past_messages = list(reversed(res.scalars().all()))
                if past_messages:
                    history_lines = [f"{m.role.upper()}: {m.content}" for m in past_messages]
                    history_snippet = "Recent Conversation Context:\n" + "\n".join(history_lines) + "\n\n"
            except Exception as e:
                logger.warning(f"Could not load conversation history: {e}")

        prompt = (
            f"User Location: {loc_name}\n"
            f"Target Language: {lang}\n"
            f"{history_snippet}"
            f"Current User Query: {query}\n\n"
            f"Official Grounded Meteorological Data:\n{json.dumps(context_data, indent=2)}\n\n"
            f"Instructions:\n"
            f"- Answer the user's inquiry directly, accurately, and naturally in {lang}.\n"
            f"- If the user asks a follow-up referring to the conversation context, resolve it seamlessly.\n"
            f"- Use clean bullet points with emojis for readability.\n"
            f"- DO NOT use raw '***' or hash markdown headers. Keep text elegant.\n"
            f"- Provide practical, actionable advice for citizens or farmers."
        )
        
        client = client or self._get_client()
        raw_text = None
        try:
            interaction = await client.aio.interactions.create(
                model=model_name,
                input=f"{SYSTEM_PROMPT}\n\n{prompt}"
            )
            raw_text = interaction.output_text
        except Exception as ex:
            logger.info(f"Interactions API fallback ({ex}), using generate_content...")
            import asyncio
            response = await asyncio.to_thread(
                client.models.generate_content,
                model=model_name,
                contents=[prompt],
                config={
                    "system_instruction": SYSTEM_PROMPT,
                    "temperature": 0.2
                }
            )
            raw_text = response.text or "Weather information retrieved."

        raw_text = raw_text or "Weather information retrieved."
        resp_text = self.clean_markdown(raw_text)
        
        weather_card = WeatherCardSummary(
            location_name=loc_name,
            temperature=curr.temperature,
            feels_like=curr.feels_like,
            condition_text=curr.condition_text,
            condition_icon=curr.condition_icon,
            humidity=curr.humidity,
            wind_speed=curr.wind_speed,
            rain_probability=today.precipitation_probability_max if today else 0,
            uv_index=curr.uv_index,
            source_type=curr.provenance.source_type.value
        )
        
        return ChatQueryResponse(
            session_id=session_id,
            response_text=resp_text,
            language=lang,
            intent="gemini_agent_query",
            detected_location=loc_name,
            weather_card=weather_card,
            active_alerts=alerts_data.alerts,
            citations=[f"Google {model_name}", "India Meteorological Department (IMD)", "ECMWF High-Resolution 2.5km"],
            tools_used=["get_weather_forecast", "get_disaster_warnings"],
            created_at=datetime.now(timezone.utc)
        )

    async def _run_grounded_engine(
        self,
        query: str,
        lang: str,
        lat: float,
        lon: float,
        loc_name: str,
        session_id: str,
        db: Optional[AsyncSession] = None
    ) -> ChatQueryResponse:
        """Grounded fallback engine when offline or testing without LLM API key."""
        loc_name = loc_name or "Location"
        q_lower = query.lower()
        tools_used: List[str] = []
        citations: List[str] = ["India Meteorological Department (IMD)", "ECMWF High-Resolution NWP 2.5km Grid"]
        weather_card: Optional[WeatherCardSummary] = None
        alerts_list: List[DisasterAlertResponse] = []
        advisory_summary: Optional[str] = None
        intent: str = "weather_forecast"
        
        # 1. Check if Agri / Spraying query
        if any(w in q_lower for w in ["spray", "pesticide", "fertilizer", "crop", "farm", "விவசாய", "மருந்து", "பயிர்", "छिड़काव", "फसल", "खेती"]):
            tools_used.append("get_agricultural_advisory")
            adv = await advisory_service.get_agriculture_advisory(lat, lon, location_name=loc_name)
            advisory_summary = f"Spraying is {adv.spraying_suitability}. {adv.spraying_reason}"
            
            if lang == "ta":
                resp_text = (
                    f"🌾 **{loc_name} விவசாய ஆலோசனை**:\n\n"
                    f"• **பூச்சிக்கொல்லி தெளிக்கும் நிலை**: **{adv.spraying_suitability}**\n"
                    f"• **காரணம்**: {adv.spraying_reason}\n"
                    f"• **பாசன வழிகாட்டல்**: {adv.irrigation_advice}\n"
                    f"• **24 மணிநேர மழை அளவு**: {adv.rain_risk_24h_mm:.1f} மி.மீ (அபாயம்: {adv.rain_risk_level})"
                )
            elif lang == "hi":
                resp_text = (
                    f"🌾 **{loc_name} कृषि मौसम सलाह**:\n\n"
                    f"• **कीटनाशक छिड़काव**: **{adv.spraying_suitability}**\n"
                    f"• **कारण**: {adv.spraying_reason}\n"
                    f"• **सिंचाई सलाह**: {adv.irrigation_advice}\n"
                    f"• **24 घंटे में वर्षा अनुमान**: {adv.rain_risk_24h_mm:.1f} मिमी (जोखिम: {adv.rain_risk_level})"
                )
            else:
                resp_text = (
                    f"🌾 **Agricultural Advisory for {loc_name}**:\n\n"
                    f"• **Spraying Suitability**: **{adv.spraying_suitability}**\n"
                    f"• **Analysis**: {adv.spraying_reason}\n"
                    f"• **Irrigation Advice**: {adv.irrigation_advice}\n"
                    f"• **24h Rainfall Expected**: {adv.rain_risk_24h_mm:.1f} mm ({adv.rain_risk_level} Risk)"
                )
            intent = "agricultural_advisory"

        # 2. Check if Travel query
        elif any(w in q_lower for w in ["travel", "trip", "road", "drive", "flight", "பயணம்", "ரோடு", "यात्रा", "सफर", "सड़क"]):
            tools_used.append("get_travel_advisory")
            t_adv = await advisory_service.get_travel_advisory(lat, lon, location_name=loc_name)
            advisory_summary = f"Travel suitability is {t_adv.overall_suitability} (Risk Score: {t_adv.travel_risk_score}/100)"
            
            if lang == "ta":
                resp_text = (
                    f"🚗 **{loc_name} பயண வானிலை நிலவரம்**:\n\n"
                    f"• **பயணப் பாதுகாப்பு நிலை**: **{t_adv.overall_suitability}** (அபாயக் குறியீடு: {t_adv.travel_risk_score}/100)\n"
                    f"• **பார்வைத் திறன் (Visibility)**: {t_adv.visibility_condition}\n"
                    f"• **சாலை நிலை**: {t_adv.road_safety_condition}\n"
                    f"• **பரிந்துரை**: {t_adv.safety_recommendations[0] if t_adv.safety_recommendations else 'பயணம் செய்யலாம்.'}"
                )
            elif lang == "hi":
                resp_text = (
                    f"🚗 **{loc_name} यात्रा मौसम सलाह**:\n\n"
                    f"• **यात्रा उपयुक्तता**: **{t_adv.overall_suitability}** (जोखिम स्कोर: {t_adv.travel_risk_score}/100)\n"
                    f"• **दृश्यता (Visibility)**: {t_adv.visibility_condition}\n"
                    f"• **सड़क सुरक्षा**: {t_adv.road_safety_condition}\n"
                    f"• **सलाह**: {t_adv.safety_recommendations[0] if t_adv.safety_recommendations else 'यात्रा सुरक्षित है।'}"
                )
            else:
                resp_text = (
                    f"🚗 **Travel Advisory for {loc_name}**:\n\n"
                    f"• **Travel Condition**: **{t_adv.overall_suitability}** (Risk Score: {t_adv.travel_risk_score}/100)\n"
                    f"• **Visibility**: {t_adv.visibility_condition}\n"
                    f"• **Road Safety**: {t_adv.road_safety_condition}\n"
                    f"• **Key Safety Note**: {t_adv.safety_recommendations[0] if t_adv.safety_recommendations else 'Conditions are clear for travel.'}"
                )
            intent = "travel_advisory"

        # 3. Check if Warning / Disaster query
        elif any(w in q_lower for w in ["warning", "alert", "cyclone", "flood", "disaster", "புயல்", "எச்சரிக்கை", "வெள்ளம்", "चेतावनी", "चक्रवात", "बाढ़"]):
            tools_used.append("get_disaster_warnings")
            alerts_data = await disaster_service.get_active_alerts(lat=lat, lon=lon, db=db)
            alerts_list = alerts_data.alerts
            if alerts_data.total_active_alerts > 0:
                top_a = alerts_data.alerts[0]
                if lang == "ta":
                    resp_text = (
                        f"🚨 **வானிலை எச்சரிக்கை: {top_a.headline}**\n\n"
                        f"• **அபாய நிலை**: **{top_a.severity.value}** ({top_a.category})\n"
                        f"• **விளக்கம்**: {top_a.description}\n"
                        f"• **பாதுகாப்பு அறிவுரை**: {top_a.instruction or 'அரசு பேரிடர் மேலாண்மை வழிகாட்டுதல்களைப் பின்பற்றவும்.'}"
                    )
                elif lang == "hi":
                    resp_text = (
                        f"🚨 **मौसम चेतावनी: {top_a.headline}**\n\n"
                        f"• **गंभीरता**: **{top_a.severity.value}** ({top_a.category})\n"
                        f"• **विवरण**: {top_a.description}\n"
                        f"• **सुरक्षा सलाह**: {top_a.instruction or 'राष्ट्रीय आपदा प्रबंधन दिशानिर्देशों का पालन करें।'}"
                    )
                else:
                    resp_text = (
                        f"🚨 **Weather Alert: {top_a.headline}**\n\n"
                        f"• **Severity Level**: **{top_a.severity.value.upper()}** ({top_a.category})\n"
                        f"• **Area**: {top_a.area_description}\n"
                        f"• **Description**: {top_a.description}\n"
                        f"• **Safety Protocol**: {top_a.instruction or 'Stay indoors and follow local authorities guidelines.'}"
                    )
            else:
                if lang == "ta":
                    resp_text = f"✅ **{loc_name} பகுதியில் தற்போது தீவிர வானிலை அல்லது புயல் எச்சரிக்கைகள் ஏதுமில்லை.** வானிலை இயல்பாக உள்ளது."
                elif lang == "hi":
                    resp_text = f"✅ **{loc_name} क्षेत्र के लिए वर्तमान में कोई गंभीर चक्रवात या आपदा चेतावनी नहीं है।** मौसम स्थिर है।"
                else:
                    resp_text = f"✅ **No active severe weather warnings or disaster alerts for {loc_name}.** Atmospheric conditions are stable."
            intent = "disaster_alert"

        # 4. Standard Weather & Forecast query
        else:
            tools_used.append("get_weather_forecast")
            forecast = await weather_service.get_weather(lat, lon, location_name=loc_name, days=7, db=db)
            curr = forecast.current
            daily = forecast.daily
            
            is_tomorrow = any(w in q_lower for w in ["tomorrow", "நாளை", "कल"])
            target_d = daily[1] if (is_tomorrow and len(daily) > 1) else daily[0]
            day_title = "Tomorrow" if is_tomorrow else "Today"
            
            if lang == "ta":
                day_title_ta = "நாளை" if is_tomorrow else "இன்று"
                resp_text = (
                    f"🌤️ **{loc_name} {day_title_ta} வானிலை நிலவரம்**:\n\n"
                    f"• **வானிலை நிலை**: {target_d.condition_text}\n"
                    f"• **வெப்பநிலை**: {target_d.temp_min:.0f}°C முதல் {target_d.temp_max:.0f}°C வரை (தற்போது: {curr.temperature:.0f}°C)\n"
                    f"• **மழை வாய்ப்பு**: **{target_d.precipitation_probability_max}%** (மழை அளவு: {target_d.precipitation_sum:.1f} மி.மீ)\n"
                    f"• **காற்றின் வேகம்**: {curr.wind_speed:.0f} கி.மீ/மணி | **ஈரப்பதம்**: {curr.humidity}%\n"
                    f"• **காற்றுத் தரம் (AQI)**: {forecast.air_quality.aqi} ({forecast.air_quality.category})"
                )
            elif lang == "hi":
                day_title_hi = "कल" if is_tomorrow else "आज"
                resp_text = (
                    f"🌤️ **{loc_name} {day_title_hi} का मौसम पूर्वानुमान**:\n\n"
                    f"• **स्थिति**: {target_d.condition_text}\n"
                    f"• **तापमान**: {target_d.temp_min:.0f}°C से {target_d.temp_max:.0f}°C (वर्तमान: {curr.temperature:.0f}°C)\n"
                    f"• **बारिश की संभावना**: **{target_d.precipitation_probability_max}%** (वर्षा: {target_d.precipitation_sum:.1f} मिमी)\n"
                    f"• **हवा की गति**: {curr.wind_speed:.0f} किमी/घंटा | **नमी**: {curr.humidity}%\n"
                    f"• **वायु गुणवत्ता (AQI)**: {forecast.air_quality.aqi} ({forecast.air_quality.category})"
                )
            else:
                resp_text = (
                    f"🌤️ **Weather Forecast for {loc_name} ({day_title})**:\n\n"
                    f"• **Condition**: {target_d.condition_text}\n"
                    f"• **Temperature**: {target_d.temp_min:.0f}°C to {target_d.temp_max:.0f}°C (Feels like {curr.feels_like:.0f}°C)\n"
                    f"• **Rain Probability**: **{target_d.precipitation_probability_max}%** (Precipitation: {target_d.precipitation_sum:.1f} mm)\n"
                    f"• **Wind Speed**: {curr.wind_speed:.0f} km/h | **Humidity**: {curr.humidity}%\n"
                    f"• **Air Quality (AQI)**: {forecast.air_quality.aqi} ({forecast.air_quality.category})"
                )
            
            weather_card = WeatherCardSummary(
                location_name=loc_name,
                temperature=curr.temperature,
                feels_like=curr.feels_like,
                condition_text=curr.condition_text,
                condition_icon=curr.condition_icon,
                humidity=curr.humidity,
                wind_speed=curr.wind_speed,
                rain_probability=target_d.precipitation_probability_max,
                uv_index=curr.uv_index,
                source_type=curr.provenance.source_type.value
            )

        resp_text = self.clean_markdown(resp_text)

        return ChatQueryResponse(
            session_id=session_id,
            response_text=resp_text,
            language=lang,
            intent=intent,
            detected_location=loc_name,
            weather_card=weather_card,
            active_alerts=alerts_list,
            advisory_summary=advisory_summary,
            citations=citations,
            tools_used=tools_used,
            created_at=datetime.now(timezone.utc)
        )


ai_agent = ConversationalAIAgent()
