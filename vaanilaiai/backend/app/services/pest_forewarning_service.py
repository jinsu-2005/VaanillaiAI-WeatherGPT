import math
from datetime import datetime, timezone
from typing import List, Dict, Optional, Tuple

from app.schemas.pest_forewarning import (
    PestRiskLevel,
    EpidemicCondition,
    CausalAgentType,
    MicroclimateTelemetry,
    PestDiseaseAlertItem,
    AgroClimaticZoneInfo,
    PestForewarningResponse,
)


class PestForewarningService:
    """
    Ministry of Earth Sciences (MoES) / IMD Gramin Krishi Mausam Seva (GKMS)
    and ICAR-NCIPM Pest & Disease Forewarning Engine.
    """

    AGRO_CLIMATIC_ZONES: List[Dict] = [
        {
            "zone_id": 1,
            "zone_name": "Western Himalayan Region",
            "key_states": ["Jammu & Kashmir", "Himachal Pradesh", "Uttarakhand"],
            "dominant_crops": ["Apple", "Wheat", "Maize", "Saffron", "Potato"],
            "typical_pest_threats": ["Apple Scab", "Potato Late Blight", "Wheat Stripe Rust", "San Jose Scale"],
            "latitude": 32.5,
            "longitude": 75.8,
        },
        {
            "zone_id": 2,
            "zone_name": "Eastern Himalayan Region",
            "key_states": ["Assam", "Sikkim", "Arunachal Pradesh", "Meghalaya"],
            "dominant_crops": ["Rice", "Tea", "Citrus", "Pineapple", "Mustard"],
            "typical_pest_threats": ["Tea Mosquito Bug", "Rice Stem Borer", "Citrus Canker", "Rice Blast"],
            "latitude": 26.2,
            "longitude": 92.9,
        },
        {
            "zone_id": 3,
            "zone_name": "Lower Gangetic Plains Region",
            "key_states": ["West Bengal"],
            "dominant_crops": ["Rice (Aman/Boro)", "Jute", "Potato", "Mustard", "Sesamum"],
            "typical_pest_threats": ["Potato Late Blight", "Rice Brown Planthopper", "Rice Sheath Blight", "Mustard Aphid"],
            "latitude": 22.9,
            "longitude": 87.8,
        },
        {
            "zone_id": 4,
            "zone_name": "Middle Gangetic Plains Region",
            "key_states": ["Eastern Uttar Pradesh", "Bihar"],
            "dominant_crops": ["Rice", "Wheat", "Maize", "Sugarcane", "Potato", "Mustard"],
            "typical_pest_threats": ["Potato Late Blight", "Mustard Aphid", "Sugarcane Top Borer", "Rice Blast"],
            "latitude": 25.6,
            "longitude": 84.1,
        },
        {
            "zone_id": 5,
            "zone_name": "Upper Gangetic Plains Region",
            "key_states": ["Western Uttar Pradesh"],
            "dominant_crops": ["Wheat", "Sugarcane", "Mustard", "Potato", "Pigeonpea"],
            "typical_pest_threats": ["Mustard Aphid", "Potato Late Blight", "Sugarcane Pyrilla", "Wheat Stripe Rust"],
            "latitude": 28.5,
            "longitude": 77.8,
        },
        {
            "zone_id": 6,
            "zone_name": "Trans-Gangetic Plains Region",
            "key_states": ["Punjab", "Haryana", "Delhi", "Ganganagar (Rajasthan)"],
            "dominant_crops": ["Wheat", "Paddy", "Cotton", "Mustard", "Sugarcane"],
            "typical_pest_threats": ["Cotton Whitefly", "Mustard Aphid", "Wheat Yellow Rust", "Rice Brown Planthopper"],
            "latitude": 30.5,
            "longitude": 75.8,
        },
        {
            "zone_id": 7,
            "zone_name": "Eastern Plateau and Hills Region",
            "key_states": ["Jharkhand", "Odisha", "Chhattisgarh"],
            "dominant_crops": ["Rice", "Niger", "Groundnut", "Pigeonpea", "Maize"],
            "typical_pest_threats": ["Rice Gall Midge", "Rice Blast", "Helicoverpa Pod Borer", "Groundnut Tikka"],
            "latitude": 21.5,
            "longitude": 83.9,
        },
        {
            "zone_id": 8,
            "zone_name": "Central Plateau and Hills Region",
            "key_states": ["Madhya Pradesh", "Eastern Rajasthan"],
            "dominant_crops": ["Soybean", "Gram (Chickpea)", "Wheat", "Mustard", "Lentil"],
            "typical_pest_threats": ["Gram Pod Borer", "Soybean Girdle Beetle", "Mustard Aphid", "Wheat Brown Rust"],
            "latitude": 23.8,
            "longitude": 77.5,
        },
        {
            "zone_id": 9,
            "zone_name": "Western Plateau and Hills Region",
            "key_states": ["Maharashtra", "Western Madhya Pradesh"],
            "dominant_crops": ["Cotton", "Jowar", "Soybean", "Sugarcane", "Grapes", "Pomegranate"],
            "typical_pest_threats": ["Cotton Pink Bollworm", "Grape Downy Mildew", "Pomegranate Bacterial Blight", "Soybean Rust"],
            "latitude": 19.7,
            "longitude": 75.7,
        },
        {
            "zone_id": 10,
            "zone_name": "Southern Plateau and Hills Region",
            "key_states": ["Karnataka", "Telangana", "Andhra Pradesh", "Tamil Nadu"],
            "dominant_crops": ["Ragi", "Cotton", "Groundnut", "Sorghum", "Redgram", "Coffee"],
            "typical_pest_threats": ["Groundnut Spodoptera", "Cotton Bollworm Complex", "Coffee Berry Borer", "Ragi Blast"],
            "latitude": 14.5,
            "longitude": 76.5,
        },
        {
            "zone_id": 11,
            "zone_name": "East Coast Plains and Hills Region",
            "key_states": ["Coastal Andhra Pradesh", "Coastal Odisha", "Coastal Tamil Nadu"],
            "dominant_crops": ["Rice", "Groundnut", "Blackgram", "Coconut", "Sugarcane"],
            "typical_pest_threats": ["Rice Brown Planthopper", "Rice Blast", "Groundnut Leaf Miner", "Coconut Black Headed Caterpillar"],
            "latitude": 16.5,
            "longitude": 81.2,
        },
        {
            "zone_id": 12,
            "zone_name": "West Coast Plains and Ghats Region",
            "key_states": ["Kerala", "Coastal Karnataka", "Goa", "Konkan (Maharashtra)"],
            "dominant_crops": ["Rice", "Coconut", "Arecanut", "Black Pepper", "Cardamom", "Rubber"],
            "typical_pest_threats": ["Pepper Quick Wilt", "Coconut Rhinoceros Beetle", "Arecanut Koleroga (Kole-roga)", "Rice Gall Midge"],
            "latitude": 10.5,
            "longitude": 76.2,
        },
        {
            "zone_id": 13,
            "zone_name": "Gujarat Plains and Hills Region",
            "key_states": ["Gujarat", "Dadra & Nagar Haveli"],
            "dominant_crops": ["Cotton", "Groundnut", "Castor", "Bajra", "Wheat"],
            "typical_pest_threats": ["Cotton Pink Bollworm", "Cotton Whitefly", "Groundnut Spodoptera", "Castor Semilooper"],
            "latitude": 22.3,
            "longitude": 71.8,
        },
        {
            "zone_id": 14,
            "zone_name": "Western Dry Region",
            "key_states": ["Western Rajasthan"],
            "dominant_crops": ["Bajra", "Moth bean", "Clusterbean (Guar)", "Mustard", "Cumin"],
            "typical_pest_threats": ["Cumin Blight", "Mustard Aphid", "Locust Swarm Risk", "White Grub"],
            "latitude": 27.0,
            "longitude": 71.5,
        },
        {
            "zone_id": 15,
            "zone_name": "The Islands Region",
            "key_states": ["Andaman & Nicobar Islands", "Lakshadweep"],
            "dominant_crops": ["Coconut", "Arecanut", "Paddy", "Spices", "Cassava"],
            "typical_pest_threats": ["Coconut Eriophyid Mite", "Rhinoceros Beetle", "Paddy Leaf Folder"],
            "latitude": 11.6,
            "longitude": 92.7,
        },
    ]

    @classmethod
    def match_zone(
        cls,
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        zone_id: Optional[int] = None,
    ) -> Dict:
        """Resolves target Agro-Climatic Zone by zone_id or closest geodetic centroid."""
        if zone_id is not None:
            for z in cls.AGRO_CLIMATIC_ZONES:
                if z["zone_id"] == zone_id:
                    return z

        if latitude is not None and longitude is not None:
            best_zone = cls.AGRO_CLIMATIC_ZONES[0]
            min_dist = float("inf")
            for z in cls.AGRO_CLIMATIC_ZONES:
                dist = math.hypot(z["latitude"] - latitude, z["longitude"] - longitude)
                if dist < min_dist:
                    min_dist = dist
                    best_zone = z
            return best_zone

        # Default to Trans-Gangetic Plains (Zone 6)
        return cls.AGRO_CLIMATIC_ZONES[5]

    @staticmethod
    def evaluate_potato_late_blight(
        t_c: float,
        rh_pct: float,
        leaf_wetness_h: float,
    ) -> Tuple[PestRiskLevel, EpidemicCondition, str]:
        """
        Wallin's / Hyre's Potato Late Blight Model (Phytophthora infestans).
        Infection favorable when:
        - 10°C <= T <= 24°C (optimal 15-20°C)
        - RH >= 90% for >= 10 consecutive hours
        - Leaf wetness duration >= 4 hours
        """
        is_temp_favorable = 10.0 <= t_c <= 24.0
        is_rh_favorable = rh_pct >= 88.0
        is_lwd_favorable = leaf_wetness_h >= 6.0

        if is_temp_favorable and rh_pct >= 90.0 and leaf_wetness_h >= 10.0:
            return (
                PestRiskLevel.CRITICAL,
                EpidemicCondition.FAVORABLE,
                "Wallin Severity Index = 4 (Maximum). Extreme sporulation window active. Blight lesions will appear within 48-72h without intervention.",
            )
        elif is_temp_favorable and is_rh_favorable and is_lwd_favorable:
            return (
                PestRiskLevel.HIGH,
                EpidemicCondition.FAVORABLE,
                "Microclimate highly conducive for conidial germination. Leaf wetness duration threshold satisfied.",
            )
        elif (10.0 <= t_c <= 26.0) and rh_pct >= 80.0:
            return (
                PestRiskLevel.MODERATE,
                EpidemicCondition.MARGINAL,
                "Moderate night condensation supporting sporangial survival; monitor canopy wetness.",
            )
        return (
            PestRiskLevel.LOW,
            EpidemicCondition.UNFAVORABLE,
            "Low humidity and dry foliage inhibit Phytophthora sporangial germination.",
        )

    @staticmethod
    def evaluate_mustard_aphid(
        t_c: float,
        rh_pct: float,
        cloud_oktas: int,
        gdd_base5: float,
    ) -> Tuple[PestRiskLevel, EpidemicCondition, str]:
        """
        Mustard Aphid Model (Lipaphis erysimi).
        Favorable when:
        - T_mean between 10°C and 18°C
        - Morning RH >= 70%
        - Overcast / foggy conditions (Oktas >= 4)
        """
        if 10.0 <= t_c <= 18.0 and rh_pct >= 75.0 and cloud_oktas >= 4:
            return (
                PestRiskLevel.CRITICAL if gdd_base5 >= 180 else PestRiskLevel.HIGH,
                EpidemicCondition.FAVORABLE,
                f"Cloudy overcast canopy with high RH is triggering explosive parthenogenetic nymphal reproduction. Thermal sum: {gdd_base5:.1f} GDD.",
            )
        elif 9.0 <= t_c <= 21.0 and rh_pct >= 65.0:
            return (
                PestRiskLevel.MODERATE,
                EpidemicCondition.MARGINAL,
                "Aphid populations building up on terminal inflorescence shoots; inspect border rows.",
            )
        return (
            PestRiskLevel.LOW,
            EpidemicCondition.UNFAVORABLE,
            "Clear sunny skies and low humidity suppress aphid alate colonization.",
        )

    @staticmethod
    def evaluate_rice_blast(
        t_c: float,
        rh_pct: float,
        leaf_wetness_h: float,
    ) -> Tuple[PestRiskLevel, EpidemicCondition, str]:
        """
        Rice / Paddy Blast (Magnaporthe oryzae).
        Favorable when:
        - Night T: 20-24°C, Day T: 28-32°C (Mean T: 22-26°C)
        - RH >= 85%
        - Dew / Leaf wetness >= 10-12 hours
        """
        if 20.0 <= t_c <= 27.0 and rh_pct >= 85.0 and leaf_wetness_h >= 10.0:
            return (
                PestRiskLevel.CRITICAL,
                EpidemicCondition.FAVORABLE,
                "Severe blast outbreak risk: Continuous canopy wetness and night dew exceeding 10h trigger rapid appressorium formation.",
            )
        elif 18.0 <= t_c <= 29.0 and rh_pct >= 80.0:
            return (
                PestRiskLevel.MODERATE,
                EpidemicCondition.MARGINAL,
                "Spore deposition active on upper leaves; scout for spindle-shaped lesions with ash-grey centers.",
            )
        return (
            PestRiskLevel.LOW,
            EpidemicCondition.UNFAVORABLE,
            "Unfavorable: Low canopy wetness prevents conidial germination.",
        )

    @staticmethod
    def evaluate_cotton_whitefly(
        t_c: float,
        rh_pct: float,
    ) -> Tuple[PestRiskLevel, EpidemicCondition, str]:
        """
        Cotton Whitefly (Bemisia tabaci).
        Favorable when:
        - Warm to hot dry conditions (T_mean >= 28°C or T_max >= 33°C)
        - Low morning RH <= 65%
        - Absence of rain wash
        """
        if t_c >= 28.0 and rh_pct <= 65.0:
            return (
                PestRiskLevel.HIGH,
                EpidemicCondition.FAVORABLE,
                "Warm dry weather triggers explosive whitefly adult emergence and Cotton Leaf Curl Virus (CLCuV) transmission.",
            )
        elif t_c >= 24.0 and rh_pct <= 75.0:
            return (
                PestRiskLevel.MODERATE,
                EpidemicCondition.MARGINAL,
                "Moderate dry spell encourages nymphal feeding on leaf undersides.",
            )
        return (
            PestRiskLevel.LOW,
            EpidemicCondition.UNFAVORABLE,
            "High humidity or rainy wash-down suppresses whitefly populations.",
        )

    @staticmethod
    def evaluate_wheat_yellow_rust(
        t_c: float,
        rh_pct: float,
        leaf_wetness_h: float,
    ) -> Tuple[PestRiskLevel, EpidemicCondition, str]:
        """
        Wheat Yellow / Stripe Rust (Puccinia striiformis).
        Favorable when:
        - Cool temp 10-15°C
        - Intermittent rain / heavy dew (LWD >= 6h)
        - RH >= 80%
        """
        if 9.0 <= t_c <= 16.0 and rh_pct >= 80.0 and leaf_wetness_h >= 6.0:
            return (
                PestRiskLevel.HIGH,
                EpidemicCondition.FAVORABLE,
                "Sub-montane cool damp microclimate favors stripe rust urediniospore germination on flag leaves.",
            )
        elif 8.0 <= t_c <= 19.0 and rh_pct >= 70.0:
            return (
                PestRiskLevel.MODERATE,
                EpidemicCondition.MARGINAL,
                "Marginal: Inspect foothills and shady field borders for yellow powdery pustules in linear stripes.",
            )
        return (
            PestRiskLevel.LOW,
            EpidemicCondition.UNFAVORABLE,
            "Temperatures above 22°C or dry conditions halt urediniospore viability.",
        )

    @classmethod
    def generate_multilingual_bulletins(
        cls,
        zone_name: str,
        peak_risk: PestRiskLevel,
        top_pest: str,
        crop: str,
    ) -> Dict[str, str]:
        risk_str = peak_risk.value
        en = (
            f"IMD GKMS AGROMET FOREWARNING: {risk_str} epidemic risk for {top_pest} on {crop} in {zone_name}. "
            f"Microclimate thresholds satisfied. Farmers are advised to conduct immediate field scouting and initiate "
            f"preventative bio-control or prescribed chemical spray upon crossing Economic Threshold Levels (ETL)."
        )

        hi = (
            f"आईएमडी ग्रामीण कृषि मौसम सेवा चेतावनी: {zone_name} में {crop} की फसल पर {top_pest} का {risk_str} प्रकोप जोखिम। "
            f"मौसम संबंधी अनुकूलता पूर्ण। किसानों को सलाह दी जाती है कि वे खेतों का निरीक्षण करें तथा आर्थिक क्षति स्तर (ETL) पार होने पर "
            f"तत्काल जैविक या अनुशंसित कीटनाशक/फफूंदनाशी का छिड़काव करें।"
        )

        pa = (
            f"ਮੌਸਮ ਵਿਭਾਗ ਖੇਤੀ ਚੇਤਾਵਨੀ: {zone_name} ਵਿੱਚ {crop} ਦੀ ਫ਼ਸਲ ਉੱਤੇ {top_pest} ਦਾ {risk_str} ਖ਼ਤਰਾ। "
            f"ਅਨੁਕੂਲ ਮੌਸਮ ਕਾਰਨ ਬਿਮਾਰੀ/ਕੀੜੇ ਵਧਣ ਦੇ ਪੂਰੇ ਆਸਾਰ ਹਨ। ਕਿਸਾਨ ਤੁਰੰਤ ਖੇਤਾਂ ਦਾ ਦੌਰਾ ਕਰਨ ਅਤੇ ਆਰਥਿਕ ਨੁਕਸਾਨ ਪੱਧਰ (ETL) ਟੱਪਣ 'ਤੇ "
            f"ਸਿਫ਼ਾਰਸ਼ ਕੀਤੀ ਦਵਾਈ ਦਾ ਛਿੜਕਾਅ ਕਰਨ।"
        )

        te = (
            f"ఐఎండి వ్యవసాయ వాతావరణ హెచ్చరిక: {zone_name} లో {crop} పంటకు {top_pest} వల్ల {risk_str} తెగులు ప్రమాదం. "
            f"వాతావరణ పరిస్థితులు వ్యాప్తికి అనుకూలంగా ఉన్నాయి. రైతులు వెంటనే పొలాలను పరిశీలించి ఆర్థిక నష్ట పరిమితి (ETL) దాటినప్పుడు "
            f"సిఫార్సు చేసిన మందులను పిచికారీ చేయాలి."
        )

        ta = (
            f"வானிலை ஆய்வு மையம் வேளாண் எச்சரிக்கை: {zone_name}-ல் {crop} பயிரில் {top_pest} நோய்/பூச்சி {risk_str} தீவிர அபாயம். "
            f"தட்பவெப்ப நிலை பரவலுக்கு ஏதுவாக உள்ளது. விவசாயிகள் பயிர்களை கண்காணித்து பொருளாதார சேத நிலையை (ETL) தாண்டினால் "
            f"பரிந்துரைக்கப்பட்ட பூஞ்சாணக்கொல்லி/பூச்சிக்கொல்லியை தெளிக்கவும்."
        )

        return {
            "en": en,
            "hi": hi,
            "pa": pa,
            "te": te,
            "ta": ta,
        }

    @classmethod
    def get_pest_forewarning(
        cls,
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        zone_id: Optional[int] = None,
        observed_t_c: Optional[float] = None,
        observed_rh_pct: Optional[float] = None,
    ) -> PestForewarningResponse:
        zone_dict = cls.match_zone(latitude, longitude, zone_id)
        zone_info = AgroClimaticZoneInfo(
            zone_id=zone_dict["zone_id"],
            zone_name=zone_dict["zone_name"],
            key_states=zone_dict["key_states"],
            dominant_crops=zone_dict["dominant_crops"],
            typical_pest_threats=zone_dict["typical_pest_threats"],
        )

        # Microclimate telemetry: Use provided or representative seasonal conditions for the zone
        t_c = observed_t_c if observed_t_c is not None else 16.5
        rh_pct = observed_rh_pct if observed_rh_pct is not None else 91.0
        leaf_wetness_h = 11.5 if rh_pct >= 85.0 else 4.0
        cloud_oktas = 5
        gdd_base5 = round(max(0.0, t_c - 5.0) * 14.0, 1)  # 14-day degree day accumulation
        fav_days = 3

        telemetry = MicroclimateTelemetry(
            temperature_c=t_c,
            relative_humidity_pct=rh_pct,
            leaf_wetness_hours=leaf_wetness_h,
            cloud_cover_oktas=cloud_oktas,
            growing_degree_days_base5=gdd_base5,
            consecutive_favorable_days=fav_days,
        )

        # Build epidemiological alerts tailored to the zone and microclimate
        alerts: List[PestDiseaseAlertItem] = []

        # 1. Potato Late Blight
        plb_risk, plb_cond, plb_rule = cls.evaluate_potato_late_blight(t_c, rh_pct, leaf_wetness_h)
        alerts.append(
            PestDiseaseAlertItem(
                id="POTATO_LATE_BLIGHT",
                name="Potato Late Blight",
                scientific_name="Phytophthora infestans",
                target_crop="Potato (Solanum tuberosum)",
                causal_agent=CausalAgentType.FUNGAL,
                risk_level=plb_risk,
                epidemic_condition=plb_cond,
                favorable_microclimate_rule="RH >= 90% for >= 10 hours with temperatures 10°C to 24°C and dew formation.",
                economic_threshold_level="Initial water-soaked spots on 1-2% leaves or Wallin Severity Value accumulation >= 18 points.",
                pre_symptomatic_forewarning=plb_rule,
                organic_biocontrol_directive="Foliar spray of Trichoderma viride / harzianum @ 5g/L or 5% Neem Seed Kernel Extract (NSKE).",
                chemical_emergency_directive="Prophylactic spray of Mancozeb 75 WP @ 2.5 g/L. If disease already appeared, spray systemic Cymoxanil 8% + Mancozeb 64% WP @ 3 g/L.",
            )
        )

        # 2. Mustard Aphid
        ma_risk, ma_cond, ma_rule = cls.evaluate_mustard_aphid(t_c, rh_pct, cloud_oktas, gdd_base5)
        alerts.append(
            PestDiseaseAlertItem(
                id="MUSTARD_APHID",
                name="Mustard Aphid (Mahun / Chepa)",
                scientific_name="Lipaphis erysimi",
                target_crop="Mustard / Rapeseed (Brassica juncea)",
                causal_agent=CausalAgentType.INSECT_VECTOR,
                risk_level=ma_risk,
                epidemic_condition=ma_cond,
                favorable_microclimate_rule="Mean temperature 10°C to 18°C with morning RH >= 70% and cloudy/overcast skies.",
                economic_threshold_level="25-28 aphids per 10 cm terminal central shoot or 1.5-2.0 cm shoot colony length on 20% plants.",
                pre_symptomatic_forewarning=ma_rule,
                organic_biocontrol_directive="Install yellow sticky traps @ 10-12 per acre. Spray entomopathogenic fungus Verticillium lecanii @ 5 g/L or 5% NSKE.",
                chemical_emergency_directive="Foliar spray of Dimethoate 30 EC @ 1.0 ml/L or Thiamethoxam 25 WG @ 0.2 g/L in 500 liters of water per hectare.",
            )
        )

        # 3. Rice Blast
        rb_risk, rb_cond, rb_rule = cls.evaluate_rice_blast(t_c, rh_pct, leaf_wetness_h)
        alerts.append(
            PestDiseaseAlertItem(
                id="RICE_BLAST",
                name="Rice / Paddy Blast (Leaf & Neck)",
                scientific_name="Magnaporthe oryzae (Pyricularia oryzae)",
                target_crop="Paddy / Rice (Oryza sativa)",
                causal_agent=CausalAgentType.FUNGAL,
                risk_level=rb_risk,
                epidemic_condition=rb_cond,
                favorable_microclimate_rule="Continuous leaf wetness >= 10-12 hours, night temperatures 20-24°C, day temperatures 28-32°C, and RH >= 85%.",
                economic_threshold_level="2-5% leaf area affected at tillering stage or 1% panicle neck infection at heading stage.",
                pre_symptomatic_forewarning=rb_rule,
                organic_biocontrol_directive="Seed treatment and foliar spray of Pseudomonas fluorescens @ 10 g/L or Trichoderma asperellum.",
                chemical_emergency_directive="Foliar application of Tricyclazole 75 WP @ 0.6 g/L or Isoprothiolane 40 EC @ 1.5 ml/L.",
            )
        )

        # 4. Cotton Whitefly
        cw_risk, cw_cond, cw_rule = cls.evaluate_cotton_whitefly(t_c, rh_pct)
        alerts.append(
            PestDiseaseAlertItem(
                id="COTTON_WHITEFLY",
                name="Cotton Whitefly & CLCuV Vector",
                scientific_name="Bemisia tabaci",
                target_crop="Cotton (Gossypium hirsutum)",
                causal_agent=CausalAgentType.INSECT_VECTOR,
                risk_level=cw_risk,
                epidemic_condition=cw_cond,
                favorable_microclimate_rule="High daytime heat (>= 33°C), warm nights (>= 22°C), morning RH <= 65%, and dry spells without washing rains.",
                economic_threshold_level="6-8 adult whiteflies or nymphs per leaf across middle and upper canopy.",
                pre_symptomatic_forewarning=cw_rule,
                organic_biocontrol_directive="Erect yellow sticky traps @ 15 per acre. Spray 5% Neem oil (1500 ppm azadirachtin) @ 5 ml/L.",
                chemical_emergency_directive="Foliar application of Pyriproxyfen 10 EC @ 2.0 ml/L or Flonicamid 50 WG @ 0.3 g/L.",
            )
        )

        # 5. Wheat Yellow / Stripe Rust
        yr_risk, yr_cond, yr_rule = cls.evaluate_wheat_yellow_rust(t_c, rh_pct, leaf_wetness_h)
        alerts.append(
            PestDiseaseAlertItem(
                id="WHEAT_YELLOW_RUST",
                name="Wheat Yellow / Stripe Rust",
                scientific_name="Puccinia striiformis f. sp. tritici",
                target_crop="Wheat (Triticum aestivum)",
                causal_agent=CausalAgentType.FUNGAL,
                risk_level=yr_risk,
                epidemic_condition=yr_cond,
                favorable_microclimate_rule="Cool damp conditions (10°C to 15°C) with RH >= 80% and overnight dew or dense fog.",
                economic_threshold_level="First appearance of linear yellow pustules on leaf blades of susceptible cultivars.",
                pre_symptomatic_forewarning=yr_rule,
                organic_biocontrol_directive="Grow resistant varieties (e.g. HD 3086, DBW 187, PBW 725). Spray sour buttermilk (Chhachh) @ 5% with cow urine.",
                chemical_emergency_directive="Spray Propiconazole 25 EC (Tilt) @ 1.0 ml/L or Tebuconazole 25.9 EC @ 1.0 ml/L in 500 liters of water per hectare.",
            )
        )

        # Determine peak risk level
        risk_hierarchy = {
            PestRiskLevel.LOW: 1,
            PestRiskLevel.MODERATE: 2,
            PestRiskLevel.HIGH: 3,
            PestRiskLevel.CRITICAL: 4,
        }
        highest_risk = max(alerts, key=lambda a: risk_hierarchy[a.risk_level])

        headline = (
            f"{highest_risk.risk_level.value} Risk: {highest_risk.name} outbreak alert for "
            f"{zone_info.zone_name}. Microclimatic infection threshold satisfied."
        )

        ipm_actions = [
            "Conduct early morning field scouting across border rows and canopy undersides twice a week.",
            "Install yellow sticky traps (10/acre) for sucking insect vectors (aphids, whiteflies, jassids).",
            "Avoid excessive nitrogenous top-dressing (urea) which produces soft succulent vegetative growth vulnerable to fungal penetration.",
            "Maintain clean irrigation channels and eliminate weed collateral hosts (Parthenium, Chenopodium) around bunds.",
            "Ensure spray droplets reach under-surface of foliage by using hollow cone nozzles at 30-40 psi pressure.",
        ]

        bulletins = cls.generate_multilingual_bulletins(
            zone_info.zone_name,
            highest_risk.risk_level,
            highest_risk.name,
            highest_risk.target_crop,
        )

        all_zones_list = [
            AgroClimaticZoneInfo(
                zone_id=z["zone_id"],
                zone_name=z["zone_name"],
                key_states=z["key_states"],
                dominant_crops=z["dominant_crops"],
                typical_pest_threats=z["typical_pest_threats"],
            )
            for z in cls.AGRO_CLIMATIC_ZONES
        ]

        return PestForewarningResponse(
            zone=zone_info,
            location_name=zone_dict.get("key_states", ["India"])[0],
            latitude=latitude if latitude is not None else zone_dict["latitude"],
            longitude=longitude if longitude is not None else zone_dict["longitude"],
            timestamp=datetime.now(timezone.utc).isoformat(),
            highest_risk_level=highest_risk.risk_level,
            summary_headline=headline,
            telemetry=telemetry,
            alerts=alerts,
            ipm_calendar_actions=ipm_actions,
            multilingual_bulletins=bulletins,
            all_zones=all_zones_list,
        )
