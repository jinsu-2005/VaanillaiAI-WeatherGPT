"""Schemas for Numerical Weather Prediction (NWP) Multi-Model Ensemble Comparison."""
from typing import Dict, List, Optional
from pydantic import BaseModel, Field


class NwpModelOutput(BaseModel):
    """Forecast output from a specific NWP model for a single day."""
    model_id: str = Field(..., description="Internal model identifier (e.g. ecmwf_ifs025, gfs_seamless, icon_seamless)")
    model_name: str = Field(..., description="Human-readable model name")
    agency: str = Field(..., description="Operating meteorological agency")
    resolution_km: float = Field(..., description="Approximate spatial resolution in kilometers")
    precipitation_mm: float = Field(..., description="Projected 24-hour total precipitation in mm")
    temperature_max: float = Field(..., description="Projected maximum 2m temperature in °C")
    temperature_min: float = Field(..., description="Projected minimum 2m temperature in °C")


class DailyNwpComparison(BaseModel):
    """Daily cross-model comparison, consensus, and spread metrics."""
    date: str = Field(..., description="Date of forecast in ISO format YYYY-MM-DD")
    day_name: str = Field(..., description="Weekday name (e.g. Monday)")
    models: Dict[str, NwpModelOutput] = Field(..., description="Map of model_id to model output")
    consensus_rain_mean_mm: float = Field(..., description="Ensemble mean rainfall in mm")
    consensus_rain_min_mm: float = Field(..., description="Lowest projected rainfall across models in mm")
    consensus_rain_max_mm: float = Field(..., description="Highest projected rainfall across models in mm")
    rain_spread_mm: float = Field(..., description="Difference between max and min projected rainfall in mm")
    consensus_temp_max: float = Field(..., description="Ensemble mean maximum temperature in °C")
    consensus_temp_min: float = Field(..., description="Ensemble mean minimum temperature in °C")
    confidence: str = Field(..., description="Model consensus confidence rating: High, Moderate, or Low")
    divergence_note: str = Field(..., description="Meteorological explanation of inter-model divergence")


class NwpModelMetadata(BaseModel):
    """Metadata describing an NWP model and its operational agency."""
    model_id: str
    full_name: str
    agency: str
    country: str
    resolution: str
    primary_strength: str


class MultiModelComparisonResponse(BaseModel):
    """Response payload for multi-model NWP forecast comparison."""
    location_name: str
    latitude: float
    longitude: float
    elevation: Optional[float] = None
    days_count: int
    overall_confidence: str = Field(..., description="Overall 5-day ensemble agreement: High, Moderate, or Low")
    overall_summary: str = Field(..., description="Executive meteorological consensus narrative")
    daily_comparisons: List[DailyNwpComparison]
    model_metadata: List[NwpModelMetadata]
    provenance: str = "Open-Meteo Multi-Model Global NWP Ensemble API (ECMWF, NOAA/NCEP, DWD)"
