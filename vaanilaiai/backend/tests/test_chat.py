"""Test conversational AI WeatherGPT chat and multilingual capabilities."""
import pytest


@pytest.mark.asyncio
async def test_chat_english_weather_query(client):
    payload = {
        "query": "What is the weather in Nagercoil today?",
        "language": "en",
        "latitude": 8.1833,
        "longitude": 77.4119,
        "location_name": "Nagercoil"
    }
    response = await client.post("/api/v1/chat/message", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert "response_text" in data
    assert len(data["response_text"]) > 0
    assert data["language"] == "en"
    assert data["weather_card"] is not None
    assert "Nagercoil" in data["weather_card"]["location_name"]
    assert "tools_used" in data


@pytest.mark.asyncio
async def test_chat_tamil_query(client):
    payload = {
        "query": "நாளை மழை வருமா?",
        "language": "ta",
        "latitude": 9.9252,
        "longitude": 78.1198,
        "location_name": "Madurai"
    }
    response = await client.post("/api/v1/chat/message", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["language"] == "ta"
    assert "வானிலை" in data["response_text"] or "மழை" in data["response_text"]


@pytest.mark.asyncio
async def test_chat_hindi_agri_query(client):
    payload = {
        "query": "क्या कल कीटनाशक का छिड़काव करना ठीक रहेगा?",
        "language": "hi",
        "latitude": 25.3176,
        "longitude": 82.9739,
        "location_name": "Varanasi"
    }
    response = await client.post("/api/v1/chat/message", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["language"] == "hi"
    assert "छिड़काव" in data["response_text"] or "कृषि" in data["response_text"]


@pytest.mark.asyncio
async def test_chat_history(client):
    session_id = "test-session-12345"
    payload = {
        "query": "Is it safe to travel to Wayanad?",
        "session_id": session_id,
        "language": "en",
        "latitude": 11.6854,
        "longitude": 76.1320,
        "location_name": "Wayanad"
    }
    chat_resp = await client.post("/api/v1/chat/message", json=payload)
    assert chat_resp.status_code == 200

    hist_resp = await client.get(f"/api/v1/chat/history/{session_id}")
    assert hist_resp.status_code == 200
    history = hist_resp.json()
    assert len(history) >= 2  # user message and assistant message
    assert history[0]["role"] == "user"
    assert history[1]["role"] == "assistant"
