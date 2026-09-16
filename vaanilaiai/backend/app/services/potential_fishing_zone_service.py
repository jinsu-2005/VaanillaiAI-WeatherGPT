import math
from datetime import datetime, timezone
from typing import Dict, List, Optional

from app.schemas.potential_fishing_zone import (
    PfzProductivityTier,
    PelagicSpeciesGroup,
    FishingCraftType,
    OceanColorTelemetry,
    ThermalFrontTelemetry,
    NavigationalVector,
    EconomicFuelSavings,
    EcologicalConservationBoundary,
    PfzSector,
    SectorSummary,
    PfzResponse,
)


def _haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculate the great-circle distance between two points in km."""
    r = 6371.0
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (
        math.sin(dlat / 2) ** 2
        + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2) ** 2
    )
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return r * c


class PotentialFishingZoneService:
    """INCOIS & CMFRI Potential Fishing Zone (PFZ), Chlorophyll-a & Marine Fuel Conservation Engine."""

    _SECTORS: Dict[str, Dict] = {
        "kochi_malabar": {
            "sector_name": "Kochi & Munambam FLC (Malabar Coast)",
            "state": "Kerala",
            "coastal_sea": "Southeastern Arabian Sea",
            "latitude": 9.9312,
            "longitude": 76.2673,
            "primary_species": PelagicSpeciesGroup.SMALL_PELAGICS_SARDINE_MACKEREL,
            "ocean_color": {
                "chlorophyll_a": 1.85,
                "tier": PfzProductivityTier.OPTIMAL_HIGH_YIELD,
                "k490": 0.14,
                "bloom": True,
                "hab": False,
            },
            "thermal_front": {
                "sst": 28.4,
                "gradient": 0.65,
                "front_type": "COASTAL_UPWELLING_FRONT",
                "eddy_type": "CYCLONIC_COLD_CORE_UPWELLING",
                "ssha": -6.2,
            },
            "navigation": {
                "harbour": "Thoppumpady / Munambam Fishing Harbour",
                "bearing": 235,
                "compass": "SW",
                "dist_nm": 25.0,
                "dist_km": 46.3,
                "centroid_lat": 9.78,
                "centroid_lon": 75.82,
                "depth_fathoms": 28,
                "depth_meters": 51.2,
            },
            "conservation": {
                "mpa_name": "Vembanad Estuarine Wetland Buffer",
                "dist_mpa_km": 18.5,
                "buffer_status": "SAFE_OUTSIDE_BUFFER",
                "mls_advisory": "Oil Sardine MLS >= 10 cm, Indian Mackerel MLS >= 14 cm (CMFRI Gazetted)",
                "artisanal_status": "0-10 km Coastal Zone Reserved Exclusively for Traditional Motorized Crafts",
            },
            "bulletins": {
                "en": "INCOIS-CMFRI PFZ ADVISORY FOR KOCHI/MALABAR: High-yield pelagic zone active at 25.0 nm on bearing 235° SW (Depth 28 fathoms). SST thermal front 28.4°C with Chlorophyll-a 1.85 mg/m³ concentrating dense sardine and mackerel schools. Direct vectoring saves 45% scouting time and ~35L diesel per voyage for motorized craft. Bottom trawling strictly prohibited within 10 km artisanal coastal reserve.",
                "ml": "കൊച്ചി/മലബാർ തീരദേശ മത്സ്യബന്ധന മേഖല (INCOIS PFZ): തോപ്പുംപടിയിൽ നിന്ന് 235° തെക്ക്-പടിഞ്ഞാറ് (SW) ദിശയിൽ 25 നോട്ടിക്കൽ മൈൽ അകലെ 28 ഫാതം ആഴത്തിൽ മികച്ച ചാള, അയല മീൻകൂട്ടങ്ങൾ കണ്ടെത്തി. ഉപഗ്രഹ മാർഗ്ഗനിർദ്ദേശം വഴി 45% തിരച്ചിൽ സമയം ലാഭിക്കാം. 10 കി.മീ പരമ്പരാഗത മേഖലയിൽ ട്രോളിംഗ് കർശനമായി നിരോധിച്ചിരിക്കുന്നു.",
                "ta": "கொச்சி/மலபார் பகுதி மீன்பிடி மண்டல அறிவிப்பு (INCOIS PFZ): துறைமுகத்திலிருந்து 235° தென்மேற்கு திசையில் 25 கடல் மைல் தொலைவில் 28 பாகம் ஆழத்தில் மத்தி, கானாங்கெளுத்தி மீன்கள் அதிகளவில் உள்ளன. நேரடி வழிகாட்டல் மூலம் 45% டீசல் மிச்சமாகும்.",
                "te": "కొచ్చి/మలబార్ తీర మత్స్య సలహా (INCOIS PFZ): 235° నైరుతి దిశలో 25 నాటికల్ మైళ్ళ దూరంలో 28 ఫాతంల లోతులో చేపల లభ్యత ఎక్కువగా ఉంది. నేరుగా వెళ్లడం ద్వారా 45% డీజిల్ ఆదా అవుతుంది.",
                "gu": "કોચી મલબાર સંભવિત મત્સ્ય ઝોન: 235° દક્ષિણ-પશ્ચિમ દિશામાં 25 નોટિકલ માઈલ પર પ્રચુર માછલીઓ મળી આવી છે. 45% ઇંધણની બચત થશે.",
                "mr": "कोची मलबार संभाव्य मत्स्य क्षेत्र (PFZ): 235° नैऋत्य दिशेला 25 नॉटिकल मैल अंतरावर 28 फॅदम खोलीवर बांगडा व तारली माशांचे थवे आहेत. 45% डिझेल बचत होईल.",
                "bn": "কোচি মালাবার উপকূলীয় মৎস্য অঞ্চল: 235° দক্ষিণ-পশ্চিমে 25 নটিক্যাল মাইল দূরে প্রচুর সার্ডিন ও ম্যাকেরেল মাছ রয়েছে। 45% জ্বালানি সাশ্রয় হবে।",
                "od": "କୋଚି ମାଲାବାର ଉପକୂଳ ମତ୍ସ୍ୟ କ୍ଷେତ୍ର: 235° ଦକ୍ଷିଣ-ପଶ୍ଚିମରେ 25 ନଟିକାଲ୍ ମାଇଲ୍ ଦୂରତାରେ ପ୍ରଚୁର ମାଛ ମିଳିବାର ସମ୍ଭାବନା ଅଛି। 45% ଇନ୍ଧନ ବଞ୍ଚିବ।",
            },
        },
        "veraval_saurashtra": {
            "sector_name": "Veraval & Porbandar (Saurashtra Coast)",
            "state": "Gujarat",
            "coastal_sea": "Northern Arabian Sea",
            "latitude": 20.9000,
            "longitude": 70.3667,
            "primary_species": PelagicSpeciesGroup.ESTUARINE_PLUME_HILSA_POMFRET,
            "ocean_color": {
                "chlorophyll_a": 2.10,
                "tier": PfzProductivityTier.OPTIMAL_HIGH_YIELD,
                "k490": 0.18,
                "bloom": True,
                "hab": False,
            },
            "thermal_front": {
                "sst": 27.2,
                "gradient": 0.80,
                "front_type": "WINTER_CONVECTIVE_OVERTURNING_FRONT",
                "eddy_type": "CYCLONIC_GYRE",
                "ssha": -8.0,
            },
            "navigation": {
                "harbour": "Veraval Fishing Harbour / Porbandar",
                "bearing": 240,
                "compass": "WSW",
                "dist_nm": 38.0,
                "dist_km": 70.4,
                "centroid_lat": 20.65,
                "centroid_lon": 69.80,
                "depth_fathoms": 35,
                "depth_meters": 64.0,
            },
            "conservation": {
                "mpa_name": "Marine National Park Gulf of Kutch",
                "dist_mpa_km": 115.0,
                "buffer_status": "SAFE_OUTSIDE_BUFFER",
                "mls_advisory": "Silver Pomfret MLS >= 13 cm, Ribbonfish MLS >= 46 cm",
                "artisanal_status": "5 nm Territorial Water Belt Reserved for Non-Mechanized Boats",
            },
            "bulletins": {
                "en": "VERAVAL & PORBANDAR PFZ ADVISORY: High-density Silver Pomfret and Ribbonfish concentration at 38.0 nm, bearing 240° WSW (Depth 35 fathoms). Strong convective SST front (27.2°C) with Chlorophyll-a 2.10 mg/m³. Trawlers save up to 380L diesel per voyage.",
                "ml": "വേരാവൽ സൗരാഷ്ട്ര തീരം: 240° പടിഞ്ഞാറ്-തെക്ക്-പടിഞ്ഞാറ് ദിശയിൽ 38 നോട്ടിക്കൽ മൈൽ അകലെ 35 ഫാതം ആഴത്തിൽ ആവോലി, വാള മീനുകളുടെ വലിയ കൂട്ടങ്ങൾ കാണപ്പെടുന്നു. 380 ലിറ്റർ ഡീസൽ ലാഭിക്കാം.",
                "ta": "வேராவல் சௌராஷ்டிரா மீன்பிடி மண்டலம்: 240° மேற்கு-தென்மேற்கு திசையில் 38 கடல் மைல் தொலைவில் வௌவால் மற்றும் வாளை மீன்கள் மிகுந்துள்ளன. 380 லிட்டர் டீசல் சேமிக்கலாம்.",
                "te": "వెరావల్ సౌరాష్ట్ర మత్స్య జోన్: 240° పశ్చిమ-నైరుతి దిశలో 38 నాటికల్ మైళ్ళ దూరంలో పాంఫ్రెట్, రిబ్బన్ ఫిష్ సమృద్ధిగా ఉన్నాయి.",
                "gu": "વેરાવળ-પોરબંદર સંભવિત મત્સ્ય ઝોન (INCOIS PFZ): 240° પશ્ચિમ-દક્ષિણ-પશ્ચિમ (WSW) દિશામાં 38 નોટિકલ માઈલ પર 35 ફાધમ ઊંડાણમાં પાપલેટ અને પટ્ટી માછલીઓનો વિશાળ જથ્થો નોંધાયો છે. ટ્રોલર્સને ટ્રીપ દીઠ 380 લીટર ડીઝલની બચત થશે.",
                "mr": "वेरावळ व पोरबंदर संभाव्य मत्स्य क्षेत्र: 240° पश्चिम-नैऋत्य दिशेला 38 नॉटिकल मैल अंतरावर पापलेट व वाकटी मासे मुबलक आहेत. 380 लिटर डिझेल बचत होईल.",
                "bn": "ভেরাভাল সৌরাষ্ট্র মৎস্য জোন: 240° পশ্চিম-দক্ষিণ-পশ্চিমে 38 নটিক্যাল মাইল দূরে পমফ্রেট ও রিবনফিশ প্রচুর পরিমাণে রয়েছে। 380 লিটার ডিজেল সাশ্রয় সম্ভব।",
                "od": "ଭେରାଭାଲ ସୌରାଷ୍ଟ୍ର ମତ୍ସ୍ୟ କ୍ଷେତ୍ର: 240° ପଶ୍ଚିମ-ଦକ୍ଷିଣ-ପଶ୍ଚିମରେ 38 ନଟିକାଲ୍ ମାଇଲ୍ ଦୂରରେ ଚାନ୍ଦି ଓ ଫିତା ମାଛ ପ୍ରଚୁର ମିଳିବ।",
            },
        },
        "sassoon_dock_konkan": {
            "sector_name": "Sassoon Dock & Ratnagiri (Konkan Coast)",
            "state": "Maharashtra",
            "coastal_sea": "Central Arabian Sea",
            "latitude": 18.9167,
            "longitude": 72.8167,
            "primary_species": PelagicSpeciesGroup.SMALL_PELAGICS_SARDINE_MACKEREL,
            "ocean_color": {
                "chlorophyll_a": 1.45,
                "tier": PfzProductivityTier.OPTIMAL_HIGH_YIELD,
                "k490": 0.12,
                "bloom": True,
                "hab": False,
            },
            "thermal_front": {
                "sst": 28.8,
                "gradient": 0.55,
                "front_type": "SHELF_BREAK_THERMAL_FRONT",
                "eddy_type": "ANTICYCLONIC_MEANDER",
                "ssha": 3.5,
            },
            "navigation": {
                "harbour": "Sassoon Dock / New Ferry Wharf (Bhaucha Dhakka)",
                "bearing": 265,
                "compass": "W",
                "dist_nm": 28.0,
                "dist_km": 51.9,
                "centroid_lat": 18.90,
                "centroid_lon": 72.35,
                "depth_fathoms": 25,
                "depth_meters": 45.7,
            },
            "conservation": {
                "mpa_name": "Malvan Marine Sanctuary Buffer",
                "dist_mpa_km": 240.0,
                "buffer_status": "SAFE_OUTSIDE_BUFFER",
                "mls_advisory": "Bombay Duck MLS >= 18 cm, Horse Mackerel MLS >= 14 cm",
                "artisanal_status": "Maharashtra MFRA 5-fathom Artisanal Inshore Zone Protected",
            },
            "bulletins": {
                "en": "SASSOON DOCK / KONKAN PFZ ADVISORY: Target coordinate bearing 265° W at 28.0 nm (Depth 25 fathoms). High concentration of Bombay Duck, Indian Mackerel, and Horse Mackerel. Fuel savings: ~30L for FRP boats, ~240L for mechanized trawlers.",
                "ml": "സാസൂൺ ഡോക്ക് / കൊങ്കൺ തീരം: 265° പടിഞ്ഞാറ് ദിശയിൽ 28 നോട്ടിക്കൽ മൈൽ അകലെ ബൊംബെ ഡക്ക്, അയല മീനുകൾ കൂടുതലായി കാണപ്പെടുന്നു. 240 ലിറ്റർ ഡീസൽ ലാഭിക്കാം.",
                "ta": "சாசூன் டாக் / கொங்கண் பகுதி: 265° மேற்கு திசையில் 28 கடல் மைல் தொலைவில் வஞ்சிரம், கானாங்கெளுத்தி மீன்கள் உள்ளன. 240 லிட்டர் டீசல் மிச்சமாகும்.",
                "te": "సాసూన్ డాక్ కొంకణ్ తీరం: 265° పశ్చిమ దిశలో 28 నాటికల్ మైళ్ళ దూరంలో బాంబే డక్, బంగడా చేపలు లభిస్తాయి.",
                "gu": "સસૂન ડૉક મુંબઈ મત્સ્ય ઝોન: 265° પશ્ચિમ દિશામાં 28 નોટિકલ માઈલ પર બૂમલા અને બાંગડા માછલીઓ મળી આવી છે.",
                "mr": "ससून डॉक / कोकण संभाव्य मत्स्य क्षेत्र (INCOIS PFZ): 265° पश्चिम (W) दिशेला 28 नॉटिकल मैल अंतरावर 25 फॅदम खोलीवर बोंबील आणि बांगड्यांचे मोठे थवे आढळले आहेत. थेट प्रवासाने ट्रॉलर्सचे 240 लिटर डिझेल वाचेल. लहान पिल्ले पकडण्यास बंदी आहे.",
                "bn": "সাসুন ডক কোঙ্কন উপকূল: 265° পশ্চিমে 28 নটিক্যাল মাইল দূরে বোম্বে ডাক ও ম্যাকেরেল মাছ পাওয়া যাবে। 240 লিটার জ্বালানি সাশ্রয় হবে।",
                "od": "ସାସୁନ୍ ଡକ୍ କୋଙ୍କଣ ଉପକୂଳ: 265° ପଶ୍ଚିମରେ 28 ନଟିକାଲ୍ ମାଇଲ୍ ଦୂରରେ ବମ୍ବେ ଡକ୍ ଓ ମାକେରେଲ୍ ପ୍ରଚୁର ଅଛି।",
            },
        },
        "mangalore_malpe": {
            "sector_name": "Mangalore & Malpe FLC (Canara Coast)",
            "state": "Karnataka",
            "coastal_sea": "Central Arabian Sea",
            "latitude": 12.8667,
            "longitude": 74.8333,
            "primary_species": PelagicSpeciesGroup.SMALL_PELAGICS_SARDINE_MACKEREL,
            "ocean_color": {
                "chlorophyll_a": 1.60,
                "tier": PfzProductivityTier.OPTIMAL_HIGH_YIELD,
                "k490": 0.13,
                "bloom": True,
                "hab": False,
            },
            "thermal_front": {
                "sst": 28.6,
                "gradient": 0.60,
                "front_type": "COASTAL_EKMAN_UPWELLING",
                "eddy_type": "CYCLONIC_SHEAR",
                "ssha": -4.5,
            },
            "navigation": {
                "harbour": "Mangalore Old Port / Malpe Fishing Harbour",
                "bearing": 290,
                "compass": "WNW",
                "dist_nm": 22.0,
                "dist_km": 40.7,
                "centroid_lat": 13.05,
                "centroid_lon": 74.45,
                "depth_fathoms": 22,
                "depth_meters": 40.2,
            },
            "conservation": {
                "mpa_name": "Netrani Island Coral Sanctuary Buffer",
                "dist_mpa_km": 65.0,
                "buffer_status": "SAFE_OUTSIDE_BUFFER",
                "mls_advisory": "Oil Sardine MLS >= 10 cm, Indian Mackerel MLS >= 14 cm",
                "artisanal_status": "Karnataka MFRA 6 km Traditional Fishing Belt Enforced",
            },
            "bulletins": {
                "en": "MANGALORE & MALPE PFZ ADVISORY: Prime pelagic feeding ground located at 22.0 nm, bearing 290° WNW (Depth 22 fathoms). Cyclonic Ekman upwelling sustains high Oil Sardine and Indian Mackerel density. Expected fuel savings: 25L (FRP), 210L (Trawlers).",
                "ml": "മംഗലാപുരം & മാൽപെ: 290° പടിഞ്ഞാറ്-വടക്ക്-പടിഞ്ഞാറ് ദിശയിൽ 22 നോട്ടിക്കൽ മൈൽ അകലെ ചാള, അയല മീനുകൾ കൂടുതലായി കാണപ്പെടുന്നു. 210 ലിറ്റർ ഡീസൽ ലാഭിക്കാം.",
                "ta": "மங்களூரு & மால்பே மீன்பிடி மண்டலம்: 290° மேற்கு-வடமேற்கு திசையில் 22 கடல் மைல் தொலைவில் மத்தி, கானாங்கெளுத்தி மீன்கள் மிகுந்துள்ளன.",
                "te": "మంగళూరు & మాల్పే మత్స్య జోన్: 290° పశ్చిమ-వాయవ్య దిశలో 22 నాటికಲ್ మైళ్ళ దూరంలో సర్డీన్ చేపలు సమృద్ధిగా ఉన్నాయి.",
                "gu": "મંગલોર અને માલ્પે મત્સ્ય ઝોન: 290° પશ્ચિમ-ઉત્તર-પશ્ચિમ દિશામાં 22 નોટિકલ માઈલ પર મબલખ માછલીઓ મળી આવી છે.",
                "mr": "मंगळूर व मालपे संभाव्य मत्स्य क्षेत्र: 290° पश्चिम-वायव्य दिशेला 22 नॉटिकल मैल अंतरावर बांगडा व तारलीचे थवे आहेत.",
                "kn": "ಮಂಗಳೂರು ಮತ್ತು ಮಲ್ಪೆ ಮೀನುಗಾರಿಕಾ ವಲಯ (INCOIS PFZ): 290° ಪಶ್ಚಿಮ-ವಾಯುವ್ಯ (WNW) ದಿಕ್ಕಿನಲ್ಲಿ 22 ನಾಟಿಕಲ್ ಮೈಲಿ ದೂರದಲ್ಲಿ 22 ಫ್ಯಾಥಮ್ ಆಳದಲ್ಲಿ ಬೂತಾಯಿ (ಸಾರ್ಡೀನ್) ಮತ್ತು ಬಂಗುಡೆ (ಮ್ಯಾಕೆರೆಲ್) ಮೀನುಗಳ ಸಮೃದ್ಧಿ ಕಂಡುಬಂದಿದೆ. ನೇರ ದಾರಿಯಿಂದ 210 ಲೀಟರ್ ಡೀಸೆಲ್ ಉಳಿತಾಯವಾಗಲಿದೆ.",
                "bn": "ম্যাঙ্গালোর ও মালপে উপকূল: 290° পশ্চিম-উত্তর-পশ্চিমে 22 নটিক্যাল মাইল দূরে প্রচুর সার্ডিন মাছ পাওয়া যাবে।",
                "od": "ମାଙ୍ଗାଲୋର ଓ ମାଲପେ କ୍ଷେତ୍ର: 290° ପଶ୍ଚିମ-ଉତ୍ତର-ପଶ୍ଚିମରେ 22 ନଟିକାଲ୍ ମାଇଲ୍ ଦୂରରେ ମାଛ ସମୃଦ୍ଧ କ୍ଷେତ୍ର ଅଛି।",
            },
        },
        "tuticorin_mannar": {
            "sector_name": "Tuticorin & Pamban (Gulf of Mannar)",
            "state": "Tamil Nadu",
            "coastal_sea": "Gulf of Mannar / Palk Bay",
            "latitude": 8.7833,
            "longitude": 78.1333,
            "primary_species": PelagicSpeciesGroup.LARGE_PELAGICS_TUNA_SEERFISH,
            "ocean_color": {
                "chlorophyll_a": 0.95,
                "tier": PfzProductivityTier.OPTIMAL_HIGH_YIELD,
                "k490": 0.08,
                "bloom": False,
                "hab": False,
            },
            "thermal_front": {
                "sst": 29.2,
                "gradient": 0.52,
                "front_type": "OCEANIC_TUNA_CONVERGENCE",
                "eddy_type": "MANNAR_GYRE",
                "ssha": -2.0,
            },
            "navigation": {
                "harbour": "Tuticorin Fishing Harbour / Pamban Port",
                "bearing": 140,
                "compass": "SE",
                "dist_nm": 20.0,
                "dist_km": 37.0,
                "centroid_lat": 8.55,
                "centroid_lon": 78.45,
                "depth_fathoms": 45,
                "depth_meters": 82.3,
            },
            "conservation": {
                "mpa_name": "Gulf of Mannar Marine Biosphere Core Reefs",
                "dist_mpa_km": 14.2,
                "buffer_status": "PROXIMITY_ALERT",
                "mls_advisory": "Yellowfin Tuna MLS >= 50 cm, Seerfish (King Mackerel) MLS >= 37 cm",
                "artisanal_status": "Strict Trawling Ban inside Coral Reef Protected Islands",
            },
            "bulletins": {
                "en": "TUTICORIN & PAMBAN PFZ ADVISORY: Oceanic convergence zone located at 20.0 nm, bearing 140° SE (Depth 45 fathoms). High concentration of Yellowfin Tuna, Skipjack, and Seer Fish. CAUTION: Vessel tracking near Gulf of Mannar Marine Biosphere buffer (14.2 km). Zero bottom-trawling permitted in coral reefs.",
                "ml": "തൂത്തുക്കുടി & പാമ്പൻ: 140° തെക്ക്-കിഴക്ക് ദിശയിൽ 20 നോട്ടിക്കൽ മൈൽ അകലെ ചൂര, നെയ്മീൻ എന്നിവയുടെ വലിയ കൂട്ടങ്ങൾ കണ്ടെത്തി. മന്നാർ ഉൾക്കടൽ പവിഴപ്പുറ്റ് മേഖലയിൽ ട്രോളിംഗ് നിരോധിച്ചിരിക്കുന്നു.",
                "ta": "தூத்துக்குடி & பாம்பன் சாத்தியமான மீன்பிடி மண்டலம் (INCOIS PFZ): 140° தென்கிழக்கு (SE) திசையில் 20 கடல் மைல் தொலைவில் 45 பாகம் ஆழத்தில் சூர மீன் மற்றும் வஞ்சிர மீன்கள் மிகுந்துள்ளன. மன்னார் வளைகுடா பவளப்பாறை உயிரியல் பூங்கா எல்லைக்கு வெளியே மட்டுமே மீன்பிடிக்க வேண்டும். 290 லிட்டர் டீசல் சேமிக்கலாம்.",
                "te": "ట్యూటికోరిన్ & పాంబన్ మత్స్య జోన్: 140° ఆగ్నేయ దిశలో 20 నాటికల్ మైళ్ళ దూరంలో ట్యూనా, వంజరం చేపలు విస్తారంగా ఉన్నాయి. పగడపు దిబ్బల ప్రాంతంలో ట్రాలింగ్ నిషిద్ధం.",
                "gu": "તુતીકોરિન મન્નાર અખાત: 140° દક્ષિણ-પૂર્વ દિશામાં 20 નોટિકલ માઈલ પર ટુના માછલીઓનો વિશાળ જથ્થો છે.",
                "mr": "तुतिकोरीन व पामबन संभाव्य मत्स्य क्षेत्र: 140° आग्नेय दिशेला 20 नॉटिकल मैल अंतरावर सुरमई व ट्युना मासे आहेत.",
                "bn": "তুতিকোরিন ও পাম্বান উপকূল: 140° দক্ষিণ-পূর্বে 20 নটিক্যাল মাইল দূরে টুনা ও সুরমাই মাছের প্রাচুর্য রয়েছে।",
                "od": "ତୁତିକୋରିନ୍ ଓ ପାମ୍ବାନ୍ ମତ୍ସ୍ୟ କ୍ଷେତ୍ର: 140° ଦକ୍ଷିଣ-ପୂର୍ବରେ 20 ନଟିକାଲ୍ ମାଇଲ୍ ଦୂରରେ ଟୁନା ମାଛ ମିଳିବ।",
            },
        },
        "visakhapatnam_kakinada": {
            "sector_name": "Visakhapatnam & Kakinada (Northern Circars)",
            "state": "Andhra Pradesh",
            "coastal_sea": "Western Bay of Bengal",
            "latitude": 17.6833,
            "longitude": 83.2167,
            "primary_species": PelagicSpeciesGroup.LARGE_PELAGICS_TUNA_SEERFISH,
            "ocean_color": {
                "chlorophyll_a": 1.35,
                "tier": PfzProductivityTier.OPTIMAL_HIGH_YIELD,
                "k490": 0.15,
                "bloom": True,
                "hab": False,
            },
            "thermal_front": {
                "sst": 29.0,
                "gradient": 0.58,
                "front_type": "GODAVARI_RIVER_PLUME_FRONT",
                "eddy_type": "CYCLONIC_EDDY",
                "ssha": -5.5,
            },
            "navigation": {
                "harbour": "Visakhapatnam Fishing Harbour / Kakinada FLC",
                "bearing": 115,
                "compass": "ESE",
                "dist_nm": 32.0,
                "dist_km": 59.3,
                "centroid_lat": 17.50,
                "centroid_lon": 83.75,
                "depth_fathoms": 50,
                "depth_meters": 91.4,
            },
            "conservation": {
                "mpa_name": "Coringa Mangrove Wildlife Sanctuary Buffer",
                "dist_mpa_km": 48.0,
                "buffer_status": "SAFE_OUTSIDE_BUFFER",
                "mls_advisory": "Skipjack Tuna MLS >= 35 cm, Indian Mackerel MLS >= 14 cm",
                "artisanal_status": "AP Marine Fishing Act 8 km Inshore Zone Enforced",
            },
            "bulletins": {
                "en": "VISAKHAPATNAM & KAKINADA PFZ ADVISORY: Target heading 115° ESE at 32.0 nm (Depth 50 fathoms). Godavari estuarine plume boundary concentrating Skipjack Tuna, Ribbonfish, and Indian Mackerel. Expected fuel savings: 30L (FRP), 260L (Trawlers).",
                "ml": "വിശാഖപട്ടണം & കാക്കിനട: 115° കിഴക്ക്-തെക്ക്-കിഴക്ക് ദിശയിൽ 32 നോട്ടിക്കൽ മൈൽ അകലെ ചൂര, അയല മീനുകൾ കൂടുതലായി കാണപ്പെടുന്നു. 260 ലിറ്റർ ഡീസൽ ലാഭിക്കാം.",
                "ta": "விசாகப்பட்டினம் & காக்கிநாடா: 115° கிழக்கு-தென்கிழக்கு திசையில் 32 கடல் மைல் தொலைவில் சூர மீன்கள் மற்றும் கானாங்கெளுத்தி மிகுந்துள்ளன.",
                "te": "విశాఖపట్నం & కాకినాడ సంభావ్య మత్స్య జోన్ (INCOIS PFZ): 115° తూర్పు-ఆగ్నేయ (ESE) దిశలో 32 నాటికల్ మైళ్ళ దూరంలో 50 ఫాతంల లోతులో ట్యూనా, రిబ్బన్ ఫిష్, కనగర్తలు సమృద్ధిగా ఉన్నాయి. నేరుగా వెళ్లడం ద్వారా ట్రాలర్లకు 260 లీటర్ల డీజిల్ ఆదా అవుతుంది.",
                "gu": "વિશાખાપટ્ટનમ આંધ્ર પ્રદેશ: 115° પૂર્વ-દક્ષિણ-પૂર્વ દિશામાં 32 નોટિકલ માઈલ પર ટુના માછલીઓ મળી આવી છે.",
                "mr": "विशाखापट्टणम व काकिनाडा संभाव्य मत्स्य क्षेत्र: 115° पूर्व-आग्नेय दिशेला 32 नॉटिकल मैल अंतरावर सुरमई व ट्युना मासे आढळले आहेत.",
                "bn": "বিশাখাপত্তনম ও কাকিনাড়া উপকূল: 115° পূর্ব-দক্ষিণ-পূর্বে 32 নটিক্যাল মাইল দূরে প্রচুর টুনা ও ম্যাকেরেল মাছ রয়েছে।",
                "od": "ବିଶାଖାପାଟଣା ଓ କାକିନାଡ଼ା ମତ୍ସ୍ୟ କ୍ଷେତ୍ର: 115° ପୂର୍ବ-ଦକ୍ଷିଣ-ପୂର୍ବରେ 32 ନଟିକାଲ୍ ମାଇଲ୍ ଦୂରରେ ଟୁନା ଓ ଚାନ୍ଦି ମାଛ ମିଳିବ।",
            },
        },
        "paradeep_gahirmatha": {
            "sector_name": "Paradeep & Dhamra (Utkal Coast)",
            "state": "Odisha",
            "coastal_sea": "Northern Bay of Bengal",
            "latitude": 20.3167,
            "longitude": 86.6167,
            "primary_species": PelagicSpeciesGroup.ESTUARINE_PLUME_HILSA_POMFRET,
            "ocean_color": {
                "chlorophyll_a": 2.25,
                "tier": PfzProductivityTier.OPTIMAL_HIGH_YIELD,
                "k490": 0.22,
                "bloom": True,
                "hab": False,
            },
            "thermal_front": {
                "sst": 27.8,
                "gradient": 0.72,
                "front_type": "GANGETIC_ESTUARINE_FRONT",
                "eddy_type": "BAY_CYCLONIC_EDDY",
                "ssha": -7.2,
            },
            "navigation": {
                "harbour": "Paradeep Fishing Harbour / Dhamra Port",
                "bearing": 95,
                "compass": "E",
                "dist_nm": 35.0,
                "dist_km": 64.8,
                "centroid_lat": 20.30,
                "centroid_lon": 87.25,
                "depth_fathoms": 20,
                "depth_meters": 36.6,
            },
            "conservation": {
                "mpa_name": "Gahirmatha Marine Sanctuary & Olive Ridley Rookery",
                "dist_mpa_km": 12.0,
                "buffer_status": "PROXIMITY_ALERT",
                "mls_advisory": "Hilsa Shad MLS >= 23 cm, Silver Pomfret MLS >= 13 cm",
                "artisanal_status": "Turtle Excluder Devices (TED) Mandatory on all Trawlers",
            },
            "bulletins": {
                "en": "PARADEEP & DHAMRA PFZ ADVISORY: Target heading 095° E at 35.0 nm (Depth 20 fathoms). High-density Hilsa, Silver Pomfret, and Croaker schools in Gangetic estuarine thermal front. CAUTION: Operating 12.0 km from Gahirmatha Olive Ridley Marine Sanctuary. Turtle Excluder Devices (TED) strictly mandatory on all nets.",
                "ml": "പാരദ്വീപ് & ധാമ്റ: 095° കിഴക്ക് ദിശയിൽ 35 നോട്ടിക്കൽ മൈൽ അകലെ ഇൽഷ, ആവോലി മീനുകൾ കൂടുതലായി കാണപ്പെടുന്നു. ഗഹിർമാത കടലാമ സങ്കേത മേഖലയിൽ ടിഇഡി നിർബന്ധം.",
                "ta": "பாரதீப் & தாம்ரா மீன்பிடி மண்டலம்: 095° கிழக்கு திசையில் 35 கடல் மைல் தொலைவில் இல்சா மற்றும் வௌவால் மீன்கள் மிகுந்துள்ளன. ஆலிவ் ரிட்லி ஆமைகள் பாதுகாப்பு விதிமுறைகளை பின்பற்றவும்.",
                "te": "పారదీప్ & ధామ్రా మత్స్య జోన్: 095° తూర్పు దిశలో 35 నాటికల్ మైళ్ళ దూరంలో హిల్సా, పాంఫ్రెట్ చేపలు సమృద్ధిగా ఉన్నాయి. తాబేళ్ల రక్షణ నియమాలు తప్పనిసరి.",
                "gu": "પારાદીપ ઓડિશા મત્સ્ય ઝોન: 095° પૂર્વ દિશામાં 35 નોટિકલ માઈલ પર હિલસા માછલીઓ મળી આવી છે.",
                "mr": "पारादीप व धामरा संभाव्य मत्स्य क्षेत्र: 095° पूर्व दिशेला 35 नॉटिकल मैल अंतरावर हिल्सा व पापलेट मासे मुबलक आहेत.",
                "bn": "পারাদীপ ও ধামরা উপকূলীয় মৎস্য অঞ্চল: 095° পূর্বে 35 নটিক্যাল মাইল দূরে ইলিশ ও পমফ্রেট মাছের বিশাল ঝাঁক রয়েছে। গাহিরমাথা কচ্ছপ অভয়ারণ্য বিধি মেনে চলুন।",
                "od": "ପାରାଦୀପ ଓ ଧାମରା ସମ୍ଭାବ୍ୟ ମତ୍ସ୍ୟ କ୍ଷେତ୍ର (INCOIS PFZ): 095° ପୂର୍ବ (E) ଦିଗରେ 35 ନଟିକାଲ୍ ମାଇଲ୍ ଦୂରରେ 20 ଫାଥମ୍ ଗଭୀରତାରେ ଇଲିସି ଓ ଧଳା ଚାନ୍ଦି ମାଛର ବିଶାଳ ସମାବେଶ ରହିଛି। ଗହିରମଥା ଅଲିଭ୍ ରିଡଲେ ଅଭୟାରଣ୍ୟ (12 କିମି) ନିକଟବର୍ତ୍ତୀ ହୋଇଥିବାରୁ ଟର୍ଟଲ୍ ଏକ୍ସକ୍ଲୁଡର୍ ଡିଭାଇସ୍ (TED) ବ୍ୟବହାର ବାଧ୍ୟତାମୂଳକ।",
            },
        },
    }

    @classmethod
    def get_sector(
        cls,
        sector_id: Optional[str] = None,
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        craft_type: Optional[str] = None,
    ) -> PfzResponse:
        """Resolve closest or specified coastal fishing sector and compute economic fuel conservation."""
        # 1. Select sector ID
        selected_id = sector_id.lower() if sector_id else None
        if not selected_id or selected_id not in cls._SECTORS:
            if latitude is not None and longitude is not None:
                selected_id = cls._resolve_nearest_sector(latitude, longitude)
            else:
                selected_id = "kochi_malabar"

        raw = cls._SECTORS[selected_id]

        # 2. Parse craft type
        parsed_craft = cls._parse_craft_type(craft_type)

        # 3. Ocean Color & Thermal Front telemetry
        oc = raw["ocean_color"]
        ocean_color = OceanColorTelemetry(
            chlorophyll_a_mg_m3=oc["chlorophyll_a"],
            productivity_tier=oc["tier"],
            diffuse_attenuation_k490=oc["k490"],
            phytoplankton_bloom_active=oc["bloom"],
            harmful_algal_bloom_risk=oc["hab"],
        )

        tf = raw["thermal_front"]
        thermal_front = ThermalFrontTelemetry(
            sea_surface_temp_celsius=tf["sst"],
            sst_gradient_deg_c_per_km=tf["gradient"],
            thermal_front_type=tf["front_type"],
            mesoscale_eddy_type=tf["eddy_type"],
            sea_surface_height_anomaly_cm=tf["ssha"],
        )

        # 4. Navigational Vector
        nv = raw["navigation"]
        navigational_vector = NavigationalVector(
            landing_harbour_name=nv["harbour"],
            true_bearing_degrees=nv["bearing"],
            compass_direction=nv["compass"],
            distance_nautical_miles=nv["dist_nm"],
            distance_kilometers=nv["dist_km"],
            centroid_latitude=nv["centroid_lat"],
            centroid_longitude=nv["centroid_lon"],
            target_depth_fathoms=nv["depth_fathoms"],
            target_depth_meters=nv["depth_meters"],
        )

        # 5. Economic Fuel Savings
        fuel_savings = cls._calculate_fuel_savings(parsed_craft, nv["dist_nm"])

        # 6. Conservation Boundaries
        cb = raw["conservation"]
        conservation = EcologicalConservationBoundary(
            nearest_mpa_name=cb["mpa_name"],
            distance_to_mpa_boundary_km=cb["dist_mpa_km"],
            mpa_buffer_violation_risk=cb["buffer_status"],
            minimum_legal_size_advisory=cb["mls_advisory"],
            artisanal_exclusive_zone_status=cb["artisanal_status"],
        )

        current_sector = PfzSector(
            sector_id=selected_id,
            sector_name=raw["sector_name"],
            state=raw["state"],
            coastal_sea=raw["coastal_sea"],
            primary_species=raw["primary_species"],
            ocean_color=ocean_color,
            thermal_front=thermal_front,
            navigational_vector=navigational_vector,
            fuel_savings=fuel_savings,
            conservation=conservation,
            vernacular_bulletins=raw["bulletins"],
        )

        # 7. Summaries for all sectors
        all_summaries = [
            SectorSummary(
                sector_id=sid,
                sector_name=data["sector_name"],
                state=data["state"],
                productivity_tier=data["ocean_color"]["tier"],
                primary_species=data["primary_species"],
                compass_direction=data["navigation"]["compass"],
                distance_nm=data["navigation"]["dist_nm"],
            )
            for sid, data in cls._SECTORS.items()
        ]

        return PfzResponse(
            sector_id=selected_id,
            sector_name=raw["sector_name"],
            state=raw["state"],
            current_sector=current_sector,
            all_sectors=all_summaries,
            last_updated_utc=datetime.now(timezone.utc).isoformat(),
            data_source="INCOIS Oceansat-3 OCM / MODIS Ocean Color & CMFRI Pelagic Fishery Telemetry",
        )

    @classmethod
    def _resolve_nearest_sector(cls, lat: float, lon: float) -> str:
        best_id = "kochi_malabar"
        min_dist = float("inf")
        for sid, data in cls._SECTORS.items():
            dist = _haversine_distance(lat, lon, data["latitude"], data["longitude"])
            if dist < min_dist:
                min_dist = dist
                best_id = sid
        return best_id

    @classmethod
    def _parse_craft_type(cls, craft_type_str: Optional[str]) -> FishingCraftType:
        if not craft_type_str:
            return FishingCraftType.TRADITIONAL_MOTORIZED_FRP
        norm = craft_type_str.upper().strip()
        for member in FishingCraftType:
            if member.value == norm or member.name == norm:
                return member
        return FishingCraftType.TRADITIONAL_MOTORIZED_FRP

    @classmethod
    def _calculate_fuel_savings(
        cls, craft: FishingCraftType, distance_nm: float
    ) -> EconomicFuelSavings:
        """Estimate scouting time reduction, diesel liters saved, rupee cost savings, and CO2 offset."""
        diesel_price_per_liter = 90.0  # Typical subsidized / marine diesel price in INR

        if craft == FishingCraftType.TRADITIONAL_MOTORIZED_FRP:
            # 8-10m boat with OBM (9.9-15 HP). Typical scouting burn: ~70L; with PFZ: ~35L
            scouting_reduction = 45.0
            diesel_saved = round(max(15.0, distance_nm * 1.3), 1)
            rupee_saved = round(diesel_saved * diesel_price_per_liter, 0)
            co2_offset = round(diesel_saved * 2.68, 1)
        elif craft == FishingCraftType.MECHANIZED_TRAWLER_INBOARD:
            # 14-20m trawler (110-160 HP IBM). Multi-day voyage scouting burn: ~600-800L
            scouting_reduction = 50.0
            diesel_saved = round(max(180.0, distance_nm * 8.5), 1)
            rupee_saved = round(diesel_saved * diesel_price_per_liter, 0)
            co2_offset = round(diesel_saved * 2.68, 1)
        else:
            # Deep sea tuna longliner (25m+, 250+ HP). High voyage fuel consumption
            scouting_reduction = 55.0
            diesel_saved = round(max(400.0, distance_nm * 15.0), 1)
            rupee_saved = round(diesel_saved * diesel_price_per_liter, 0)
            co2_offset = round(diesel_saved * 2.68, 1)

        return EconomicFuelSavings(
            craft_type=craft,
            scouting_time_reduction_pct=scouting_reduction,
            diesel_saved_liters=diesel_saved,
            rupee_fuel_cost_savings_inr=rupee_saved,
            carbon_emission_reduction_kg_co2=co2_offset,
        )
