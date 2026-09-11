"""Location search and favorite management endpoints."""
from typing import List, Optional
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.schemas.location import LocationSearchResult, SavedLocationCreate, SavedLocationResponse
from app.services.location_service import location_service

router = APIRouter()


@router.get("/search", response_model=List[LocationSearchResult], summary="Search Indian Places")
async def search_places(
    q: str = Query(..., min_length=1, description="Location name (city, town, village, or district)"),
    count: int = Query(10, ge=1, le=20)
):
    """Search Indian locations with district and village resolution."""
    return await location_service.search_locations(q, count=count)


@router.get("/favorites", response_model=List[SavedLocationResponse], summary="List Saved Locations")
async def get_favorites(
    user_id: Optional[int] = Query(None, description="Optional user ID"),
    db: AsyncSession = Depends(get_db)
):
    """Retrieve saved and favorite locations."""
    return await location_service.get_saved_locations(db, user_id=user_id)


@router.post("/favorites", response_model=SavedLocationResponse, status_code=status.HTTP_201_CREATED, summary="Save Location")
async def add_favorite(
    payload: SavedLocationCreate,
    user_id: Optional[int] = Query(None),
    db: AsyncSession = Depends(get_db)
):
    """Save a location for quick access."""
    return await location_service.add_saved_location(db, payload, user_id=user_id)
