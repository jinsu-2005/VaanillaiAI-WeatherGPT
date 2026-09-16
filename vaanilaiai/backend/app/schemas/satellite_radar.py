"""Pydantic schemas for ISRO MOSDAC Satellite and IMD Doppler Weather Radar Layers."""
from datetime import datetime, timezone
from typing import List, Optional
from pydantic import BaseModel, Field


class DwrRadarStation(BaseModel):
    """Metadata and operational status for an IMD Doppler Weather Radar station."""
    station_id: str = Field(..., description="Unique radar station identifier (e.g. dwr_chennai)")
    name: str = Field(..., description="Full station display name")
    state: str = Field(..., description="Indian State or Union Territory")
    latitude: float = Field(..., ge=-90.0, le=90.0, description="Station latitude")
    longitude: float = Field(..., ge=-180.0, le=180.0, description="Station longitude")
    band: str = Field(..., description="Radar band: S-band (10cm), C-band (5cm), or X-band (3cm)")
    frequency_ghz: float = Field(..., description="Operating central frequency in GHz")
    max_range_km: int = Field(..., description="Maximum operational surveillance scan radius in km")
    status: str = Field(..., description="Operating health: Operational, Calibrating, or Maintenance")
    last_sweep_utc: datetime = Field(..., description="Timestamp of the most recent volumetric radar sweep")
    peak_reflectivity_dbz: Optional[float] = Field(None, description="Maximum radar reflectivity observed in station sector in dBZ")
    convective_cells_detected: int = Field(0, description="Count of active convective precipitation cells tracked")
    storm_motion_heading_deg: Optional[float] = Field(None, description="Convective cell movement heading in degrees azimuth (0-360)")
    storm_motion_speed_kmh: Optional[float] = Field(None, description="Estimated storm cell displacement velocity in km/h")
    station_code: Optional[str] = Field(None, description="Official IMD radar station short code (e.g. tvm, cni, mum)")
    radar_image_url: Optional[str] = Field(None, description="Direct URL to IMD live Doppler radar sweep GIF")


class MosdacSatelliteProduct(BaseModel):
    """Metadata and visualization parameters for an ISRO MOSDAC INSAT-3DR satellite channel."""
    product_id: str = Field(..., description="Product key: insat3dr_tir1_ctt, insat3dr_wv, insat3dr_vis, etc.")
    name: str = Field(..., description="Product title (e.g. INSAT-3DR Thermal IR - Cloud Top Temperature)")
    satellite: str = Field(..., description="Satellite platform (e.g. INSAT-3DR Geostationary 74°E)")
    sensor: str = Field(..., description="Payload instrument (e.g. 6-Channel Multispectral Imager)")
    resolution_km: float = Field(..., description="Sub-satellite ground spatial resolution in km")
    channel_wavelength: str = Field(..., description="Central spectral wavelength (e.g. 10.8 µm, 6.8 µm)")
    latest_scan_time_utc: datetime = Field(..., description="Acquisition timestamp of latest imagery frame")
    refresh_interval_min: int = Field(..., description="Nominal repeat cycle cadence in minutes")
    color_scale_unit: str = Field(..., description="Physical measurement unit: °C, %, Albedo %")
    color_scale_labels: List[str] = Field(default_factory=list, description="Legend label thresholds")
    palette_gradient: List[str] = Field(default_factory=list, description="Hex color gradient progression")
    synoptic_interpretation: str = Field(..., description="Meteorological interpretation of current frame")
    tile_or_image_url: Optional[str] = Field(None, description="Direct WMS/slippy tile URL template or imagery link")
    bounds: List[float] = Field(
        default_factory=lambda: [-10.0, 45.0, 45.0, 110.0],
        description="Geographic bounding box [min_lat, min_lon, max_lat, max_lon]"
    )


class SatelliteRadarOverviewResponse(BaseModel):
    """Combined response delivering live DWR radar network status and MOSDAC satellite feeds."""
    dwr_stations: List[DwrRadarStation] = Field(default_factory=list)
    satellite_products: List[MosdacSatelliteProduct] = Field(default_factory=list)
    nearest_dwr_station: Optional[DwrRadarStation] = Field(None, description="Geographically closest IMD radar station")
    distance_to_nearest_radar_km: Optional[float] = Field(None, description="Distance to closest DWR in km")
    local_radar_coverage_status: str = Field(
        ...,
        description="Coverage classification: Within 100km Nowcast Range, Within 250km Surveillance Range, Beyond Direct DWR Coverage"
    )
    data_provenance: str = Field(
        default="ISRO MOSDAC (Meteorological & Oceanographic Satellite Data Archival Centre) & IMD Doppler Weather Radar Network",
        description="Authoritative source attribution"
    )
    generated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
