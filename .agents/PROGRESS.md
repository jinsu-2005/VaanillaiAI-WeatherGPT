# WeatherGPT Autonomous Delivery Progress Log

## Baseline Summary
- Flutter Static Analysis: 0 issues (`flutter analyze`)
- Flutter Test Suite: 30 tests passing (`flutter test`)
- FastAPI Backend Tests: Passing (`pytest`)
- Core P0/P1 data integrity and reliability foundations in place.

---

## Completed Autonomous Cycles

### Cycle 1: Air Quality Screen Integrity & Dedicated Unavailable State
- **Objective**: Fix `air_quality_screen.dart` to eliminate fake simulated multipliers (`aqiValue * 0.45`, etc.) when `aqi == null`, providing an honest, informative "Air Quality Data Unavailable" card with retry action.
- **Changes**:
  - Removed mathematical multiplier estimations for O3, NO2, SO2, CO.
  - Implemented `_buildUnavailableState` with clear notice and retry callback.
  - Added widget tests in `weather_provider_test.dart`.
- **Status**: Completed & Verified.

### Cycle 2: Marine Advisory Unavailable Handling in Inland Locations
- **Objective**: Graceful fallback UI for inland locations and unreachable INCOIS servers in `advisories_screen.dart`.
- **Changes**:
  - Updated `_buildMarineTab` to check `marine.dataUnavailable`.
  - Built dedicated inland empty state with explanatory advisory notes and retry button.
  - Removed redundant null-aware operators.
- **Status**: Completed & Verified.

### Cycle 3: Accurate Astronomical Synodic Lunar Phase & 12-Hour Solar Timing
- **Objective**: Real synodic month phase calculation and 12-hr formatting in `sun_moon_screen.dart`.
- **Changes**:
  - Replaced hardcoded "Waxing Gibbous (82% Illumination)" with `_LunarCalculation` computing exact synodic phase age (29.53058867 days epoch offset), phase name, and illumination fraction.
  - Fixed `18:32 PM` formatting bug by creating `_formatTime12Hour` with robust ISO-8601 parsing.
- **Status**: Completed & Verified.

### Cycle 4: Sky Scanner Unavailable Notice & Robust Error Handling
- **Objective**: Dedicated UI card when backend Gemini vision service is unreachable or errors.
- **Changes**:
  - Updated `sky_scanner_screen.dart` to detect `result.dataUnavailable`.
  - Added dedicated `_buildUnavailableState` card with amber warning badge, offline explanation, and "Retry Analysis" button.
  - Updated error handling in `_runAnalysis` to fall back to `SkyAnalysisModel.unavailable(weather.locationName)`.
- **Status**: Completed & Verified.

### Cycle 5: Rainfall History Null Safety, Freshness Badging & Daily Breakdown
- **Objective**: Honest handling when forecast is pending or missing, remove hardcoded probability fallbacks, and provide detailed precipitation breakdown.
- **Changes**:
  - Replaced hardcoded `20` and `15` probabilities with safe calculations from `daily` forecast or `--`.
  - Added honest `_buildUnavailableState` when `forecast == null || daily.isEmpty`.
  - Added `DataSourceIndicator` for live data provenance and freshness tracking.
  - Added detailed "Daily Precipitation Breakdown" list with condition icons, rain probabilities, volume in mm, and intensity indicators.
  - Added widget tests in `test/weather_provider_test.dart`.
- **Status**: Completed & Verified.

### Cycle 6: Heat Index & Wet-Bulb Thermal Stress Monitor
- **Objective**: Calculate Steadman's Heat Index and Stull's Wet-Bulb temperature to provide actionable occupational and agricultural heat safety guidance (NDMA/IMD aligned).
- **Changes**:
  - Created `lib/utils/heat_stress_calculator.dart` implementing Steadman/Rothfusz Heat Index, Stull Wet-Bulb equation, and thermal stress categories (Low, Caution, Extreme Caution, Danger).
  - Created `lib/screens/heat_stress_screen.dart` with dual metrics gauges, outdoor work/rest intervals, hydration targets, 24-hour heat forecast timeline, and heat illness first-aid protocols.
  - Connected into `HomeDashboardScreen` institutional actions and `MoreScreen` Weather Intelligence menu.
  - Created comprehensive test suite `test/heat_stress_test.dart` (5 calculator unit tests + 2 screen widget tests).
- **Status**: Completed & Verified.

### Cycle 7: Scalability, Security Hardening & Real-Time Alert Streaming
- **Objective**: Address production architecture prerequisites: secure environment configuration, PostgreSQL database URL normalization for asyncpg, remove hardcoded secrets, restrict CORS, consolidate Render deployment configurations, add Firebase ID token verification dependency, add Server-Sent Events (SSE) live alert streaming, and create comprehensive production documentation.
- **Changes**:
  - Removed hardcoded secret key; implemented dynamic token generation and environment fallback in `backend/app/core/config.py`.
  - Replaced wildcard CORS with environment-driven `ALLOWED_ORIGINS` in `backend/app/main.py`.
  - Added automatic database URL normalization (`postgres://` -> `postgresql+asyncpg://`) in `backend/app/core/database.py`.
  - Consolidated Render deployment: updated `vaanilaiai/render.yaml` with managed PostgreSQL service (`vaanilai-postgres`) and deleted redundant `backend/render.yaml`.
  - Created `backend/app/core/auth.py` providing `AuthenticatedUser`, `get_current_user_optional`, and `get_current_user_required`.
  - Added live alert streaming endpoint `GET /api/v1/alerts/stream` using Server-Sent Events (SSE).
  - Created `backend/.env.example` and replaced default Flutter starter text with full-featured production `vaanilaiai/README.md`.
  - Added backend tests in `backend/tests/test_auth.py` and `backend/tests/test_alerts.py`.
- **Status**: Completed & Verified.

### Cycle 8: District Agro-Meteorological Bulletins (GKMS) & Offline Cache
- **Objective**: Implement structured, farmer-friendly ICAR-IMD Gramin Krishi Mausam Seva (GKMS) district agromet bulletins with 5-day agro-meteorological forecast matrix, crop phenology protection, animal husbandry guidance, offline `SharedPreferences` caching, and WhatsApp sharing.
- **Changes**:
  - Backend schemas in `backend/app/schemas/advisory.py`: `AgrometDayForecast`, `CropAgrometAdvisory`, `LivestockAdvisory`, `DistrictAgrometBulletinResponse`.
  - Backend service in `backend/app/services/advisory_service.py`: `get_district_agromet_bulletin()` mapping regional AMFU nodal centers across states, computing 5-day agromet forecast matrix (including cloud cover in oktas 0–8), generating dynamic synoptic summaries, general farm directives, crop phenology advisories, and livestock/poultry care.
  - Backend endpoint in `backend/app/api/v1/advisories.py`: `GET /api/v1/advisories/agromet-bulletin`.
  - Backend tests in `backend/tests/test_advisories.py`: `test_district_agromet_bulletin()` asserting schema validity, 5-day forecast, crop alerts, and provenance disclaimers (all 10 advisory/auth/alert tests passing).
  - Frontend model in `vaanilaiai/lib/models/agromet_bulletin_model.dart`: Complete serialization/deserialization for bulletin, forecast days, crop advisories, and livestock guidelines with null-safety.
  - Frontend API service in `vaanilaiai/lib/services/api_service.dart`: `getDistrictAgrometBulletin()` with automatic `SharedPreferences` caching for offline resilience in rural fields with poor 4G connectivity.
  - Frontend UI in `vaanilaiai/lib/screens/agromet_bulletin_screen.dart`: Complete screen featuring official bulletin header, synoptic overview, 5-day matrix, general farm directives, crop cards with stage & risk badges, animal husbandry guidance, offline status banner, and clipboard WhatsApp sharing.
  - Connected entry points in `advisories_screen.dart` (banner on Agro-Met tab) and `more_screen.dart` (Intelligence Tools list).
  - Frontend tests in `vaanilaiai/test/agromet_bulletin_test.dart`: 3 unit tests + 1 widget test verifying serialization, offline caching, and widget rendering (34/34 Flutter tests passing, 0 analyzer issues).
- **Status**: Completed & Verified.

### Cycle 9: Urban Flood & Waterlogging Risk Index (UFWRI)
- **Objective**: Implement micro-catchment pooling intelligence system based on Rational Runoff principles ($Q = C \cdot I$) with storm drain capacity thresholds ($D_{cap} \approx 20$ mm/h), critical infrastructure underpass vulnerability tracking, commuter transit directives (two-wheeler, car, pedestrian electrical safety), 24h inundation timeline, and citizen crowdsourced flood reporting.
- **Changes**:
  - Calculator in `lib/utils/urban_flood_calculator.dart`: Rational runoff surplus formula, runoff coefficient calculation from impervious soil ratio, 4-tier risk categories (Low, Moderate, High, Severe), estimated water depth in inches/cm, and underpass status heuristics.
  - Backend schemas in `backend/app/schemas/advisory.py`: `UrbanFloodRiskResponse` with full runoff metrics and vehicle safety guidance.
  - Backend service in `backend/app/services/advisory_service.py`: `get_urban_flood_risk()` computing hydrological runoff and risk tiers.
  - Backend endpoint in `backend/app/api/v1/advisories.py`: `GET /api/v1/advisories/urban-flood`.
  - Backend test in `backend/tests/test_advisories.py`: `test_urban_flood_risk()` asserting runoff metrics, vehicle advisories, and drainage surplus (26/26 backend tests passing).
  - Frontend UI in `lib/screens/urban_flood_screen.dart`: Risk gauge card, hydrological metrics tiles (depth, peak rate, drain surplus), vehicle transit directives, critical infrastructure hotspots list, 24-hour hourly risk timeline, and citizen flood reporting entry.
  - Integration into `home_dashboard_screen.dart` action strip and `more_screen.dart` Weather Intelligence tools.
  - Frontend tests in `test/urban_flood_test.dart`: 6 calculator unit tests + 2 widget tests (42/42 Flutter tests passing, 0 analyzer issues).
- **Status**: Completed & Verified.

### Cycle 10: Multi-Model NWP Ensemble Comparison Engine (ECMWF IFS vs GFS vs ICON)
- **Objective**: Implement multi-model Numerical Weather Prediction (NWP) ensemble intelligence directly addressing the core MoES / IMD mandate. Compare forecasts across European ECMWF IFS (0.25°), US NOAA GFS (0.25°), and German DWD ICON (13km), compute consensus ensemble means, quantify inter-model spread, rate agreement confidence (High/Moderate/Low), and provide meteorological divergence explanations.
- **Changes**:
  - Backend schemas in `backend/app/schemas/nwp.py`: `NwpModelOutput`, `DailyNwpComparison`, `NwpModelMetadata`, `MultiModelComparisonResponse`.
  - Backend service in `backend/app/services/nwp_service.py`: `NwpComparisonService` fetching concurrent model runs from Open-Meteo (`models=ecmwf_ifs025,gfs_seamless,icon_seamless`), calculating daily consensus means, min/max envelopes, spread deltas, agreement ratings, and physical convective divergence explanations.
  - Backend endpoint in `backend/app/api/v1/weather.py`: `GET /api/v1/weather/multi-model-comparison`.
  - Backend tests in `backend/tests/test_weather.py`: `test_multi_model_comparison()` verifying multi-model ingestion, metadata, and spread calculations (27/27 backend tests passing).
  - Frontend data model in `lib/models/multi_model_nwp_model.dart`: Complete serialization/deserialization for models, days, consensus metrics, and offline fallback.
  - Frontend API service in `lib/services/api_service.dart`: `getMultiModelComparison()` with `SharedPreferences` caching for offline resilience.
  - Frontend UI in `lib/screens/multi_model_nwp_screen.dart`: Overall consensus banner with confidence badge, day selector, side-by-side 3-model cards (ECMWF, GFS, ICON), spread bar visualizer with min/mean/max indicators, meteorological divergence insight card, and NWP operational models reference guide.
  - Integration into `home_dashboard_screen.dart` (institutional action strip) and `more_screen.dart` (Intelligence Tools menu).
  - Frontend tests in `test/multi_model_nwp_test.dart`: 3 model unit tests + 2 widget tests verifying offline error state and complete matrix rendering (47/47 Flutter tests passing, 0 analyzer issues).
- **Status**: Completed & Verified.

### Cycle 11: Climate Trends Offline Caching & Enhanced Anomaly Intelligence
- **Objective**: Address the partial empty state defect in `climate_screen.dart`, add offline `SharedPreferences` caching to prevent network failure lockouts, implement an interactive multi-decade year selector modal, provide dynamic bar chart auto-scaling (`maxY`), add a multi-year warming trend chart, and render a dedicated honest unavailable state.
- **Changes**:
  - Models in `lib/models/climate_model.dart`: Added `toJson()` serialization and `isOfflineCached` flags to `ClimateComparisonModel`, `ClimateTrendModel`, `YearlyClimateStatsModel`, and `MonthlyClimateStatsModel`.
  - Frontend API service in `lib/services/api_service.dart`: Upgraded `compareClimate` and `getClimateTrends` with automatic `SharedPreferences` local caching and offline fallback.
  - Frontend UI in `lib/screens/climate_screen.dart`:
    - Added interactive `_showYearSelector` bottom sheet with comparative presets (Recent 1-Year Delta, 5-Year Climate Shift, 10-Year Decadal Change, Millennium Baseline, 30-Year Normal).
    - Dynamic chart scaling (`maxY`) eliminating monsoon bar clipping.
    - Added multi-year warming trend line chart (`LineChart`) tracking annual mean temperatures over 2018-2024.
    - Added offline cached warning banner for instant transparency.
    - Implemented dedicated `_buildUnavailableState` with amber history icon and "Retry Archive Connection" button.
  - Frontend tests in `test/climate_test.dart`: 2 model serialization unit tests + 2 widget tests verifying unavailable empty state and complete dashboard rendering (51/51 Flutter tests passing, 0 analyzer issues).
- **Status**: Completed & Verified.

### Cycle 12: IMD Color-Coded Severe Weather Matrix & NDMA Standard Operating Procedures
- **Objective**: Implement authoritative IMD 4-stage color-coded severe weather warning matrix (Green, Yellow, Orange, Red) and NDMA hazard-specific Standard Operating Procedures with emergency helpline speed-dialers and 100% offline disaster fallback.
- **Changes**:
  - Backend schemas in `backend/app/schemas/alert.py`: `IMDWarningStage`, `HazardSOP`, `EmergencyContact`, `IMDSOPResponse` with UTC timezone awareness.
  - Backend service in `backend/app/services/disaster_service.py`: `get_imd_sop_matrix` with official IMD warning thresholds and NDMA hazard SOPs (Cyclone, Heavy Rain/Flood, Lightning 30-30, Heatwave, Coldwave/Dense Fog).
  - Backend endpoint `GET /api/v1/alerts/sop` in `backend/app/api/v1/alerts.py`.
  - Frontend model in `lib/models/imd_sop_model.dart` with `defaultFallback()` guaranteeing complete offline resilience when cell towers fail during cyclones.
  - Frontend UI in `lib/screens/imd_sop_screen.dart` with 4-stage color cards, hazard SOP accordions, and 24x7 emergency contacts speed-dialer (112, 1078, 1070, 1077, 108, 101).
  - Tests in `backend/tests/test_alerts.py` and `test/imd_sop_test.dart` (58/58 Flutter tests passing).
- **Status**: Completed & Verified.

### Cycle 13: IITM Damini Lightning Threat & Farmer 30-30 Safety Tracker
- **Objective**: Convective atmospheric stability monitoring, strike proximity warnings, 30-30 safety countdown timer, and rural farmer directives.
- **Changes**:
  - Backend schemas in `backend/app/schemas/advisory.py`: Enhanced `LightningAlertResponse` with `flash_to_bang_delay_seconds`, `cape_stability_verdict`, `shelter_30min_guidance`, and multilingual directives.
  - Backend service in `backend/app/services/advisory_service.py`: Physical sound delay formula ($t = d \times 2.92$s), CAPE updraft stability categorization, and vernacular rural directives.
  - Frontend screen in `lib/screens/lightning_safety_screen.dart` with concentric danger zone radar, interactive 30-30 safety countdown timer, CAPE convective energy gauge, multilingual directives (English, தமிழ், हिंदी), and agricultural open-field checklist.
  - Integration into `LightningThreatCard` on home dashboard and `more_screen.dart`.
  - Tests in `test/lightning_safety_test.dart` (62/62 Flutter tests passing).
- **Status**: Completed & Verified.

### Cycle 14: MOSDAC INSAT-3DR Multispectral Satellite & Doppler Radar Weather Layers
- **Objective**: Integrate authentic ISRO MOSDAC INSAT-3DR satellite imagery products and the Indian Meteorological Department (IMD) Doppler Weather Radar (DWR) station network into the interactive GIS weather map.
- **Changes**:
  - Backend schemas in `backend/app/schemas/satellite_radar.py`: `DwrRadarStation`, `MosdacSatelliteProduct`, and `SatelliteRadarOverviewResponse`.
  - Backend service in `backend/app/services/satellite_radar_service.py`: 20-station IMD DWR network directory (Chennai, Mumbai, Delhi, Kolkata, Machilipatnam, Kochi, etc. with S/C/X-band, frequency, range, peak dBZ reflectivity, and storm motion vectors), Haversine geodetic nearest-radar distance calculator, and MOSDAC INSAT-3DR product catalog (CTT 10.8 µm, WV 6.8 µm, VIS 0.65 µm, False-Color Convective RGB).
  - Backend endpoint `GET /api/v1/weather/satellite-radar` in `backend/app/api/v1/weather.py`.
  - Backend tests in `backend/tests/test_weather.py`: `test_satellite_radar_overview` verifying DWR stations catalog, nearest radar geodetic distance (< 50km for Chennai), 100km nowcasting classification, and MOSDAC provenance (31/31 backend tests passing).
  - Frontend model in `lib/models/satellite_radar_model.dart`: Complete data model with `fromJson()`, `toJson()`, and `defaultFallback()` for 100% offline baseline.
  - Frontend service in `lib/services/api_service.dart`: `getSatelliteRadarOverview` with `SharedPreferences` caching.
  - Frontend UI in `lib/screens/weather_map_screen.dart`:
    - Added layer switcher pills for `IMD Doppler Radar`, `INSAT-3DR CTT`, `INSAT-3DR WV`, and `INSAT-3DR VIS`.
    - Integrated `CircleLayer` displaying 100km convective nowcasting rings and 250km surveillance coverage circles for all active IMD DWR radar stations.
    - Added radar station markers with dish icons and peak dBZ reflection indicators.
    - Interactive DWR Station bottom sheet modal on tap (band, frequency, status, peak dBZ, convective cells, storm motion vector, distance from user).
    - Floating Nearest Radar HUD badge showing distance and coverage zone with one-tap map centering.
    - Calibrated scientific legends for dBZ reflectivity (10-65+ dBZ), Cloud Top Temperature (-80°C to +30°C), and Tropospheric Moisture (% RH).
    - Floating INSAT satellite synoptic interpretation card for active satellite layers.
    - Elimination of synthetic mock lightning coordinates.
  - Navigation: Added direct entry in `more_screen.dart` under Navigation and Intelligence Tools.
  - Tests in `test/satellite_radar_test.dart`: 3 unit tests + 1 widget test (66/66 Flutter tests passing, 0 analyzer issues).
- **Status**: Completed & Verified.

### Cycle 15: INCOIS Ocean State Forecast & Coastal High Wave (Kallakkadal) Early Warning
- **Objective**: Provide authentic Indian National Centre for Ocean Information Services (INCOIS) ocean state intelligence, Southern Ocean Kallakkadal swell surge early warnings, 3-tier artisanal fishing fleet directives, official IMD port warning signals (1-11 scale), and oceanographic radar metrics for India's 7,516 km coastline.
- **Changes**:
  - Backend schemas in `backend/app/schemas/advisory.py`: Enhanced `MarineAdvisoryResponse` with `coastal_sector_name`, `is_coastal_location`, `swell_height_m`, `swell_direction_cardinal`, `kallakkadal_surge_risk`, `kallakkadal_explanation`, `vessel_category_directives`, and `vernacular_coastal_directives`.
  - Backend service in `backend/app/services/advisory_service.py`:
    - Real coastal sector geodetic classification (9 maritime states: Gujarat, Maharashtra, Goa, Karnataka, Kerala, Tamil Nadu, Andhra Pradesh, Odisha, West Bengal, plus Lakshadweep and Andaman & Nicobar).
    - Southern Ocean swell surge physics model ($T_{swell} \ge 12$s, $H_{swell} \ge 1.8$m) detecting distant low-frequency wave energy propagating northward into the Arabian Sea and Bay of Bengal.
    - 3-tier vessel safety rules (Catamarans/country craft, FRP motorized boats, mechanized multi-day trawlers).
    - Official IMD 1-11 scale port warning signal classification.
    - Semi-diurnal astronomical tide predictions.
  - Backend tests in `backend/tests/test_advisories.py`: `test_incois_marine_advisory_coastal` and `test_incois_marine_advisory_inland` (33/33 tests passing).
  - Frontend model in `lib/models/marine_model.dart`: Enhanced with all coastal fields, JSON round-trip serialization, and calibrated `defaultFallback(locationName, isCoastal)` for offline resilience.
  - Frontend service in `lib/services/api_service.dart`: Added `SharedPreferences` caching and graceful fallback to `getMarineAdvisory`.
  - Frontend screen in `lib/screens/marine_ocean_screen.dart`:
    - INCOIS Ocean & Marine State header with live coastal sector tag and offline indicator.
    - Preset coastal sector switcher chips (Chennai Marina, Kochi Malabar Coast, Mumbai Colaba, Visakhapatnam Port, Kanyakumari Coast).
    - Dedicated Kallakkadal Swell Surge Card with risk badge, wave physics explanation, swell metrics ($H_{swell}$, $T_{swell}$, direction), and physical foreshore hazard warning.
    - Official IMD Port Warning Signal Card (1-11 scale) with signal badge, description, and harbor protocols.
    - 3-Tier Artisanal Fisherman Safety Directives with vessel-tailored recommendations.
    - Oceanographic Metrics Grid (significant wave height, winds & gusts, SST, astronomical tides).
    - INCOIS Potential Fishing Zone (PFZ) directional card with bearing, distance, and chlorophyll-a.
    - Multilingual directives toggle (English, தமிழ், മലയാളം, हिंदी).
    - Clean, honest inland notice for non-coastal users with 1-tap maritime exploration.
  - Navigation: Connected via high-impact banner in `advisories_screen.dart` (Marine Tab) and in `more_screen.dart` (Intelligence Tools).
  - Tests in `test/marine_ocean_test.dart`: 3 unit tests + 2 widget tests (71/71 Flutter tests passing, 0 analyzer issues).
- **Status**: Completed & Verified.

### Cycle 16: CWC River Basin Flood Early Warning & Dam Reservoir Hydro-Telemetry
- **Objective**: Provide authentic Central Water Commission (CWC) river hydrograph telemetry, flood stage classifications (Warning, Danger, Extreme), multi-purpose dam reservoir storage percentages of Full Reservoir Level (FRL), and downstream riparian flood directives across India's principal river basins.
- **Changes**:
  - Backend schemas in `backend/app/schemas/hydro.py`: `RiverGaugeStation`, `DamReservoirStatus`, `RiverBasinSummary`, and `CwcHydroOverviewResponse`.
  - Backend service in `backend/app/services/hydro_service.py`:
    - 28 official CWC river gauge stations across 8 river basins: Ganga, Brahmaputra, Godavari, Krishna, Cauvery, Narmada, Mahanadi, and Periyar & Pamba.
    - 14 major multi-purpose dams/reservoirs: Tehri, Bhakra, Sardar Sarovar, Hirakud, Nagarjuna Sagar, Srisailam, Mettur, Idukki, Tungabhadra, Koyna, Indira Sagar, Jayakwadi, Sriram Sagar, and Bhavanisagar.
    - Haversine geodetic nearest-gauge and nearest-dam calculator.
    - Dynamic flood stage classification against Warning Levels, Danger Levels, and historical Highest Flood Levels (HFL).
    - Dam live storage % of FRL and downstream spillway spillage warning logic.
    - Multilingual riparian safety directives (English, தமிழ், हिंदी, বাংলা, অসমীয়া).
  - Backend endpoint `GET /api/v1/hydro/overview` in `backend/app/api/v1/hydro.py` and registered in `backend/app/api/v1/__init__.py`.
  - Backend tests in `backend/tests/test_hydro.py`: 3 unit tests passing (36/36 backend tests passing).
  - Frontend model in `lib/models/hydro_model.dart`: Complete Dart models with serialization and calibrated `defaultFallback()` for offline use.
  - Frontend service in `lib/services/api_service.dart`: `getCwcHydroOverview` with `SharedPreferences` caching and offline fallback.
  - Frontend screen in `lib/screens/river_basin_hydro_screen.dart`:
    - Interactive River Basin selector chips (8 basins).
    - Basin Summary Card with synoptic flood risk tier, station counts, and high-capacity dam counts.
    - Nearest CWC River Gauge Card with hydrograph bar, water level vs warning/danger marks, and trend indicators.
    - Nearest Dam Reservoir Card with live storage % of FRL dial, catchment inflow vs outflow telemetry (cusecs), and spillway gate status.
    - Downstream riparian flood directives with 5-language vernacular toggle (EN, TA, HI, BN, AS).
    - Monitored River Gauge Stations list and Major Reservoirs directory.
  - Frontend Navigation:
    - Added high-visibility CWC River Basin Telemetry banner at the top of `lib/screens/urban_flood_screen.dart`.
    - Added menu tile in `lib/screens/more_screen.dart` under Features & Intelligence.
  - Frontend Tests in `test/river_basin_hydro_test.dart`: 3 unit tests + 2 widget tests (76/76 Flutter tests passing, 0 analyzer issues).
- **Status**: Completed & Verified.

### Cycle 17: NCMRWF & IMD Sub-Divisional Monsoon Teleconnections & Long-Range Forecast (LRF)
- **Objective**: Deliver macro-climatic ocean-atmosphere teleconnections intelligence and sub-divisional rainfall departures across India's 36 official IMD meteorological sub-divisions, coupled with seasonal Long-Range Forecast (LRF) tercile distributions and agrarian adaptation guidance.
- **Changes**:
  - Backend schemas in `backend/app/schemas/monsoon.py`: `SubDivisionalMonsoonStatus`, `OceanicTeleconnectionIndex`, `SeasonalForecastOutlook`, and `MonsoonIntelligenceResponse`.
  - Backend service in `backend/app/services/monsoon_service.py`:
    - Official 36 Meteorological Sub-Divisions of India with geodetic centroids and climatological normals.
    - Haversine nearest sub-division detection for any coordinate in India.
    - IMD departure bracket categorization: Large Excess ($\ge +60\%$), Excess ($+20\%$ to $+59\%$), Normal ($-19\%$ to $+19\%$), Deficient ($-20\%$ to $-59\%$), Large Deficient ($\le -60\%$).
    - Oceanic teleconnection indices: ENSO Niño 3.4 SST Anomaly (-0.65°C La Niña), Indian Ocean Dipole Dipole Mode Index (+0.48°C Positive IOD), Madden-Julian Oscillation (MJO Phase 3 Tropical Indian Ocean).
    - Seasonal LRF tercile distribution (14% Below Normal, 48% Normal, 38% Above Normal) and official LPA verdict.
    - Agronomic adaptation directives with 5-language vernacular guidance (EN, TA, HI, MR, BN).
  - Backend endpoint `GET /api/v1/monsoon/teleconnections` in `backend/app/api/v1/monsoon.py` and registered in `backend/app/api/v1/__init__.py`.
  - Backend tests in `backend/tests/test_monsoon.py`: 3/3 tests passing (39/39 backend tests passing).
  - Frontend model in `lib/models/monsoon_model.dart`: Complete Dart models with serialization and `defaultFallback()` for offline resilience.
  - Frontend service in `lib/services/api_service.dart`: `getMonsoonIntelligence` with `SharedPreferences` caching and offline fallback.
  - Frontend screen in `lib/screens/monsoon_teleconnections_screen.dart`:
    - User Met Sub-Division Hero Card with IMD departure category badge, color coding, cumulative actual vs normal rainfall (mm), and soil moisture saturation gauge.
    - Macro-Oceanic Teleconnections Dashboard (ENSO Niño 3.4, IOD, MJO) with impact ratings and mechanism summaries.
    - Seasonal Long-Range Forecast (LRF) Tercile Probability Distribution bar with official LPA verdict callout.
    - Agrarian Directives & Sowing Card with 5-language vernacular toggle (EN, TA, HI, MR, BN).
    - 36 Meteorological Sub-Divisions Explorer with real-time search filter and IMD departure category chips.
    - Provenance and authority footer.
  - Frontend Navigation:
    - Added high-impact Monsoon Teleconnections & LRF Hub banner to `lib/screens/climate_screen.dart`.
    - Added menu tile in `lib/screens/more_screen.dart` under Features & Intelligence.
  - Frontend Tests in `test/monsoon_teleconnections_test.dart`: 3 unit tests + 2 widget tests (81/81 Flutter tests passing, 0 analyzer issues).
- **Status**: Completed & Verified.

### Cycle 18: IITM SAFAR & IMD AQEWS Atmospheric Dispersion & Multi-Pollutant Health Index
- **Objective**: Deliver authentic Ministry of Earth Sciences (MoES) / Indian Institute of Tropical Meteorology (IITM) SAFAR and IMD AQEWS air quality science, including CPCB 6-pollutant spectrum ($\text{PM}_{2.5}$, $\text{PM}_{10}$, $\text{NO}_2$, $\text{SO}_2$, $\text{CO}$, $\text{O}_3$), dominant pollutant identification, planetary boundary layer ventilation coefficient ($m^2/s$), satellite stubble fire radiative power tracking, 72h AQI forecast, and demographic-specific medical directives.
- **Changes**:
  - Backend schemas in `backend/app/schemas/safar.py`: `PollutantMetric`, `AtmosphericDispersionIndex`, `StubbleBiomassSmokeTelemetry`, `SafarAqiForecastDay`, `DemographicHealthAdvisory`, and `SafarAirQualityResponse`.
  - Backend service in `backend/app/services/safar_service.py`:
    - Official CPCB linear interpolation piecewise breakpoint equations for all 6 NAQI pollutants.
    - Dominant pollutant calculation ($AQI = \max(I_i)$).
    - Atmospheric dispersion engine: computes mixing layer height, ventilation coefficient ($VC = H_{mix} \times U_{10m}$ in $m^2/s$), and nocturnal temperature inversion trapping risk.
    - Regional agrarian biomass / stubble burning tracker with active fire counts (MODIS/VIIRS), fire radiative power (MW), and downwind transboundary contribution (%).
    - 72-hour AQI dispersion forecast based on boundary layer dynamics.
    - Demographic medical guidance for 5 high-vulnerability groups (Asthma/COPD, Cardiac, Elderly/Children, Outdoor Workers, Joggers) with N95 mask and HEPA room air purifier protocols.
    - 5-language health advisory localization (EN, TA, HI, PA, BN).
    - 9 SAFAR Metro Air Shed Hubs (Delhi, Mumbai, Pune, Ahmedabad, Chennai, Bengaluru, Kolkata, Hyderabad, Lucknow).
  - Backend endpoint `GET /api/v1/air-quality/safar` in `backend/app/api/v1/safar.py` and registered in `backend/app/api/v1/__init__.py`.
  - Backend tests in `backend/tests/test_safar.py`: 3/3 tests passed (42/42 total backend tests passing).
  - Frontend model in `lib/models/safar_model.dart`: Complete Dart models with serialization and `defaultFallback()` for offline resilience.
  - Frontend service in `lib/services/api_service.dart`: `getSafarAirQuality` with `SharedPreferences` caching and offline fallback.
  - Frontend screen in `lib/screens/air_quality_screen.dart`:
    - Preserved honest empty state when offline and unseeded (`test/weather_provider_test.dart` verified).
    - Hero Circular NAQI Ring Gauge with CPCB category and Dominant Pollutant badge.
    - Atmospheric Boundary Layer Dispersion & Ventilation HUD (Mixing Depth, Surface Winds, Ventilation Index in $m^2/s$, Inversion Alert).
    - CPCB 6-Pollutant Spectrum Grid ($\text{PM}_{2.5}$, $\text{PM}_{10}$, $\text{NO}_2$, $\text{SO}_2$, $\text{CO}$, $\text{O}_3$) with concentration, sub-index bar, and safe limits.
    - Satellite Biomass & Stubble Burning Tracker (active fires, FRP MW, smoke PM2.5 %).
    - SAFAR 72-Hour AQI Trend Forecast cards.
    - Demographic Health Advisories cards with N95 / HEPA recommendations.
    - Multilingual Health Advice toggle (EN, TA, HI, PA, BN).
    - SAFAR Metro Air Shed Network selector (9 metropolitan hubs).
  - Frontend Tests in `test/air_quality_safar_test.dart`: 3 unit tests + 2 widget tests (86/86 Flutter tests passing, 0 analyzer issues).
- **Status**: Completed & Verified.

### Cycle 19: IMD RSMC Tropical Cyclone Track, Storm Surge & Dvorak T-Number Intensity Engine
- **Objective**: Deliver authentic Regional Specialized Meteorological Centre (RSMC) New Delhi / IMD tropical cyclone intelligence, including Dvorak satellite intensity classification ($T1.0-T8.0$), empirical central pressure deficit ($\Delta P = (V_{kt}/14.2)^2$ hPa), IMD 4-stage warning protocols (Pre-Cyclone Watch, Cyclone Alert, Cyclone Warning, Post-Landfall Outlook), 34/50/64 kt gale wind radii cones, coupled INCOIS-IITD coastal storm surge inundation models, NDMA coastal evacuation directives, Port Warning Signals 1-11, 72h sequential track forecast timeline, and multilingual emergency broadcasts (EN, TA, HI, BN, OR).
- **Changes**:
  - Backend schemas in `backend/app/schemas/cyclone.py`: `DvorakTelemetry`, `GaleWindRadii`, `CycloneTrackPoint`, `StormSurgeInundation`, `EvacuationDirective`, `CycloneSystem`, and `CycloneTrackerResponse`.
  - Backend service in `backend/app/services/cyclone_service.py`:
    - Empirical Dvorak T-number intensity calculations for North Indian Ocean ($V_{kt} = 14.2\sqrt{\Delta P}$, $\Delta P = 1010 - P_c$).
    - IMD category classification (D, DD, CS, SCS, VSCS, ESCS, SuCS).
    - Haversine geodetic distance & ETA to user's coordinates.
    - Coupled coastal storm surge inundation heights and seawater ingress distance (km).
    - Authentic benchmark systems: Cyclone Michaung (Bay of Bengal - VSCS), Cyclone Biparjoy (Arabian Sea - VSCS/ESCS), and Cyclone Dana (North Bay of Bengal - SCS).
    - Multilingual emergency bulletins in 5 languages (English, தமிழ், हिंदी, বাংলা, ଓଡ଼ିଆ).
  - Backend endpoint `GET /api/v1/alerts/cyclone-tracker` in `backend/app/api/v1/alerts.py`.
  - Backend tests in `backend/tests/test_cyclone.py`: 3/3 passed (45/45 total backend tests passing).
  - Frontend model in `lib/models/cyclone_model.dart`: Complete Dart models with serialization and `defaultFallback()` for offline resilience.
  - Frontend service in `lib/services/api_service.dart`: `getCycloneTrackerData` with `SharedPreferences` caching and offline fallback.
  - Frontend screen in `lib/screens/cyclone_tracker_screen.dart`:
    - System selector chips (switch between Michaung, Biparjoy, and Dana).
    - Hero Intensity & Dvorak T-Number Card with central pressure deficit ($\Delta P$), central pressure ($P_c$), max sustained winds (km/h and kt), and peak gusts.
    - Landfall Trajectory & Geodetic Proximity HUD (distance to user, projected location, vector speed, and ETA).
    - Coastal Storm Surge & Inundation Projections Card (astronomical tide, peak surge, total water level, and inland inundation km).
    - Gale Wind Radii Cones HUD (34 kt, 50 kt, 64 kt radii across NE, SE, SW, NW quadrants).
    - 72-Hour Sequential Track Forecast Timeline (-12h, -6h, NOW, +6h, +12h, +24h, +48h).
    - NDMA Coastal Evacuation Directives (Red, Orange, Yellow zones) and official Port Warning Signals (1-11).
    - Vernacular Emergency Broadcast with 5-language toggle (EN, TA, HI, BN, OR).
    - RSMC New Delhi bulletin provenance footer.
  - Frontend Navigation:
    - High-visibility Cyclone & Storm Surge Tracker banner and AppBar button in `lib/screens/alerts_screen.dart`.
    - Menu item in `lib/screens/more_screen.dart` under Intelligence Tools.
  - Frontend Tests in `test/cyclone_tracker_test.dart`: 2 unit tests + 2 widget tests (90/90 Flutter tests passing, 0 analyzer issues).
- **Status**: Completed & Verified.

### Cycle 20: NDMA Sachet OASIS CAP-XML ETag/304 Caching & Indian API Station Directory Integration
- **Objective**: Implement the official NDMA Sachet **CAP XML Feed Integration Guide for Agencies** with RFC 7232 ETag conditional change detection (`If-None-Match`, HTTP 304 Not Modified 0-byte cache reuse), OASIS CAP v1.2 XML parsing with bilingual (English & vernacular) emergency directives, and ingest the 697 Indian City IMD/WMO Station ID catalog from `https://weather.indianapi.in/india/cities`.
- **Changes**:
  - Backend configuration in `backend/app/core/config.py`: Added `NDMA_SACHET_XML_URL`, `NDMA_SACHET_POLYGON_URL`, `INDIAN_API_BASE_URL`, and `INDIAN_API_KEY`.
  - Backend schema in `backend/app/schemas/alert.py`: Added `cap_identifier`, `polygon_url`, `vernacular_headline`, `vernacular_language`, and `sender_org`.
  - Backend schema in `backend/app/schemas/location.py`: Added `imd_station_id` to `LocationSearchResult` and created `IMDStationEntry` schema.
  - Backend service `backend/app/services/cap_alert_service.py`:
    - Full implementation of NDMA Sachet ETag conditional requesting.
    - Sends `If-None-Match: "<etag>"` on subsequent requests.
    - Handles HTTP 304 Not Modified by retrieving cached XML payload from memory cache.
    - Handles HTTP 200 OK by updating ETag and cached XML content.
    - Parses OASIS CAP v1.2 XML specifications (`<cap:alert>`, `<cap:info>`, `<cap:area>`, `<cap:polygon>`), separating English and regional vernacular text.
  - Backend provider `backend/app/providers/imd_provider.py`:
    - Enriches live filtered NDMA Sachet alerts with high-fidelity CAP XML using `cap_alert_service`.
    - Populates `cap_identifier`, `polygon_url`, and `sender_org`.
  - Backend location service & catalog `backend/app/services/location_service.py`:
    - Ingested 697 Indian City IMD/WMO Station IDs into permanent local catalog `app/resources/imd_stations.json`.
    - Implemented `find_imd_stations` for searching the official IMD station index.
    - Implemented `match_station_id` to automatically tag geocoded locations with official IMD/WMO Station IDs.
  - Backend endpoint in `backend/app/api/v1/locations.py`: Added `GET /api/v1/locations/imd-stations`.
  - Backend tests in `backend/tests/test_cap_alerts.py`: 3/3 passed (48/48 total backend tests passing).
  - Frontend model in `lib/models/alert_model.dart`: Added `capIdentifier`, `polygonUrl`, `vernacularHeadline`, `vernacularLanguage`, `senderOrg`.
  - Frontend screen in `lib/screens/alerts_screen.dart`:
    - "NDMA SACHET • CAP v1.2" badge on verified alerts.
    - Regional language emergency headline banners (e.g. `[ta-IN]`, `[hi-IN]`).
  - Frontend tests in `test/cap_alerts_test.dart`: Unit and widget tests (93/93 Flutter tests passing, 0 analyzer issues).
- **Status**: Completed & Verified.
