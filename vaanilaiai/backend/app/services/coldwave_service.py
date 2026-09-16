import math
from datetime import datetime, timezone
from typing import List, Dict, Optional, Tuple

from app.schemas.coldwave import (
    ColdWaveSeverity,
    GroundFrostRisk,
    HypothermiaRisk,
    CropVulnerabilityItem,
    NocturnalCoolingPhysics,
    UrbanShelterAdvisory,
    ColdwaveStation,
    ColdWaveResponse,
)


class ColdWaveService:
    """
    Ministry of Earth Sciences (MoES) / IMD Cold Wave & ICAR Ground Frost Engine.
    Implements:
    1. Official IMD Cold Wave / Severe Cold Wave & Cold Day criteria (Plains vs Hills).
    2. Stefan-Boltzmann nocturnal radiative cooling model for Grass Minimum Temperature (T_grass).
    3. JAG/TI Wind Chill Index calculation.
    4. ICAR Rabi crop freeze injury mitigation protocols.
    5. Urban Rain Basera / night shelter hypothermia alerts.
    """

    MONITORING_STATIONS: List[Dict] = [
        {
            "station_id": "CHURU_RJ",
            "station_name": "Churu",
            "state": "Rajasthan",
            "latitude": 28.29,
            "longitude": 74.96,
            "elevation_m": 286.0,
            "is_hill_station": False,
            "t_min": 1.4,
            "t_normal_min": 8.5,
            "sky_cover_oktas": 0,
            "wind_speed_kmh": 3.2,
            "dew_point_c": 0.2,
        },
        {
            "station_id": "HISAR_HR",
            "station_name": "Hisar",
            "state": "Haryana",
            "latitude": 29.15,
            "longitude": 75.72,
            "elevation_m": 215.0,
            "is_hill_station": False,
            "t_min": 2.2,
            "t_normal_min": 7.8,
            "sky_cover_oktas": 1,
            "wind_speed_kmh": 4.0,
            "dew_point_c": 0.8,
        },
        {
            "station_id": "LUDHIANA_PB",
            "station_name": "Ludhiana",
            "state": "Punjab",
            "latitude": 30.90,
            "longitude": 75.85,
            "elevation_m": 247.0,
            "is_hill_station": False,
            "t_min": 3.8,
            "t_normal_min": 9.0,
            "sky_cover_oktas": 1,
            "wind_speed_kmh": 5.5,
            "dew_point_c": 1.5,
        },
        {
            "station_id": "NARNAUL_HR",
            "station_name": "Narnaul",
            "state": "Haryana",
            "latitude": 28.04,
            "longitude": 76.10,
            "elevation_m": 300.0,
            "is_hill_station": False,
            "t_min": 1.8,
            "t_normal_min": 8.0,
            "sky_cover_oktas": 0,
            "wind_speed_kmh": 2.5,
            "dew_point_c": -0.4,
        },
        {
            "station_id": "KARNAL_HR",
            "station_name": "Karnal",
            "state": "Haryana",
            "latitude": 29.68,
            "longitude": 76.99,
            "elevation_m": 252.0,
            "is_hill_station": False,
            "t_min": 3.2,
            "t_normal_min": 8.2,
            "sky_cover_oktas": 2,
            "wind_speed_kmh": 6.0,
            "dew_point_c": 1.2,
        },
        {
            "station_id": "SRINAGAR_JK",
            "station_name": "Srinagar",
            "state": "Jammu & Kashmir",
            "latitude": 34.08,
            "longitude": 74.79,
            "elevation_m": 1585.0,
            "is_hill_station": True,
            "t_min": -4.6,
            "t_normal_min": -1.2,
            "sky_cover_oktas": 1,
            "wind_speed_kmh": 2.0,
            "dew_point_c": -6.0,
        },
        {
            "station_id": "SHIMLA_HP",
            "station_name": "Shimla",
            "state": "Himachal Pradesh",
            "latitude": 31.10,
            "longitude": 77.17,
            "elevation_m": 2206.0,
            "is_hill_station": True,
            "t_min": -1.5,
            "t_normal_min": 3.0,
            "sky_cover_oktas": 2,
            "wind_speed_kmh": 8.0,
            "dew_point_c": -3.5,
        },
        {
            "station_id": "BAREILLY_UP",
            "station_name": "Bareilly",
            "state": "Uttar Pradesh",
            "latitude": 28.36,
            "longitude": 79.43,
            "elevation_m": 166.0,
            "is_hill_station": False,
            "t_min": 4.5,
            "t_normal_min": 9.5,
            "sky_cover_oktas": 3,
            "wind_speed_kmh": 5.0,
            "dew_point_c": 2.8,
        },
        {
            "station_id": "GAYA_BR",
            "station_name": "Gaya",
            "state": "Bihar",
            "latitude": 24.79,
            "longitude": 85.00,
            "elevation_m": 111.0,
            "is_hill_station": False,
            "t_min": 5.2,
            "t_normal_min": 10.2,
            "sky_cover_oktas": 1,
            "wind_speed_kmh": 6.5,
            "dew_point_c": 3.0,
        },
    ]

    @staticmethod
    def calculate_stefan_boltzmann_cooling(
        t_air_min: float,
        sky_cover_oktas: int,
        wind_speed_kmh: float,
    ) -> Tuple[float, float]:
        """
        Calculates grass minimum temperature (T_grass) at 5cm height and net terrestrial radiation loss (W/m²).
        Based on Stefan-Boltzmann net outgoing longwave radiation model damped by cloud cover and aerodynamic boundary layer mixing:
        delta_T_rad = max(1.0, 4.8 * (1 - 0.75 * (oktas / 8)) * exp(-0.18 * wind_speed_kmh))
        """
        clamped_oktas = max(0, min(8, sky_cover_oktas))
        cloud_factor = 1.0 - 0.75 * (clamped_oktas / 8.0)
        wind_damping = math.exp(-0.18 * max(0.0, wind_speed_kmh))
        
        delta_t_rad = max(0.8, 4.8 * cloud_factor * wind_damping)
        t_grass_min = round(t_air_min - delta_t_rad, 1)

        # Stefan-Boltzmann net flux loss: sigma * T^4 * (1 - eps_sky) * cloud_factor
        # Nominal clear sky net outgoing flux in cold dry air ~ 75 W/m²
        net_radiation_wm2 = round(75.0 * cloud_factor * (0.85 + 0.15 * math.exp(-0.1 * max(0.0, wind_speed_kmh))), 1)
        
        return t_grass_min, net_radiation_wm2

    @staticmethod
    def calculate_wind_chill(t_air_c: float, wind_speed_kmh: float) -> float:
        """
        Joint Action Group on Temperature Indices (JAG/TI) Wind Chill Formula:
        WCI = 13.12 + 0.6215*T - 11.37*(V^0.16) + 0.3965*T*(V^0.16)
        Valid for T <= 10°C and V >= 4.8 km/h.
        """
        if t_air_c <= 10.0 and wind_speed_kmh >= 4.8:
            v16 = math.pow(wind_speed_kmh, 0.16)
            wci = 13.12 + (0.6215 * t_air_c) - (11.37 * v16) + (0.3965 * t_air_c * v16)
            return round(wci, 1)
        return round(t_air_c, 1)

    @staticmethod
    def classify_cold_wave(
        t_air_min: float,
        t_normal_min: float,
        is_hill_station: bool,
    ) -> ColdWaveSeverity:
        """
        Official IMD Cold Wave Classification:
        Plains:
        - When normal min >= 10°C:
            - Cold Wave: departure -4.5°C to -6.4°C
            - Severe Cold Wave: departure <= -6.5°C
        - Based on actual min temp (regardless of normal):
            - Actual min <= 2.0°C -> Severe Cold Wave
            - Actual min <= 4.0°C -> Cold Wave
        Hills (elevation >= 1000m):
        - When actual min <= 0°C:
            - Cold Wave: departure -4.5°C to -6.4°C
            - Severe Cold Wave: departure <= -6.5°C
        """
        departure = t_air_min - t_normal_min

        if is_hill_station:
            if t_air_min <= 0.0:
                if departure <= -6.5:
                    return ColdWaveSeverity.SEVERE_COLD_WAVE
                elif departure <= -4.5:
                    return ColdWaveSeverity.COLD_WAVE
            return ColdWaveSeverity.NONE

        # Plains
        if t_air_min <= 2.0:
            return ColdWaveSeverity.SEVERE_COLD_WAVE
        if t_air_min <= 4.0:
            return ColdWaveSeverity.COLD_WAVE

        if t_normal_min >= 10.0:
            if departure <= -6.5:
                return ColdWaveSeverity.SEVERE_COLD_WAVE
            elif departure <= -4.5:
                return ColdWaveSeverity.COLD_WAVE

        return ColdWaveSeverity.NONE

    @staticmethod
    def classify_ground_frost(t_grass_min: float) -> GroundFrostRisk:
        """
        Classifies Ground Frost risk according to grass minimum temperature:
        - T_grass > 0.0°C: NONE
        - -2.0°C < T_grass <= 0.0°C: LIGHT
        - -4.0°C < T_grass <= -2.0°C: MODERATE
        - T_grass <= -4.0°C: SEVERE
        """
        if t_grass_min <= -4.0:
            return GroundFrostRisk.SEVERE
        elif t_grass_min <= -2.0:
            return GroundFrostRisk.MODERATE
        elif t_grass_min <= 0.0:
            return GroundFrostRisk.LIGHT
        return GroundFrostRisk.NONE

    @staticmethod
    def assess_hypothermia(wind_chill_c: float) -> HypothermiaRisk:
        if wind_chill_c <= 0.0:
            return HypothermiaRisk.EXTREME
        elif wind_chill_c <= 4.0:
            return HypothermiaRisk.HIGH
        elif wind_chill_c <= 8.0:
            return HypothermiaRisk.ELEVATED
        return HypothermiaRisk.LOW

    @classmethod
    def get_rabi_crop_advisories(
        cls,
        frost_risk: GroundFrostRisk,
        t_min: float,
    ) -> List[CropVulnerabilityItem]:
        """
        ICAR-CRIDA field-validated crop protection measures against cold wave and frost.
        """
        items: List[CropVulnerabilityItem] = []

        # Mustard
        mustard_loss = 0
        mustard_countermeasures = [
            "Monitor crop for pod frost blistering and white floral blight.",
        ]
        if frost_risk in [GroundFrostRisk.MODERATE, GroundFrostRisk.SEVERE] or t_min <= 3.0:
            mustard_loss = 45 if frost_risk == GroundFrostRisk.MODERATE else 65
            mustard_countermeasures = [
                "Apply light sprinkler irrigation in evening to increase soil heat storage and raise canopy temperature by 1.5–2°C.",
                "Create smoke screens (smudge fire using dry straw/biomass) along northwest field boundaries between 11 PM and 5 AM.",
                "Foliar spray of 0.1% commercial sulfuric acid (1 ml H2SO4 per liter of water) or thiourea (500 ppm) to lower cellular freezing threshold.",
            ]
        elif frost_risk == GroundFrostRisk.LIGHT:
            mustard_loss = 20
            mustard_countermeasures = [
                "Provide light protective irrigation to prevent soil radiation loss.",
                "Burn weed heaps on windward border to create gentle thermal blanket.",
            ]
        items.append(
            CropVulnerabilityItem(
                crop_name="Mustard / Rapeseed (Sarson)",
                critical_stage="Pod Formation & Siliqua Filling",
                injury_mechanism="Intracellular ice crystallization causing pod abortion, shriveled seed formation, and oil content degradation.",
                yield_loss_risk_pct=mustard_loss,
                countermeasures=mustard_countermeasures,
            )
        )

        # Potato
        potato_loss = 0
        potato_countermeasures = [
            "Perform soil earthing-up around tuber mounds to provide thermal insulation.",
        ]
        if frost_risk in [GroundFrostRisk.MODERATE, GroundFrostRisk.SEVERE] or t_min <= 3.0:
            potato_loss = 50 if frost_risk == GroundFrostRisk.MODERATE else 75
            potato_countermeasures = [
                "Irrigate fields immediately during evening; wet soil holds twice the heat capacity of dry soil.",
                "Cover emerging potato nurseries with plastic sheet or sarkanda thatch during night; remove at sunrise.",
                "Spray 0.2% Mancozeb 75 WP to prevent secondary Late Blight infection triggered by tissue frost injury.",
            ]
        elif frost_risk == GroundFrostRisk.LIGHT:
            potato_loss = 25
            potato_countermeasures = [
                "Maintain adequate soil moisture via furrow irrigation.",
                "Keep plastic mulch intact over ridge beds.",
            ]
        items.append(
            CropVulnerabilityItem(
                crop_name="Potato (Aloo)",
                critical_stage="Vegetative Canopy & Tuber Initiation",
                injury_mechanism="Cellular membrane rupture causing black leaf necrosis, foliage collapse, and severe predisposition to Phytophthora late blight.",
                yield_loss_risk_pct=potato_loss,
                countermeasures=potato_countermeasures,
            )
        )

        # Wheat
        wheat_loss = 0
        wheat_countermeasures = [
            "Normal vegetative tillering; winter chill benefits vernalization.",
        ]
        if frost_risk in [GroundFrostRisk.MODERATE, GroundFrostRisk.SEVERE] or t_min <= 2.0:
            wheat_loss = 20 if frost_risk == GroundFrostRisk.MODERATE else 35
            wheat_countermeasures = [
                "Apply light irrigation at crown root initiation (CRI) or booting stage to buffer microclimate.",
                "Avoid nitrogenous top-dressing during active cold wave spell as tender lush foliage is susceptible to frost scorch.",
            ]
        elif frost_risk == GroundFrostRisk.LIGHT:
            wheat_loss = 10
            wheat_countermeasures = [
                "Ensure soil is not under drought stress; apply light watering.",
            ]
        items.append(
            CropVulnerabilityItem(
                crop_name="Wheat (Gehun)",
                critical_stage="Crown Root Initiation / Booting",
                injury_mechanism="Florets become sterile if frost occurs at ear emergence; tip leaf scorching.",
                yield_loss_risk_pct=wheat_loss,
                countermeasures=wheat_countermeasures,
            )
        )

        # Winter Vegetables (Tomato / Brinjal / Pea)
        veg_loss = 15 if frost_risk == GroundFrostRisk.LIGHT else (50 if frost_risk == GroundFrostRisk.MODERATE else 85)
        items.append(
            CropVulnerabilityItem(
                crop_name="Winter Vegetables (Tomato, Pea, Brinjal)",
                critical_stage="Flowering & Early Fruiting",
                injury_mechanism="Severe water soaking and sudden wilting of tender blossoms; fruit drop.",
                yield_loss_risk_pct=veg_loss,
                countermeasures=[
                    "Erect straw thatch (sarki) on northwestern exposure sloping towards southeast.",
                    "Spray 0.2% potassium nitrate (KNO3) to increase cell sap osmotic concentration.",
                    "Harvest all mature fruits immediately before predicted sub-zero nocturnal grass frost.",
                ],
            )
        )

        return items

    @classmethod
    def get_urban_shelter_advisory(
        cls,
        cold_severity: ColdWaveSeverity,
        hypothermia_risk: HypothermiaRisk,
        wind_chill_c: float,
    ) -> UrbanShelterAdvisory:
        is_shelter_active = cold_severity in [
            ColdWaveSeverity.COLD_WAVE,
            ColdWaveSeverity.SEVERE_COLD_WAVE,
        ] or wind_chill_c <= 5.0

        layers = 2
        if wind_chill_c <= 2.0:
            layers = 4
        elif wind_chill_c <= 6.0:
            layers = 3

        livestock_rules = [
            "Provide dry straw / husk bedding (6–8 inches thick) on concrete barn floors to stop conductive body heat loss.",
            "Cover animal sheds with gunny bags / tarpaulin curtains during nighttime to shield against northerly winds.",
            "Offer lukewarm drinking water and supplement daily cattle feed with 100g mineral mixture and jaggery (gur) for metabolic warmth.",
            "Keep young calves and poultry birds under 100W incandescent warming lamps during night.",
        ]

        return UrbanShelterAdvisory(
            night_shelter_activated=is_shelter_active,
            hypothermia_risk=hypothermia_risk,
            recommended_clothing_layers=layers,
            livestock_protection_rules=livestock_rules,
        )

    @classmethod
    def generate_multilingual_bulletins(
        cls,
        station_name: str,
        t_min: float,
        t_grass: float,
        severity: ColdWaveSeverity,
        frost_risk: GroundFrostRisk,
    ) -> Dict[str, str]:
        sev_label = severity.value.replace("_", " ")
        frost_label = frost_risk.value

        en = (
            f"IMD BULLETIN: {sev_label} declared for {station_name}. Minimum air temperature at {t_min}°C "
            f"with Grass Minimum Temperature plunging to {t_grass}°C ({frost_label} Ground Frost risk). "
            f"Farmers are strongly urged to apply evening irrigation and smudge fires across mustard and potato fields. "
            f"Urban local bodies must ensure 24x7 operational readiness of Rain Basera night shelters."
        )

        hi = (
            f"आईएमडी शीत लहर बुलेटिन: {station_name} में {sev_label} घोषित। न्यूनतम तापमान {t_min}°C और "
            f"घास स्तर का न्यूनतम तापमान {t_grass}°C ({frost_label} पाला जोखिम) तक गिर गया है। "
            f"किसानों से सरसों और आलू की फसलों में सायंकालीन हल्की सिंचाई तथा खेत की मेड़ों पर धुआं करने की अपील की जाती है। "
            f"नगर निकाय रैन बसेरों को पूर्ण रूप से संचालित रखें।"
        )

        pa = (
            f"ਮੌਸਮ ਵਿਭਾਗ ਸੀਤ ਲਹਿਰ ਚੇਤਾਵਨੀ: {station_name} ਵਿੱਚ {sev_label} ਦਾ ਐਲਾਨ। ਘੱਟੋ-ਘੱਟ ਤਾਪਮਾਨ {t_min}°C ਅਤੇ "
            f"ਜ਼ਮੀਨੀ ਘਾਹ ਦਾ ਤਾਪਮਾਨ {t_grass}°C ਤੱਕ ਡਿੱਗ ਗਿਆ ਹੈ ({frost_label} ਕੋਰਾ/ਪਾਲਾ ਖਤਰਾ)। "
            f"ਕਿਸਾਨ ਸਰ੍ਹੋਂ ਅਤੇ ਆਲੂ ਦੀ ਫਸਲ ਨੂੰ ਬਚਾਉਣ ਲਈ ਸ਼ਾਮ ਵੇਲੇ ਹਲਕਾ ਪਾਣੀ ਲਾਉਣ ਅਤੇ ਧੂੰਆਂ ਕਰਨ। "
            f"ਬੇਘਰ ਲੋਕਾਂ ਲਈ ਰੈਣ ਬਸੇਰੇ ਤੁਰੰਤ ਖੋਲ੍ਹੇ ਜਾਣ।"
        )

        bn = (
            f"আইএমডি শৈত্যপ্রবাহ সতর্কতা: {station_name}-এ {sev_label} জারি। সর্বনিম্ন তাপমাত্রা {t_min}°C এবং "
            f"তৃণস্তরের তাপমাত্রা নেমে দাঁড়িয়েছে {t_grass}°C ({frost_label} তুহিন/তুষারপাতের ঝুঁকি)। "
            f"সরিষা ও আলু ফসলের সুরক্ষায় কৃষকদের সন্ধ্যায় হালকা সেচ ও ধোঁয়ার ব্যবস্থা করার পরামর্শ দেওয়া হচ্ছে। "
            f"শহরাঞ্চলে রাত্রিকালীন আশ্রয়কেন্দ্র প্রস্তুত রাখা আবশ্যক।"
        )

        ur = (
            f"محکمہ موسمیات سرد لہر بلیٹن: {station_name} میں {sev_label} نافذ۔ کم سے کم درجہ حرارت {t_min}°C اور "
            f"گھاس کی سطح کا درجہ حرارت {t_grass}°C تک گر چکا ہے ({frost_label} پالا پڑنے کا خطرہ)۔ "
            f"کسانوں کو سرسوں اور آلو کی فصل کے تحفظ کے لیے شام میں ہلکی آبپاشی اور دھواں کرنے کا مشورہ دیا جاتا ہے۔ "
            f"شہری انتظامیہ رین بسیروں کو فعال رکھے۔"
        )

        return {
            "en": en,
            "hi": hi,
            "pa": pa,
            "bn": bn,
            "ur": ur,
        }

    @classmethod
    def get_cold_wave_assessment(
        cls,
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        station_id: Optional[str] = None,
    ) -> ColdWaveResponse:
        # 1. Match requested station or pick closest geodetic station
        selected_station = cls.MONITORING_STATIONS[0]
        if station_id:
            for st in cls.MONITORING_STATIONS:
                if st["station_id"].upper() == station_id.upper():
                    selected_station = st
                    break
        elif latitude is not None and longitude is not None:
            min_dist = float("inf")
            for st in cls.MONITORING_STATIONS:
                # Euclidean approximation in degrees
                d = math.hypot(st["latitude"] - latitude, st["longitude"] - longitude)
                if d < min_dist:
                    min_dist = d
                    selected_station = st

        t_min = selected_station["t_min"]
        t_normal_min = selected_station["t_normal_min"]
        oktas = selected_station["sky_cover_oktas"]
        wind_kmh = selected_station["wind_speed_kmh"]
        dew_point = selected_station["dew_point_c"]
        is_hill = selected_station["is_hill_station"]

        # 2. Compute physics
        t_grass, net_rad_wm2 = cls.calculate_stefan_boltzmann_cooling(t_min, oktas, wind_kmh)
        wind_chill = cls.calculate_wind_chill(t_min, wind_kmh)
        departure = round(t_min - t_normal_min, 1)

        # 3. Classifications
        cold_severity = cls.classify_cold_wave(t_min, t_normal_min, is_hill)
        ground_frost = cls.classify_ground_frost(t_grass)
        hypothermia_risk = cls.assess_hypothermia(wind_chill)

        # 4. Crop & Urban Guidance
        crop_advisories = cls.get_rabi_crop_advisories(ground_frost, t_min)
        urban_shelter = cls.get_urban_shelter_advisory(cold_severity, hypothermia_risk, wind_chill)

        # 5. Station directory with computed live metrics
        active_stations: List[ColdwaveStation] = []
        for st in cls.MONITORING_STATIONS:
            st_tgrass, _ = cls.calculate_stefan_boltzmann_cooling(st["t_min"], st["sky_cover_oktas"], st["wind_speed_kmh"])
            st_sev = cls.classify_cold_wave(st["t_min"], st["t_normal_min"], st["is_hill_station"])
            st_frost = cls.classify_ground_frost(st_tgrass)
            active_stations.append(
                ColdwaveStation(
                    station_id=st["station_id"],
                    station_name=st["station_name"],
                    state=st["state"],
                    latitude=st["latitude"],
                    longitude=st["longitude"],
                    elevation_m=st["elevation_m"],
                    is_hill_station=st["is_hill_station"],
                    t_min=st["t_min"],
                    t_grass=st_tgrass,
                    cold_wave_severity=st_sev,
                    frost_risk=st_frost,
                )
            )

        # 6. Headline & Bulletins
        sev_text = cold_severity.value.replace("_", " ").title()
        frost_text = ground_frost.value.title()
        headline = (
            f"{sev_text} warning in effect for {selected_station['station_name']} ({selected_station['state']}). "
            f"Ground minimum temp {t_grass}°C with {frost_text} frost risk. Wind chill {wind_chill}°C."
        )

        bulletins = cls.generate_multilingual_bulletins(
            selected_station["station_name"],
            t_min,
            t_grass,
            cold_severity,
            ground_frost,
        )

        physics = NocturnalCoolingPhysics(
            t_air_min=t_min,
            t_normal_min=t_normal_min,
            departure_c=departure,
            t_grass_min=t_grass,
            sky_cover_oktas=oktas,
            wind_speed_kmh=wind_kmh,
            dew_point_c=dew_point,
            wind_chill_c=wind_chill,
            net_radiation_loss_wm2=net_rad_wm2,
        )

        return ColdWaveResponse(
            station_id=selected_station["station_id"],
            station_name=selected_station["station_name"],
            state=selected_station["state"],
            latitude=selected_station["latitude"],
            longitude=selected_station["longitude"],
            elevation_m=selected_station["elevation_m"],
            is_hill_station=selected_station["is_hill_station"],
            timestamp=datetime.now(timezone.utc).isoformat(),
            cold_wave_severity=cold_severity,
            ground_frost_risk=ground_frost,
            summary_headline=headline,
            physics=physics,
            rabi_crop_advisories=crop_advisories,
            urban_shelter=urban_shelter,
            multilingual_bulletins=bulletins,
            monitoring_stations=active_stations,
        )
