"""Test Gemini Live voice initialization, proactive converse-first greeting, and voice query endpoints."""
import pytest


@pytest.mark.asyncio
async def test_voice_init_english(client):
    payload = {
        "language": "en",
        "latitude": 13.0827,
        "longitude": 80.2707,
        "location_name": "Chennai"
    }
    resp = await client.post("/api/v1/voice/init", json=payload)
    assert resp.status_code == 200
    data = resp.json()
    assert "session_id" in data
    assert "greeting_text" in data
    assert "Chennai" in data["greeting_text"] or "Namaste" in data["greeting_text"]
    assert "system_prompt" in data
    assert "suggested_voice_prompts" in data
    assert len(data["suggested_voice_prompts"]) > 0


@pytest.mark.asyncio
async def test_voice_init_tamil(client):
    payload = {
        "language": "ta",
        "latitude": 9.9252,
        "longitude": 78.1198,
        "location_name": "Madurai"
    }
    resp = await client.post("/api/v1/voice/init", json=payload)
    assert resp.status_code == 200
    data = resp.json()
    assert "வணக்கம்" in data["greeting_text"] or "Madurai" in data["greeting_text"]
    assert data["detected_language"] == "ta"


@pytest.mark.asyncio
async def test_voice_init_hindi(client):
    payload = {
        "language": "hi",
        "latitude": 28.6139,
        "longitude": 77.2090,
        "location_name": "New Delhi"
    }
    resp = await client.post("/api/v1/voice/init", json=payload)
    assert resp.status_code == 200
    data = resp.json()
    assert "नमस्ते" in data["greeting_text"] or "Delhi" in data["greeting_text"]
    assert data["detected_language"] == "hi"


@pytest.mark.asyncio
async def test_voice_query_spoken_flow(client):
    payload = {
        "transcription": "Will it rain in Chennai today?",
        "language": "en",
        "latitude": 13.0827,
        "longitude": 80.2707,
        "location_name": "Chennai"
    }
    resp = await client.post("/api/v1/voice/query", json=payload)
    assert resp.status_code == 200
    data = resp.json()
    assert "chat_response" in data
    assert data["chat_response"]["response_text"] is not None
