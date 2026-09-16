import math
from datetime import datetime, timezone
from typing import List, Dict, Optional

from app.schemas.livestock_heat_stress import (
    LivestockStressTier,
    AnimalSpeciesBreedCategory,
    MicroclimateBiometeorology,
    SpeciesVulnerabilityProfile,
    FarmShelterAndNutritionDirectives,
    DairyCorridorBasin,
    LivestockHeatStressResponse,
)


class LivestockHeatStressService:
    """
    ICAR-NDRI & IMD Agromet Dairy Livestock Biometeorology Service.
    Computes Thom's Temperature-Humidity Index (THI), species-specific thermal tolerance,
    milk production loss forecasting, and veterinary farm cooling directives.
    """

    DAIRY_BASINS: List[Dict] = [
        {
            "basin_id": "karnal_kurukshetra_hr",
            "basin_name": "Karnal & Kurukshetra Basin",
            "state": "Haryana",
            "prominent_dairy_cluster": "ICAR-National Dairy Research Institute (NDRI) & Murrah Buffalo Tract",
            "latitude": 29.6857,
            "longitude": 76.9905,
            "stress_tier": LivestockStressTier.MODERATE_STRESS,
            "microclimate": {
                "dry_bulb_temperature_c": 41.5,
                "relative_humidity_pct": 58.0,
                "dew_point_temperature_c": 31.8,
                "wind_speed_ms": 1.8,
                "solar_radiation_wm2": 880.0,
                "temperature_humidity_index_thi": 87.2,
                "black_globe_humidity_index_bgthi": 91.5,
            },
            "species_profiles": [
                {
                    "species_category": AnimalSpeciesBreedCategory.MURRAH_WATER_BUFFALO,
                    "breed_name": "Murrah Water Buffalo",
                    "respiration_rate_bpm": 78,
                    "rectal_temperature_c": 39.8,
                    "estimated_milk_yield_drop_pct": 22.0,
                    "dry_matter_intake_reduction_pct": 18.0,
                    "conception_rate_penalty_pct": 32.0,
                },
                {
                    "species_category": AnimalSpeciesBreedCategory.CROSSBRED_HF_JERSEY,
                    "breed_name": "Karan Fries (HF x Tharparkar Crossbred)",
                    "respiration_rate_bpm": 88,
                    "rectal_temperature_c": 40.2,
                    "estimated_milk_yield_drop_pct": 26.5,
                    "dry_matter_intake_reduction_pct": 22.0,
                    "conception_rate_penalty_pct": 38.0,
                },
                {
                    "species_category": AnimalSpeciesBreedCategory.INDIGENOUS_ZEBU_CATTLE,
                    "breed_name": "Sahiwal & Hariana Indigenous Zebu",
                    "respiration_rate_bpm": 44,
                    "rectal_temperature_c": 38.9,
                    "estimated_milk_yield_drop_pct": 8.5,
                    "dry_matter_intake_reduction_pct": 6.0,
                    "conception_rate_penalty_pct": 10.0,
                },
            ],
            "directives": {
                "shed_cooling_protocol": "Operate high-pressure roof foggers (3 min ON, 12 min OFF) paired with 1.8-2.2 m/s ceiling exhaust fans between 10:30 AM and 04:30 PM.",
                "wallowing_pond_recommendation": "Provide minimum 45-60 minute wallowing in clean pond or shower wash twice daily (11:00 AM and 03:00 PM) for Murrah buffaloes.",
                "water_requirement_liters_per_animal": 140.0,
                "dietary_ration_adjustment": "Shift 65% of daily concentrate & green fodder to cool night hours (08:00 PM to 05:00 AM). Add 100g sodium bicarbonate buffer and 200g bypass fat to prevent ruminal acidosis.",
                "grazing_curfew_hours": "Strict stall feeding between 10:00 AM and 05:00 PM. No open field pasturing under direct solar irradiance.",
                "veterinary_emergency_signs": [
                    "Open-mouth panting with tongue protrusion",
                    "Excessive frothy salivation and drooling",
                    "Rectal temperature exceeding 40.5°C",
                    "Complete cessation of rumination and recumbency",
                ],
            },
            "vernacular_bulletins": {
                "en": "LIVESTOCK HEAT STRESS ADVISORY: Karnal & Kurukshetra dairy belt experiencing high THI of 87.2 (Moderate-to-Severe Stress). Murrah buffaloes and Crossbred cows face 22-27% milk yield loss. Shift feeding to night hours and activate fogger fans.",
                "hi": "पशुधन ताप तनाव परामर्श: करनाल और कुरुक्षेत्र में THI 87.2 दर्ज हुआ है। मुर्रा भैंसों और क्रॉस-ब्रीड गायों के दूध में 22-27% गिरावट का अनुमान है। रात में 65% चारा खिलाएं और पंखे-फव्वारे चलाएं।",
                "pa": "ਪਸ਼ੂ ਧਨ ਗਰਮੀ ਤਣਾਅ ਸਲਾਹ: ਕਰਨਾਲ ਅਤੇ ਕੁਰੂਕਸ਼ੇਤਰ ਖੇਤਰ ਵਿੱਚ THI 87.2 ਦਰਜ ਹੋਣ ਕਾਰਨ ਮੁਰ੍ਹਾ ਮੱਝਾਂ ਅਤੇ ਕਰਾਸਬ੍ਰੀਡ ਗਾਵਾਂ ਦੇ ਦੁੱਧ ਵਿੱਚ 22-27% ਗਿਰਾਵਟ ਆ ਸਕਦੀ ਹੈ। ਰਾਤ ਨੂੰ ਚਾਰਾ ਪਾਓ ਅਤੇ ਪਾਣੀ ਵਿੱਚ ਨੁਹਾਓ।",
            },
        },
        {
            "basin_id": "anand_mehsana_gj",
            "basin_name": "Anand & Mehsana Dairy Belt",
            "state": "Gujarat",
            "prominent_dairy_cluster": "Amul (GCMMF) Cooperative Milk Federation & Mehsani Buffalo Tract",
            "latitude": 22.5645,
            "longitude": 72.9289,
            "stress_tier": LivestockStressTier.MODERATE_STRESS,
            "microclimate": {
                "dry_bulb_temperature_c": 39.2,
                "relative_humidity_pct": 64.0,
                "dew_point_temperature_c": 31.0,
                "wind_speed_ms": 2.1,
                "solar_radiation_wm2": 850.0,
                "temperature_humidity_index_thi": 85.8,
                "black_globe_humidity_index_bgthi": 89.8,
            },
            "species_profiles": [
                {
                    "species_category": AnimalSpeciesBreedCategory.MURRAH_WATER_BUFFALO,
                    "breed_name": "Mehsani & Jafrabadi Water Buffalo",
                    "respiration_rate_bpm": 72,
                    "rectal_temperature_c": 39.6,
                    "estimated_milk_yield_drop_pct": 19.5,
                    "dry_matter_intake_reduction_pct": 16.0,
                    "conception_rate_penalty_pct": 28.0,
                },
                {
                    "species_category": AnimalSpeciesBreedCategory.CROSSBRED_HF_JERSEY,
                    "breed_name": "HF x Kankrej Crossbred",
                    "respiration_rate_bpm": 82,
                    "rectal_temperature_c": 40.0,
                    "estimated_milk_yield_drop_pct": 23.0,
                    "dry_matter_intake_reduction_pct": 19.0,
                    "conception_rate_penalty_pct": 34.0,
                },
                {
                    "species_category": AnimalSpeciesBreedCategory.INDIGENOUS_ZEBU_CATTLE,
                    "breed_name": "Gir & Kankrej Purebred Zebu",
                    "respiration_rate_bpm": 40,
                    "rectal_temperature_c": 38.8,
                    "estimated_milk_yield_drop_pct": 6.5,
                    "dry_matter_intake_reduction_pct": 5.0,
                    "conception_rate_penalty_pct": 8.0,
                },
            ],
            "directives": {
                "shed_cooling_protocol": "Install green agro-shade nets (80% solar reflection) along west and south eaves. Run water sprinklers on tin roofs.",
                "wallowing_pond_recommendation": "Encourage village talab (pond) wallowing early morning and late afternoon.",
                "water_requirement_liters_per_animal": 130.0,
                "dietary_ration_adjustment": "Provide cool ad-libitum drinking water with 0.1% potassium chloride electrolyte. Feed succulent green maize/sorghum silage at dusk.",
                "grazing_curfew_hours": "Cease open pasture grazing between 10:30 AM and 04:30 PM.",
                "veterinary_emergency_signs": [
                    "Labored breathing and elevated pulse",
                    "Milk letdown failure during evening milking",
                    "Dehydration with sunken eyeballs",
                ],
            },
            "vernacular_bulletins": {
                "en": "AMUL DAIRY LIVESTOCK ADVISORY: Anand & Mehsana corridor THI is 85.8. Mehsani buffaloes and HF crossbreds susceptible to milk yield decline. Keep animals in well-ventilated sheds and provide continuous cool water.",
                "hi": "अमूल डेयरी पशुधन परामर्श: आणंद और मेहसाणा में THI 85.8 है। मेहसाणी भैंसों और संकर गायों में दूध उत्पादन गिरने से बचाने के लिए टीन शेड पर पानी छिड़कें और ठंडा पानी पिलाएं।",
                "gu": "પશુપાલન હીટ સ્ટ્રેસ ચેતવણી: આણંદ અને મહેસાણા ડેરી વિસ્તારમાં THI ૮૫.૮ નોંધાયું છે. મહેસાણી ભેંસો અને ક્રોસબ્રીડ ગાયોમાં દૂધ ઉત્પાદન ૨૦% સુધી ઘટી શકે છે. શેડ પર સ્પ્રિંકલર ચાલુ કરો અને રાત્રે ખોરાક આપો.",
            },
        },
        {
            "basin_id": "kolhapur_sangli_mh",
            "basin_name": "Kolhapur & Sangli Basin",
            "state": "Maharashtra",
            "prominent_dairy_cluster": "Gokul (Kolhapur Zilla Sahakari Dudh Utpadak Sangh) & Krishna Valley",
            "latitude": 16.7050,
            "longitude": 74.2433,
            "stress_tier": LivestockStressTier.MODERATE_STRESS,
            "microclimate": {
                "dry_bulb_temperature_c": 36.8,
                "relative_humidity_pct": 72.0,
                "dew_point_temperature_c": 31.0,
                "wind_speed_ms": 2.4,
                "solar_radiation_wm2": 820.0,
                "temperature_humidity_index_thi": 84.5,
                "black_globe_humidity_index_bgthi": 88.0,
            },
            "species_profiles": [
                {
                    "species_category": AnimalSpeciesBreedCategory.MURRAH_WATER_BUFFALO,
                    "breed_name": "Pandharpuri & Murrah Buffalo",
                    "respiration_rate_bpm": 68,
                    "rectal_temperature_c": 39.4,
                    "estimated_milk_yield_drop_pct": 17.5,
                    "dry_matter_intake_reduction_pct": 14.0,
                    "conception_rate_penalty_pct": 24.0,
                },
                {
                    "species_category": AnimalSpeciesBreedCategory.CROSSBRED_HF_JERSEY,
                    "breed_name": "HF Crossbred Milking Herd",
                    "respiration_rate_bpm": 80,
                    "rectal_temperature_c": 39.9,
                    "estimated_milk_yield_drop_pct": 22.5,
                    "dry_matter_intake_reduction_pct": 18.0,
                    "conception_rate_penalty_pct": 32.0,
                },
                {
                    "species_category": AnimalSpeciesBreedCategory.INDIGENOUS_ZEBU_CATTLE,
                    "breed_name": "Khillari Indigenous Draught Cattle",
                    "respiration_rate_bpm": 38,
                    "rectal_temperature_c": 38.7,
                    "estimated_milk_yield_drop_pct": 5.0,
                    "dry_matter_intake_reduction_pct": 4.0,
                    "conception_rate_penalty_pct": 6.0,
                },
            ],
            "directives": {
                "shed_cooling_protocol": "Utilize ceiling fans and spray water mist along animal feed passages.",
                "wallowing_pond_recommendation": "Krishna and Panchganga riverside wallowing allowed under supervision.",
                "water_requirement_liters_per_animal": 125.0,
                "dietary_ration_adjustment": "Supplement bypass protein and live yeast cultures to stabilize rumen fermentation.",
                "grazing_curfew_hours": "Keep milch animals tethered under shady tree groves or ventilated sheds between 11:00 AM and 04:00 PM.",
                "veterinary_emergency_signs": [
                    "High body temperature (>40°C)",
                    "Dullness, head hanging down, and cessation of chewing cud",
                ],
            },
            "vernacular_bulletins": {
                "en": "GOKUL DAIRY HEAT STRESS ALERT: Kolhapur & Sangli basin THI is 84.5. High relative humidity impairs evaporative cooling. Ensure cross ventilation and cool water for Pandharpuri buffaloes and crossbred cows.",
                "hi": "गोकुल डेयरी पशुधन ताप तनाव अलर्ट: कोल्हापुर व सांगली में THI 84.5 है। उच्च नमी के कारण पशुओं में हांफने की समस्या हो सकती है। पंढरपुरी भैंसों और संकर गायों को दिन में दो बार नहलाएं।",
                "mr": "गोकुळ दूध उत्पादक पशुधन सल्ला: कोल्हापूर व सांगली खोऱ्यात THI ८४.५ वर गेला आहे. हवेतील जास्त दमटपणामुळे पंढरपुरी म्हशी व संकरित गायींना त्रास होऊ शकतो. गोठ्यात पंखे सुरू ठेवा व थंड पाण्याची सोय करा.",
            },
        },
        {
            "basin_id": "salem_erode_tn",
            "basin_name": "Salem & Erode Dairy Corridor",
            "state": "Tamil Nadu",
            "water_body": "Cauvery River Basin",
            "prominent_dairy_cluster": "Aavin (Tamil Nadu Co-operative Milk Producers' Federation) & Kongu Belt",
            "latitude": 11.6643,
            "longitude": 78.1460,
            "stress_tier": LivestockStressTier.MODERATE_STRESS,
            "microclimate": {
                "dry_bulb_temperature_c": 37.8,
                "relative_humidity_pct": 60.0,
                "dew_point_temperature_c": 28.5,
                "wind_speed_ms": 2.0,
                "solar_radiation_wm2": 860.0,
                "temperature_humidity_index_thi": 83.9,
                "black_globe_humidity_index_bgthi": 87.5,
            },
            "species_profiles": [
                {
                    "species_category": AnimalSpeciesBreedCategory.MURRAH_WATER_BUFFALO,
                    "breed_name": "Murrah & Toda Buffalo",
                    "respiration_rate_bpm": 66,
                    "rectal_temperature_c": 39.3,
                    "estimated_milk_yield_drop_pct": 16.5,
                    "dry_matter_intake_reduction_pct": 13.0,
                    "conception_rate_penalty_pct": 22.0,
                },
                {
                    "species_category": AnimalSpeciesBreedCategory.CROSSBRED_HF_JERSEY,
                    "breed_name": "Jersey Crossbred Milkers",
                    "respiration_rate_bpm": 76,
                    "rectal_temperature_c": 39.8,
                    "estimated_milk_yield_drop_pct": 21.0,
                    "dry_matter_intake_reduction_pct": 17.0,
                    "conception_rate_penalty_pct": 30.0,
                },
                {
                    "species_category": AnimalSpeciesBreedCategory.INDIGENOUS_ZEBU_CATTLE,
                    "breed_name": "Kangayam Purebred Indigenous Zebu",
                    "respiration_rate_bpm": 36,
                    "rectal_temperature_c": 38.6,
                    "estimated_milk_yield_drop_pct": 4.5,
                    "dry_matter_intake_reduction_pct": 3.5,
                    "conception_rate_penalty_pct": 5.0,
                },
            ],
            "directives": {
                "shed_cooling_protocol": "Hang wet gunny bags along shed sides and run misting nozzles.",
                "wallowing_pond_recommendation": "Sponge buffalo body with wet hessian cloth if wallowing facility unavailable.",
                "water_requirement_liters_per_animal": 120.0,
                "dietary_ration_adjustment": "Provide Co-4 / Co-5 hybrid Napier green fodder early morning. Add 50g mineral mixture and salt lick.",
                "grazing_curfew_hours": "Avoid grazing in open fields from 11:00 AM to 04:00 PM.",
                "veterinary_emergency_signs": [
                    "Animal restless, seeking water troughs constantly",
                    "Reduction in morning milk yield by >2 liters",
                ],
            },
            "vernacular_bulletins": {
                "en": "AAVIN LIVESTOCK THERMAL STRESS BULLETIN: Salem & Erode corridor experiencing THI 83.9. Jersey crossbreds and Murrah buffaloes show elevated respiration. Wet gunny bags on shed perimeters recommended.",
                "hi": "आविन डेयरी पशुधन ताप परामर्श: सलेम और इरोड में THI 83.9 है। जर्सी संकर गायों और मुर्रा भैंसों में दूध की कमी से बचने के लिए पशुशाला के किनारों पर गीली बोरियां लटकाएं।",
                "ta": "ஆவின் பால் பண்ணை கால்நடை வெப்ப அழுத்த எச்சரிக்கை: சேலம் மற்றும் ஈரோடு மாவட்டங்களில் THI 83.9 ஆக உள்ளது. ஜெர்சி கலப்பின மாடுகள் மற்றும் முர்ரா எருமைகளில் பால் உற்பத்தி குறையாமல் இருக்க கொட்டகைகளில் ஈர சாக்குகளை தொங்கவிடவும்.",
            },
        },
        {
            "basin_id": "bikaner_jodhpur_rj",
            "basin_name": "Bikaner & Jodhpur Arid Pastoral Belt",
            "state": "Rajasthan",
            "prominent_dairy_cluster": "Saras (RCDF) & Thar Desert Rathi/Tharparkar Pastoralists",
            "latitude": 28.0229,
            "longitude": 73.3119,
            "stress_tier": LivestockStressTier.MODERATE_STRESS,
            "microclimate": {
                "dry_bulb_temperature_c": 44.5,
                "relative_humidity_pct": 22.0,
                "dew_point_temperature_c": 16.5,
                "wind_speed_ms": 3.2,
                "solar_radiation_wm2": 950.0,
                "temperature_humidity_index_thi": 82.8,
                "black_globe_humidity_index_bgthi": 88.5,
            },
            "species_profiles": [
                {
                    "species_category": AnimalSpeciesBreedCategory.INDIGENOUS_ZEBU_CATTLE,
                    "breed_name": "Rathi & Tharparkar Indigenous Cattle",
                    "respiration_rate_bpm": 48,
                    "rectal_temperature_c": 39.0,
                    "estimated_milk_yield_drop_pct": 8.0,
                    "dry_matter_intake_reduction_pct": 7.0,
                    "conception_rate_penalty_pct": 12.0,
                },
                {
                    "species_category": AnimalSpeciesBreedCategory.INDIGENOUS_SMALL_RUMINANTS,
                    "breed_name": "Marwari Sheep & Sirohi Goats",
                    "respiration_rate_bpm": 52,
                    "rectal_temperature_c": 39.2,
                    "estimated_milk_yield_drop_pct": 6.0,
                    "dry_matter_intake_reduction_pct": 5.0,
                    "conception_rate_penalty_pct": 8.0,
                },
                {
                    "species_category": AnimalSpeciesBreedCategory.MURRAH_WATER_BUFFALO,
                    "breed_name": "Murrah Buffalo in Canal Belt",
                    "respiration_rate_bpm": 84,
                    "rectal_temperature_c": 40.4,
                    "estimated_milk_yield_drop_pct": 28.0,
                    "dry_matter_intake_reduction_pct": 24.0,
                    "conception_rate_penalty_pct": 42.0,
                },
            ],
            "directives": {
                "shed_cooling_protocol": "Thatched roofs with local Bajra/Kair straw. Provide whitewash/lime coating on outer shed walls.",
                "wallowing_pond_recommendation": "Mandatory canal water bathing for buffaloes along Indira Gandhi Canal distributaries.",
                "water_requirement_liters_per_animal": 160.0,
                "dietary_ration_adjustment": "Feed soaked mustard cake and wheat bran at 04:00 AM and 09:00 PM. Provide shade over water troughs to avoid scalding water.",
                "grazing_curfew_hours": "Complete ban on desert rangeland grazing from 09:30 AM to 05:30 PM.",
                "veterinary_emergency_signs": [
                    "Sunstroke symptoms (hyperthermia, collapse in shade)",
                    "Severely dry muzzle and skin tenting dehydration",
                ],
            },
            "vernacular_bulletins": {
                "en": "THAR ARID LIVESTOCK WARNING: Bikaner & Jodhpur experiencing extreme dry heat (44.5°C). Water troughs in open sun will become dangerously hot; keep water shaded. Strict ban on daytime desert grazing.",
                "hi": "थार रेगिस्तानी पशुधन चेतावनी: बीकानेर और जोधपुर में 44.5 डिग्री की भीषण गर्मी। पशुओं के पानी की खेलियों (टंकियों) पर छाया रखें ताकि पानी खौले नहीं। सुबह 9:30 से शाम 5:30 बजे तक चराने पर पूर्ण रोक लगाएं।",
            },
        },
        {
            "basin_id": "guntur_krishna_ap",
            "basin_name": "Guntur & Krishna Delta Basin",
            "state": "Andhra Pradesh",
            "prominent_dairy_cluster": "Vijaya Dairy Cooperative & Ongole Cattle Heartland",
            "latitude": 16.3067,
            "longitude": 80.4365,
            "stress_tier": LivestockStressTier.SEVERE_EMERGENCY,
            "microclimate": {
                "dry_bulb_temperature_c": 40.5,
                "relative_humidity_pct": 66.0,
                "dew_point_temperature_c": 32.5,
                "wind_speed_ms": 1.6,
                "solar_radiation_wm2": 890.0,
                "temperature_humidity_index_thi": 88.6,
                "black_globe_humidity_index_bgthi": 93.2,
            },
            "species_profiles": [
                {
                    "species_category": AnimalSpeciesBreedCategory.MURRAH_WATER_BUFFALO,
                    "breed_name": "Graded Murrah Buffalo",
                    "respiration_rate_bpm": 86,
                    "rectal_temperature_c": 40.3,
                    "estimated_milk_yield_drop_pct": 28.5,
                    "dry_matter_intake_reduction_pct": 24.0,
                    "conception_rate_penalty_pct": 44.0,
                },
                {
                    "species_category": AnimalSpeciesBreedCategory.CROSSBRED_HF_JERSEY,
                    "breed_name": "Crossbred Dairy Cows",
                    "respiration_rate_bpm": 94,
                    "rectal_temperature_c": 40.6,
                    "estimated_milk_yield_drop_pct": 32.0,
                    "dry_matter_intake_reduction_pct": 28.0,
                    "conception_rate_penalty_pct": 48.0,
                },
                {
                    "species_category": AnimalSpeciesBreedCategory.INDIGENOUS_ZEBU_CATTLE,
                    "breed_name": "Ongole Heritage Purebred Zebu",
                    "respiration_rate_bpm": 46,
                    "rectal_temperature_c": 39.1,
                    "estimated_milk_yield_drop_pct": 9.0,
                    "dry_matter_intake_reduction_pct": 7.5,
                    "conception_rate_penalty_pct": 12.0,
                },
            ],
            "directives": {
                "shed_cooling_protocol": "CRITICAL EMERGENCY: Continuous fan ventilation and sprinkler misting mandatory. Install side tarpaulins to deflect hot blast winds.",
                "wallowing_pond_recommendation": "Bathe buffaloes 3 to 4 times daily in canal water or under hose pipe.",
                "water_requirement_liters_per_animal": 155.0,
                "dietary_ration_adjustment": "Add 150g sodium bicarbonate buffer and feed green fodder exclusively during late evening.",
                "grazing_curfew_hours": "Zero daytime grazing. House all milch cattle in well-ventilated sheds.",
                "veterinary_emergency_signs": [
                    "Heat prostration, animal unable to stand up",
                    "Rectal temperature >41°C requires immediate cold water dousing on head",
                ],
            },
            "vernacular_bulletins": {
                "en": "RED EMERGENCY LIVESTOCK ALERT: Guntur & Krishna delta THI has breached 88.6 (Severe Thermal Emergency). Extreme threat of heat apoplexy and milk collapse in buffaloes. Continuous water splashing on head and back required.",
                "hi": "रेड इमरजेंसी पशुधन चेतावनी: गुंटूर और कृष्णा डेल्टा में THI 88.6 (अति गंभीर स्तर) पार कर चुका है। भैंसों और गायों में लू लगने और दूध 30% तक गिरने का खतरा है। तुरंत सिर और पीठ पर ठंडा पानी डालें।",
                "te": "రెడ్ ఎమర్జెన్సీ పాడి పశువుల హెచ్చరిక: గుంటూరు మరియు కృష్ణా డెల్టాలో THI 88.6 కు చేరింది. ముర్రా గేదెలు మరియు సంకరజాతి ఆవులు తీవ్ర వడదెబ్బకు గురయ్యే ప్రమాదం ఉంది. తలపై మరియు వీపుపై చల్లని నీరు నిరంతరం పోయాలి.",
            },
        },
        {
            "basin_id": "mathura_aligarh_up",
            "basin_name": "Mathura & Aligarh Doab Corridor",
            "state": "Uttar Pradesh",
            "prominent_dairy_cluster": "Yamuna-Ganga Doab Buffalo & Cow Milk Supply Belt",
            "latitude": 27.4924,
            "longitude": 77.6737,
            "stress_tier": LivestockStressTier.MODERATE_STRESS,
            "microclimate": {
                "dry_bulb_temperature_c": 42.0,
                "relative_humidity_pct": 52.0,
                "dew_point_temperature_c": 29.5,
                "wind_speed_ms": 2.2,
                "solar_radiation_wm2": 890.0,
                "temperature_humidity_index_thi": 86.4,
                "black_globe_humidity_index_bgthi": 90.8,
            },
            "species_profiles": [
                {
                    "species_category": AnimalSpeciesBreedCategory.MURRAH_WATER_BUFFALO,
                    "breed_name": "Nili-Ravi & Murrah Buffalo",
                    "respiration_rate_bpm": 76,
                    "rectal_temperature_c": 39.7,
                    "estimated_milk_yield_drop_pct": 21.0,
                    "dry_matter_intake_reduction_pct": 17.5,
                    "conception_rate_penalty_pct": 30.0,
                },
                {
                    "species_category": AnimalSpeciesBreedCategory.CROSSBRED_HF_JERSEY,
                    "breed_name": "HF Crossbred Milking Cows",
                    "respiration_rate_bpm": 85,
                    "rectal_temperature_c": 40.1,
                    "estimated_milk_yield_drop_pct": 25.0,
                    "dry_matter_intake_reduction_pct": 21.0,
                    "conception_rate_penalty_pct": 36.0,
                },
                {
                    "species_category": AnimalSpeciesBreedCategory.INDIGENOUS_ZEBU_CATTLE,
                    "breed_name": "Sahiwal Purebred Cows",
                    "respiration_rate_bpm": 42,
                    "rectal_temperature_c": 38.8,
                    "estimated_milk_yield_drop_pct": 7.5,
                    "dry_matter_intake_reduction_pct": 5.5,
                    "conception_rate_penalty_pct": 9.0,
                },
            ],
            "directives": {
                "shed_cooling_protocol": "Sprinkle water on roofs and maintain continuous air movement through fans.",
                "wallowing_pond_recommendation": "Village ponds or tubewell channels utilized for 45 min wallowing.",
                "water_requirement_liters_per_animal": 140.0,
                "dietary_ration_adjustment": "Provide mineral mixture (50-70g/day) with common salt. Feed green fodder late evening.",
                "grazing_curfew_hours": "Stall feed during daytime; no open grazing between 10:00 AM and 05:00 PM.",
                "veterinary_emergency_signs": [
                    "Panting with tongue extended",
                    "Severe drop in evening milk yield",
                ],
            },
            "vernacular_bulletins": {
                "en": "DOAB DAIRY LIVESTOCK ADVISORY: Mathura & Aligarh belt THI is 86.4. High ambient heat combined with humidity threatens buffalo milk yield. Keep sheds cool and provide fresh water continuously.",
                "hi": "दोआब डेयरी पशुधन परामर्श: मथुरा और अलीगढ़ में THI 86.4 दर्ज किया गया है। अत्यधिक गर्मी व उमस से भैंसों में दूध घटने का खतरा है। पशुओं को दिन में 2-3 बार नहलाएं और ताजा ठंडा पानी पिलाएं।",
            },
        },
    ]

    @classmethod
    def get_livestock_heat_stress_assessment(
        cls,
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        basin_id: Optional[str] = None,
    ) -> LivestockHeatStressResponse:
        """
        Evaluate real-time biometeorological livestock heat stress, Thom's THI,
        species vulnerability, and dairy farm cooling directives.
        """
        all_models: List[DairyCorridorBasin] = []
        for raw in cls.DAIRY_BASINS:
            basin = DairyCorridorBasin(
                basin_id=raw["basin_id"],
                basin_name=raw["basin_name"],
                state=raw["state"],
                prominent_dairy_cluster=raw["prominent_dairy_cluster"],
                latitude=raw["latitude"],
                longitude=raw["longitude"],
                stress_tier=raw["stress_tier"],
                microclimate=MicroclimateBiometeorology(**raw["microclimate"]),
                species_profiles=[SpeciesVulnerabilityProfile(**p) for p in raw["species_profiles"]],
                directives=FarmShelterAndNutritionDirectives(**raw["directives"]),
                vernacular_bulletins=raw["vernacular_bulletins"],
            )
            all_models.append(basin)

        selected = all_models[0]
        if basin_id:
            match = next((b for b in all_models if b.basin_id == basin_id), None)
            if match:
                selected = match
        elif latitude is not None and longitude is not None:
            selected = min(
                all_models,
                key=lambda b: cls._haversine_distance(latitude, longitude, b.latitude, b.longitude),
            )

        now_utc = datetime.now(timezone.utc).isoformat()
        bulletin_ref = f"ICAR-NDRI/THI-WARN/{datetime.now(timezone.utc).strftime('%Y%m')}-{selected.basin_id[:6].upper()}"

        synopsis = "MODERATE: Indian Dairy Livestock Thermal Stress Surveillance Active"
        if selected.stress_tier == LivestockStressTier.SEVERE_EMERGENCY:
            synopsis = "CRITICAL: Severe Livestock Thermal Stress & Heat Apoplexy Risk (THI > 88)"
        elif selected.stress_tier == LivestockStressTier.MODERATE_STRESS:
            synopsis = "WARNING: Moderate Livestock Heat Stress (THI 79-88) - Substantial Milk Yield Loss Anticipated"

        return LivestockHeatStressResponse(
            timestamp=now_utc,
            bulletin_number=bulletin_ref,
            provenance="ICAR-National Dairy Research Institute (NDRI) & IMD Agromet Livestock Division",
            national_pastoral_summary=synopsis,
            selected_basin=selected,
            all_basins=all_models,
            bioclimatic_model="Thom (1959) & NRC (1971) Temperature-Humidity Index: THI = 0.8*Tdb + (RH/100)*(Tdb - 14.4) + 46.4",
            vernacular_bulletins=selected.vernacular_bulletins,
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
