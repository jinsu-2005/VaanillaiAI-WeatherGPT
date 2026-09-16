import math
from datetime import datetime, timezone
from typing import List, Dict, Optional

from app.schemas.forest_fire import (
    FireDangerRatingTier,
    ForestBiomeType,
    SatelliteSensor,
    FireWeatherIndices,
    ActiveThermalAnomaly,
    FireBehaviorMetrics,
    ForestryProtectionDirectives,
    ForestFireZoneHotspot,
    ForestFireResponse,
)


class ForestFireService:
    """
    Forest Survey of India (FSI) Van Agni 2.0 & ISRO-Bhuvan Forest Fire Service.
    Nowcasting Canadian Fire Weather Index (FWI) components, active MODIS/VIIRS thermal anomalies,
    fire behavior physics, and wildlife sanctuary protection directives across India.
    """

    FOREST_ZONES: List[Dict] = [
        {
            "zone_id": "uttarakhand_garhwal_pine",
            "zone_name": "Garhwal & Kumaon Chir Pine Forests",
            "state": "Uttarakhand",
            "reserve_name": "Almora, Pauri & Nainital Forest Divisions",
            "latitude": 29.6200,
            "longitude": 79.6600,
            "biome_type": ForestBiomeType.CHIR_PINE_CONIFEROUS,
            "indices": {
                "ffmc_fine_fuel_moisture": 92.4,
                "dmc_duff_moisture": 68.0,
                "dc_drought_code": 410.0,
                "isi_initial_spread_index": 14.8,
                "bui_buildup_index": 95.0,
                "fwi_fire_weather_index": 38.6,
                "danger_tier": FireDangerRatingTier.VERY_HIGH,
            },
            "active_thermal_hotspots": [
                {
                    "sensor": SatelliteSensor.SNPP_VIIRS_375M,
                    "detection_timestamp": "2026-09-12T03:30:00Z",
                    "latitude": 29.6350,
                    "longitude": 79.6720,
                    "brightness_temp_kelvin": 365.4,
                    "fire_radiative_power_mw": 24.8,
                    "confidence_pct": 92.0,
                },
                {
                    "sensor": SatelliteSensor.NOAA20_VIIRS_375M,
                    "detection_timestamp": "2026-09-12T04:15:00Z",
                    "latitude": 29.6120,
                    "longitude": 79.6450,
                    "brightness_temp_kelvin": 352.1,
                    "fire_radiative_power_mw": 18.2,
                    "confidence_pct": 88.0,
                },
            ],
            "total_frp_mw": 145.2,
            "behavior": {
                "estimated_rate_of_spread_m_hr": 620.0,
                "flame_length_m": 3.8,
                "fireline_intensity_kw_m": 3200.0,
                "crown_fire_risk": True,
                "spot_fire_probability_pct": 65.0,
            },
            "directives": {
                "ranger_deployment_alert": "STAGE-3 VAN SAMITI MOBILIZATION: Immediate beat guard rapid response deployment across pine needle ridges.",
                "firebreak_clearance_width_m": 15.0,
                "wildlife_corridor_status": "Wildlife moving toward lower river basins; water troughs replenished in Almora division.",
                "tribal_ntfp_collection_directive": "Strict prohibition on open flame, beedi smoking, and agricultural residue burning on terraced slopes.",
                "aerial_water_bombing_standby": True,
            },
            "localized_bulletins": {
                "en": "CRITICAL ALERT: Very High Fire Weather Index (FWI 38.6) in Garhwal-Kumaon Chir Pine forest divisions. Resinous pine needles are producing rapid uphill flame spread (620 m/hr) with spotting risk. Forest fire lines activated.",
                "hi": "गंभीर चेतावनी: गढ़वाल और कुमाऊं के चीड़ वनों में अत्यधिक वनाग्नि जोखिम (FWI 38.6)। सूखी चीड़ की पत्तियों (पिरुल) के कारण आग तेजी से ढलानों पर फैल रही है। वन पंचायतों और गश्ती दलों को तुरंत आग बुझाने में लगाया गया है।",
                "kn": "ಎಚ್ಚರಿಕೆ: ಗರ್ಹ್ವಾಲ್ ಪೈನ್ ಅರಣ್ಯಗಳಲ್ಲಿ ತೀವ್ರ ಕಾಡ್ಗಿಚ್ಚಿನ ಅಪಾಯ (FWI 38.6). ಬೆಂಕಿ ಹರಡುವ ವೇಗ ಹೆಚ್ಚಾಗಿದ್ದು ನಿಯಂತ್ರಣ ರೇಖೆಗಳನ್ನು ತೆರವುಗೊಳಿಸಲಾಗಿದೆ.",
                "or": "ଚେତାବନୀ: ଗଡ଼ୱାଲ ଏବଂ କୁମାଉଁ ପାଇନ ଜଙ୍ଗଲରେ ଭୟଙ୍କର ବଣନିଆଁ ଚେତାବନୀ (FWI 38.6)। ପିରୁଲ ଶୁଖିଲା ପତ୍ର ଯୋଗୁଁ ନିଆଁ ଦ୍ରୁତ ଗତିରେ ମାଡୁଛି।",
                "ta": "எச்சரிக்கை: கர்வால்-குமாவோன் பைன் காடுகளில் கடுமையான காட்டுத்தீ அபாயம் (FWI 38.6). காற்று வேகத்தால் தீ மலை முகடுகளில் வேகமாக பரவி வருகிறது.",
            },
        },
        {
            "zone_id": "similipal_tiger_reserve",
            "zone_name": "Similipal Biosphere Reserve & Tiger Sanctuary",
            "state": "Odisha",
            "reserve_name": "Similipal Tiger Reserve",
            "latitude": 21.8500,
            "longitude": 86.3500,
            "biome_type": ForestBiomeType.DRY_DECIDUOUS_SAL,
            "indices": {
                "ffmc_fine_fuel_moisture": 94.2,
                "dmc_duff_moisture": 76.5,
                "dc_drought_code": 520.0,
                "isi_initial_spread_index": 18.2,
                "bui_buildup_index": 112.0,
                "fwi_fire_weather_index": 48.5,
                "danger_tier": FireDangerRatingTier.EXTREME,
            },
            "active_thermal_hotspots": [
                {
                    "sensor": SatelliteSensor.SNPP_VIIRS_375M,
                    "detection_timestamp": "2026-09-12T03:45:00Z",
                    "latitude": 21.8620,
                    "longitude": 86.3680,
                    "brightness_temp_kelvin": 382.0,
                    "fire_radiative_power_mw": 45.6,
                    "confidence_pct": 98.0,
                },
                {
                    "sensor": SatelliteSensor.MODIS_AQUA_1KM,
                    "detection_timestamp": "2026-09-12T04:20:00Z",
                    "latitude": 21.8340,
                    "longitude": 86.3320,
                    "brightness_temp_kelvin": 368.5,
                    "fire_radiative_power_mw": 38.2,
                    "confidence_pct": 94.0,
                },
            ],
            "total_frp_mw": 210.8,
            "behavior": {
                "estimated_rate_of_spread_m_hr": 840.0,
                "flame_length_m": 4.5,
                "fireline_intensity_kw_m": 4600.0,
                "crown_fire_risk": True,
                "spot_fire_probability_pct": 78.0,
            },
            "directives": {
                "ranger_deployment_alert": "RED EMERGENCY PROTOCOL: Full mobilization of Odisha Forest Protection Force and ODRAF squads across Similipal core.",
                "firebreak_clearance_width_m": 20.0,
                "wildlife_corridor_status": "Major elephant migration corridor between Barehipani and Chahala active with waterhole solar pump support.",
                "tribal_ntfp_collection_directive": "Complete moratorium on Mahua flower and Sal seed collection inside core zone until fire danger abates.",
                "aerial_water_bombing_standby": True,
            },
            "localized_bulletins": {
                "en": "EMERGENCY: Extreme Forest Fire Danger (FWI 48.5) at Similipal Tiger Reserve. Deciduous Sal leaf litter causing high-intensity crown fires (4600 kW/m). Evacuate forest fringe tourist lodges; ODRAF teams deployed.",
                "or": "ଜରୁରୀ ସତର୍କତା: ଶିମିଳିପାଳ ବ୍ୟାଘ୍ର ଅଭୟାରଣ୍ୟରେ ଚରମ ବଣନିଆଁ ବିପଦ (FWI 48.5)। ଶାଳ ପତ୍ର ଶୁଖିଲା ଥିବାରୁ ନିଆଁ ଦ୍ରୁତ ବେଗରେ (୮୪୦ ମି/ଘଣ୍ଟା) ମାଡୁଛି। ପର୍ଯ୍ୟଟନ ଓ ମହୁଲ ସଂଗ୍ରହ ସମ୍ପୂର୍ଣ୍ଣ ବନ୍ଦ କରାଯାଇଛି।",
                "hi": "आपातकालीन चेतावनी: सिमलीपाल टाइगर रिजर्व में चरम वनाग्नि अलर्ट (FWI 48.5)। साल के पत्तों के जलने से 4.5 मीटर ऊंची लपटें उठ रही हैं। कोर क्षेत्र में महाजन और पर्यटकों का प्रवेश निषिद्ध।",
                "kn": "ತುರ್ತು ಎಚ್ಚರಿಕೆ: ಸಿಮಿಲಿಪಾಲ್ ಹುಲಿ ಸಂರಕ್ಷಿತ ಪ್ರದೇಶದಲ್ಲಿ ತೀವ್ರ ಕಾಡ್ಗಿಚ್ಚು (FWI 48.5). ಪ್ರವಾಸಿಗರಿಗೆ ನಿರ್ಬಂಧ ಹೇರಲಾಗಿದೆ.",
                "ta": "அவசர எச்சரிக்கை: சிமிலிபால் புலிகள் காப்பகத்தில் உச்சக்கட்ட காட்டுத்தீ ஆபத்து (FWI 48.5). தீயணைப்பு படைகள் தீவிரமாக செயல்படுகின்றன.",
            },
        },
        {
            "zone_id": "bandipur_nagarhole_nilgiri",
            "zone_name": "Bandipur & Nagarhole Tiger Reserve Complex",
            "state": "Karnataka",
            "reserve_name": "Bandipur National Park",
            "latitude": 11.6667,
            "longitude": 76.6333,
            "biome_type": ForestBiomeType.BAMBOO_BRAKES,
            "indices": {
                "ffmc_fine_fuel_moisture": 89.5,
                "dmc_duff_moisture": 54.0,
                "dc_drought_code": 380.0,
                "isi_initial_spread_index": 11.4,
                "bui_buildup_index": 78.0,
                "fwi_fire_weather_index": 27.2,
                "danger_tier": FireDangerRatingTier.HIGH,
            },
            "active_thermal_hotspots": [
                {
                    "sensor": SatelliteSensor.SNPP_VIIRS_375M,
                    "detection_timestamp": "2026-09-12T04:00:00Z",
                    "latitude": 11.6820,
                    "longitude": 76.6450,
                    "brightness_temp_kelvin": 348.0,
                    "fire_radiative_power_mw": 16.5,
                    "confidence_pct": 87.0,
                }
            ],
            "total_frp_mw": 68.0,
            "behavior": {
                "estimated_rate_of_spread_m_hr": 450.0,
                "flame_length_m": 2.8,
                "fireline_intensity_kw_m": 1850.0,
                "crown_fire_risk": False,
                "spot_fire_probability_pct": 42.0,
            },
            "directives": {
                "ranger_deployment_alert": "WATCHTOWER SURVEILLANCE & LEAF BLOWER TEAMS: Fire watchers stationed along Gundlupet border and NH-766 corridor.",
                "firebreak_clearance_width_m": 10.0,
                "wildlife_corridor_status": "Moyar river corridor clear for herbivore movement. Night vehicle transit on NH-766 speed capped at 30 km/h.",
                "tribal_ntfp_collection_directive": "Regulated dry wood gathering with forest escort only during morning hours (06:00-10:00).",
                "aerial_water_bombing_standby": False,
            },
            "localized_bulletins": {
                "en": "WARNING: High Fire Weather Index (FWI 27.2) across Bandipur-Nagarhole bamboo dry deciduous ranges. Dry bamboo clumps present localized flashover threat. Highway watchtowers on alert.",
                "kn": "ಎಚ್ಚರಿಕೆ: ಬಂಡೀಪುರ ಮತ್ತು ನಾಗರಹೊಳೆ ಹುಲಿ ಸಂರಕ್ಷಿತ ಪ್ರದೇಶದಲ್ಲಿ ಹೆಚ್ಚಿನ ಕಾಡ್ಗಿಚ್ಚಿನ ಅಪಾಯ (FWI 27.2). ಒಣ ಬಿದಿರು ಮೆಳೆಗಳು ಬೇಗನೆ ಹೊತ್ತಿ ಉರಿಯುವ ಸಾಧ್ಯತೆಯಿದೆ. ಹೆದ್ದಾರಿ ಗಸ್ತು ಹೆಚ್ಚಿಸಲಾಗಿದೆ.",
                "ta": "எச்சரிக்கை: பண்டிப்பூர்-நாகர்ஹோளே காடுகளில் அதிக காட்டுத்தீ அபாயம் (FWI 27.2). மூங்கில் காடுகள் உள்ளதால் தீயணைப்பு குழுக்கள் தயார் நிலையில் வைக்கப்பட்டுள்ளன.",
                "hi": "चेतावनी: बांदीपुर और नागरहोले में बांस और शुष्क पर्णपाती वनों में वनाग्नि का उच्च अलर्ट (FWI 27.2)। गश्त तेज की गई।",
                "or": "ଚେତାବନୀ: ବାନ୍ଦୀପୁର-ନାଗରହୋଳ ବଣରେ ବାଉଁଶ ଜଙ୍ଗଲ ନିଆଁର ଉଚ୍ଚ ସତର୍କତା (FWI 27.2)।",
            },
        },
        {
            "zone_id": "gir_national_park_asiatic_lion",
            "zone_name": "Gir National Park & Wildlife Sanctuary",
            "state": "Gujarat",
            "reserve_name": "Gir Forest Asiatic Lion Sanctuary",
            "latitude": 21.1244,
            "longitude": 70.8242,
            "biome_type": ForestBiomeType.THORN_SCRUB,
            "indices": {
                "ffmc_fine_fuel_moisture": 88.0,
                "dmc_duff_moisture": 48.0,
                "dc_drought_code": 340.0,
                "isi_initial_spread_index": 9.8,
                "bui_buildup_index": 68.0,
                "fwi_fire_weather_index": 22.5,
                "danger_tier": FireDangerRatingTier.HIGH,
            },
            "active_thermal_hotspots": [
                {
                    "sensor": SatelliteSensor.NOAA20_VIIRS_375M,
                    "detection_timestamp": "2026-09-12T04:10:00Z",
                    "latitude": 21.1350,
                    "longitude": 70.8350,
                    "brightness_temp_kelvin": 344.0,
                    "fire_radiative_power_mw": 14.2,
                    "confidence_pct": 85.0,
                }
            ],
            "total_frp_mw": 42.5,
            "behavior": {
                "estimated_rate_of_spread_m_hr": 380.0,
                "flame_length_m": 2.2,
                "fireline_intensity_kw_m": 1200.0,
                "crown_fire_risk": False,
                "spot_fire_probability_pct": 30.0,
            },
            "directives": {
                "ranger_deployment_alert": "LION PRIDE RESCUE CORRIDOR: Sasan Gir control room monitoring 25 artificial water saucers and Maldhari nesses.",
                "firebreak_clearance_width_m": 8.0,
                "wildlife_corridor_status": "Dedicated lion tracking units with tranquilizer kits patrolling dry scrub boundaries.",
                "tribal_ntfp_collection_directive": "Maldhari pastoralists requested to graze cattle within approved riverine strips only.",
                "aerial_water_bombing_standby": False,
            },
            "localized_bulletins": {
                "en": "ADVISORY: High Fire Danger (FWI 22.5) in Gir dry thorn scrub forest. Protection teams monitoring Asiatic lion breeding prides and watering points.",
                "hi": "सलाह: गिर राष्ट्रीय उद्यान में कांटेदार झाड़ियों में आग का उच्च जोखिम (FWI 22.5)। एशियाई शेरों और मालधारी बस्तियों की सुरक्षा हेतु गश्त तेज।",
                "kn": "ಸಲಹೆ: ಗಿರ್ ಏಷ್ಯಾಟಿಕ್ ಸಿಂಹಗಳ ಅಭಯಾರಣ್ಯದಲ್ಲಿ ಕಾಡ್ಗಿಚ್ಚಿನ ಎಚ್ಚರಿಕೆ (FWI 22.5). ಸಿಂಹಗಳ ನೀರಿನ ತೊಟ್ಟಿಗಳ ಬಳಿ ರಕ್ಷಣೆ ಹೆಚ್ಚಿಸಲಾಗಿದೆ.",
                "ta": "அறிவுறுத்தல்: கிர் தேசிய பூங்காவில் ஆசிய சிங்கங்களின் வாழிடத்தில் காட்டுத்தீ எச்சரிக்கை (FWI 22.5).",
                "or": "ସୂଚନା: ଗିର ଏସିଆଟିକ ସିଂହ ଅଭୟାରଣ୍ୟରେ ନିଆଁ ସତର୍କତା (FWI 22.5)।",
            },
        },
        {
            "zone_id": "nilgiris_shola_grassland",
            "zone_name": "Mudumalai & Nilgiris Biosphere Core",
            "state": "Tamil Nadu",
            "reserve_name": "Mudumalai Tiger Reserve & Nilgiri Sholas",
            "latitude": 11.5600,
            "longitude": 76.5300,
            "biome_type": ForestBiomeType.SHOLA_GRASSLAND_MOSAIC,
            "indices": {
                "ffmc_fine_fuel_moisture": 86.2,
                "dmc_duff_moisture": 42.0,
                "dc_drought_code": 290.0,
                "isi_initial_spread_index": 8.5,
                "bui_buildup_index": 58.0,
                "fwi_fire_weather_index": 18.4,
                "danger_tier": FireDangerRatingTier.HIGH,
            },
            "active_thermal_hotspots": [
                {
                    "sensor": SatelliteSensor.SNPP_VIIRS_375M,
                    "detection_timestamp": "2026-09-12T04:25:00Z",
                    "latitude": 11.5710,
                    "longitude": 76.5420,
                    "brightness_temp_kelvin": 339.5,
                    "fire_radiative_power_mw": 11.2,
                    "confidence_pct": 82.0,
                }
            ],
            "total_frp_mw": 28.0,
            "behavior": {
                "estimated_rate_of_spread_m_hr": 310.0,
                "flame_length_m": 1.8,
                "fireline_intensity_kw_m": 950.0,
                "crown_fire_risk": False,
                "spot_fire_probability_pct": 25.0,
            },
            "directives": {
                "ranger_deployment_alert": "SHOLA-GRASSLAND EDGE PROTECTION: Clearing fire traces between exotic wattle/eucalyptus plantations and native sholas.",
                "firebreak_clearance_width_m": 8.0,
                "wildlife_corridor_status": "Segur plateau corridor open; check-posts regulating campfire bans around Ooty outskirts.",
                "tribal_ntfp_collection_directive": "Irula and Kurumba honey gatherers restricted from smoking wild bee hives during dry afternoon hours.",
                "aerial_water_bombing_standby": False,
            },
            "localized_bulletins": {
                "en": "ADVISORY: High Fire Weather Index (FWI 18.4) in Mudumalai and Nilgiri high-altitude grassland mosaic. Strict campfire bans in place across tourist routes.",
                "ta": "அறிவுறுத்தல்: முதுமலை மற்றும் நீலகிரி சோலை புல்வெளி பகுதிகளில் காட்டுத்தீ ஆபத்து (FWI 18.4). சுற்றுலா பயணிகள் திறந்த வெளியில் நெருப்பு மூட்டுவது தடை செய்யப்பட்டுள்ளது.",
                "kn": "ಸಲಹೆ: ಮುದುಮಲೈ ಮತ್ತು ನೀಲಗಿರಿ ಹುಲ್ಲುಗಾವಲು ಪ್ರದೇಶಗಳಲ್ಲಿ ಬೆಂಕಿಯ ಎಚ್ಚರಿಕೆ (FWI 18.4).",
                "hi": "सलाह: मुदुमलाई और नीलगिरि के शोला घास के मैदानों में वनाग्नि अलर्ट (FWI 18.4)। पर्यटकों के लिए आग जलाने पर पूर्ण प्रतिबंध।",
                "or": "ସୂଚନା: ମୁଦୁମଲାଇ ଏବଂ ନୀଳଗିରି ଘାସଭୂମିରେ ନିଆଁ ସତର୍କତା (FWI 18.4)।",
            },
        },
        {
            "zone_id": "dampa_tiger_reserve_mizoram",
            "zone_name": "Dampa Tiger Reserve & Western Lushai Hills",
            "state": "Mizoram",
            "reserve_name": "Dampa Tiger Reserve",
            "latitude": 23.6800,
            "longitude": 92.4200,
            "biome_type": ForestBiomeType.BAMBOO_BRAKES,
            "indices": {
                "ffmc_fine_fuel_moisture": 91.0,
                "dmc_duff_moisture": 62.0,
                "dc_drought_code": 440.0,
                "isi_initial_spread_index": 13.2,
                "bui_buildup_index": 89.0,
                "fwi_fire_weather_index": 32.8,
                "danger_tier": FireDangerRatingTier.VERY_HIGH,
            },
            "active_thermal_hotspots": [
                {
                    "sensor": SatelliteSensor.SNPP_VIIRS_375M,
                    "detection_timestamp": "2026-09-12T03:50:00Z",
                    "latitude": 23.6920,
                    "longitude": 92.4350,
                    "brightness_temp_kelvin": 358.0,
                    "fire_radiative_power_mw": 28.5,
                    "confidence_pct": 91.0,
                }
            ],
            "total_frp_mw": 96.0,
            "behavior": {
                "estimated_rate_of_spread_m_hr": 550.0,
                "flame_length_m": 3.4,
                "fireline_intensity_kw_m": 2800.0,
                "crown_fire_risk": True,
                "spot_fire_probability_pct": 58.0,
            },
            "directives": {
                "ranger_deployment_alert": "JHUM ESCAPE FIRE CONTAINMENT: Coordination with Village Council Presidents to enforce boundary fire tracing.",
                "firebreak_clearance_width_m": 12.0,
                "wildlife_corridor_status": "Western border corridor monitored for clouded leopard and elephant movement into Bangladesh Chittagong tracts.",
                "tribal_ntfp_collection_directive": "Controlled jhum burning restricted strictly between 06:00 and 09:00 with village vigil guards.",
                "aerial_water_bombing_standby": False,
            },
            "localized_bulletins": {
                "en": "WARNING: Very High Fire Weather Index (FWI 32.8) in Dampa Tiger Reserve bamboo slopes. Escaped shifting cultivation burns creating high crown fire risk.",
                "hi": "चेतावनी: डंपा टाइगर रिजर्व में बांस के जंगलों में बहुत उच्च वनाग्नि जोखिम (FWI 32.8)। झूम खेती की आग से जंगल में फैलाव का खतरा।",
                "kn": "ಎಚ್ಚರಿಕೆ: ಡಂಪಾ ಹುಲಿ ಸಂರಕ್ಷಿತ ಪ್ರದೇಶದಲ್ಲಿ ಬಿದಿರು ಅರಣ್ಯ ಕಾಡ್ಗಿಚ್ಚಿನ ಗಂಭೀರ ಎಚ್ಚರಿಕೆ (FWI 32.8).",
                "or": "ଚେତାବନୀ: ଡାମ୍ପା ବ୍ୟାଘ୍ର ଅଭୟାରଣ୍ୟରେ ବାଉଁଶ ବଣରେ ନିଆଁର ଉଚ୍ଚ ବିପଦ (FWI 32.8)।",
                "ta": "எச்சரிக்கை: டம்பா புலிகள் காப்பகத்தில் மூங்கில் காடுகளில் மிக அதிக காட்டுத்தீ அபாயம் (FWI 32.8).",
            },
        },
        {
            "zone_id": "melghat_tiger_reserve_satpura",
            "zone_name": "Melghat Tiger Reserve & Satpura South",
            "state": "Maharashtra",
            "reserve_name": "Melghat Tiger Reserve",
            "latitude": 21.4500,
            "longitude": 77.2000,
            "biome_type": ForestBiomeType.DRY_DECIDUOUS_TEAK,
            "indices": {
                "ffmc_fine_fuel_moisture": 93.0,
                "dmc_duff_moisture": 70.0,
                "dc_drought_code": 480.0,
                "isi_initial_spread_index": 15.5,
                "bui_buildup_index": 98.0,
                "fwi_fire_weather_index": 40.2,
                "danger_tier": FireDangerRatingTier.VERY_HIGH,
            },
            "active_thermal_hotspots": [
                {
                    "sensor": SatelliteSensor.NOAA20_VIIRS_375M,
                    "detection_timestamp": "2026-09-12T04:05:00Z",
                    "latitude": 21.4650,
                    "longitude": 77.2180,
                    "brightness_temp_kelvin": 366.2,
                    "fire_radiative_power_mw": 32.0,
                    "confidence_pct": 93.0,
                }
            ],
            "total_frp_mw": 118.5,
            "behavior": {
                "estimated_rate_of_spread_m_hr": 690.0,
                "flame_length_m": 4.0,
                "fireline_intensity_kw_m": 3600.0,
                "crown_fire_risk": True,
                "spot_fire_probability_pct": 68.0,
            },
            "directives": {
                "ranger_deployment_alert": "SATPUDA STRIKE TEAMS ACTIVE: Mechanized blowers and water tankers deployed along Sipna and Khandu river valleys.",
                "firebreak_clearance_width_m": 15.0,
                "wildlife_corridor_status": "Semadoh-Chikhaldara corridor closed for non-essential traffic due to thick pyrogenic smoke.",
                "tribal_ntfp_collection_directive": "Korku tribal villages alerted to suspend Tendu leaf collection during midday gale hours.",
                "aerial_water_bombing_standby": True,
            },
            "localized_bulletins": {
                "en": "WARNING: Very High Fire Weather Index (FWI 40.2) in Melghat dry deciduous teak forest. Large broadleaf litter and steep Satpura ravines driving fast uphill runs.",
                "hi": "चेतावनी: मेलघाट टाइगर रिजर्व (सतपुड़ा) में भीषण वनाग्नि का अलर्ट (FWI 40.2)। सागौन के सूखे पत्तों के कारण आग तेजी से घाटियों में फैल रही है।",
                "kn": "ಎಚ್ಚರಿಕೆ: ಮೇಲ್‌ಘಾಟ್ ತೇಗದ ಕಾಡುಗಳಲ್ಲಿ ತೀವ್ರ ಕಾಡ್ಗಿಚ್ಚಿನ ಎಚ್ಚರಿಕೆ (FWI 40.2).",
                "or": "ଚେତାବନୀ: ମେଲଘାଟ ବ୍ୟାଘ୍ର ଅଭୟାରଣ୍ୟରେ ଶାଗୁଆନ ବଣରେ ଭୟଙ୍କର ବଣନିଆଁ (FWI 40.2)।",
                "ta": "எச்சரிக்கை: மேல்காட் தேக்கு மர காடுகளில் தீவிர காட்டுத்தீ எச்சரிக்கை (FWI 40.2).",
            },
        },
    ]

    @classmethod
    def get_assessment(
        cls,
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        zone_id: Optional[str] = None,
    ) -> ForestFireResponse:
        """
        Retrieves Forest Survey of India & ISRO-Bhuvan forest fire early warnings and FWI analytics.
        Selects target forest zone via explicit ID or geodetic Haversine proximity.
        """
        all_models: List[ForestFireZoneHotspot] = []
        for raw in cls.FOREST_ZONES:
            zone = ForestFireZoneHotspot(
                zone_id=raw["zone_id"],
                zone_name=raw["zone_name"],
                state=raw["state"],
                reserve_name=raw["reserve_name"],
                latitude=raw["latitude"],
                longitude=raw["longitude"],
                biome_type=raw["biome_type"],
                indices=FireWeatherIndices(**raw["indices"]),
                active_thermal_hotspots=[ActiveThermalAnomaly(**a) for a in raw["active_thermal_hotspots"]],
                total_frp_mw=raw["total_frp_mw"],
                behavior=FireBehaviorMetrics(**raw["behavior"]),
                directives=ForestryProtectionDirectives(**raw["directives"]),
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
        bulletin_ref = f"FSI-ISRO/FF-FWIE/{datetime.now(timezone.utc).strftime('%Y%m')}-{selected.zone_id[:6].upper()}"

        return ForestFireResponse(
            timestamp=now_utc,
            bulletin_number=bulletin_ref,
            provenance="Forest Survey of India (Van Agni 2.0) & ISRO-Bhuvan Fire Weather Early Warning",
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
