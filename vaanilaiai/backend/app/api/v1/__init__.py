"""API v1 router configuration."""
from fastapi import APIRouter
from app.api.v1 import (
    health,
    weather,
    locations,
    alerts,
    advisories,
    climate,
    chat,
    voice,
    vision,
    reports,
    hydro,
    monsoon,
    safar,
    fog,
    coldwave,
    pest_forewarning,
    avalanche,
    convective_storm,
    drought,
    marine_heatwave,
    cloudburst,
    hazmat,
    forest_fire,
    heat_action_plan,
    tsunami,
    crop_water_stress,
    storm_surge,
    ocean_state,
    livestock_heat_stress,
    earthquake,
    solar_energy,
    lightning_cell,
    wind_energy,
    glof,
    oil_spill,
    urban_heat_island,
    potential_fishing_zone,
    extended_range_prediction,
    snowmelt_runoff,
    agri_storage,
    flash_drought,
    hydro_rating,
    saltwater_intrusion,
)

api_router = APIRouter()

api_router.include_router(health.router, tags=["Health"])
api_router.include_router(weather.router, prefix="/weather", tags=["Weather & Forecast"])
api_router.include_router(locations.router, prefix="/locations", tags=["Locations & Geocoding"])
api_router.include_router(alerts.router, prefix="/alerts", tags=["Disaster & Warnings"])
api_router.include_router(advisories.router, prefix="/advisories", tags=["Decision Support Advisories"])
api_router.include_router(climate.router, prefix="/climate", tags=["Historical Climate"])
api_router.include_router(chat.router, prefix="/chat", tags=["Conversational AI"])
api_router.include_router(voice.router, prefix="/voice", tags=["Voice Interaction"])
api_router.include_router(vision.router, prefix="/vision", tags=["Multimodal Vision AI"])
api_router.include_router(reports.router, prefix="/reports", tags=["Citizen Science & Ground Truth"])
api_router.include_router(hydro.router, prefix="/hydro", tags=["CWC River Basin & Dam Hydro-Telemetry"])
api_router.include_router(monsoon.router, prefix="/monsoon", tags=["Monsoon & Teleconnections"])
api_router.include_router(safar.router, prefix="/air-quality", tags=["Air Quality & Atmospheric Dispersion"])
api_router.include_router(fog.router, prefix="/fog", tags=["IMD FogPass & Highway/Aviation Low-Visibility"])
api_router.include_router(coldwave.router, prefix="/coldwave", tags=["IMD Cold Wave & Ground Frost Vulnerability"])
api_router.include_router(pest_forewarning.router, prefix="/advisories", tags=["Crop Pest & Disease Forewarning"])
api_router.include_router(avalanche.router, prefix="/avalanche", tags=["Himalayan Western Disturbance & Avalanche Warning"])
api_router.include_router(convective_storm.router, prefix="/alerts", tags=["Severe Thunderstorm & Haboob Dust Storm Warning"])
api_router.include_router(drought.router, prefix="/advisories", tags=["Agricultural Drought & Groundwater Vulnerability"])
api_router.include_router(marine_heatwave.router, prefix="/advisories", tags=["Marine Heatwave & Coral Bleaching"])
api_router.include_router(cloudburst.router, prefix="/alerts", tags=["Cloudburst, Flash Flood & Landslide Warning"])
api_router.include_router(hazmat.router, prefix="/alerts", tags=["Industrial Hazmat & Toxic Plume Dispersion"])
api_router.include_router(forest_fire.router, prefix="/alerts", tags=["Forest Fire Danger & Fire Weather Index"])
api_router.include_router(heat_action_plan.router, prefix="/alerts", tags=["National Heat Action Plan & Solar UV Radiation"])
api_router.include_router(tsunami.router, prefix="/alerts", tags=["INCOIS Indian Tsunami Early Warning Centre (ITEWS)"])
api_router.include_router(crop_water_stress.router, prefix="/advisories", tags=["ICAR-CRIDA Crop Water Stress & Soil Moisture"])
api_router.include_router(storm_surge.router, prefix="/alerts", tags=["INCOIS-IMD Coastal Storm Surge & Tidal Inundation"])
api_router.include_router(ocean_state.router, prefix="/alerts", tags=["INCOIS Ocean State Forecast & Beach Rip Current Warning"])
api_router.include_router(livestock_heat_stress.router, prefix="/advisories", tags=["ICAR-NDRI Dairy Livestock Thermal Stress & THI"])
api_router.include_router(earthquake.router, prefix="/alerts", tags=["NCS/IMD Earthquake Seismology & Aftershock Warning"])
api_router.include_router(solar_energy.router, prefix="/advisories", tags=["NISE/IMD Solar Radiation & Rooftop PV"])
api_router.include_router(lightning_cell.router, prefix="/alerts", tags=["IITM & IMD Lightning Flash Density & Downburst Nowcasting"])
api_router.include_router(wind_energy.router, prefix="/advisories", tags=["NIWE/IMD Wind Resource & Wind Farm Generation"])
api_router.include_router(glof.router, prefix="/alerts", tags=["NRSC/CWC/NDMA Himalayan GLOF Early Warning"])
api_router.include_router(oil_spill.router, prefix="/alerts", tags=["INCOIS & ICG Marine Oil Spill & Coastal Ecology"])
api_router.include_router(urban_heat_island.router, prefix="/advisories", tags=["IMD & NDMA Urban Heat Island & Cool Roof Engine"])
api_router.include_router(potential_fishing_zone.router, prefix="/advisories", tags=["INCOIS & CMFRI Potential Fishing Zone & Marine Fuel Engine"])
api_router.include_router(extended_range_prediction.router, prefix="/monsoon", tags=["IMD, NCMRWF & IITM Extended Range Prediction (ERP) & Monsoon Pulse"])
api_router.include_router(snowmelt_runoff.router, prefix="/hydro", tags=["Himalayan Snowmelt Runoff & Glacial Hydrology"])
api_router.include_router(agri_storage.router, prefix="/advisories", tags=["Post-Harvest Mandi Weather Defense & Grain Moisture"])
api_router.include_router(flash_drought.router, prefix="/advisories", tags=["Flash Drought & Atmospheric Evaporative Demand"])
api_router.include_router(hydro_rating.router, prefix="/hydro", tags=["CWC Flood Forecasting & Hydrological Rating Curves"])
api_router.include_router(saltwater_intrusion.router, prefix="/coastal", tags=["Coastal Salinity & Estuarine Hydrology"])







