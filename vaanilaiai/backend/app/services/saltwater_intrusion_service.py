"""Service implementation for IMD, INCOIS & CGWB Coastal Estuarine Saltwater Intrusion,
Tidal Prism & Groundwater Salinization Engine (SALTWATER-TIDE).
"""

from datetime import datetime, timezone
import math
from typing import Dict, List, Optional

from app.schemas.saltwater_intrusion import (
    AquiferVulnerabilityTier,
    CoastalAgricultureDirectives,
    CoastalEstuarineZone,
    CoastalZoneSummary,
    EstuarineSalineWedgeTelemetry,
    GhybenHerzbergAquiferMetrics,
    SalinitySeverityTier,
    SaltwaterIntrusionResponse,
    TidalPrismPhase,
)


class SaltwaterIntrusionService:
    """Calculates Ghyben-Herzberg coastal aquifer freshwater lens depth, estuarine saline wedge
    penetration length, mineralization indices (EC, TDS, SAR), and ICAR-CSSRI farming directives.
    """

    # 7 Strategic Monitored Coastal Belts across India
    COASTAL_ZONES = {
        "sundarbans_delta": {
            "zone_id": "sundarbans_delta",
            "zone_name": "Sundarbans Estuarine Delta",
            "coastal_district": "South 24 Parganas",
            "state_name": "West Bengal",
            "latitude": 22.15,
            "longitude": 88.80,
            "coastal_body_type": "Tidal Delta & Mangrove Estuary",
            "estuary_name": "Matla & Bidyadhari Estuary",
            "river_mouth_distance_km": 18.0,
            "upstream_q_cumecs": 45.0,
            "channel_depth_m": 12.0,
            "surface_salinity_ppt": 14.5,
            "bottom_salinity_ppt": 22.0,
            "tidal_range_m": 4.80,
            "tidal_phase": TidalPrismPhase.SPRING_HIGH_TIDE,
            "tidal_prism_million_m3": 142.0,
            "piezometric_head_m_msl": 0.65,
            "measured_interface_m": 22.0,
            "upconing_rate_cm_week": 4.2,
            "ec_us_cm": 3850.0,
            "sar": 7.8,
            "chloride_mg_l": 1120.0,
            "sluice_status": "CLOSED",
            "sluice_notice": "Flap gates locked 2.5 hours prior to high astronomical spring tide peak.",
            "pumping_limit_hours": 2.5,
            "crops": ["CSR-36 Salt-Tolerant Rice", "Amal-Mana", "Dhaincha (Sesbania)"],
            "gypsum_tons_ha": 3.5,
            "ro_alert": "Membrane scaling alert: Raw intake TDS exceeds 2400 mg/L. Engage dual anti-scalant dosing.",
        },
        "cauvery_delta": {
            "zone_id": "cauvery_delta",
            "zone_name": "Cauvery Delta Maritime Aquifer",
            "coastal_district": "Nagapattinam",
            "state_name": "Tamil Nadu",
            "latitude": 11.20,
            "longitude": 79.83,
            "coastal_body_type": "Deltaic Estuary & Coastal Sands",
            "estuary_name": "Kollidam (Coleroon) Estuary",
            "river_mouth_distance_km": 12.0,
            "upstream_q_cumecs": 25.0,
            "channel_depth_m": 6.5,
            "surface_salinity_ppt": 8.5,
            "bottom_salinity_ppt": 15.0,
            "tidal_range_m": 1.20,
            "tidal_phase": TidalPrismPhase.NEAP_HIGH_TIDE,
            "tidal_prism_million_m3": 38.0,
            "piezometric_head_m_msl": -0.40,  # Below MSL
            "measured_interface_m": 14.0,
            "upconing_rate_cm_week": 6.5,
            "ec_us_cm": 4600.0,
            "sar": 9.2,
            "chloride_mg_l": 1450.0,
            "sluice_status": "CLOSED",
            "sluice_notice": "Lock gates closed. Moratorium on estuarine pumping during flood tide.",
            "pumping_limit_hours": 1.5,
            "crops": ["TRY-1 Salt-Tolerant Paddy", "TRY-3", "VBN-3 Blackgram"],
            "gypsum_tons_ha": 4.5,
            "ro_alert": "Critical Aquifer Salinization: Deep borewells pumping brackish water. Desalination mandatory.",
        },
        "krishna_godavari": {
            "zone_id": "krishna_godavari",
            "zone_name": "Krishna-Godavari Estuarine Belt",
            "coastal_district": "Dr. B.R. Ambedkar Konaseema",
            "state_name": "Andhra Pradesh",
            "latitude": 16.75,
            "longitude": 82.20,
            "coastal_body_type": "Estuarine Delta & Polder Canals",
            "estuary_name": "Gautami Godavari Estuary",
            "river_mouth_distance_km": 15.0,
            "upstream_q_cumecs": 55.0,
            "channel_depth_m": 10.0,
            "surface_salinity_ppt": 6.8,
            "bottom_salinity_ppt": 14.2,
            "tidal_range_m": 1.85,
            "tidal_phase": TidalPrismPhase.SPRING_HIGH_TIDE,
            "tidal_prism_million_m3": 64.0,
            "piezometric_head_m_msl": 0.85,
            "measured_interface_m": 28.0,
            "upconing_rate_cm_week": 2.8,
            "ec_us_cm": 2450.0,
            "sar": 5.4,
            "chloride_mg_l": 680.0,
            "sluice_status": "PARTIAL",
            "sluice_notice": "Regulate shutter height to preserve positive freshwater hydraulic head.",
            "pumping_limit_hours": 4.0,
            "crops": ["CSR-27 Halophytic Rice", "BPT-5204 (Salinity Shield)", "Coconut Palm"],
            "gypsum_tons_ha": 2.0,
            "ro_alert": "Moderate Brackish Ingress: Blend surface canal water with groundwater to maintain TDS < 800 mg/L.",
        },
        "mahanadi_estuary": {
            "zone_id": "mahanadi_estuary",
            "zone_name": "Mahanadi Coastal Estuary",
            "coastal_district": "Kendrapara",
            "state_name": "Odisha",
            "latitude": 20.25,
            "longitude": 86.65,
            "coastal_body_type": "Coastal Tidal Lagoon & Delta",
            "estuary_name": "Devi & Mahanadi Estuary",
            "river_mouth_distance_km": 14.0,
            "upstream_q_cumecs": 70.0,
            "channel_depth_m": 8.5,
            "surface_salinity_ppt": 5.2,
            "bottom_salinity_ppt": 12.0,
            "tidal_range_m": 2.40,
            "tidal_phase": TidalPrismPhase.SPRING_HIGH_TIDE,
            "tidal_prism_million_m3": 52.0,
            "piezometric_head_m_msl": 1.10,
            "measured_interface_m": 38.0,
            "upconing_rate_cm_week": 1.9,
            "ec_us_cm": 1850.0,
            "sar": 4.1,
            "chloride_mg_l": 490.0,
            "sluice_status": "CLOSED",
            "sluice_notice": "Flap gates drop automatically as Bay of Bengal tide crests at 2.4m.",
            "pumping_limit_hours": 5.0,
            "crops": ["Lunishree Saline Paddy", "SR-26B", "Green Gram"],
            "gypsum_tons_ha": 1.5,
            "ro_alert": "Potable tubewell salinity elevated in coastal Rajnagar block. Use community RO units.",
        },
        "vembanad_kuttanad": {
            "zone_id": "vembanad_kuttanad",
            "zone_name": "Vembanad Lagoon & Kuttanad Polders",
            "coastal_district": "Alappuzha",
            "state_name": "Kerala",
            "latitude": 9.60,
            "longitude": 76.40,
            "coastal_body_type": "Coastal Lagoon & Sub-Sea Level Polders",
            "estuary_name": "Vembanad Lake (Thanneermukkom Bund)",
            "river_mouth_distance_km": 8.0,
            "upstream_q_cumecs": 85.0,
            "channel_depth_m": 5.0,
            "surface_salinity_ppt": 3.5,
            "bottom_salinity_ppt": 7.2,
            "tidal_range_m": 0.95,
            "tidal_phase": TidalPrismPhase.SPRING_EBB_TIDE,
            "tidal_prism_million_m3": 22.0,
            "piezometric_head_m_msl": 0.45,
            "measured_interface_m": 15.0,
            "upconing_rate_cm_week": 2.1,
            "ec_us_cm": 1280.0,
            "sar": 3.2,
            "chloride_mg_l": 310.0,
            "sluice_status": "CLOSED",
            "sluice_notice": "Thanneermukkom Bund barrier gates strictly shut to insulate southern lake fresh pool.",
            "pumping_limit_hours": 6.0,
            "crops": ["Traditional Pokkali Rice", "Vyttila-1 Saline Resilient", "Giant Prawn"],
            "gypsum_tons_ha": 1.0,
            "ro_alert": "Maintain fresh water head in Kuttanad below-sea-level fields to avoid acid-sulfate soil salinization.",
        },
        "khambhat_narmada": {
            "zone_id": "khambhat_narmada",
            "zone_name": "Gulf of Khambhat & Narmada Estuary",
            "coastal_district": "Bharuch",
            "state_name": "Gujarat",
            "latitude": 21.68,
            "longitude": 72.85,
            "coastal_body_type": "Macrotidal Estuary & Mudflats",
            "estuary_name": "Narmada Tidal Reach (Bhadbhut)",
            "river_mouth_distance_km": 28.0,
            "upstream_q_cumecs": 18.0,
            "channel_depth_m": 11.5,
            "surface_salinity_ppt": 18.5,
            "bottom_salinity_ppt": 27.0,
            "tidal_range_m": 7.80,  # Extreme macrotidal
            "tidal_phase": TidalPrismPhase.SPRING_HIGH_TIDE,
            "tidal_prism_million_m3": 310.0,
            "piezometric_head_m_msl": 0.30,
            "measured_interface_m": 10.5,
            "upconing_rate_cm_week": 5.8,
            "ec_us_cm": 6200.0,
            "sar": 11.5,
            "chloride_mg_l": 1980.0,
            "sluice_status": "CLOSED",
            "sluice_notice": "EMERGENCY: Seawater surge past Bhadbhut. Industrial & municipal water intakes stopped.",
            "pumping_limit_hours": 1.0,
            "crops": ["Halophytic Salt-Grass", "G.Cot-23 Saline Cotton", "Castor"],
            "gypsum_tons_ha": 5.0,
            "ro_alert": "Seawater Intrusion Catastrophe: High-recovery SWRO operation required. Feedwater EC > 6000 uS/cm.",
        },
        "goa_zuari": {
            "zone_id": "goa_zuari",
            "zone_name": "Goa Mandovi-Zuari Estuary",
            "coastal_district": "North & South Goa",
            "state_name": "Goa",
            "latitude": 15.42,
            "longitude": 73.85,
            "coastal_body_type": "Tidal Estuary & Khazan Lands",
            "estuary_name": "Zuari River Estuary",
            "river_mouth_distance_km": 10.0,
            "upstream_q_cumecs": 32.0,
            "channel_depth_m": 7.2,
            "surface_salinity_ppt": 4.8,
            "bottom_salinity_ppt": 9.5,
            "tidal_range_m": 2.30,
            "tidal_phase": TidalPrismPhase.SPRING_HIGH_TIDE,
            "tidal_prism_million_m3": 44.0,
            "piezometric_head_m_msl": 1.80,
            "measured_interface_m": 65.0,
            "upconing_rate_cm_week": 0.8,
            "ec_us_cm": 920.0,
            "sar": 2.1,
            "chloride_mg_l": 195.0,
            "sluice_status": "OPEN",
            "sluice_notice": "Khazan traditional wooden sluice gates functioning normally with diurnal tidal rhythm.",
            "pumping_limit_hours": 8.0,
            "crops": ["Korgut Khazan Rice", "Arecanut", "Cashew"],
            "gypsum_tons_ha": 0.5,
            "ro_alert": "Potable water safe. Estuarine water acceptable for industrial processing.",
        },
    }

    @classmethod
    def _find_zone(
        cls,
        zone_id: Optional[str] = None,
        lat: Optional[float] = None,
        lon: Optional[float] = None,
    ) -> Dict:
        """Finds coastal zone by exact slug or nearest geodetic distance."""
        if zone_id and zone_id in cls.COASTAL_ZONES:
            return cls.COASTAL_ZONES[zone_id]

        if lat is not None and lon is not None:
            best_id = "sundarbans_delta"
            best_dist = float("inf")
            for zid, data in cls.COASTAL_ZONES.items():
                dist = (data["latitude"] - lat) ** 2 + (data["longitude"] - lon) ** 2
                if dist < best_dist:
                    best_dist = dist
                    best_id = zid
            return cls.COASTAL_ZONES[best_id]

        return cls.COASTAL_ZONES["sundarbans_delta"]

    @classmethod
    def compute_zone_metrics(cls, raw: Dict) -> CoastalEstuarineZone:
        """Computes Ghyben-Herzberg hydrostatic lens, estuarine wedge penetration distance,
        salinity tiering, and agricultural directives.
        """
        # 1. Ghyben-Herzberg Freshwater-Saltwater Equilibrium
        # z = (rho_f / (rho_s - rho_f)) * hf approx 40 * hf
        hf = raw["piezometric_head_m_msl"]
        if hf > 0:
            theoretical_lens_z = round(40.0 * hf, 2)
        else:
            theoretical_lens_z = 0.0

        # Aquifer vulnerability classification
        if hf < 0.0:
            aq_tier = AquiferVulnerabilityTier.CRITICAL_AQUIFER_CONTAMINATION
        elif hf < 0.75:
            aq_tier = AquiferVulnerabilityTier.ACTIVE_SALINE_UPCONING
        elif hf < 1.50:
            aq_tier = AquiferVulnerabilityTier.VULNERABLE_THINNING
        else:
            aq_tier = AquiferVulnerabilityTier.SAFE_CONFINED_LENS

        # 2. Mineralization & Salinity Severity
        ec = raw["ec_us_cm"]
        tds = round(0.64 * ec, 1)

        if ec >= 6000.0 or raw["surface_salinity_ppt"] >= 18.0:
            salinity_tier = SalinitySeverityTier.HYPERSALINE_SEAWATER_INCURSION
        elif ec >= 3000.0 or raw["surface_salinity_ppt"] >= 10.0:
            salinity_tier = SalinitySeverityTier.SEVERE_SALINE_CONTAMINATION
        elif ec >= 1500.0 or raw["surface_salinity_ppt"] >= 5.0:
            salinity_tier = SalinitySeverityTier.MODERATE_BRACKISH_INGRESS
        elif ec >= 750.0:
            salinity_tier = SalinitySeverityTier.SLIGHT_SALINE_STRESS
        else:
            salinity_tier = SalinitySeverityTier.NORMAL_FRESHWATER

        # 3. Two-Layer Estuarine Saline Wedge Length (Keulegan formulation approximation)
        q_fresh = raw["upstream_q_cumecs"]
        h0 = raw["channel_depth_m"]
        t_range = raw["tidal_range_m"]

        # Reduced gravity g' = 0.024 * 9.81 approx 0.235 m/s2
        g_prime = 0.235
        # Densimetric Froude number F0 = V0 / sqrt(g' * H0)
        # Assume channel width approx 150m - 500m depending on depth
        width = 25.0 * h0
        v0 = q_fresh / max(1.0, width * h0)
        f0 = round(v0 / math.sqrt(g_prime * h0), 3)

        # Saline wedge penetration: inversely related to F0^2 and augmented by spring tidal range
        base_wedge_km = round((h0 / (2.0 * 0.003)) * (1.0 / (5.0 * max(0.01, f0**2) + 0.1)) / 1000.0, 1)
        # Scaled realistic estuarine wedge penetration (10km - 45km)
        calibrated_wedge_km = min(50.0, max(5.0, round(base_wedge_km * (1.0 + 0.25 * t_range), 1)))

        # Directives
        if salinity_tier in [
            SalinitySeverityTier.HYPERSALINE_SEAWATER_INCURSION,
            SalinitySeverityTier.SEVERE_SALINE_CONTAMINATION,
        ]:
            irrigation_advice = (
                f"DO NOT IRRIGATE directly from estuary or shallow borewells (EC: {ec} uS/cm). "
                f"High risk of osmotic crop root burn and irreversible soil sodification."
            )
        elif salinity_tier == SalinitySeverityTier.MODERATE_BRACKISH_INGRESS:
            irrigation_advice = (
                "Restricted irrigation only. Apply alternate fresh canal leaching cycles. "
                "Monitor root-zone electrical conductivity."
            )
        else:
            irrigation_advice = "Safe for general agronomic irrigation. Maintain freshwater lens recharge."

        estuarine_telemetry = EstuarineSalineWedgeTelemetry(
            estuary_name=raw["estuary_name"],
            river_mouth_distance_km=raw["river_mouth_distance_km"],
            saline_wedge_length_km=calibrated_wedge_km,
            upstream_freshwater_discharge_cumecs=q_fresh,
            estuary_channel_depth_m=h0,
            densimetric_froude_number=f0,
            surface_salinity_ppt=raw["surface_salinity_ppt"],
            bottom_bed_salinity_ppt=raw["bottom_salinity_ppt"],
            astronomical_tidal_range_m=t_range,
            tidal_prism_phase=raw["tidal_phase"],
            tidal_prism_volume_million_m3=raw["tidal_prism_million_m3"],
        )

        aquifer_metrics = GhybenHerzbergAquiferMetrics(
            freshwater_piezometric_head_m_msl=hf,
            theoretical_freshwater_lens_depth_m=theoretical_lens_z,
            measured_saline_interface_depth_m=raw["measured_interface_m"],
            saline_upconing_velocity_cm_week=raw["upconing_rate_cm_week"],
            aquifer_vulnerability_tier=aq_tier,
            electrical_conductivity_us_cm=ec,
            total_dissolved_solids_mg_l=tds,
            sodium_adsorption_ratio_sar=raw["sar"],
            chloride_concentration_mg_l=raw["chloride_mg_l"],
        )

        directives = CoastalAgricultureDirectives(
            sluice_flap_gate_status=raw["sluice_status"],
            sluice_closure_timing_notice=raw["sluice_notice"],
            borewell_pumping_limit_hours=raw["pumping_limit_hours"],
            recommended_salt_tolerant_crops=raw["crops"],
            gypsum_amendment_dosage_tons_ha=raw["gypsum_tons_ha"],
            potable_ro_membrane_alert=raw["ro_alert"],
            irrigation_suitability_advice=irrigation_advice,
        )

        return CoastalEstuarineZone(
            zone_id=raw["zone_id"],
            zone_name=raw["zone_name"],
            coastal_district=raw["coastal_district"],
            state_name=raw["state_name"],
            latitude=raw["latitude"],
            longitude=raw["longitude"],
            coastal_body_type=raw["coastal_body_type"],
            salinity_severity=salinity_tier,
            estuarine_wedge=estuarine_telemetry,
            aquifer_metrics=aquifer_metrics,
            directives=directives,
        )

    @classmethod
    def _generate_vernacular_bulletins(cls, zone: CoastalEstuarineZone) -> Dict[str, str]:
        """Generates 7-language coastal saline intrusion and groundwater protection bulletins."""
        z_name = zone.zone_name
        d_name = zone.coastal_district
        wedge = zone.estuarine_wedge.saline_wedge_length_km
        ec = zone.aquifer_metrics.electrical_conductivity_us_cm
        tds = zone.aquifer_metrics.total_dissolved_solids_mg_l
        sluice = zone.directives.sluice_flap_gate_status
        tier = zone.salinity_severity.value

        en = (
            f"INCOIS & CGWB SALINITY BULLETIN: {z_name} ({d_name}) is experiencing {tier}. "
            f"Estuarine saline wedge has penetrated {wedge}km inland. Groundwater EC is {ec} uS/cm "
            f"(TDS: {tds} mg/L). Tidal sluice flap gates are {sluice}. Farmers must limit borewell "
            f"pumping to prevent Ghyben-Herzberg saline upconing and follow ICAR-CSSRI crop directives."
        )

        hi = (
            f"INCOIS एवं CGWB तटीय लवणता बुलेटिन: {z_name} ({d_name}) में लवणता स्तर '{tier}' दर्ज किया गया है। "
            f"समुद्री खारा पानी मुहाने से {wedge} किमी अंतर्देशीय तक पहुंच चुका है। भूजल विद्युत चालकता (EC) "
            f"{ec} uS/cm (TDS: {tds} mg/L) है। ज्वारीय स्लूस गेट {sluice} हैं। किसान खारे पानी के उत्थान "
            f"(Upconing) को रोकने हेतु बोरवेल दोहन सीमित करें एवं ICAR-CSSRI लवण-सहिष्णु फसलें अपनाएं।"
        )

        bn = (
            f"INCOIS ও CGWB উপকূলীয় লবণাক্ততা বুলেটিন: {z_name} ({d_name})-এ লবণাক্ততার মাত্রা '{tier}'। "
            f"নদীর নোনা জলের খাঁড়ি অভ্যন্তরে {wedge} কিমি পর্যন্ত প্রবেশ করেছে। ভূগর্ভস্থ জলের EC {ec} uS/cm "
            f"(TDS: {tds} mg/L)। জোয়ারের স্লুইস গেট {sluice} রাখা হয়েছে। গভীর নলকূপ থেকে অতিরিক্ত জল তোলা বন্ধ "
            f"করুন এবং ICAR-CSSRI লবণ-সহনশীল ধান (CSR-36, অমল-মানা) চাষ করুন।"
        )

        ta = (
            f"INCOIS & CGWB கடலோர உவர்ப்பு புல்லட்டின்: {z_name} ({d_name}) பகுதியில் உவர்ப்பு நிலை '{tier}' ஆக உள்ளது. "
            f"கடல் உவர்நீர் ஆற்றுப்படுகையில் {wedge} கி.மீ உள்நோக்கி ஊடுருவியுள்ளது. நிலத்தடி நீர் EC {ec} uS/cm "
            f"(TDS: {tds} mg/L). மதகுகள் {sluice} நிலையில் உள்ளன. விவசாயிகள் நிலத்தடி நீர் உறிஞ்சுதலைக் குறைத்து "
            f"ICAR-CSSRI உவர்நில நெல் வகைகளை (TRY-1) பயிரிடவும்."
        )

        te = (
            f"INCOIS & CGWB తీరప్రాంత లవణీయత హెచ్చరిక: {z_name} ({d_name}) లో లవణీయత తీవ్రత '{tier}' గా ఉంది. "
            f"సముద్రపు ఉప్పునీటి చీలిక {wedge} కి.మీ లోపలికి చొచ్చుకువచ్చింది. భూగర్భ జలాల EC {ec} uS/cm "
            f"(TDS: {tds} mg/L). స్లూయిస్ గేట్లు {sluice} చేయబడ్డాయి. రైతులు బోర్వెల్ పంపింగ్‌ను తగ్గించి "
            f"ICAR-CSSRI సిఫార్సు చేసిన లవణ-సహన రకాలను సాగు చేయాలి."
        )

        ml = (
            f"INCOIS & CGWB തീരദേശ ലവണാംശ ബുള്ളറ്റിൻ: {z_name} ({d_name}) മേഖലയിൽ ലവണാംശം '{tier}' ആയി ഉയർന്നു. "
            f"ഉപ്പുവെള്ളം നദിക്കുള്ളിലേക്ക് {wedge} കി.മീ വ്യാപിച്ചു. ഭൂഗർഭജല EC {ec} uS/cm (TDS: {tds} mg/L) ആണ്. "
            f"തണ്ണീർമുക്കം / റെഗുലേറ്റർ ഷട്ടറുകൾ {sluice} ആണ്. ശുദ്ധജല തടാകം സംരക്ഷിക്കാൻ പൊക്കാളി നെൽക്കൃഷി "
            f"മാർഗ്ഗനിർദ്ദേശങ്ങൾ പാലിക്കുക."
        )

        gu = (
            f"INCOIS અને CGWB દરિયાકાંઠા ખારાશ બુલેટિન: {z_name} ({d_name}) માં ખારાશનું સ્તર '{tier}' છે. "
            f"દરિયાઈ ખારી ફાચર નદીમાં {wedge} કિમી અંદર સુધી પ્રવેશી ચૂકી છે. ભૂગર્ભજળ EC {ec} uS/cm "
            f"(TDS: {tds} mg/L) છે. સ્લુઈસ ગેટ {sluice} છે. ખેડૂતોએ બોરવેલ પમ્પિંગ મર્યાદિત કરવું અને "
            f"ખારાશ-પ્રતિરોધક પાકોની ખેતી કરવી."
        )

        return {
            "EN": en,
            "HI": hi,
            "BN": bn,
            "TA": ta,
            "TE": te,
            "ML": ml,
            "GU": gu,
        }

    @classmethod
    def get_assessment(
        cls,
        zone_id: Optional[str] = None,
        lat: Optional[float] = None,
        lon: Optional[float] = None,
    ) -> SaltwaterIntrusionResponse:
        """Generates comprehensive estuarine saline wedge telemetry, Ghyben-Herzberg lens metrics,
        and 7-language coastal agricultural bulletins.
        """
        raw_active = cls._find_zone(zone_id=zone_id, lat=lat, lon=lon)
        active_zone = cls.compute_zone_metrics(raw_active)

        all_summaries: List[CoastalZoneSummary] = []
        for zid, z_raw in cls.COASTAL_ZONES.items():
            zm = cls.compute_zone_metrics(z_raw)
            all_summaries.append(
                CoastalZoneSummary(
                    zone_id=zid,
                    zone_name=z_raw["zone_name"],
                    state_name=z_raw["state_name"],
                    saline_wedge_length_km=zm.estuarine_wedge.saline_wedge_length_km,
                    surface_salinity_ppt=z_raw["surface_salinity_ppt"],
                    salinity_severity=zm.salinity_severity,
                    aquifer_vulnerability_tier=zm.aquifer_metrics.aquifer_vulnerability_tier,
                    sluice_flap_gate_status=z_raw["sluice_status"],
                )
            )

        bulletins = cls._generate_vernacular_bulletins(active_zone)

        return SaltwaterIntrusionResponse(
            timestamp=datetime.now(timezone.utc).isoformat(),
            active_zone=active_zone,
            all_zones=all_summaries,
            vernacular_bulletins=bulletins,
        )
