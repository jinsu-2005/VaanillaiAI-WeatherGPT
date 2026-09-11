"""Pydantic schemas for Historical Weather and Climate Analytics."""
from typing import List, Dict, Optional
from pydantic import BaseModel, Field


class MonthlyClimateStats(BaseModel):
    month_name: str
    month_index: int
    avg_temperature_c: float
    total_rainfall_mm: float
    rainy_days_count: int


class YearlyClimateStats(BaseModel):
    year: int
    annual_rainfall_mm: float
    annual_mean_temp_c: float
    max_temp_recorded_c: float
    min_temp_recorded_c: float
    monthly_stats: List[MonthlyClimateStats] = []


class ClimateComparisonResponse(BaseModel):
    location_name: str
    latitude: float
    longitude: float
    year_1: int
    year_2: int
    year_1_stats: YearlyClimateStats
    year_2_stats: YearlyClimateStats
    rainfall_difference_mm: float
    rainfall_change_percent: float
    temperature_difference_c: float
    climate_summary: str


class ClimateTrendResponse(BaseModel):
    location_name: str
    latitude: float
    longitude: float
    start_year: int
    end_year: int
    multi_year_stats: List[YearlyClimateStats]
    average_annual_rainfall_mm: float
    rainfall_trend_slope: float  # mm/year change
    warming_trend_c_per_decade: float
    trend_description: str
