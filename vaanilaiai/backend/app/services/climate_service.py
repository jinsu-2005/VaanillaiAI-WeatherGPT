"""Historical Weather and Climate Analytics Service."""
import logging
from datetime import datetime
from typing import List, Dict, Any
from app.providers.open_meteo import OpenMeteoProvider
from app.schemas.climate import (
    MonthlyClimateStats,
    YearlyClimateStats,
    ClimateComparisonResponse,
    ClimateTrendResponse,
)

logger = logging.getLogger(__name__)

MONTH_NAMES = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]


class ClimateService:
    """Historical meteorological analysis and multi-year climate trend processing."""

    def __init__(self):
        self.weather_provider = OpenMeteoProvider()

    async def get_yearly_stats(self, lat: float, lon: float, year: int) -> YearlyClimateStats:
        """Fetch and aggregate 365-day weather archive for a given year."""
        start_date = f"{year}-01-01"
        end_date = f"{year}-12-31"

        data = await self.weather_provider.get_historical_weather(lat, lon, start_date, end_date)
        daily = data.get("daily", {})
        
        times = daily.get("time", [])
        temp_means = daily.get("temperature_2m_mean", [])
        temp_maxs = daily.get("temperature_2m_max", [])
        temp_mins = daily.get("temperature_2m_min", [])
        precips = daily.get("precipitation_sum", [])

        # Group by month
        monthly_groups: Dict[int, Dict[str, Any]] = {
            m: {"temps": [], "precips": [], "rainy_days": 0} for m in range(1, 13)
        }

        all_temps = []
        for i in range(len(times)):
            t_str = times[i]
            month = int(t_str.split("-")[1])
            
            t_mean = temp_means[i] if i < len(temp_means) and temp_means[i] is not None else 25.0
            p_val = precips[i] if i < len(precips) and precips[i] is not None else 0.0
            
            monthly_groups[month]["temps"].append(t_mean)
            monthly_groups[month]["precips"].append(p_val)
            all_temps.append(t_mean)

            # IMD standard rainy day is >= 2.5 mm
            if p_val >= 2.5:
                monthly_groups[month]["rainy_days"] += 1

        monthly_stats: List[MonthlyClimateStats] = []
        total_annual_rainfall = 0.0

        for m in range(1, 13):
            t_list = monthly_groups[m]["temps"]
            p_list = monthly_groups[m]["precips"]
            avg_t = sum(t_list) / len(t_list) if t_list else 0.0
            sum_p = sum(p_list)
            total_annual_rainfall += sum_p

            monthly_stats.append(
                MonthlyClimateStats(
                    month_name=MONTH_NAMES[m - 1],
                    month_index=m,
                    avg_temperature_c=round(avg_t, 1),
                    total_rainfall_mm=round(sum_p, 1),
                    rainy_days_count=monthly_groups[m]["rainy_days"]
                )
            )

        mean_temp = sum(all_temps) / len(all_temps) if all_temps else 25.0
        max_t = max([t for t in temp_maxs if t is not None] or [35.0])
        min_t = min([t for t in temp_mins if t is not None] or [15.0])

        return YearlyClimateStats(
            year=year,
            annual_rainfall_mm=round(total_annual_rainfall, 1),
            annual_mean_temp_c=round(mean_temp, 2),
            max_temp_recorded_c=round(max_t, 1),
            min_temp_recorded_c=round(min_t, 1),
            monthly_stats=monthly_stats
        )

    async def compare_years(
        self,
        lat: float,
        lon: float,
        location_name: str,
        year_1: int,
        year_2: int
    ) -> ClimateComparisonResponse:
        """Compare meteorological parameters between two distinct years."""
        stats_1 = await self.get_yearly_stats(lat, lon, year_1)
        stats_2 = await self.get_yearly_stats(lat, lon, year_2)

        diff_rain = stats_2.annual_rainfall_mm - stats_1.annual_rainfall_mm
        pct_rain = (diff_rain / stats_1.annual_rainfall_mm * 100) if stats_1.annual_rainfall_mm > 0 else 0.0
        diff_temp = stats_2.annual_mean_temp_c - stats_1.annual_mean_temp_c

        summary = (
            f"Comparing {year_2} with {year_1} in {location_name}: Total annual rainfall was {stats_2.annual_rainfall_mm:.1f} mm "
            f"in {year_2} vs {stats_1.annual_rainfall_mm:.1f} mm in {year_1} ({'+' if diff_rain >= 0 else ''}{diff_rain:.1f} mm, "
            f"{'+' if pct_rain >= 0 else ''}{pct_rain:.1f}%). Mean annual temperature was {stats_2.annual_mean_temp_c:.2f}°C vs "
            f"{stats_1.annual_mean_temp_c:.2f}°C ({'+' if diff_temp >= 0 else ''}{diff_temp:.2f}°C)."
        )

        return ClimateComparisonResponse(
            location_name=location_name,
            latitude=lat,
            longitude=lon,
            year_1=year_1,
            year_2=year_2,
            year_1_stats=stats_1,
            year_2_stats=stats_2,
            rainfall_difference_mm=round(diff_rain, 1),
            rainfall_change_percent=round(pct_rain, 1),
            temperature_difference_c=round(diff_temp, 2),
            climate_summary=summary
        )

    async def get_multi_year_trends(
        self,
        lat: float,
        lon: float,
        location_name: str,
        start_year: int = 2018,
        end_year: int = 2024
    ) -> ClimateTrendResponse:
        """Analyze multi-year climate trajectory and anomalies."""
        multi_year_stats = []
        for y in range(start_year, end_year + 1):
            stats = await self.get_yearly_stats(lat, lon, y)
            multi_year_stats.append(stats)

        total_rain = sum(s.annual_rainfall_mm for s in multi_year_stats)
        avg_rain = total_rain / len(multi_year_stats) if multi_year_stats else 0.0

        # Simple linear rate calculation
        if len(multi_year_stats) >= 2:
            rain_slope = (multi_year_stats[-1].annual_rainfall_mm - multi_year_stats[0].annual_rainfall_mm) / (len(multi_year_stats) - 1)
            temp_diff = multi_year_stats[-1].annual_mean_temp_c - multi_year_stats[0].annual_mean_temp_c
            warming_rate_decade = (temp_diff / (len(multi_year_stats) - 1)) * 10
        else:
            rain_slope = 0.0
            warming_rate_decade = 0.0

        desc = (
            f"Over the {start_year}-{end_year} period in {location_name}, average annual rainfall is {avg_rain:.1f} mm. "
            f"Annual rainfall trend shows a shift of {rain_slope:+.1f} mm/year. "
            f"Temperature trend indicates {warming_rate_decade:+.2f}°C change per decade."
        )

        return ClimateTrendResponse(
            location_name=location_name,
            latitude=lat,
            longitude=lon,
            start_year=start_year,
            end_year=end_year,
            multi_year_stats=multi_year_stats,
            average_annual_rainfall_mm=round(avg_rain, 1),
            rainfall_trend_slope=round(rain_slope, 2),
            warming_trend_c_per_decade=round(warming_rate_decade, 2),
            trend_description=desc
        )


climate_service = ClimateService()
