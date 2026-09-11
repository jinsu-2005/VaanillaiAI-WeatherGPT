"""FastAPI Main Application Entrypoint for VaanilaiAI."""
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import RedirectResponse
from app.core.config import settings
from app.core.database import init_db
from app.core.logging import setup_logging, logger
from app.api.v1 import api_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application startup and shutdown lifespan events."""
    setup_logging()
    logger.info("Initializing VaanilaiAI Backend Services...")
    await init_db()
    logger.info(f"VaanilaiAI Backend {settings.VERSION} ready.")
    yield
    logger.info("Shutting down VaanilaiAI Backend...")


app = FastAPI(
    title=settings.PROJECT_NAME,
    description=(
        "**VaanilaiAI (WeatherGPT)**: Official Conversational AI & Weather Intelligence Platform.\n\n"
        "Built for Ministry of Earth Sciences (MoES) & India Meteorological Department (IMD).\n"
        "Features: Zero-Hallucination Weather Intelligence, Coordinate-Level NWP Model Fusion, "
        "Disaster Management & Warnings (Red/Orange/Yellow), Agro-Met & Travel Advisories, "
        "Historical Climate Trends, Multilingual (English, Tamil, Hindi) & Voice Interaction."
    ),
    version=settings.VERSION,
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API Routers
app.include_router(api_router, prefix=settings.API_V1_STR)


@app.get("/", include_in_schema=False)
async def root():
    """Redirect root to OpenAPI docs."""
    return RedirectResponse(url="/docs")
