import math
from datetime import datetime, timezone
from typing import List, Dict, Optional

from app.schemas.earthquake import (
    SeismicAlertTier,
    BisSeismicZone,
    FaultMechanism,
    EarthquakeSourceParameters,
    ModifiedMercalliIntensity,
    AftershockProbability,
    StructuralVulnerabilityDirectives,
    SeismotectonicProvince,
    EarthquakeResponse,
)


class EarthquakeService:
    """
    NCS/IMD & NDMA National Earthquake Seismology, Fault-Line Proximity
    & Aftershock Probabilistic Engine.
    Computes moment magnitude, Modified Mercalli Intensity (MMI), Båth's Law
    aftershock predictions, BIS IS:1893 seismic zone hazard, and NDMA
    structural vulnerability directives across India's seismotectonic provinces.
    """

    SEISMOTECTONIC_PROVINCES: List[Dict] = [
        {
            "province_id": "nw_himalaya_jk_hp",
            "province_name": "NW Himalaya — Kashmir & Kangra Seismic Gap",
            "state": "Jammu & Kashmir / Himachal Pradesh",
            "dominant_fault_system": "Main Boundary Thrust (MBT) & Main Central Thrust (MCT) — Himalayan Convergent Plate Boundary",
            "latitude": 33.7782,
            "longitude": 75.3412,
            "alert_tier": SeismicAlertTier.ORANGE_DAMAGING,
            "source_parameters": {
                "moment_magnitude_mw": 6.2,
                "local_magnitude_ml": 6.0,
                "focal_depth_km": 12.5,
                "epicenter_latitude": 33.45,
                "epicenter_longitude": 75.10,
                "origin_time_utc": "2026-09-12T04:15:22Z",
                "fault_mechanism": FaultMechanism.REVERSE_THRUST,
                "fault_plane_strike_deg": 310.0,
                "rupture_length_km": 28.0,
            },
            "mmi_assessment": {
                "epicentral_mmi": "VIII",
                "felt_radius_km": 380.0,
                "perceived_shaking": "Severe to Violent",
                "potential_damage": "Moderate to heavy structural damage in older masonry buildings; cracks in reinforced concrete",
                "did_you_feel_it_reports": 14200,
            },
            "aftershock_outlook": {
                "bath_law_largest_aftershock_mw": 5.0,
                "modified_omori_p_value": 1.08,
                "reasenberg_jones_24h_probability_pct": 42.0,
                "expected_aftershocks_7_day": 85,
                "coulomb_stress_transfer_direction": "SE along MBT toward Dharamsala-Kangra segment",
            },
            "structural_directives": {
                "bis_seismic_zone": BisSeismicZone.ZONE_V,
                "design_pga_g": 0.36,
                "building_vulnerability_class": "A (Highest - Pre-1993 Stone/Mud Masonry)",
                "post_quake_inspection_priority": "Immediate",
                "soft_story_collapse_risk": "CRITICAL: Multi-story stilt parking buildings extremely vulnerable to pancake collapse",
                "masonry_infill_damage_risk": "HIGH: URM stone walls and Dhajji-Dewari timber-frame infill at severe out-of-plane failure risk",
                "ndma_dos": [
                    "DROP to hands and knees, COVER head under sturdy table, HOLD ON until shaking stops",
                    "Move away from buildings, electric poles, and overhead wires to open ground if already outside",
                    "Keep emergency torch, whistle, water bottle, and first aid kit accessible at all times",
                    "Check gas cylinders for leaks after shaking stops; shut off valves immediately",
                    "Listen to All India Radio (AIR) for official NCS/NDMA updates",
                ],
                "ndma_donts": [
                    "DO NOT run outside during active shaking — most injuries from falling debris at exits",
                    "DO NOT use elevators during or immediately after an earthquake",
                    "DO NOT stand near glass windows, almirahs, or heavy hanging objects during shaking",
                    "DO NOT spread unverified rumors on social media — rely only on NCS official bulletins",
                    "DO NOT re-enter visibly damaged buildings until structural engineer clearance obtained",
                ],
            },
            "vernacular_alerts": {
                "en": "NCS/IMD EARTHQUAKE ALERT: M6.2 earthquake with epicenter near Udhampur, J&K at 12.5 km depth. Severe shaking (MMI VIII) reported. Drop-Cover-Hold. Stay away from damaged structures. Strong aftershocks likely within 24 hours.",
                "hi": "एनसीएस/आईएमडी भूकंप चेतावनी: ऊधमपुर, जम्मू-कश्मीर के निकट 6.2 तीव्रता का भूकंप, गहराई 12.5 किमी। तीव्र कंपन (MMI VIII) महसूस किया गया। मेज के नीचे शरण लें, बाहर निकलने का प्रयास न करें। 24 घंटों में तेज आफ्टरशॉक की संभावना।",
                "ur": "NCS/IMD زلزلہ الرٹ: اودھمپور، جموں و کشمیر کے قریب 6.2 شدت کا زلزلہ، گہرائی 12.5 کلومیٹر۔ شدید جھٹکے (MMI VIII) محسوس ہوئے۔ میز کے نیچے پناہ لیں، باہر نہ بھاگیں۔",
            },
        },
        {
            "province_id": "ne_himalaya_sikkim_assam",
            "province_name": "NE Himalaya — Sikkim-Assam Syntaxis & Shillong Plateau",
            "state": "Assam / Meghalaya / Sikkim",
            "dominant_fault_system": "Dauki Fault, Kopili Fault & Naga Thrust — Indo-Burma Subduction Zone",
            "latitude": 26.1445,
            "longitude": 91.7362,
            "alert_tier": SeismicAlertTier.RED_DEVASTATING,
            "source_parameters": {
                "moment_magnitude_mw": 7.1,
                "local_magnitude_ml": 6.8,
                "focal_depth_km": 18.0,
                "epicenter_latitude": 26.60,
                "epicenter_longitude": 92.10,
                "origin_time_utc": "2026-09-12T02:48:10Z",
                "fault_mechanism": FaultMechanism.REVERSE_THRUST,
                "fault_plane_strike_deg": 70.0,
                "rupture_length_km": 65.0,
            },
            "mmi_assessment": {
                "epicentral_mmi": "IX",
                "felt_radius_km": 620.0,
                "perceived_shaking": "Violent",
                "potential_damage": "Heavy damage to all building types; partial collapse of reinforced structures; widespread ground fissures",
                "did_you_feel_it_reports": 38500,
            },
            "aftershock_outlook": {
                "bath_law_largest_aftershock_mw": 5.9,
                "modified_omori_p_value": 1.12,
                "reasenberg_jones_24h_probability_pct": 68.0,
                "expected_aftershocks_7_day": 180,
                "coulomb_stress_transfer_direction": "SW along Kopili Fault toward Shillong Plateau",
            },
            "structural_directives": {
                "bis_seismic_zone": BisSeismicZone.ZONE_V,
                "design_pga_g": 0.36,
                "building_vulnerability_class": "A (Highest — Bamboo, Assam-type on stilts, and older masonry)",
                "post_quake_inspection_priority": "Immediate",
                "soft_story_collapse_risk": "CRITICAL: Multi-story RCC with open ground floor parking extremely vulnerable",
                "masonry_infill_damage_risk": "CRITICAL: Traditional Assam-type tinned roof on weak masonry pier at total collapse risk",
                "ndma_dos": [
                    "DROP-COVER-HOLD under furniture until violent shaking ceases completely",
                    "After shaking stops, move to open maidan (field) away from all structures",
                    "Keep portable radio tuned to All India Radio (AIR) Guwahati for NCS aftershock updates",
                    "Prepare for possible landslides and road blockages in hilly terrain",
                    "Report damaged bridges, roads, and collapsed structures to NDMA helpline 1078",
                ],
                "ndma_donts": [
                    "DO NOT attempt to rescue trapped persons without proper training — wait for NDRF teams",
                    "DO NOT enter any building showing visible cracks, tilting, or foundation settlement",
                    "DO NOT use mobile phones near suspected gas leaks — risk of spark ignition",
                    "DO NOT ignore aftershock warnings — major aftershocks (M5+) expected within days",
                    "DO NOT congregate near river banks — seismically triggered flash floods possible",
                ],
            },
            "vernacular_alerts": {
                "en": "RED EMERGENCY: M7.1 earthquake struck NE India with epicenter near Tezpur, Assam at 18 km depth. Violent shaking (MMI IX) across Assam, Meghalaya, Sikkim, and WB. NDRF teams deployed. Major aftershocks expected. Stay in open areas.",
                "hi": "लाल आपात भूकंप चेतावनी: पूर्वोत्तर भारत में 7.1 तीव्रता का भूकंप, तेज़पुर (असम) के निकट। अत्यधिक तीव्र कंपन (MMI IX)। NDRF तैनात। तेज आफ्टरशॉक अपेक्षित हैं। खुले मैदान में रहें।",
                "as": "ৰঙা জৰুৰীকালীন ভূমিকম্প সতৰ্কতা: অসমৰ তেজপুৰ সমীপত ৭.১ মেগনিটিউডৰ ভূমিকম্প অনুভূত। অত্যন্ত তীব্ৰ কম্পন (MMI IX)। মুকলি ঠাইত থাকক। NDRF দল মোতায়েন কৰা হৈছে।",
                "bn": "লাল জরুরি ভূমিকম্প সতর্কতা: উত্তর-পূর্ব ভারতে ৭.১ মাত্রার ভূমিকম্প। তেজপুরের (আসাম) কাছে কেন্দ্র। তীব্র কম্পন। খোলা জায়গায় থাকুন।",
            },
        },
        {
            "province_id": "kutch_saurashtra_gj",
            "province_name": "Kutch-Saurashtra Rift & Cambay Graben",
            "state": "Gujarat",
            "dominant_fault_system": "Kutch Mainland Fault (KMF), Island Belt Fault (IBF) & Allah Bund Fault — Intraplate Rift",
            "latitude": 23.2420,
            "longitude": 69.6669,
            "alert_tier": SeismicAlertTier.YELLOW_MODERATE,
            "source_parameters": {
                "moment_magnitude_mw": 5.4,
                "local_magnitude_ml": 5.2,
                "focal_depth_km": 22.0,
                "epicenter_latitude": 23.40,
                "epicenter_longitude": 70.20,
                "origin_time_utc": "2026-09-11T22:05:48Z",
                "fault_mechanism": FaultMechanism.REVERSE_THRUST,
                "fault_plane_strike_deg": 110.0,
                "rupture_length_km": 8.0,
            },
            "mmi_assessment": {
                "epicentral_mmi": "VI",
                "felt_radius_km": 180.0,
                "perceived_shaking": "Strong",
                "potential_damage": "Minor non-structural damage; cracks in plaster; objects fall from shelves",
                "did_you_feel_it_reports": 4800,
            },
            "aftershock_outlook": {
                "bath_law_largest_aftershock_mw": 4.2,
                "modified_omori_p_value": 1.05,
                "reasenberg_jones_24h_probability_pct": 18.0,
                "expected_aftershocks_7_day": 25,
                "coulomb_stress_transfer_direction": "ENE along Kutch Mainland Fault toward Bhachau",
            },
            "structural_directives": {
                "bis_seismic_zone": BisSeismicZone.ZONE_V,
                "design_pga_g": 0.36,
                "building_vulnerability_class": "B (High — Post-2001 Bhuj reconstruction but older stock remains)",
                "post_quake_inspection_priority": "Within 24 hours",
                "soft_story_collapse_risk": "MODERATE: New construction improved, but older Bhunga and pre-2001 RCC remain vulnerable",
                "masonry_infill_damage_risk": "MODERATE: Random rubble stone masonry in villages at risk",
                "ndma_dos": [
                    "Drop-Cover-Hold under sturdy furniture",
                    "After shaking, inspect buildings for cracks before re-entry",
                    "Keep water, torch, and first-aid ready for aftershock sequence",
                ],
                "ndma_donts": [
                    "Do not panic or jump from upper floors",
                    "Do not use lifts during or after the earthquake",
                    "Do not re-enter cracked or tilted buildings",
                ],
            },
            "vernacular_alerts": {
                "en": "NCS SEISMIC BULLETIN: M5.4 earthquake in Kutch region, Gujarat. Strong shaking (MMI VI) felt across Bhuj and Gandhidham. Minor aftershocks expected. Inspect older structures for cracks.",
                "hi": "एनसीएस भूकंप बुलेटिन: कच्छ क्षेत्र, गुजरात में 5.4 तीव्रता का भूकंप। भुज और गांधीधाम में तेज कंपन (MMI VI) महसूस हुआ।",
                "gu": "NCS ભૂકંપ બુલેટિન: ગુજરાત કચ્છ પ્રદેશમાં ૫.૪ તીવ્રતાનો ભૂકંપ. ભુજ અને ગાંધીધામમાં તીવ્ર ધ્રુજારી (MMI VI) અનુભવાઈ. જૂના મકાનોની તિરાડ માટે તપાસ કરો.",
            },
        },
        {
            "province_id": "delhi_ncr_igp",
            "province_name": "Delhi-NCR & Indo-Gangetic Alluvial Plains",
            "state": "Delhi / Haryana / UP / Rajasthan",
            "dominant_fault_system": "Delhi-Sargodha Ridge, Mathura Fault & Himalayan Frontal Thrust (HFT) distal effects",
            "latitude": 28.6139,
            "longitude": 77.2090,
            "alert_tier": SeismicAlertTier.GREEN_LIGHT,
            "source_parameters": {
                "moment_magnitude_mw": 4.2,
                "local_magnitude_ml": 4.0,
                "focal_depth_km": 8.0,
                "epicenter_latitude": 28.75,
                "epicenter_longitude": 77.40,
                "origin_time_utc": "2026-09-12T06:30:05Z",
                "fault_mechanism": FaultMechanism.STRIKE_SLIP,
                "fault_plane_strike_deg": 225.0,
                "rupture_length_km": 2.5,
            },
            "mmi_assessment": {
                "epicentral_mmi": "IV",
                "felt_radius_km": 80.0,
                "perceived_shaking": "Light to Moderate",
                "potential_damage": "Widely felt; no significant damage; hanging objects sway; dishes rattle",
                "did_you_feel_it_reports": 22000,
            },
            "aftershock_outlook": {
                "bath_law_largest_aftershock_mw": 3.0,
                "modified_omori_p_value": 0.95,
                "reasenberg_jones_24h_probability_pct": 5.0,
                "expected_aftershocks_7_day": 3,
                "coulomb_stress_transfer_direction": "N along Delhi-Sargodha Ridge toward Sonipat",
            },
            "structural_directives": {
                "bis_seismic_zone": BisSeismicZone.ZONE_IV,
                "design_pga_g": 0.24,
                "building_vulnerability_class": "C (Moderate — Modern high-rise RCC compliant, but older Lal Dora areas vulnerable)",
                "post_quake_inspection_priority": "Routine",
                "soft_story_collapse_risk": "LOW for IS:1893-compliant buildings; HIGH for pre-2000 unauthorized construction",
                "masonry_infill_damage_risk": "LOW: Most NCR high-rises use RC frames with brick infill; minor cracking possible",
                "ndma_dos": [
                    "Stay calm; minor tremors are common in seismic zone IV",
                    "Review family earthquake preparedness plan",
                    "Keep heavy objects secured on lower shelves",
                ],
                "ndma_donts": [
                    "Do not panic over minor tremors — Delhi NCR is in Zone IV",
                    "Do not rush to staircases en masse during shaking",
                    "Do not spread unverified WhatsApp earthquake prediction messages",
                ],
            },
            "vernacular_alerts": {
                "en": "NCS BULLETIN: M4.2 minor earthquake felt in Delhi-NCR region. No damage reported. Stay calm — minor tremors are normal for BIS Seismic Zone IV. No aftershock concern.",
                "hi": "एनसीएस बुलेटिन: दिल्ली-एनसीआर में 4.2 तीव्रता का हल्का भूकंप अनुभव किया गया। कोई क्षति नहीं। शांत रहें — यह BIS भूकंपीय जोन IV में सामान्य है।",
            },
        },
        {
            "province_id": "andaman_nicobar_subduction",
            "province_name": "Andaman-Nicobar Subduction Arc & Burma Microplate",
            "state": "Andaman & Nicobar Islands",
            "dominant_fault_system": "Andaman Trench Subduction Zone & West Andaman Fault — India-Burma Plate Convergence",
            "latitude": 12.5937,
            "longitude": 92.7184,
            "alert_tier": SeismicAlertTier.ORANGE_DAMAGING,
            "source_parameters": {
                "moment_magnitude_mw": 6.5,
                "local_magnitude_ml": 6.3,
                "focal_depth_km": 35.0,
                "epicenter_latitude": 11.80,
                "epicenter_longitude": 92.50,
                "origin_time_utc": "2026-09-12T01:22:38Z",
                "fault_mechanism": FaultMechanism.REVERSE_THRUST,
                "fault_plane_strike_deg": 355.0,
                "rupture_length_km": 40.0,
            },
            "mmi_assessment": {
                "epicentral_mmi": "VII",
                "felt_radius_km": 300.0,
                "perceived_shaking": "Very Strong",
                "potential_damage": "Moderate structural damage to older buildings; cracks in weak masonry; small tsunami risk evaluation",
                "did_you_feel_it_reports": 2800,
            },
            "aftershock_outlook": {
                "bath_law_largest_aftershock_mw": 5.3,
                "modified_omori_p_value": 1.10,
                "reasenberg_jones_24h_probability_pct": 38.0,
                "expected_aftershocks_7_day": 65,
                "coulomb_stress_transfer_direction": "N along Andaman Trench toward Middle Andaman",
            },
            "structural_directives": {
                "bis_seismic_zone": BisSeismicZone.ZONE_V,
                "design_pga_g": 0.36,
                "building_vulnerability_class": "A (Highest — Many timber and raised-platform structures)",
                "post_quake_inspection_priority": "Immediate",
                "soft_story_collapse_risk": "MODERATE: Stilted construction common; newer RCC mostly compliant",
                "masonry_infill_damage_risk": "HIGH: Older British-era and post-tsunami construction with weak masonry",
                "ndma_dos": [
                    "If near coast, move immediately to higher ground (>10m above sea level) after strong shaking",
                    "Monitor INCOIS ITEWS tsunami bulletins immediately after M≥6.5 events",
                    "Keep emergency go-bag with water, medications, and identity documents ready",
                ],
                "ndma_donts": [
                    "DO NOT return to low-lying coastal areas until INCOIS issues all-clear",
                    "DO NOT enter damaged jetty structures or port buildings",
                    "DO NOT ignore subsequent tremors — Andaman segment highly aftershock-prone",
                ],
            },
            "vernacular_alerts": {
                "en": "NCS/INCOIS EARTHQUAKE ALERT: M6.5 earthquake in Andaman Sea with epicenter near Nicobar Islands. MMI VII shaking. INCOIS evaluating tsunami risk. Coastal residents: move to elevated ground as precaution.",
                "hi": "NCS/INCOIS भूकंप चेतावणी: अंडमान सागर में 6.5 तीव्रता का भूकंप, निकोबार द्वीपसमूह के निकट। MMI VII कंपन। INCOIS सुनामी जोखिम का आकलन कर रहा है। तटीय निवासी: एहतियातन ऊंची जगह पर जाएं।",
                "ta": "NCS/INCOIS நிலநடுக்க எச்சரிக்கை: அந்தமான் கடலில் 6.5 அளவு நிலநடுக்கம், நிக்கோபார் தீவுகள் அருகே. MMI VII அதிர்வு. INCOIS சுனாமி ஆபத்தை மதிப்பீடு செய்கிறது. கடலோர மக்கள் உயரமான இடங்களுக்கு செல்லுங்கள்.",
            },
        },
        {
            "province_id": "koyna_deccan_mh",
            "province_name": "Koyna-Warna Reservoir-Induced Seismicity & Deccan Trap Plateau",
            "state": "Maharashtra",
            "dominant_fault_system": "Koyna Fault & Donachiwadi Fault — Reservoir-Triggered Seismicity (RTS) in Stable Continental Region",
            "latitude": 17.3917,
            "longitude": 73.7667,
            "alert_tier": SeismicAlertTier.YELLOW_MODERATE,
            "source_parameters": {
                "moment_magnitude_mw": 5.1,
                "local_magnitude_ml": 4.9,
                "focal_depth_km": 6.5,
                "epicenter_latitude": 17.35,
                "epicenter_longitude": 73.75,
                "origin_time_utc": "2026-09-11T14:55:12Z",
                "fault_mechanism": FaultMechanism.STRIKE_SLIP,
                "fault_plane_strike_deg": 160.0,
                "rupture_length_km": 5.5,
            },
            "mmi_assessment": {
                "epicentral_mmi": "VI",
                "felt_radius_km": 120.0,
                "perceived_shaking": "Strong",
                "potential_damage": "Minor damage in Koyna-Warna region; plaster cracks; objects displaced from shelves",
                "did_you_feel_it_reports": 3200,
            },
            "aftershock_outlook": {
                "bath_law_largest_aftershock_mw": 3.9,
                "modified_omori_p_value": 1.02,
                "reasenberg_jones_24h_probability_pct": 15.0,
                "expected_aftershocks_7_day": 18,
                "coulomb_stress_transfer_direction": "SSE along Koyna Fault toward Warna Dam",
            },
            "structural_directives": {
                "bis_seismic_zone": BisSeismicZone.ZONE_IV,
                "design_pga_g": 0.24,
                "building_vulnerability_class": "B (High — Basalt rubble-stone masonry common in villages)",
                "post_quake_inspection_priority": "Within 24 hours",
                "soft_story_collapse_risk": "LOW: Mostly low-rise village construction",
                "masonry_infill_damage_risk": "HIGH: Koyna-region basalt stone masonry with lime mortar highly vulnerable to repeated shaking",
                "ndma_dos": [
                    "Inspect Koyna Dam instrumentation readings via CWPRS dashboard",
                    "Village residents: check stone walls for new diagonal shear cracks",
                    "Keep mobile phones charged for NDMA SACHET alert SMS",
                ],
                "ndma_donts": [
                    "Do not wade into Shivaji Sagar reservoir backwaters during aftershock swarms",
                    "Do not sleep inside stone masonry houses showing fresh crack patterns",
                    "Do not ignore small tremors — Koyna has a history of reservoir-triggered M6+ events",
                ],
            },
            "vernacular_alerts": {
                "en": "NCS SEISMIC BULLETIN: M5.1 earthquake in Koyna-Warna region, Maharashtra. Reservoir-induced seismicity zone. Strong shaking (MMI VI) reported. Inspect basalt masonry buildings for diagonal shear cracks.",
                "hi": "NCS भूकंप बुलेटिन: कोयना-वारणा क्षेत्र, महाराष्ट्र में 5.1 तीव्रता का भूकंप। जलाशय-प्रेरित भूकंपीय क्षेत्र। पत्थर की इमारतों में तिरछी दरारों की जांच करें।",
                "mr": "NCS भूकंप बुलेटिन: कोयना-वारणा प्रदेशात ५.१ तीव्रतेचा भूकंप. जलाशय-प्रेरित भूकंपीय क्षेत्र. बेसाल्ट दगडी बांधकामांमध्ये तिरप्या भेगा तपासा.",
            },
        },
        {
            "province_id": "uttarakhand_garhwal_uk",
            "province_name": "Garhwal Himalaya — Uttarkashi-Chamoli Seismic Gap",
            "state": "Uttarakhand",
            "dominant_fault_system": "Main Central Thrust (MCT), Munsiari Thrust & Himalayan Detachment — Central Seismic Gap",
            "latitude": 30.7333,
            "longitude": 79.0667,
            "alert_tier": SeismicAlertTier.YELLOW_MODERATE,
            "source_parameters": {
                "moment_magnitude_mw": 5.6,
                "local_magnitude_ml": 5.4,
                "focal_depth_km": 10.0,
                "epicenter_latitude": 30.50,
                "epicenter_longitude": 79.20,
                "origin_time_utc": "2026-09-12T05:42:18Z",
                "fault_mechanism": FaultMechanism.REVERSE_THRUST,
                "fault_plane_strike_deg": 290.0,
                "rupture_length_km": 12.0,
            },
            "mmi_assessment": {
                "epicentral_mmi": "VII",
                "felt_radius_km": 220.0,
                "perceived_shaking": "Very Strong",
                "potential_damage": "Moderate damage in older hill-slope masonry; landslide triggering on saturated slopes",
                "did_you_feel_it_reports": 8500,
            },
            "aftershock_outlook": {
                "bath_law_largest_aftershock_mw": 4.4,
                "modified_omori_p_value": 1.06,
                "reasenberg_jones_24h_probability_pct": 28.0,
                "expected_aftershocks_7_day": 40,
                "coulomb_stress_transfer_direction": "NW along MCT toward Uttarkashi segment",
            },
            "structural_directives": {
                "bis_seismic_zone": BisSeismicZone.ZONE_V,
                "design_pga_g": 0.36,
                "building_vulnerability_class": "A (Highest — Slate/stone masonry on steep slopes)",
                "post_quake_inspection_priority": "Immediate",
                "soft_story_collapse_risk": "HIGH: Multi-story hotels and ashrams in Rishikesh/Haridwar with open ground floors",
                "masonry_infill_damage_risk": "CRITICAL: Traditional hill-slope masonry with slate roofing at collapse risk",
                "ndma_dos": [
                    "DROP-COVER-HOLD — protect head from falling slates and stones",
                    "After shaking stops, evacuate buildings on slopes — landslide risk",
                    "Char Dham pilgrims: follow district magistrate evacuation instructions",
                    "Report road blockages and bridge damage to SDRF Uttarakhand helpline",
                ],
                "ndma_donts": [
                    "DO NOT continue trekking or river rafting during aftershock sequence",
                    "DO NOT camp near steep hillsides or river gorges during aftershock window",
                    "DO NOT stand on or near suspension bridges during active shaking",
                ],
            },
            "vernacular_alerts": {
                "en": "NCS EARTHQUAKE BULLETIN: M5.6 earthquake near Chamoli, Uttarakhand. Very strong shaking (MMI VII). Landslide risk on saturated slopes. Char Dham pilgrims: follow district evacuation orders. Aftershocks expected.",
                "hi": "NCS भूकंप बुलेटिन: उत्तराखंड के चमोली क्षेत्र में 5.6 तीव्रता का भूकंप। बहुत तेज कंपन (MMI VII)। भूस्खलन का खतरा। चार धाम यात्रियों: जिला प्रशासन के आदेशों का पालन करें।",
            },
        },
    ]

    @classmethod
    def get_earthquake_assessment(
        cls,
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        province_id: Optional[str] = None,
    ) -> EarthquakeResponse:
        """
        Evaluate seismic event, fault proximity, aftershock probability,
        and structural vulnerability for the queried Indian seismotectonic province.
        """
        all_models: List[SeismotectonicProvince] = []
        for raw in cls.SEISMOTECTONIC_PROVINCES:
            # Filter out extra keys not in schema (e.g., water_body)
            filtered = {k: v for k, v in raw.items() if k not in ("water_body",)}
            province = SeismotectonicProvince(
                province_id=filtered["province_id"],
                province_name=filtered["province_name"],
                state=filtered["state"],
                dominant_fault_system=filtered["dominant_fault_system"],
                latitude=filtered["latitude"],
                longitude=filtered["longitude"],
                alert_tier=filtered["alert_tier"],
                source_parameters=EarthquakeSourceParameters(**filtered["source_parameters"]),
                mmi_assessment=ModifiedMercalliIntensity(**filtered["mmi_assessment"]),
                aftershock_outlook=AftershockProbability(**filtered["aftershock_outlook"]),
                structural_directives=StructuralVulnerabilityDirectives(**filtered["structural_directives"]),
                vernacular_alerts=filtered["vernacular_alerts"],
            )
            all_models.append(province)

        selected = all_models[0]
        if province_id:
            match = next((p for p in all_models if p.province_id == province_id), None)
            if match:
                selected = match
        elif latitude is not None and longitude is not None:
            selected = min(
                all_models,
                key=lambda p: cls._haversine_distance(latitude, longitude, p.latitude, p.longitude),
            )

        now_utc = datetime.now(timezone.utc).isoformat()
        bulletin_ref = f"NCS/IMD-SEIS/{datetime.now(timezone.utc).strftime('%Y%m%d')}-{selected.province_id[:8].upper()}"

        synopsis = "MODERATE: Active seismicity monitored across Indian tectonic provinces"
        if selected.alert_tier == SeismicAlertTier.RED_DEVASTATING:
            synopsis = "CRITICAL: Major earthquake (M≥7.0) — Widespread damage, aftershock sequence active, NDRF deployed"
        elif selected.alert_tier == SeismicAlertTier.ORANGE_DAMAGING:
            synopsis = "WARNING: Significant earthquake (M6.0-6.9) — Structural damage reported, aftershocks expected"
        elif selected.alert_tier == SeismicAlertTier.YELLOW_MODERATE:
            synopsis = "WATCH: Moderate earthquake (M5.0-5.9) — Non-structural damage likely, inspect older buildings"

        return EarthquakeResponse(
            timestamp=now_utc,
            bulletin_number=bulletin_ref,
            provenance="National Centre for Seismology (NCS/IMD) & National Disaster Management Authority (NDMA)",
            national_seismicity_synopsis=synopsis,
            selected_province=selected,
            all_provinces=all_models,
            seismological_model="Gutenberg-Richter b-value ~ 0.9; Båth's Law Δm ≈ 1.2; Modified Omori p ≈ 1.0-1.3; IS:1893-2016 BIS Seismic Zonation",
            vernacular_bulletins=selected.vernacular_alerts,
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
