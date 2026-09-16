"""Service implementation for IMD & CWC National Flood Forecasting,
Hydrological Rating Curve & Embankment Breach Telemetry Engine (HYDRO-RATING).
"""

from datetime import datetime, timezone
import math
from typing import Dict, List, Optional

from app.schemas.hydro_rating import (
    BasinSummary,
    CwcBenchmarkLevels,
    CwcFloodStageTier,
    EmbankmentPipingRiskTier,
    EmbankmentStructuralSafetyMetrics,
    FreeboardSafetyMarginTier,
    GumbelFloodReturnPeriod,
    GumbelFrequencyAnalysis,
    HydrologicalRatingCurveTelemetry,
    HydroRatingResponse,
    RiparianDefenseDirectives,
    RiverBasinHydroStation,
)


class HydroRatingService:
    """Calculates non-linear stage-discharge rating curves, Manning conveyance,
    levee freeboard margins, exit hydraulic gradient piping safety, and CWC flood alerts.
    """

    # 7 Calibrated National River Basins across India
    STATIONS_CATALOG = {
        "kosi_baltara": {
            "station_id": "kosi_baltara",
            "station_name": "Baltara Gauge Station",
            "river_name": "Kosi River",
            "state_name": "Bihar",
            "latitude": 25.68,
            "longitude": 86.68,
            "cwc_division": "Middle Ganga Division III, Patna",
            "zero_flow_datum_m": 28.50,
            "warning_level_m": 33.85,
            "danger_level_m": 34.75,
            "hfl_m": 36.40,
            "hfl_year": 2008,
            "crest_level_m": 37.80,
            "countryside_toe_m": 30.20,
            "current_stage_m": 35.15,  # In Danger Stage
            "coeff_a": 64.20,
            "exp_b": 1.92,
            "manning_n": 0.034,
            "slope_s0": 0.00030,
            "seepage_path_l_m": 32.0,
            "sand_boil_detected": False,
            "q10": 14500.0,
            "q25": 18200.0,
            "q50": 21400.0,
            "q100": 24800.0,
        },
        "brahmaputra_pandu": {
            "station_id": "brahmaputra_pandu",
            "station_name": "Pandu Gauge Station",
            "river_name": "Brahmaputra River",
            "state_name": "Assam",
            "latitude": 26.17,
            "longitude": 91.68,
            "cwc_division": "Brahmaputra & Barak Basin Organization, Guwahati",
            "zero_flow_datum_m": 40.00,
            "warning_level_m": 48.68,
            "danger_level_m": 49.68,
            "hfl_m": 51.46,
            "hfl_year": 2004,
            "crest_level_m": 52.80,
            "countryside_toe_m": 44.50,
            "current_stage_m": 50.12,  # In Danger Stage
            "coeff_a": 112.50,
            "exp_b": 1.98,
            "manning_n": 0.038,
            "slope_s0": 0.00018,
            "seepage_path_l_m": 45.0,
            "sand_boil_detected": True,  # Active piping watch
            "q10": 48000.0,
            "q25": 56000.0,
            "q50": 62500.0,
            "q100": 71000.0,
        },
        "ganga_farakka": {
            "station_id": "ganga_farakka",
            "station_name": "Farakka Barrage Gauge Site",
            "river_name": "Ganga River",
            "state_name": "West Bengal",
            "latitude": 24.81,
            "longitude": 87.91,
            "cwc_division": "Lower Ganga Basin Organization, Kolkata",
            "zero_flow_datum_m": 15.00,
            "warning_level_m": 21.25,
            "danger_level_m": 22.25,
            "hfl_m": 23.90,
            "hfl_year": 1998,
            "crest_level_m": 25.20,
            "countryside_toe_m": 17.50,
            "current_stage_m": 21.80,  # Warning Stage
            "coeff_a": 88.00,
            "exp_b": 1.88,
            "manning_n": 0.032,
            "slope_s0": 0.00015,
            "seepage_path_l_m": 38.0,
            "sand_boil_detected": False,
            "q10": 52000.0,
            "q25": 61000.0,
            "q50": 68000.0,
            "q100": 76000.0,
        },
        "godavari_dowleswaram": {
            "station_id": "godavari_dowleswaram",
            "station_name": "Sir Arthur Cotton Barrage",
            "river_name": "Godavari River",
            "state_name": "Andhra Pradesh",
            "latitude": 16.94,
            "longitude": 81.76,
            "cwc_division": "Godavari Basin Organization, Hyderabad",
            "zero_flow_datum_m": 8.00,
            "warning_level_m": 13.75,
            "danger_level_m": 15.25,
            "hfl_m": 17.80,
            "hfl_year": 1986,
            "crest_level_m": 19.50,
            "countryside_toe_m": 10.50,
            "current_stage_m": 14.60,  # Warning Stage (1st to 2nd Warning)
            "coeff_a": 95.00,
            "exp_b": 1.85,
            "manning_n": 0.030,
            "slope_s0": 0.00022,
            "seepage_path_l_m": 35.0,
            "sand_boil_detected": False,
            "q10": 42000.0,
            "q25": 51000.0,
            "q50": 58000.0,
            "q100": 66000.0,
        },
        "mahanadi_mundali": {
            "station_id": "mahanadi_mundali",
            "station_name": "Mundali Barrage Gauge Station",
            "river_name": "Mahanadi River",
            "state_name": "Odisha",
            "latitude": 20.44,
            "longitude": 85.74,
            "cwc_division": "Mahanadi & Eastern Rivers Organization, Bhubaneswar",
            "zero_flow_datum_m": 18.00,
            "warning_level_m": 25.40,
            "danger_level_m": 26.25,
            "hfl_m": 27.35,
            "hfl_year": 2008,
            "crest_level_m": 28.90,
            "countryside_toe_m": 20.00,
            "current_stage_m": 25.10,  # Above Normal
            "coeff_a": 72.00,
            "exp_b": 1.90,
            "manning_n": 0.035,
            "slope_s0": 0.00028,
            "seepage_path_l_m": 30.0,
            "sand_boil_detected": False,
            "q10": 28000.0,
            "q25": 34000.0,
            "q50": 39000.0,
            "q100": 45000.0,
        },
        "yamuna_delhi": {
            "station_id": "yamuna_delhi",
            "station_name": "Old Railway Bridge (ORB)",
            "river_name": "Yamuna River",
            "state_name": "Delhi NCR",
            "latitude": 28.66,
            "longitude": 77.25,
            "cwc_division": "Upper Ganga Basin Organization, New Delhi",
            "zero_flow_datum_m": 198.00,
            "warning_level_m": 204.50,
            "danger_level_m": 205.33,
            "hfl_m": 208.66,
            "hfl_year": 2023,
            "crest_level_m": 209.50,
            "countryside_toe_m": 201.00,
            "current_stage_m": 205.85,  # Danger Stage
            "coeff_a": 48.00,
            "exp_b": 1.78,
            "manning_n": 0.040,
            "slope_s0": 0.00035,
            "seepage_path_l_m": 25.0,
            "sand_boil_detected": False,
            "q10": 7200.0,
            "q25": 8900.0,
            "q50": 10400.0,
            "q100": 12200.0,
        },
        "narmada_golden_bridge": {
            "station_id": "narmada_golden_bridge",
            "station_name": "Golden Bridge Gauge Site",
            "river_name": "Narmada River",
            "state_name": "Gujarat",
            "latitude": 21.71,
            "longitude": 72.98,
            "cwc_division": "Narmada Basin Organization, Vadodara",
            "zero_flow_datum_m": 1.50,
            "warning_level_m": 7.32,
            "danger_level_m": 9.14,
            "hfl_m": 12.75,
            "hfl_year": 2023,
            "crest_level_m": 14.20,
            "countryside_toe_m": 3.50,
            "current_stage_m": 8.45,  # Warning Stage
            "coeff_a": 58.50,
            "exp_b": 1.84,
            "manning_n": 0.033,
            "slope_s0": 0.00032,
            "seepage_path_l_m": 28.0,
            "sand_boil_detected": False,
            "q10": 22000.0,
            "q25": 27500.0,
            "q50": 32000.0,
            "q100": 38000.0,
        },
    }

    @classmethod
    def _find_station(
        cls,
        basin_id: Optional[str] = None,
        lat: Optional[float] = None,
        lon: Optional[float] = None,
    ) -> Dict:
        """Finds basin station by exact id or nearest coordinates."""
        if basin_id and basin_id in cls.STATIONS_CATALOG:
            return cls.STATIONS_CATALOG[basin_id]

        if lat is not None and lon is not None:
            best_id = "kosi_baltara"
            best_dist = float("inf")
            for sid, data in cls.STATIONS_CATALOG.items():
                dist = (data["latitude"] - lat) ** 2 + (data["longitude"] - lon) ** 2
                if dist < best_dist:
                    best_dist = dist
                    best_id = sid
            return cls.STATIONS_CATALOG[best_id]

        return cls.STATIONS_CATALOG["kosi_baltara"]

    @classmethod
    def compute_station_metrics(cls, raw: Dict) -> RiverBasinHydroStation:
        """Calculates non-linear rating curve discharge, Manning conveyance,
        freeboard safety, exit hydraulic gradient piping stability, and CWC alerts.
        """
        stage = raw["current_stage_m"]
        h0 = raw["zero_flow_datum_m"]
        wl = raw["warning_level_m"]
        dl = raw["danger_level_m"]
        hfl = raw["hfl_m"]
        crest = raw["crest_level_m"]
        toe = raw["countryside_toe_m"]
        a = raw["coeff_a"]
        b = raw["exp_b"]
        manning_n = raw["manning_n"]
        s0 = raw["slope_s0"]
        l_seep = raw["seepage_path_l_m"]

        # 1. Non-linear Rating Curve: Q = a * (h - h0)^b
        eff_head = max(0.1, stage - h0)
        discharge_q = round(a * (eff_head**b), 1)

        # Open-channel Manning conveyance and mean velocity:
        # Cross-sectional area A approx derived from hydraulic geometry:
        # A = 120.0 * (eff_head ^ 1.35), Hydraulic radius Rh = 0.65 * (eff_head ^ 0.82)
        area_a = round(120.0 * (eff_head**1.35), 1)
        rh = round(0.65 * (eff_head**0.82), 2)
        mean_vel = round(discharge_q / max(1.0, area_a), 2)

        # 2. CWC Flood Stage Tier
        if stage >= hfl:
            flood_tier = CwcFloodStageTier.UNPRECEDENTED_FLOOD
            color = "#7C3AED"  # Purple / Catastrophic
            urgency = "CATASTROPHIC_EMERGENCY_EVACUATE"
        elif stage >= dl:
            flood_tier = CwcFloodStageTier.DANGER_STAGE
            color = "#DC2626"  # Red / Severe Danger
            urgency = "IMMEDIATE_RIPARIAN_EVACUATION"
        elif stage >= wl:
            flood_tier = CwcFloodStageTier.WARNING_STAGE
            color = "#D97706"  # Amber / Warning
            urgency = "STANDBY_CHAR_DIARA_ALERT"
        elif stage >= (wl - 0.5):
            flood_tier = CwcFloodStageTier.ABOVE_NORMAL
            color = "#2563EB"  # Blue / Alert
            urgency = "ADVISORY_MONITORING"
        else:
            flood_tier = CwcFloodStageTier.NORMAL_FLOW
            color = "#059669"  # Green / Normal
            urgency = "ROUTINE_MONITORING"

        # 3. Levee Crest Freeboard Margin
        freeboard_m = round(crest - stage, 2)
        if freeboard_m > 1.50:
            freeboard_tier = FreeboardSafetyMarginTier.OPTIMAL_FREEBOARD
        elif freeboard_m > 0.75:
            freeboard_tier = FreeboardSafetyMarginTier.REDUCED_MARGIN
        elif freeboard_m > 0.00:
            freeboard_tier = FreeboardSafetyMarginTier.OVERTOPPING_THREAT
        else:
            freeboard_tier = FreeboardSafetyMarginTier.CREST_OVERTOPPING_BREACH

        # 4. Embankment Piping & Seepage Hydraulic Gradient Instability
        # Exit hydraulic gradient i = Delta_h / L where Delta_h = stage - countryside_toe
        delta_head = max(0.0, stage - toe)
        exit_grad = round(delta_head / max(1.0, l_seep), 3)
        icrit = 1.0  # (Gs - 1) / (1 + e) approx 1.0 for alluvial silty sand
        fs_piping = round(icrit / max(0.001, exit_grad), 2)

        sand_boil = raw.get("sand_boil_detected", False)
        if fs_piping < 1.20 or freeboard_m <= 0.0:
            piping_tier = EmbankmentPipingRiskTier.IMMINENT_COLLAPSE_BREACH
        elif fs_piping < 1.80 or sand_boil:
            piping_tier = EmbankmentPipingRiskTier.HIGH_SANDBOIL_RISK
        elif fs_piping < 2.50:
            piping_tier = EmbankmentPipingRiskTier.PIPING_WATCH
        else:
            piping_tier = EmbankmentPipingRiskTier.SAFE_STABLE

        # 5. Gumbel EV1 Recurrence Interval
        q10 = raw["q10"]
        q25 = raw["q25"]
        q50 = raw["q50"]
        q100 = raw["q100"]

        if discharge_q >= q100:
            gumbel_cat = GumbelFloodReturnPeriod.HUNDRED_YEAR_RECORD
            aep = 1.0
        elif discharge_q >= q50:
            gumbel_cat = GumbelFloodReturnPeriod.FIFTY_YEAR_FLOOD
            aep = 2.0
        elif discharge_q >= q25:
            gumbel_cat = GumbelFloodReturnPeriod.TWENTY_FIVE_YEAR_FLOOD
            aep = 4.0
        elif discharge_q >= q10:
            gumbel_cat = GumbelFloodReturnPeriod.TEN_YEAR_FLOOD
            aep = 10.0
        else:
            gumbel_cat = GumbelFloodReturnPeriod.LESS_THAN_10_YEAR
            aep = 25.0

        # Directives
        if piping_tier in [
            EmbankmentPipingRiskTier.HIGH_SANDBOIL_RISK,
            EmbankmentPipingRiskTier.IMMINENT_COLLAPSE_BREACH,
        ]:
            piping_directive = (
                "CRITICAL: Construct inverted sandbag ring filter bunds around countryside boils "
                "to equalize hydrostatic backpressure. Do NOT plug boils directly with clay."
            )
            patrol_freq = "Continuous 24x7 Foot Vigil (30-Minute Checkpoints)"
        elif piping_tier == EmbankmentPipingRiskTier.PIPING_WATCH:
            piping_directive = (
                "Deploy geo-textile filter rolls and stockpile crushed stone gravel at embankment toe. "
                "Monitor seepage turbidity every 2 hours."
            )
            patrol_freq = "High Vigil (2-Hour Patrol Intervals)"
        else:
            piping_directive = "Standard visual inspection of revetments, porcupine spurs, and drainage sluices."
            patrol_freq = "Daily Routine Inspections"

        if flood_tier in [CwcFloodStageTier.DANGER_STAGE, CwcFloodStageTier.UNPRECEDENTED_FLOOD]:
            riparian_safety = (
                f"River stage ({stage}m) exceeds Danger Level ({dl}m). Immediate vertical and high-ground "
                f"evacuation of chars, diaras, and low-lying floodplain hamlets to designated flood shelters."
            )
            water_sanitation = (
                "Super-chlorinate all borewells and tube-wells (bleaching powder 2.5 kg/1000L). Distribute "
                "halogen tablets (1 tablet per 20L boiled water) to prevent waterborne epidemic outbreaks."
            )
        else:
            riparian_safety = (
                f"River flowing at {stage}m MSL. Stay clear of riverbank erosional scarps, shifting sandbanks, "
                f"and low-lying agricultural floodways."
            )
            water_sanitation = "Maintain boiled drinking water protocols in riparian zones."

        rating_telemetry = HydrologicalRatingCurveTelemetry(
            stage_height_m=stage,
            zero_flow_datum_h0_m=h0,
            effective_head_m=round(eff_head, 2),
            rating_coefficient_a=a,
            hydraulic_exponent_b=b,
            computed_discharge_cumecs=discharge_q,
            wetted_cross_section_area_m2=area_a,
            hydraulic_radius_m=rh,
            manning_roughness_n=manning_n,
            channel_energy_slope=s0,
            mean_flow_velocity_mps=mean_vel,
        )

        embankment_metrics = EmbankmentStructuralSafetyMetrics(
            embankment_crest_level_m=crest,
            countryside_toe_level_m=toe,
            freeboard_margin_m=freeboard_m,
            freeboard_tier=freeboard_tier,
            seepage_path_length_m=l_seep,
            exit_hydraulic_gradient=exit_grad,
            critical_hydraulic_gradient=icrit,
            piping_factor_of_safety=fs_piping,
            piping_risk_tier=piping_tier,
            sand_boil_detected=sand_boil,
        )

        benchmarks = CwcBenchmarkLevels(
            zero_flow_datum_m=h0,
            warning_level_m=wl,
            danger_level_m=dl,
            highest_flood_level_hfl_m=hfl,
            hfl_record_year=raw["hfl_year"],
            embankment_crest_m=crest,
        )

        gumbel = GumbelFrequencyAnalysis(
            discharge_10yr_cumecs=q10,
            discharge_25yr_cumecs=q25,
            discharge_50yr_cumecs=q50,
            discharge_100yr_cumecs=q100,
            current_return_period=gumbel_cat,
            annual_exceedance_probability_pct=aep,
        )

        directives = RiparianDefenseDirectives(
            flood_warning_color=color,
            evacuation_urgency_level=urgency,
            embankment_patrol_frequency=patrol_freq,
            piping_countermeasure_directive=piping_directive,
            riparian_safety_protocol=riparian_safety,
            drinking_water_sanitation_advisory=water_sanitation,
        )

        return RiverBasinHydroStation(
            station_id=raw["station_id"],
            station_name=raw["station_name"],
            river_name=raw["river_name"],
            state_name=raw["state_name"],
            latitude=raw["latitude"],
            longitude=raw["longitude"],
            cwc_division=raw["cwc_division"],
            flood_stage_tier=flood_tier,
            benchmarks=benchmarks,
            rating_curve=rating_telemetry,
            embankment_safety=embankment_metrics,
            gumbel_frequency=gumbel,
            directives=directives,
        )

    @classmethod
    def _generate_vernacular_bulletins(cls, station: RiverBasinHydroStation) -> Dict[str, str]:
        """Generates 7-language riparian flood emergency bulletins."""
        r_name = station.river_name
        s_name = station.station_name
        stage = station.rating_curve.stage_height_m
        dl = station.benchmarks.danger_level_m
        q = station.rating_curve.computed_discharge_cumecs
        freeboard = station.embankment_safety.freeboard_margin_m
        tier = station.flood_stage_tier.value

        en = (
            f"CWC & IMD FLOOD BULLETIN: {r_name} at {s_name} is flowing at {stage}m MSL "
            f"(Danger Level: {dl}m, Status: {tier}). Rating curve discharge: {q} cumecs. "
            f"Embankment freeboard margin is {freeboard}m. Riparian communities in low-lying "
            f"floodplains must adhere to NDMA evacuation protocols and monitor levee toes."
        )

        hi = (
            f"केंद्रीय जल आयोग (CWC) एवं IMD बाढ़ चेतावनी: {s_name} पर {r_name} का जलस्तर "
            f"{stage} मीटर MSL पर प्रवाहित हो रहा है (खतरा निशान: {dl} मीटर, स्थिति: {tier})। "
            f"अनुमानित जल बहाव {q} क्यूमेक्स है। तटबंध फ्रीबोर्ड मार्जिन {freeboard} मीटर है। "
            f"दियारा एवं निचले तटीय क्षेत्रों के निवासी तत्काल सुरक्षित बाढ़ आश्रयों में शरण लें।"
        )

        as_bulletin = (
            f"কেন্দ্ৰীয় জল আয়োগ (CWC) আৰু IMD বান সতৰ্কবাৰ্তা: {s_name}ত {r_name}ৰ জলস্তৰ "
            f"{stage} মিটাৰলৈ বৃদ্ধি পাইছে (বিপদসীমা: {dl} মিটাৰ, স্তৰ: {tier})। "
            f"পানীৰ নিষ্কাশন {q} কিউমেক্স। মথাউৰিৰ সুৰক্ষা মাৰ্জিন {freeboard} মিটাৰ। "
            f"নদীদ্বীপ (চাপৰি) আৰু দাঁতিকাষৰীয়া অঞ্চলৰ ৰাইজক উচ্চ সুৰক্ষিত স্থানলৈ যাবলৈ আহ্বান।"
        )

        bn = (
            f"কেন্দ্রীয় জল কমিশন (CWC) ও IMD বন্যা বুলেটিন: {s_name}-এ {r_name}-এর জলস্তর "
            f"{stage} মিটার MSL (বিপদসীমা: {dl} মিটার, স্থিতি: {tier})। জলপ্রবাহ {q} কিউমেক। "
            f"বাঁধের ফ্রি-বোর্ড মার্জিন {freeboard} মিটার। নদী তীরবর্তী চর ও প্লাবনভূমির বাসিন্দাদের "
            f"অবিলম্বে নিরাপদ আশ্রয়কেন্দ্রে পৌঁছানোর পরামর্শ দেওয়া হচ্ছে।"
        )

        od = (
            f"କେନ୍ଦ୍ରୀୟ ଜଳ ଆୟୋଗ (CWC) ଓ IMD ବନ୍ୟା ସତର୍କତା: {s_name} ଠାରେ {r_name}ର ଜଳସ୍ତର "
            f"{stage} ମିଟରରେ ପ୍ରବାହିତ ହେଉଛି (ବିପଦ ସଙ୍କେତ: {dl} ମିଟର, ସ୍ଥିତି: {tier})। ଜଳ ନିଷ୍କାସନ "
            f"{q} କ୍ୟୁମେକ୍ସ। ନଦୀବନ୍ଧ ସୁରକ୍ଷା ମାର୍ଜିନ {freeboard} ମିଟର। ତଳିଆ ଅଞ୍ଚଳ ବାସୀ ସୁରକ୍ଷିତ ଆଶ୍ରୟସ୍ଥଳକୁ ଯାଆନ୍ତୁ।"
        )

        te = (
            f"కేంద్ర జల సంఘం (CWC) & IMD వరద హెచ్చరిక: {s_name} వద్ద {r_name} నీటిమట్టం "
            f"{stage} మీటర్లకు చేరింది (ప్రమాద హెచ్చరిక: {dl} మీటర్లు, స్థితి: {tier}). "
            f"నీటి విడుదల {q} క్యూమెక్స్. గట్టు రక్షణ మార్జిన్ {freeboard} మీటర్లు. "
            f"లంక గ్రామాలు మరియు లోతట్టు ప్రాంతాల ప్రజలు వెంటనే సహాయక శిబిరాలకు తరలివెళ్లాలి."
        )

        gu = (
            f"સેન્ટ્રલ વોટર કમિશન (CWC) અને IMD પૂર બુલેટિન: {s_name} ખાતે {r_name}નું જળસ્તર "
            f"{stage} મીટર MSL પર વહી રહ્યું છે (ભયજનક સપાટી: {dl} મીટર, સ્થિતિ: {tier}). "
            f"ડિસ્ચાર્જ {q} ક્યૂમેક્સ છે. પાળાની ફ્રીબોર્ડ માર્જિન {freeboard} મીટર છે. "
            f"નદીકાંઠાના નીચાણવાળા વિસ્તારોના લોકોએ તાત્કાલિક સુરક્ષિત સ્થળે ખસી જવું."
        )

        return {
            "EN": en,
            "HI": hi,
            "AS": as_bulletin,
            "BN": bn,
            "OD": od,
            "TE": te,
            "GU": gu,
        }

    @classmethod
    def get_assessment(
        cls,
        basin_id: Optional[str] = None,
        lat: Optional[float] = None,
        lon: Optional[float] = None,
    ) -> HydroRatingResponse:
        """Generates comprehensive hydrological rating curve telemetry, levee stability,
        Gumbel recurrence, and 7-language riparian evacuation bulletins.
        """
        raw_active = cls._find_station(basin_id=basin_id, lat=lat, lon=lon)
        active_station = cls.compute_station_metrics(raw_active)

        # Build summaries for all 7 stations
        all_summaries: List[BasinSummary] = []
        for sid, s_raw in cls.STATIONS_CATALOG.items():
            st_metrics = cls.compute_station_metrics(s_raw)
            all_summaries.append(
                BasinSummary(
                    station_id=sid,
                    station_name=s_raw["station_name"],
                    river_name=s_raw["river_name"],
                    state_name=s_raw["state_name"],
                    stage_height_m=s_raw["current_stage_m"],
                    danger_level_m=s_raw["danger_level_m"],
                    flood_stage_tier=st_metrics.flood_stage_tier,
                    freeboard_margin_m=st_metrics.embankment_safety.freeboard_margin_m,
                    piping_risk_tier=st_metrics.embankment_safety.piping_risk_tier,
                )
            )

        bulletins = cls._generate_vernacular_bulletins(active_station)

        return HydroRatingResponse(
            timestamp=datetime.now(timezone.utc).isoformat(),
            active_station=active_station,
            all_stations=all_summaries,
            vernacular_bulletins=bulletins,
        )
