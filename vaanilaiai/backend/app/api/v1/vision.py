"""Multimodal Sky & Cloud Vision Diagnostic API Endpoints."""
import base64
from typing import Optional
from fastapi import APIRouter, File, UploadFile, Query
from pydantic import BaseModel, Field
from app.schemas.advisory import SkyAnalysisResponse
from app.services.vision_service import vision_service

router = APIRouter()


class SkyAnalysisBase64Request(BaseModel):
    image_base64: str = Field(..., description="Base64-encoded image string")
    mime_type: str = "image/jpeg"
    location_name: str = "Location"


@router.post("/analyze-sky", response_model=SkyAnalysisResponse, summary="Diagnose Sky Image via Multipart Upload")
async def analyze_sky_multipart(
    file: UploadFile = File(...),
    location_name: str = Query("Location")
):
    """Analyze sky photo with Gemini Multimodal Vision to classify cloud genus, rain ETA, and squall risk."""
    image_bytes = await file.read()
    mime_type = file.content_type or "image/jpeg"
    return await vision_service.analyze_sky_image(
        image_bytes=image_bytes,
        mime_type=mime_type,
        location_name=location_name
    )


@router.post("/analyze-sky-base64", response_model=SkyAnalysisResponse, summary="Diagnose Sky Image via Base64 JSON")
async def analyze_sky_base64(payload: SkyAnalysisBase64Request):
    """Analyze sky photo encoded in base64 string for seamless Flutter Web/Mobile compatibility."""
    raw_b64 = payload.image_base64
    if "," in raw_b64:
        raw_b64 = raw_b64.split(",", 1)[1]
    image_bytes = base64.b64decode(raw_b64)
    return await vision_service.analyze_sky_image(
        image_bytes=image_bytes,
        mime_type=payload.mime_type,
        location_name=payload.location_name
    )
