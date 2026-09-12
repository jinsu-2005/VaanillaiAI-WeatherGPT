import json
import logging
from pathlib import Path
from typing import Dict, List, Optional
import httpx
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.core.config import settings
from app.models.location import SavedLocation
from app.schemas.location import LocationSearchResult, SavedLocationCreate, SavedLocationResponse, IMDStationEntry

logger = logging.getLogger(__name__)

# Key Indian metropolitan and district seed mappings
DEFAULT_INDIAN_LOCATIONS = [
    {"name": "Nagercoil", "district": "Kanyakumari", "state": "Tamil Nadu", "lat": 8.1833, "lon": 77.4119},
    {"name": "Chennai", "district": "Chennai", "state": "Tamil Nadu", "lat": 13.0827, "lon": 80.2707},
    {"name": "Coimbatore", "district": "Coimbatore", "state": "Tamil Nadu", "lat": 11.0168, "lon": 76.9558},
    {"name": "Madurai", "district": "Madurai", "state": "Tamil Nadu", "lat": 9.9252, "lon": 78.1198},
    {"name": "New Delhi", "district": "New Delhi", "state": "Delhi", "lat": 28.6139, "lon": 77.2090},
    {"name": "Mumbai", "district": "Mumbai City", "state": "Maharashtra", "lat": 19.0760, "lon": 72.8777},
    {"name": "Bengaluru", "district": "Bengaluru Urban", "state": "Karnataka", "lat": 12.9716, "lon": 77.5946},
    {"name": "Hyderabad", "district": "Hyderabad", "state": "Telangana", "lat": 17.3850, "lon": 78.4867},
    {"name": "Kolkata", "district": "Kolkata", "state": "West Bengal", "lat": 22.5726, "lon": 88.3639},
    {"name": "Varanasi", "district": "Varanasi", "state": "Uttar Pradesh", "lat": 25.3176, "lon": 82.9739},
    {"name": "Wayanad", "district": "Wayanad", "state": "Kerala", "lat": 11.6854, "lon": 76.1320},
    {"name": "Shimla", "district": "Shimla", "state": "Himachal Pradesh", "lat": 31.1048, "lon": 77.1734},
]


class LocationService:
    """Service for resolving location queries, coordinates, and managing saved places."""

    def __init__(self):
        self._stations: Dict[str, str] = self._load_imd_stations()

    def _load_imd_stations(self) -> Dict[str, str]:
        """Load the 697 Indian City IMD/WMO station ID mapping from resources."""
        stations: Dict[str, str] = {}
        try:
            res_path = Path(__file__).resolve().parent.parent / "resources" / "imd_stations.json"
            if res_path.exists():
                with open(res_path, "r", encoding="utf-8") as f:
                    stations = json.load(f)
        except Exception as e:
            logger.warning(f"Could not load local IMD station directory: {e}")
        return stations

    def find_imd_stations(self, query: str = "", limit: int = 20) -> List[IMDStationEntry]:
        """Search the 697 Indian City IMD/WMO station ID catalog."""
        q = query.strip().lower()
        if not q:
            return [IMDStationEntry(station_id=sid, city_name=name) for sid, name in list(self._stations.items())[:limit]]
        
        matches: List[IMDStationEntry] = []
        for sid, name in self._stations.items():
            if q in sid.lower() or q in name.lower():
                matches.append(IMDStationEntry(station_id=sid, city_name=name))
                if len(matches) >= limit:
                    break
        return matches

    def match_station_id(self, name: Optional[str], district: Optional[str] = None) -> Optional[str]:
        """Match a location name or district to an official IMD station ID."""
        if not name and not district:
            return None
        candidates = [c.lower().strip() for c in [name, district] if c]
        for sid, sname in self._stations.items():
            s_clean = sname.lower().strip()
            for cand in candidates:
                if cand == s_clean or cand in s_clean or s_clean in cand:
                    return sid
        return None

    async def search_locations(self, query: str, count: int = 10) -> List[LocationSearchResult]:
        """Search Indian towns, villages, and cities."""
        query = query.strip()
        if not query:
            return []

        results: List[LocationSearchResult] = []

        try:
            params = {
                "name": query,
                "count": min(count, 20),
                "language": "en",
                "format": "json"
            }
            async with httpx.AsyncClient(timeout=8.0) as client:
                resp = await client.get(settings.OPEN_METEO_GEOCODING_URL, params=params)
                if resp.status_code == 200:
                    data = resp.json()
                    for item in data.get("results", []):
                        # Filter or prioritize India
                        country = item.get("country", "")
                        state = item.get("admin1")
                        district = item.get("admin2") or item.get("admin3")
                        is_village = item.get("feature_code", "").startswith("PPL") and item.get("population", 0) < 15000
                        
                        display_parts = [item.get("name")]
                        if district and district != item.get("name"):
                            display_parts.append(district)
                        if state:
                            display_parts.append(state)
                        if country:
                            display_parts.append(country)

                        loc_name = item.get("name")
                        station_id = self.match_station_id(loc_name, district)

                        results.append(
                            LocationSearchResult(
                                id=item.get("id"),
                                name=loc_name,
                                district=district,
                                state=state,
                                country=country,
                                latitude=float(item.get("latitude")),
                                longitude=float(item.get("longitude")),
                                elevation=float(item.get("elevation", 0.0)) if item.get("elevation") is not None else None,
                                is_village=is_village,
                                display_name=", ".join(display_parts),
                                imd_station_id=station_id,
                            )
                        )
        except Exception as e:
            logger.warning(f"Error calling geocoding API for query '{query}': {e}")

        # Fallback to local default locations if external search yielded 0 results
        if not results:
            for loc in DEFAULT_INDIAN_LOCATIONS:
                if query.lower() in loc["name"].lower() or (loc["district"] and query.lower() in loc["district"].lower()):
                    station_id = self.match_station_id(loc["name"], loc["district"])
                    results.append(
                        LocationSearchResult(
                            name=loc["name"],
                            district=loc["district"],
                            state=loc["state"],
                            country="India",
                            latitude=loc["lat"],
                            longitude=loc["lon"],
                            display_name=f"{loc['name']}, {loc['district']}, {loc['state']}, India",
                            imd_station_id=station_id,
                        )
                    )

        return results

    async def get_saved_locations(self, db: AsyncSession, user_id: Optional[int] = None) -> List[SavedLocationResponse]:
        """Fetch saved/favorite locations from the database."""
        stmt = select(SavedLocation)
        if user_id is not None:
            stmt = stmt.where(SavedLocation.user_id == user_id)
        
        result = await db.execute(stmt)
        records = result.scalars().all()
        return [SavedLocationResponse.model_validate(r) for r in records]

    async def add_saved_location(
        self,
        db: AsyncSession,
        data: SavedLocationCreate,
        user_id: Optional[int] = None
    ) -> SavedLocationResponse:
        """Save a new favorite location."""
        record = SavedLocation(
            user_id=user_id,
            name=data.name,
            district=data.district,
            state=data.state,
            country=data.country,
            latitude=data.latitude,
            longitude=data.longitude,
            elevation=data.elevation,
            is_village=data.is_village,
            is_favorite=data.is_favorite
        )
        db.add(record)
        await db.flush()
        await db.refresh(record)
        return SavedLocationResponse.model_validate(record)


location_service = LocationService()
