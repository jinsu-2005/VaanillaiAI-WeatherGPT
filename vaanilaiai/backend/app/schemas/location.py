"""Pydantic schemas for Locations and Geocoding."""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, ConfigDict


class LocationCoordinates(BaseModel):
    latitude: float = Field(..., ge=-90.0, le=90.0, description="Latitude in decimal degrees")
    longitude: float = Field(..., ge=-180.0, le=180.0, description="Longitude in decimal degrees")


class LocationSearchResult(BaseModel):
    id: Optional[int] = None
    name: str = Field(..., description="City, town or village name")
    district: Optional[str] = Field(None, description="District name (e.g., Kanyakumari, Pune)")
    state: Optional[str] = Field(None, description="State / Union Territory (e.g., Tamil Nadu)")
    country: str = Field("India", description="Country")
    latitude: float
    longitude: float
    elevation: Optional[float] = None
    is_village: bool = False
    display_name: str = Field(..., description="Formatted full location string")


class SavedLocationCreate(BaseModel):
    name: str
    district: Optional[str] = None
    state: Optional[str] = None
    country: str = "India"
    latitude: float
    longitude: float
    elevation: Optional[float] = None
    is_village: bool = False
    is_favorite: bool = False


class SavedLocationResponse(SavedLocationCreate):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: Optional[int] = None
    created_at: datetime
