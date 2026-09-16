import math
from datetime import datetime, timezone
from typing import List, Dict, Optional

from app.schemas.hazmat import (
    PasquillStabilityClass,
    ToxicGasSpecies,
    HazmatReleaseSeverity,
    AtmosphericDispersionTelemetry,
    GasToxicityProfile,
    PlumeDispersionMetrics,
    EmergencyResponseProtocol,
    IndustrialChemicalCluster,
    HazmatDispersionResponse,
)


class HazmatService:
    """
    CPCB (Central Pollution Control Board) & IMD Emergency Response Decision Support System.
    Atmospheric Dispersion Modeling & Toxic Gas Plume Nowcasting for High-Density Indian
    Petroleum, Chemicals and Petrochemicals Investment Regions (PCPIR) and Chemical Estates.
    """

    CHEMICAL_CLUSTERS: List[Dict] = [
        {
            "cluster_id": "dahej_pcpir_gujarat",
            "cluster_name": "Dahej Petroleum, Chemicals & Petrochemicals Investment Region (PCPIR)",
            "state": "Gujarat",
            "district": "Bharuch",
            "latitude": 21.7133,
            "longitude": 72.5833,
            "major_industrial_sectors": [
                "Chlor-Alkali & Caustic Soda",
                "Vinyl Chloride Monomer (VCM)",
                "Petrochemical Cracking & Aromatics",
                "Agrochemical Technical Intermediates",
            ],
            "active_gas_profile": {
                "species": ToxicGasSpecies.CHLORINE_CL2,
                "common_name": "Chlorine Gas",
                "chemical_formula": "Cl2",
                "cas_number": "7782-50-5",
                "molecular_weight_g_mol": 70.9,
                "vapor_density_air_ratio": 2.45,
                "odor_threshold_ppm": 0.31,
                "aegl_1_ppm": 0.50,
                "aegl_2_ppm": 2.00,
                "aegl_3_ppm": 20.00,
                "idlh_ppm": 10.00,
            },
            "atmospheric_telemetry": {
                "wind_speed_m_s": 3.2,
                "wind_direction_degrees": 245.0,
                "wind_direction_cardinal": "WSW",
                "pasquill_stability_class": PasquillStabilityClass.CLASS_E_SLIGHTLY_STABLE,
                "mixing_height_m": 350.0,
                "ambient_temp_c": 32.5,
                "relative_humidity_pct": 74.0,
                "solar_radiation_w_m2": 120.0,
                "inversion_layer_present": True,
            },
            "dispersion_metrics": {
                "release_rate_kg_s": 12.5,
                "release_height_m": 8.0,
                "centerline_peak_concentration_ppm": 48.6,
                "protective_action_distance_km": 4.2,
                "initial_isolation_zone_m": 400.0,
                "plume_width_1km_m": 320.0,
                "transit_time_buffer_min": 14.5,
                "severity_tier": HazmatReleaseSeverity.SIGNIFICANT_TANK_LEAK,
            },
            "emergency_protocol": {
                "crosswind_escape_direction": "EVACUATE PERPENDICULAR TO WIND: Move North-Northwest (NNW) towards Luvara or South-Southeast (SSE). Do NOT flee downwind.",
                "shelter_in_place_directives": "Shelter indoors on higher floors (dense gas sinks). Seal door thresholds with damp cloths or towels. Switch off all AC and ventilation units.",
                "recommended_ppe": "Level A fully encapsulating vapor-protective suit with positive-pressure SCBA (Self-Contained Breathing Apparatus).",
                "medical_countermeasures": "Immediate humidified oxygen therapy, nebulized 0.5% sodium bicarbonate solution, inhaled bronchodilators (salbutamol). Decontaminate exposed skin with copious water.",
                "water_spray_curtain_recommended": True,
            },
            "sensitive_downwind_receptors": [
                "Dahej Port Township (2.4 km ENE)",
                "Jageshwar Coastal Habitation (3.8 km ENE)",
                "GIDC Industrial Housing Colony (1.8 km NE)",
            ],
            "localized_bulletins": {
                "en": "WARNING: Significant Chlorine (Cl2) plume dispersion detected at Dahej PCPIR. Low nocturnal mixing depth (350m, Class E) is trapping dense vapor near ground level. Evacuate 400m initial isolation zone immediately crosswind towards NNW.",
                "gu": "ચેતવણી: દહેજ પીસીપીઆઇઆરમાં ક્લોરિન વાયુનું ગંભીર લીકેજ નોંધાયું છે. વાતાવરણમાં સ્થિરતા હોવાથી ઝેરી વાદળ જમીન નજીક ફેલાઈ રહ્યું છે. પવનની વિરુદ્ધ દિશામાં (ઉત્તર-ઉત્તરપશ્ચિમ) ખસી જાઓ અને 400 મીટર વિસ્તાર તાત્કાલિક ખાલી કરો.",
                "hi": "चेतावनी: दहेज पीसीपीआईआर में क्लोरीन गैस के फैलाव का गंभीर अलर्ट। कम मिश्रण ऊंचाई के कारण भारी क्लोरीन गैस जमीन के पास फैल रही है। 400 मीटर के दायरे को तत्काल खाली करें और हवा की दिशा के लंबवत (क्रॉसविंड) सुरक्षित स्थान पर जाएं।",
                "ta": "எச்சரிக்கை: குஜராத் தஹேஜ் பெட்ரோ கெமிக்கல் மண்டலத்தில் குளோரின் நச்சு வாயு கசிவு பதிவாகியுள்ளது. காற்று மட்டம் தாழ்வாக உள்ளதால் வாயு தரையோடு பரவுகிறது. உடனடியாக 400 மீட்டர் சுற்றளவை விட்டு விலகி குறுக்கு திசையில் பாதுகாப்பான இடம் நோக்கி செல்லவும்.",
                "te": "హెచ్చరిక: దహేజ్ పీసీపీఐఆర్ పారిశ్రామిక ప్రాంతంలో క్లోరిన్ గ్యాస్ లీకేజ్ నమోదైంది. విష వాయువు నేలమట్టంలో వ్యాపిస్తున్నందున తక్షణమే 400 మీటర్ల పరిధిని ఖాళీ చేసి గాలి వీచే దిశకు అడ్డంగా తరలివెళ్ళండి.",
            },
        },
        {
            "cluster_id": "manali_industrial_corridor_chennai",
            "cluster_name": "Manali Petrochemical & Fertilizer Complex (Chennai)",
            "state": "Tamil Nadu",
            "district": "Chennai / Tiruvallur",
            "latitude": 13.1667,
            "longitude": 80.2667,
            "major_industrial_sectors": [
                "Nitrogenous Fertilizer (Urea / Ammonia)",
                "Petroleum Refining (CPCL)",
                "Epichlorohydrin & Polyols",
                "Synthetic Rubbers & Polybutenes",
            ],
            "active_gas_profile": {
                "species": ToxicGasSpecies.AMMONIA_NH3,
                "common_name": "Anhydrous Ammonia",
                "chemical_formula": "NH3",
                "cas_number": "7664-41-7",
                "molecular_weight_g_mol": 17.03,
                "vapor_density_air_ratio": 0.59,
                "odor_threshold_ppm": 5.0,
                "aegl_1_ppm": 30.0,
                "aegl_2_ppm": 160.0,
                "aegl_3_ppm": 1100.0,
                "idlh_ppm": 300.0,
            },
            "atmospheric_telemetry": {
                "wind_speed_m_s": 4.5,
                "wind_direction_degrees": 65.0,
                "wind_direction_cardinal": "ENE",
                "pasquill_stability_class": PasquillStabilityClass.CLASS_D_NEUTRAL,
                "mixing_height_m": 600.0,
                "ambient_temp_c": 31.0,
                "relative_humidity_pct": 82.0,
                "solar_radiation_w_m2": 450.0,
                "inversion_layer_present": False,
            },
            "dispersion_metrics": {
                "release_rate_kg_s": 25.0,
                "release_height_m": 12.0,
                "centerline_peak_concentration_ppm": 340.0,
                "protective_action_distance_km": 3.5,
                "initial_isolation_zone_m": 300.0,
                "plume_width_1km_m": 290.0,
                "transit_time_buffer_min": 11.2,
                "severity_tier": HazmatReleaseSeverity.SIGNIFICANT_TANK_LEAK,
            },
            "emergency_protocol": {
                "crosswind_escape_direction": "EVACUATE CROSSWIND: Move North-Northwest towards Madhavaram or South-Southeast toward Thiruvottiyur. Escape coastal onshore plume.",
                "shelter_in_place_directives": "Stay indoors, close all windows, shut down split ACs. Hold a wet cloth over nose and mouth (ammonia is highly soluble in water).",
                "recommended_ppe": "Level B splash suit with positive-pressure airline respirator or SCBA with ammonia-rated canisters.",
                "medical_countermeasures": "Flush eyes and skin with water for at least 15 minutes. Administer humidified oxygen. Treat chemical burns with saline rinses.",
                "water_spray_curtain_recommended": True,
            },
            "sensitive_downwind_receptors": [
                "Manali New Town Habitations (1.5 km WSW)",
                "Madhavaram Milk Colony Residential Buffer (3.1 km WSW)",
                "Kaviarasu Kannadasan Nagar (3.4 km SW)",
            ],
            "localized_bulletins": {
                "en": "EMERGENCY: High-concentration Ammonia (NH3) vapor release at Manali Petrochemical Corridor. Peak concentration exceeds IDLH (340 ppm vs 300 ppm threshold). Maintain 300m initial isolation; cover nose and mouth with wet fabric.",
                "ta": "அவசர எச்சரிக்கை: மணலி தொழிற்பேட்டையில் அம்மோனியா வாயு கசிவு (340 ppm) அபாய அளவை தாண்டியுள்ளது. 300 மீட்டர் சுற்றளவை உடனடியாக காலி செய்யவும். ஈரமான துணியால் மூக்கு மற்றும் வாயை மூடிக்கொண்டு குறுக்கு திசையில் வெளியேறவும்.",
                "hi": "आपातकालीन चेतावनी: मनाली पेट्रोकेमिकल परिसर (चेन्नई) में अमोनिया गैस का भारी रिसाव। सांद्रता खतरे के निशान (340 ppm) से अधिक। 300 मीटर आइसोलेशन क्षेत्र खाली करें और गीले कपड़े से मुंह-नाक ढकें।",
                "gu": "તાત્કાલિક ચેતવણી: મનાલી પેટ્રોકેમિકલ કોરિડોરમાં એમોનિયા ગેસનું લીકેજ. 300 મીટર સુરક્ષિત અંતર જાળવો અને મોં પર ભીનું કપડું રાખીને સુરક્ષિત સ્થળે ખસો.",
                "te": "అత్యవసర హెచ్చరిక: మనాలి పెట్రోకెమికల్ కారిడార్‌లో అమ్మోనియా గ్యాస్ లీకేజ్. 300 మీటర్ల పరిధిని ఖాళీ చేయండి; తడి గుడ్డతో ముక్కు, నోరు కప్పుకోండి.",
            },
        },
        {
            "cluster_id": "visakhapatnam_pharma_city",
            "cluster_name": "Jawaharlal Nehru Pharma City (Parawada, Vizag)",
            "state": "Andhra Pradesh",
            "district": "Anakapalli / Visakhapatnam",
            "latitude": 17.6214,
            "longitude": 83.0845,
            "major_industrial_sectors": [
                "Active Pharmaceutical Ingredients (API)",
                "Bulk Drug Intermediate Synthesis",
                "Solvent Distillation & Recovery Units",
                "Sulfur Chemistry & Heterocyclic Processing",
            ],
            "active_gas_profile": {
                "species": ToxicGasSpecies.HYDROGEN_SULFIDE_H2S,
                "common_name": "Hydrogen Sulfide",
                "chemical_formula": "H2S",
                "cas_number": "7783-06-4",
                "molecular_weight_g_mol": 34.08,
                "vapor_density_air_ratio": 1.19,
                "odor_threshold_ppm": 0.008,
                "aegl_1_ppm": 0.51,
                "aegl_2_ppm": 27.00,
                "aegl_3_ppm": 50.00,
                "idlh_ppm": 100.00,
            },
            "atmospheric_telemetry": {
                "wind_speed_m_s": 2.8,
                "wind_direction_degrees": 135.0,
                "wind_direction_cardinal": "SE",
                "pasquill_stability_class": PasquillStabilityClass.CLASS_C_SLIGHTLY_UNSTABLE,
                "mixing_height_m": 500.0,
                "ambient_temp_c": 30.2,
                "relative_humidity_pct": 78.0,
                "solar_radiation_w_m2": 380.0,
                "inversion_layer_present": False,
            },
            "dispersion_metrics": {
                "release_rate_kg_s": 4.8,
                "release_height_m": 5.0,
                "centerline_peak_concentration_ppm": 62.0,
                "protective_action_distance_km": 2.8,
                "initial_isolation_zone_m": 250.0,
                "plume_width_1km_m": 260.0,
                "transit_time_buffer_min": 16.0,
                "severity_tier": HazmatReleaseSeverity.SIGNIFICANT_TANK_LEAK,
            },
            "emergency_protocol": {
                "crosswind_escape_direction": "EVACUATE CROSSWIND: Move Northeast toward Kurmannapalem or Southwest toward Atchutapuram. Do not linger in low depressions or valleys.",
                "shelter_in_place_directives": "Shelter in upper floors. Olfactory fatigue occurs rapidly above 50 ppm (rotten egg smell disappears despite lethal concentrations).",
                "recommended_ppe": "Level A/B positive-pressure SCBA. H2S is pyrophoric/flammable; use intrinsically safe instruments.",
                "medical_countermeasures": "High-flow 100% normobaric oxygen. In severe cyanide-like respiratory arrest, administer sodium nitrite or amyl nitrite inhalant under clinical supervision.",
                "water_spray_curtain_recommended": False,
            },
            "sensitive_downwind_receptors": [
                "Parawada Village Settlement (1.2 km NW)",
                "Tadi Rural Habitation (2.3 km NW)",
                "Lankelapalem Junction (2.7 km NNW)",
            ],
            "localized_bulletins": {
                "en": "WARNING: Hydrogen Sulfide (H2S) toxic emission at JNPC Parawada Pharma City. Current plume peak (62 ppm) exceeds AEGL-3 threshold. Rapid olfactory fatigue risk: lack of smell does NOT indicate safety. Evacuate 250m crosswind.",
                "te": "హెచ్చరిక: జేఎన్‌పీసీ పరవాడ ఫార్మా సిటీలో హైడ్రోజన్ సల్ఫైడ్ (H2S) గ్యాస్ లీకేజ్. కుళ్ళిన గుడ్ల వాసన ఆగిపోయినా ప్రమాదం పొంచి ఉంది. తక్షణమే 250 మీటర్ల ప్రాంతం నుండి బయటకు రండి.",
                "hi": "चेतावनी: विशाखापट्टनम परवाडा फार्मा सिटी में हाइड्रोजन सल्फाइड (H2S) का रिसाव। 50 ppm से ऊपर सूंघने की क्षमता समाप्त हो जाती है। तुरंत 250 मीटर का घेरा खाली करें।",
                "ta": "எச்சரிக்கை: விசாகப்பட்டினம் பரவாடா பார்மா சிட்டியில் ஹைட்ரஜன் சல்பைட் வாயு கசிவு. மூக்கின் நுகரும் தன்மை மங்கிவிடும் அபாயம் உள்ளதால் வாடை வரவில்லை என்றாலும் பாதுகாப்பு இல்லை. 250 மீ தூரம் வெளியேறவும்.",
                "gu": "ચેતવણી: વિશાખાપટ્ટનમ પરવાડા ફાર્મા સિટીમાં હાઇડ્રોજન સલ્ફાઇડ વાયુનું ઉત્સર્જન. ગંધ ન આવે તો પણ જોખમ રહેલું છે. 250 મીટરનો વિસ્તાર તાત્કાલિક ખાલી કરો.",
            },
        },
        {
            "cluster_id": "rasayani_taloja_midc",
            "cluster_name": "Taloja & Rasayani MIDC Chemical Industrial Belt (Navi Mumbai)",
            "state": "Maharashtra",
            "district": "Raigad / Thane",
            "latitude": 19.0667,
            "longitude": 73.1167,
            "major_industrial_sectors": [
                "Phosgenation & Isocyanate Chemistry",
                "Specialty Intermediates & Polyurethanes",
                "Dyes & Organic Pigments",
                "Hazardous Waste Treatment & Incineration",
            ],
            "active_gas_profile": {
                "species": ToxicGasSpecies.PHOSGENE_COCL2,
                "common_name": "Phosgene (Carbonyl Chloride)",
                "chemical_formula": "COCl2",
                "cas_number": "75-44-5",
                "molecular_weight_g_mol": 98.92,
                "vapor_density_air_ratio": 3.41,
                "odor_threshold_ppm": 0.40,
                "aegl_1_ppm": 0.15,
                "aegl_2_ppm": 0.60,
                "aegl_3_ppm": 1.50,
                "idlh_ppm": 2.00,
            },
            "atmospheric_telemetry": {
                "wind_speed_m_s": 1.8,
                "wind_direction_degrees": 315.0,
                "wind_direction_cardinal": "NW",
                "pasquill_stability_class": PasquillStabilityClass.CLASS_F_MODERATELY_STABLE,
                "mixing_height_m": 220.0,
                "ambient_temp_c": 27.5,
                "relative_humidity_pct": 68.0,
                "solar_radiation_w_m2": 40.0,
                "inversion_layer_present": True,
            },
            "dispersion_metrics": {
                "release_rate_kg_s": 1.2,
                "release_height_m": 4.0,
                "centerline_peak_concentration_ppm": 3.8,
                "protective_action_distance_km": 5.5,
                "initial_isolation_zone_m": 500.0,
                "plume_width_1km_m": 210.0,
                "transit_time_buffer_min": 22.0,
                "severity_tier": HazmatReleaseSeverity.CATASTROPHIC_VESSEL_RUPTURE,
            },
            "emergency_protocol": {
                "crosswind_escape_direction": "EVACUATE CROSSWIND TO HIGHER ELEVATION: Move East-Northeast towards Kharghar Hills. Heavy gas (density 3.41) settles in Kasardi river basin.",
                "shelter_in_place_directives": "Shelter in top-floor concrete rooms. Close all openings. Ammonia aerosol knock-down systems active at facility boundary.",
                "recommended_ppe": "Level A encapsulating chemical suit with positive-pressure SCBA. Skin contact and delayed lung alveoli hydrolysis hazard.",
                "medical_countermeasures": "CRITICAL: Strict absolute physical rest (exertion accelerates pulmonary edema). Hospitalization and observation for minimum 24-48 hours. Nebulized N-acetylcysteine and dexamethasone.",
                "water_spray_curtain_recommended": True,
            },
            "sensitive_downwind_receptors": [
                "Taloja Village & Housing Board (1.6 km SE)",
                "Navi Mumbai Metro Corridor Depot (2.9 km SE)",
                "Panvel Outskirts Settlement (5.2 km SE)",
            ],
            "localized_bulletins": {
                "en": "CRITICAL ALERT: Phosgene (COCl2) release at Taloja MIDC under nocturnal inversion (Class F). Ground-level concentration is 3.8 ppm (exceeds IDLH 2.0 ppm). Evacuate 500m IIZ crosswind toward higher elevations; delayed lung symptoms require immediate clinical rest.",
                "hi": "गंभीर चेतावनी: तलोजा एमआईडीसी में फॉसजीन (COCl2) गैस का घातक रिसाव। रात्रि तापीय उलटाव (क्लास F) के कारण अत्यधिक भारी गैस जमीन पर जमी है। 500 मीटर क्षेत्र खाली करें और तुरंत ऊंचे स्थानों की ओर जाएं।",
                "gu": "ગંભીર ચેતવણી: તલોજા એમઆઈડીસીમાં ફોસ્જીન ગેસનું ખતરનાક લીકેજ. ભારે વાયુ જમીન પર જમા થઈ રહ્યો છે. 500 મીટરનો વિસ્તાર તાત્કાલિક ખાલી કરો અને ઊંચા સ્થળો તરફ ખસો.",
                "ta": "தீவிர எச்சரிக்கை: தலோஜா தொழிற்பேட்டையில் பாஸ்ஜீன் நச்சு வாயு வெளியேற்றம். வாயு மிக அதிக எடையுடையது என்பதால் தரைமட்டத்தில் தேங்குகிறது. 500 மீட்டர் பகுதியை உடனடியாக காலி செய்து மேடான பகுதிக்கு செல்லவும்.",
                "te": "తీవ్ర హెచ్చరిక: తలోజా ఎంఐడీసీలో ఫాస్జీన్ విష వాయువు లీకేజ్. రాత్రిపూట గాలులు లేకపోవడంతో గ్యాస్ నేలపైనే ఉంది. 500 మీటర్ల ప్రాంతం ఖాళీ చేసి ఎత్తైన ప్రాంతాలకు వెళ్లండి.",
            },
        },
        {
            "cluster_id": "vapi_chemical_estate",
            "cluster_name": "Vapi & Ankleshwar GIDC Industrial Chemical Core",
            "state": "Gujarat",
            "district": "Valsad / Bharuch",
            "latitude": 20.3700,
            "longitude": 72.9100,
            "major_industrial_sectors": [
                "Dyes, Pigments & Textile Chemicals",
                "Sulfuric Acid & Oleum Plants",
                "Pesticides & Chlorinated Organic Synthesis",
                "Bulk Chemical Storage Terminals",
            ],
            "active_gas_profile": {
                "species": ToxicGasSpecies.SULFUR_DIOXIDE_SO2,
                "common_name": "Sulfur Dioxide",
                "chemical_formula": "SO2",
                "cas_number": "7446-09-5",
                "molecular_weight_g_mol": 64.07,
                "vapor_density_air_ratio": 2.26,
                "odor_threshold_ppm": 0.50,
                "aegl_1_ppm": 0.20,
                "aegl_2_ppm": 0.75,
                "aegl_3_ppm": 30.00,
                "idlh_ppm": 100.00,
            },
            "atmospheric_telemetry": {
                "wind_speed_m_s": 3.8,
                "wind_direction_degrees": 220.0,
                "wind_direction_cardinal": "SW",
                "pasquill_stability_class": PasquillStabilityClass.CLASS_D_NEUTRAL,
                "mixing_height_m": 550.0,
                "ambient_temp_c": 33.0,
                "relative_humidity_pct": 71.0,
                "solar_radiation_w_m2": 520.0,
                "inversion_layer_present": False,
            },
            "dispersion_metrics": {
                "release_rate_kg_s": 18.0,
                "release_height_m": 15.0,
                "centerline_peak_concentration_ppm": 42.0,
                "protective_action_distance_km": 3.1,
                "initial_isolation_zone_m": 200.0,
                "plume_width_1km_m": 310.0,
                "transit_time_buffer_min": 13.0,
                "severity_tier": HazmatReleaseSeverity.CONTROLLED_FLARING,
            },
            "emergency_protocol": {
                "crosswind_escape_direction": "EVACUATE CROSSWIND: Move Northwest towards Daman road or Southeast towards Lavachha.",
                "shelter_in_place_directives": "Close all ventilation. Breath through damp cloth to absorb choking acidic sulfurous vapors.",
                "recommended_ppe": "Level B chemical-resistant suit with acid gas canister respirator or SCBA.",
                "medical_countermeasures": "Administer humidified oxygen, nebulized bronchodilators. Irrigate respiratory passages with sterile saline.",
                "water_spray_curtain_recommended": True,
            },
            "sensitive_downwind_receptors": [
                "Vapi Town Market Area (2.1 km NE)",
                "Chharwada Residential Sector (2.8 km NE)",
                "NH-48 Corridor Transit Buffer (1.4 km ENE)",
            ],
            "localized_bulletins": {
                "en": "ADVISORY: Sulfur Dioxide (SO2) elevated concentration plume at Vapi GIDC. Ground concentration 42 ppm exceeds AEGL-3 threshold (30 ppm). Vulnerable asthma and COPD patients shelter indoors immediately.",
                "gu": "સૂચના: વાપી જીઆઈડીસીમાં સલ્ફર ડાયોક્સાઇડ (SO2) વાયુનું ઊંચું પ્રમાણ. અસ્થમા અને શ્વાસના દર્દીઓ તાત્કાલિક ઘરમાં જ રહે અને બારી-બારણાં બંધ રાખે.",
                "hi": "सलाह: वापी जीआईडीसी में सल्फर डाइऑक्साइड (SO2) गैस का स्तर 42 ppm तक बढ़ा। सांस और दमे के मरीज तुरंत घर के अंदर रहें और खिड़कियां बंद रखें।",
                "ta": "அறிவுறுத்தல்: வாபி ஜிஐடிசி பகுதியில் சல்பர் டை ஆக்சைடு வாயு அதிகரித்துள்ளது. ஆஸ்துமா நோயாளிகள் உடனடியாக வீடுகளுக்குள் இருக்கவும்.",
                "te": "సలహా: వాపి జీఐడీసీలో సల్ఫర్ డయాక్సైడ్ పెరిగింది. ఉబ్బసం రోగులు ఇంట్లోనే ఉండండి, తలుపులు మూసివేయండి.",
            },
        },
        {
            "cluster_id": "haldia_industrial_complex",
            "cluster_name": "Haldia Petrochemicals & Port Chemical Complex",
            "state": "West Bengal",
            "district": "Purba Medinipur",
            "latitude": 22.0667,
            "longitude": 88.0667,
            "major_industrial_sectors": [
                "Naphtha Cracking & Aromatics",
                "Benzene, Toluene & Xylene Extraction",
                "Polyethylene & Polypropylene Manufacturing",
                "Coastal Port Chemical Storage Terminals",
            ],
            "active_gas_profile": {
                "species": ToxicGasSpecies.BENZENE_C6H6,
                "common_name": "Benzene Vapor",
                "chemical_formula": "C6H6",
                "cas_number": "71-43-2",
                "molecular_weight_g_mol": 78.11,
                "vapor_density_air_ratio": 2.77,
                "odor_threshold_ppm": 1.50,
                "aegl_1_ppm": 52.0,
                "aegl_2_ppm": 800.0,
                "aegl_3_ppm": 2000.0,
                "idlh_ppm": 500.0,
            },
            "atmospheric_telemetry": {
                "wind_speed_m_s": 5.1,
                "wind_direction_degrees": 160.0,
                "wind_direction_cardinal": "SSE",
                "pasquill_stability_class": PasquillStabilityClass.CLASS_C_SLIGHTLY_UNSTABLE,
                "mixing_height_m": 750.0,
                "ambient_temp_c": 30.8,
                "relative_humidity_pct": 85.0,
                "solar_radiation_w_m2": 610.0,
                "inversion_layer_present": False,
            },
            "dispersion_metrics": {
                "release_rate_kg_s": 8.5,
                "release_height_m": 10.0,
                "centerline_peak_concentration_ppm": 215.0,
                "protective_action_distance_km": 2.1,
                "initial_isolation_zone_m": 150.0,
                "plume_width_1km_m": 280.0,
                "transit_time_buffer_min": 10.0,
                "severity_tier": HazmatReleaseSeverity.MINOR_FUGITIVE_EMISSION,
            },
            "emergency_protocol": {
                "crosswind_escape_direction": "EVACUATE CROSSWIND: Move East toward Hooghly riverbank or West toward Sutahata.",
                "shelter_in_place_directives": "Shelter indoors. Benzene is a Group 1 carcinogen and CNS depressant. Prevent static spark ignition (flammable vapor).",
                "recommended_ppe": "Level B organic vapor SCBA with anti-static spark-proof protective suits.",
                "medical_countermeasures": "Remove from exposure, administer 100% oxygen. Avoid epinephrine due to risk of ventricular arrhythmias.",
                "water_spray_curtain_recommended": True,
            },
            "sensitive_downwind_receptors": [
                "Haldia Port Township (1.8 km NNW)",
                "Durgachak Habitation Sector (3.2 km NNW)",
                "IOCL Refinery Township (2.4 km N)",
            ],
            "localized_bulletins": {
                "en": "ADVISORY: Benzene aromatic vapor fugitive release detected at Haldia Petrochemicals. Volatile organic vapor concentration 215 ppm. Eliminate all open flames and ignition sources; evacuate 150m initial zone.",
                "hi": "सलाह: हल्दिया पेट्रोकेमिकल्स में बेंजीन वाष्प का रिसाव (215 ppm)। सभी अग्नि स्रोत और स्पार्क तुरंत बंद करें। 150 मीटर के क्षेत्र को सुरक्षित रखें।",
                "ta": "அறிவுறுத்தல்: ஹால்டியா பெட்ரோகெமிக்கல்ஸ் பகுதியில் பென்சீன் ஆவி வெளியேற்றம் கண்டறியப்பட்டுள்ளது. தீப்பிடிக்கும் அபாயம் உள்ளதால் கவனமாக இருக்கவும்.",
                "gu": "સૂચના: હલ્દિયા પેટ્રોકેમિકલ્સમાં બેન્ઝીન વરાળનું લીકેજ. કોઈ પણ પ્રકારના અગ્નિ સ્રોતો ચાલુ ન કરો. 150 મીટરનું અંતર જાળવો.",
                "te": "సలహా: హల్దియా పెట్రోకెమికల్స్ వద్ద బెంజీన్ వేపర్ లీక్. అగ్ని ప్రమాద నివారణ చర్యలు తీసుకోండి, 150 మీటర్ల దూరం ఉండండి.",
            },
        },
        {
            "cluster_id": "bhopal_mandideep_industrial",
            "cluster_name": "Mandideep & Govindpura Industrial Corridor (Bhopal Region)",
            "state": "Madhya Pradesh",
            "district": "Raisen / Bhopal",
            "latitude": 23.0800,
            "longitude": 77.5200,
            "major_industrial_sectors": [
                "Agrochemical Synthesis & Formulation",
                "Solvent Extraction & Processing",
                "Electro-chemical & Battery Production",
                "Industrial Resins & Polymers",
            ],
            "active_gas_profile": {
                "species": ToxicGasSpecies.CHLORINE_CL2,
                "common_name": "Chlorine Gas",
                "chemical_formula": "Cl2",
                "cas_number": "7782-50-5",
                "molecular_weight_g_mol": 70.9,
                "vapor_density_air_ratio": 2.45,
                "odor_threshold_ppm": 0.31,
                "aegl_1_ppm": 0.50,
                "aegl_2_ppm": 2.00,
                "aegl_3_ppm": 20.00,
                "idlh_ppm": 10.00,
            },
            "atmospheric_telemetry": {
                "wind_speed_m_s": 2.2,
                "wind_direction_degrees": 290.0,
                "wind_direction_cardinal": "WNW",
                "pasquill_stability_class": PasquillStabilityClass.CLASS_E_SLIGHTLY_STABLE,
                "mixing_height_m": 310.0,
                "ambient_temp_c": 28.5,
                "relative_humidity_pct": 55.0,
                "solar_radiation_w_m2": 180.0,
                "inversion_layer_present": True,
            },
            "dispersion_metrics": {
                "release_rate_kg_s": 6.0,
                "release_height_m": 6.0,
                "centerline_peak_concentration_ppm": 24.5,
                "protective_action_distance_km": 2.4,
                "initial_isolation_zone_m": 250.0,
                "plume_width_1km_m": 240.0,
                "transit_time_buffer_min": 18.0,
                "severity_tier": HazmatReleaseSeverity.SIGNIFICANT_TANK_LEAK,
            },
            "emergency_protocol": {
                "crosswind_escape_direction": "EVACUATE CROSSWIND: Move South-Southwest towards Dahod dam ridge or North-Northeast toward Misrod. Avoid low-lying Betwa drainage nullahs.",
                "shelter_in_place_directives": "Seal all doors and windows. Move to highest room in the house. Place wet towels at door gaps.",
                "recommended_ppe": "Level A/B positive-pressure SCBA with chemical splash suits.",
                "medical_countermeasures": "Humidified oxygen therapy, nebulized bronchodilators, ophthalmic irrigation for eye pain.",
                "water_spray_curtain_recommended": True,
            },
            "sensitive_downwind_receptors": [
                "Mandideep Township Sector A (1.3 km ESE)",
                "Bhopal-Hoshangabad Highway Transit Corridor (1.9 km E)",
                "Samardha Rural Habitation (2.5 km ESE)",
            ],
            "localized_bulletins": {
                "en": "WARNING: Toxic chemical plume advisory for Mandideep Industrial Area. Ground-level Chlorine concentration (24.5 ppm) exceeds AEGL-3 threshold (20 ppm). Evacuate 250m IIZ crosswind; seal upper floor residential rooms.",
                "hi": "चेतावनी: मंडीदीप औद्योगिक क्षेत्र में क्लोरीन गैस का रिसाव (24.5 ppm)। कम ऊंचाई के मिश्रण और स्थिर हवा के कारण गैस आबादी की ओर बढ़ रही है। 250 मीटर दायरा खाली करें और ऊपरी मंजिल के कमरों में खिड़कियां सील करें।",
                "ta": "எச்சரிக்கை: மண்டிதீப் தொழிற்பேட்டை பகுதியில் குளோரின் வாயு கசிவு. உடனடியாக 250 மீ சுற்றளவை காலி செய்து பாதுகாப்பாக இருக்கவும்.",
                "gu": "ચેતવણી: મંડીદીપ ઔદ્યોગિક ક્ષેત્રમાં ક્લોરિન વાયુ લીકેજ. 250 મીટરનો વિસ્તાર તાત્કાલિક ખાલી કરો.",
                "te": "హెచ్చరిక: మండిదీప్ పారిశ్రామిక ప్రాంతంలో క్లోరిన్ గ్యాస్ లీకేజ్. 250 మీటర్ల ప్రాంతం ఖాళీ చేయండి.",
            },
        },
    ]

    @classmethod
    def get_assessment(
        cls,
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        cluster_id: Optional[str] = None,
        gas_species: Optional[str] = None,
    ) -> HazmatDispersionResponse:
        """
        Retrieves atmospheric dispersion modeling and toxic gas plume nowcasting.
        Selects target chemical cluster via explicit ID, gas species filter, or geodetic Haversine proximity.
        """
        all_models: List[IndustrialChemicalCluster] = []
        for raw in cls.CHEMICAL_CLUSTERS:
            cluster = IndustrialChemicalCluster(
                cluster_id=raw["cluster_id"],
                cluster_name=raw["cluster_name"],
                state=raw["state"],
                district=raw["district"],
                latitude=raw["latitude"],
                longitude=raw["longitude"],
                major_industrial_sectors=raw["major_industrial_sectors"],
                active_gas_profile=GasToxicityProfile(**raw["active_gas_profile"]),
                atmospheric_telemetry=AtmosphericDispersionTelemetry(**raw["atmospheric_telemetry"]),
                dispersion_metrics=PlumeDispersionMetrics(**raw["dispersion_metrics"]),
                emergency_protocol=EmergencyResponseProtocol(**raw["emergency_protocol"]),
                sensitive_downwind_receptors=raw["sensitive_downwind_receptors"],
                localized_bulletins=raw["localized_bulletins"],
            )
            all_models.append(cluster)

        selected = all_models[0]
        if cluster_id:
            match = next((c for c in all_models if c.cluster_id == cluster_id), None)
            if match:
                selected = match
        elif gas_species:
            match = next((c for c in all_models if c.active_gas_profile.species.value == gas_species or c.active_gas_profile.chemical_formula == gas_species), None)
            if match:
                selected = match
        elif latitude is not None and longitude is not None:
            selected = min(
                all_models,
                key=lambda c: cls._haversine_distance(latitude, longitude, c.latitude, c.longitude),
            )

        now_utc = datetime.now(timezone.utc).isoformat()
        bulletin_ref = f"CPCB-IMD/HAZMAT-ADPE/{datetime.now(timezone.utc).strftime('%Y%m')}-{selected.cluster_id[:6].upper()}"

        return HazmatDispersionResponse(
            timestamp=now_utc,
            bulletin_number=bulletin_ref,
            provenance="CPCB Central Pollution Control Board & IMD Emergency Response Decision Support System",
            selected_cluster=selected,
            all_clusters=all_models,
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
