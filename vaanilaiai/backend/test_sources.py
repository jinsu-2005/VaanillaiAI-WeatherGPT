import asyncio
import httpx
import time
import os
import json
from dotenv import load_dotenv

# Load env variables
load_dotenv()

async def probe_all_sources():
    sources = [
        {
            "name": "IMD / NDMA Sachet CAP Alerts",
            "category": "Official Disaster & Weather Alerts",
            "method": "POST",
            "url": "https://sachet.ndma.gov.in/cap_public_website/FetchAllAlertDetails",
            "headers": {"User-Agent": "Mozilla/5.0"},
            "data": None,
        },
        {
            "name": "Open-Meteo NWP Forecast (ECMWF/GFS)",
            "category": "Numerical Weather Prediction",
            "method": "GET",
            "url": "https://api.open-meteo.com/v1/forecast?latitude=13.0827&longitude=80.2707&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&hourly=temperature_2m&daily=temperature_2m_max,temperature_2m_min&timezone=auto",
            "headers": None,
            "data": None,
        },
        {
            "name": "Open-Meteo Air Quality (NAQI)",
            "category": "Atmospheric Composition & AQI",
            "method": "GET",
            "url": "https://air-quality-api.open-meteo.com/v1/air-quality?latitude=13.0827&longitude=80.2707&current=pm2_5,pm10,us_aqi,european_aqi&hourly=pm2_5&timezone=auto",
            "headers": None,
            "data": None,
        },
        {
            "name": "Open-Meteo Geocoding",
            "category": "Location Search & Reverse Geocode",
            "method": "GET",
            "url": "https://geocoding-api.open-meteo.com/v1/search?name=Chennai&count=1&format=json",
            "headers": None,
            "data": None,
        },
        {
            "name": "Open-Meteo Historical Archive (ERA5)",
            "category": "Climate Reanalysis & Baseline",
            "method": "GET",
            "url": "https://archive-api.open-meteo.com/v1/archive?latitude=13.0827&longitude=80.2707&start_date=2023-01-01&end_date=2023-01-07&daily=temperature_2m_mean&timezone=auto",
            "headers": None,
            "data": None,
        },
        {
            "name": "RainViewer Doppler Radar Metadata",
            "category": "Live Radar Imagery",
            "method": "GET",
            "url": "https://api.rainviewer.com/public/weather-maps.json",
            "headers": None,
            "data": None,
        },
        {
            "name": "CartoDB Positron Basemap Tiles",
            "category": "Interactive Map Base Layer",
            "method": "GET",
            "url": "https://basemaps.cartocdn.com/light_all/6/46/29.png",
            "headers": None,
            "data": None,
        }
    ]

    print("=" * 80)
    print("      METEOROLOGICAL SOURCES HEALTH CHECK & LIVE STATUS PROBE")
    print("=" * 80)

    radar_tile_test_url = None

    async with httpx.AsyncClient(timeout=12.0, follow_redirects=True) as client:
        for s in sources:
            t0 = time.time()
            try:
                if s["method"] == "POST":
                    resp = await client.post(s["url"], data=s["data"], headers=s["headers"])
                else:
                    resp = await client.get(s["url"], headers=s["headers"])
                elapsed = (time.time() - t0) * 1000

                status = "OK (200)" if resp.status_code == 200 else f"HTTP {resp.status_code}"
                extra = ""

                if "FetchAllAlertDetails" in s["url"] and resp.status_code == 200:
                    raw = resp.json()
                    extra = f"[{len(raw)} active alerts nationwide]"
                elif "weather-maps.json" in s["url"] and resp.status_code == 200:
                    data = resp.json()
                    past = data.get("radar", {}).get("past", [])
                    host = data.get("host", "https://tilecache.rainviewer.com")
                    if past:
                        latest_path = past[-1]["path"]
                        radar_tile_test_url = f"{host}{latest_path}/256/6/46/29/2/1_1.png"
                    extra = f"[{len(past)} radar frames available, host: {host}]"
                elif "forecast" in s["url"] and resp.status_code == 200:
                    cur = resp.json().get("current", {})
                    extra = f"[Temp: {cur.get('temperature_2m')}°C, Code: {cur.get('weather_code')}]"
                elif "air-quality" in s["url"] and resp.status_code == 200:
                    cur = resp.json().get("current", {})
                    extra = f"[PM2.5: {cur.get('pm2_5')} µg/m³, AQI: {cur.get('us_aqi')}]"
                elif "search" in s["url"] and resp.status_code == 200:
                    res = resp.json().get("results", [])
                    loc = res[0]["name"] if res else "None"
                    extra = f"[Resolved: {loc}]"

                print(f"[{status:^10}] {s['name']:<38} | {elapsed:6.1f} ms | {extra}")
            except Exception as exc:
                print(f"[  ERROR   ] {s['name']:<38} | Exception: {exc}")

        # Test RainViewer Tile Cache directly
        if radar_tile_test_url:
            t0 = time.time()
            try:
                resp = await client.get(radar_tile_test_url)
                elapsed = (time.time() - t0) * 1000
                status = "OK (200)" if resp.status_code == 200 else f"HTTP {resp.status_code}"
                print(f"[{status:^10}] {'RainViewer Live Radar Tile Stream':<38} | {elapsed:6.1f} ms | [{len(resp.content)} bytes tile PNG]")
            except Exception as exc:
                print(f"[  ERROR   ] {'RainViewer Live Radar Tile Stream':<38} | Exception: {exc}")

    # Test Google Gemini AI Models
    print("-" * 80)
    print("Testing Google Gemini Meteorological Advisory Engine...")
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        print("[  SKIPPED ] Gemini API Key not set in environment.")
        return

    try:
        from google import genai
        ai_client = genai.Client(api_key=api_key)
        for model_id in ["gemini-3.5-flash-lite", "gemini-3.6-flash"]:
            t0 = time.time()
            try:
                response = ai_client.models.generate_content(
                    model=model_id,
                    contents="In 1 sentence, summarize weather in Chennai at 32C with high humidity."
                )
                elapsed = (time.time() - t0) * 1000
                reply_snippet = response.text.strip().replace("\n", " ")[:60]
                print(f"[{'OK (200)':^10}] Google GenAI ({model_id:<21}) | {elapsed:6.1f} ms | [\"{reply_snippet}...\"]")
            except Exception as model_err:
                print(f"[  ERROR   ] Google GenAI ({model_id:<21}) | Exception: {model_err}")
    except Exception as e:
        print(f"[  ERROR   ] Google GenAI SDK failure: {e}")

    print("=" * 80)

if __name__ == "__main__":
    asyncio.run(probe_all_sources())
