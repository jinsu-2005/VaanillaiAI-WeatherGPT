import math
from datetime import datetime, timezone
from typing import Dict, List, Optional

from app.schemas.extended_range_prediction import (
    AgriculturalStressLevel,
    BsisoMode,
    ErpResponse,
    ErpZone,
    ErpZoneSummary,
    IcarDistrictContingency,
    IntraSeasonalPulseTelemetry,
    MjoConvectivePhase,
    MonsoonSpellState,
    RainfallDepartureTier,
    WeeklyErpForecast,
)


def _haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    r = 6371.0  # Earth's radius in kilometers
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (
        math.sin(dlat / 2) ** 2
        + math.cos(math.radians(lat1))
        * math.cos(math.radians(lat2))
        * math.sin(dlon / 2) ** 2
    )
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return r * c


def _get_departure_tier(pct: float) -> RainfallDepartureTier:
    if pct <= -99.0:
        return RainfallDepartureTier.NO_RAIN
    elif pct <= -60.0:
        return RainfallDepartureTier.LARGE_DEFICIENT
    elif pct <= -20.0:
        return RainfallDepartureTier.DEFICIENT
    elif pct <= 19.0:
        return RainfallDepartureTier.NORMAL
    elif pct <= 59.0:
        return RainfallDepartureTier.EXCESS
    else:
        return RainfallDepartureTier.LARGE_EXCESS


class ExtendedRangePredictionService:
    """IMD, NCMRWF & IITM Pune Extended Range Prediction (ERP) & Intra-Seasonal Monsoon Pulse Engine."""

    ZONES: Dict[str, Dict] = {
        "vidarbha_central_rainfed": {
            "zone_id": "vidarbha_central_rainfed",
            "zone_name": "Central India Rainfed Soybean-Cotton Zone",
            "state": "Maharashtra",
            "sub_division_name": "Vidarbha & West Madhya Pradesh",
            "latitude": 21.1458,
            "longitude": 79.0882,
            "dominant_crops": [
                "Soybean (JS 335, JS 9560)",
                "Bt Cotton",
                "Pigeonpea (Tur / Arhar)",
                "Chickpea (Rabi Gram)",
            ],
            "intra_seasonal_pulse": {
                "bsiso_mode": BsisoMode.BSISO_1_CANONICAL_30_60D,
                "bsiso_active_phase": 7,  # Phase 7: Break monsoon over central India
                "bsiso_amplitude": 1.75,
                "northward_propagation_speed_deg_per_day": 1.25,
                "mjo_phase": MjoConvectivePhase.PHASE_6_WESTERN_PACIFIC,
                "mjo_amplitude": 1.45,
                "findlater_jet_speed_kt": 18.5,
                "monsoon_trough_position_latitude": 28.5,  # Shifted north to foothills
                "break_spell_risk": True,
            },
            "four_week_forecast": [
                {
                    "week_number": 1,
                    "date_range_label": "Week 1: Days 1–7 (12–18 Sep)",
                    "rainfall_lpa_departure_pct": -42.0,
                    "rainfall_forecast_mm": 28.5,
                    "normal_lpa_rainfall_mm": 49.1,
                    "max_temp_anomaly_c": 1.8,
                    "min_temp_anomaly_c": 1.1,
                    "heatwave_coldwave_probability_pct": 25.0,
                    "monsoon_spell_state": MonsoonSpellState.BREAK_MONSOON_CRITICAL,
                },
                {
                    "week_number": 2,
                    "date_range_label": "Week 2: Days 8–14 (19–25 Sep)",
                    "rainfall_lpa_departure_pct": -25.0,
                    "rainfall_forecast_mm": 32.0,
                    "normal_lpa_rainfall_mm": 42.7,
                    "max_temp_anomaly_c": 1.2,
                    "min_temp_anomaly_c": 0.8,
                    "heatwave_coldwave_probability_pct": 15.0,
                    "monsoon_spell_state": MonsoonSpellState.WEAK_MONSOON,
                },
                {
                    "week_number": 3,
                    "date_range_label": "Week 3: Days 15–21 (26 Sep – 02 Oct)",
                    "rainfall_lpa_departure_pct": 15.0,
                    "rainfall_forecast_mm": 44.0,
                    "normal_lpa_rainfall_mm": 38.3,
                    "max_temp_anomaly_c": -0.4,
                    "min_temp_anomaly_c": 0.1,
                    "heatwave_coldwave_probability_pct": 5.0,
                    "monsoon_spell_state": MonsoonSpellState.POST_BREAK_REVIVAL,
                },
                {
                    "week_number": 4,
                    "date_range_label": "Week 4: Days 22–28 (03–09 Oct)",
                    "rainfall_lpa_departure_pct": 28.0,
                    "rainfall_forecast_mm": 46.5,
                    "normal_lpa_rainfall_mm": 36.3,
                    "max_temp_anomaly_c": -0.8,
                    "min_temp_anomaly_c": -0.2,
                    "heatwave_coldwave_probability_pct": 0.0,
                    "monsoon_spell_state": MonsoonSpellState.ACTIVE_SURGE,
                },
            ],
            "agricultural_contingency": {
                "stress_level": AgriculturalStressLevel.WARNING_PROLONGED_DRY_SPELL,
                "sowing_window_status": "Mid-Season Vegetative Dry Spell (18 Days Subdued Precipitation)",
                "contingency_crop_alternatives": [
                    "Maintain intercropped Pigeonpea (Arhar) + Soybean in 1:2 pattern to spread risk",
                    "For barren patches, sow drought-tolerant Greengram (BM 2003-2) or Blackgram (TAU 1)",
                    "Prepare field bunds for anticipated Week 3-4 monsoon revival to harvest run-off",
                ],
                "irrigation_mitigation_directive": "Provide protective life-saving micro-sprinkler irrigation from farm ponds (Amrit Sarovars / Khet Talab) during calm early mornings.",
                "in_situ_moisture_conservation": "Implement Broad Bed Furrow (BBF) or shallow intercultivation dust mulching to break capillary soil pores and retard evaporative moisture loss.",
                "standing_crop_intervention": "Foliar spray of 2% Urea or 1% Potassium Nitrate (13:0:45) on standing Soybean/Cotton to mitigate moisture stress and prevent flower/boll abortion.",
            },
            "vernacular_bulletins": {
                "en": "IMD-NCMRWF EXTENDED RANGE BULLETIN: Central India faces an active break monsoon spell in Week 1 (-42% LPA departure) and Week 2 (-25%). BSISO Phase 7 and MJO Phase 6 indicate suppressed convective activity. Strong revival indicated from Week 3 (+15%) into Week 4 (+28%). ICAR-CRIDA advises life-saving farm pond sprinkler irrigation and 1% KNO3 foliar sprays for standing Soybean and Cotton.",
                "hi": "आईएमडी-एनसीएमआरडब्ल्यूएफ विस्तारित पूर्वानुमान बुलेटिन: मध्य भारत में सप्ताह 1 (-42% एलपीए) और सप्ताह 2 में मानसून ब्रेक की स्थिति बनी रहेगी। सप्ताह 3 (+15%) और सप्ताह 4 (+28%) से बंगाल की खाड़ी से मानसूनी बारिश के मजबूत पुनरुद्धार की संभावना है। किसान भाई अमृत सरोवर से सोयाबीन व कपास में जीवनरक्षक सिंचाई करें एवं 1% पोटेशियम नाइट्रेट का छिड़काव करें।",
                "mr": "विदर्भ व मध्य भारत हवामान अंदाज: आठवडा १ (-४२% पाऊस) व आठवडा २ मध्ये मान्सून खंड (Break Monsoon) ची स्थिती राहील. आठवडा ३ (+१५%) व आठवडा ४ पासून जोरदार पाऊस परतण्याचे संकेत आहेत. शेततळ्यांमधून तुषार सिंचनाने संरक्षित पाणी द्यावे व २% युरिया किंवा १% पोटॅशियम नायट्रेटची फवारणी करावी.",
                "te": "విదర్భ మరియు మధ్య భారత వర్షపాత సూచన: రాబోయే 1-2 వారాలలో వర్షపాతం సాధారణం కంటే తక్కువగా (-42%) నమోదు కావచ్చు. 3-4వ వారాల్లో వర్షాలు బలంగా పుంజుకుంటాయి. పంటకుంటల ద్వారా పొలాలకు ప్రాణరక్షణ నీరు అందించండి.",
                "pa": "ਮੱਧ ਭਾਰਤ ਮੌਨਸੂਨ ਬੁਲੇਟਿਨ: ਪਹਿਲੇ ਅਤੇ ਦੂਜੇ ਹਫ਼ਤੇ ਦੌਰਾਨ ਮੌਨਸੂਨ ਕਮਜ਼ੋਰ ਰਹੇਗਾ। ਤੀਜੇ ਅਤੇ ਚੌਥੇ ਹਫ਼ਤੇ ਮੀਂਹ ਪੈਣ ਦੇ ਚੰਗੇ ਆਸਾਰ ਹਨ। ਨਮੀ ਬਚਾਉਣ ਲਈ ਮਲਚਿੰਗ ਅਤੇ ਸੰਜਮ ਨਾਲ ਸਿੰਚਾਈ ਕਰੋ।",
                "bn": "আইএমডি মধ্য ভারত বর্ধিত পূর্বাভাষ: প্রথম দুই সপ্তাহে বৃষ্টির ঘাটতি থাকবে (-৪২%)। তবে তৃতীয় সপ্তাহ থেকে মৌসুমী বায়ু পুনরায় সক্রিয় হবে। তুলা ও সয়াবিনে পরিপূরক সেচ প্রয়োগের পরামর্শ দেওয়া হচ্ছে।",
                "gu": "મધ્ય ભારત વિસ્તૃત આગાહી: પ્રથમ સપ્તાહમાં ચોમાસામાં મોટો વિરામ રહેશે (-42%). સપ્તાહ 3 અને 4માં ભારે વરસાદ સાથે ચોમાસું ફરી સક્રિય થશે. ખેડૂતોએ પાકમાં હળવી પિયત આપવી.",
                "kn": "ವಿದರ್ಭ ಹಾಗೂ ಮಧ್ಯ ಭಾರತ ವಿಸ್ತೃತ ಮುನ್ಸೂಚನೆ: ಮೊದಲ 2 ವಾರಗಳಲ್ಲಿ ಮಳೆ ಕೊರತೆ ಇರಲಿದ್ದು, 3ನೇ ವಾರದಿಂದ ಮುಂಗಾರು ಚುರುಕಾಗಲಿದೆ. ಕೃಷಿ ಹೊಂಡಗಳಿಂದ ಲಘು ನೀರಾವರಿ ಒದಗಿಸಿ.",
            },
        },
        "indo_gangetic_breadbasket": {
            "zone_id": "indo_gangetic_breadbasket",
            "zone_name": "North-Western Indo-Gangetic Breadbasket",
            "state": "Punjab",
            "sub_division_name": "Punjab, Haryana, Chandigarh & Delhi",
            "latitude": 30.9010,
            "longitude": 75.8573,
            "dominant_crops": [
                "Paddy (PR 126, Basmati)",
                "Bt Cotton",
                "Kharif Maize",
                "Wheat (Rabi)",
                "Mustard",
            ],
            "intra_seasonal_pulse": {
                "bsiso_mode": BsisoMode.BSISO_1_CANONICAL_30_60D,
                "bsiso_active_phase": 6,
                "bsiso_amplitude": 1.55,
                "northward_propagation_speed_deg_per_day": 1.30,
                "mjo_phase": MjoConvectivePhase.PHASE_6_WESTERN_PACIFIC,
                "mjo_amplitude": 1.35,
                "findlater_jet_speed_kt": 22.0,
                "monsoon_trough_position_latitude": 27.5,
                "break_spell_risk": False,
            },
            "four_week_forecast": [
                {
                    "week_number": 1,
                    "date_range_label": "Week 1: Days 1–7 (12–18 Sep)",
                    "rainfall_lpa_departure_pct": 12.0,
                    "rainfall_forecast_mm": 35.4,
                    "normal_lpa_rainfall_mm": 31.6,
                    "max_temp_anomaly_c": -0.5,
                    "min_temp_anomaly_c": 0.2,
                    "heatwave_coldwave_probability_pct": 0.0,
                    "monsoon_spell_state": MonsoonSpellState.NORMAL_MONSOON,
                },
                {
                    "week_number": 2,
                    "date_range_label": "Week 2: Days 8–14 (19–25 Sep)",
                    "rainfall_lpa_departure_pct": 4.0,
                    "rainfall_forecast_mm": 24.2,
                    "normal_lpa_rainfall_mm": 23.3,
                    "max_temp_anomaly_c": 0.3,
                    "min_temp_anomaly_c": 0.4,
                    "heatwave_coldwave_probability_pct": 5.0,
                    "monsoon_spell_state": MonsoonSpellState.NORMAL_MONSOON,
                },
                {
                    "week_number": 3,
                    "date_range_label": "Week 3: Days 15–21 (26 Sep – 02 Oct)",
                    "rainfall_lpa_departure_pct": -15.0,
                    "rainfall_forecast_mm": 12.5,
                    "normal_lpa_rainfall_mm": 14.7,
                    "max_temp_anomaly_c": 0.8,
                    "min_temp_anomaly_c": 0.6,
                    "heatwave_coldwave_probability_pct": 10.0,
                    "monsoon_spell_state": MonsoonSpellState.NORMAL_MONSOON,
                },
                {
                    "week_number": 4,
                    "date_range_label": "Week 4: Days 22–28 (03–09 Oct)",
                    "rainfall_lpa_departure_pct": -8.0,
                    "rainfall_forecast_mm": 8.0,
                    "normal_lpa_rainfall_mm": 8.7,
                    "max_temp_anomaly_c": 1.0,
                    "min_temp_anomaly_c": -0.5,
                    "heatwave_coldwave_probability_pct": 0.0,
                    "monsoon_spell_state": MonsoonSpellState.NORMAL_MONSOON,
                },
            ],
            "agricultural_contingency": {
                "stress_level": AgriculturalStressLevel.NONE_OPTIMAL,
                "sowing_window_status": "Optimal Grain Filling / Panicle Emergence Stage in Paddy",
                "contingency_crop_alternatives": [
                    "Canal & tube-well network adequate; avoid excessive ponding in Basmati",
                    "Begin field preparations for early Toria / Mustard (Pusa Bold) post paddy harvest",
                ],
                "irrigation_mitigation_directive": "Maintain 2-3 cm thin water layer in paddy during panicle initiation; withhold irrigation 10-14 days prior to harvest.",
                "in_situ_moisture_conservation": "Avoid residue burning; incorporate paddy straw using happy seeder or smart seeder to conserve residual soil moisture.",
                "standing_crop_intervention": "Scout for Whitefly and Pink Bollworm in Cotton; apply recommended neem-based sprays if threshold is breached.",
            },
            "vernacular_bulletins": {
                "en": "INDO-GANGETIC BREADBASKET ERP: Near-normal monsoon rainfall across Week 1 (+12%) and Week 2 (+4%). Favorable moisture conditions for grain filling in Paddy. Prepare seedbeds for early Rabi mustard post mid-September.",
                "hi": "सिंधु-गंगा मैदान विस्तारित पूर्वानुमान: पंजाब व हरियाणा में पहले दो हफ्तों में सामान्य बारिश (+12%, +4%) के आसार हैं। धान की बालियों के भराव हेतु मौसम अनुकूल है। रबी तोरिया/सरसों की बुवाई की तैयारी शुरू करें।",
                "pa": "ਪੰਜਾਬ ਤੇ ਹਰਿਆਣਾ ਮੌਨਸੂਨ ਬੁਲੇਟਿਨ: ਪਹਿਲੇ ਦੋ ਹਫ਼ਤਿਆਂ ਦੌਰਾਨ ਮਾਨਸੂਨ ਆਮ ਵਾਂਗ ਰਹੇਗਾ। ਝੋਨੇ ਵਿੱਚ ਲੋੜ ਅਨੁਸਾਰ ਪਾਣੀ ਖੜ੍ਹਾ ਰੱਖੋ। ਪਰਾਲੀ ਨੂੰ ਅੱਗ ਨਾ ਲਾਓ ਅਤੇ ਹੈਪੀ ਸੀਡਰ ਨਾਲ ਕਣਕ/ਸਰ੍ਹੋਂ ਦੀ ਬਿਜਾਈ ਦੀ ਤਿਆਰੀ ਕਰੋ।",
                "mr": "उत्तर-पश्चिम भारत: सामान्य पाऊस राहील. रब्बी पिकांच्या पूर्वतयारीस प्रारंभ करावा.",
                "te": "పంజాబ్-హర్యానా వర్షపాత సమాచారం: సాధారణ వర్షాలు నమోదు కానున్నాయి.",
                "bn": "পাঞ্জাব-হরিয়ানা সমভূমি: স্বাভাবিক বৃষ্টিপাত বজায় থাকবে।",
                "gu": "પંજાબ-હરિયાણા ક્ષેત્ર: સામાન્ય વરસાદ રહેશે.",
                "kn": "ಪಂಜಾಬ್-ಹರಿಯಾಣ ಬಯಲು ಸೀಮೆ: ಸಾಮಾನ್ಯ ಮಳೆ ಮುನ್ಸೂಚನೆ.",
            },
        },
        "eastern_gangetic_rice_basin": {
            "zone_id": "eastern_gangetic_rice_basin",
            "zone_name": "Eastern Gangetic Rice & Pulse Basin",
            "state": "Bihar",
            "sub_division_name": "Bihar & East Uttar Pradesh",
            "latitude": 25.5941,
            "longitude": 85.1376,
            "dominant_crops": [
                "Kharif Paddy (Swarna Sub-1, Sahbhagi Dhan)",
                "Maize",
                "Pigeonpea",
                "Lentil",
                "Winter Wheat",
            ],
            "intra_seasonal_pulse": {
                "bsiso_mode": BsisoMode.BSISO_1_CANONICAL_30_60D,
                "bsiso_active_phase": 7,
                "bsiso_amplitude": 1.70,
                "northward_propagation_speed_deg_per_day": 1.20,
                "mjo_phase": MjoConvectivePhase.PHASE_6_WESTERN_PACIFIC,
                "mjo_amplitude": 1.40,
                "findlater_jet_speed_kt": 26.0,
                "monsoon_trough_position_latitude": 28.0,  # Foothill convergence
                "break_spell_risk": True,
            },
            "four_week_forecast": [
                {
                    "week_number": 1,
                    "date_range_label": "Week 1: Days 1–7 (12–18 Sep)",
                    "rainfall_lpa_departure_pct": 65.0,
                    "rainfall_forecast_mm": 92.4,
                    "normal_lpa_rainfall_mm": 56.0,
                    "max_temp_anomaly_c": -1.8,
                    "min_temp_anomaly_c": 0.2,
                    "heatwave_coldwave_probability_pct": 0.0,
                    "monsoon_spell_state": MonsoonSpellState.ACTIVE_SURGE,
                },
                {
                    "week_number": 2,
                    "date_range_label": "Week 2: Days 8–14 (19–25 Sep)",
                    "rainfall_lpa_departure_pct": 35.0,
                    "rainfall_forecast_mm": 60.8,
                    "normal_lpa_rainfall_mm": 45.0,
                    "max_temp_anomaly_c": -1.0,
                    "min_temp_anomaly_c": 0.1,
                    "heatwave_coldwave_probability_pct": 0.0,
                    "monsoon_spell_state": MonsoonSpellState.ACTIVE_SURGE,
                },
                {
                    "week_number": 3,
                    "date_range_label": "Week 3: Days 15–21 (26 Sep – 02 Oct)",
                    "rainfall_lpa_departure_pct": -12.0,
                    "rainfall_forecast_mm": 31.0,
                    "normal_lpa_rainfall_mm": 35.2,
                    "max_temp_anomaly_c": 0.4,
                    "min_temp_anomaly_c": -0.2,
                    "heatwave_coldwave_probability_pct": 0.0,
                    "monsoon_spell_state": MonsoonSpellState.NORMAL_MONSOON,
                },
                {
                    "week_number": 4,
                    "date_range_label": "Week 4: Days 22–28 (03–09 Oct)",
                    "rainfall_lpa_departure_pct": 5.0,
                    "rainfall_forecast_mm": 24.5,
                    "normal_lpa_rainfall_mm": 23.3,
                    "max_temp_anomaly_c": 0.2,
                    "min_temp_anomaly_c": -0.4,
                    "heatwave_coldwave_probability_pct": 0.0,
                    "monsoon_spell_state": MonsoonSpellState.NORMAL_MONSOON,
                },
            ],
            "agricultural_contingency": {
                "stress_level": AgriculturalStressLevel.WATCH_SLIGHT_MOISTURE_STRESS,
                "sowing_window_status": "High Inundation & Flash Flood Risk Along Foothills Catchments",
                "contingency_crop_alternatives": [
                    "Utilize flood-tolerant rice varieties (Swarna Sub-1, BINA 11) in low-lying tal lands",
                    "Keep drainage gates unblocked to prevent prolonged submergence over 7 days",
                ],
                "irrigation_mitigation_directive": "Drain excess standing floodwater from maize and pulse fields into farm channels; waterlogging causes rapid hypoxia.",
                "in_situ_moisture_conservation": "Construct secondary field bunds to retain water in upland paddy fields once heavy spell recedes.",
                "standing_crop_intervention": "Top-dress with Urea (25-30 kg/ha) post flood-water recession to stimulate vigorous tillering.",
            },
            "vernacular_bulletins": {
                "en": "EASTERN GANGETIC BASIN ERP: Strong orographic and foothill convergence brings Large Excess rainfall in Week 1 (+65%) and Week 2 (+35%). Risk of waterlogging in North Bihar and Terai catchments. Ensure clear drainage.",
                "hi": "पूर्वी गंगा बेसिन विस्तारित पूर्वानुमान: बिहार एवं पूर्वी यूपी में सप्ताह 1 (+65%) और सप्ताह 2 (+35%) में भारी बारिश के आसार हैं। तराई एवं निचली भूमि में जलभराव की संभावना है। जल निकासी की व्यवस्था दुरुस्त रखें।",
                "bn": "পূর্ব গাঙ্গেয় অববাহিকা: আগামী দুই সপ্তাহে ভারী থেকে অতি ভারী বৃষ্টিপাতের সম্ভাবনা (+৬৫%)। নিচু জমির ধানক্ষেতের নিষ্কাশন পথ পরিষ্কার রাখুন।",
                "mr": "पूर्व गंगा खोरे: पहिल्या दोन आठवड्यात मुसळधार पाऊस. सखल भागात पाण्याचा निचरा करावा.",
                "te": "తూర్పు గంగా మైదాన వర్ష సమాచారం: మొదటి 2 వారాలలో భారీ వర్షాలు పడే అవకాశం ఉంది.",
                "pa": "ਪੂਰਬੀ ਗੰਗਾ ਬੇਸਿਨ: ਭਾਰੀ ਮੀਂਹ ਦੇ ਮੱਦੇਨਜ਼ਰ ਪਾਣੀ ਦੇ ਨਿਕਾਸ ਦਾ ਪ੍ਰਬੰਧ ਯਕੀਨੀ ਬਣਾਓ।",
                "gu": "પૂર્વ ગંગા તટપ્રદેશ: પ્રથમ બે સપ્તાહમાં ભારે વરસાદની સંભાવના છે.",
                "kn": "ಪೂರ್ವ ಗಂಗಾ ಜಲಾನಯನ ಪ್ರದೇಶ: ಮುಂದಿನ 2 ವಾರಗಳಲ್ಲಿ ಭಾರೀ ಮಳೆ ಸಂಭವ.",
            },
        },
        "southern_peninsular_millet": {
            "zone_id": "southern_peninsular_millet",
            "zone_name": "Southern Peninsular Semi-Arid Millet & Oilseed Belt",
            "state": "Telangana",
            "sub_division_name": "Telangana & Rayalaseema",
            "latitude": 17.3850,
            "longitude": 78.4867,
            "dominant_crops": [
                "Cotton",
                "Redgram (Pigeonpea)",
                "Kharif Maize",
                "Groundnut",
                "Pearl Millet (Bajra)",
            ],
            "intra_seasonal_pulse": {
                "bsiso_mode": BsisoMode.BSISO_2_QUASI_BIWEEKLY_10_20D,
                "bsiso_active_phase": 3,
                "bsiso_amplitude": 1.40,
                "northward_propagation_speed_deg_per_day": 1.45,
                "mjo_phase": MjoConvectivePhase.PHASE_3_INDIAN_OCEAN_ACTIVE,
                "mjo_amplitude": 1.25,
                "findlater_jet_speed_kt": 28.0,
                "monsoon_trough_position_latitude": 22.0,
                "break_spell_risk": False,
            },
            "four_week_forecast": [
                {
                    "week_number": 1,
                    "date_range_label": "Week 1: Days 1–7 (12–18 Sep)",
                    "rainfall_lpa_departure_pct": -38.0,
                    "rainfall_forecast_mm": 22.4,
                    "normal_lpa_rainfall_mm": 36.1,
                    "max_temp_anomaly_c": 1.4,
                    "min_temp_anomaly_c": 0.8,
                    "heatwave_coldwave_probability_pct": 10.0,
                    "monsoon_spell_state": MonsoonSpellState.WEAK_MONSOON,
                },
                {
                    "week_number": 2,
                    "date_range_label": "Week 2: Days 8–14 (19–25 Sep)",
                    "rainfall_lpa_departure_pct": -18.0,
                    "rainfall_forecast_mm": 27.5,
                    "normal_lpa_rainfall_mm": 33.5,
                    "max_temp_anomaly_c": 0.6,
                    "min_temp_anomaly_c": 0.3,
                    "heatwave_coldwave_probability_pct": 0.0,
                    "monsoon_spell_state": MonsoonSpellState.NORMAL_MONSOON,
                },
                {
                    "week_number": 3,
                    "date_range_label": "Week 3: Days 15–21 (26 Sep – 02 Oct)",
                    "rainfall_lpa_departure_pct": 22.0,
                    "rainfall_forecast_mm": 42.0,
                    "normal_lpa_rainfall_mm": 34.4,
                    "max_temp_anomaly_c": -0.8,
                    "min_temp_anomaly_c": 0.0,
                    "heatwave_coldwave_probability_pct": 0.0,
                    "monsoon_spell_state": MonsoonSpellState.ACTIVE_SURGE,
                },
                {
                    "week_number": 4,
                    "date_range_label": "Week 4: Days 22–28 (03–09 Oct)",
                    "rainfall_lpa_departure_pct": 16.0,
                    "rainfall_forecast_mm": 38.2,
                    "normal_lpa_rainfall_mm": 32.9,
                    "max_temp_anomaly_c": -0.5,
                    "min_temp_anomaly_c": -0.1,
                    "heatwave_coldwave_probability_pct": 0.0,
                    "monsoon_spell_state": MonsoonSpellState.NORMAL_MONSOON,
                },
            ],
            "agricultural_contingency": {
                "stress_level": AgriculturalStressLevel.WATCH_SLIGHT_MOISTURE_STRESS,
                "sowing_window_status": "Vegetative to Flowering Transition in Redgram & Cotton",
                "contingency_crop_alternatives": [
                    "Redgram (ICPL 87119) exhibits moderate drought tolerance; maintain crop stand",
                    "For late sowings, choose Castor (DCH 519) or Horsegram (CRHG 19)",
                ],
                "irrigation_mitigation_directive": "Deploy micro-irrigation or furrow-alternate watering from community check dams during Week 1 dry spell.",
                "in_situ_moisture_conservation": "Form conservation furrows at 3.6m intervals across the slope to arrest surface runoff.",
                "standing_crop_intervention": "Spray 2% DAP or 1% Potassium Chloride (KCl) to enhance osmotic adjustment against mild moisture deficit.",
            },
            "vernacular_bulletins": {
                "en": "SOUTHERN PENINSULAR ERP: Moderate dry spell in Week 1 (-38%) transitioning to active monsoon showers by Week 3 (+22%) and Week 4 (+16%). BSISO-2 quasi-biweekly pulse active. Provide life-saving irrigation to Cotton and Redgram.",
                "te": "దక్షిణ ద్వీపకల్ప వర్ష సూచన: 1వ వారంలో వర్షాలు తగ్గుముఖం పడతాయి (-38%). అయితే 3 మరియు 4వ వారాల్లో విస్తారంగా వర్షాలు కురుస్తాయి (+22%). పత్తి మరియు కంది పంటలకు రక్షక తడులు అందించండి.",
                "hi": "दक्षिण प्रायद्वीपीय विस्तारित पूर्वानुमान: सप्ताह 1 में बारिश कम (-38%) रहेगी, परंतु सप्ताह 3 व 4 में मानसूनी फुहारें पुनः सक्रिय होंगी (+22%)। कपास व अरहर में सूक्ष्म सिंचाई करें।",
                "mr": "दक्षिण द्विपकल्प: आठवडा ३ पासून पाऊस पुन्हा सक्रिय होईल. पिकांना संरक्षित पाणी द्यावे.",
                "kn": "ದಕ್ಷಿಣ ಪ್ರಸ್ಥಭೂಮಿ: ವಾರ 1ರಲ್ಲಿ ಮಳೆ ಕೊರತೆ, ಆದರೆ ವಾರ 3ರಿಂದ ಉತ್ತಮ ಮಳೆ ನಿರೀಕ್ಷೆ. ಹತ್ತಿ ಮತ್ತು ತೊಗರಿಗೆ ಲಘು ನೀರಾವರಿ ಒದಗಿಸಿ.",
                "bn": "দক্ষিণ উপদ্বীপ: তৃতীয় সপ্তাহ থেকে বৃষ্টির তীব্রতা বৃদ্ধি পাবে।",
                "pa": "ਦੱਖਣੀ ਪ੍ਰਾਇਦੀਪ: ਤੀਜੇ ਹਫ਼ਤੇ ਤੋਂ ਮੀਂਹ ਮੁੜ ਸ਼ੁਰੂ ਹੋਣ ਦੀ ਸੰਭਾਵਨਾ।",
                "gu": "દક્ષિણ દ્વીપકલ્પ: સપ્તાહ 3થી વરસાદમાં વધારો થશે.",
            },
        },
        "konkan_malabar_coastal": {
            "zone_id": "konkan_malabar_coastal",
            "zone_name": "Western Coastal Ghats & Konkan-Malabar Maritime Zone",
            "state": "Goa",
            "sub_division_name": "Konkan & Goa, Coastal Karnataka",
            "latitude": 15.2993,
            "longitude": 74.1240,
            "dominant_crops": [
                "Coastal Kharif Paddy",
                "Coconut",
                "Arecanut",
                "Cashew",
                "Black Pepper & Spices",
            ],
            "intra_seasonal_pulse": {
                "bsiso_mode": BsisoMode.BSISO_1_CANONICAL_30_60D,
                "bsiso_active_phase": 4,
                "bsiso_amplitude": 1.60,
                "northward_propagation_speed_deg_per_day": 1.35,
                "mjo_phase": MjoConvectivePhase.PHASE_3_INDIAN_OCEAN_ACTIVE,
                "mjo_amplitude": 1.50,
                "findlater_jet_speed_kt": 34.0,  # Strong coastal low level jet
                "monsoon_trough_position_latitude": 21.0,
                "break_spell_risk": False,
            },
            "four_week_forecast": [
                {
                    "week_number": 1,
                    "date_range_label": "Week 1: Days 1–7 (12–18 Sep)",
                    "rainfall_lpa_departure_pct": 24.0,
                    "rainfall_forecast_mm": 115.0,
                    "normal_lpa_rainfall_mm": 92.7,
                    "max_temp_anomaly_c": -1.2,
                    "min_temp_anomaly_c": 0.1,
                    "heatwave_coldwave_probability_pct": 0.0,
                    "monsoon_spell_state": MonsoonSpellState.ACTIVE_SURGE,
                },
                {
                    "week_number": 2,
                    "date_range_label": "Week 2: Days 8–14 (19–25 Sep)",
                    "rainfall_lpa_departure_pct": 18.0,
                    "rainfall_forecast_mm": 88.5,
                    "normal_lpa_rainfall_mm": 75.0,
                    "max_temp_anomaly_c": -0.6,
                    "min_temp_anomaly_c": 0.0,
                    "heatwave_coldwave_probability_pct": 0.0,
                    "monsoon_spell_state": MonsoonSpellState.NORMAL_MONSOON,
                },
                {
                    "week_number": 3,
                    "date_range_label": "Week 3: Days 15–21 (26 Sep – 02 Oct)",
                    "rainfall_lpa_departure_pct": 10.0,
                    "rainfall_forecast_mm": 62.0,
                    "normal_lpa_rainfall_mm": 56.4,
                    "max_temp_anomaly_c": 0.2,
                    "min_temp_anomaly_c": -0.1,
                    "heatwave_coldwave_probability_pct": 0.0,
                    "monsoon_spell_state": MonsoonSpellState.NORMAL_MONSOON,
                },
                {
                    "week_number": 4,
                    "date_range_label": "Week 4: Days 22–28 (03–09 Oct)",
                    "rainfall_lpa_departure_pct": -5.0,
                    "rainfall_forecast_mm": 42.0,
                    "normal_lpa_rainfall_mm": 44.2,
                    "max_temp_anomaly_c": 0.5,
                    "min_temp_anomaly_c": 0.1,
                    "heatwave_coldwave_probability_pct": 0.0,
                    "monsoon_spell_state": MonsoonSpellState.NORMAL_MONSOON,
                },
            ],
            "agricultural_contingency": {
                "stress_level": AgriculturalStressLevel.NONE_OPTIMAL,
                "sowing_window_status": "Vigorous Offshore Trough Precipitation across Ghats",
                "contingency_crop_alternatives": [
                    "Ensure adequate drainage channels in Arecanut and Black Pepper orchards to avert phytophthora rot",
                    "Maintain salt-tolerant paddy varieties (Kagga, Pokkali) in coastal estuarine fields",
                ],
                "irrigation_mitigation_directive": "Soil moisture is in excess; ensure drainage ditches are cleared of debris to avoid root suffocation.",
                "in_situ_moisture_conservation": "Terrace bunding across sloping lateritic terrains to control soil erosion during heavy orographic downpours.",
                "standing_crop_intervention": "Apply 1% Bordeaux mixture on Arecanut bunches and pepper vines as prophylactic defense against Mahali / fruit rot.",
            },
            "vernacular_bulletins": {
                "en": "KONKAN-MALABAR ERP: Active offshore trough maintains Excess to Normal rainfall across Week 1 (+24%) and Week 2 (+18%). Ghat catchments will receive steady replenishment. Apply prophylactic anti-fungal sprays on plantation crops.",
                "mr": "कोकण व गोवा विस्तारित अंदाज: आठवडा १ (+२४%) आणि आठवडा २ मध्ये चांगला पाऊस राहील. सुपारी व काळी मिरी बागांमध्ये पाण्याचा निचरा ठेवावा आणि बोर्डो मिश्रणाची फवारणी करावी.",
                "hi": "कोंकण-गोवा विस्तारित पूर्वानुमान: पहले दो हफ्तों में तटीय ट्रफ के प्रभाव से सामान्य से अधिक वर्षा (+24%, +18%) होगी। बागवानी फसलों में जलभराव न होने दें।",
                "kn": "ಕರಾವಳಿ ಕರ್ನಾಟಕ: ಮುಂದಿನ 2 ವಾರಗಳಲ್ಲಿ ಉತ್ತಮ ಮಳೆ ಮುಂದುವರಿಯಲಿದೆ. ಅಡಿಕೆ ತೋಟಗಳಲ್ಲಿ ನೀರು ನಿಲ್ಲದಂತೆ ಎಚ್ಚರವಹಿಸಿ.",
                "te": "కొంకణ్-గోవా వర్ష సమాచారం: మొదటి రెండు వారాల్లో సాధారణం కంటే ఎక్కువ వర్షాలు ఉంటాయి.",
                "bn": "কোঙ্কন-গোয়া উপকূল: আগামী দুই সপ্তাহে ভালো বৃষ্টিপাত অব্যাহত থাকবে।",
                "pa": "ਕੋਂਕਣ ਤੇ ਮਾਲਾਬਾਰ: ਪਹਿਲੇ ਦੋ ਹਫ਼ਤਿਆਂ ਵਿੱਚ ਵਧੀਆ ਮੀਂਹ ਪਵੇਗਾ।",
                "gu": "કોંકણ-ગોવા ક્ષેત્ર: આગામી બે સપ્તાહમાં સારો વરસાદ રહેશે.",
            },
        },
        "northeastern_brahmaputra_fluvial": {
            "zone_id": "northeastern_brahmaputra_fluvial",
            "zone_name": "Northeastern Brahmaputra Humid Fluvial Zone",
            "state": "Assam",
            "sub_division_name": "Assam & Meghalaya",
            "latitude": 26.1445,
            "longitude": 91.7362,
            "dominant_crops": [
                "Sali Kharif Paddy",
                "Tea Plantations",
                "Jute",
                "Rapeseed & Mustard (Rabi)",
                "Boro Rice",
            ],
            "intra_seasonal_pulse": {
                "bsiso_mode": BsisoMode.BSISO_1_CANONICAL_30_60D,
                "bsiso_active_phase": 7,  # Inverse regime: active rain in NE while break in central India
                "bsiso_amplitude": 1.70,
                "northward_propagation_speed_deg_per_day": 1.20,
                "mjo_phase": MjoConvectivePhase.PHASE_6_WESTERN_PACIFIC,
                "mjo_amplitude": 1.40,
                "findlater_jet_speed_kt": 24.0,
                "monsoon_trough_position_latitude": 28.5,
                "break_spell_risk": True,
            },
            "four_week_forecast": [
                {
                    "week_number": 1,
                    "date_range_label": "Week 1: Days 1–7 (12–18 Sep)",
                    "rainfall_lpa_departure_pct": 72.0,
                    "rainfall_forecast_mm": 138.0,
                    "normal_lpa_rainfall_mm": 80.2,
                    "max_temp_anomaly_c": -2.1,
                    "min_temp_anomaly_c": 0.2,
                    "heatwave_coldwave_probability_pct": 0.0,
                    "monsoon_spell_state": MonsoonSpellState.ACTIVE_SURGE,
                },
                {
                    "week_number": 2,
                    "date_range_label": "Week 2: Days 8–14 (19–25 Sep)",
                    "rainfall_lpa_departure_pct": 48.0,
                    "rainfall_forecast_mm": 96.2,
                    "normal_lpa_rainfall_mm": 65.0,
                    "max_temp_anomaly_c": -1.4,
                    "min_temp_anomaly_c": 0.1,
                    "heatwave_coldwave_probability_pct": 0.0,
                    "monsoon_spell_state": MonsoonSpellState.ACTIVE_SURGE,
                },
                {
                    "week_number": 3,
                    "date_range_label": "Week 3: Days 15–21 (26 Sep – 02 Oct)",
                    "rainfall_lpa_departure_pct": 15.0,
                    "rainfall_forecast_mm": 54.0,
                    "normal_lpa_rainfall_mm": 47.0,
                    "max_temp_anomaly_c": 0.2,
                    "min_temp_anomaly_c": -0.2,
                    "heatwave_coldwave_probability_pct": 0.0,
                    "monsoon_spell_state": MonsoonSpellState.NORMAL_MONSOON,
                },
                {
                    "week_number": 4,
                    "date_range_label": "Week 4: Days 22–28 (03–09 Oct)",
                    "rainfall_lpa_departure_pct": -10.0,
                    "rainfall_forecast_mm": 32.5,
                    "normal_lpa_rainfall_mm": 36.1,
                    "max_temp_anomaly_c": 0.6,
                    "min_temp_anomaly_c": -0.3,
                    "heatwave_coldwave_probability_pct": 0.0,
                    "monsoon_spell_state": MonsoonSpellState.NORMAL_MONSOON,
                },
            ],
            "agricultural_contingency": {
                "stress_level": AgriculturalStressLevel.WATCH_SLIGHT_MOISTURE_STRESS,
                "sowing_window_status": "Severe Fluvial Inundation & Flash Flood Threat Along Brahmaputra Catchments",
                "contingency_crop_alternatives": [
                    "For flood-damaged Sali paddy, prepare community wet-nurseries for staggered transplanting with Manohar Sali or Andrew Sali",
                    "Keep submerged tea bushes drained; stagnant water causes tea mosquito bug flare-up",
                ],
                "irrigation_mitigation_directive": "Drain excess water immediately from low-lying fields into river sluices to prevent seedling decay.",
                "in_situ_moisture_conservation": "Strengthen bamboo-soil embankment bunds along tributary perimeters.",
                "standing_crop_intervention": "Top-dress with Potash (MOP) to enhance stalk stiffness and flood recovery in submerged paddy hills.",
            },
            "vernacular_bulletins": {
                "en": "NORTHEASTERN BRAHMAPUTRA ERP: Inverse monsoon regime active. High-intensity rainfall in Week 1 (+72%) and Week 2 (+48%) across Assam & Meghalaya due to foothill trough alignment. Flood alert along river islands and lowlands.",
                "bn": "উত্তর-পূর্ব ব্রহ্মপুত্র অববাহিকা: আসাম ও মেঘালয়ে আগামী দুই সপ্তাহে অত্যন্ত ভারী বৃষ্টিপাত (+৭২%, +৪৮%) হবে। নদী অববাহিকায় বন্যা ও জলাবদ্ধতার উচ্চ সতর্কতা রয়েছে।",
                "hi": "पूर्वोत्तर ब्रह्मपुत्र बेसिन: असम व मेघालय में हिमालयी तलहटी ट्रफ के कारण सप्ताह 1 (+72%) और सप्ताह 2 (+48%) में भारी वर्षा और बाढ़ का खतरा है। सुरक्षित स्थानों पर रहें।",
                "mr": "ईशान्य भारत: मुसळधार पावसामुळे पूरस्थिती निर्माण होण्याची शक्यता आहे.",
                "te": "ఈశాన్య భారతం: అస్సాం మరియు మేఘాలయలో భారీ వర్షాలు పడనున్నాయి. వరద ముప్పు పొంచి ఉంది.",
                "pa": "ਉੱਤਰ-ਪੂਰਬੀ ਭਾਰਤ: ਭਾਰੀ ਮੀਂਹ ਕਾਰਨ ਹੜ੍ਹਾਂ ਦਾ ਖ਼ਤਰਾ। ਸੁਚੇਤ ਰਹੋ।",
                "gu": "ઉત્તર-પૂર્વ ભારત: ભારે વરસાદને કારણે પૂરની સ્થિતિ સર્જાઈ શકે છે.",
                "kn": "ಈಶಾನ್ಯ ಭಾರತ: ಅಸ್ಸಾಂ-ಮೇಘಾಲಯದಲ್ಲಿ ಭಾರೀ ಮಳೆ ಹಾಗೂ ಪ್ರವಾಹ ಎಚ್ಚರಿಕೆ.",
            },
        },
        "western_arid_coarse_grain": {
            "zone_id": "western_arid_coarse_grain",
            "zone_name": "Western Arid & Semi-Arid Coarse Grain Zone",
            "state": "Rajasthan",
            "sub_division_name": "West Rajasthan & Saurashtra",
            "latitude": 26.2389,
            "longitude": 73.0243,
            "dominant_crops": [
                "Pearl Millet (Bajra - HHB 67)",
                "Guar (Clusterbean)",
                "Moth Bean (RMO 40)",
                "Cumin (Jeera)",
                "Castor",
            ],
            "intra_seasonal_pulse": {
                "bsiso_mode": BsisoMode.BSISO_1_CANONICAL_30_60D,
                "bsiso_active_phase": 7,
                "bsiso_amplitude": 1.75,
                "northward_propagation_speed_deg_per_day": 1.25,
                "mjo_phase": MjoConvectivePhase.PHASE_6_WESTERN_PACIFIC,
                "mjo_amplitude": 1.45,
                "findlater_jet_speed_kt": 16.0,
                "monsoon_trough_position_latitude": 28.5,
                "break_spell_risk": True,
            },
            "four_week_forecast": [
                {
                    "week_number": 1,
                    "date_range_label": "Week 1: Days 1–7 (12–18 Sep)",
                    "rainfall_lpa_departure_pct": -55.0,
                    "rainfall_forecast_mm": 6.8,
                    "normal_lpa_rainfall_mm": 15.1,
                    "max_temp_anomaly_c": 2.2,
                    "min_temp_anomaly_c": 1.4,
                    "heatwave_coldwave_probability_pct": 35.0,
                    "monsoon_spell_state": MonsoonSpellState.BREAK_MONSOON_CRITICAL,
                },
                {
                    "week_number": 2,
                    "date_range_label": "Week 2: Days 8–14 (19–25 Sep)",
                    "rainfall_lpa_departure_pct": -35.0,
                    "rainfall_forecast_mm": 7.5,
                    "normal_lpa_rainfall_mm": 11.5,
                    "max_temp_anomaly_c": 1.5,
                    "min_temp_anomaly_c": 0.8,
                    "heatwave_coldwave_probability_pct": 20.0,
                    "monsoon_spell_state": MonsoonSpellState.WEAK_MONSOON,
                },
                {
                    "week_number": 3,
                    "date_range_label": "Week 3: Days 15–21 (26 Sep – 02 Oct)",
                    "rainfall_lpa_departure_pct": -12.0,
                    "rainfall_forecast_mm": 6.2,
                    "normal_lpa_rainfall_mm": 7.0,
                    "max_temp_anomaly_c": 0.6,
                    "min_temp_anomaly_c": 0.2,
                    "heatwave_coldwave_probability_pct": 5.0,
                    "monsoon_spell_state": MonsoonSpellState.NORMAL_MONSOON,
                },
                {
                    "week_number": 4,
                    "date_range_label": "Week 4: Days 22–28 (03–09 Oct)",
                    "rainfall_lpa_departure_pct": 18.0,
                    "rainfall_forecast_mm": 4.5,
                    "normal_lpa_rainfall_mm": 3.8,
                    "max_temp_anomaly_c": -0.4,
                    "min_temp_anomaly_c": -0.6,
                    "heatwave_coldwave_probability_pct": 0.0,
                    "monsoon_spell_state": MonsoonSpellState.NORMAL_MONSOON,
                },
            ],
            "agricultural_contingency": {
                "stress_level": AgriculturalStressLevel.WARNING_PROLONGED_DRY_SPELL,
                "sowing_window_status": "Severe Aridity Deficit; Reproductive Stage in Rainfed Bajra & Moth",
                "contingency_crop_alternatives": [
                    "If Bajra fails to fill grain, harvest for dry stover / livestock fodder (Karbi)",
                    "Protect early maturing Moth Bean (RMO 40, RMO 257) with straw mulch",
                ],
                "irrigation_mitigation_directive": "Prioritize life-saving drip/dikas sprinkler irrigation from farm diggis or tubewells during night hours.",
                "in_situ_moisture_conservation": "Spread local weed/crop residue mulch at 3-4 t/ha in Guar and Castor rows to retain sparse root-zone moisture.",
                "standing_crop_intervention": "Foliar spray of 0.1% Thiourea (1000 ppm) or 1% KCl at grain development to improve heat and desiccation resistance.",
            },
            "vernacular_bulletins": {
                "en": "WESTERN ARID ZONE ERP: Severe dry conditions in Week 1 (-55%) with elevated max temperatures (+2.2°C). High soil moisture deficit across West Rajasthan and Saurashtra. Protect Bajra with mulching and spray 0.1% Thiourea.",
                "hi": "पश्चिमी शुष्क क्षेत्र विस्तारित पूर्वानुमान: पश्चिमी राजस्थान में पहले दो हफ्तों में भीषण सूखा (-55%, -35%) और तापमान 2.2°C अधिक रहेगा। बाजरा और ग्वार में नमी संरक्षण हेतु पलवार (मल्चिंग) करें एवं 0.1% थायोयूरिया का छिड़काव करें।",
                "gu": "પશ્ચિમ શુષ્ક ક્ષેત્ર (સૌરાષ્ટ્ર): સપ્તાહ 1માં તીવ્ર વરસાદની ઘટ (-55%) રહેશે. બાજરી અને ગવારના પાકને પિયત આપો અને જમીનમાં ભેજ જાળવી રાખવા માટે મલ્ચિંગ કરો.",
                "mr": "पश्चिम शुष्क विभाग: तीव्र दुष्काळी परिस्थिती. पिकांना वाचवण्यासाठी आच्छादनाचा वापर करावा.",
                "te": "పశ్చిమ శుష్క ప్రాంతం: తీవ్ర వర్షపు కొరత ఉంటుంది. పశుగ్రాసం మరియు తేమ రక్షణపై దృష్టి పెట్టండి.",
                "pa": "ਪੱਛਮੀ ਸੁੱਕਾ ਖੇਤਰ: ਮੀਂહ ਦੀ ਭਾਰੀ ਘਾਟ। ਨਮੀ ਬਚਾਉਣ ਲਈ ਪਰਾਲੀ ਦੀ ਵਰਤੋਂ ਕਰੋ।",
                "bn": "পশ্চিম শুষ্ক অঞ্চল: চরম শুষ্ক আবহাওয়া। ফসলের গোড়ায় মালচিং করুন।",
                "kn": "ಪಶ್ಚಿಮ ಶುಷ್ಕ ವಲಯ: ತೀವ್ರ ಮಳೆ ಕೊರತೆ. ಬೆಳೆ ಉಳಿಸಲು ಹೊದಿಕೆ ಬಳಸಿ.",
            },
        },
    }

    DEFAULT_ZONE_ID = "vidarbha_central_rainfed"

    @classmethod
    def get_extended_range_assessment(
        cls,
        zone_id: Optional[str] = None,
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        language: str = "en",
    ) -> ErpResponse:
        # Determine target zone
        selected_zone_data: Optional[Dict] = None

        if zone_id and zone_id in cls.ZONES:
            selected_zone_data = cls.ZONES[zone_id]
        elif latitude is not None and longitude is not None:
            # Geodetic nearest-neighbor match
            closest_id = cls.DEFAULT_ZONE_ID
            min_dist = float("inf")
            for zid, zdata in cls.ZONES.items():
                dist = _haversine_distance(
                    latitude, longitude, zdata["latitude"], zdata["longitude"]
                )
                if dist < min_dist:
                    min_dist = dist
                    closest_id = zid
            selected_zone_data = cls.ZONES[closest_id]
        else:
            selected_zone_data = cls.ZONES[cls.DEFAULT_ZONE_ID]

        # Build 4-week forecast with typed departure tiers
        forecast_list: List[WeeklyErpForecast] = []
        for wf in selected_zone_data["four_week_forecast"]:
            tier = _get_departure_tier(wf["rainfall_lpa_departure_pct"])
            forecast_list.append(
                WeeklyErpForecast(
                    week_number=wf["week_number"],
                    date_range_label=wf["date_range_label"],
                    rainfall_lpa_departure_pct=wf["rainfall_lpa_departure_pct"],
                    departure_tier=tier,
                    rainfall_forecast_mm=wf["rainfall_forecast_mm"],
                    normal_lpa_rainfall_mm=wf["normal_lpa_rainfall_mm"],
                    max_temp_anomaly_c=wf["max_temp_anomaly_c"],
                    min_temp_anomaly_c=wf["min_temp_anomaly_c"],
                    heatwave_coldwave_probability_pct=wf["heatwave_coldwave_probability_pct"],
                    monsoon_spell_state=wf["monsoon_spell_state"],
                )
            )

        # Build typed intra-seasonal pulse telemetry
        pulse_data = selected_zone_data["intra_seasonal_pulse"]
        pulse = IntraSeasonalPulseTelemetry(
            bsiso_mode=pulse_data["bsiso_mode"],
            bsiso_active_phase=pulse_data["bsiso_active_phase"],
            bsiso_amplitude=pulse_data["bsiso_amplitude"],
            northward_propagation_speed_deg_per_day=pulse_data["northward_propagation_speed_deg_per_day"],
            mjo_phase=pulse_data["mjo_phase"],
            mjo_amplitude=pulse_data["mjo_amplitude"],
            findlater_jet_speed_kt=pulse_data["findlater_jet_speed_kt"],
            monsoon_trough_position_latitude=pulse_data["monsoon_trough_position_latitude"],
            break_spell_risk=pulse_data["break_spell_risk"],
        )

        # Build typed ICAR-CRIDA contingency advice
        contingency_data = selected_zone_data["agricultural_contingency"]
        contingency = IcarDistrictContingency(
            stress_level=contingency_data["stress_level"],
            sowing_window_status=contingency_data["sowing_window_status"],
            contingency_crop_alternatives=contingency_data["contingency_crop_alternatives"],
            irrigation_mitigation_directive=contingency_data["irrigation_mitigation_directive"],
            in_situ_moisture_conservation=contingency_data["in_situ_moisture_conservation"],
            standing_crop_intervention=contingency_data["standing_crop_intervention"],
        )

        # Assemble current ErpZone
        current_zone = ErpZone(
            zone_id=selected_zone_data["zone_id"],
            zone_name=selected_zone_data["zone_name"],
            state=selected_zone_data["state"],
            sub_division_name=selected_zone_data["sub_division_name"],
            latitude=selected_zone_data["latitude"],
            longitude=selected_zone_data["longitude"],
            dominant_crops=selected_zone_data["dominant_crops"],
            four_week_forecast=forecast_list,
            intra_seasonal_pulse=pulse,
            agricultural_contingency=contingency,
            vernacular_bulletins=selected_zone_data["vernacular_bulletins"],
        )

        # Assemble summary list of all 7 zones
        all_zones_summary: List[ErpZoneSummary] = []
        for zid, zd in cls.ZONES.items():
            w1 = zd["four_week_forecast"][0]
            w2 = zd["four_week_forecast"][1]
            stress = zd["agricultural_contingency"]["stress_level"]
            is_alert = stress in [
                AgriculturalStressLevel.WARNING_PROLONGED_DRY_SPELL,
                AgriculturalStressLevel.ALERT_CRITICAL_CONTINGENCY,
            ]
            all_zones_summary.append(
                ErpZoneSummary(
                    zone_id=zd["zone_id"],
                    zone_name=zd["zone_name"],
                    state=zd["state"],
                    sub_division_name=zd["sub_division_name"],
                    current_monsoon_spell=w1["monsoon_spell_state"],
                    week1_departure_pct=w1["rainfall_lpa_departure_pct"],
                    week2_departure_pct=w2["rainfall_lpa_departure_pct"],
                    contingency_alert_active=is_alert,
                )
            )

        now_utc = datetime.now(timezone.utc).isoformat()

        return ErpResponse(
            zone_id=current_zone.zone_id,
            zone_name=current_zone.zone_name,
            state=current_zone.state,
            current_zone=current_zone,
            all_zones=all_zones_summary,
            mme_model_consensus_pct=85.5,
            last_updated_utc=now_utc,
            data_source="IMD-NCMRWF-IITM Extended Range Multi-Model Ensemble (CFSv2 / NCUM-ER) & ICAR-CRIDA",
        )
