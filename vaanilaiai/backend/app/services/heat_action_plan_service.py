import math
from datetime import datetime, timezone
from typing import List, Dict, Optional

from app.schemas.heat_action_plan import (
    HapTriggerAlertTier,
    UvIndexCategory,
    HeatwaveThermalMetrics,
    SolarUvRadiationMetrics,
    MunicipalHeatDirectives,
    HeatActionHotspotZone,
    HeatActionPlanResponse,
)


class HeatActionPlanService:
    """
    National Disaster Management Authority (NDMA) & IMD National Heat Action Plan (HAP) Service.
    Municipal color-coded triggers, solar ultraviolet radiation photobiology, cool roof metrics,
    and occupational labor safety protocols across India's extreme heatwave corridors.
    """

    HEAT_ZONES: List[Dict] = [
        {
            "zone_id": "phalodi_churu_thar",
            "zone_name": "Phalodi & Churu Arid Desert Corridor",
            "state": "Rajasthan",
            "district": "Phalodi / Churu",
            "latitude": 27.1300,
            "longitude": 72.3600,
            "alert_tier": HapTriggerAlertTier.EXTREME_HEAT_RED,
            "thermal_metrics": {
                "max_temp_c": 49.8,
                "normal_temp_c": 42.0,
                "departure_c": 7.8,
                "consecutive_heatwave_days": 6,
                "relative_humidity_pct": 18.0,
                "wet_bulb_temp_c": 26.5,
                "night_min_temp_c": 34.2,
            },
            "uv_metrics": {
                "uv_index": 13.5,
                "uv_category": UvIndexCategory.EXTREME,
                "peak_uv_hour": "11:30 - 15:30",
                "ozone_column_du": 260.0,
                "minimal_erythemal_dose_rate_med_hr": 3.2,
                "time_to_sunburn_minutes": 12,
                "recommended_spf": 50,
            },
            "municipal_directives": {
                "cool_roof_initiative_active": True,
                "solar_reflectance_index_sri": 82.0,
                "bocw_labor_work_suspension_hours": "11:00 - 16:00 (Mandatory Afternoon Halt)",
                "active_pyau_water_stations": 185,
                "hospital_heatstroke_beds": 45,
                "emergency_cooling_ice_bath_ready": True,
                "ors_distribution_booths": 92,
            },
            "vulnerable_demographics": [
                "Agricultural farm laborers & pastoralists",
                "Brick kiln and salt pan workers",
                "Elderly rural residents without active cooling",
            ],
            "localized_bulletins": {
                "en": "RED ALERT: Severe Heatwave conditions across Phalodi & Churu (49.8°C, +7.8°C departure). Extreme Solar UV Index 13.5 with 12-minute sunburn risk. Mandatory labor halt between 11:00 and 16:00; hospital ice baths on full readiness.",
                "hi": "रेड अलर्ट: फलोदी और चुरू में भीषण लू (हीटवेव) का प्रकोप (49.8°C, सामान्य से +7.8°C अधिक)। अत्यधिक पराबैंगनी सूचकांक (UV 13.5)। दोपहर 11 से 4 बजे तक खुले में शारीरिक श्रम प्रतिबंधित।",
                "gu": "રેડ એલર્ટ: ફલોદી અને ચુરુમાં અતિ ગંભીર હીટવેવ (49.8°C). બપોરે 11 થી 4 વાગ્યા સુધી મજૂરી કાર્ય બંધ રાખવું અને ઓઆરએસ કેન્દ્રો પરથી પુષ્કળ પાણી પીવું.",
                "te": "రెడ్ అలర్ట్: ఫలోది మరియు చురూలో తీవ్ర వడగాల్పులు (49.8°C). మధ్యాహ్నం 11 నుండి సాయంత్రం 4 వరకు కార్మికులు ఎండలో పని చేయరాదు.",
                "or": "ରେଡ୍ ଆଲର୍ଟ: ଫାଲୋଦି ଏବଂ ଚୁରୁରେ ଭୟଙ୍କର ଅଂଶୁଘାତ ପରିସ୍ଥିତି (୪୯.୮°C)। ୧୧ଟାରୁ ୪ଟା ପର୍ଯ୍ୟନ୍ତ କାର୍ଯ୍ୟ ବନ୍ଦ ରଖିବାକୁ ନିର୍ଦ୍ଦେଶ।",
            },
        },
        {
            "zone_id": "ahmedabad_metropolitan",
            "zone_name": "Ahmedabad Municipal Corporation (AMC Heat Action Plan)",
            "state": "Gujarat",
            "district": "Ahmedabad",
            "latitude": 23.0225,
            "longitude": 72.5714,
            "alert_tier": HapTriggerAlertTier.SEVERE_HEAT_ALERT_ORANGE,
            "thermal_metrics": {
                "max_temp_c": 44.2,
                "normal_temp_c": 40.5,
                "departure_c": 3.7,
                "consecutive_heatwave_days": 4,
                "relative_humidity_pct": 32.0,
                "wet_bulb_temp_c": 28.1,
                "night_min_temp_c": 30.5,
            },
            "uv_metrics": {
                "uv_index": 11.8,
                "uv_category": UvIndexCategory.EXTREME,
                "peak_uv_hour": "12:00 - 15:00",
                "ozone_column_du": 268.0,
                "minimal_erythemal_dose_rate_med_hr": 2.8,
                "time_to_sunburn_minutes": 15,
                "recommended_spf": 50,
            },
            "municipal_directives": {
                "cool_roof_initiative_active": True,
                "solar_reflectance_index_sri": 80.0,
                "bocw_labor_work_suspension_hours": "12:00 - 15:30 (Mandatory Shift Rescheduling)",
                "active_pyau_water_stations": 420,
                "hospital_heatstroke_beds": 110,
                "emergency_cooling_ice_bath_ready": True,
                "ors_distribution_booths": 280,
            },
            "vulnerable_demographics": [
                "Slum dwellers under corrugated tin roofs",
                "BRTS & traffic police personnel",
                "Construction and road paving workers",
            ],
            "localized_bulletins": {
                "en": "ORANGE ALERT: AMC Heat Action Plan Orange Trigger active for Ahmedabad (44.2°C). Cool roof initiatives deployed across 15,000 households. Construction suspended 12:00-15:30; visit public cooling centers.",
                "gu": "ઓરેન્જ એલર્ટ: અમદાવાદ મ્યુનિસિપલ કોર્પોરેશન હીટ એક્શન પ્લાન ઓરેન્જ ટ્રીગર સક્રિય (44.2°C). 12 થી 3:30 દરમિયાન બાંધકામ મજૂરી પર પ્રતિબંધ; પુષ્કળ છાશ અને ઓઆરએસનું સેવન કરવું.",
                "hi": "ऑरेंज अलर्ट: अहमदाबाद में हीट एक्शन प्लान का ऑरेंज ट्रिगर सक्रिय (44.2°C)। दोपहर 12 से 3:30 तक निर्माण कार्य स्थगित; नगर निगम प्याऊ और कूलिंग सेंटर खुले हैं।",
                "te": "ఆరెంజ్ అలర్ట్: అహ్మదాబాద్‌లో తీవ్ర వేడి గాలులు (44.2°C). మధ్యాహ్నం 12 నుండి 3:30 వరకు పనులు నిలిపివేయాలి.",
                "or": "ଅରେଞ୍ଜ ଆଲର୍ଟ: ଅହମ୍ମଦାବାଦ ମହାନଗର ନିଗମ ହିଟ୍ ଆକ୍ସନ ପ୍ଲାନ ସକ୍ରିୟ (୪୪.୨°C)। ଖରାରୁ ରକ୍ଷା ପାଇଁ ପର୍ଯ୍ୟାପ୍ତ ପାଣି ପିଅନ୍ତୁ।",
            },
        },
        {
            "zone_id": "titlagarh_jharsuguda_belt",
            "zone_name": "Titlagarh, Bolangir & Jharsuguda Mining Belt",
            "state": "Odisha",
            "district": "Bolangir / Jharsuguda",
            "latitude": 20.3000,
            "longitude": 83.1500,
            "alert_tier": HapTriggerAlertTier.EXTREME_HEAT_RED,
            "thermal_metrics": {
                "max_temp_c": 47.5,
                "normal_temp_c": 40.8,
                "departure_c": 6.7,
                "consecutive_heatwave_days": 5,
                "relative_humidity_pct": 28.0,
                "wet_bulb_temp_c": 28.6,
                "night_min_temp_c": 32.0,
            },
            "uv_metrics": {
                "uv_index": 12.6,
                "uv_category": UvIndexCategory.EXTREME,
                "peak_uv_hour": "11:45 - 15:15",
                "ozone_column_du": 264.0,
                "minimal_erythemal_dose_rate_med_hr": 3.0,
                "time_to_sunburn_minutes": 14,
                "recommended_spf": 50,
            },
            "municipal_directives": {
                "cool_roof_initiative_active": True,
                "solar_reflectance_index_sri": 78.0,
                "bocw_labor_work_suspension_hours": "11:00 - 15:30 (MCL Open-Cast Mines & Construction)",
                "active_pyau_water_stations": 240,
                "hospital_heatstroke_beds": 65,
                "emergency_cooling_ice_bath_ready": True,
                "ors_distribution_booths": 160,
            },
            "vulnerable_demographics": [
                "Open-cast coal and iron ore miners",
                "Rural weekly market vendors (Hats)",
                "Pregnant women and infants in non-electrified hamlets",
            ],
            "localized_bulletins": {
                "en": "RED ALERT: Critical Heatwave in Western Odisha mining belt (Titlagarh 47.5°C). Extreme UV Index 12.6. Mandatory daytime mining shift suspension; Jal Chhatras and hospital cold wards operational.",
                "or": "ଜରୁରୀ ରେଡ୍ ଆଲର୍ଟ: ପଶ୍ଚିମ ଓଡ଼ିଶାର ଟିଟିଲାଗଡ଼ ଏବଂ ଝାରସୁଗୁଡ଼ାରେ ଭୟଙ୍କର ଅଂଶୁଘାତ (୪୭.୫°C)। ଦିନ ୧୧ଟାରୁ ୩:୩୦ ପର୍ଯ୍ୟନ୍ତ ଶ୍ରମିକଙ୍କ କାର୍ଯ୍ୟ ବନ୍ଦ ରହିବ; ଜଳଛତ୍ର ଓ ସିଏଚସିରେ ବରଫ ଚିକିତ୍ସା ବ୍ୟବସ୍ଥା କରାଯାଇଛି।",
                "hi": "रेड अलर्ट: पश्चिमी ओडिशा के टिटलागढ़-झारसुगुड़ा में भीषण लू (47.5°C)। खदानों में दिन के काम पर रोक; जल छत्रों और ओआरएस केंद्रों की व्यवस्था सक्रिय।",
                "te": "రెడ్ అలర్ట్: పశ్చిమ ఒడిశా గనుల ప్రాంతంలో తీవ్ర వడగాల్పులు (47.5°C). మధ్యాహ్న సమయాల్లో పనులను పూర్తిగా నిలిపివేయాలి.",
                "gu": "રેડ એલર્ટ: પશ્ચિમ ઓડિશા ટિટલાગઢમાં ભયાનક હીટવેવ (47.5°C). 11 થી 3:30 દરમિયાન ખુલ્લી ખાણોમાં કામ બંધ.",
            },
        },
        {
            "zone_id": "nagpur_chandrapur_vidarbha",
            "zone_name": "Nagpur & Chandrapur Thermal Corridor (Vidarbha)",
            "state": "Maharashtra",
            "district": "Nagpur / Chandrapur",
            "latitude": 21.1458,
            "longitude": 79.0882,
            "alert_tier": HapTriggerAlertTier.SEVERE_HEAT_ALERT_ORANGE,
            "thermal_metrics": {
                "max_temp_c": 45.4,
                "normal_temp_c": 41.2,
                "departure_c": 4.2,
                "consecutive_heatwave_days": 4,
                "relative_humidity_pct": 24.0,
                "wet_bulb_temp_c": 27.2,
                "night_min_temp_c": 31.8,
            },
            "uv_metrics": {
                "uv_index": 12.0,
                "uv_category": UvIndexCategory.EXTREME,
                "peak_uv_hour": "12:00 - 15:00",
                "ozone_column_du": 265.0,
                "minimal_erythemal_dose_rate_med_hr": 2.9,
                "time_to_sunburn_minutes": 15,
                "recommended_spf": 50,
            },
            "municipal_directives": {
                "cool_roof_initiative_active": True,
                "solar_reflectance_index_sri": 79.0,
                "bocw_labor_work_suspension_hours": "12:00 - 15:30 (Industrial & Construction Labor)",
                "active_pyau_water_stations": 310,
                "hospital_heatstroke_beds": 80,
                "emergency_cooling_ice_bath_ready": True,
                "ors_distribution_booths": 210,
            },
            "vulnerable_demographics": [
                "Thermal power plant and coal corridor workforce",
                "Cotton farmers in rainfed tracts",
                "Auto-rickshaw and cycle rickshaw operators",
            ],
            "localized_bulletins": {
                "en": "ORANGE ALERT: Severe Heatwave conditions across Vidarbha (Nagpur 45.4°C). Extreme UV Index 12.0. Municipal public gardens open for shade; hospital heat wards on high alert.",
                "hi": "ऑरेंज अलर्ट: विदर्भ के नागपुर-चंद्रपुर में तीव्र लू का प्रकोप (45.4°C)। दोपहर में पार्कों को छाया के लिए खुला रखा गया है; निर्माण कार्य 12 से 3:30 तक स्थगित।",
                "gu": "ઓરેન્જ એલર્ટ: વિદર્ભના નાગપુરમાં હીટવેવ (45.4°C). બપોરે બગીચાઓ લોકો માટે ખુલ્લા રાખવામાં આવ્યા છે.",
                "te": "ఆరెంజ్ అలర్ట్: విదర్భ నాగ్‌పూర్‌లో తీవ్ర వడగాల్పులు (45.4°C). ప్రజలు నీడగల ప్రదేశాలలో ఉండాలి.",
                "or": "ଅରେଞ୍ଜ ଆଲର୍ଟ: ବିଦର୍ଭ ନାଗପୁରରେ ପ୍ରଚଣ୍ଡ ତାତି (୪୫.୪°C)। ଡାକ୍ତରଖାନା ଗୁଡ଼ିକରେ ସ୍ୱତନ୍ତ୍ର ୱାର୍ଡ ଖୋଲାଯାଇଛି।",
            },
        },
        {
            "zone_id": "ramagundam_hyderabad_deccan",
            "zone_name": "Ramagundam & Hyderabad Heat Corridor (Telangana)",
            "state": "Telangana",
            "district": "Peddapalli / Hyderabad",
            "latitude": 18.7600,
            "longitude": 79.4800,
            "alert_tier": HapTriggerAlertTier.SEVERE_HEAT_ALERT_ORANGE,
            "thermal_metrics": {
                "max_temp_c": 44.8,
                "normal_temp_c": 40.6,
                "departure_c": 4.2,
                "consecutive_heatwave_days": 3,
                "relative_humidity_pct": 30.0,
                "wet_bulb_temp_c": 27.8,
                "night_min_temp_c": 30.2,
            },
            "uv_metrics": {
                "uv_index": 12.4,
                "uv_category": UvIndexCategory.EXTREME,
                "peak_uv_hour": "11:45 - 15:15",
                "ozone_column_du": 262.0,
                "minimal_erythemal_dose_rate_med_hr": 3.0,
                "time_to_sunburn_minutes": 14,
                "recommended_spf": 50,
            },
            "municipal_directives": {
                "cool_roof_initiative_active": True,
                "solar_reflectance_index_sri": 81.0,
                "bocw_labor_work_suspension_hours": "11:30 - 15:30 (Telangana Heatwave Action Plan)",
                "active_pyau_water_stations": 290,
                "hospital_heatstroke_beds": 70,
                "emergency_cooling_ice_bath_ready": True,
                "ors_distribution_booths": 195,
            },
            "vulnerable_demographics": [
                "SCCL coal miners and NTPC industrial belt workers",
                "Swiggy/Zomato delivery gig workers",
                "Chilli and cotton agricultural laborers",
            ],
            "localized_bulletins": {
                "en": "ORANGE ALERT: Telangana Heatwave Plan Orange Alert for Ramagundam & Hyderabad (44.8°C). Chalivendram water kiosks activated across transit junctions; avoid direct midday sun.",
                "te": "ఆరెంజ్ అలర్ట్: రామగుండం మరియు హైదరాబాద్‌లో తీవ్ర వడగాల్పుల హెచ్చరిక (44.8°C). చలివేంద్రాల ద్వారా ఉచిత మంచినీరు, ఓఆర్ఎస్ పంపిణీ చేయబడుతోంది. 11:30 నుండి 3:30 వరకు పనులను ఆపాలి.",
                "hi": "ऑरेंज अलर्ट: तेलंगाना के रामागुंडम और हैदराबाद में भीषण गर्मी (44.8°C)। चलिवेंद्रम (प्याऊ) सक्रिय; दोपहर के समय सीधी धूप से बचें।",
                "gu": "ઓરેન્જ એલર્ટ: તેલંગાણાના રામાગુંડમમાં ગરમીનું મોજું (44.8°C). બપોરના સમયે સીધા સૂર્યપ્રકાશથી બચવું.",
                "or": "ଅରେଞ୍ଜ ଆଲର୍ଟ: ରାମାଗୁଣ୍ଡମ ଏବଂ ହାଇଦ୍ରାବାଦରେ ପ୍ରଚଣ୍ଡ ଗ୍ରୀଷ୍ମ ପ୍ରବାହ (୪୪.୮°C)।",
            },
        },
        {
            "zone_id": "delhi_ncr_urban_heat_island",
            "zone_name": "Delhi-NCR & Gurgaon Megacity Urban Heat Island",
            "state": "Delhi / Haryana",
            "district": "New Delhi / Gurugram",
            "latitude": 28.6139,
            "longitude": 77.2090,
            "alert_tier": HapTriggerAlertTier.EXTREME_HEAT_RED,
            "thermal_metrics": {
                "max_temp_c": 46.8,
                "normal_temp_c": 40.2,
                "departure_c": 6.6,
                "consecutive_heatwave_days": 5,
                "relative_humidity_pct": 35.0,
                "wet_bulb_temp_c": 30.2,
                "night_min_temp_c": 33.6,
            },
            "uv_metrics": {
                "uv_index": 11.5,
                "uv_category": UvIndexCategory.EXTREME,
                "peak_uv_hour": "12:00 - 15:00",
                "ozone_column_du": 272.0,
                "minimal_erythemal_dose_rate_med_hr": 2.7,
                "time_to_sunburn_minutes": 16,
                "recommended_spf": 50,
            },
            "municipal_directives": {
                "cool_roof_initiative_active": True,
                "solar_reflectance_index_sri": 78.0,
                "bocw_labor_work_suspension_hours": "12:00 - 16:00 (DDMA Red Alert Enforced)",
                "active_pyau_water_stations": 520,
                "hospital_heatstroke_beds": 150,
                "emergency_cooling_ice_bath_ready": True,
                "ors_distribution_booths": 340,
            },
            "vulnerable_demographics": [
                "Megacity asphalt and concrete urban heat island residents",
                "Street vendors, daily-wage construction laborers",
                "Schoolchildren and public bus commuters",
            ],
            "localized_bulletins": {
                "en": "RED ALERT: Extreme Heatwave & Deadly Humid Heat in Delhi-NCR (46.8°C, Wet-bulb 30.2°C). High night minimum (33.6°C) impairs thermal recovery. DDMA orders outdoor construction halt 12:00-16:00; misting trucks deployed.",
                "hi": "रेड अलर्ट: दिल्ली-एनसीआर में भीषण लू और आद्र गर्मी का जानलेवा प्रकोप (46.8°C, वेट-बल्ब 30.2°C)। रात का तापमान भी 33.6°C तक ऊंचा। दोपहर 12 से 4 बजे तक निर्माण कार्य पूर्णतः बंद; पानी के छिड़काव वाले टैंकर तैनात।",
                "gu": "રેડ એલર્ટ: દિલ્હી-એનસીઆરમાં અતિ ગંભીર હીટવેવ (46.8°C). રાત્રિનું ઊંચું તાપમાન શરીરને આરામ મળવા દેતું નથી. બપોરે બહાર નીકળવાનું ટાળો.",
                "te": "రెడ్ అలర్ట్: ఢిల్లీ-ఎన్‌సీఆర్‌లో భయంకరమైన ఎండలు (46.8°C). ఉక్కపోతతో కూడిన వేడి తీవ్ర ముప్పు కలిగిస్తోంది. మధ్యాహ్నం 12 నుండి 4 వరకు పనులు ఆపాలి.",
                "or": "ରେଡ୍ ଆଲର୍ଟ: ଦିଲ୍ଲୀ-ଏନସିଆରରେ ଭୟଙ୍କର ଗ୍ରୀଷ୍ମ ଲହରୀ (୪୬.୮°C)। ଦିନ ୧୨ଟାରୁ ୪ଟା ଯାଏଁ ନିର୍ମାଣ କାର୍ଯ୍ୟ ବନ୍ଦ ରଖିବାକୁ ଡିଡିଏମଏ ନିର୍ଦ୍ଦେଶ।",
            },
        },
        {
            "zone_id": "banda_prayagraj_bundelkhand",
            "zone_name": "Banda & Prayagraj Rocky Plateau (Bundelkhand)",
            "state": "Uttar Pradesh",
            "district": "Banda / Prayagraj",
            "latitude": 25.4800,
            "longitude": 80.3300,
            "alert_tier": HapTriggerAlertTier.EXTREME_HEAT_RED,
            "thermal_metrics": {
                "max_temp_c": 48.2,
                "normal_temp_c": 41.5,
                "departure_c": 6.7,
                "consecutive_heatwave_days": 6,
                "relative_humidity_pct": 20.0,
                "wet_bulb_temp_c": 27.4,
                "night_min_temp_c": 33.0,
            },
            "uv_metrics": {
                "uv_index": 12.8,
                "uv_category": UvIndexCategory.EXTREME,
                "peak_uv_hour": "11:30 - 15:15",
                "ozone_column_du": 266.0,
                "minimal_erythemal_dose_rate_med_hr": 3.1,
                "time_to_sunburn_minutes": 13,
                "recommended_spf": 50,
            },
            "municipal_directives": {
                "cool_roof_initiative_active": False,
                "solar_reflectance_index_sri": 65.0,
                "bocw_labor_work_suspension_hours": "11:00 - 15:30 (Bundelkhand Drought & Heat Protocol)",
                "active_pyau_water_stations": 160,
                "hospital_heatstroke_beds": 40,
                "emergency_cooling_ice_bath_ready": True,
                "ors_distribution_booths": 120,
            },
            "vulnerable_demographics": [
                "Bundelkhand dryland farmers and pastoral herders",
                "Stone quarry and sand mining laborers",
                "Villagers walking long distances to drinking water wells",
            ],
            "localized_bulletins": {
                "en": "RED ALERT: Extreme Heatwave in Bundelkhand rocky plateau (Banda 48.2°C). High UV Index 12.8. Mobile water tankers dispatched; avoid travel between 11:00 and 15:30.",
                "hi": "रेड अलर्ट: बुंदेलखंड के बांदा-प्रयागराज में भीषण लू का तांडव (48.2°C)। पथरीली भूमि के कारण अत्यधिक विकिरण। दोपहर में यात्रा से बचें और छाछ, आम पना का सेवन करें।",
                "gu": "રેડ એલર્ટ: બુંદેલખંડ બાંદામાં તીવ્ર હીટવેવ (48.2°C). 11 થી 3:30 દરમિયાન મુસાફરી ટાળવી.",
                "te": "రెడ్ అలర్ట్: బుందేల్‌ఖండ్ బందాలో తీవ్ర వడగాల్పులు (48.2°C). మధ్యాహ్నం ప్రయాణాలు వాయిదా వేసుకోవాలి.",
                "or": "ରେଡ୍ ଆଲର୍ଟ: ବୁନ୍ଦେଲଖଣ୍ଡ ବାନ୍ଦାରେ ପ୍ରଚଣ୍ଡ ଅଂଶୁଘାତ (୪୮.୨°C)। ଦିନ ୧୧ଟାରୁ ୩:୩୦ ପର୍ଯ୍ୟନ୍ତ ବାହାରକୁ ନବାହାରିବାକୁ ପରାମର୍ଶ।",
            },
        },
    ]

    @classmethod
    def get_assessment(
        cls,
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        zone_id: Optional[str] = None,
    ) -> HeatActionPlanResponse:
        """
        Retrieves NDMA & IMD National Heat Action Plan (HAP) triggers and Solar UV radiation analytics.
        Selects target heatwave zone via explicit ID or geodetic Haversine proximity.
        """
        all_models: List[HeatActionHotspotZone] = []
        for raw in cls.HEAT_ZONES:
            zone = HeatActionHotspotZone(
                zone_id=raw["zone_id"],
                zone_name=raw["zone_name"],
                state=raw["state"],
                district=raw["district"],
                latitude=raw["latitude"],
                longitude=raw["longitude"],
                alert_tier=raw["alert_tier"],
                thermal_metrics=HeatwaveThermalMetrics(**raw["thermal_metrics"]),
                uv_metrics=SolarUvRadiationMetrics(**raw["uv_metrics"]),
                municipal_directives=MunicipalHeatDirectives(**raw["municipal_directives"]),
                vulnerable_demographics=raw["vulnerable_demographics"],
                localized_bulletins=raw["localized_bulletins"],
            )
            all_models.append(zone)

        selected = all_models[0]
        if zone_id:
            match = next((z for z in all_models if z.zone_id == zone_id), None)
            if match:
                selected = match
        elif latitude is not None and longitude is not None:
            selected = min(
                all_models,
                key=lambda z: cls._haversine_distance(latitude, longitude, z.latitude, z.longitude),
            )

        now_utc = datetime.now(timezone.utc).isoformat()
        bulletin_ref = f"NDMA-IMD/HAP-UVIE/{datetime.now(timezone.utc).strftime('%Y%m')}-{selected.zone_id[:6].upper()}"

        return HeatActionPlanResponse(
            timestamp=now_utc,
            bulletin_number=bulletin_ref,
            provenance="National Disaster Management Authority (NDMA) & IMD National Heat Action Plan Framework",
            selected_zone=selected,
            all_zones=all_models,
            vernacular_bulletins=selected.localized_bulletins,
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
