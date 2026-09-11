"""Development and production server runner for VaanilaiAI."""
import os
import uvicorn

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    host = os.environ.get("HOST", "0.0.0.0")
    reload = os.environ.get("RELOAD", "True").lower() == "true"
    
    print(f"Starting VaanilaiAI Backend on http://{host}:{port}")
    uvicorn.run("app.main:app", host=host, port=port, reload=reload)
