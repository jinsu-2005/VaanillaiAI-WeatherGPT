import math
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional

from app.schemas.glof import (
    BreachHydrodynamics,
    BreachTriggerMechanism,
    DownstreamImpactNode,
    GlacialLakeCorridor,
    GlacialLakeMorphometry,
    GlofResponse,
    GlofThreatTier,
    LakeSummary,
    MoraineDamGeotechnics,
)


class GlofService:
    """
    NRSC-ISRO, CWC & NDMA Himalayan Glacial Lake Outburst Flood (GLOF)
    & Moraine Dam Breach Early Warning Engine.
    """

    # Curated High-Risk Himalayan Glacial Lakes Database
    GLACIAL_LAKES_DB: Dict[str, Dict[str, Any]] = {
        "south_lhonak_sikkim": {
            "lake_id": "south_lhonak_sikkim",
            "lake_name": "South Lhonak Lake (Chungthang / Teesta Basin)",
            "river_basin": "Teesta River Basin",
            "state": "Sikkim",
            "latitude": 27.9150,
            "longitude": 88.2050,
            "elevation_m": 5200.0,
            "threat_tier": GlofThreatTier.CRITICAL_RED_BREACH_IMMINENT,
            "trigger_mechanism": BreachTriggerMechanism.OVERTOPPING_ICE_AVALANCHE_SURGE,
            "surface_area_ha": 168.0,
            "mean_depth_m": 38.0,
            "max_depth_m": 131.0,
            "expansion_rate_10yr_pct": 28.5,
            "satellite_sensor": "Sentinel-1 SAR & RISAT-1A Multi-temporal Interferometry",
            "dam_crest_elevation_m": 5240.0,
            "dam_height_m": 55.0,
            "crest_width_to_height": 1.65,
            "freeboard_height_m": 4.5,
            "permafrost_degradation_pct": 68.0,
            "hydraulic_piping_index": 1.25,
            "stability_status": "CRITICAL PIPING & AVALANCHE OVERTOPPING SUSCEPTIBILITY",
            "wave_speed_kmh": 45.0,
            "breach_time_hours": 0.8,
            "volume_released_pct": 70.0,
            "impact_nodes": [
                {
                    "node_name": "Teesta-III Chungthang Dam",
                    "distance_km": 65.0,
                    "surge_depth_m": 18.5,
                    "alert": "RADIAL GATES FULL FLUSH - Open all bottom spillways immediately to prevent catastrophic barrage overtopping.",
                    "evacuation_elevation_m": 35.0,
                },
                {
                    "node_name": "Mangan District Headquarters",
                    "distance_km": 85.0,
                    "surge_depth_m": 12.0,
                    "alert": "CIVILIAN EVACUATION SIREN - Relocate riverbank settlements to designated municipal high grounds.",
                    "evacuation_elevation_m": 30.0,
                },
                {
                    "node_name": "Dikchu Suspension Bridge & NH-10",
                    "distance_km": 115.0,
                    "surge_depth_m": 8.5,
                    "alert": "HIGHWAY CLOSURE - Border Roads Organisation (BRO) emergency bridge and arterial transit halt.",
                    "evacuation_elevation_m": 25.0,
                },
                {
                    "node_name": "Singtam Municipal Hub",
                    "distance_km": 145.0,
                    "surge_depth_m": 6.2,
                    "alert": "FLOOD PLAIN EVACUATION - Public sirens active. Move beyond the 100-year inundation contour.",
                    "evacuation_elevation_m": 20.0,
                },
                {
                    "node_name": "Rangpo Inter-State Border",
                    "distance_km": 170.0,
                    "surge_depth_m": 4.8,
                    "alert": "BORDER DEFENSE & RESCUE - NDRF/SDRF emergency deployment on Teesta riparian corridor.",
                    "evacuation_elevation_m": 15.0,
                },
            ],
            "directives": [
                "IMMEDIATE EVACUATION: All riverside inhabitants within 200m lateral and 30m vertical from Teesta riverbed must evacuate immediately.",
                "HYDROPOWER DIRECTIVE: Teesta-III, Teesta-IV, and Teesta-V barrages must trigger complete sluice flush to eliminate reservoir backwater damming.",
                "HIGHWAY PASS RESTRICTION: BRO must shut NH-10 connectivity between Siliguri, Gangtok, and North Sikkim.",
                "COMMUNICATION ALERT: Indian Army, ITBP, and NDRF base camps on high-frequency satcom link.",
            ],
        },
        "shako_cho_sikkim": {
            "lake_id": "shako_cho_sikkim",
            "lake_name": "Shako Cho Glacial Lake (Mangan Basin)",
            "river_basin": "Teesta Upper Catchment",
            "state": "Sikkim",
            "latitude": 27.8720,
            "longitude": 88.5830,
            "elevation_m": 4950.0,
            "threat_tier": GlofThreatTier.HIGH_ORANGE_WARNING,
            "trigger_mechanism": BreachTriggerMechanism.INTERNAL_PIPING_SEEPAGE_COLLAPSE,
            "surface_area_ha": 85.0,
            "mean_depth_m": 32.0,
            "max_depth_m": 78.0,
            "expansion_rate_10yr_pct": 34.0,
            "satellite_sensor": "Sentinel-2 MSI & RISAT-1A SAR",
            "dam_crest_elevation_m": 4985.0,
            "dam_height_m": 42.0,
            "crest_width_to_height": 1.85,
            "freeboard_height_m": 6.2,
            "permafrost_degradation_pct": 52.0,
            "hydraulic_piping_index": 0.94,
            "stability_status": "ELEVATED SEEPAGE THROUGH ICE-CORED MORAINE",
            "wave_speed_kmh": 42.0,
            "breach_time_hours": 1.1,
            "volume_released_pct": 60.0,
            "impact_nodes": [
                {
                    "node_name": "Lachen Forward Valley",
                    "distance_km": 40.0,
                    "surge_depth_m": 11.2,
                    "alert": "VALLEY WARNING - High-altitude pastoral camps and BRO road clearing teams alert.",
                    "evacuation_elevation_m": 25.0,
                },
                {
                    "node_name": "Chungthang Confluence",
                    "distance_km": 68.0,
                    "surge_depth_m": 7.5,
                    "alert": "CONFLUENCE SURGE - Inflow monitoring on Teesta main stem.",
                    "evacuation_elevation_m": 20.0,
                },
            ],
            "directives": [
                "HIGH GROUND PROTOCOL: Move all valley livestock and machinery above the historical high-water benchmark.",
                "REMOTE MONITORING: Activate automated water-level sensor telemetry at proglacial outlet.",
                "CIVIC RESTRICTIONS: Prohibit tourist movement towards Lachen-Chungthang axis during nocturnal hours.",
            ],
        },
        "chorabari_uttarakhand": {
            "lake_id": "chorabari_uttarakhand",
            "lake_name": "Chorabari Lake / Gandhi Sarovar (Kedarnath)",
            "river_basin": "Mandakini River Basin",
            "state": "Uttarakhand",
            "latitude": 30.7480,
            "longitude": 79.0550,
            "elevation_m": 3900.0,
            "threat_tier": GlofThreatTier.HIGH_ORANGE_WARNING,
            "trigger_mechanism": BreachTriggerMechanism.OVERTOPPING_ICE_AVALANCHE_SURGE,
            "surface_area_ha": 35.0,
            "mean_depth_m": 18.0,
            "max_depth_m": 35.0,
            "expansion_rate_10yr_pct": 19.5,
            "satellite_sensor": "Cartosat-3 Stereo & Sentinel-1 SAR",
            "dam_crest_elevation_m": 3930.0,
            "dam_height_m": 30.0,
            "crest_width_to_height": 1.70,
            "freeboard_height_m": 5.0,
            "permafrost_degradation_pct": 45.0,
            "hydraulic_piping_index": 0.88,
            "stability_status": "HANGING SERAC GLACIER CALVING SURGE RISK",
            "wave_speed_kmh": 40.0,
            "breach_time_hours": 0.6,
            "volume_released_pct": 65.0,
            "impact_nodes": [
                {
                    "node_name": "Kedarnath Temple Sanctuary Complex",
                    "distance_km": 2.5,
                    "surge_depth_m": 6.8,
                    "alert": "THREE-TIER DEFENSE WALL ACTIVE - Divert flow via eastern and western mountain chutes.",
                    "evacuation_elevation_m": 15.0,
                },
                {
                    "node_name": "Rambara Pilgrimage Transit Hub",
                    "distance_km": 9.0,
                    "surge_depth_m": 5.4,
                    "alert": "PILGRIM TRANSIT HALT - Clear trekking path and riverbed helipads immediately.",
                    "evacuation_elevation_m": 20.0,
                },
                {
                    "node_name": "Gaurikund Base Camp",
                    "distance_km": 16.0,
                    "surge_depth_m": 4.2,
                    "alert": "BASE STATION EVACUATION - Hot water spring and lower bazaar evacuation.",
                    "evacuation_elevation_m": 20.0,
                },
                {
                    "node_name": "Sonprayag Bridge",
                    "distance_km": 21.0,
                    "surge_depth_m": 3.5,
                    "alert": "SHUTTLE STOPPAGE - Halt Kedarnath pilgrim taxi transit.",
                    "evacuation_elevation_m": 15.0,
                },
            ],
            "directives": [
                "PILGRIM LIFE-SAFETY: Trigger acoustic sirens in Kedarnath township; halt all upward foot traffic from Gaurikund.",
                "DEFLECTION WALL MANAGEMENT: Ensure Kedarnath diversion channel remains unblocked by boulder debris.",
                "HELICOPTER EVACUATION STANDBY: Air Force and civil aviation helicopters positioned at Phata and Guptkashi.",
            ],
        },
        "ghepan_gath_himachal": {
            "lake_id": "ghepan_gath_himachal",
            "lake_name": "Ghepan Gath Lake (Lahaul & Spiti)",
            "river_basin": "Chandra River Basin (Chenab)",
            "state": "Himachal Pradesh",
            "latitude": 32.4180,
            "longitude": 77.1650,
            "elevation_m": 4680.0,
            "threat_tier": GlofThreatTier.HIGH_ORANGE_WARNING,
            "trigger_mechanism": BreachTriggerMechanism.INTERNAL_PIPING_SEEPAGE_COLLAPSE,
            "surface_area_ha": 95.0,
            "mean_depth_m": 38.0,
            "max_depth_m": 92.0,
            "expansion_rate_10yr_pct": 42.0,
            "satellite_sensor": "ISRO Bhuvan Sentinel-1 SAR Telemetry",
            "dam_crest_elevation_m": 4725.0,
            "dam_height_m": 48.0,
            "crest_width_to_height": 1.78,
            "freeboard_height_m": 6.8,
            "permafrost_degradation_pct": 58.0,
            "hydraulic_piping_index": 0.96,
            "stability_status": "SUB-SURFACE HYDROSTATIC PIPING DETECTED",
            "wave_speed_kmh": 38.0,
            "breach_time_hours": 1.2,
            "volume_released_pct": 65.0,
            "impact_nodes": [
                {
                    "node_name": "Sissu Village & Atal Tunnel North Portal",
                    "distance_km": 28.0,
                    "surge_depth_m": 9.5,
                    "alert": "TUNNEL PORTAL ALERT - Monitor Chandra river level near Atal Tunnel north approach.",
                    "evacuation_elevation_m": 25.0,
                },
                {
                    "node_name": "Tandi (Chandra-Bhaga Confluence)",
                    "distance_km": 45.0,
                    "surge_depth_m": 6.8,
                    "alert": "CONFLUENCE MONITORING - Alert downstream Keylong and Chenab valley settlements.",
                    "evacuation_elevation_m": 20.0,
                },
            ],
            "directives": [
                "INFRASTRUCTURE PROTECTION: Keep emergency barriers ready at the Atal Tunnel North Portal approach.",
                "RIVERBED CURFEW: Prohibit camping and vehicular movement on Chandra riverbanks between Sissu and Tandi.",
                "HYDRO-POWER ALERT: Druk-Tandi and Sawalkote hydropower surveillance teams on active guard.",
            ],
        },
        "chamoli_ronti_uttarakhand": {
            "lake_id": "chamoli_ronti_uttarakhand",
            "lake_name": "Chamoli / Ronti Glacier Lake (Rishiganga)",
            "river_basin": "Dhauliganga / Alaknanda Basin",
            "state": "Uttarakhand",
            "latitude": 30.3850,
            "longitude": 79.7420,
            "elevation_m": 4400.0,
            "threat_tier": GlofThreatTier.MODERATE_YELLOW_WATCH,
            "trigger_mechanism": BreachTriggerMechanism.OVERTOPPING_ICE_AVALANCHE_SURGE,
            "surface_area_ha": 25.0,
            "mean_depth_m": 15.0,
            "max_depth_m": 28.0,
            "expansion_rate_10yr_pct": 14.0,
            "satellite_sensor": "Cartosat-2 & Sentinel-1 SAR",
            "dam_crest_elevation_m": 4430.0,
            "dam_height_m": 32.0,
            "crest_width_to_height": 2.10,
            "freeboard_height_m": 7.5,
            "permafrost_degradation_pct": 38.0,
            "hydraulic_piping_index": 0.65,
            "stability_status": "MODERATE RISK; HIGH ROCK/ICE DETACHMENT SLOPE",
            "wave_speed_kmh": 44.0,
            "breach_time_hours": 0.5,
            "volume_released_pct": 60.0,
            "impact_nodes": [
                {
                    "node_name": "Raini Village (Chipko Movement Heritage)",
                    "distance_km": 22.0,
                    "surge_depth_m": 6.4,
                    "alert": "RIVERSIDE EVACUATION - Move inhabitants to Raini Chak high ground.",
                    "evacuation_elevation_m": 25.0,
                },
                {
                    "node_name": "Tapovan Vishnugad Hydropower Project",
                    "distance_km": 28.0,
                    "surge_depth_m": 5.2,
                    "alert": "BARRAGE TUNNEL CLEARANCE - Evacuate all headrace and desilting tunnel personnel.",
                    "evacuation_elevation_m": 20.0,
                },
            ],
            "directives": [
                "EARLY WARNING SENSOR TEST: Verify acoustic and vibration tripwires on the Rishiganga gorge.",
                "TUNNEL PROTOCOL: Ensure automated sirens inside Tapovan Vishnugad hydropower tunnels are operational.",
            ],
        },
        "pareechu_himachal": {
            "lake_id": "pareechu_himachal",
            "lake_name": "Pareechu Glacial Lake (Spiti / Tibet Border)",
            "river_basin": "Sutlej River Basin",
            "state": "Himachal Pradesh",
            "latitude": 31.9820,
            "longitude": 78.5850,
            "elevation_m": 4200.0,
            "threat_tier": GlofThreatTier.MODERATE_YELLOW_WATCH,
            "trigger_mechanism": BreachTriggerMechanism.MORAINIC_SLOPE_SLUMPING,
            "surface_area_ha": 65.0,
            "mean_depth_m": 22.0,
            "max_depth_m": 45.0,
            "expansion_rate_10yr_pct": 18.0,
            "satellite_sensor": "RISAT-1A SAR Satellite Altimetry",
            "dam_crest_elevation_m": 4235.0,
            "dam_height_m": 35.0,
            "crest_width_to_height": 2.20,
            "freeboard_height_m": 8.0,
            "permafrost_degradation_pct": 32.0,
            "hydraulic_piping_index": 0.58,
            "stability_status": "STABLE MORAINE DAM WITH CONTINUOUS DEBRIS WATCH",
            "wave_speed_kmh": 36.0,
            "breach_time_hours": 1.5,
            "volume_released_pct": 55.0,
            "impact_nodes": [
                {
                    "node_name": "Khab Confluence (Spiti-Sutlej)",
                    "distance_km": 35.0,
                    "surge_depth_m": 4.8,
                    "alert": "BORDER BRIDGE WATCH - Inspect NH-505 bridge scour and pier foundations.",
                    "evacuation_elevation_m": 15.0,
                },
                {
                    "node_name": "Nathpa Jhakri Hydropower Dam (1500 MW)",
                    "distance_km": 95.0,
                    "surge_depth_m": 3.8,
                    "alert": "DAM SILT MANAGEMENT - Ready desilting chambers and spillway gates.",
                    "evacuation_elevation_m": 15.0,
                },
            ],
            "directives": [
                "TRANS-BOUNDARY MONITORING: Maintain multi-agency remote sensing telemetry across the Spiti-Tibet border.",
                "SUTLEJ DESILTING PROTOCOL: Ready sediment bypass tunnels at Nathpa Jhakri and Karcham Wangtoo.",
            ],
        },
        "dibang_cluster_arunachal": {
            "lake_id": "dibang_cluster_arunachal",
            "lake_name": "Dibang Proglacial Lake Cluster",
            "river_basin": "Dibang / Brahmaputra Basin",
            "state": "Arunachal Pradesh",
            "latitude": 28.7520,
            "longitude": 95.9450,
            "elevation_m": 4800.0,
            "threat_tier": GlofThreatTier.LOW_GREEN_MONITOR,
            "trigger_mechanism": BreachTriggerMechanism.STABLE_WATCH,
            "surface_area_ha": 48.0,
            "mean_depth_m": 20.0,
            "max_depth_m": 40.0,
            "expansion_rate_10yr_pct": 12.0,
            "satellite_sensor": "Sentinel-1 SAR C-band",
            "dam_crest_elevation_m": 4835.0,
            "dam_height_m": 35.0,
            "crest_width_to_height": 2.45,
            "freeboard_height_m": 9.5,
            "permafrost_degradation_pct": 22.0,
            "hydraulic_piping_index": 0.42,
            "stability_status": "STABLE BEDROCK-CONFINED PROGLACIAL DAM",
            "wave_speed_kmh": 35.0,
            "breach_time_hours": 2.0,
            "volume_released_pct": 40.0,
            "impact_nodes": [
                {
                    "node_name": "Anini Valley Settlement",
                    "distance_km": 55.0,
                    "surge_depth_m": 3.2,
                    "alert": "ROUTINE PATROL - River discharge within seasonal baseline envelope.",
                    "evacuation_elevation_m": 15.0,
                },
            ],
            "directives": [
                "BASELINE MAPPING: Periodic satellite radar altimetry comparison every 15 days.",
                "LOCAL ADVISORY: Normal agricultural and transit activity permitted in valley.",
            ],
        },
    }

    @classmethod
    def calculate_lake_volume(cls, area_ha: float, mean_depth_m: float) -> float:
        """
        Computes impounded water volume V in million m^3:
        V = (area_ha * 10,000 * mean_depth_m) / 1,000,000 = (area_ha * mean_depth_m) / 100
        """
        vol = (area_ha * mean_depth_m) / 100.0
        return round(vol, 2)

    @classmethod
    def calculate_peak_breach_discharge(cls, volume_million_m3: float) -> float:
        """
        Computes peak breach discharge Qp using Costa / Froehlich moraine dam breach empirical scaling:
        Qp = 0.72 * (V_m3)^0.53
        """
        v_m3 = volume_million_m3 * 1_000_000.0
        qp = 0.72 * math.pow(v_m3, 0.53)
        return round(qp, 1)

    @classmethod
    def calculate_wave_eta_min(cls, distance_km: float, speed_kmh: float) -> int:
        """Computes downstream flood surge arrival time (ETA) in minutes."""
        if speed_kmh <= 0:
            return 999
        hours = distance_km / speed_kmh
        return int(round(hours * 60.0))

    @classmethod
    def find_nearest_lake(cls, lat: float, lon: float) -> str:
        """Finds closest monitored glacial lake using Haversine great-circle distance."""
        def haversine(lat1, lon1, lat2, lon2):
            r = 6371.0
            dlat = math.radians(lat2 - lat1)
            dlon = math.radians(lon2 - lon1)
            a = math.sin(dlat / 2.0) ** 2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2.0) ** 2
            c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
            return r * c

        best_lake = "south_lhonak_sikkim"
        min_dist = float("inf")

        for l_id, data in cls.GLACIAL_LAKES_DB.items():
            dist = haversine(lat, lon, data["latitude"], data["longitude"])
            if dist < min_dist:
                min_dist = dist
                best_lake = l_id

        return best_lake

    @classmethod
    def generate_vernacular_bulletins(
        cls, corridor: GlacialLakeCorridor
    ) -> Dict[str, str]:
        """Generates emergency bulletins in 7 Himalayan & regional languages."""
        name = corridor.lake_name
        tier = corridor.threat_tier.value
        elev = corridor.elevation_m
        qp = corridor.breach_hydrodynamics.peak_outflow_discharge_m3_s
        earliest_node = corridor.downstream_impact_timeline[0] if corridor.downstream_impact_timeline else None
        eta = earliest_node.wave_arrival_eta_min if earliest_node else 0
        dest = earliest_node.node_name if earliest_node else "Downstream Valley"

        return {
            "en": (
                f"NRSC-CWC-NDMA GLOF BULLETIN for {name} ({elev:.0f}m MSL): Threat Level {tier}. "
                f"Projected peak breach outflow discharge {qp:,.0f} m³/s. Earliest flood wave ETA to {dest} "
                f"is {eta} minutes. Immediate vertical civilian evacuation (>30m above riverbed) and hydropower barrage sluice flush ordered."
            ),
            "hi": (
                f"एनआरएससी-सीडब्ल्यूसी-एनडीएमए हिमनद झील विस्फोट (GLOF) बुलेटिन - {name} ({elev:.0f} मीटर ऊँचाई): चेतावनी स्तर {tier}। "
                f"अनुमानित अधिकतम रिसाव प्रवाह {qp:,.0f} घन मीटर/सेकंड। {dest} तक बाढ़ की लहर पहुँचने का समय (ETA) मात्र {eta} मिनट है। "
                f"नदी किनारे से तुरंत 30 मीटर ऊँचाई पर सुरक्षित स्थानों की ओर जाएँ तथा जलविद्युत बाँधों के फ्लश गेट तुरंत खोलें।"
            ),
            "ne": (
                f"राष्ट्रिय विपद् व्यवस्थापन प्राधिकरण (NDMA) र CWC हिमनदी ताल विष्फोट (GLOF) सूचना - {name} ({elev:.0f} मिटर): "
                f"खतराको स्तर {tier}। अनुमानित उच्च बहाव {qp:,.0f} m³/s। {dest} सम्म बाढीको लहर आइपुग्ने समय (ETA) {eta} मिनेट मात्र। "
                f"नदी किनारका बासिन्दा तुरुन्त ३० मिटरभन्दा माथिल्लो सुरक्षित स्थानमा जानुहोस् र जलविद्युत बाँधका ढोकाहरू तत्काल खोल्नुहोस्।"
            ),
            "bo": (
                f"NRSC-CWC-NDMA གངས་རིའི་མཚོ་བརྡོལ་ཉེན་བརྡ། {name} (མཐོ་ཚད་ {elev:.0f}m): ཉེན་ཚབས་རིམ་པ། {tier}། "
                f"ཆུ་ལོག་ཆེ་ཤོས་ {qp:,.0f} m³/s འབབ་རྒྱུའི་ཚོད་དཔག {dest} ལ་ཆུ་ལོག་སླེབས་པའི་དུས་ཚོད་སྐར་མ་ {eta} ཡིན། "
                f"གཙང་པོའི་འགྲམ་ནས་མཐོ་ཚད་ 30m ཡན་གྱི་ས་ཆ་མཐོན་པོར་འཕྲལ་དུ་གནས་སྤོ་དགོས།"
            ),
            "pa": (
                f"NRSC-CWC-NDMA ਗਲੇਸ਼ੀਅਰ ਝੀਲ ਫਟਣ (GLOF) ਚਿਤਾਵਨੀ - {name} ({elev:.0f} ਮੀਟਰ): ਖ਼ਤਰਾ ਪੱਧਰ {tier}। "
                f"ਅੰਦਾਜ਼ਨ ਸਿਖਰ ਨਿਕਾਸੀ {qp:,.0f} ਕਿਊਬਿਕ ਮੀਟਰ/ਸੈਕਿੰਡ। {dest} ਤੱਕ ਹੜ੍ਹ ਦੀ ਲਹਿਰ ਪਹੁੰਚਣ ਦਾ ਸਮਾਂ (ETA) {eta} ਮਿੰਟ ਹੈ। "
                f"ਨਦੀ ਕੰਢੇ ਤੋਂ ਤੁਰੰਤ 30 ਮੀਟਰ ਉੱਚੇ ਸੁਰੱਖਿਅਤ ਸਥਾਨਾਂ ਤੇ ਜਾਓ ਅਤੇ ਡੈਮਾਂ ਦੇ ਫਲੱਸ਼ ਗੇਟ ਤੁਰੰਤ ਖੋਲ੍ਹੋ।"
            ),
            "bn": (
                f"NRSC-CWC-NDMA হিমবাহ হ্রদ বিস্ফোরণ (GLOF) সতর্কতা - {name} ({elev:.0f} মিটার উচ্চতা): সতর্কতা স্তর {tier}। "
                f"সম্ভাব্য সর্বোচ্চ বন্যা প্রবাহ {qp:,.0f} ঘনমিটার/সেকেন্ড। {dest}-এ প্লাবন পৌঁছানোর সময় (ETA) মাত্র {eta} মিনিট। "
                f"নদী তীরবর্তী মানুষ অবিলম্বে ৩০ মিটারের বেশি উঁচু স্থানে আশ্রয় নিন এবং জলবিদ্যুৎ বাঁধের সমস্ত রেডিয়াল গেট খুলে দিন।"
            ),
            "as": (
                f"NRSC-CWC-NDMA হিমবাহ হ্ৰদ বিস্ফোৰণ (GLOF) সতৰ্কবাৰ্তা - {name} ({elev:.0f} মিটাৰ): ভাবুকি স্তৰ {tier}। "
                f"সম্ভাব্য সৰ্বাধিক নিৰ্গমন প্ৰবাহ {qp:,.0f} ঘনমিটাৰ/ছেকেণ্ড। {dest} পোৱাৰ আনুমানিক সময় (ETA) {eta} মিনিট। "
                f"নৈৰ পাৰৰ পৰা তাৎক্ষণিকভাৱে ৩০ মিটাৰ ওখ সুৰক্ষিত স্থানলৈ স্থানান্তৰ হওক আৰু বান্ধৰ পানী নিষ্কাষণ গেট মুকলি কৰক।"
            ),
        }

    @classmethod
    def get_assessment(
        cls, lake_id: Optional[str] = None, latitude: Optional[float] = None, longitude: Optional[float] = None
    ) -> GlofResponse:
        """
        Executes full GLOF morphometric, moraine stability, breach hydrodynamics,
        and downstream early warning assessment.
        """
        # 1. Resolve lake ID
        if lake_id and lake_id in cls.GLACIAL_LAKES_DB:
            target_id = lake_id
        elif latitude is not None and longitude is not None:
            target_id = cls.find_nearest_lake(latitude, longitude)
        else:
            target_id = "south_lhonak_sikkim"

        raw = cls.GLACIAL_LAKES_DB[target_id]

        # 2. Morphometry
        area_ha = raw["surface_area_ha"]
        area_km2 = round(area_ha / 100.0, 3)
        mean_d = raw["mean_depth_m"]
        max_d = raw["max_depth_m"]
        vol_m_m3 = cls.calculate_lake_volume(area_ha, mean_d)

        morph = GlacialLakeMorphometry(
            surface_area_ha=area_ha,
            surface_area_km2=area_km2,
            mean_depth_m=mean_d,
            max_depth_m=max_d,
            water_volume_million_m3=vol_m_m3,
            expansion_rate_10yr_pct=raw["expansion_rate_10yr_pct"],
            satellite_sensor_provenance=raw["satellite_sensor"],
        )

        # 3. Moraine Geotechnics
        geotech = MoraineDamGeotechnics(
            crest_elevation_m=raw["dam_crest_elevation_m"],
            dam_height_m=raw["dam_height_m"],
            crest_width_to_height_ratio=raw["crest_width_to_height"],
            freeboard_height_m=raw["freeboard_height_m"],
            permafrost_degradation_pct=raw["permafrost_degradation_pct"],
            hydraulic_piping_index=raw["hydraulic_piping_index"],
            stability_status=raw["stability_status"],
        )

        # 4. Breach Hydrodynamics
        qp = cls.calculate_peak_breach_discharge(vol_m_m3)
        surge_speed = raw["wave_speed_kmh"]
        vol_released = round(vol_m_m3 * (raw["volume_released_pct"] / 100.0), 2)

        hydro = BreachHydrodynamics(
            peak_outflow_discharge_m3_s=qp,
            breach_formation_time_hours=raw["breach_time_hours"],
            total_breach_volume_million_m3=vol_released,
            wave_propagation_speed_kmh=surge_speed,
            trigger_mechanism=raw["trigger_mechanism"],
        )

        # 5. Downstream Impact Timeline
        impact_nodes: List[DownstreamImpactNode] = []
        for n in raw["impact_nodes"]:
            eta_m = cls.calculate_wave_eta_min(n["distance_km"], surge_speed)
            impact_nodes.append(
                DownstreamImpactNode(
                    node_name=n["node_name"],
                    distance_km=n["distance_km"],
                    wave_arrival_eta_min=eta_m,
                    peak_surge_depth_m=n["surge_depth_m"],
                    infrastructure_alert=n["alert"],
                    evacuation_zone_elevation_m=n["evacuation_elevation_m"],
                )
            )

        # 6. Selected Glacial Lake Corridor
        selected = GlacialLakeCorridor(
            lake_id=raw["lake_id"],
            lake_name=raw["lake_name"],
            river_basin=raw["river_basin"],
            state=raw["state"],
            latitude=raw["latitude"],
            longitude=raw["longitude"],
            elevation_m=raw["elevation_m"],
            threat_tier=raw["threat_tier"],
            morphometry=morph,
            moraine_geotechnics=geotech,
            breach_hydrodynamics=hydro,
            downstream_impact_timeline=impact_nodes,
            ndma_safety_directives=raw["directives"],
        )

        # 7. Lake Summaries
        summaries: List[LakeSummary] = []
        for l_id, l_data in cls.GLACIAL_LAKES_DB.items():
            l_vol = cls.calculate_lake_volume(l_data["surface_area_ha"], l_data["mean_depth_m"])
            l_qp = cls.calculate_peak_breach_discharge(l_vol)
            first_dist = l_data["impact_nodes"][0]["distance_km"] if l_data["impact_nodes"] else 50.0
            first_eta = cls.calculate_wave_eta_min(first_dist, l_data["wave_speed_kmh"])

            summaries.append(
                LakeSummary(
                    lake_id=l_id,
                    lake_name=l_data["lake_name"],
                    river_basin=l_data["river_basin"],
                    state=l_data["state"],
                    elevation_m=l_data["elevation_m"],
                    threat_tier=l_data["threat_tier"],
                    surface_area_ha=l_data["surface_area_ha"],
                    volume_million_m3=l_vol,
                    peak_discharge_m3_s=l_qp,
                    earliest_eta_min=first_eta,
                )
            )

        # 8. Multi-lingual Bulletins
        bulletins = cls.generate_vernacular_bulletins(selected)

        return GlofResponse(
            selected_lake=selected,
            all_lakes=summaries,
            bulletins=bulletins,
            offline_cached=False,
            generated_at=datetime.now(timezone.utc).isoformat(),
        )
