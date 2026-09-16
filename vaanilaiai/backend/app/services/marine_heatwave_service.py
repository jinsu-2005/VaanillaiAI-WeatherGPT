import math
from datetime import datetime, timezone
from typing import Dict, List, Optional
from app.schemas.marine_heatwave import (
    CoralBleachingAlertLevel,
    CoastalSeaFogTelemetry,
    MarineConservationDirectives,
    MarineHeatwaveCategory,
    MarineHeatwaveResponse,
    MarineHeatwaveTelemetry,
    MarineHotspotSector,
    SeaFogRiskTier,
    ThermalStressMetrics,
)


def _haversine_distance_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    r = 6371.0
    d_lat = math.radians(lat2 - lat1)
    d_lon = math.radians(lon2 - lon1)
    a = (
        math.sin(d_lat / 2.0) ** 2
        + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(d_lon / 2.0) ** 2
    )
    c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
    return r * c


class MarineHeatwaveService:
    """INCOIS Ocean State Forecast, MoES Marine Living Resources, and Coral Reef Watch

    operational Marine Heatwave, Coral Bleaching, and Coastal Sea Fog warning service.
    """

    def _build_sectors(self) -> List[MarineHotspotSector]:
        return [
            MarineHotspotSector(
                hotspot_id="gulf_of_mannar_rameshwaram",
                sector_name="Gulf of Mannar Biosphere Reserve & Rameswaram",
                maritime_zone="Gulf of Mannar / Palk Bay",
                state_or_ut="Tamil Nadu",
                latitude=9.2876,
                longitude=79.3129,
                reef_type="Fringing Reef & Patch Reef Complexes",
                dominant_coral_taxa=["Acropora formosa", "Porites lutea", "Montipora digitata", "Favia speciosa"],
                thermal_stress=ThermalStressMetrics(
                    sea_surface_temp_c=31.8,
                    climatological_mmm_c=29.8,
                    sst_anomaly_c=2.0,
                    coral_hotspot_c=2.0,
                    degree_heating_weeks=9.4,
                    bleaching_alert_level=CoralBleachingAlertLevel.ALERT_LEVEL_1,
                ),
                heatwave=MarineHeatwaveTelemetry(
                    category=MarineHeatwaveCategory.CATEGORY_II_STRONG,
                    duration_days=19,
                    peak_anomaly_c=2.4,
                    depth_penetration_m=22.0,
                    pelagic_fish_displacement="Lesser sardines and Indian mackerel displaced to offshore depths (>30m); nearshore artisanal gillnet catch down by 45%.",
                ),
                coastal_fog=CoastalSeaFogTelemetry(
                    is_fog_active=False,
                    sea_air_temp_diff_c=0.8,
                    nautical_visibility_m=8500.0,
                    marine_inversion_height_m=350.0,
                    vts_channel_status="Normal Open Navigation",
                ),
                directives=MarineConservationDirectives(
                    reef_protection_notice="Coral Bleaching Alert Level 1: Widespread bleaching of branching Acropora corals observed across Krusadai and Shingle islands.",
                    diving_tourism_advisory="Prohibit boat anchoring on shallow reef flats (<5m depth); restrict snorkeling tourism to designated sandy entry paths.",
                    artisanal_fisher_guidance="Artisanal fishers advised to set nets in deeper shelf waters (>35m) where cooler thermoclines prevail.",
                    artificial_shading_status="Tamil Nadu Forest Department & SDMRI deploying shade cloth covers over in-situ coral nurseries.",
                ),
            ),
            MarineHotspotSector(
                hotspot_id="lakshadweep_kavaratti",
                sector_name="Lakshadweep Atolls (Kavaratti & Agatti Lagoons)",
                maritime_zone="Southeastern Arabian Sea",
                state_or_ut="Lakshadweep",
                latitude=10.5669,
                longitude=72.6420,
                reef_type="Atoll Lagoon & Barrier Reef Wall",
                dominant_coral_taxa=["Acropora branching corals", "Pocillopora damicornis", "Porites solida", "Goniastrea"],
                thermal_stress=ThermalStressMetrics(
                    sea_surface_temp_c=32.2,
                    climatological_mmm_c=29.5,
                    sst_anomaly_c=2.7,
                    coral_hotspot_c=2.7,
                    degree_heating_weeks=13.5,
                    bleaching_alert_level=CoralBleachingAlertLevel.ALERT_LEVEL_2,
                ),
                heatwave=MarineHeatwaveTelemetry(
                    category=MarineHeatwaveCategory.CATEGORY_III_SEVERE,
                    duration_days=28,
                    peak_anomaly_c=3.1,
                    depth_penetration_m=35.0,
                    pelagic_fish_displacement="Live baitfish (Sprats & Chromis) in lagoons decimated by thermal shock; Skipjack and Yellowfin tuna schools displaced 20 nm offshore.",
                ),
                coastal_fog=CoastalSeaFogTelemetry(
                    is_fog_active=False,
                    sea_air_temp_diff_c=0.5,
                    nautical_visibility_m=12000.0,
                    marine_inversion_height_m=500.0,
                    vts_channel_status="Normal Open Navigation",
                ),
                directives=MarineConservationDirectives(
                    reef_protection_notice="CRITICAL EMERGENCY: Bleaching Alert Level 2 (DHW > 12 °C-weeks). Over 70% of lagoon Acropora corals completely bleached with multi-species mortality.",
                    diving_tourism_advisory="Halt all recreational scuba diving and underwater propeller watercraft in Kavaratti and Bangaram lagoon passages.",
                    artisanal_fisher_guidance="Pole-and-line tuna boats facing acute live bait scarcity. Utilize artificial jigs and venture into deep oceanic upwelling zones.",
                    artificial_shading_status="Urgent ex-situ cryopreservation of coral gametes and seawater pumping over shallow micro-nurseries active.",
                ),
            ),
            MarineHotspotSector(
                hotspot_id="andaman_havelock_swaraj",
                sector_name="Swaraj Dweep (Havelock) & Ritchie's Archipelago",
                maritime_zone="Andaman Sea",
                state_or_ut="Andaman & Nicobar Islands",
                latitude=11.9761,
                longitude=92.9876,
                reef_type="Fringing Reef & Submerged Coral Ridges",
                dominant_coral_taxa=["Diploastrea heliopora", "Porites compressa", "Goniastrea retiformis", "Acropora hyacinthus"],
                thermal_stress=ThermalStressMetrics(
                    sea_surface_temp_c=31.4,
                    climatological_mmm_c=29.6,
                    sst_anomaly_c=1.8,
                    coral_hotspot_c=1.8,
                    degree_heating_weeks=7.2,
                    bleaching_alert_level=CoralBleachingAlertLevel.BLEACHING_WARNING,
                ),
                heatwave=MarineHeatwaveTelemetry(
                    category=MarineHeatwaveCategory.CATEGORY_II_STRONG,
                    duration_days=16,
                    peak_anomaly_c=2.1,
                    depth_penetration_m=28.0,
                    pelagic_fish_displacement="Snappers and Groupers seeking deeper drop-offs (>40m); reef fish diversity temporarily compressed into reef wall caves.",
                ),
                coastal_fog=CoastalSeaFogTelemetry(
                    is_fog_active=False,
                    sea_air_temp_diff_c=1.0,
                    nautical_visibility_m=9500.0,
                    marine_inversion_height_m=400.0,
                    vts_channel_status="Normal Open Navigation",
                ),
                directives=MarineConservationDirectives(
                    reef_protection_notice="Bleaching Warning: Coral bleaching likely across Elephant Beach and Light House reefs. Pigment loss noted in 40% of table corals.",
                    diving_tourism_advisory="Strict no-touch dive protocols; suspend introductory trial dives on shallow bommies to prevent mechanical breakage.",
                    artisanal_fisher_guidance="Avoid spearfishing or bottom-longlining on bleaching reef crests to protect herbivorous parrotfish that graze smothering algae.",
                    artificial_shading_status="Biorock reef restoration pilot active; electrolytic mineral accretion active on nursery frames.",
                ),
            ),
            MarineHotspotSector(
                hotspot_id="gulf_of_kutch_mithapur",
                sector_name="Gulf of Kutch Marine National Park & Mithapur Reef",
                maritime_zone="Northern Arabian Sea",
                state_or_ut="Gujarat",
                latitude=22.4215,
                longitude=68.9912,
                reef_type="Macro-Tidal Intertidal Coral Reef Flat",
                dominant_coral_taxa=["Favia favus", "Turbinaria mesenterina", "Goniopora planulata", "Porites lutea"],
                thermal_stress=ThermalStressMetrics(
                    sea_surface_temp_c=31.0,
                    climatological_mmm_c=29.2,
                    sst_anomaly_c=1.8,
                    coral_hotspot_c=1.8,
                    degree_heating_weeks=6.5,
                    bleaching_alert_level=CoralBleachingAlertLevel.BLEACHING_WARNING,
                ),
                heatwave=MarineHeatwaveTelemetry(
                    category=MarineHeatwaveCategory.CATEGORY_I_MODERATE,
                    duration_days=12,
                    peak_anomaly_c=2.0,
                    depth_penetration_m=15.0,
                    pelagic_fish_displacement="Mudskipper and crab burrow micro-habitats enduring extreme evaporative salinity and heat; prawn migration delayed.",
                ),
                coastal_fog=CoastalSeaFogTelemetry(
                    is_fog_active=False,
                    sea_air_temp_diff_c=1.5,
                    nautical_visibility_m=7000.0,
                    marine_inversion_height_m=280.0,
                    vts_channel_status="Normal Open Navigation",
                ),
                directives=MarineConservationDirectives(
                    reef_protection_notice="Intertidal Reef Warning: Extreme low spring tides expose corals to direct solar radiation and 31°C water pools.",
                    diving_tourism_advisory="Limit tourist walking on Pirotan and Narara intertidal reef flats; coral trampling causes irreversible mortality during thermal stress.",
                    artisanal_fisher_guidance="Traditional Pagadiya fishers advised not to drag tidal stake nets across living coral colonies.",
                    artificial_shading_status="Mangrove buffer reforestation prioritized to minimize hypersaline thermal runoff into reef lagoons.",
                ),
            ),
            MarineHotspotSector(
                hotspot_id="netrani_island_karnataka",
                sector_name="Netrani Island (Pigeon Island) Marine Zone",
                maritime_zone="Central Arabian Sea",
                state_or_ut="Karnataka",
                latitude=14.0175,
                longitude=74.3292,
                reef_type="Rocky Coral Outcrop & Fringing Patches",
                dominant_coral_taxa=["Porites solida", "Dendrophyllia micrantha", "Pocillopora verrucosa"],
                thermal_stress=ThermalStressMetrics(
                    sea_surface_temp_c=30.6,
                    climatological_mmm_c=29.4,
                    sst_anomaly_c=1.2,
                    coral_hotspot_c=1.2,
                    degree_heating_weeks=3.8,
                    bleaching_alert_level=CoralBleachingAlertLevel.BLEACHING_WATCH,
                ),
                heatwave=MarineHeatwaveTelemetry(
                    category=MarineHeatwaveCategory.CATEGORY_I_MODERATE,
                    duration_days=9,
                    peak_anomaly_c=1.5,
                    depth_penetration_m=25.0,
                    pelagic_fish_displacement="Caranx and Barracuda schooling active around pinnacle walls; mild downward shift toward 20m thermocline.",
                ),
                coastal_fog=CoastalSeaFogTelemetry(
                    is_fog_active=False,
                    sea_air_temp_diff_c=0.6,
                    nautical_visibility_m=10000.0,
                    marine_inversion_height_m=450.0,
                    vts_channel_status="Normal Open Navigation",
                ),
                directives=MarineConservationDirectives(
                    reef_protection_notice="Bleaching Watch: Corals under mild thermal accumulation; monitor Acropora colonies on the northern pinnacle for paling.",
                    diving_tourism_advisory="Scuba dive operators must maintain neutral buoyancy checks; no anchoring allowed on coral reef slopes.",
                    artisanal_fisher_guidance="Purse-seine operators cautioned to avoid the 2 km sanctuary buffer around Netrani Island.",
                    artificial_shading_status="Karnataka Forest Department continuous camera-trap and water temperature logger monitoring deployed.",
                ),
            ),
            MarineHotspotSector(
                hotspot_id="malvan_marine_sanctuary",
                sector_name="Malvan Marine Sanctuary (Sindhudurg Reefs)",
                maritime_zone="Konkan Coast / Central Arabian Sea",
                state_or_ut="Maharashtra",
                latitude=16.0583,
                longitude=73.4682,
                reef_type="Submerged Rock Platform & Fringing Coral Communities",
                dominant_coral_taxa=["Coscinaraea monile", "Siderastrea savignyana", "Porites lutea", "Favites abdita"],
                thermal_stress=ThermalStressMetrics(
                    sea_surface_temp_c=30.8,
                    climatological_mmm_c=29.3,
                    sst_anomaly_c=1.5,
                    coral_hotspot_c=1.5,
                    degree_heating_weeks=4.8,
                    bleaching_alert_level=CoralBleachingAlertLevel.BLEACHING_WARNING,
                ),
                heatwave=MarineHeatwaveTelemetry(
                    category=MarineHeatwaveCategory.CATEGORY_I_MODERATE,
                    duration_days=11,
                    peak_anomaly_c=1.8,
                    depth_penetration_m=18.0,
                    pelagic_fish_displacement="Indian mackerel migrating toward cooler coastal upwelling pockets near Vengurla Rocks.",
                ),
                coastal_fog=CoastalSeaFogTelemetry(
                    is_fog_active=False,
                    sea_air_temp_diff_c=1.2,
                    nautical_visibility_m=8000.0,
                    marine_inversion_height_m=320.0,
                    vts_channel_status="Normal Open Navigation",
                ),
                directives=MarineConservationDirectives(
                    reef_protection_notice="Bleaching Warning: Bleaching likely in shallow encrusting corals around Sindhudurg Fort walls.",
                    diving_tourism_advisory="Restrict commercial scuba diving batches to maximum 4 divers per guide to prevent accidental coral fin strikes.",
                    artisanal_fisher_guidance="Artisanal fishers encouraged to participate in citizen science coral health reporting via VaanilaiAI.",
                    artificial_shading_status="Mangrove and Marine Biodiversity Conservation Foundation of Maharashtra monitoring water quality.",
                ),
            ),
            MarineHotspotSector(
                hotspot_id="coastal_sea_fog_jnpt",
                sector_name="JNPT & Mumbai Port Approach Corridor",
                maritime_zone="North Konkan Maritime Corridor",
                state_or_ut="Maharashtra",
                latitude=18.9483,
                longitude=72.9515,
                reef_type="Non-Reef Commercial Maritime Estuary & Shipping Channel",
                dominant_coral_taxa=["Non-Reef Commercial Navigational Fairway"],
                thermal_stress=ThermalStressMetrics(
                    sea_surface_temp_c=25.2,
                    climatological_mmm_c=29.0,
                    sst_anomaly_c=-3.8,
                    coral_hotspot_c=0.0,
                    degree_heating_weeks=0.0,
                    bleaching_alert_level=CoralBleachingAlertLevel.NO_STRESS,
                ),
                heatwave=MarineHeatwaveTelemetry(
                    category=MarineHeatwaveCategory.CATEGORY_I_MODERATE,
                    duration_days=0,
                    peak_anomaly_c=0.0,
                    depth_penetration_m=0.0,
                    pelagic_fish_displacement="Upwelled cold shelf waters driving pelagic fish aggregations; coastal gillnetters reporting bumper catch.",
                ),
                coastal_fog=CoastalSeaFogTelemetry(
                    is_fog_active=True,
                    sea_air_temp_diff_c=4.6,
                    nautical_visibility_m=120.0,
                    marine_inversion_height_m=45.0,
                    vts_channel_status="NAVIGATION RESTRICTED: Mandatory Radar Navigation & 6-Knot Speed Cap",
                ),
                directives=MarineConservationDirectives(
                    reef_protection_notice="Commercial shipping channel — No coral reef systems present.",
                    diving_tourism_advisory="Harbour diving operations suspended due to zero underwater and surface visibility.",
                    artisanal_fisher_guidance="Artisanal fishing trawlers and catamarans must sound fog horns (one prolonged blast every 2 minutes) and display radar reflectors.",
                    artificial_shading_status="JNPT & Mumbai Port Authority operating dual X-band coastal radar tracking for collision avoidance.",
                ),
            ),
        ]

    def _generate_vernacular_bulletins(self, sector: MarineHotspotSector) -> Dict[str, str]:
        if sector.coastal_fog.is_fog_active:
            return {
                "en": (
                    f"INCOIS & PORT VTS ADVISORY: {sector.sector_name} is under DENSE ADVECTION SEA FOG. "
                    f"Nautical visibility has collapsed to {sector.coastal_fog.nautical_visibility_m:.0f}m. "
                    f"Air-sea thermal contrast: +{sector.coastal_fog.sea_air_temp_diff_c:.1f}°C. "
                    f"VTS Status: {sector.coastal_fog.vts_channel_status}. Sound fog signals."
                ),
                "ta": (
                    f"இன்கோயிஸ் துறைமுக எச்சரிக்கை: {sector.sector_name} பகுதியில் கடுமையான கடல் மூடுபனி (Sea Fog) நிலவுகிறது. "
                    f"பார்வைத்திறன் {sector.coastal_fog.nautical_visibility_m:.0f} மீட்டராகக் குறைந்துள்ளது. "
                    f"படகு மற்றும் கப்பல்கள் எச்சரிக்கை சிக்னல் ஒலித்து ரேடார் உதவியுடன் இயக்கவும்."
                ),
                "ml": (
                    f"ഇൻകോയിസ് തുറമുഖ മുന്നറിയിപ്പ്: {sector.sector_name} ൽ ശക്തമായ കടൽ മൂടൽമഞ്ഞ് അനുഭവപ്പെടുന്നു. "
                    f"കാഴ്ചപരിധി {sector.coastal_fog.nautical_visibility_m:.0f} മീറ്ററായി കുറഞ്ഞു. "
                    f"മത്സ്യബന്ധന വള്ളങ്ങൾ ഫോഗ് ഹോൺ മുഴക്കണമെന്നും വേഗത കുറയ്ക്കണമെന്നും നിർദ്ദേശിക്കുന്നു."
                ),
                "gu": (
                    f"ઇન્કોઇસ પોર્ટ એડવાઇઝરી: {sector.sector_name} પર ગાઢ દરિયાઇ ધુમ્મસ (Sea Fog) છવાયેલ છે. "
                    f"દ્રશ્યતા ઘટીને {sector.coastal_fog.nautical_visibility_m:.0f} મીટર થઇ છે. "
                    f"જહાજો અને બોટોને રડાર નેવિગેશનનો ઉપયોગ કરવા અને ફોગ હોર્ન વગાડવા સૂચના."
                ),
                "mr": (
                    f"इनकॉईस व बंदर व्हीटीएस इशारा: {sector.sector_name} येथे दाट सागरी धुके (Advection Sea Fog) पसरले आहे. "
                    f"दृश्यमानता {sector.coastal_fog.nautical_visibility_m:.0f} मीटरवर घसरली आहे. "
                    f"व्हीटीएस स्थिती: {sector.coastal_fog.vts_channel_status}. बोटींनी फॉग हॉर्न वाजवावा."
                ),
            }

        bleach_str = sector.thermal_stress.bleaching_alert_level.value.replace("_", " ")
        mhw_str = sector.heatwave.category.value.replace("_", " ")
        return {
            "en": (
                f"INCOIS & MOES MARINE HEATWAVE BULLETIN: {sector.sector_name} is under {bleach_str} & {mhw_str}. "
                f"SST is {sector.thermal_stress.sea_surface_temp_c:.1f}°C (Anomaly: +{sector.thermal_stress.sst_anomaly_c:.1f}°C). "
                f"Degree Heating Weeks (DHW): {sector.thermal_stress.degree_heating_weeks:.1f} °C-weeks. "
                f"Advisory: {sector.directives.reef_protection_notice}"
            ),
            "ta": (
                f"இன்கோயிஸ் கடல் வெப்ப அலை எச்சரிக்கை: {sector.sector_name} பகுதியில் பவளப்பாறை வெளுத்தல் எச்சரிக்கை நிலை ({bleach_str}) जारी செய்யப்பட்டுள்ளது. "
                f"கடல் மேற்பரப்பு வெப்பநிலை {sector.thermal_stress.sea_surface_temp_c:.1f}°C (இயல்பை விட +{sector.thermal_stress.sst_anomaly_c:.1f}°C அதிகம்). "
                f"டிஹெச்W: {sector.thermal_stress.degree_heating_weeks:.1f} °C-weeks. பவளப்பாறை பகுதிகளில் படகு நங்கூரமிடுவதைத் தவிர்க்கவும்."
            ),
            "ml": (
                f"ഇൻകോയിസ് സമുദ്ര താപതരംഗ മുന്നറിയിപ്പ്: {sector.sector_name} ൽ പവിഴപ്പുറ്റ് വെളുക്കൽ മുന്നറിയിപ്പ് ({bleach_str}) നിലവിലുണ്ട്. "
                f"കടൽ താപനില {sector.thermal_stress.sea_surface_temp_c:.1f}°C (കൂടുതൽ: +{sector.thermal_stress.sst_anomaly_c:.1f}°C). "
                f"ഡിവൺ ചൂട് ആഴ്ചകൾ (DHW): {sector.thermal_stress.degree_heating_weeks:.1f} °C-weeks. ആഴക്കടൽ മത്സ്യബന്ധനം നടത്തുക."
            ),
            "gu": (
                f"ઇન્કોઇસ મરીન હીટવેવ બુલેટિન: {sector.sector_name} વિસ્તારમાં પરવાળાના બ્લીચિંગની ચેતવણી ({bleach_str}). "
                f"દરિયાઈ સપાટીનું તાપમાન {sector.thermal_stress.sea_surface_temp_c:.1f}°C છે (સામાન્ય કરતાં +{sector.thermal_stress.sst_anomaly_c:.1f}°C વધુ). "
                f"ડીએચડબલ્યુ: {sector.thermal_stress.degree_heating_weeks:.1f} °C-weeks. પરવાળાના વિસ્તારોનું રક્ષણ કરો."
            ),
            "mr": (
                f"इनकॉईस सागरी उष्णतेची लाट इशारा: {sector.sector_name} येथे प्रवाळ विरंजन इशारा ({bleach_str}) जारी. "
                f"सागरी तापमान {sector.thermal_stress.sea_surface_temp_c:.1f}°C (+{sector.thermal_stress.sst_anomaly_c:.1f}°C वाढ). "
                f"डीएचडब्ल्यू: {sector.thermal_stress.degree_heating_weeks:.1f} °C-weeks. प्रवाळ खडकांवर नौका नांगरण्यास मनाई."
            ),
        }

    def get_marine_heatwave_assessment(
        self,
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        sector_id: Optional[str] = None,
    ) -> MarineHeatwaveResponse:
        all_sectors = self._build_sectors()

        selected: Optional[MarineHotspotSector] = None
        if sector_id:
            for s in all_sectors:
                if s.hotspot_id.lower() == sector_id.lower():
                    selected = s
                    break

        if not selected and latitude is not None and longitude is not None:
            closest = min(all_sectors, key=lambda s: _haversine_distance_km(latitude, longitude, s.latitude, s.longitude))
            selected = closest

        if not selected:
            selected = all_sectors[0]  # default to Gulf of Mannar

        bulletins = self._generate_vernacular_bulletins(selected)
        now_utc = datetime.now(timezone.utc).isoformat()

        return MarineHeatwaveResponse(
            timestamp=now_utc,
            selected_sector=selected,
            all_sectors=all_sectors,
            vernacular_bulletins=bulletins,
            bulletin_number=f"INCOIS-MHW/CRW/{datetime.now(timezone.utc).strftime('%Y%m')}-SEC{selected.hotspot_id[:3].upper()}",
            provenance="INCOIS Ocean State Forecast, MoES Marine Living Resources & Coral Reef Watch (CRW)",
            is_offline_cached=False,
        )


marine_heatwave_service = MarineHeatwaveService()
