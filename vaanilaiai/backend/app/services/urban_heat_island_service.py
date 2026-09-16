import math
from datetime import datetime, timezone
from typing import Dict, List, Optional

from app.schemas.urban_heat_island import (
    UhiSeverityLevel,
    CanopyUrbanMorphology,
    CoolRoofMaterialType,
    SurfaceThermalTelemetry,
    BiophysicalCanopyMetrics,
    CoolRoofSimulation,
    MicroclimateHotspot,
    MunicipalUhiDirectives,
    UrbanHeatIslandCorridor,
    CorridorSummary,
    UrbanHeatIslandResponse,
)


def _haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculate the great-circle distance between two points in km."""
    r = 6371.0  # Earth radius in kilometers
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (
        math.sin(dlat / 2) ** 2
        + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2) ** 2
    )
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return r * c


class UrbanHeatIslandService:
    """IMD & NDMA Urban Heat Island (UHI), Cool Roof Albedo & Surface Thermal Anomaly Engine."""

    # Pre-calibrated database of 7 high-vulnerability Indian Megacities
    _CORRIDORS: Dict[str, Dict] = {
        "delhi_ncr": {
            "city_name": "Delhi-NCR",
            "state": "Delhi-NCR",
            "latitude": 28.6304,
            "longitude": 77.2177,
            "climate_zone": "Composite Semi-Arid",
            "dominant_morphology": CanopyUrbanMorphology.HIGH_DENSITY_CONCRETE_CORE,
            "lst_urban": 48.5,
            "lst_rural": 41.7,
            "canopy_air_temp": 43.2,
            "tropical_night_min_temp": 29.8,
            "isf_pct": 88.5,
            "ndvi_urban": 0.11,
            "ndvi_rural": 0.46,
            "svf": 0.38,
            "anthropogenic_qf": 96.0,
            "hotspots": [
                {
                    "hotspot_id": "dl_anand_vihar",
                    "hotspot_name": "Anand Vihar ISBT & Railway Hub",
                    "morphology": CanopyUrbanMorphology.INDUSTRIAL_ASPHALT_ZONE,
                    "lst_celsius": 49.8,
                    "thermal_anomaly_delta_c": 8.1,
                    "vulnerability_rank": "VERY_HIGH",
                    "cooling_shelter_distance_m": 350,
                },
                {
                    "hotspot_id": "dl_chandni_chowk",
                    "hotspot_name": "Chandni Chowk Old Walled City",
                    "morphology": CanopyUrbanMorphology.HIGH_DENSITY_CONCRETE_CORE,
                    "lst_celsius": 48.9,
                    "thermal_anomaly_delta_c": 7.2,
                    "vulnerability_rank": "VERY_HIGH",
                    "cooling_shelter_distance_m": 200,
                },
                {
                    "hotspot_id": "dl_okhla_ind",
                    "hotspot_name": "Okhla Industrial Phase-III",
                    "morphology": CanopyUrbanMorphology.INDUSTRIAL_ASPHALT_ZONE,
                    "lst_celsius": 50.2,
                    "thermal_anomaly_delta_c": 8.5,
                    "vulnerability_rank": "VERY_HIGH",
                    "cooling_shelter_distance_m": 600,
                },
                {
                    "hotspot_id": "dl_connaught_place",
                    "hotspot_name": "Connaught Place Inner Radial",
                    "morphology": CanopyUrbanMorphology.COMMERCIAL_GLASS_CANYON,
                    "lst_celsius": 48.1,
                    "thermal_anomaly_delta_c": 6.4,
                    "vulnerability_rank": "HIGH",
                    "cooling_shelter_distance_m": 150,
                },
            ],
            "directives": {
                "cool_roof_policy_status": "ACTIVE_MANDATORY_COMMERCIAL",
                "cool_roof_target_sq_meters": 1200000,
                "urban_forestry_corridor_km": 45.0,
                "transit_misting_stations_count": 65,
                "construction_heat_shift_enforced": True,
                "public_pyaus_drinking_water_points": 820,
                "emergency_cooling_shelters_active": 140,
            },
            "bulletins": {
                "en": "DELHI-NCR UHI ADVISORY: Land surface temperature reached 48.5°C with a critical +6.8°C thermal anomaly. Nocturnal minimum stayed at 29.8°C, triggering a Severe Tropical Night with continuous physiological heat stress. High-albedo cool roofs (SRI>=78) provide up to 3.5°C indoor cooling relief. Strenuous outdoor labor is strictly prohibited from 12:00 to 16:00.",
                "hi": "दिल्ली-एनसीआर शहरी ताप द्वीप (UHI) चेतावनी: भूमि की सतह का तापमान 48.5°C तक पहुंच गया है (+6.8°C ताप विसंगति)। रात का न्यूनतम तापमान 29.8°C रहा, जिससे गंभीर 'ट्रॉपिकल नाइट' बनी हुई है। एसआरआई 78+ कूल रूफ कोटिंग से कमरों का तापमान 3.5°C तक कम किया जा सकता है। दोपहर 12 से 4 बजे तक भारी मजदूरी प्रतिबंधित है।",
                "gu": "દિલ્હી-એનસીઆર અર્બન હીટ આઇલેન્ડ ચેતવણી: જમીનનું સપાટી તાપમાન 48.5°C પર પહોંચ્યું છે (+6.8°C વિસંગતતા). રાત્રિનું લઘુત્તમ તાપમાન 29.8°C રહેતા ગંભીર ટ્રોપિકલ નાઇટ જાહેર કરાઈ છે. કૂલ રૂફ ટેકનોલોજીથી ઘરોમાં 3.5°C સુધી રાહત મળી શકે છે.",
                "mr": "दिल्ली-एनसीआर अर्बन हीट आयलंड इशारा: जमिनीचे पृष्ठभाग तापमान 48.5°C नोंदवले गेले असून +6.8°C थर्मल ॲनोमली आहे. रात्रीचे किमान तापमान 29.8°C राहिल्याने शरीराला उष्णतेपासून विश्रांती मिळत नाही. कुल रूफ कोटिंगमुळे 3.5°C पर्यंत थंडावा मिळतो.",
                "kn": "ದೆಹಲಿ-ಎನ್‌ಸಿಆರ್ ಅರ್ಬನ್ ಹೀಟ್ ಐಲ್ಯಾಂಡ್ ಎಚ್ಚರಿಕೆ: ಭೂ ಮೇಲ್ಮೈ ತಾಪಮಾನವು 48.5°C ತಲುಪಿದ್ದು +6.8°C ವ್ಯತ್ಯಾಸವಿದೆ. ರಾತ್ರಿಯ ಕನಿಷ್ಠ ತಾಪಮಾನ 29.8°C ಆಗಿದ್ದು ತೀವ್ರ ಉಷ್ಣತೆಯಿದೆ. ಕೂಲ್ ರೂಫ್ ಲೇಪನವು 3.5°C ಒಳಾಂಗಣ ತಂಪನ್ನು ನೀಡುತ್ತದೆ.",
                "ta": "டெல்லி-என்சிஆர் நகர்ப்புற வெப்ப தீவு (UHI) எச்சரிக்கை: நில மேற்பரப்பு வெப்பநிலை 48.5°C (+6.8°C முரண்பாடு) எட்டியுள்ளது. இரவு குறைந்தபட்ச வெப்பநிலை 29.8°C ஆக பதிவாகியுள்ளது. கூல் ரூஃப் (SRI>=78) பூச்சு உட்புற வெப்பநிலையை 3.5°C வரை குறைக்கும்.",
                "bn": "দিল্লি-এনসিআর আরবান হিট আইল্যান্ড সতর্কতা: ভূপৃষ্ঠের তাপমাত্রা রেকর্ড করা হয়েছে 48.5°C (+6.8°C অ্যানোমালি)। রাতের সর্বনিম্ন তাপমাত্রা 29.8°C থাকায় শরীর স্বাভাবিক হতে পারছে না। কুল রুফ কোটিং 3.5°C পর্যন্ত তাপমাত্রা কমায়।",
            },
        },
        "ahmedabad_amc": {
            "city_name": "Ahmedabad AMC",
            "state": "Gujarat",
            "latitude": 23.0225,
            "longitude": 72.5714,
            "climate_zone": "Hot-Dry",
            "dominant_morphology": CanopyUrbanMorphology.INDUSTRIAL_ASPHALT_ZONE,
            "lst_urban": 47.2,
            "lst_rural": 41.3,
            "canopy_air_temp": 42.5,
            "tropical_night_min_temp": 28.5,
            "isf_pct": 84.0,
            "ndvi_urban": 0.12,
            "ndvi_rural": 0.44,
            "svf": 0.42,
            "anthropogenic_qf": 78.0,
            "hotspots": [
                {
                    "hotspot_id": "ah_naroda",
                    "hotspot_name": "Naroda GIDC Industrial Estate",
                    "morphology": CanopyUrbanMorphology.INDUSTRIAL_ASPHALT_ZONE,
                    "lst_celsius": 48.4,
                    "thermal_anomaly_delta_c": 7.1,
                    "vulnerability_rank": "VERY_HIGH",
                    "cooling_shelter_distance_m": 400,
                },
                {
                    "hotspot_id": "ah_kalupur",
                    "hotspot_name": "Kalupur Old Railway Station Area",
                    "morphology": CanopyUrbanMorphology.HIGH_DENSITY_CONCRETE_CORE,
                    "lst_celsius": 47.8,
                    "thermal_anomaly_delta_c": 6.5,
                    "vulnerability_rank": "HIGH",
                    "cooling_shelter_distance_m": 250,
                },
                {
                    "hotspot_id": "ah_maninagar",
                    "hotspot_name": "Maninagar Commercial Grid",
                    "morphology": CanopyUrbanMorphology.HIGH_DENSITY_CONCRETE_CORE,
                    "lst_celsius": 46.9,
                    "thermal_anomaly_delta_c": 5.6,
                    "vulnerability_rank": "HIGH",
                    "cooling_shelter_distance_m": 300,
                },
            ],
            "directives": {
                "cool_roof_policy_status": "ACTIVE_MANDATORY_MUNICIPAL",
                "cool_roof_target_sq_meters": 850000,
                "urban_forestry_corridor_km": 32.0,
                "transit_misting_stations_count": 48,
                "construction_heat_shift_enforced": True,
                "public_pyaus_drinking_water_points": 640,
                "emergency_cooling_shelters_active": 95,
            },
            "bulletins": {
                "en": "AHMEDABAD AMC UHI ADVISORY: Urban Land Surface Temperature peaked at 47.2°C (+5.9°C anomaly). AMC Cool Roofs Program mandate active for low-income settlements and commercial terraces. Tropical Night minimum 28.5°C recorded.",
                "hi": "अहमदाबाद एएमसी यूएचआई चेतावनी: शहर का सतह तापमान 47.2°C (+5.9°C विसंगति) दर्ज किया गया। एएमसी कूल रूफ कार्यक्रम के तहत छत पर सफेदी व कूल कोटिंग अनिवार्य की जा रही है। रात का तापमान 28.5°C बना हुआ है।",
                "gu": "અમદાવાદ મ્યુનિસિપલ કોર્પોરેશન હીટ આઇલેન્ડ ચેતવણી: શહેરનું જમીન સપાટી તાપમાન 47.2°C (+5.9°C વિસંગતતા) નોંધાયું છે. એએમસી કૂલ રૂફ મિશન હેઠળ ચૂનો અથવા કૂલ રૂફ કલર લગાવવો જરૂરી છે. રાત્રિનું તાપમાન 28.5°C છે.",
                "mr": "अहमदाबाद महानगरपालिका इशारा: जमिनीचे पृष्ठभाग तापमान 47.2°C (+5.9°C ॲनोमली). कुल रूफ कार्यक्रमांतर्गत घराच्या छतावर पांढरा रंग किंवा टाईल्स लावण्याचे आवाहन. रात्रीचे तापमान 28.5°C आहे.",
                "kn": "ಅಹಮದಾಬಾದ್ ಎಎಂಸಿ ಹೀಟ್ ಐಲ್ಯಾಂಡ್ ಎಚ್ಚರಿಕೆ: ನಗರದ ಭೂ ಮೇಲ್ಮೈ ತಾಪಮಾನ 47.2°C ದಾಖಲಾಗಿದೆ. ಕೂಲ್ ರೂಫ್ ಲೇಪನವು ಒಳಾಂಗಣ ತಾಪಮಾನವನ್ನು 3.2°C ವರೆಗೆ ತಗ್ಗಿಸುತ್ತದೆ.",
                "ta": "அகமதாபாத் நகர்ப்புற வெப்ப தீவு எச்சரிக்கை: நில வெப்பநிலை 47.2°C (+5.9°C முரண்பாடு). கூல் ரூஃப் பூச்சுகள் வீட்டு வெப்பத்தை 3.2°C வரை தணிக்கும்.",
                "bn": "আহমেদাবাদ এএমসি ইউএইচআই বুলেটিন: ভূপৃষ্ঠের তাপমাত্রা 47.2°C। এএমসি কুল রুফ প্রকল্পের আওতায় ছাদ সাদা রঙ করার নির্দেশ দেওয়া হয়েছে।",
            },
        },
        "mumbai_mmr": {
            "city_name": "Mumbai MMR",
            "state": "Maharashtra",
            "latitude": 19.0400,
            "longitude": 72.8550,
            "climate_zone": "Warm-Humid Coastal",
            "dominant_morphology": CanopyUrbanMorphology.INFORMAL_SETTLEMENT_TIN_ROOF,
            "lst_urban": 41.6,
            "lst_rural": 36.8,
            "canopy_air_temp": 36.2,
            "tropical_night_min_temp": 27.9,
            "isf_pct": 91.0,
            "ndvi_urban": 0.09,
            "ndvi_rural": 0.48,
            "svf": 0.32,
            "anthropogenic_qf": 88.0,
            "hotspots": [
                {
                    "hotspot_id": "mum_dharavi",
                    "hotspot_name": "Dharavi Tin Roof Cluster",
                    "morphology": CanopyUrbanMorphology.INFORMAL_SETTLEMENT_TIN_ROOF,
                    "lst_celsius": 43.8,
                    "thermal_anomaly_delta_c": 7.0,
                    "vulnerability_rank": "VERY_HIGH",
                    "cooling_shelter_distance_m": 180,
                },
                {
                    "hotspot_id": "mum_lower_parel",
                    "hotspot_name": "Lower Parel Commercial Towers",
                    "morphology": CanopyUrbanMorphology.COMMERCIAL_GLASS_CANYON,
                    "lst_celsius": 42.4,
                    "thermal_anomaly_delta_c": 5.6,
                    "vulnerability_rank": "HIGH",
                    "cooling_shelter_distance_m": 220,
                },
                {
                    "hotspot_id": "mum_kurla_west",
                    "hotspot_name": "Kurla West Transit Junction",
                    "morphology": CanopyUrbanMorphology.HIGH_DENSITY_CONCRETE_CORE,
                    "lst_celsius": 42.0,
                    "thermal_anomaly_delta_c": 5.2,
                    "vulnerability_rank": "HIGH",
                    "cooling_shelter_distance_m": 280,
                },
            ],
            "directives": {
                "cool_roof_policy_status": "ACTIVE_MANDATORY_COMMERCIAL",
                "cool_roof_target_sq_meters": 1500000,
                "urban_forestry_corridor_km": 25.0,
                "transit_misting_stations_count": 55,
                "construction_heat_shift_enforced": True,
                "public_pyaus_drinking_water_points": 580,
                "emergency_cooling_shelters_active": 110,
            },
            "bulletins": {
                "en": "MUMBAI MMR UHI ADVISORY: High humidity compounded by +4.8°C thermal anomaly. Uninsulated corrugated tin roofs in high-density informal settlements exceed 43.8°C. High-reflectance coatings reduce tin roof heat transmission by up to 22°C.",
                "hi": "मुंबई एमएमआर यूएचआई चेतावनी: उच्च आर्द्रता और +4.8°C सतही ताप विसंगति। धारावी जैसे घने क्षेत्रों में टीन की छतें 43.8°C तक तप रही हैं। कूल रूफ कोटिंग से टीन की छतों का तापमान 22°C तक कम होता है।",
                "gu": "મુંબઈ એમએમઆર અર્બન હીટ આઇલેન્ડ ચેતવણી: ભેજ સાથે +4.8°C થર્મલ વિસંગતતા. પતરાંવાળા મકાનોમાં છતનું તાપમાન 43.8°C પહોંચ્યું. કૂલ રૂફ કોટિંગથી મોટી રાહત મળશે.",
                "mr": "मुंबई एमएमआर अर्बन हीट आयलंड इशारा: उच्च आर्द्रता आणि +4.8°C उष्णतेची विसंगती. धारावीसारख्या वस्त्यांमध्ये पत्र्याची छते 43.8°C पर्यंत तापली आहेत. कुल रूफ पेंटमुळे पत्र्याचे तापमान 22°C ने कमी होऊ शकते.",
                "kn": "ಮುಂಬೈ ಎಂಎಂಆರ್ ಹೀಟ್ ಐಲ್ಯಾಂಡ್ ಎಚ್ಚರಿಕೆ: ತೇವಾಂಶ ಮತ್ತು +4.8°C ತಾಪಮಾನ ಹೆಚ್ಚಳ. ತಗಡಿನ ಛಾವಣಿಗಳ ಮೇಲೆ ಕೂಲ್ ಕೋಟಿಂಗ್ ಮಾಡುವುದರಿಂದ ಶಾಖ ಕಡಿಮೆಯಾಗುತ್ತದೆ.",
                "ta": "மும்பை பெருநகர வெப்ப தீவு எச்சரிக்கை: அதிக ஈரப்பதத்துடன் +4.8°C வெப்ப முரண்பாடு. தகரக் கூரைகளில் கூல் ரூஃப் பூசுவது 22°C வரை வெப்பத்தைக் குறைக்கும்.",
                "bn": "মুম্বাই এমএমআর ইউএইচআই সতর্কবার্তা: আর্দ্রতার সাথে +4.8°C ভূপৃষ্ঠ তাপবৃদ্ধি। টিনের চালের ঘরগুলিতে কুল রুফ কোটিং আবশ্যক।",
            },
        },
        "bengaluru_bbmp": {
            "city_name": "Bengaluru BBMP",
            "state": "Karnataka",
            "latitude": 12.9716,
            "longitude": 77.5946,
            "climate_zone": "Moderate Semi-Arid Plateau",
            "dominant_morphology": CanopyUrbanMorphology.COMMERCIAL_GLASS_CANYON,
            "lst_urban": 37.8,
            "lst_rural": 33.6,
            "canopy_air_temp": 34.5,
            "tropical_night_min_temp": 23.8,
            "isf_pct": 82.0,
            "ndvi_urban": 0.18,
            "ndvi_rural": 0.52,
            "svf": 0.48,
            "anthropogenic_qf": 62.0,
            "hotspots": [
                {
                    "hotspot_id": "blr_peenya",
                    "hotspot_name": "Peenya Industrial Estate",
                    "morphology": CanopyUrbanMorphology.INDUSTRIAL_ASPHALT_ZONE,
                    "lst_celsius": 39.2,
                    "thermal_anomaly_delta_c": 5.6,
                    "vulnerability_rank": "HIGH",
                    "cooling_shelter_distance_m": 450,
                },
                {
                    "hotspot_id": "blr_whitefield",
                    "hotspot_name": "Whitefield IT Corridor",
                    "morphology": CanopyUrbanMorphology.COMMERCIAL_GLASS_CANYON,
                    "lst_celsius": 38.5,
                    "thermal_anomaly_delta_c": 4.9,
                    "vulnerability_rank": "MODERATE",
                    "cooling_shelter_distance_m": 350,
                },
                {
                    "hotspot_id": "blr_majestic",
                    "hotspot_name": "Majestic Transport Interchange",
                    "morphology": CanopyUrbanMorphology.HIGH_DENSITY_CONCRETE_CORE,
                    "lst_celsius": 38.1,
                    "thermal_anomaly_delta_c": 4.5,
                    "vulnerability_rank": "MODERATE",
                    "cooling_shelter_distance_m": 120,
                },
            ],
            "directives": {
                "cool_roof_policy_status": "PILOT_VOLUNTARY",
                "cool_roof_target_sq_meters": 600000,
                "urban_forestry_corridor_km": 40.0,
                "transit_misting_stations_count": 30,
                "construction_heat_shift_enforced": False,
                "public_pyaus_drinking_water_points": 420,
                "emergency_cooling_shelters_active": 60,
            },
            "bulletins": {
                "en": "BENGALURU BBMP UHI ADVISORY: Loss of green canopy (-58% over 20 years) drives a +4.2°C urban thermal anomaly. Lake microclimates provide vital cooling buffers. Industrial corridors in Peenya reach 39.2°C.",
                "hi": "बेंगलुरु बीबीएमपी यूएचआई परामर्श: हरित क्षेत्र में कमी के कारण +4.2°C सतही ताप विसंगति उत्पन्न हुई है। पीन्या औद्योगिक क्षेत्र 39.2°C तक गर्म है। झीलों के संरक्षण से प्राकृतिक शीतलन को बढ़ावा दें।",
                "gu": "બેંગલુરુ બીબીએમપી હીટ આઇલેન્ડ ચેતવણી: હરિયાળી ઘટવાથી +4.2°C થર્મલ વિસંગતતા નોંધાઈ છે. પીન્યા ઇન્ડસ્ટ્રિયલ એરિયામાં 39.2°C તાપમાન છે.",
                "mr": "बंगळुरू बीबीएमपी इशारा: वृक्षतोडीमुळे +4.2°C अर्बन हीट आयलंड विसंगती. पीन्या औद्योगिक क्षेत्रात तापमान 39.2°C पर्यंत वाढले आहे.",
                "kn": "ಬೆಂಗಳೂರು ಬಿಬಿಎಂಪಿ ಯುಎಚ್‌ಐ ಸಲಹೆ: ಹಸಿರು ಹೊದಿಕೆ ಕಡಿಮೆಯಾಗಿರುವುದರಿಂದ +4.2°C ಉಷ್ಣತೆ ಹೆಚ್ಚಾಗಿದೆ. ಪೀಣ್ಯ ಕೈಗಾರಿಕಾ ಪ್ರದೇಶದಲ್ಲಿ ತಾಪಮಾನ 39.2°C ತಲುಪಿದೆ. ಕೂಲ್ ರೂಫ್ ಅಳವಡಿಕೆಯಿಂದ ಒಳಾಂಗಣ ತಂಪನ್ನು ಕಾಪಾಡಿಕೊಳ್ಳಿ.",
                "ta": "பெங்களூரு மாநகராட்சி வெப்ப தீவு தகவல்: மரங்கள் குறைவால் +4.2°C வெப்ப முரண்பாடு. பீன்யா தொழிற்பேட்டையில் 39.2°C பதிவாகியுள்ளது.",
                "bn": "বেঙ্গালুরু বিবিএমপি পরামর্শ: সবুজ ধ্বংসের কারণে +4.2°C তাপ বৃদ্ধি। পিনিয়া শিল্পাঞ্চলে সর্বোচ্চ 39.2°C তাপমাত্রা।",
            },
        },
        "hyderabad_ghmc": {
            "city_name": "Hyderabad GHMC",
            "state": "Telangana",
            "latitude": 17.3850,
            "longitude": 78.4867,
            "climate_zone": "Semi-Arid Deccan Plateau",
            "dominant_morphology": CanopyUrbanMorphology.HIGH_DENSITY_CONCRETE_CORE,
            "lst_urban": 44.2,
            "lst_rural": 39.0,
            "canopy_air_temp": 40.8,
            "tropical_night_min_temp": 28.1,
            "isf_pct": 85.0,
            "ndvi_urban": 0.14,
            "ndvi_rural": 0.45,
            "svf": 0.40,
            "anthropogenic_qf": 74.0,
            "hotspots": [
                {
                    "hotspot_id": "hyd_charminar",
                    "hotspot_name": "Charminar Old Walled Core",
                    "morphology": CanopyUrbanMorphology.HIGH_DENSITY_CONCRETE_CORE,
                    "lst_celsius": 45.6,
                    "thermal_anomaly_delta_c": 6.6,
                    "vulnerability_rank": "VERY_HIGH",
                    "cooling_shelter_distance_m": 220,
                },
                {
                    "hotspot_id": "hyd_hitec_city",
                    "hotspot_name": "HITEC City Cyber Towers Canyon",
                    "morphology": CanopyUrbanMorphology.COMMERCIAL_GLASS_CANYON,
                    "lst_celsius": 44.8,
                    "thermal_anomaly_delta_c": 5.8,
                    "vulnerability_rank": "HIGH",
                    "cooling_shelter_distance_m": 300,
                },
                {
                    "hotspot_id": "hyd_sanath_nagar",
                    "hotspot_name": "Sanath Nagar Industrial Corridor",
                    "morphology": CanopyUrbanMorphology.INDUSTRIAL_ASPHALT_ZONE,
                    "lst_celsius": 45.9,
                    "thermal_anomaly_delta_c": 6.9,
                    "vulnerability_rank": "VERY_HIGH",
                    "cooling_shelter_distance_m": 400,
                },
            ],
            "directives": {
                "cool_roof_policy_status": "ACTIVE_MANDATORY_MUNICIPAL",
                "cool_roof_target_sq_meters": 2000000,
                "urban_forestry_corridor_km": 35.0,
                "transit_misting_stations_count": 50,
                "construction_heat_shift_enforced": True,
                "public_pyaus_drinking_water_points": 510,
                "emergency_cooling_shelters_active": 80,
            },
            "bulletins": {
                "en": "HYDERABAD GHMC UHI ADVISORY: Telangana Cool Roof Policy 2023-2028 mandate in effect for all plots >=600 sq yd. Urban thermal anomaly reached +5.2°C with nocturnal tropical night of 28.1°C. High thermal mass granite geology retains substantial evening heat.",
                "hi": "हैदराबाद जीएचएमसी यूएचआई चेतावनी: तेलंगाना कूल रूफ पॉलिसी 2023-2028 लागू है। शहर की थर्मल विसंगति +5.2°C और रात का तापमान 28.1°C रहा। ग्रेनाइट चट्टानें शाम को भारी मात्रा में ऊष्मा उत्सर्जित करती हैं।",
                "gu": "હૈદરાબાદ જીએચએમસી ચેતવણી: તેલંગાણા કૂલ રૂફ પોલિસી હેઠળ છતનું તાપમાન નિયંત્રિત કરવું ફરજિયાત છે. +5.2°C અર્બન હીટ આઇલેન્ડ વિસંગતતા નોંધાઈ.",
                "mr": "हैदराबाद जीएचएमसी इशारा: तेलंगणा कुल रूफ धोरण लागू. +5.2°C उष्णतेची विसंगती असून रात्रीचे तापमान 28.1°C आहे.",
                "kn": "ಹೈದರಾಬಾದ್ ಜಿಎಚ್‌ಎಂಸಿ ಯುಎಚ್‌ಐ ಎಚ್ಚರಿಕೆ: ತೆಲಂಗಾಣ ಕೂಲ್ ರೂಫ್ ನೀತಿ ಜಾರಿಯಲ್ಲಿದೆ. ನಗರದ ಉಷ್ಣತೆಯು +5.2°C ಹೆಚ್ಚಾಗಿದ್ದು ರಾತ್ರಿಯ ಕನಿಷ್ಠ ತಾಪಮಾನ 28.1°C ಆಗಿದೆ.",
                "ta": "ஹைதராபாத் ஜிஎச்எம்சி வெப்ப எச்சரிக்கை: தெலங்கானா கூல் ரூஃப் கொள்கை 2023-2028 கட்டாயம். இரவு குறைந்தபட்ச வெப்பம் 28.1°C ஆக உள்ளதால் தூக்கம் பாதிக்கப்படலாம்.",
                "bn": "হায়দ্রাবাদ জিএইচএমসি বুলেটিন: তেলেঙ্গানা কুল রুফ নীতি কার্যকর। শহরের ভূপৃষ্ঠ তাপবৃদ্ধি +5.2°C এবং রাতে তীব্র গরম অনুভূত হচ্ছে।",
            },
        },
        "chennai_gcc": {
            "city_name": "Chennai GCC",
            "state": "Tamil Nadu",
            "latitude": 13.0827,
            "longitude": 80.2707,
            "climate_zone": "Warm-Humid Coastal",
            "dominant_morphology": CanopyUrbanMorphology.HIGH_DENSITY_CONCRETE_CORE,
            "lst_urban": 42.1,
            "lst_rural": 37.6,
            "canopy_air_temp": 37.5,
            "tropical_night_min_temp": 28.4,
            "isf_pct": 87.0,
            "ndvi_urban": 0.13,
            "ndvi_rural": 0.47,
            "svf": 0.36,
            "anthropogenic_qf": 82.0,
            "hotspots": [
                {
                    "hotspot_id": "chn_george_town",
                    "hotspot_name": "George Town Commercial Alleyways",
                    "morphology": CanopyUrbanMorphology.HIGH_DENSITY_CONCRETE_CORE,
                    "lst_celsius": 43.4,
                    "thermal_anomaly_delta_c": 5.8,
                    "vulnerability_rank": "VERY_HIGH",
                    "cooling_shelter_distance_m": 150,
                },
                {
                    "hotspot_id": "chn_t_nagar",
                    "hotspot_name": "T. Nagar Ranganathan Street Area",
                    "morphology": CanopyUrbanMorphology.HIGH_DENSITY_CONCRETE_CORE,
                    "lst_celsius": 43.1,
                    "thermal_anomaly_delta_c": 5.5,
                    "vulnerability_rank": "HIGH",
                    "cooling_shelter_distance_m": 190,
                },
                {
                    "hotspot_id": "chn_ambattur",
                    "hotspot_name": "Ambattur Industrial Estate",
                    "morphology": CanopyUrbanMorphology.INDUSTRIAL_ASPHALT_ZONE,
                    "lst_celsius": 43.9,
                    "thermal_anomaly_delta_c": 6.3,
                    "vulnerability_rank": "VERY_HIGH",
                    "cooling_shelter_distance_m": 500,
                },
            ],
            "directives": {
                "cool_roof_policy_status": "ACTIVE_MANDATORY_COMMERCIAL",
                "cool_roof_target_sq_meters": 900000,
                "urban_forestry_corridor_km": 28.0,
                "transit_misting_stations_count": 42,
                "construction_heat_shift_enforced": True,
                "public_pyaus_drinking_water_points": 480,
                "emergency_cooling_shelters_active": 75,
            },
            "bulletins": {
                "en": "CHENNAI GCC UHI ADVISORY: Land surface temperature 42.1°C with +4.5°C anomaly. Dense concrete street grids block cooling afternoon sea breezes. Tropical Night minimum 28.4°C severely impairs natural sleep recovery. Cool roof application cuts indoor heat significantly.",
                "hi": "चेन्नई जीसीसी यूएचआई परामर्श: भूमि की सतह का तापमान 42.1°C (+4.5°C विसंगति)। कंक्रीट की ऊंची इमारतें समुद्री हवा के प्रवाह को रोकती हैं। रात का न्यूनतम तापमान 28.4°C बना हुआ है। कूल रूफ तकनीक का उपयोग करें।",
                "gu": "ચેન્નાઈ જીસીસી અર્બન હીટ આઇલેન્ડ ચેતવણી: જમીનનું તાપમાન 42.1°C પહોંચ્યું છે. દરિયાઈ પવન અટકતા રાત્રે પણ 28.4°C અતિશય ગરમી રહે છે.",
                "mr": "चेन्नई जीसीसी इशारा: जमिनीचे तापमान 42.1°C. दाट सिमेंटच्या इमारतींमुळे समुद्राची थंड हवा रोखली जाते. रात्रीचे तापमान 28.4°C नोंदवले गेले.",
                "kn": "ಚೆನ್ನೈ ಜಿಸಿಸಿ ಯುಎಚ್‌ಐ ಎಚ್ಚರಿಕೆ: ಭೂ ಮೇಲ್ಮೈ ತಾಪಮಾನ 42.1°C ಆಗಿದೆ. ಸಮುದ್ರದ ತಂಗಾಳಿ ಬಾರದಂತೆ ಕಾಂಕ್ರೀಟ್ ಕಟ್ಟಡಗಳು ತಡೆದಿವೆ. ರಾತ್ರಿಯ ತಾಪಮಾನ 28.4°C ಆಗಿದೆ.",
                "ta": "சென்னை மாநகராட்சி நகர்ப்புற வெப்ப தீவு (UHI) எச்சரிக்கை: நில மேற்பரப்பு வெப்பநிலை 42.1°C (+4.5°C முரண்பாடு). கான்கிரீட் அடுக்குமாடிகள் கடல் காற்றை தடுப்பதால் இரவிலும் 28.4°C வெப்பம் நீடிக்கிறது. கூல் ரூஃப் (வெள்ளை சுண்ணாம்பு / பூச்சு) பயன்படுத்துங்கள்.",
                "bn": "চেন্নাই জিসিসি ইউএইচআই সতর্কবার্তা: ভূপৃষ্ঠের তাপমাত্রা 42.1°C। বহুতল ভবনের কারণে সমুদ্রের বাতাস ঢুকতে পারছে না। রাতেও তীব্র 28.4°C গরম।",
            },
        },
        "kolkata_kmc": {
            "city_name": "Kolkata KMC",
            "state": "West Bengal",
            "latitude": 22.5726,
            "longitude": 88.3639,
            "climate_zone": "Warm-Humid Indo-Gangetic Delta",
            "dominant_morphology": CanopyUrbanMorphology.HIGH_DENSITY_CONCRETE_CORE,
            "lst_urban": 43.4,
            "lst_rural": 38.5,
            "canopy_air_temp": 38.8,
            "tropical_night_min_temp": 28.7,
            "isf_pct": 86.0,
            "ndvi_urban": 0.12,
            "ndvi_rural": 0.50,
            "svf": 0.35,
            "anthropogenic_qf": 72.0,
            "hotspots": [
                {
                    "hotspot_id": "kol_burrabazar",
                    "hotspot_name": "Burrabazar Wholesale Density",
                    "morphology": CanopyUrbanMorphology.HIGH_DENSITY_CONCRETE_CORE,
                    "lst_celsius": 44.6,
                    "thermal_anomaly_delta_c": 6.1,
                    "vulnerability_rank": "VERY_HIGH",
                    "cooling_shelter_distance_m": 160,
                },
                {
                    "hotspot_id": "kol_howrah_appr",
                    "hotspot_name": "Howrah Station Approach & Foreshore",
                    "morphology": CanopyUrbanMorphology.INDUSTRIAL_ASPHALT_ZONE,
                    "lst_celsius": 44.2,
                    "thermal_anomaly_delta_c": 5.7,
                    "vulnerability_rank": "HIGH",
                    "cooling_shelter_distance_m": 210,
                },
                {
                    "hotspot_id": "kol_salt_lake_sec5",
                    "hotspot_name": "Salt Lake Sector V IT Complex",
                    "morphology": CanopyUrbanMorphology.COMMERCIAL_GLASS_CANYON,
                    "lst_celsius": 43.7,
                    "thermal_anomaly_delta_c": 5.2,
                    "vulnerability_rank": "HIGH",
                    "cooling_shelter_distance_m": 320,
                },
            ],
            "directives": {
                "cool_roof_policy_status": "ACTIVE_MANDATORY_COMMERCIAL",
                "cool_roof_target_sq_meters": 750000,
                "urban_forestry_corridor_km": 30.0,
                "transit_misting_stations_count": 38,
                "construction_heat_shift_enforced": True,
                "public_pyaus_drinking_water_points": 460,
                "emergency_cooling_shelters_active": 70,
            },
            "bulletins": {
                "en": "KOLKATA KMC UHI ADVISORY: High relative humidity and +4.9°C surface thermal anomaly creating oppressive heat indices. East Kolkata Wetlands act as a critical natural cooling sink. Nighttime minimum of 28.7°C recorded in Burrabazar core.",
                "hi": "कोलकाता केएमसी यूएचआई चेतावनी: उच्च आर्द्रता और +4.9°C सतही ताप विसंगति से अत्यधिक बेचैनी। पूर्वी कोलकाता वेटलैंड्स प्राकृतिक शीतलन प्रदान कर रहे हैं। बड़ाबाजार में रात का तापमान 28.7°C दर्ज हुआ।",
                "gu": "કોલકાતા કેએમસી અર્બન હીટ આઇલેન્ડ ચેતવણી: ભેજ સાથે +4.9°C થર્મલ વિસંગતતા. બડાબજાર વિસ્તારમાં રાત્રે પણ 28.7°C ગરમી રહે છે.",
                "mr": "कोलकाता केएमसी इशारा: उच्च आर्द्रता आणि +4.9°C उष्णतेची विसंगती. पूर्व कोलकाता वेटलँड्स शहराला काही प्रमाणात थंड ठेवतात. रात्रीचे तापमान 28.7°C नोंदवले गेले.",
                "kn": "ಕೋಲ್ಕತ್ತಾ ಕೆಎಂಸಿ ಯುಎಚ್‌ಐ ಎಚ್ಚರಿಕೆ: ಹೆಚ್ಚಿನ ತೇವಾಂಶ ಮತ್ತು +4.9°C ಶಾಖದ ವ್ಯತ್ಯಾಸ. ಪೂರ್ವ ಕೋಲ್ಕತ್ತಾ ಜೌಗು ಪ್ರದೇಶಗಳು ತಂಪನ್ನು ನೀಡುತ್ತಿವೆ. ರಾತ್ರಿಯ ತಾಪಮಾನ 28.7°C ಇದೆ.",
                "ta": "கொல்கத்தா கேஎம்சி வெப்ப தீவு எச்சரிக்கை: ஈரப்பதம் மற்றும் +4.9°C வெப்ப முரண்பாடு. இரவு வெப்பநிலை 28.7°C ஆக உள்ளதால் மின்விசிறி/குளிர்சாதன தேவை உயர்கிறது.",
                "bn": "কলকাতা কেএমসি ইউএইচআই বুলেটিন: উচ্চ আর্দ্রতার সাথে +4.9°C ভূপৃষ্ঠের তাপবৃদ্ধি। পূর্ব কলকাতা জলাভূমি শহরের প্রাকৃতিক কুলিং সিঙ্ক হিসেবে কাজ করছে। রাতে বড়বাজারে সর্বনিম্ন তাপমাত্রা 28.7°C রেকর্ড হয়েছে।",
            },
        },
    }

    @classmethod
    def get_corridor(
        cls,
        corridor_id: Optional[str] = None,
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        roof_type: Optional[str] = None,
    ) -> UrbanHeatIslandResponse:
        """Resolve the closest or specified megacity corridor and run Cool Roof simulation."""
        # 1. Select corridor ID
        selected_id = corridor_id.lower() if corridor_id else None
        if not selected_id or selected_id not in cls._CORRIDORS:
            if latitude is not None and longitude is not None:
                selected_id = cls._resolve_nearest_corridor(latitude, longitude)
            else:
                selected_id = "delhi_ncr"

        raw = cls._CORRIDORS[selected_id]

        # 2. Compute thermal anomaly
        lst_urban = raw["lst_urban"]
        lst_rural = raw["lst_rural"]
        uhi_delta = round(lst_urban - lst_rural, 1)

        # 3. Categorize severity
        if uhi_delta >= 6.0:
            threat_level = UhiSeverityLevel.CRITICAL_EXTREME
        elif uhi_delta >= 4.0:
            threat_level = UhiSeverityLevel.HIGH_SEVERE
        elif uhi_delta >= 2.0:
            threat_level = UhiSeverityLevel.MODERATE_ELEVATED
        else:
            threat_level = UhiSeverityLevel.LOW_NEGLIGIBLE

        # 4. Tropical Night classification
        t_min = raw["tropical_night_min_temp"]
        tropical_night_flag = t_min >= 25.0
        severe_tropical_night_flag = t_min >= 28.0

        surface_telemetry = SurfaceThermalTelemetry(
            lst_urban_celsius=lst_urban,
            lst_rural_baseline_celsius=lst_rural,
            uhi_thermal_anomaly_delta_c=uhi_delta,
            canopy_air_temp_celsius=raw["canopy_air_temp"],
            tropical_night_min_temp_celsius=t_min,
            tropical_night_flag=tropical_night_flag,
            severe_tropical_night_flag=severe_tropical_night_flag,
        )

        # 5. Biophysical canopy metrics
        ndvi_urban = raw["ndvi_urban"]
        ndvi_rural = raw["ndvi_rural"]
        # Empirical vegetation cooling deficit: ~7.5°C per unit drop in NDVI
        veg_deficit = round(max(0.0, (ndvi_rural - ndvi_urban) * 7.5), 1)

        biophysical_metrics = BiophysicalCanopyMetrics(
            impervious_surface_fraction_pct=raw["isf_pct"],
            ndvi_urban_core=ndvi_urban,
            ndvi_rural_baseline=ndvi_rural,
            vegetation_cooling_deficit_delta_c=veg_deficit,
            sky_view_factor_svf=raw["svf"],
            anthropogenic_heat_flux_w_m2=raw["anthropogenic_qf"],
        )

        # 6. Cool Roof simulation
        parsed_roof = cls._parse_roof_type(roof_type)
        cool_roof_sim = cls._simulate_cool_roof(parsed_roof, lst_urban)

        # 7. Hotspots
        hotspots = [
            MicroclimateHotspot(
                hotspot_id=h["hotspot_id"],
                hotspot_name=h["hotspot_name"],
                morphology=h["morphology"],
                lst_celsius=h["lst_celsius"],
                thermal_anomaly_delta_c=h["thermal_anomaly_delta_c"],
                vulnerability_rank=h["vulnerability_rank"],
                cooling_shelter_distance_m=h["cooling_shelter_distance_m"],
            )
            for h in raw["hotspots"]
        ]

        # 8. Municipal Directives
        d = raw["directives"]
        directives = MunicipalUhiDirectives(
            cool_roof_policy_status=d["cool_roof_policy_status"],
            cool_roof_target_sq_meters=d["cool_roof_target_sq_meters"],
            urban_forestry_corridor_km=d["urban_forestry_corridor_km"],
            transit_misting_stations_count=d["transit_misting_stations_count"],
            construction_heat_shift_enforced=d["construction_heat_shift_enforced"],
            public_pyaus_drinking_water_points=d["public_pyaus_drinking_water_points"],
            emergency_cooling_shelters_active=d["emergency_cooling_shelters_active"],
        )

        current_corridor = UrbanHeatIslandCorridor(
            corridor_id=selected_id,
            city_name=raw["city_name"],
            state=raw["state"],
            latitude=raw["latitude"],
            longitude=raw["longitude"],
            climate_zone=raw["climate_zone"],
            dominant_morphology=raw["dominant_morphology"],
            threat_level=threat_level,
            surface_telemetry=surface_telemetry,
            biophysical_metrics=biophysical_metrics,
            cool_roof_simulation=cool_roof_sim,
            hotspots=hotspots,
            directives=directives,
            vernacular_bulletins=raw["bulletins"],
        )

        # 9. Corridor summaries
        all_summaries = []
        for cid, data in cls._CORRIDORS.items():
            delta = round(data["lst_urban"] - data["lst_rural"], 1)
            if delta >= 6.0:
                tlevel = UhiSeverityLevel.CRITICAL_EXTREME
            elif delta >= 4.0:
                tlevel = UhiSeverityLevel.HIGH_SEVERE
            elif delta >= 2.0:
                tlevel = UhiSeverityLevel.MODERATE_ELEVATED
            else:
                tlevel = UhiSeverityLevel.LOW_NEGLIGIBLE

            all_summaries.append(
                CorridorSummary(
                    corridor_id=cid,
                    city_name=data["city_name"],
                    state=data["state"],
                    threat_level=tlevel,
                    uhi_thermal_anomaly_delta_c=delta,
                    lst_urban_celsius=data["lst_urban"],
                    tropical_night_flag=data["tropical_night_min_temp"] >= 25.0,
                )
            )

        return UrbanHeatIslandResponse(
            corridor_id=selected_id,
            city_name=raw["city_name"],
            state=raw["state"],
            current_corridor=current_corridor,
            all_corridors=all_summaries,
            last_updated_utc=datetime.now(timezone.utc).isoformat(),
            data_source="IMD Urban Meteorology Mesonet & NDMA Mission Cool Roofs Telemetry",
        )

    @classmethod
    def _resolve_nearest_corridor(cls, lat: float, lon: float) -> str:
        best_id = "delhi_ncr"
        min_dist = float("inf")
        for cid, data in cls._CORRIDORS.items():
            dist = _haversine_distance(lat, lon, data["latitude"], data["longitude"])
            if dist < min_dist:
                min_dist = dist
                best_id = cid
        return best_id

    @classmethod
    def _parse_roof_type(cls, roof_type_str: Optional[str]) -> CoolRoofMaterialType:
        if not roof_type_str:
            return CoolRoofMaterialType.HIGH_ALBEDO_ELASTOMERIC_WHITE
        norm = roof_type_str.upper().strip()
        for member in CoolRoofMaterialType:
            if member.value == norm or member.name == norm:
                return member
        return CoolRoofMaterialType.HIGH_ALBEDO_ELASTOMERIC_WHITE

    @classmethod
    def _simulate_cool_roof(cls, material: CoolRoofMaterialType, lst_urban: float) -> CoolRoofSimulation:
        """Calculate peak roof surface temperature, indoor cooling delta, and AC load relief."""
        # Properties: (SRI, alpha, epsilon, base_surf_temp, indoor_cooling_delta, ac_reduction_pct, compliant)
        props = {
            CoolRoofMaterialType.HIGH_ALBEDO_ELASTOMERIC_WHITE: (104, 0.85, 0.90, 36.5, -3.5, 24.5, True),
            CoolRoofMaterialType.REFLECTIVE_CERAMIC_TILES: (85, 0.75, 0.88, 41.2, -2.8, 19.5, True),
            CoolRoofMaterialType.SLAKED_LIME_WASH: (78, 0.72, 0.85, 43.5, -2.3, 16.0, True),
            CoolRoofMaterialType.STANDARD_CONCRETE_UNCOATED: (20, 0.30, 0.85, 59.0, 0.0, 0.0, False),
            CoolRoofMaterialType.CORRUGATED_GALVANIZED_TIN: (12, 0.20, 0.25, 67.5, 2.5, -15.0, False),
        }

        sri, alpha, eps, surf_temp, indoor_delta, ac_pct, compliant = props.get(
            material, props[CoolRoofMaterialType.HIGH_ALBEDO_ELASTOMERIC_WHITE]
        )

        # Baseline comparison against standard uncoated concrete (59.0°C)
        baseline_temp = 59.0
        reduction = round(baseline_temp - surf_temp, 1)

        return CoolRoofSimulation(
            roof_material=material,
            solar_reflectance_index_sri=sri,
            solar_reflectance_alpha=alpha,
            thermal_emittance_epsilon=eps,
            surface_temperature_celsius=surf_temp,
            surface_temp_reduction_delta_c=reduction,
            indoor_cooling_benefit_delta_c=indoor_delta,
            ac_energy_load_reduction_pct=ac_pct,
            ndma_cool_roof_compliant=compliant,
        )
