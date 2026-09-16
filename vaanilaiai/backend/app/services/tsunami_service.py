import math
from datetime import datetime, timezone
from typing import List, Dict, Optional

from app.schemas.tsunami import (
    TsunamiAlertTier,
    TsunamigenicSubductionZone,
    SeismicSourceParameters,
    DeepOceanDartBuoy,
    CoastalTideGaugeTelemetry,
    CoastalTsunamiWaveMetrics,
    EvacuationAndMaritimeDirectives,
    CoastalForecastSector,
    TsunamiWarningResponse,
)


class TsunamiService:
    """
    Indian National Centre for Ocean Information Services (INCOIS) & IMD
    Indian Tsunami Early Warning Centre (ITEWS) Service.
    Deep-ocean DART tsunameter buoys, coastal tide gauge sea-level anomalies,
    hydrodynamic wave arrival travel-time isochrones, and vertical evacuation directives.
    """

    COASTAL_SECTORS: List[Dict] = [
        {
            "sector_id": "andaman_nicobar_islands",
            "sector_name": "Andaman & Nicobar Islands (Near-Field Trench)",
            "state": "Andaman & Nicobar Islands (UT)",
            "key_coastal_nodes": ["Port Blair", "Car Nicobar", "Hut Bay (Little Andaman)", "Campbell Bay (Great Nicobar)"],
            "latitude": 11.6670,
            "longitude": 92.7350,
            "alert_tier": TsunamiAlertTier.WARNING_RED,
            "seismic_source": {
                "moment_magnitude_mw": 8.4,
                "focal_depth_km": 18.0,
                "epicenter_latitude": 9.2500,
                "epicenter_longitude": 93.8500,
                "origin_time_utc": "2026-09-12T04:15:00Z",
                "subduction_zone": TsunamigenicSubductionZone.ANDAMAN_SUMATRA_TRENCH,
                "rupture_mechanism": "Underthrust Megathrust Faulting (Subduction Zone)",
            },
            "wave_metrics": {
                "estimated_time_of_arrival_eta": "04:43 UTC (28 min elapsed)",
                "time_to_first_wave_minutes": 28,
                "maximum_expected_wave_amplitude_m": 4.2,
                "deep_water_propagation_speed_kmh": 725.0,
                "estimated_inundation_distance_m": 850.0,
                "shoaling_amplification_factor": 5.8,
            },
            "dart_buoys": [
                {
                    "buoy_id": "BPR-TB02",
                    "sea_basin": "Andaman Sea Trench",
                    "latitude": 10.8200,
                    "longitude": 93.4100,
                    "water_depth_m": 2850.0,
                    "pressure_anomaly_hpa": 14.8,
                    "deep_ocean_wave_amplitude_cm": 42.5,
                    "is_event_mode_triggered": True,
                },
                {
                    "buoy_id": "BPR-TB01",
                    "sea_basin": "East Bay of Bengal",
                    "latitude": 13.5000,
                    "longitude": 89.2000,
                    "water_depth_m": 3320.0,
                    "pressure_anomaly_hpa": 8.6,
                    "deep_ocean_wave_amplitude_cm": 28.0,
                    "is_event_mode_triggered": True,
                },
            ],
            "tide_gauges": [
                {
                    "station_id": "INCOIS-TG-PBLR",
                    "station_name": "Port Blair Phoenix Bay Jetty",
                    "observed_sea_level_m": 2.45,
                    "astronomical_tide_m": 0.82,
                    "tsunami_residual_amplitude_m": 1.63,
                    "last_sample_time_utc": "2026-09-12T04:32:00Z",
                },
                {
                    "station_id": "INCOIS-TG-CNIC",
                    "station_name": "Car Nicobar Malacca Jetty",
                    "observed_sea_level_m": 3.80,
                    "astronomical_tide_m": 0.75,
                    "tsunami_residual_amplitude_m": 3.05,
                    "last_sample_time_utc": "2026-09-12T04:35:00Z",
                },
            ],
            "evacuation_directives": {
                "vertical_evacuation_altitude_m": 20.0,
                "horizontal_evacuation_distance_km": 1.5,
                "deep_sea_vessel_directive": "Vessels in harbor MUST evacuate crews immediately and head to open sea (>100m depth). DO NOT remain moored.",
                "coastal_siren_network_status": "HIGH ALERT: All 42 coastal sirens sounding in Port Blair and Car Nicobar.",
                "port_cargo_operations_status": "SUSPENDED: All cargo and passenger ferry operations halted immediately.",
                "designated_safe_shelter_locations": [
                    "Mount Harriet High Ground Tsunami Refuge",
                    "Car Nicobar Air Force Station Elevated Ridge",
                    "Hut Bay Primary Tsunami Evacuation Tower",
                ],
            },
            "localized_bulletins": {
                "en": "CRITICAL TSUNAMI WARNING (RED ALERT): Major tsunamigenic earthquake (Mw 8.4) in Andaman-Sumatra trench. Maximum tsunami wave amplitude 4.2m expected. Immediate vertical evacuation to elevation >20m required across Andaman & Nicobar coastal sectors.",
                "hi": "अति गंभीर सुनामी चेतावनी (लाल अलर्ट): अंडमान-सुमात्रा गर्त में 8.4 तीव्रता का सुनामी भूकंप। 4.2 मीटर ऊंची सुनामी लहरें उठने की आशंका। तटीय क्षेत्रों के लोग तुरंत 20 मीटर से अधिक ऊंचाई वाले सुरक्षित स्थानों पर जाएं।",
                "ta": "சுனாமி சிவப்பு எச்சரிக்கை: அந்தமான்-சுமத்ரா அகழியில் 8.4 ரிக்டர் நிலநடுக்கம். 4.2 மீட்டர் உயர சுனாமி அலைகள் தாக்கக்கூடும். கடலோர மக்கள் உடனடியாக 20 மீட்டருக்கு மேல் உயரமான இடங்களுக்கு வெளியேறவும்.",
                "te": "సునామీ రెడ్ అలర్ట్: అండమాన్-సుమత్రా ట్రెంచ్‌లో 8.4 తీవ్రతతో భారీ భూకంపం. 4.2 మీటర్ల ఎత్తు వరకు సునామీ అలలు వచ్చే అవకాశం ఉంది. తీరప్రాంత ప్రజలు వెంటనే 20 మీటర్ల ఎత్తైన సురక్షిత ప్రాంతాలకు వెళ్లాలి.",
                "ml": "സുനാമി റെഡ് അലർട്ട്: ആൻഡമാൻ-സുമാത്ര ട്രെഞ്ചിൽ 8.4 തീവ്രത രേഖപ്പെടുത്തിയ ഭൂകമ്പം. 4.2 മീറ്റർ ഉയരത്തിൽ സുനാമി തിരമാലകൾക്ക് സാധ്യത. തീരദേശവാസികൾ ഉടൻ 20 മീറ്ററിലധികം ഉയർന്ന സ്ഥലങ്ങളിലേക്ക് മാറുക.",
                "bn": "সুনামি লাল সতর্কতা: আন্দামান-সুমাত্রা ট্রেঞ্চে ৮.৪ মাত্রার শক্তিশালী ভূমিকম্প। ৪.২ মিটার পর্যন্ত সুনামির ঢেউ আছড়ে পড়ার আশঙ্কা। উপকূলবর্তী বাসিন্দারা অবিলম্বে ২০ মিটারের বেশি উঁচু স্থানে আশ্রয় নিন।",
                "or": "ସୁନାମି ଲାଲ୍ ସତର୍କତା: ଆଣ୍ଡାମାନ-ସୁମାତ୍ରା ଟ୍ରେଞ୍ଚରେ ୮.୪ ତୀବ୍ରତାର ଭୂକମ୍ପ। ୪.୨ ମିଟର ଉଚ୍ଚ ସୁନାମି ତରଙ୍ଗ ଆସିବାର ସମ୍ଭାବନା। ଉପକୂଳବର୍ତ୍ତୀ ଲୋକେ ତୁରନ୍ତ ୨୦ ମିଟରରୁ ଅଧିକ ଉଚ୍ଚ ସ୍ଥାନକୁ ଚାଲିଯାଆନ୍ତୁ।",
            },
        },
        {
            "sector_id": "tamil_nadu_coromandel_coast",
            "sector_name": "Tamil Nadu & Puducherry Coromandel Coast",
            "state": "Tamil Nadu & Puducherry",
            "key_coastal_nodes": ["Nagapattinam", "Cuddalore", "Chennai Marina / Ennore Port", "Tuticorin", "Karaikal"],
            "latitude": 10.7670,
            "longitude": 79.8420,
            "alert_tier": TsunamiAlertTier.WARNING_RED,
            "seismic_source": {
                "moment_magnitude_mw": 8.4,
                "focal_depth_km": 18.0,
                "epicenter_latitude": 9.2500,
                "epicenter_longitude": 93.8500,
                "origin_time_utc": "2026-09-12T04:15:00Z",
                "subduction_zone": TsunamigenicSubductionZone.ANDAMAN_SUMATRA_TRENCH,
                "rupture_mechanism": "Underthrust Megathrust Faulting (Subduction Zone)",
            },
            "wave_metrics": {
                "estimated_time_of_arrival_eta": "06:10 UTC (115 min remaining)",
                "time_to_first_wave_minutes": 115,
                "maximum_expected_wave_amplitude_m": 2.8,
                "deep_water_propagation_speed_kmh": 710.0,
                "estimated_inundation_distance_m": 620.0,
                "shoaling_amplification_factor": 4.6,
            },
            "dart_buoys": [
                {
                    "buoy_id": "BPR-TB01",
                    "sea_basin": "East Bay of Bengal",
                    "latitude": 13.5000,
                    "longitude": 89.2000,
                    "water_depth_m": 3320.0,
                    "pressure_anomaly_hpa": 8.6,
                    "deep_ocean_wave_amplitude_cm": 28.0,
                    "is_event_mode_triggered": True,
                },
            ],
            "tide_gauges": [
                {
                    "station_id": "INCOIS-TG-MAA",
                    "station_name": "Chennai Port Trust Tide Gauge",
                    "observed_sea_level_m": 1.15,
                    "astronomical_tide_m": 0.95,
                    "tsunami_residual_amplitude_m": 0.20,
                    "last_sample_time_utc": "2026-09-12T04:40:00Z",
                },
                {
                    "station_id": "INCOIS-TG-NAGT",
                    "station_name": "Nagapattinam Fishing Harbour",
                    "observed_sea_level_m": 1.05,
                    "astronomical_tide_m": 0.88,
                    "tsunami_residual_amplitude_m": 0.17,
                    "last_sample_time_utc": "2026-09-12T04:38:00Z",
                },
            ],
            "evacuation_directives": {
                "vertical_evacuation_altitude_m": 15.0,
                "horizontal_evacuation_distance_km": 1.0,
                "deep_sea_vessel_directive": "All fishing boats and commercial vessels out to sea (>100m depth). Clear Marina, Besant Nagar, and Nagapattinam beaches immediately.",
                "coastal_siren_network_status": "ACTIVATED: Coromandel coastal sirens broadcasting evacuation tone.",
                "port_cargo_operations_status": "SUSPENDED: Chennai, Kamarajar (Ennore), and VOC Tuticorin ports de-berthing oil tankers.",
                "designated_safe_shelter_locations": [
                    "Nagapattinam Multi-Purpose Tsunami Shelter",
                    "Cuddalore Silver Beach Cyclone/Tsunami Refuge",
                    "Chennai Lighthouse Elevated Assembly Area",
                ],
            },
            "localized_bulletins": {
                "en": "TSUNAMI WARNING (RED ALERT): Coromandel coast on high alert. Peak tsunami wave amplitude 2.8m arriving Nagapattinam/Chennai around 06:10 UTC. Evacuate beaches and coastal lowlands to RCC multistory buildings or ground >15m.",
                "hi": "सुनामी चेतावनी (लाल अलर्ट): कोरोमंडल तट पर भारी खतरा। नागपट्टिनम और चेन्नई में 2.8 मीटर ऊंची सुनामी लहरें 06:10 UTC तक पहुंचने की संभावना। तटीय बस्तियां तुरंत खाली करें।",
                "ta": "சுனாமி சிவப்பு எச்சரிக்கை: நாகப்பட்டினம், கடலூர், சென்னை கடற்கரைகளுக்கு 2.8 மீ உயர சுனாமி அலைகள் 06:10 UTC அளவில் வரக்கூடும். மக்கள் கடற்கரையிலிருந்து 1 கி.மீ தூரத்திற்கு அப்பால் அல்லது 15 மீ உயரமான இடங்களுக்கு செல்லவும்.",
                "te": "సునామీ రెడ్ అలర్ట్: కోరమాండల్ తీరంలో తీవ్ర ముప్పు. నాగపట్నం, చెన్నై తీరాలకు 2.8 మీటర్ల ఎత్తుగల అలలు చేరే ప్రమాదం ఉంది. బీచ్‌లు, లోతట్టు ప్రాంతాల ప్రజలు వెంటనే తరలివెళ్లాలి.",
                "ml": "സുനാമി മുന്നറിയിപ്പ് (റെഡ് അലർട്ട്): തമിഴ്‌നാട് കോറോമാണ്ടൽ തീരത്ത് 2.8 മീറ്റർ സുനാമി തിരമാലകൾ പ്രതീക്ഷിക്കുന്നു. തീരപ്രദേശങ്ങളിൽ നിന്ന് ആളുകൾ സുരക്ഷിത സ്ഥാനങ്ങളിലേക്ക് മാറുക.",
                "bn": "সুনামি সতর্কতা (লাল সতর্কতা): করমন্ডল উপকূলে ২.৮ মিটার উচ্চতার সুনামি আছড়ে পড়ার সম্ভাবনা। চেন্নাই ও নাগাপট্টিনম সৈকত অবিলম্বে খালি করুন।",
                "or": "ସୁନାମି ସତର୍କତା (ଲାଲ୍): କରମଣ୍ଡଳ ଉପକୂଳ ପ୍ରତି ବିପଦ। ନାଗାପାଟ୍ଟିନମ୍ ଓ ଚେନ୍ନାଇ ଉପକୂଳରେ ୨.୮ ମିଟର ଉଚ୍ଚ ସୁନାମି ତରଙ୍ଗ ଆସିପାରେ। ସୁରକ୍ଷିତ ଉଚ୍ଚ ସ୍ଥାନକୁ ଚାଲିଯାଆନ୍ତୁ।",
            },
        },
        {
            "sector_id": "andhra_pradesh_coast",
            "sector_name": "Andhra Pradesh Northern Circars & Krishna Coast",
            "state": "Andhra Pradesh",
            "key_coastal_nodes": ["Visakhapatnam Port", "Machilipatnam", "Kakinada Deepwater Port", "Nizampatnam"],
            "latitude": 17.6868,
            "longitude": 83.2185,
            "alert_tier": TsunamiAlertTier.ALERT_ORANGE,
            "seismic_source": {
                "moment_magnitude_mw": 8.4,
                "focal_depth_km": 18.0,
                "epicenter_latitude": 9.2500,
                "epicenter_longitude": 93.8500,
                "origin_time_utc": "2026-09-12T04:15:00Z",
                "subduction_zone": TsunamigenicSubductionZone.ANDAMAN_SUMATRA_TRENCH,
                "rupture_mechanism": "Underthrust Megathrust Faulting (Subduction Zone)",
            },
            "wave_metrics": {
                "estimated_time_of_arrival_eta": "06:35 UTC (140 min remaining)",
                "time_to_first_wave_minutes": 140,
                "maximum_expected_wave_amplitude_m": 1.6,
                "deep_water_propagation_speed_kmh": 695.0,
                "estimated_inundation_distance_m": 340.0,
                "shoaling_amplification_factor": 3.8,
            },
            "dart_buoys": [
                {
                    "buoy_id": "BPR-TB01",
                    "sea_basin": "East Bay of Bengal",
                    "latitude": 13.5000,
                    "longitude": 89.2000,
                    "water_depth_m": 3320.0,
                    "pressure_anomaly_hpa": 8.6,
                    "deep_ocean_wave_amplitude_cm": 28.0,
                    "is_event_mode_triggered": True,
                },
            ],
            "tide_gauges": [
                {
                    "station_id": "INCOIS-TG-VIZ",
                    "station_name": "Visakhapatnam Outer Harbour Gauge",
                    "observed_sea_level_m": 1.02,
                    "astronomical_tide_m": 0.90,
                    "tsunami_residual_amplitude_m": 0.12,
                    "last_sample_time_utc": "2026-09-12T04:42:00Z",
                },
            ],
            "evacuation_directives": {
                "vertical_evacuation_altitude_m": 10.0,
                "horizontal_evacuation_distance_km": 0.5,
                "deep_sea_vessel_directive": "Keep small mechanized boats away from river inlets and estuaries. Deep-sea trawlers remain offshore.",
                "coastal_siren_network_status": "STANDBY: Sirens armed for immediate triggering if amplitude exceeds 1.5m.",
                "port_cargo_operations_status": "ADVISORY: Vizag and Kakinada ports restricting incoming ship movements.",
                "designated_safe_shelter_locations": [
                    "Visakhapatnam Kailasagiri Elevated Relief Staging Area",
                    "Machilipatnam Coastal Cyclone Shelter Grid",
                ],
            },
            "localized_bulletins": {
                "en": "TSUNAMI ALERT (ORANGE ALERT): Andhra Pradesh coastal waters expecting moderate tsunami wave amplitude up to 1.6m at Vizag and Machilipatnam. Fishermen prohibited from entering sea; clear beach promenades.",
                "hi": "सुनामी अलर्ट (नारंगी अलर्ट): आंध्र प्रदेश के विशाखापट्टनम और मछलीपट्टनम में 1.6 मीटर तक ऊंची समुद्री लहरें उठने की आशंका। समुद्र में न जाएं और तटों से दूर रहें।",
                "te": "సునామీ ఆరెంజ్ అలర్ట్: ఆంధ్రప్రదేశ్ తీరంలో విశాఖపట్నం, మచిలీపట్నం వద్ద 1.6 మీటర్ల ఎత్తు వరకు అలలు ఎగసిపడే అవకాశం ఉంది. మత్స్యకారులు సముద్రంలోకి వెళ్లరాదు.",
                "ta": "சுனாமி ஆரஞ்சு எச்சரிக்கை: ஆந்திரா கடற்கரையில் விசாகப்பட்டினம் மற்றும் மச்சிலிப்பட்டினத்தில் 1.6 மீ அலைகள் வரக்கூடும். கடற்கரைக்கு செல்வதை தவிர்க்கவும்.",
            },
        },
        {
            "sector_id": "odisha_bengal_coast",
            "sector_name": "Odisha & West Bengal Northern Bay Coast",
            "state": "Odisha & West Bengal",
            "key_coastal_nodes": ["Puri Beach", "Paradeep Port", "Digha", "Gopalpur-on-Sea", "Sagar Island"],
            "latitude": 19.8135,
            "longitude": 85.8312,
            "alert_tier": TsunamiAlertTier.WATCH_YELLOW,
            "seismic_source": {
                "moment_magnitude_mw": 8.4,
                "focal_depth_km": 18.0,
                "epicenter_latitude": 9.2500,
                "epicenter_longitude": 93.8500,
                "origin_time_utc": "2026-09-12T04:15:00Z",
                "subduction_zone": TsunamigenicSubductionZone.ANDAMAN_SUMATRA_TRENCH,
                "rupture_mechanism": "Underthrust Megathrust Faulting (Subduction Zone)",
            },
            "wave_metrics": {
                "estimated_time_of_arrival_eta": "07:00 UTC (165 min remaining)",
                "time_to_first_wave_minutes": 165,
                "maximum_expected_wave_amplitude_m": 0.85,
                "deep_water_propagation_speed_kmh": 680.0,
                "estimated_inundation_distance_m": 120.0,
                "shoaling_amplification_factor": 2.9,
            },
            "dart_buoys": [
                {
                    "buoy_id": "BPR-TB01",
                    "sea_basin": "East Bay of Bengal",
                    "latitude": 13.5000,
                    "longitude": 89.2000,
                    "water_depth_m": 3320.0,
                    "pressure_anomaly_hpa": 8.6,
                    "deep_ocean_wave_amplitude_cm": 28.0,
                    "is_event_mode_triggered": True,
                },
            ],
            "tide_gauges": [
                {
                    "station_id": "INCOIS-TG-PRDP",
                    "station_name": "Paradeep Port Wet Basin",
                    "observed_sea_level_m": 1.30,
                    "astronomical_tide_m": 1.25,
                    "tsunami_residual_amplitude_m": 0.05,
                    "last_sample_time_utc": "2026-09-12T04:45:00Z",
                },
            ],
            "evacuation_directives": {
                "vertical_evacuation_altitude_m": 6.0,
                "horizontal_evacuation_distance_km": 0.2,
                "deep_sea_vessel_directive": "Small craft stay moored securely in harbors. Avoid recreational swimming at Puri and Digha beaches.",
                "coastal_siren_network_status": "MONITORING: Watch advisory transmitted to District Collectors.",
                "port_cargo_operations_status": "NORMAL WITH ADVISORY: Paradeep and Haldia operating under watch caution.",
                "designated_safe_shelter_locations": [
                    "Puri Swargadwar Multi-Purpose Cyclone Shelter",
                    "Digha Coastal Police Outpost Elevation",
                ],
            },
            "localized_bulletins": {
                "en": "TSUNAMI WATCH (YELLOW WATCH): Wave amplitudes under 0.9m forecast for Puri, Paradeep, and Digha. Minor current surges in harbors. Public advised to avoid beach waters.",
                "hi": "सुनामी वॉच (पीला अलर्ट): ओडिशा और पश्चिम बंगाल तट पर 0.9 मीटर से कम की हल्की सुनामी लहरों की संभावना। समुद्र तटों पर नहाने से बचें।",
                "or": "ସୁନାମି ୱାଚ୍ (ହଳଦିଆ): ପୁରୀ, ପାରାଦ୍ୱୀପ ଏବଂ ଦୀଘା ଉପକୂଳରେ ୦.୯ ମିଟରରୁ କମ୍ ତରଙ୍ଗ ଆସିପାରେ। ସମୁଦ୍ରକୂଳକୁ ଯିବାରୁ ନିବୃତ୍ତ ରୁହନ୍ତୁ।",
                "bn": "সুনামি ওয়াচ (হলুদ সতর্কতা): দিঘা, সাগরদ্বীপ ও পারাদ্বীপে ০.৯ মিটারের কম ঢেউয়ের পূর্বাভাস। সৈকতে নামা ও সাঁতার কাটা থেকে বিরত থাকুন।",
            },
        },
        {
            "sector_id": "kerala_malabar_coast",
            "sector_name": "Kerala Malabar & Lakshadweep Sea Coast",
            "state": "Kerala",
            "key_coastal_nodes": ["Kollam", "Alappuzha", "Kochi Marine Drive", "Kannur", "Vizhinjam Port"],
            "latitude": 9.9312,
            "longitude": 76.2673,
            "alert_tier": TsunamiAlertTier.ALERT_ORANGE,
            "seismic_source": {
                "moment_magnitude_mw": 8.4,
                "focal_depth_km": 18.0,
                "epicenter_latitude": 9.2500,
                "epicenter_longitude": 93.8500,
                "origin_time_utc": "2026-09-12T04:15:00Z",
                "subduction_zone": TsunamigenicSubductionZone.ANDAMAN_SUMATRA_TRENCH,
                "rupture_mechanism": "Underthrust Megathrust Faulting (Subduction Zone)",
            },
            "wave_metrics": {
                "estimated_time_of_arrival_eta": "07:20 UTC (185 min remaining)",
                "time_to_first_wave_minutes": 185,
                "maximum_expected_wave_amplitude_m": 1.4,
                "deep_water_propagation_speed_kmh": 690.0,
                "estimated_inundation_distance_m": 260.0,
                "shoaling_amplification_factor": 3.4,
            },
            "dart_buoys": [
                {
                    "buoy_id": "BPR-TB05",
                    "sea_basin": "Arabian Sea South",
                    "latitude": 11.2000,
                    "longitude": 72.5000,
                    "water_depth_m": 2980.0,
                    "pressure_anomaly_hpa": 3.2,
                    "deep_ocean_wave_amplitude_cm": 12.0,
                    "is_event_mode_triggered": False,
                },
            ],
            "tide_gauges": [
                {
                    "station_id": "INCOIS-TG-COCH",
                    "station_name": "Kochi Willington Island Tide Gauge",
                    "observed_sea_level_m": 0.85,
                    "astronomical_tide_m": 0.78,
                    "tsunami_residual_amplitude_m": 0.07,
                    "last_sample_time_utc": "2026-09-12T04:44:00Z",
                },
            ],
            "evacuation_directives": {
                "vertical_evacuation_altitude_m": 8.0,
                "horizontal_evacuation_distance_km": 0.4,
                "deep_sea_vessel_directive": "All country crafts and tourist boats along backwaters and coastal beaches must remain tied up.",
                "coastal_siren_network_status": "READY: Kerala Disaster Management Authority alerted.",
                "port_cargo_operations_status": "ADVISORY: Kochi Port Trust monitoring tidal oscillations.",
                "designated_safe_shelter_locations": [
                    "Alappuzha Beach High School Relief Camp",
                    "Vizhinjam Marine Research Elevated Center",
                ],
            },
            "localized_bulletins": {
                "en": "TSUNAMI ALERT (ORANGE ALERT): Refracted tsunami wave train approaching southern Kerala coast (Kollam, Alappuzha, Kochi) around 07:20 UTC with up to 1.4m surges. Strong littoral currents expected.",
                "hi": "सुनामी अलर्ट (नारंगी अलर्ट): केरल के कोल्लम, अलப்புझा और कोच्चि में 1.4 मीटर तक की समुद्री लहरें। मछुआरे समुद्र में न जाएं।",
                "ml": "സുനാമി ഓറഞ്ച് അലർട്ട്: കൊല്ലം, ആലപ്പുഴ, കൊച്ചി തീരങ്ങളിൽ 1.4 മീറ്റർ വരെ സുനാമി തിരമാലകൾ 07:20 UTC യോടെ എത്തും. ബീച്ചുകളിൽ നിന്നും തീരത്തു നിന്നും ആളുകൾ മാറിനിൽക്കുക.",
                "ta": "சுனாமி ஆரஞ்சு எச்சரிக்கை: கேரளாவின் கொல்லம் மற்றும் கொச்சி கடற்கரைகளில் 1.4 மீ வரை அலைகள் அதிகரிக்கக்கூடும். கடலில் இறங்க வேண்டாம்.",
            },
        },
        {
            "sector_id": "gujarat_makran_gulf",
            "sector_name": "Gujarat Saurashtra & Makran Approaches (Arabian Sea)",
            "state": "Gujarat",
            "key_coastal_nodes": ["Dwarka", "Okha Port", "Kandla Deendayal Port", "Porbandar"],
            "latitude": 22.2442,
            "longitude": 68.9685,
            "alert_tier": TsunamiAlertTier.WATCH_YELLOW,
            "seismic_source": {
                "moment_magnitude_mw": 7.8,
                "focal_depth_km": 25.0,
                "epicenter_latitude": 24.8000,
                "epicenter_longitude": 63.5000,
                "origin_time_utc": "2026-09-12T03:30:00Z",
                "subduction_zone": TsunamigenicSubductionZone.MAKRAN_SUBDUCTION_ZONE,
                "rupture_mechanism": "Makran Trench Oceanic-Continental Plate Collision",
            },
            "wave_metrics": {
                "estimated_time_of_arrival_eta": "07:30 UTC (240 min elapsed)",
                "time_to_first_wave_minutes": 60,
                "maximum_expected_wave_amplitude_m": 0.65,
                "deep_water_propagation_speed_kmh": 660.0,
                "estimated_inundation_distance_m": 90.0,
                "shoaling_amplification_factor": 2.2,
            },
            "dart_buoys": [
                {
                    "buoy_id": "BPR-TB05",
                    "sea_basin": "North Arabian Sea (Makran)",
                    "latitude": 20.4000,
                    "longitude": 67.2000,
                    "water_depth_m": 3400.0,
                    "pressure_anomaly_hpa": 2.1,
                    "deep_ocean_wave_amplitude_cm": 8.5,
                    "is_event_mode_triggered": False,
                },
            ],
            "tide_gauges": [
                {
                    "station_id": "INCOIS-TG-OKHA",
                    "station_name": "Okha Port Lighthouse Jetty",
                    "observed_sea_level_m": 2.10,
                    "astronomical_tide_m": 2.05,
                    "tsunami_residual_amplitude_m": 0.05,
                    "last_sample_time_utc": "2026-09-12T04:40:00Z",
                },
            ],
            "evacuation_directives": {
                "vertical_evacuation_altitude_m": 5.0,
                "horizontal_evacuation_distance_km": 0.15,
                "deep_sea_vessel_directive": "Moored cargo ships check mooring tension. Minor tidal eddies expected at Gulf of Kutch entrance.",
                "coastal_siren_network_status": "NORMAL STANDBY: Gujarat State Disaster Management Authority informed.",
                "port_cargo_operations_status": "NORMAL: Deendayal Port (Kandla) and Mundra operations continuing with caution.",
                "designated_safe_shelter_locations": [
                    "Dwarka Temple Ridge High Ground",
                    "Okha Port Administration Safe Zone",
                ],
            },
            "localized_bulletins": {
                "en": "TSUNAMI WATCH (YELLOW WATCH): Makran Subduction Zone seismic event producing mild wave heights (<0.7m) along Dwarka and Okha coast. Normal precautions advised.",
                "hi": "सुनामी वॉच (पीला अलर्ट): मकरान क्षेत्र से उत्पन्न हल्की सुनामी लहरें (0.7 मीटर से कम) द्वारका और ओखा तट पर पहुंचने का अनुमान।",
                "gu": "સુનામી વૉચ (પીળી ચેતવણી): મકરાણ સબડક્શન ઝોનમાંથી હળવા મોજાં (<0.7 મીટર) દ્વારકા અને ઓખા કિનારે પહોંચવાની શક્યતા છે. સાવચેતી રાખવી.",
            },
        },
        {
            "sector_id": "lakshadweep_archipelago",
            "sector_name": "Lakshadweep Coral Atoll Archipelago",
            "state": "Lakshadweep (UT)",
            "key_coastal_nodes": ["Kavaratti Island", "Agatti Island", "Minicoy Atoll", "Amini Island"],
            "latitude": 10.5667,
            "longitude": 72.6417,
            "alert_tier": TsunamiAlertTier.ALERT_ORANGE,
            "seismic_source": {
                "moment_magnitude_mw": 8.4,
                "focal_depth_km": 18.0,
                "epicenter_latitude": 9.2500,
                "epicenter_longitude": 93.8500,
                "origin_time_utc": "2026-09-12T04:15:00Z",
                "subduction_zone": TsunamigenicSubductionZone.ANDAMAN_SUMATRA_TRENCH,
                "rupture_mechanism": "Underthrust Megathrust Faulting (Subduction Zone)",
            },
            "wave_metrics": {
                "estimated_time_of_arrival_eta": "07:45 UTC (210 min remaining)",
                "time_to_first_wave_minutes": 210,
                "maximum_expected_wave_amplitude_m": 1.2,
                "deep_water_propagation_speed_kmh": 700.0,
                "estimated_inundation_distance_m": 180.0,
                "shoaling_amplification_factor": 3.1,
            },
            "dart_buoys": [
                {
                    "buoy_id": "BPR-TB05",
                    "sea_basin": "Arabian Sea South",
                    "latitude": 11.2000,
                    "longitude": 72.5000,
                    "water_depth_m": 2980.0,
                    "pressure_anomaly_hpa": 3.2,
                    "deep_ocean_wave_amplitude_cm": 12.0,
                    "is_event_mode_triggered": False,
                },
            ],
            "tide_gauges": [
                {
                    "station_id": "INCOIS-TG-KAVR",
                    "station_name": "Kavaratti Eastern Lagoon Gauge",
                    "observed_sea_level_m": 0.92,
                    "astronomical_tide_m": 0.85,
                    "tsunami_residual_amplitude_m": 0.07,
                    "last_sample_time_utc": "2026-09-12T04:41:00Z",
                },
            ],
            "evacuation_directives": {
                "vertical_evacuation_altitude_m": 4.0,
                "horizontal_evacuation_distance_km": 0.1,
                "deep_sea_vessel_directive": "Due to low island elevation, move residents to upper floors of RCC government buildings, schools, and helipads.",
                "coastal_siren_network_status": "ACTIVATED: Island-wide loudspeakers broadcasting alert.",
                "port_cargo_operations_status": "HALTED: Inter-island ferry service suspended.",
                "designated_safe_shelter_locations": [
                    "Kavaratti Secretariat Multistory Building",
                    "Agatti Airport Terminal Building (Elevated)",
                ],
            },
            "localized_bulletins": {
                "en": "TSUNAMI ALERT (ORANGE ALERT): Low-lying atolls of Lakshadweep (Kavaratti, Agatti, Minicoy) on orange alert. Wave surges up to 1.2m expected inside lagoons. Vertical evacuation to upper concrete floors required.",
                "hi": "सुनामी अलर्ट (नारंगी अलर्ट): लक्षद्वीप के कवारत्ती और अगत्ती द्वीपों में 1.2 मीटर तक ऊंची लहरों की चेतावनी। पक्की इमारतों की ऊपरी मंजिलों पर जाएं।",
                "ml": "സുനാമി ഓറഞ്ച് അലർട്ട്: ലക്ഷദ്വീപ് സമൂഹത്തിൽ (കവരത്തി, അഗത്തി, മിനിക്കോയ്) 1.2 മീറ്റർ ഉയരത്തിൽ സുനാമി തിരകൾ ഉണ്ടാകാം. കോൺക്രീറ്റ് കെട്ടിടങ്ങളുടെ മുകൾ നിലകളിലേക്ക് മാറുക.",
            },
        },
    ]

    @classmethod
    def get_assessment(
        cls,
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        sector_id: Optional[str] = None,
    ) -> TsunamiWarningResponse:
        all_models: List[CoastalForecastSector] = []
        for raw in cls.COASTAL_SECTORS:
            sector = CoastalForecastSector(
                sector_id=raw["sector_id"],
                sector_name=raw["sector_name"],
                state=raw["state"],
                key_coastal_nodes=raw["key_coastal_nodes"],
                latitude=raw["latitude"],
                longitude=raw["longitude"],
                alert_tier=raw["alert_tier"],
                seismic_source=SeismicSourceParameters(**raw["seismic_source"]),
                wave_metrics=CoastalTsunamiWaveMetrics(**raw["wave_metrics"]),
                dart_buoys=[DeepOceanDartBuoy(**b) for b in raw["dart_buoys"]],
                tide_gauges=[CoastalTideGaugeTelemetry(**tg) for tg in raw["tide_gauges"]],
                evacuation_directives=EvacuationAndMaritimeDirectives(**raw["evacuation_directives"]),
                localized_bulletins=raw["localized_bulletins"],
            )
            all_models.append(sector)

        selected = all_models[0]
        if sector_id:
            match = next((s for s in all_models if s.sector_id == sector_id), None)
            if match:
                selected = match
        elif latitude is not None and longitude is not None:
            selected = min(
                all_models,
                key=lambda s: cls._haversine_distance(latitude, longitude, s.latitude, s.longitude),
            )

        now_utc = datetime.now(timezone.utc).isoformat()
        bulletin_ref = f"INCOIS-ITEWS/TSU-WARN/{datetime.now(timezone.utc).strftime('%Y%m')}-{selected.sector_id[:6].upper()}"

        overall_threat = "HIGH ALERT: Active Indian Ocean Tsunamigenic Event Under Surveillance"
        if selected.alert_tier == TsunamiAlertTier.WARNING_RED:
            overall_threat = "CRITICAL: Coastal Inundation Threat (Red Alert) Active"

        return TsunamiWarningResponse(
            timestamp=now_utc,
            bulletin_number=bulletin_ref,
            provenance="Indian National Centre for Ocean Information Services (INCOIS) & National Tsunami Early Warning Centre (ITEWS)",
            threat_status=overall_threat,
            selected_sector=selected,
            all_sectors=all_models,
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
