"""Service implementation for IMD & ICAR Post-Harvest Mandi Weather Defense,
Grain Moisture & Open-Godown Spoilage Engine (AGRI-STORAGE).
"""

import math
from datetime import datetime, timezone
from typing import Dict, List, Optional, Tuple

from app.schemas.agri_storage import (
    AgriStorageResponse,
    CropHygroscopicMetrics,
    FungalMycotoxinTelemetry,
    GrainMoistureState,
    MandiHub,
    MandiStorageDirectives,
    MandiSummary,
    MandiWeatherRiskTier,
    MycotoxinAflatoxinRisk,
    OpenMandiYardTelemetry,
    TarpaulinAlertStatus,
)


class AgriStorageService:
    """Calculates Henderson-Thompson EMC, Aflatoxin B1 fungal risk,
    and open-plinth yard weather defense directives for APMC mandis.
    """

    # Henderson-Thompson Parameters: (K, C, N, Safe_Limit_Pct)
    # EMC = [ -ln(1 - RH) / (K * (T + C)) ] ** (1 / N)
    CROP_EMC_PARAMETERS: Dict[str, Tuple[float, float, float, float]] = {
        "Wheat": (2.3e-5, 55.8, 2.29, 12.0),
        "Paddy": (1.9e-5, 35.7, 2.15, 14.0),
        "Soybean": (4.2e-5, 82.3, 1.85, 10.0),
        "Mustard": (4.8e-5, 78.0, 1.78, 9.0),
        "Maize": (3.2e-5, 46.5, 1.98, 13.0),
        "Bengal Gram (Chana)": (2.7e-5, 62.1, 2.05, 11.0),
    }

    # Curated APMC Mandi Hubs
    MANDI_HUBS: Dict[str, MandiHub] = {
        "KHANNA_APMC": MandiHub(
            mandi_id="KHANNA_APMC",
            name="Khanna APMC Grain Market",
            district="Ludhiana",
            state="Punjab",
            latitude=30.7020,
            longitude=76.2160,
            primary_commodities=["Wheat", "Paddy", "Maize"],
            daily_arrival_metric_tonnes=18500.0,
            storage_capacity_metric_tonnes=120000.0,
            open_plinth_pct=38.5,
        ),
        "KARNAL_APMC": MandiHub(
            mandi_id="KARNAL_APMC",
            name="Karnal New Grain Market",
            district="Karnal",
            state="Haryana",
            latitude=29.6857,
            longitude=76.9905,
            primary_commodities=["Paddy", "Wheat", "Mustard"],
            daily_arrival_metric_tonnes=14200.0,
            storage_capacity_metric_tonnes=95000.0,
            open_plinth_pct=42.0,
        ),
        "NEEMUCH_APMC": MandiHub(
            mandi_id="NEEMUCH_APMC",
            name="Neemuch Krishi Upaj Mandi",
            district="Neemuch",
            state="Madhya Pradesh",
            latitude=24.4632,
            longitude=74.8683,
            primary_commodities=["Soybean", "Mustard", "Wheat", "Bengal Gram (Chana)"],
            daily_arrival_metric_tonnes=9800.0,
            storage_capacity_metric_tonnes=65000.0,
            open_plinth_pct=32.0,
        ),
        "LATUR_APMC": MandiHub(
            mandi_id="LATUR_APMC",
            name="Latur Agricultural Produce Market Committee",
            district="Latur",
            state="Maharashtra",
            latitude=18.4088,
            longitude=76.5604,
            primary_commodities=["Soybean", "Bengal Gram (Chana)", "Paddy"],
            daily_arrival_metric_tonnes=11500.0,
            storage_capacity_metric_tonnes=78000.0,
            open_plinth_pct=29.0,
        ),
        "NIZAMABAD_APMC": MandiHub(
            mandi_id="NIZAMABAD_APMC",
            name="Nizamabad Agricultural Market Yard",
            district="Nizamabad",
            state="Telangana",
            latitude=18.6725,
            longitude=78.0941,
            primary_commodities=["Paddy", "Maize", "Bengal Gram (Chana)"],
            daily_arrival_metric_tonnes=8400.0,
            storage_capacity_metric_tonnes=54000.0,
            open_plinth_pct=35.0,
        ),
        "GUNTUR_MIRCHI": MandiHub(
            mandi_id="GUNTUR_MIRCHI",
            name="Guntur Agricultural Market Yard (Mirchi Yard)",
            district="Guntur",
            state="Andhra Pradesh",
            latitude=16.3067,
            longitude=80.4365,
            primary_commodities=["Paddy", "Bengal Gram (Chana)", "Maize"],
            daily_arrival_metric_tonnes=12800.0,
            storage_capacity_metric_tonnes=88000.0,
            open_plinth_pct=25.0,
        ),
        "KOTA_BHAMASHAH": MandiHub(
            mandi_id="KOTA_BHAMASHAH",
            name="Kota Bhamashah Krishi Upaj Mandi",
            district="Kota",
            state="Rajasthan",
            latitude=25.1825,
            longitude=75.8398,
            primary_commodities=["Mustard", "Soybean", "Wheat", "Paddy"],
            daily_arrival_metric_tonnes=13600.0,
            storage_capacity_metric_tonnes=82000.0,
            open_plinth_pct=40.0,
        ),
    }

    @classmethod
    def calculate_henderson_thompson_emc(
        cls,
        crop: str,
        temperature_c: float,
        relative_humidity_pct: float,
    ) -> float:
        """Calculates Equilibrium Moisture Content (% wet basis) using the
        modified Henderson-Thompson equation.
        """
        params = cls.CROP_EMC_PARAMETERS.get(crop, cls.CROP_EMC_PARAMETERS["Wheat"])
        k, c, n, _ = params

        # Clamp relative humidity fraction strictly between 0.01 and 0.98 to avoid numerical singularities
        rh_frac = max(0.01, min(0.98, relative_humidity_pct / 100.0))
        temp_val = max(1.0, temperature_c + c)

        # Numerator: -ln(1 - RH)
        num = -math.log(1.0 - rh_frac)
        denom = k * temp_val

        # EMC formula in dry basis percentage, converted to approximate wet basis
        emc_dry_basis = (num / denom) ** (1.0 / n)
        # Wet basis conversion: MC_wb = MC_db / (1 + MC_db/100)
        emc_wet_basis = (emc_dry_basis / (1.0 + (emc_dry_basis / 100.0)))

        return round(float(emc_wet_basis), 2)

    @classmethod
    def evaluate_grain_moisture_state(
        cls,
        current_moisture_pct: float,
        safe_limit_pct: float,
    ) -> GrainMoistureState:
        """Evaluates grain moisture danger status relative to safe storage limits."""
        delta = current_moisture_pct - safe_limit_pct
        if delta > 2.5:
            return GrainMoistureState.PERILOUS_FERMENTATION_RISK
        elif delta > 0.0:
            return GrainMoistureState.UNSAFE_ELEVATED_MOISTURE
        elif delta >= -1.5:
            return GrainMoistureState.ACCEPTABLE_STABLE
        else:
            return GrainMoistureState.OPTIMAL_SAFE_DRY

    @classmethod
    def evaluate_aflatoxin_risk(
        cls,
        temperature_c: float,
        relative_humidity_pct: float,
    ) -> Tuple[MycotoxinAflatoxinRisk, float, float]:
        """Evaluates Aspergillus flavus mold proliferation kinetics and projected Aflatoxin B1.
        Returns: (AflatoxinRiskTier, MoldIncubationIndex [0-10], ProjectedAflatoxinPPB)
        """
        # Optimal temperature range is 25 - 37 deg C with peak activity at ~31 deg C
        temp_factor = math.exp(-(((temperature_c - 31.0) / 8.5) ** 2))

        # Relative humidity threshold: Aspergillus flavus requires RH > 70%, surges above 80%
        if relative_humidity_pct < 65.0:
            rh_factor = 0.05
        elif relative_humidity_pct < 75.0:
            rh_factor = 0.15 + 0.35 * ((relative_humidity_pct - 65.0) / 10.0)
        else:
            rh_factor = 0.50 + 0.50 * min(1.0, (relative_humidity_pct - 75.0) / 20.0)

        mold_index = round(max(0.1, min(10.0, 10.0 * temp_factor * rh_factor)), 2)

        # Baseline Aflatoxin B1 synthesis (FSSAI statutory threshold is 15 ug/kg = 15 ppb)
        projected_ppb = round(1.2 + (mold_index * 2.8), 2)

        if projected_ppb >= 20.0 or mold_index >= 7.5:
            risk = MycotoxinAflatoxinRisk.EXTREME_AFLATOXIN_OUTBREAK
        elif projected_ppb >= 13.0 or mold_index >= 5.0:
            risk = MycotoxinAflatoxinRisk.HIGH_FUNGAL_PROLIFERATION
        elif projected_ppb >= 7.0 or mold_index >= 2.5:
            risk = MycotoxinAflatoxinRisk.MODERATE_MONITORING_REQUIRED
        else:
            risk = MycotoxinAflatoxinRisk.MINIMAL_MYCOTOXIN_RISK

        return risk, mold_index, projected_ppb

    @classmethod
    def find_nearest_mandi(cls, lat: float, lon: float) -> MandiHub:
        """Finds nearest monitored APMC mandi hub using Euclidean approximation."""
        best_mandi = cls.MANDI_HUBS["KHANNA_APMC"]
        best_dist = float("inf")

        for hub in cls.MANDI_HUBS.values():
            dist = math.hypot(hub.latitude - lat, hub.longitude - lon)
            if dist < best_dist:
                best_dist = dist
                best_mandi = hub

        return best_mandi

    @classmethod
    def get_agri_storage_assessment(
        cls,
        mandi_id: Optional[str] = None,
        lat: Optional[float] = None,
        lon: Optional[float] = None,
    ) -> AgriStorageResponse:
        """Computes comprehensive mandi post-harvest grain defense telemetry."""
        # Resolve target mandi
        if mandi_id and mandi_id.upper() in cls.MANDI_HUBS:
            target_hub = cls.MANDI_HUBS[mandi_id.upper()]
        elif lat is not None and lon is not None:
            target_hub = cls.find_nearest_mandi(lat, lon)
        else:
            target_hub = cls.MANDI_HUBS["KHANNA_APMC"]

        # Deterministic microclimate calibration based on mandi coordinates and seasonality
        # For instance, Khanna/Karnal in pre-monsoon/western disturbance scenarios
        seed = int(abs(target_hub.latitude * 100 + target_hub.longitude * 10)) % 100
        ambient_temp = round(28.0 + (seed % 9) - 2.0, 1)  # 26.0 - 35.0 C
        ambient_rh = round(62.0 + (seed % 28), 1)         # 62.0 - 90.0 %
        rain_24h = round(float((seed * 3.7) % 45.0), 1)   # 0.0 - 45.0 mm
        hail_prob = round(float(25.0 if rain_24h > 20.0 else 5.0 + (seed % 15)), 1)
        wind_gust = round(22.0 + (seed % 35), 1)

        # Weather condition text
        if rain_24h > 25.0:
            condition = "Approaching Severe Thundershower & Squall"
        elif rain_24h > 10.0:
            condition = "Scattered Moderate Rains with Gusty Winds"
        elif ambient_rh > 75.0:
            condition = "Humid Overcast Sky with High Spoilage Vapor"
        else:
            condition = "Clear Sky with High Diurnal Radiation"

        # Calculate Crop Hygroscopic Metrics
        crop_metrics: List[CropHygroscopicMetrics] = []
        for crop_name in target_hub.primary_commodities:
            if crop_name not in cls.CROP_EMC_PARAMETERS:
                continue
            k, c, n, safe_limit = cls.CROP_EMC_PARAMETERS[crop_name]
            emc = cls.calculate_henderson_thompson_emc(crop_name, ambient_temp, ambient_rh)

            # Simulated actual moisture content based on EMC and rain exposure
            current_mc = round(emc + (1.2 if rain_24h > 15.0 else -0.3), 2)
            surplus = round(current_mc - safe_limit, 2)
            state = cls.evaluate_grain_moisture_state(current_mc, safe_limit)

            crop_metrics.append(
                CropHygroscopicMetrics(
                    crop_name=crop_name,
                    current_moisture_content_pct=current_mc,
                    equilibrium_moisture_content_pct=emc,
                    safe_storage_limit_pct=safe_limit,
                    moisture_surplus_deficit_pct=surplus,
                    moisture_state=state,
                    henderson_thompson_k=k,
                    henderson_thompson_c=c,
                    henderson_thompson_n=n,
                )
            )

        # Fungal Mycotoxin Telemetry
        aflatoxin_risk, mold_idx, proj_aflatoxin = cls.evaluate_aflatoxin_risk(
            ambient_temp, ambient_rh
        )
        fungal_telemetry = FungalMycotoxinTelemetry(
            aflatoxin_b1_risk_level=aflatoxin_risk,
            optimal_growth_temp_range="25°C - 37°C",
            ambient_temp_c=ambient_temp,
            relative_humidity_pct=ambient_rh,
            mold_spore_incubation_index=mold_idx,
            fssai_limit_ug_per_kg=15.0,
            projected_aflatoxin_ppb=proj_aflatoxin,
        )

        # Open Mandi Yard Telemetry
        dunnage_h = 10.0 if seed % 2 == 0 else 18.0  # cm
        inundation_risk = min(100.0, round(rain_24h * 2.2 + (15.0 if dunnage_h < 15.0 else 0.0), 1))
        clearance_hours = round(max(1.0, rain_24h / 6.0), 1)

        open_yard = OpenMandiYardTelemetry(
            yard_type_label="Open Plinth / CAP (Cover and Plinth) Storage Yard",
            surface_inundation_risk_pct=inundation_risk,
            forecast_rain_24h_mm=rain_24h,
            forecast_hail_probability_pct=hail_prob,
            wind_gust_kmh=wind_gust,
            dunnage_pallet_elevation_cm=dunnage_h,
            waterlogging_clearance_hours=clearance_hours,
        )

        # Determine Tarpaulin Status & Overall Risk Tier
        if rain_24h >= 15.0 or hail_prob >= 30.0 or wind_gust >= 50.0:
            tarpaulin_status = TarpaulinAlertStatus.IMMEDIATE_TIRPAL_DEPLOYMENT
        elif rain_24h >= 5.0 or ambient_rh >= 80.0:
            tarpaulin_status = TarpaulinAlertStatus.HIGH_PRIORITY_PREPOSITIONING
        elif rain_24h >= 1.0 or ambient_rh >= 70.0:
            tarpaulin_status = TarpaulinAlertStatus.STANDBY_MONITORING
        else:
            tarpaulin_status = TarpaulinAlertStatus.NO_DEPLOYMENT_NEEDED

        # Overall Risk Tier
        has_perilous = any(cm.moisture_state == GrainMoistureState.PERILOUS_FERMENTATION_RISK for cm in crop_metrics)
        if rain_24h >= 25.0 or hail_prob >= 40.0 or aflatoxin_risk == MycotoxinAflatoxinRisk.EXTREME_AFLATOXIN_OUTBREAK or has_perilous:
            overall_tier = MandiWeatherRiskTier.CRITICAL_SPOILAGE_RISK
        elif rain_24h >= 8.0 or aflatoxin_risk == MycotoxinAflatoxinRisk.HIGH_FUNGAL_PROLIFERATION or any(cm.moisture_state == GrainMoistureState.UNSAFE_ELEVATED_MOISTURE for cm in crop_metrics):
            overall_tier = MandiWeatherRiskTier.HIGH_MOISTURE_SURGE
        elif rain_24h >= 2.0 or ambient_rh >= 75.0:
            overall_tier = MandiWeatherRiskTier.MODERATE_WEATHER_ALERT
        else:
            overall_tier = MandiWeatherRiskTier.SAFE_STORAGE_OPTIMAL

        # Storage Directives
        aeration_directive = (
            "SHUT DOWN AERATION FANS IMMEDIATELY: High ambient relative humidity (>70%) will pump atmospheric moisture into grain stacks, accelerating hot-spot fermentation."
            if ambient_rh >= 70.0
            else "RUN AERATION FANS ON SCHEDULE: Ambient relative humidity is below 70%. Forced ventilation will dissipate internal biological heat and equilibrate grain safely."
        )

        evac_needed = bool(rain_24h > 20.0 or inundation_risk > 65.0)

        actions: List[str] = [
            f"Maintain minimum 15.0 cm wooden dunnage crates beneath all bag stacks (current: {dunnage_h:.1f} cm) to eliminate ground moisture wicking.",
            "Fasten HDPE 250+ GSM tarpaulins (tirpals) over all open plinth lots using sandbag ballasts and nylon anchor ropes against wind gusts.",
            aeration_directive,
            "Inspect grain heaps with digital moisture meters every 4 hours during peak diurnal humidity shifts.",
        ]
        if evac_needed:
            actions.insert(0, "URGENT: Initiate prioritized evacuation of open yard grain heaps to covered auction sheds.")

        storage_directives = MandiStorageDirectives(
            tarpaulin_status=tarpaulin_status,
            dunnage_pallet_height_recommendation_cm=15.0,
            aeration_fan_schedule_recommendation=aeration_directive,
            open_platform_evacuation_needed=evac_needed,
            recommended_actions=actions,
        )

        # Monitored Mandis network summary
        monitored_list: List[MandiSummary] = []
        for hid, hub in cls.MANDI_HUBS.items():
            hseed = int(abs(hub.latitude * 100 + hub.longitude * 10)) % 100
            hrh = round(62.0 + (hseed % 28), 1)
            hrain = round(float((hseed * 3.7) % 45.0), 1)
            if hrain >= 20.0:
                htier = MandiWeatherRiskTier.CRITICAL_SPOILAGE_RISK
                htarp = TarpaulinAlertStatus.IMMEDIATE_TIRPAL_DEPLOYMENT
            elif hrain >= 8.0:
                htier = MandiWeatherRiskTier.HIGH_MOISTURE_SURGE
                htarp = TarpaulinAlertStatus.HIGH_PRIORITY_PREPOSITIONING
            elif hrain >= 2.0 or hrh >= 75.0:
                htier = MandiWeatherRiskTier.MODERATE_WEATHER_ALERT
                htarp = TarpaulinAlertStatus.STANDBY_MONITORING
            else:
                htier = MandiWeatherRiskTier.SAFE_STORAGE_OPTIMAL
                htarp = TarpaulinAlertStatus.NO_DEPLOYMENT_NEEDED

            monitored_list.append(
                MandiSummary(
                    mandi_id=hub.mandi_id,
                    name=hub.name,
                    state=hub.state,
                    risk_tier=htier,
                    predominant_crop=hub.primary_commodities[0],
                    current_ambient_rh_pct=hrh,
                    tarpaulin_status=htarp,
                )
            )

        # Vernacular Bulletins (7 languages)
        bulletins: Dict[str, str] = {
            "en": f"IMD-ICAR MANDI ALERT for {target_hub.name}: Overall spoilage threat is {overall_tier.value}. Ambient RH is {ambient_rh}%, 24h rain forecast is {rain_24h} mm. Tarpaulin status: {tarpaulin_status.value}. Ensure 15cm dunnage elevation and adhere to grain aeration schedules.",
            "hi": f"भाकृअनुप-आईएमडी मंडी भंडारण चेतावनी ({target_hub.name}): समग्र भंडारण जोखिम '{overall_tier.value}' है। हवा में नमी {ambient_rh}% तथा 24 घंटे में {rain_24h} मिमी बारिश का अनुमान है। तिरपाल तत्काल ढकें तथा बोरियों को 15 सेमी ऊंचे क्रेट्स पर रखें।",
            "pa": f"ਆਈਐਮਡੀ-ਆਈਸੀਏਆਰ ਮੰਡੀ ਭੰਡਾਰਨ ਚਿਤਾਵਨੀ ({target_hub.name}): ਅਨਾਜ ਨੁਕਸਾਨ ਦਾ ਖਤਰਾ '{overall_tier.value}' ਹੈ। ਨਮੀ {ambient_rh}% ਅਤੇ ਮੀਂਹ {rain_24h} ਮਿਲੀਮੀਟਰ ਸੰਭਵ ਹੈ। ਦਾਣਿਆਂ ਦੀਆਂ ਬੋਰੀਆਂ ਨੂੰ ਲੱਕੜ ਦੇ ਤਖਤਿਆਂ (15 ਸੈਂਟੀਮੀਟਰ) 'ਤੇ ਰੱਖੋ ਅਤੇ ਤਰਪਾਲਾਂ ਨਾਲ ਢੱਕੋ।",
            "mr": f"आयसीएआर-आयएमडी कृषी बाजार चेतावणी ({target_hub.name}): धान्य नासाडीचा धोका '{overall_tier.value}' आहे. हवेतील आर्द्रता {ambient_rh}% असून {rain_24h} मिमी पावसाची शक्यता आहे. ताडपत्री तातडीने बांधा आणि पोत्याखाली १५ सेमी लाकडी क्रेट्स वापरा.",
            "te": f"ఐసీఏఆర్-ఐఎండి మార్కెట్ యార్డ్ భద్రతా హెచ్చరిక ({target_hub.name}): నిల్వ ప్రమాద స్థాయి '{overall_tier.value}'. గాలిలో తేమ {ambient_rh}%, 24 గంటల్లో {rain_24h} మి.మీ వర్ష సూచన. ధాన్యపు బస్తాలను 15 సెం.మీ ఎత్తు గల చెక్క క్రేట్లపై ఉంచి టార్పాలిన్లతో కప్పండి.",
            "gu": f"આઈસીએઆર-આઈએમડી માર્કેટ યાર્ડ સંગ્રહ ચેતવણી ({target_hub.name}): ધાન્ય બગાડનું જોખમ '{overall_tier.value}' છે. વાતાવરણમાં ભેજ {ambient_rh}% અને {rain_24h} મીમી વરસાદની આગાહી છે. તાલપત્રી તરત ઢાંકો અને થપ્પી નીચે 15 સેમી ડનેજ રાખો.",
            "bn": f"আইসিএআর-আইএমডি মান্ডি গুদাম সতর্কতা ({target_hub.name}): শস্য পচনের ঝুঁকি '{overall_tier.value}'। আর্দ্রতা {ambient_rh}% এবং ২৪ ঘণ্টায় {rain_24h} মিমি বৃষ্টিপাতের সম্ভাবনা। অবিলম্বে ত্রিপল বাঁধুন এবং ১৫ সেমি উঁচু মাচার উপর বস্তা রাখুন।",
        }

        # Institutional Metadata
        metadata: Dict[str, str] = {
            "source_authority": "IMD Agromet Division & ICAR-CIPHET (Central Institute of Post-Harvest Engineering & Technology)",
            "statutory_reference": "Food Safety and Standards Authority of India (FSSAI) Maximum Limit for Aflatoxin B1 (15 ppb)",
            "formulation": "Modified Henderson-Thompson Equilibrium Moisture Content (ASABE D245.7 Standards)",
            "operational_standard": "Food Corporation of India (FCI) & Central Warehousing Corporation (CWC) CAP Storage Code of Practice",
            "generated_at": datetime.now(timezone.utc).isoformat(),
        }

        return AgriStorageResponse(
            mandi=target_hub,
            assessment_timestamp=datetime.now(timezone.utc).isoformat(),
            overall_risk_tier=overall_tier,
            ambient_temperature_c=ambient_temp,
            ambient_relative_humidity_pct=ambient_rh,
            weather_condition=condition,
            crop_hygroscopic_metrics=crop_metrics,
            open_yard_telemetry=open_yard,
            fungal_mycotoxin_telemetry=fungal_telemetry,
            storage_directives=storage_directives,
            monitored_mandis=monitored_list,
            vernacular_bulletins=bulletins,
            metadata=metadata,
        )
