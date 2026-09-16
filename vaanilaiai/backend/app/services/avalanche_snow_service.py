import math
from datetime import datetime, timezone
from typing import Dict, List, Optional

from app.schemas.avalanche_snow import (
    AvalancheDangerLevel,
    WdIntensity,
    WeakLayerType,
    PassTransitStatus,
    WesternDisturbanceTelemetry,
    SnowpackPhysics,
    MountainPassStatus,
    HighAltitudeSafety,
    HimalayanSector,
    AvalancheSnowResponse,
)


def _haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    R = 6371.0  # Earth's mean radius in km
    d_lat = math.radians(lat2 - lat1)
    d_lon = math.radians(lon2 - lon1)
    a = (
        math.sin(d_lat / 2.0) ** 2
        + math.cos(math.radians(lat1))
        * math.cos(math.radians(lat2))
        * math.sin(d_lon / 2.0) ** 2
    )
    c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
    return R * c


class AvalancheSnowService:
    """
    Operational IMD Mountain Weather Division & DRDO DGRE (Defense Geoinformatics
    Research Establishment) Himalayan Snowpack & Avalanche Early Warning Engine.
    """

    def __init__(self):
        self._sectors: List[HimalayanSector] = self._init_himalayan_sectors()

    def _init_himalayan_sectors(self) -> List[HimalayanSector]:
        return [
            HimalayanSector(
                sector_id="gulmarg_pir_panjal",
                sector_name="Gulmarg & Apharwat Sector",
                mountain_range="Pir Panjal Range",
                state_or_ut="Jammu & Kashmir",
                latitude=34.0484,
                longitude=74.3805,
                base_elevation_m=2650.0,
                peak_elevation_m=3950.0,
                danger_level=AvalancheDangerLevel.LEVEL_3_ORANGE_DANGER,
                danger_rating_text="Orange Alert (High Danger): Unstable wind slab deposits on lee slopes >30°. Natural avalanches possible; human triggering very likely.",
                snowpack=SnowpackPhysics(
                    total_snowpack_depth_cm=145.0,
                    fresh_snow_24h_cm=38.0,
                    snow_water_equivalent_mm=165.0,
                    average_density_kg_m3=240.0,
                    critical_slope_angle_deg=36.0,
                    primary_weak_layer=WeakLayerType.WIND_SLAB,
                    weak_layer_depth_cm=28.0,
                    aspect_hazard="North-East to South-East lee cirques and gully corridors above Phase-2 Gondola",
                ),
                pass_status=MountainPassStatus(
                    pass_name="Gulmarg-Tangmarg Axis",
                    altitude_m=2650.0,
                    altitude_ft=8694,
                    highway_code="Gulmarg Road",
                    status=PassTransitStatus.CHAINS_MANDATORY,
                    bro_operational_status="Clearance ongoing; metallic chains mandatory for all 4x2/4x4 passenger vehicles from Tangmarg upward.",
                    bro_equipment_deployed=["Snow Blower Fresia", "Wheel Loader Caterpillar 950", "Grader Cat 120K"],
                    chains_required=True,
                ),
                safety=HighAltitudeSafety(
                    elevation_m=2650.0,
                    ams_risk="Moderate above 3,000m (Apharwat Ridge)",
                    hypothermia_risk="High (Wind Chill -18°C on exposed ridges)",
                    bps_gear_mandatory=True,
                    travel_advisory="Strictly avoid skiing or boarding outside ski-patrol marked pistes. Do not enter backcountry bowls without beacon, probe, and shovel.",
                    emergency_helpline="112 (National Emergency) / 01954-254425 (Gulmarg Tourist Police)",
                ),
            ),
            HimalayanSector(
                sector_id="zojila_dras",
                sector_name="Zoji La Pass & Dras Sector",
                mountain_range="Great Himalaya / Zanskar Transition",
                state_or_ut="Ladakh / Jammu & Kashmir",
                latitude=34.2810,
                longitude=75.4980,
                base_elevation_m=2800.0,
                peak_elevation_m=4200.0,
                danger_level=AvalancheDangerLevel.LEVEL_4_RED_HIGH_DANGER,
                danger_rating_text="Red Alert (Extreme Danger): Widespread unstable depth hoar layers with fresh heavy overburden. Massive natural avalanches reaching highway level.",
                snowpack=SnowpackPhysics(
                    total_snowpack_depth_cm=210.0,
                    fresh_snow_24h_cm=54.0,
                    snow_water_equivalent_mm=250.0,
                    average_density_kg_m3=260.0,
                    critical_slope_angle_deg=41.0,
                    primary_weak_layer=WeakLayerType.DEPTH_HOAR_FACETS,
                    weak_layer_depth_cm=65.0,
                    aspect_hazard="East and South-East chutes across Shaitan Nallah, Captain's Corner, and Gumri Basin",
                ),
                pass_status=MountainPassStatus(
                    pass_name="Zoji La Pass",
                    altitude_m=3528.0,
                    altitude_ft=11575,
                    highway_code="NH-1 (Srinagar - Leh)",
                    status=PassTransitStatus.CLOSED_SNOW_CLEARING,
                    bro_operational_status="Closed due to recurring heavy avalanche slides at Captain's Corner. Project Vijayak & Beacon heavy machinery actively clearing snow.",
                    bro_equipment_deployed=["Rotary Snow Cutter Rolba", "Bulldozer D85", "Tire Chain Heavy Uni-Tractors"],
                    chains_required=True,
                ),
                safety=HighAltitudeSafety(
                    elevation_m=3528.0,
                    ams_risk="High (Rapid ascent over 3,500m)",
                    hypothermia_risk="Extreme (Ambient -14°C, Wind Chill -28°C)",
                    bps_gear_mandatory=True,
                    travel_advisory="All civilian and non-essential transit halted across Sonamarg-Minamarg-Dras corridor. Obey BRO transit signals strictly.",
                    emergency_helpline="112 / 01985-234222 (Dras Police Control Room)",
                ),
            ),
            HimalayanSector(
                sector_id="khardungla_leh",
                sector_name="Khardung La & Leh-Nubra Sector",
                mountain_range="Ladakh Range",
                state_or_ut="Ladakh",
                latitude=34.2787,
                longitude=77.6047,
                base_elevation_m=3500.0,
                peak_elevation_m=5359.0,
                danger_level=AvalancheDangerLevel.LEVEL_3_ORANGE_DANGER,
                danger_rating_text="Orange Alert (High Danger): High-velocity wind slab accumulations on North and North-West aspects above 4,800m.",
                snowpack=SnowpackPhysics(
                    total_snowpack_depth_cm=85.0,
                    fresh_snow_24h_cm=22.0,
                    snow_water_equivalent_mm=95.0,
                    average_density_kg_m3=210.0,
                    critical_slope_angle_deg=34.0,
                    primary_weak_layer=WeakLayerType.WIND_SLAB,
                    weak_layer_depth_cm=18.0,
                    aspect_hazard="North-West and North wind-compacted slab formations along summit ridge and switchbacks",
                ),
                pass_status=MountainPassStatus(
                    pass_name="Khardung La Pass",
                    altitude_m=5359.0,
                    altitude_ft=17582,
                    highway_code="Leh - Nubra Axis",
                    status=PassTransitStatus.CONVOY_TIMED_ONE_WAY,
                    bro_operational_status="One-way controlled convoy operating. Morning traffic Leh to Nubra; Afternoon traffic Nubra to Leh. Metallic chains mandatory.",
                    bro_equipment_deployed=["Dozer D65", "Snow Cutter Rolba R-400", "BRO Rescue Recovery 4x4"],
                    chains_required=True,
                ),
                safety=HighAltitudeSafety(
                    elevation_m=5359.0,
                    ams_risk="Extreme (Severe risk of HAPE/HACE without acclimatization)",
                    hypothermia_risk="Extreme (Sub-zero thin atmosphere, Wind Chill -32°C)",
                    bps_gear_mandatory=True,
                    travel_advisory="Do not halt at the pass summit for more than 15-20 minutes. Carry portable oxygen cylinders and keep engine idling to prevent diesel freezing.",
                    emergency_helpline="112 / 01982-252018 (Leh District Disaster Management)",
                ),
            ),
            HimalayanSector(
                sector_id="rohtang_atal_tunnel",
                sector_name="Rohtang Pass & Atal Tunnel Portal Sector",
                mountain_range="Pir Panjal / Beas Catchment",
                state_or_ut="Himachal Pradesh",
                latitude=32.3716,
                longitude=77.1642,
                base_elevation_m=2050.0,
                peak_elevation_m=3978.0,
                danger_level=AvalancheDangerLevel.LEVEL_3_ORANGE_DANGER,
                danger_rating_text="Orange Alert (High Danger): Rain-on-snow crust failure and wind slab triggers around South and North tunnel portals.",
                snowpack=SnowpackPhysics(
                    total_snowpack_depth_cm=160.0,
                    fresh_snow_24h_cm=35.0,
                    snow_water_equivalent_mm=185.0,
                    average_density_kg_m3=255.0,
                    critical_slope_angle_deg=38.0,
                    primary_weak_layer=WeakLayerType.RAIN_ON_SNOW,
                    weak_layer_depth_cm=32.0,
                    aspect_hazard="Sissu side North Portal chutes and Rohtang top switchbacks",
                ),
                pass_status=MountainPassStatus(
                    pass_name="Atal Tunnel & Rohtang Pass",
                    altitude_m=3100.0,
                    altitude_ft=10170,
                    highway_code="NH-03 (Manali - Keylong)",
                    status=PassTransitStatus.CHAINS_MANDATORY,
                    bro_operational_status="Atal Tunnel operational with strict 4x4 or snow-chained vehicles; high Rohtang crest pass closed for winter.",
                    bro_equipment_deployed=["Project Deepak Rotary Snow Blowers", "Uni-Truck De-icing Sprayers"],
                    chains_required=True,
                ),
                safety=HighAltitudeSafety(
                    elevation_m=3100.0,
                    ams_risk="Moderate (Keylong and Lahaul side above 3,100m)",
                    hypothermia_risk="High (Icy conditions in North Portal shade)",
                    bps_gear_mandatory=False,
                    travel_advisory="Drive in low gear with anti-skid tire chains. Do not overtake inside the 9.02 km tunnel. Avoid halting near avalanche galleries.",
                    emergency_helpline="112 / 01902-252720 (Manali Police Control Room)",
                ),
            ),
            HimalayanSector(
                sector_id="solang_upper_beas",
                sector_name="Solang Valley & Upper Beas Catchment",
                mountain_range="Pir Panjal Foothills",
                state_or_ut="Himachal Pradesh",
                latitude=32.3166,
                longitude=77.1574,
                base_elevation_m=2050.0,
                peak_elevation_m=2560.0,
                danger_level=AvalancheDangerLevel.LEVEL_2_YELLOW_MODERATE,
                danger_rating_text="Yellow Alert (Moderate Danger): Moderate snowpack bonding. Isolated human triggering possible on steep meadow slopes >32°.",
                snowpack=SnowpackPhysics(
                    total_snowpack_depth_cm=65.0,
                    fresh_snow_24h_cm=18.0,
                    snow_water_equivalent_mm=72.0,
                    average_density_kg_m3=220.0,
                    critical_slope_angle_deg=32.0,
                    primary_weak_layer=WeakLayerType.SURFACE_HOAR,
                    weak_layer_depth_cm=12.0,
                    aspect_hazard="East and North-East aspect open ski meadows and gullies",
                ),
                pass_status=MountainPassStatus(
                    pass_name="Solang Valley Axis",
                    altitude_m=2560.0,
                    altitude_ft=8398,
                    highway_code="Manali - Solang Road",
                    status=PassTransitStatus.OPEN_NORMAL,
                    bro_operational_status="Open for all tourist transit. Caution advised regarding morning black ice on bridges and culverts.",
                    bro_equipment_deployed=["HP PWD Snow Plow", "Salt Sprayer"],
                    chains_required=False,
                ),
                safety=HighAltitudeSafety(
                    elevation_m=2560.0,
                    ams_risk="Low below 2,800m",
                    hypothermia_risk="Moderate (Ensure warm waterproof apparel for outdoor sports)",
                    bps_gear_mandatory=False,
                    travel_advisory="Follow local ski instructor guidance. Observe warning flags near steeper slopes above the ski lift terminals.",
                    emergency_helpline="112 / 1077 (District Disaster Management Authority Kullu)",
                ),
            ),
            HimalayanSector(
                sector_id="kalpa_kinnaur_spiti",
                sector_name="Kalpa, Kinnaur & Spiti Valley Sector",
                mountain_range="Zanskar & Greater Himalaya",
                state_or_ut="Himachal Pradesh",
                latitude=31.5385,
                longitude=78.2562,
                base_elevation_m=2800.0,
                peak_elevation_m=4400.0,
                danger_level=AvalancheDangerLevel.LEVEL_3_ORANGE_DANGER,
                danger_rating_text="Orange Alert (High Danger): Persistent depth hoar facets beneath recent dry powder. High trigger potential on rocky cliffs.",
                snowpack=SnowpackPhysics(
                    total_snowpack_depth_cm=110.0,
                    fresh_snow_24h_cm=28.0,
                    snow_water_equivalent_mm=125.0,
                    average_density_kg_m3=235.0,
                    critical_slope_angle_deg=37.0,
                    primary_weak_layer=WeakLayerType.DEPTH_HOAR_FACETS,
                    weak_layer_depth_cm=40.0,
                    aspect_hazard="South-East to South-West steep rocky avalanche corridors in Satluj & Spiti gorges",
                ),
                pass_status=MountainPassStatus(
                    pass_name="Kunzum La / Spiti Axis",
                    altitude_m=4551.0,
                    altitude_ft=14931,
                    highway_code="NH-505 (Kaza - Gramphu)",
                    status=PassTransitStatus.CLOSED_SNOW_CLEARING,
                    bro_operational_status="Kunzum Pass closed for seasonal winter. Lower Kinnaur NH-5 open with single-lane clearance at shooting stone zones.",
                    bro_equipment_deployed=["BRO Dozer D85", "Rock Wheel Excavators"],
                    chains_required=True,
                ),
                safety=HighAltitudeSafety(
                    elevation_m=2960.0,
                    ams_risk="High in Spiti Valley (>3,800m)",
                    hypothermia_risk="Extreme (Night temperatures dropping below -16°C)",
                    bps_gear_mandatory=True,
                    travel_advisory="Carry reserve fuel, heavy down jackets, and medical supply packs. Do not attempt crossing Kunzum Pass under any circumstances.",
                    emergency_helpline="112 / 01786-222252 (Kinnaur Disaster Management Cell)",
                ),
            ),
            HimalayanSector(
                sector_id="kedarnath_mandakini",
                sector_name="Kedarnath & Mandakini Valley Sector",
                mountain_range="Garhwal Himalaya",
                state_or_ut="Uttarakhand",
                latitude=30.7352,
                longitude=79.0669,
                base_elevation_m=1980.0,
                peak_elevation_m=3584.0,
                danger_level=AvalancheDangerLevel.LEVEL_3_ORANGE_DANGER,
                danger_rating_text="Orange Alert (High Danger): Wind slab deposits and snow drifts on companion slopes surrounding Chorabari Glacier & temple basin.",
                snowpack=SnowpackPhysics(
                    total_snowpack_depth_cm=135.0,
                    fresh_snow_24h_cm=32.0,
                    snow_water_equivalent_mm=150.0,
                    average_density_kg_m3=245.0,
                    critical_slope_angle_deg=39.0,
                    primary_weak_layer=WeakLayerType.WIND_SLAB,
                    weak_layer_depth_cm=25.0,
                    aspect_hazard="Chorabari Glacier terminus, Bhairavnath ridge slopes, and Garud Chatti avalanche tracks",
                ),
                pass_status=MountainPassStatus(
                    pass_name="Gaurikund-Kedarnath Trek Route",
                    altitude_m=3584.0,
                    altitude_ft=11759,
                    highway_code="Kedarnath Pedestrian & Mule Axis",
                    status=PassTransitStatus.CONVOY_TIMED_ONE_WAY,
                    bro_operational_status="Regulated pedestrian transit with SDRF escort. Snow clearance teams clearing drifts with rotary snow plows.",
                    bro_equipment_deployed=["SDRF Snow Cutters", "Pony & Mule Track Snow Dozers"],
                    chains_required=False,
                ),
                safety=HighAltitudeSafety(
                    elevation_m=3584.0,
                    ams_risk="High (Steep 16 km trek from Gaurikund to 3,584m)",
                    hypothermia_risk="High (Continuous freezing rain and heavy snowfall)",
                    bps_gear_mandatory=False,
                    travel_advisory="Pilgrims must carry warm thermal base layers, waterproof ponchos, and trek only during daylight. Stop at Lincholi if visibility drops.",
                    emergency_helpline="112 / 1070 (Uttarakhand State Disaster Response Force - SDRF)",
                ),
            ),
            HimalayanSector(
                sector_id="badrinath_mana_pass",
                sector_name="Badrinath & Mana Pass Sector",
                mountain_range="Garhwal Himalaya / Indo-Tibetan Border",
                state_or_ut="Uttarakhand",
                latitude=30.7433,
                longitude=79.4938,
                base_elevation_m=3133.0,
                peak_elevation_m=5608.0,
                danger_level=AvalancheDangerLevel.LEVEL_4_RED_HIGH_DANGER,
                danger_rating_text="Red Alert (Extreme Danger): Massive depth hoar collapse risk along Nar-Narayan peaks and Mana gorge. Extreme natural avalanche cycle.",
                snowpack=SnowpackPhysics(
                    total_snowpack_depth_cm=190.0,
                    fresh_snow_24h_cm=46.0,
                    snow_water_equivalent_mm=220.0,
                    average_density_kg_m3=265.0,
                    critical_slope_angle_deg=42.0,
                    primary_weak_layer=WeakLayerType.DEPTH_HOAR_FACETS,
                    weak_layer_depth_cm=50.0,
                    aspect_hazard="Nar-Narayan cirques, Nilkantha avalanche gullies, and Mana Gorge chutes",
                ),
                pass_status=MountainPassStatus(
                    pass_name="Mana Pass / Badrinath Axis",
                    altitude_m=3133.0,
                    altitude_ft=10279,
                    highway_code="NH-58 (Joshimath - Badrinath - Mana)",
                    status=PassTransitStatus.CLOSED_SNOW_CLEARING,
                    bro_operational_status="NH-58 closed ahead of Lambagar / Hanumanchatti due to recurring snow slides and heavy drift accumulation. Project Shivalik clearing track.",
                    bro_equipment_deployed=["Project Shivalik Heavy Wheel Loaders", "Snow Blowers", "D85 Dozers"],
                    chains_required=True,
                ),
                safety=HighAltitudeSafety(
                    elevation_m=3133.0,
                    ams_risk="High (Above 3,100m in cold alpine valley)",
                    hypothermia_risk="Extreme (Bitter sub-zero glacial down-valley katabatic winds)",
                    bps_gear_mandatory=True,
                    travel_advisory="Avoid any travel past Joshimath until BRO issues formal clearance. Do not cross snow slides on foot due to secondary avalanche risk.",
                    emergency_helpline="112 / 01372-251437 (Chamoli District Emergency Operation Centre)",
                ),
            ),
        ]

    def _generate_western_disturbance(self) -> WesternDisturbanceTelemetry:
        return WesternDisturbanceTelemetry(
            intensity=WdIntensity.INTENSE,
            subtropical_jet_speed_kt=135.0,
            trough_500hpa_depth_dam=546.0,
            induced_cyclonic_circulation="Over Central Pakistan and adjoining West Rajasthan with sharp convergence zone",
            moisture_source="Persistent atmospheric river moisture feed from North Arabian Sea coupled with Caspian low",
            freezing_level_m=2150.0,
            synoptic_summary=(
                "Intense Western Disturbance as a deep upper-tropospheric trough in westerlies with axis "
                "along 68°E to the north of 28°N. Subtropical Westerly Jet core exceeding 135 knots at 200 hPa "
                "is driving vigorous orographic precipitation, widespread fresh snowfall (30-55 cm/24h), "
                "and triggering Level-3 to Level-4 avalanche warnings above 2,500m across J&K, Ladakh, HP, and Uttarakhand."
            ),
        )

    def _generate_vernacular_bulletins(
        self, sector: HimalayanSector, wd: WesternDisturbanceTelemetry
    ) -> Dict[str, str]:
        level_name = sector.danger_level.value.replace("_", " ")
        pass_name = sector.pass_status.pass_name
        pass_status = sector.pass_status.status.value.replace("_", " ")

        return {
            "en": (
                f"DGRE / IMD HIMALAYAN AVALANCHE WARNING: {sector.sector_name} is under {level_name}. "
                f"Fresh 24h snow: {sector.snowpack.fresh_snow_24h_cm:.0f} cm, Total depth: {sector.snowpack.total_snowpack_depth_cm:.0f} cm. "
                f"{pass_name} is {pass_status}. Critical weak layer: {sector.snowpack.primary_weak_layer.value.replace('_', ' ')}. "
                f"Avoid avalanche terrain >30° slope. Emergency contact: {sector.safety.emergency_helpline}."
            ),
            "hi": (
                f"डीजीआरई / आईएमडी हिमालयी हिमस्खलन चेतावनी: {sector.sector_name} में {level_name} लागू है। "
                f"पिछले 24 घंटों में ताज़ा बर्फबारी: {sector.snowpack.fresh_snow_24h_cm:.0f} सेमी, कुल बर्फ: {sector.snowpack.total_snowpack_depth_cm:.0f} सेमी। "
                f"{pass_name} की स्थिति: {pass_status}। 30° से अधिक ढलान वाले हिमस्खलन क्षेत्रों में जाने से बचें। "
                f"आपातकालीन सहायता: {sector.safety.emergency_helpline}।"
            ),
            "ur": (
                f"ڈی جی آر ای / محکمہ موسمیات برفانی طوفان انتباہ: {sector.sector_name} میں {level_name} نافذ ہے۔ "
                f"گزشتہ 24 گھنٹوں میں تازہ برف باری: {sector.snowpack.fresh_snow_24h_cm:.0f} سینٹی میٹر، کل برف: {sector.snowpack.total_snowpack_depth_cm:.0f} سینٹی میٹر۔ "
                f"{pass_name} کی حالت: {pass_status}۔ برائے مہربانی ڈھلوانوں سے دور رہیں۔ ہنگامی رابطہ: {sector.safety.emergency_helpline}۔"
            ),
            "pa": (
                f"ਡੀਜੀਆਰਈ / ਆਈਐਮਡੀ ਹਿਮਾਲੀਅਨ ਬਰਫੀਲੇ ਤੂਫਾਨ ਦੀ ਚੇਤਾਵਨੀ: {sector.sector_name} ਵਿਖੇ {level_name} ਜਾਰੀ ਹੈ। "
                f"ਤਾਜ਼ਾ 24 ਘੰਟਿਆਂ ਦੀ ਬਰਫਬਾਰੀ: {sector.snowpack.fresh_snow_24h_cm:.0f} ਸਮ, ਕੁੱਲ ਬਰਫ: {sector.snowpack.total_snowpack_depth_cm:.0f} ਸਮ। "
                f"{pass_name} ਦੀ ਸਥਿਤੀ: {pass_status}। 30 ਡਿਗਰੀ ਤੋਂ ਉੱਚੀਆਂ ਢਲਾਣਾਂ ਤੋਂ ਪਰਹੇਜ਼ ਕਰੋ। ਐਮਰਜੈਂਸੀ ਹੈਲਪਲਾਈਨ: {sector.safety.emergency_helpline}।"
            ),
            "bn": (
                f"ডিজিআরই / আইএমডি হিমালয় তুষারধস সতর্কতা: {sector.sector_name} বর্তমানে {level_name} সতর্কতায় রয়েছে। "
                f"২৪ ঘণ্টায় নতুন তুষারপাত: {sector.snowpack.fresh_snow_24h_cm:.0f} সেমি, মোট তুষার গভীরতা: {sector.snowpack.total_snowpack_depth_cm:.0f} সেমি। "
                f"{pass_name} বর্তমান অবস্থা: {pass_status}। ৩০ ডিগ্রির বেশি খাড়া ঢালে যাওয়া সম্পূর্ণ এড়িয়ে চলুন। জরুরি যোগাযোগ: {sector.safety.emergency_helpline}।"
            ),
        }

    def get_avalanche_assessment(
        self,
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        sector_id: Optional[str] = None,
    ) -> AvalancheSnowResponse:
        """
        Resolves Himalayan snow & avalanche danger for a given sector_id or
        geodetically matches the closest Himalayan sector.
        """
        selected_sector: HimalayanSector

        if sector_id:
            match = next((s for s in self._sectors if s.sector_id == sector_id), None)
            if match:
                selected_sector = match
            else:
                selected_sector = self._sectors[0]
        elif latitude is not None and longitude is not None:
            # Geodetic nearest sector matching
            selected_sector = min(
                self._sectors,
                key=lambda s: _haversine_distance(latitude, longitude, s.latitude, s.longitude),
            )
        else:
            # Default to Gulmarg
            selected_sector = self._sectors[0]

        wd = self._generate_western_disturbance()
        vernacular = self._generate_vernacular_bulletins(selected_sector, wd)
        bulletin_no = f"DGRE-IMD/HIM/2026-WD-{datetime.now(timezone.utc).strftime('%m%d%H')}"

        return AvalancheSnowResponse(
            timestamp=datetime.now(timezone.utc).isoformat(),
            selected_sector=selected_sector,
            all_sectors=self._sectors,
            western_disturbance=wd,
            vernacular_bulletins=vernacular,
            dgre_advisory_bulletin_no=bulletin_no,
            provenance="IMD Mountain Weather Division & DRDO DGRE (Defense Geoinformatics Research Establishment)",
        )


avalanche_snow_service = AvalancheSnowService()
