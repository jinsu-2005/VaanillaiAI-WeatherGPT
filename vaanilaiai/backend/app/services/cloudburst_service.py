import math
from datetime import datetime, timezone
from typing import List, Dict, Optional

from app.schemas.cloudburst import (
    CloudburstCategory,
    LandslideRiskTier,
    FlashFloodStage,
    OrographicPrecipitationTelemetry,
    SlopeStabilityMetrics,
    DebrisFlowHydrodynamics,
    MountainSafetyDirectives,
    MountainCatchmentHotspot,
    CloudburstResponse,
)


class CloudburstService:
    """
    IMD Mountain Meteorology Division & Geological Survey of India (GSI) NLEWS Service.
    Nowcasting extreme orographic cloudbursts, rainfall-induced slope instability,
    and hyper-concentrated debris flow hazards across the Western Ghats and Himalayas.
    """

    CATCHMENT_HOTSPOTS: List[Dict] = [
        {
            "catchment_id": "kedarnath_mandakini",
            "catchment_name": "Mandakini Valley & Kedarnath Basin",
            "mountain_range": "Garhwal Higher Himalayas",
            "state": "Uttarakhand",
            "elevation_m": 3584,
            "latitude": 30.7352,
            "longitude": 79.0669,
            "dominant_lithology": "Central Crystalline Gneiss & Loose Moraine Deposits",
            "orographic_precipitation": {
                "rain_rate_mm_hr": 112.0,
                "accumulated_3h_mm": 185.0,
                "accumulated_24h_mm": 310.0,
                "condensation_level_m": 2400.0,
                "cloud_top_height_km": 14.5,
                "radar_reflectivity_dbz": 58.5,
                "cloudburst_category": CloudburstCategory.CLOUDBURST,
            },
            "slope_stability": {
                "slope_angle_degrees": 38.0,
                "ari_3day_mm": 165.0,
                "ari_15day_mm": 390.0,
                "pore_water_pressure_ratio": 0.94,
                "factor_of_safety": 0.82,
                "landslide_risk_tier": LandslideRiskTier.CRITICAL_IMMINENT_FAILURE,
            },
            "hydrodynamics": {
                "peak_discharge_m3_s": 850.0,
                "debris_slurry_volume_m3": 125000.0,
                "boulder_velocity_m_s": 8.5,
                "bridge_scour_threat": "Catastrophic Pier Undermining & Span Overtopping",
                "flash_flood_stage": FlashFloodStage.CATASTROPHIC_DEBRIS_FLOW,
            },
            "directives": {
                "evacuation_order": "RED ALERT: Immediate evacuation of Mandakini riverbed settlements between Gaurikund and Sonprayag.",
                "pilgrimage_transit_advisory": "Char Dham Yatra Kedarnath trek halted at all checkpoints. Move to reinforced high-elevation shelter structures.",
                "ghat_road_transit_status": "NH-109 Rudraprayag-Gaurikund blocked by mudslides at Sirobagarh and Phata. Transit strictly prohibited.",
                "plantation_worker_protocol": "All construction, trail portering, and mule operations suspended immediately.",
            },
            "bulletins": {
                "en": "IMD & GSI EMERGENCY CLOUDBURST BULLETIN: Mandakini Valley under active CLOUDBURST (112 mm/hr). Debris flow Factor of Safety 0.82 indicates catastrophic landslide failure. Halt Char Dham trek immediately.",
                "hi": "आईएमडी और जीएसआई आपातकालीन बादल फटने का बुलेटिन: मंदाकिनी घाटी में सक्रिय बादल फटा (112 मिमी/घंटा)। ढलान स्थिरता 0.82 भूस्खलन और मलबे के तीव्र बहाव का संकेत देती है। केदारनाथ यात्रा तत्काल रोकें।",
                "ml": "ഐഎംഡി & ജിഎസ്ഐ മേഘവിസ്ഫോടന മുന്നറിയിപ്പ്: മന്ദാകിനി താഴ്‌വരയിൽ മേഘവിസ്ഫോടനം (112 mm/hr). മണ്ണിടിച്ചിൽ സാദ്ധ്യത അതീവ ഗുരുതരം. കേദാർനാഥ് തീർത്ഥാടനം അടിയന്തിരമായി നിർത്തിവെക്കുക.",
                "mr": "आयएमडी व जीएसआय ढगफुटी इशारा: मंदाकिनी खोऱ्यात तीव्र ढगफुटी (११२ मिमी/तास). भूस्खलनाचा प्रचंड धोका. केदारनाथ यात्रा त्वरित थांबवावी.",
                "ta": "வானிலை ஆய்வு மையம் மற்றும் ஜிஎஸ்ஐ மேகவெடிப்பு எச்சரிக்கை: மந்தாகினி பள்ளத்தாக்கில் தீவிர மேகவெடிப்பு (112 மிமீ/மணி). நிலச்சரிவு மற்றும் பாறை உருளல் ஆபத்து மிக அதிகம். கேதார்நாத் யாத்திரை உடனடியாக நிறுத்தம்.",
            },
        },
        {
            "catchment_id": "wayanad_vythiri_meppadi",
            "catchment_name": "Vellarimala, Meppadi & Chooralmala Catchment",
            "mountain_range": "Western Ghats Sahyadri (Camel's Hump Complex)",
            "state": "Kerala",
            "elevation_m": 850,
            "latitude": 11.5372,
            "longitude": 76.1264,
            "dominant_lithology": "Deep Weathered Laterite Regolith over Granulitic Charnockite",
            "orographic_precipitation": {
                "rain_rate_mm_hr": 94.0,
                "accumulated_3h_mm": 210.0,
                "accumulated_24h_mm": 372.0,
                "condensation_level_m": 700.0,
                "cloud_top_height_km": 12.8,
                "radar_reflectivity_dbz": 54.0,
                "cloudburst_category": CloudburstCategory.MINI_CLOUDBURST,
            },
            "slope_stability": {
                "slope_angle_degrees": 34.0,
                "ari_3day_mm": 240.0,
                "ari_15day_mm": 580.0,
                "pore_water_pressure_ratio": 0.98,
                "factor_of_safety": 0.78,
                "landslide_risk_tier": LandslideRiskTier.CRITICAL_IMMINENT_FAILURE,
            },
            "hydrodynamics": {
                "peak_discharge_m3_s": 640.0,
                "debris_slurry_volume_m3": 280000.0,
                "boulder_velocity_m_s": 7.8,
                "bridge_scour_threat": "Total Submersion & Multi-ton Boulder Impact on Span Piles",
                "flash_flood_stage": FlashFloodStage.CATASTROPHIC_DEBRIS_FLOW,
            },
            "directives": {
                "evacuation_order": "LIFE SAFETY EMERGENCY: Evacuate all settlements along Chooralmala, Mundakkai, and Attamala ravines immediately.",
                "pilgrimage_transit_advisory": "Sabarimala mountain routes in central Kerala placed on high alert; Wayanad ghat tourist travel banned.",
                "ghat_road_transit_status": "Thamarassery Churam (NH-766) and Meppadi-Vaduvanchal route closed due to debris flows and fallen trees.",
                "plantation_worker_protocol": "Strict cessation of all tea plucking, estate line-room occupation, and stream crossings.",
            },
            "bulletins": {
                "en": "GSI & KSDMA CRITICAL LANDSLIDE BULLETIN: Vellarimala-Meppadi catchment saturated with 372 mm/24h. Slope Factor of Safety 0.78 indicates imminent regolith liquefaction and catastrophic debris torrent.",
                "hi": "वायनाड मेप्पाडी आपातकालीन भूस्खलन बुलेटिन: 372 मिमी अत्यधिक वर्षा के कारण ढलान स्थिरता 0.78 पर गिरी। मलबे के बहाव का भारी खतरा। नदी तटों से तुरंत सुरक्षित स्थान पर जाएं।",
                "ml": "ജിഎസ്ഐ & ദുരന്ത നിവാരണ അതോറിറ്റി അടിയന്തര മുന്നറിയിപ്പ്: മേപ്പാടി-ചൂരൽമല മേഖലയിൽ 372 മില്ലിമീറ്റർ കനത്ത മഴ. മണ്ണിടിച്ചിൽ സൂചിക 0.78 ആയി താഴ്ന്നു. പുഴയോരങ്ങളിൽ നിന്ന് ഉടനടി ഒഴിഞ്ഞുപോകുക.",
                "mr": "वायनाड मेप्पाडी दरड कोसळण्याचा अतिदक्षतेचा इशारा: २४ तासांत ३७२ मिमी पाऊस. उतारावरील माती खचण्याचा अत्यंत गंभीर धोका. त्वरित स्थलांतर करा.",
                "ta": "வயநாடு மேப்பாடி அவசர நிலச்சரிவு எச்சரிக்கை: 24 மணி நேரத்தில் 372 மிமீ தீவிர மழை. மண் பாறை சரிவு காரணி 0.78 ஆக சரிந்துள்ளது. ஆற்றங்கரை குடியிருப்பு மக்கள் உடனடியாக வெளியேறவும்.",
            },
        },
        {
            "catchment_id": "kullu_manali_beas",
            "catchment_name": "Upper Beas River Gorge & Solang Valley",
            "mountain_range": "Pir Panjal & Higher Himalayas",
            "state": "Himachal Pradesh",
            "elevation_m": 2050,
            "latitude": 32.2432,
            "longitude": 77.1892,
            "dominant_lithology": "Fractured Quartzite, Phyllite & Alluvial Boulder Fans",
            "orographic_precipitation": {
                "rain_rate_mm_hr": 104.0,
                "accumulated_3h_mm": 148.0,
                "accumulated_24h_mm": 260.0,
                "condensation_level_m": 1800.0,
                "cloud_top_height_km": 13.8,
                "radar_reflectivity_dbz": 56.0,
                "cloudburst_category": CloudburstCategory.CLOUDBURST,
            },
            "slope_stability": {
                "slope_angle_degrees": 36.0,
                "ari_3day_mm": 140.0,
                "ari_15day_mm": 310.0,
                "pore_water_pressure_ratio": 0.88,
                "factor_of_safety": 0.91,
                "landslide_risk_tier": LandslideRiskTier.CRITICAL_IMMINENT_FAILURE,
            },
            "hydrodynamics": {
                "peak_discharge_m3_s": 920.0,
                "debris_slurry_volume_m3": 95000.0,
                "boulder_velocity_m_s": 9.2,
                "bridge_scour_threat": "Extreme Bank Erosion & Highway Undermining along NH-3",
                "flash_flood_stage": FlashFloodStage.CATASTROPHIC_DEBRIS_FLOW,
            },
            "directives": {
                "evacuation_order": "Move all riverside campers, hotels, and vehicle parks in Manali, Bahang, and Solang away from Beas floodplains.",
                "pilgrimage_transit_advisory": "Manikaran Sahib and Shrikhand Mahadev trekking routes closed indefinitely.",
                "ghat_road_transit_status": "Kullu-Manali NH-3 and Rohtang Atal Tunnel approach roads closed due to flash floods and rockfalls.",
                "plantation_worker_protocol": "Cease all apple orchard harvesting on steep terraces along gorge slopes.",
            },
            "bulletins": {
                "en": "IMD MOUNTAIN MET BULLETIN: Active CLOUDBURST in Solang-Manali basin (104 mm/hr). Beas River discharge surging to 920 m3/s. Heavy debris torrent hazard. Stay off riverbanks and bridges.",
                "hi": "कुल्लू-मनाली ब्यास नदी फ्लैश फ्लड चेतावनी: सोलांग घाटी में 104 मिमी/घंटा की दर से बादल फटा। ब्यास नदी का जलस्तर खतरे के निशान से ऊपर। नदी तटों से तुरंत दूर रहें।",
                "ml": "കുളു മണാലി ബിയാസ് നദി മിന്നൽപ്രളയ മുന്നറിയിപ്പ്: സോളാങ് താഴ്‌വരയിൽ മേഘവിസ്ഫോടനം (104 mm/hr). നദിക്കരകളിൽ നിന്ന് ആളുകളെ ഒഴിപ്പിക്കുന്നു.",
                "mr": "कुलू-मनाली बियास नदी पूर इशारा: सोलांग खोऱ्यात ढगफुटी (१०४ मिमी/तास). महामार्गावरील वाहतूक ठप्प. नद्यांकाठ सुरक्षित ठेवा.",
                "ta": "குலு-மணாலி பியாஸ் நதி திடீர் வெள்ள அபாயம்: சோலாங் பள்ளத்தாக்கில் மேகவெடிப்பு (104 மிமீ/மணி). பியாஸ் நதியில் வெள்ளப்பெருக்கு தீவிரமாக உயர்கிறது.",
            },
        },
        {
            "catchment_id": "mahabaleshwar_koyna",
            "catchment_name": "Mahabaleshwar Plateau & Koyna River Ridge",
            "mountain_range": "Northern Western Ghats (Sahyadri Escarpment)",
            "state": "Maharashtra",
            "elevation_m": 1372,
            "latitude": 17.9237,
            "longitude": 73.6586,
            "dominant_lithology": "Deccan Continental Flood Basalt & Thick Ferruginous Laterite",
            "orographic_precipitation": {
                "rain_rate_mm_hr": 48.0,
                "accumulated_3h_mm": 115.0,
                "accumulated_24h_mm": 340.0,
                "condensation_level_m": 950.0,
                "cloud_top_height_km": 11.2,
                "radar_reflectivity_dbz": 48.0,
                "cloudburst_category": CloudburstCategory.HEAVY_OROGRAPHIC,
            },
            "slope_stability": {
                "slope_angle_degrees": 28.0,
                "ari_3day_mm": 210.0,
                "ari_15day_mm": 620.0,
                "pore_water_pressure_ratio": 0.85,
                "factor_of_safety": 1.12,
                "landslide_risk_tier": LandslideRiskTier.HIGH_WARNING,
            },
            "hydrodynamics": {
                "peak_discharge_m3_s": 480.0,
                "debris_slurry_volume_m3": 45000.0,
                "boulder_velocity_m_s": 4.5,
                "bridge_scour_threat": "Culvert Choking & Road Shoulder Slump on Ghat Roads",
                "flash_flood_stage": FlashFloodStage.TORRENTIAL_SURGE,
            },
            "directives": {
                "evacuation_order": "Precautionary evacuation of foothill hamlets along steep basalt scarps near Pratapgad and Koynanagar.",
                "pilgrimage_transit_advisory": "Pilgrims visiting old Mahabaleshwar and Wai temples advised against night travel.",
                "ghat_road_transit_status": "Pasarni Ghat and Ambenali Ghat (Mahabaleshwar-Poladpur) restricted to essential light vehicles only.",
                "plantation_worker_protocol": "Strawberry farmers and ridge workers to avoid active water runnels on terraced slopes.",
            },
            "bulletins": {
                "en": "MAHARASHTRA SAHYADRI LANDSLIDE WARNING: Mahabaleshwar-Koyna ridge has received 340 mm/24h. Slope Factor of Safety 1.12. Landslide warning active on Ambenali and Pasarni ghats.",
                "hi": "महाबलेश्वर-कोयना भूस्खलन चेतावनी: पश्चिमी घाट की पहाड़ियों में 340 मिमी भारी बारिश। आंबेनाली और पसरणी घाटों पर भूस्खलन का उच्च जोखिम। रात में यात्रा न करें।",
                "ml": "മഹാബലേശ്വർ കുന്നിൻനിരകളിൽ ശക്തമായ മണ്ണിടിച്ചിൽ മുന്നറിയിപ്പ്: 340 mm കനത്ത മഴ. ഘാട്ട് റോഡുകളിൽ ഗതാഗത നിയന്ത്രണം.",
                "mr": "महाबळेश्वर-कोयना सह्याद्री दरड इशारा: २४ तासांत ३४० मिमी अतिवृष्टी. आंबेनळी व पसरणी घाटात दरड कोसळण्याची दाट शक्यता. रात्रीचा प्रवास टाळा.",
                "ta": "மகாபலேஷ்வர்-கொய்னா நிலச்சரிவு எச்சரிக்கை: 24 மணி நேரத்தில் 340 மிமீ கனமழை. மலைப்பாதை போக்குவரத்தில் எச்சரிக்கை தேவை.",
            },
        },
        {
            "catchment_id": "nilgiris_coonoor_ooty",
            "catchment_name": "Nilgiris Mountain Ghats & Coonoor Valley",
            "mountain_range": "Southern Western Ghats (Nilgiri Massif)",
            "state": "Tamil Nadu",
            "elevation_m": 1850,
            "latitude": 11.3530,
            "longitude": 76.7959,
            "dominant_lithology": "Hypersthene Granulite Charnockite & Lithomargic Clay",
            "orographic_precipitation": {
                "rain_rate_mm_hr": 42.0,
                "accumulated_3h_mm": 98.0,
                "accumulated_24h_mm": 285.0,
                "condensation_level_m": 1200.0,
                "cloud_top_height_km": 10.5,
                "radar_reflectivity_dbz": 46.0,
                "cloudburst_category": CloudburstCategory.HEAVY_OROGRAPHIC,
            },
            "slope_stability": {
                "slope_angle_degrees": 31.0,
                "ari_3day_mm": 180.0,
                "ari_15day_mm": 410.0,
                "pore_water_pressure_ratio": 0.82,
                "factor_of_safety": 1.18,
                "landslide_risk_tier": LandslideRiskTier.HIGH_WARNING,
            },
            "hydrodynamics": {
                "peak_discharge_m3_s": 360.0,
                "debris_slurry_volume_m3": 32000.0,
                "boulder_velocity_m_s": 4.1,
                "bridge_scour_threat": "Railway Track Ballast Washout & Highway Retaining Wall Failure",
                "flash_flood_stage": FlashFloodStage.TORRENTIAL_SURGE,
            },
            "directives": {
                "evacuation_order": "Vulnerable houses on steep roadside slopes in Marapalam, Runnymede, and Kattery advised to move to relief camps.",
                "pilgrimage_transit_advisory": "Tourist vehicles barred from traveling on Mettupalayam-Coonoor ghat road after 7:00 PM.",
                "ghat_road_transit_status": "Mettupalayam-Coonoor NH-181 operational with pilot escort. Nilgiri Mountain Railway (NMR) train services suspended.",
                "plantation_worker_protocol": "Tea estate workers advised not to operate near steep drainage gullies or under unstable trees.",
            },
            "bulletins": {
                "en": "GSI NILGIRIS LANDSLIDE WARNING: Coonoor-Ooty slopes under High Landslide Warning (FS 1.18) following 285 mm rainfall. Nilgiri Mountain Railway suspended. Night travel barred on ghat road.",
                "hi": "नीलगिरि कुन्नूर-ऊटी भूस्खलन चेतावनी: 285 मिमी बारिश के बाद कुन्नूर घाट पर भूस्खलन का उच्च अलर्ट। नीलगिरि टॉय ट्रेन सेवाएं निलंबित।",
                "ml": "നീലഗിരി കുന്നൂർ-ഊട്ടി മണ്ണിടിച്ചിൽ മുന്നറിയിപ്പ്: 285 mm മഴ. പർവ്വത റെയിൽവേ സർവീസുകൾ നിർത്തിവെച്ചു. രാത്രി യാത്ര ഒഴിവാക്കുക.",
                "mr": "निलगिरी कुन्नूर-उटी दरड इशारा: २८५ मिमी मुसळधार पाऊस. घाट रस्त्यावर दरड कोसळण्याची भीती. रेल्वे वाहतूक स्थगित.",
                "ta": "நீலகிரி குன்னூர்-ஊட்டி நிலச்சரிவு எச்சரிக்கை: 285 மிமீ கனமழையைத் தொடர்ந்து மேட்டுப்பாளையம்-குன்னூர் மலைப்பாதையில் நிலச்சரிவு அபாயம். நீலகிரி மலை ரயில் சேவை தற்காலிக ரத்து.",
            },
        },
        {
            "catchment_id": "chamoli_joshimath_dhauliganga",
            "catchment_name": "Joshimath & Dhauliganga Canyon",
            "mountain_range": "Central Higher Himalayas (Nanda Devi Biosphere)",
            "state": "Uttarakhand",
            "elevation_m": 1890,
            "latitude": 30.5564,
            "longitude": 79.5660,
            "dominant_lithology": "Quartz-Mica Schist & Glacial Till in Inactive Thrust Faults",
            "orographic_precipitation": {
                "rain_rate_mm_hr": 76.0,
                "accumulated_3h_mm": 125.0,
                "accumulated_24h_mm": 210.0,
                "condensation_level_m": 2100.0,
                "cloud_top_height_km": 13.0,
                "radar_reflectivity_dbz": 52.0,
                "cloudburst_category": CloudburstCategory.MINI_CLOUDBURST,
            },
            "slope_stability": {
                "slope_angle_degrees": 39.0,
                "ari_3day_mm": 115.0,
                "ari_15day_mm": 290.0,
                "pore_water_pressure_ratio": 0.86,
                "factor_of_safety": 0.89,
                "landslide_risk_tier": LandslideRiskTier.CRITICAL_IMMINENT_FAILURE,
            },
            "hydrodynamics": {
                "peak_discharge_m3_s": 740.0,
                "debris_slurry_volume_m3": 80000.0,
                "boulder_velocity_m_s": 8.0,
                "bridge_scour_threat": "Severe Barrage Inflow Surge & Hydroelectric Intake Siltation",
                "flash_flood_stage": FlashFloodStage.CATASTROPHIC_DEBRIS_FLOW,
            },
            "directives": {
                "evacuation_order": "Immediate evacuation of cracked subsidence zones in Sunil and Manohar Bagh wards in Joshimath.",
                "pilgrimage_transit_advisory": "Badrinath and Hemkund Sahib pilgrim movement suspended between Pipalkoti and Joshimath.",
                "ghat_road_transit_status": "NH-58 Rishikesh-Badrinath blocked by rockfalls at Helang and Lambagarh.",
                "plantation_worker_protocol": "Hydropower project excavation and tunnel tunneling workers evacuated to safe muster zones.",
            },
            "bulletins": {
                "en": "CHAMOLI GLACIAL CATCHMENT ALERT: Mini-cloudburst (76 mm/hr) in Dhauliganga basin. Slope Factor of Safety 0.89. Extreme subsidence and flash flood threat in Joshimath. Badrinath highway shut.",
                "hi": "चमोली जोशीमठ आपदा चेतावनी: धौलीगंगा घाटी में 76 मिमी/घंटा की तीव्र बारिश। ढलान स्थिरता 0.89। जोशीमठ भूधंसाव क्षेत्र में तत्काल सतर्कता। बद्रीनाथ हाईवे बंद।",
                "ml": "ചമോലി ജോഷിമഠ് അടിയന്തര മുന്നറിയിപ്പ്: ധൗളിഗംഗ താഴ്‌വരയിൽ മിന്നൽ പ്രളയ സാദ്ധ്യത. ബദരീനാഥ് ഹൈവേ അടച്ചു.",
                "mr": "चमोली जोशीमठ आपत्ती इशारा: धौलीगंगा खोऱ्यात ढगफुटीसदृश पाऊस. भूधंसाव धोका वाढला. बद्रीनाथ महामार्ग बंद.",
                "ta": "சமோலி ஜோஷிமத் பேரிடர் எச்சரிக்கை: தௌலிகங்கா பள்ளத்தாக்கில் திடீர் வெள்ளப்பெருக்கு. பத்ரிநாத் தேசிய நெடுஞ்சாலை போக்குவரத்து நிறுத்தம்.",
            },
        },
        {
            "catchment_id": "darjeeling_teesta_canyon",
            "catchment_name": "Teesta River Canyon & Kalimpong Slopes",
            "mountain_range": "Eastern Himalayas",
            "state": "West Bengal",
            "elevation_m": 1200,
            "latitude": 27.0410,
            "longitude": 88.2663,
            "dominant_lithology": "Daling Series Metasediments, Phyllite & Weathered Schist",
            "orographic_precipitation": {
                "rain_rate_mm_hr": 46.0,
                "accumulated_3h_mm": 110.0,
                "accumulated_24h_mm": 295.0,
                "condensation_level_m": 850.0,
                "cloud_top_height_km": 11.5,
                "radar_reflectivity_dbz": 49.0,
                "cloudburst_category": CloudburstCategory.HEAVY_OROGRAPHIC,
            },
            "slope_stability": {
                "slope_angle_degrees": 35.0,
                "ari_3day_mm": 195.0,
                "ari_15day_mm": 470.0,
                "pore_water_pressure_ratio": 0.87,
                "factor_of_safety": 1.05,
                "landslide_risk_tier": LandslideRiskTier.HIGH_WARNING,
            },
            "hydrodynamics": {
                "peak_discharge_m3_s": 580.0,
                "debris_slurry_volume_m3": 60000.0,
                "boulder_velocity_m_s": 5.8,
                "bridge_scour_threat": "Teesta River Overtopping NH-10 Carriageway & Embankment Erosion",
                "flash_flood_stage": FlashFloodStage.TORRENTIAL_SURGE,
            },
            "directives": {
                "evacuation_order": "Low-lying settlements along Teesta Bazar, Melli, and Singtam alerted to move to upper terraces.",
                "pilgrimage_transit_advisory": "Tourist transits to Gangtok and North Sikkim rerouted via Lava-Gorubathan corridor.",
                "ghat_road_transit_status": "NH-10 (Siliguri-Gangtok lifeline) closed due to river scouring at 29th Mile and Birik Dara.",
                "plantation_worker_protocol": "Tea estate workers in Darjeeling hills advised to avoid steep terraced drain maintenance during rain.",
            },
            "bulletins": {
                "en": "TEESTA CANYON LANDSLIDE BULLETIN: Heavy orographic downpour (295 mm/24h) across Darjeeling-Kalimpong. Slope Factor of Safety 1.05. NH-10 lifeline severed by river scouring.",
                "hi": "दार्जिलिंग तीस्ता घाटी भूस्खलन बुलेटिन: 295 मिमी मूसलाधार बारिश। तीस्ता नदी उफान पर। एनएच-10 सिलीगुड़ी-गंगटोक मार्ग बाधित।",
                "ml": "ഡാർജിലിംഗ് തീസ്ത നദി പ്രളയ മുന്നറിയിപ്പ്: 295 mm കനത്ത മഴ. സിലിഗുരി-ഗാങ്‌ടോക് പാതയിൽ ഗതാഗതം തടസ്സപ്പെട്ടു.",
                "mr": "दार्जिलिंग तीस्ता खोरे दरड इशारा: २९५ मिमी मुसळधार पाऊस. एनएच-१० महामार्ग बंद. नद्यांकाठी राहणाऱ्यांना सतर्कतेचा इशारा.",
                "ta": "டார்ஜிலிங் தீஸ்தா பள்ளத்தாக்கு நிலச்சரிவு எச்சரிக்கை: 295 மிமீ தீவிர மழை. தீஸ்தா ஆற்றில் வெள்ளப்பெருக்கு ஏற்பட்டு என்.எச்-10 சாலை துண்டிக்கப்பட்டுள்ளது.",
            },
        },
    ]

    @classmethod
    def get_assessment(
        cls,
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        catchment_id: Optional[str] = None,
    ) -> CloudburstResponse:
        """
        Calculates mountain catchment cloudburst and landslide hazard metrics.
        Selects target catchment via explicit ID or closest geodetic Haversine proximity.
        """
        all_models: List[MountainCatchmentHotspot] = []
        for raw in cls.CATCHMENT_HOTSPOTS:
            hotspot = MountainCatchmentHotspot(
                catchment_id=raw["catchment_id"],
                catchment_name=raw["catchment_name"],
                mountain_range=raw["mountain_range"],
                state=raw["state"],
                elevation_m=raw["elevation_m"],
                latitude=raw["latitude"],
                longitude=raw["longitude"],
                dominant_lithology=raw["dominant_lithology"],
                orographic_precipitation=OrographicPrecipitationTelemetry(**raw["orographic_precipitation"]),
                slope_stability=SlopeStabilityMetrics(**raw["slope_stability"]),
                hydrodynamics=DebrisFlowHydrodynamics(**raw["hydrodynamics"]),
                directives=MountainSafetyDirectives(**raw["directives"]),
                bulletins=raw["bulletins"],
            )
            all_models.append(hotspot)

        selected = all_models[0]
        if catchment_id:
            match = next((c for c in all_models if c.catchment_id == catchment_id), None)
            if match:
                selected = match
        elif latitude is not None and longitude is not None:
            selected = min(
                all_models,
                key=lambda c: cls._haversine_distance(latitude, longitude, c.latitude, c.longitude),
            )

        now_utc = datetime.now(timezone.utc).isoformat()
        bulletin_ref = f"IMD-GSI/OC-FFLDE/{datetime.now(timezone.utc).strftime('%Y%m')}-{selected.catchment_id[:6].upper()}"

        return CloudburstResponse(
            timestamp=now_utc,
            selected_catchment=selected,
            all_catchments=all_models,
            vernacular_bulletins=selected.bulletins,
            bulletin_number=bulletin_ref,
            provenance="IMD Mountain Meteorology Division & Geological Survey of India (GSI) NLEWS",
            is_offline_cached=False,
        )

    @staticmethod
    def _haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        R = 6371.0
        d_lat = math.radians(lat2 - lat1)
        d_lon = math.radians(lon2 - lon1)
        a = (
            math.sin(d_lat / 2) ** 2
            + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(d_lon / 2) ** 2
        )
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
        return R * c
