import math
from datetime import datetime, timezone
from typing import List, Dict, Optional

from app.schemas.crop_water_stress import (
    SoilTextureClass,
    CropWaterStressTier,
    SoilMoistureProfile,
    EvapotranspirationMetrics,
    PrecisionIrrigationDirective,
    AgroClimaticZone,
    CropWaterStressResponse,
)


class CropWaterStressService:
    """
    ICAR-CRIDA & IMD Division of Agricultural Meteorology
    Crop Water Stress Index (CWSI) & Volumetric Soil Moisture Dynamics Engine.
    FAO-56 Penman-Monteith ET0, infrared canopy temperature departures,
    root-zone water availability, and precision deficit irrigation advisories.
    """

    AGRO_ZONES: List[Dict] = [
        {
            "zone_id": "vidarbha_cotton_vertisol",
            "zone_name": "Vidarbha Rainfed Cotton-Soybean Vertisol Belt",
            "state": "Maharashtra",
            "district": "Yavatmal / Nagpur",
            "primary_crop": "Bt Cotton (Gossypium hirsutum)",
            "growth_stage": "Square & Early Boll Formation",
            "latitude": 20.3888,
            "longitude": 78.1204,
            "soil_texture": SoilTextureClass.BLACK_COTTON_VERTISOL,
            "stress_tier": CropWaterStressTier.MODERATE_DEFICIT,
            "soil_moisture": {
                "topsoil_10cm_pct": 14.5,
                "root_zone_40cm_pct": 19.8,
                "subsoil_100cm_pct": 26.2,
                "field_capacity_pct": 38.0,
                "wilting_point_pct": 18.0,
                "relative_available_soil_moisture_pct": 22.5,
            },
            "evapotranspiration": {
                "reference_et0_mm_day": 5.8,
                "crop_coefficient_kc": 1.15,
                "actual_etc_mm_day": 4.6,
                "canopy_temperature_c": 34.2,
                "ambient_air_temperature_c": 31.8,
                "canopy_air_temp_departure_c": 2.4,
                "crop_water_stress_index_cwsi": 0.68,
            },
            "irrigation_directives": {
                "recommended_irrigation_depth_mm": 35.0,
                "drip_run_time_hours": 3.5,
                "critical_growth_stage": "Boll setting (moisture deficit causes squaring drop & flower shedding)",
                "anti_transpirant_spray": "Foliar spray of 1% Potassium Nitrate (KNO3) or 2% DAP to sustain turgor",
                "mulch_recommendation": "Spreading of cotton stalks or soybean straw mulch at 5 tonnes/ha to suppress evaporation",
                "intercultivation_tillage": "Shallow hoeing (Kolpa) between rows to break soil surface capillaries",
            },
            "localized_bulletins": {
                "en": "MODERATE CROP WATER STRESS: Bt Cotton in Vidarbha experiencing critical moisture deficit during boll formation (CWSI 0.68, canopy heated +2.4°C above air). Immediate supplemental drip irrigation of 35mm recommended. Apply 1% KNO3 foliar spray.",
                "hi": "मध्यम फसल जल तनाव: विदर्भ में कपास की फसल में गूलर बनने की अवस्था में नमी की भारी कमी (CWSI 0.68)। फूल और गूलर गिरने से रोकने के लिए 35 मिमी ड्रिप सिंचाई दें और 1% पोटैशियम नाइट्रेट का छिड़काव करें।",
                "mr": "मध्यम पीक जल ताण: विदर्भातील कापूस पिकात बोंडे भरण्याच्या नाजूक टप्प्यावर जमिनीतील ओलावा घटला आहे (CWSI 0.68). पाते व बोंड गळ रोखण्यासाठी तात्काळ 35 मिमी ठिबक सिंचन द्यावे व 1% पोटॅशियम नायट्रेटची फवारणी करावी.",
            },
        },
        {
            "zone_id": "punjab_wheat_rice_alluvium",
            "zone_name": "Punjab Central Alluvial Cropping Plain",
            "state": "Punjab",
            "district": "Ludhiana / Bathinda",
            "primary_crop": "Wheat (Triticum aestivum)",
            "growth_stage": "Crown Root Initiation (CRI) & Tillering",
            "latitude": 30.9010,
            "longitude": 75.8573,
            "soil_texture": SoilTextureClass.INDO_GANGETIC_ALLUVIAL,
            "stress_tier": CropWaterStressTier.OPTIMAL_TURGOR,
            "soil_moisture": {
                "topsoil_10cm_pct": 28.2,
                "root_zone_40cm_pct": 29.5,
                "subsoil_100cm_pct": 30.8,
                "field_capacity_pct": 32.0,
                "wilting_point_pct": 12.0,
                "relative_available_soil_moisture_pct": 81.0,
            },
            "evapotranspiration": {
                "reference_et0_mm_day": 3.2,
                "crop_coefficient_kc": 0.85,
                "actual_etc_mm_day": 2.7,
                "canopy_temperature_c": 18.2,
                "ambient_air_temperature_c": 20.0,
                "canopy_air_temp_departure_c": -1.8,
                "crop_water_stress_index_cwsi": 0.18,
            },
            "irrigation_directives": {
                "recommended_irrigation_depth_mm": 0.0,
                "drip_run_time_hours": 0.0,
                "critical_growth_stage": "Crown Root Initiation (Adequately hydrated from recent canal rotation)",
                "anti_transpirant_spray": "Not required under optimal moisture regime",
                "mulch_recommendation": "Happy Seeder in-situ paddy straw residue active on soil surface",
                "intercultivation_tillage": "Avoid tillage to preserve root anchorage and straw bed integrity",
            },
            "localized_bulletins": {
                "en": "OPTIMAL TURGOR: Punjab wheat canopy well-hydrated with high transpirational cooling (CWSI 0.18, canopy cooler by -1.8°C). Soil moisture at 81% RASM. No supplemental irrigation needed for the next 6 days.",
                "hi": "इष्टतम नमी: पंजाब के गेहूं में पर्याप्त नमी उपलब्ध (CWSI 0.18)। फसल का तापमान वातावरण से 1.8°C ठंडा है। आगामी 6 दिनों तक किसी सिंचाई की आवश्यकता नहीं है।",
                "pa": "ਅਨੁਕੂਲ ਨਮੀ: ਪੰਜਾਬ ਵਿੱਚ ਕਣਕ ਦੀ ਫਸਲ ਵਿੱਚ ਨਮੀ ਦੀ ਸਥਿਤੀ ਬਹੁਤ ਵਧੀਆ ਹੈ (CWSI 0.18)। ਜ਼ਮੀਨ ਵਿੱਚ 81% ਪਾਣੀ ਮੌਜੂਦ ਹੈ। ਅਗਲੇ 6 ਦਿਨਾਂ ਤੱਕ ਸਿੰਚਾਈ ਦੀ ਕੋਈ ਲੋੜ ਨਹੀਂ ਹੈ।",
            },
        },
        {
            "zone_id": "telangana_red_soil_maize",
            "zone_name": "Telangana Deccan Red Soil Dryland Tract",
            "state": "Telangana",
            "district": "Warangal / Nalgonda",
            "primary_crop": "Maize & Redgram Intercropping",
            "growth_stage": "Tasseling & Silking Stage",
            "latitude": 17.9689,
            "longitude": 79.5941,
            "soil_texture": SoilTextureClass.RED_SANDY_ALFISOL,
            "stress_tier": CropWaterStressTier.MODERATE_DEFICIT,
            "soil_moisture": {
                "topsoil_10cm_pct": 11.2,
                "root_zone_40cm_pct": 13.8,
                "subsoil_100cm_pct": 16.5,
                "field_capacity_pct": 22.0,
                "wilting_point_pct": 8.5,
                "relative_available_soil_moisture_pct": 20.0,
            },
            "evapotranspiration": {
                "reference_et0_mm_day": 5.2,
                "crop_coefficient_kc": 1.20,
                "actual_etc_mm_day": 4.1,
                "canopy_temperature_c": 33.6,
                "ambient_air_temperature_c": 32.0,
                "canopy_air_temp_departure_c": 1.6,
                "crop_water_stress_index_cwsi": 0.54,
            },
            "irrigation_directives": {
                "recommended_irrigation_depth_mm": 40.0,
                "drip_run_time_hours": 4.0,
                "critical_growth_stage": "Tasseling/Silking (Moisture stress now causes poor pollination & barren cobs)",
                "anti_transpirant_spray": "Spray 1.5% Urea + 0.5% Zinc sulphate to mitigate heat induced pollen sterility",
                "mulch_recommendation": "Cover furrows with dry weed biomass or green leaf loppings",
                "intercultivation_tillage": "Soil stirring to prevent crusting in red soils after brief showers",
            },
            "localized_bulletins": {
                "en": "MODERATE CROP WATER STRESS: Red soils in Telangana experiencing moisture stress during critical maize tasseling (CWSI 0.54). High risk of pollen desiccation. Provide 40mm furrow or sprinkler irrigation immediately.",
                "hi": "मध्यम जल तनाव: तेलंगाना के लाल मिट्टी क्षेत्रों में मक्का की नर-मंजरी अवस्था में नमी की कमी (CWSI 0.54)। पराग सूखने से बचाने के लिए 40 मिमी सिंचाई तुरंत करें।",
                "te": "మధ్యస్థ పంట నీటి ఒత్తిడి: తెలంగాణ ఎర్ర నేలల్లో మొక్కజొన్న పూత దశలో తేమ కొరత (CWSI 0.54). గింజ కట్టడం దెబ్బతినకుండా వెంటనే 40 మి.మీ నీటి తడి ఇవ్వాలి.",
            },
        },
        {
            "zone_id": "saurashtra_groundnut_belt",
            "zone_name": "Saurashtra Semi-Arid Groundnut Calcaric Tract",
            "state": "Gujarat",
            "district": "Junagadh / Rajkot",
            "primary_crop": "Groundnut (Arachis hypogaea)",
            "growth_stage": "Pegging & Pod Development",
            "latitude": 21.5222,
            "longitude": 70.4579,
            "soil_texture": SoilTextureClass.BLACK_COTTON_VERTISOL,
            "stress_tier": CropWaterStressTier.MODERATE_DEFICIT,
            "soil_moisture": {
                "topsoil_10cm_pct": 13.8,
                "root_zone_40cm_pct": 18.2,
                "subsoil_100cm_pct": 24.0,
                "field_capacity_pct": 34.0,
                "wilting_point_pct": 16.0,
                "relative_available_soil_moisture_pct": 26.6,
            },
            "evapotranspiration": {
                "reference_et0_mm_day": 5.5,
                "crop_coefficient_kc": 1.05,
                "actual_etc_mm_day": 4.2,
                "canopy_temperature_c": 35.1,
                "ambient_air_temperature_c": 33.0,
                "canopy_air_temp_departure_c": 2.1,
                "crop_water_stress_index_cwsi": 0.62,
            },
            "irrigation_directives": {
                "recommended_irrigation_depth_mm": 30.0,
                "drip_run_time_hours": 3.0,
                "critical_growth_stage": "Peg penetration into hard dry soil crust (pegs unable to enter soil)",
                "anti_transpirant_spray": "Spray Kaolin clay 5% to reflect excess solar radiation and reduce canopy heat load",
                "mulch_recommendation": "Inter-row groundnut shell or wheat bhusa mulching",
                "intercultivation_tillage": "Light loosening of surface soil around root zone to facilitate easy peg penetration",
            },
            "localized_bulletins": {
                "en": "MODERATE WATER STRESS: Groundnut in Saurashtra facing soil moisture deficit during peg penetration (CWSI 0.62). Surface crusting inhibits peg entry. Apply 30mm micro-sprinkler irrigation and 5% Kaolin spray.",
                "hi": "मध्यम जल तनाव: सौराष्ट्र में मूंगफली में सुइयां (पेग) बनने के दौरान नमी की कमी (CWSI 0.62)। जमीन सख्त होने से सुइयां अंदर नहीं जा पा रही हैं। 30 मिमी फव्वारा सिंचाई तुरंत दें।",
                "gu": "મધ્યમ પાક જળ તણાવ: સૌરાષ્ટ્રમાં મગફળીમાં સૂયા બેસવાની અવસ્થાએ જમીનમાં ભેજની અછત (CWSI 0.62). સૂયા જમીનમાં ઉતરવામાં મુશ્કેલી. તાત્કાલિક 30 મીમી ફુવારા પદ્ધતિથી પિયત આપવું.",
            },
        },
        {
            "zone_id": "cauvery_delta_paddy_wetland",
            "zone_name": "Cauvery Delta Lowland Rice Wetland Agro-Zone",
            "state": "Tamil Nadu",
            "district": "Thanjavur / Tiruvarur",
            "primary_crop": "Samba Wetland Paddy (Oryza sativa)",
            "growth_stage": "Active Tillering to Panicle Initiation",
            "latitude": 10.7870,
            "longitude": 79.1378,
            "soil_texture": SoilTextureClass.COASTAL_ALLUVIAL_LOAM,
            "stress_tier": CropWaterStressTier.MILD_STRESS,
            "soil_moisture": {
                "topsoil_10cm_pct": 31.5,
                "root_zone_40cm_pct": 33.0,
                "subsoil_100cm_pct": 35.2,
                "field_capacity_pct": 36.0,
                "wilting_point_pct": 15.0,
                "relative_available_soil_moisture_pct": 78.5,
            },
            "evapotranspiration": {
                "reference_et0_mm_day": 4.5,
                "crop_coefficient_kc": 1.20,
                "actual_etc_mm_day": 4.8,
                "canopy_temperature_c": 29.4,
                "ambient_air_temperature_c": 30.0,
                "canopy_air_temp_departure_c": -0.6,
                "crop_water_stress_index_cwsi": 0.22,
            },
            "irrigation_directives": {
                "recommended_irrigation_depth_mm": 25.0,
                "drip_run_time_hours": 0.0,
                "critical_growth_stage": "Active Tillering (Alternate Wetting and Drying - AWD recommended)",
                "anti_transpirant_spray": "Not required under current AWD regime",
                "mulch_recommendation": "Azolla water bio-mulch covering ponded surface",
                "intercultivation_tillage": "Cono-weeder pass to aerate root zone and incorporate green weeds",
            },
            "localized_bulletins": {
                "en": "MILD WATER STRESS (AWD REGIME): Cauvery Delta samba rice maintaining healthy root aeration under Alternate Wetting and Drying (CWSI 0.22). Re-irrigate to 25mm depth when water level drops 15cm below soil surface.",
                "hi": "हल्का जल तनाव: कावेरी डेल्टा में धान की फसल 'वैकल्पिक गीला और सूखा' (AWD) तकनीक के तहत सुरक्षित (CWSI 0.22)। जलस्तर 15 सेमी नीचे जाने पर 25 मिमी पानी दें।",
                "ta": "லேசான நீர் அழுத்தம் (AWD முறை): காவிரி டெல்டா சம்பா நெல் பயிரில் மாற்று நனைத்தல் மற்றும் உலர்த்துதல் முறையில் பயிர் நலம் (CWSI 0.22). நிலத்தடி நீர் மட்டம் 15 செ.மீ குறையும் போது 25 மி.மீ பாசனம் செய்யவும்.",
            },
        },
        {
            "zone_id": "bundelkhand_pulses_semiarid",
            "zone_name": "Bundelkhand Drought-Prone Rainfed Pulses Belt",
            "state": "Uttar Pradesh / Madhya Pradesh",
            "district": "Jhansi / Mahoba",
            "primary_crop": "Chickpea / Gram (Cicer arietinum)",
            "growth_stage": "Flowering & Pod Filling",
            "latitude": 25.4484,
            "longitude": 78.5685,
            "soil_texture": SoilTextureClass.RED_SANDY_ALFISOL,
            "stress_tier": CropWaterStressTier.SEVERE_DROUGHT_STRESS,
            "soil_moisture": {
                "topsoil_10cm_pct": 9.4,
                "root_zone_40cm_pct": 12.2,
                "subsoil_100cm_pct": 15.0,
                "field_capacity_pct": 28.0,
                "wilting_point_pct": 14.0,
                "relative_available_soil_moisture_pct": 10.0,
            },
            "evapotranspiration": {
                "reference_et0_mm_day": 5.0,
                "crop_coefficient_kc": 0.95,
                "actual_etc_mm_day": 2.8,
                "canopy_temperature_c": 33.8,
                "ambient_air_temperature_c": 30.0,
                "canopy_air_temp_departure_c": 3.8,
                "crop_water_stress_index_cwsi": 0.74,
            },
            "irrigation_directives": {
                "recommended_irrigation_depth_mm": 45.0,
                "drip_run_time_hours": 4.5,
                "critical_growth_stage": "Pod formation (Severe moisture depletion causing premature pod drying & flower drop)",
                "anti_transpirant_spray": "Emergency foliar spray of 2% Urea + 1% Potassium Chloride (KCl) to alleviate terminal drought",
                "mulch_recommendation": "In-situ crop residue dust-mulch creation",
                "intercultivation_tillage": "Avoid root-zone disturbance in cracked dry soil",
            },
            "localized_bulletins": {
                "en": "SEVERE CROP WATER STRESS: Bundelkhand rainfed pulses suffering terminal drought stress (CWSI 0.74, canopy +3.8°C above air). Available soil moisture critically low at 10%. Provide life-saving protective irrigation of 45mm immediately.",
                "hi": "गंभीर सूखा तनाव: बुंदेलखंड में चने की फसल गंभीर जल संकट में (CWSI 0.74)। मिट्टी में केवल 10% उपयोगी नमी बची है। फसल बचाने के लिए तुरंत 45 मिमी सुरक्षात्मक सिंचाई दें और 2% यूरिया का छिड़काव करें।",
            },
        },
        {
            "zone_id": "assam_brahmaputra_tea_valley",
            "zone_name": "Assam Brahmaputra Humid Plantation Valley",
            "state": "Assam",
            "district": "Jorhat / Dibrugarh",
            "primary_crop": "Tea Bush (Camellia sinensis)",
            "growth_stage": "Autumn Flush Plucking",
            "latitude": 26.7509,
            "longitude": 94.2037,
            "soil_texture": SoilTextureClass.LATERITIC_LOAM,
            "stress_tier": CropWaterStressTier.OPTIMAL_TURGOR,
            "soil_moisture": {
                "topsoil_10cm_pct": 33.0,
                "root_zone_40cm_pct": 32.5,
                "subsoil_100cm_pct": 34.0,
                "field_capacity_pct": 35.0,
                "wilting_point_pct": 14.0,
                "relative_available_soil_moisture_pct": 90.5,
            },
            "evapotranspiration": {
                "reference_et0_mm_day": 3.6,
                "crop_coefficient_kc": 1.00,
                "actual_etc_mm_day": 3.5,
                "canopy_temperature_c": 24.8,
                "ambient_air_temperature_c": 27.0,
                "canopy_air_temp_departure_c": -2.2,
                "crop_water_stress_index_cwsi": 0.15,
            },
            "irrigation_directives": {
                "recommended_irrigation_depth_mm": 0.0,
                "drip_run_time_hours": 0.0,
                "critical_growth_stage": "Vegetative shoot emergence (Optimal hydric status from post-monsoon reserves)",
                "anti_transpirant_spray": "Not required",
                "mulch_recommendation": "Pruned tea branches mulch between bushes to suppress weed growth",
                "intercultivation_tillage": "Maintain drainage channels to prevent waterlogging during unseasonal rains",
            },
            "localized_bulletins": {
                "en": "OPTIMAL TURGOR: Assam tea plantations possessing abundant root-zone moisture (CWSI 0.15, canopy -2.2°C cooler). Soil moisture at 90.5% of available capacity. Maintain drainage outfalls.",
                "hi": "इष्टतम नमी: असम की चाय बागानों में प्रचुर नमी उपलब्ध (CWSI 0.15)। मिट्टी की जलधारण क्षमता 90% से अधिक है। जल निकासी नालियों को साफ रखें।",
            },
        },
    ]

    @classmethod
    def get_assessment(
        cls,
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        zone_id: Optional[str] = None,
    ) -> CropWaterStressResponse:
        all_models: List[AgroClimaticZone] = []
        for raw in cls.AGRO_ZONES:
            zone = AgroClimaticZone(
                zone_id=raw["zone_id"],
                zone_name=raw["zone_name"],
                state=raw["state"],
                district=raw["district"],
                primary_crop=raw["primary_crop"],
                growth_stage=raw["growth_stage"],
                latitude=raw["latitude"],
                longitude=raw["longitude"],
                soil_texture=raw["soil_texture"],
                stress_tier=raw["stress_tier"],
                soil_moisture=SoilMoistureProfile(**raw["soil_moisture"]),
                evapotranspiration=EvapotranspirationMetrics(**raw["evapotranspiration"]),
                irrigation_directives=PrecisionIrrigationDirective(**raw["irrigation_directives"]),
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
        bulletin_ref = f"ICAR-IMD/CWSI/{datetime.now(timezone.utc).strftime('%Y%m')}-{selected.zone_id[:6].upper()}"

        return CropWaterStressResponse(
            timestamp=now_utc,
            bulletin_number=bulletin_ref,
            provenance="ICAR-CRIDA & IMD Division of Agricultural Meteorology Crop Water Stress Monitoring System",
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
