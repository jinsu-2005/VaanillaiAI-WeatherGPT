import math
from datetime import datetime, timezone
from typing import Dict, List, Optional
from app.schemas.drought import (
    AgriculturalDroughtResponse,
    AgronomicDroughtDirectives,
    BorewellYieldTrend,
    CgwbGroundwaterCategory,
    DroughtHotspot,
    DroughtSeverity,
    GroundwaterAquiferStatus,
    MeteorologicalDroughtIndices,
    SoilMoistureStress,
)


def _haversine_distance_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    r = 6371.0
    d_lat = math.radians(lat2 - lat1)
    d_lon = math.radians(lon2 - lon1)
    a = (
        math.sin(d_lat / 2.0) ** 2
        + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(d_lon / 2.0) ** 2
    )
    c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
    return r * c


class DroughtAssessmentService:
    """IMD Agricultural Meteorology, Central Ground Water Board (CGWB), and ICAR-CRIDA

    operational drought monitoring, soil moisture stress, and groundwater vulnerability service.
    """

    def _build_hotspots(self) -> List[DroughtHotspot]:
        return [
            DroughtHotspot(
                hotspot_id="marathwada_latur",
                district_name="Latur & Marathwada Rain-Shadow Zone",
                state="Maharashtra",
                latitude=18.4088,
                longitude=76.5604,
                agro_climatic_subzone="Central Maharashtra Plateau Zone (Zone 8)",
                primary_crops=["Soybean", "Pigeonpea (Tur)", "Sorghum", "Cotton"],
                severity=DroughtSeverity.WARNING_SEVERE_DROUGHT,
                meteorological=MeteorologicalDroughtIndices(
                    spi_1=-1.45,
                    spi_3=-1.82,
                    spi_6=-1.68,
                    rainfall_departure_lpa_pct=-48.0,
                    consecutive_dry_days=24,
                    drought_stage_verdict="Severe Meteorological Drought (Orange Category)",
                ),
                soil_moisture=SoilMoistureStress(
                    root_zone_soil_moisture_pct=14.5,
                    field_capacity_pct=34.0,
                    permanent_wilting_point_pct=12.0,
                    available_water_capacity_mm=18.2,
                    smdi=-2.85,
                    crop_water_stress_index=0.82,
                    stress_level="Severe Root-Zone Desiccation — Wilting Imminent",
                ),
                groundwater=GroundwaterAquiferStatus(
                    depth_to_water_table_m_bgl=24.8,
                    stage_of_extraction_pct=108.5,
                    aquifer_category=CgwbGroundwaterCategory.OVER_EXPLOITED,
                    annual_recharge_potential_mcm=142.5,
                    borewell_yield_trend=BorewellYieldTrend.DECLINING,
                    irrigation_rationing_status="Over-Exploited Aquifer: Restrict borewell pumping to critical life-saving intervals only.",
                ),
                agronomic_directives=AgronomicDroughtDirectives(
                    crop_stage_advisory="Soybean is at flowering to early pod fill; pigeonpea is at branching. High risk of flower drop under severe moisture stress.",
                    irrigation_scheduling="Apply protective life-saving irrigation (5 cm depth) via micro-sprinkler or alternate-furrow irrigation. Avoid flood irrigation.",
                    moisture_conservation="Spray 1% Potassium Nitrate (KNO3) or 2% urea solution foliar spray to alleviate thermal stress. Spread soybean residue mulching across rows.",
                    contingency_crop_switch="If main crop fails, prepare field for contingency horse gram (Kulthi), moth bean, or fodder pearl millet.",
                    livestock_fodder_advisory="Store green fodder silage; procure dry sorghum stover. Provide shaded cattle corrals with cool drinking water.",
                ),
            ),
            DroughtHotspot(
                hotspot_id="rayalaseema_anantapur",
                district_name="Anantapuramu & Rayalaseema Arid Belt",
                state="Andhra Pradesh",
                latitude=14.6819,
                longitude=77.6006,
                agro_climatic_subzone="Southern Semi-Arid Scarce Rainfall Zone (Zone 10)",
                primary_crops=["Groundnut (Peanut)", "Castor", "Pigeonpea", "Foxtail Millet"],
                severity=DroughtSeverity.EMERGENCY_EXTREME_DROUGHT,
                meteorological=MeteorologicalDroughtIndices(
                    spi_1=-2.10,
                    spi_3=-2.15,
                    spi_6=-2.30,
                    rainfall_departure_lpa_pct=-58.0,
                    consecutive_dry_days=31,
                    drought_stage_verdict="Extreme Meteorological Drought (Red Alert Emergency)",
                ),
                soil_moisture=SoilMoistureStress(
                    root_zone_soil_moisture_pct=10.2,
                    field_capacity_pct=24.0,
                    permanent_wilting_point_pct=11.0,
                    available_water_capacity_mm=8.5,
                    smdi=-3.60,
                    crop_water_stress_index=0.91,
                    stress_level="Critical Soil Moisture Depletion — Below Permanent Wilting Point",
                ),
                groundwater=GroundwaterAquiferStatus(
                    depth_to_water_table_m_bgl=38.5,
                    stage_of_extraction_pct=124.0,
                    aquifer_category=CgwbGroundwaterCategory.OVER_EXPLOITED,
                    annual_recharge_potential_mcm=115.0,
                    borewell_yield_trend=BorewellYieldTrend.DEPLETED,
                    irrigation_rationing_status="Severe Groundwater Depletion: More than 60% of agricultural borewells running dry. Ban non-essential extraction.",
                ),
                agronomic_directives=AgronomicDroughtDirectives(
                    crop_stage_advisory="Groundnut is at peg penetration and pod development. Soil hardening is halting peg penetration, risking complete pod yield loss.",
                    irrigation_scheduling="Operate mobile rain-gun or drip systems during night or early morning hours. Minimum 20 mm moisture needed for peg entry.",
                    moisture_conservation="Foliar spray with 5% Kaolin clay reflective anti-transpirant. Apply coir pith or crop residue mulch to preserve scarce moisture.",
                    contingency_crop_switch="Transition entirely to drought-hardy millets (Korralu / Foxtail millet) or fodder cowpea for surviving livestock.",
                    livestock_fodder_advisory="Coordinate with district fodder banks. Administer mineral blocks to prevent livestock dehydration and cachexia.",
                ),
            ),
            DroughtHotspot(
                hotspot_id="bundelkhand_jhansi",
                district_name="Jhansi & Bundelkhand Hard-Rock Zone",
                state="Uttar Pradesh / MP",
                latitude=25.4484,
                longitude=78.5685,
                agro_climatic_subzone="Bundelkhand Agro-Climatic Subzone",
                primary_crops=["Chickpea (Gram)", "Wheat", "Mustard", "Sesame"],
                severity=DroughtSeverity.WARNING_SEVERE_DROUGHT,
                meteorological=MeteorologicalDroughtIndices(
                    spi_1=-1.35,
                    spi_3=-1.65,
                    spi_6=-1.52,
                    rainfall_departure_lpa_pct=-42.0,
                    consecutive_dry_days=21,
                    drought_stage_verdict="Severe Meteorological Drought (Orange Category)",
                ),
                soil_moisture=SoilMoistureStress(
                    root_zone_soil_moisture_pct=16.0,
                    field_capacity_pct=32.0,
                    permanent_wilting_point_pct=13.0,
                    available_water_capacity_mm=22.0,
                    smdi=-2.45,
                    crop_water_stress_index=0.78,
                    stress_level="Severe Moisture Stress in Mixed Red-Black Soils",
                ),
                groundwater=GroundwaterAquiferStatus(
                    depth_to_water_table_m_bgl=19.4,
                    stage_of_extraction_pct=94.2,
                    aquifer_category=CgwbGroundwaterCategory.CRITICAL,
                    annual_recharge_potential_mcm=160.0,
                    borewell_yield_trend=BorewellYieldTrend.DECLINING,
                    irrigation_rationing_status="Critical Hard-Rock Aquifer: Dugwells and shallow borewells showing sharp summer drawdown.",
                ),
                agronomic_directives=AgronomicDroughtDirectives(
                    crop_stage_advisory="Rabi sowing preparation / Kharif maturity. Pre-sowing moisture is inadequate for conventional sowing depth.",
                    irrigation_scheduling="Adopt Broad Bed Furrow (BBF) systems and laser land leveling. Target life-saving irrigation at crown root initiation.",
                    moisture_conservation="Inter-row cultivation to create a dust mulch barrier that breaks capillary soil moisture evaporation.",
                    contingency_crop_switch="Sow drought-tolerant chickpea varieties (e.g., JG-14, RVG-202) treated with Trichoderma and biofertilizers.",
                    livestock_fodder_advisory="Desilt farm ponds (Khet Talab); preserve Bajra and Jowar Kadbi dry fodder.",
                ),
            ),
            DroughtHotspot(
                hotspot_id="north_interior_karnataka_kalaburagi",
                district_name="Kalaburagi & Gulbarga Pulse Bowl",
                state="Karnataka",
                latitude=17.3297,
                longitude=76.8343,
                agro_climatic_subzone="North Eastern Dry Zone (Zone 2)",
                primary_crops=["Pigeonpea (Red Gram)", "Black Gram", "Sorghum", "Sunflower"],
                severity=DroughtSeverity.WARNING_SEVERE_DROUGHT,
                meteorological=MeteorologicalDroughtIndices(
                    spi_1=-1.52,
                    spi_3=-1.74,
                    spi_6=-1.60,
                    rainfall_departure_lpa_pct=-45.0,
                    consecutive_dry_days=26,
                    drought_stage_verdict="Severe Meteorological Drought (Orange Category)",
                ),
                soil_moisture=SoilMoistureStress(
                    root_zone_soil_moisture_pct=15.2,
                    field_capacity_pct=35.0,
                    permanent_wilting_point_pct=13.5,
                    available_water_capacity_mm=19.5,
                    smdi=-2.65,
                    crop_water_stress_index=0.80,
                    stress_level="Severe Moisture Deficit in Deep Black Vertisols",
                ),
                groundwater=GroundwaterAquiferStatus(
                    depth_to_water_table_m_bgl=22.1,
                    stage_of_extraction_pct=86.5,
                    aquifer_category=CgwbGroundwaterCategory.SEMI_CRITICAL,
                    annual_recharge_potential_mcm=175.0,
                    borewell_yield_trend=BorewellYieldTrend.DECLINING,
                    irrigation_rationing_status="Semi-Critical Aquifer: Regulate extraction to protect pulse crops and drinking water tanks.",
                ),
                agronomic_directives=AgronomicDroughtDirectives(
                    crop_stage_advisory="Red gram is at flowering and pod setting. Severe terminal drought threatens up to 50% yield reduction.",
                    irrigation_scheduling="Apply protective irrigation using drip or furrow method at critical pod formation stage.",
                    moisture_conservation="Spray 1% Salicylic Acid or 1% Potassium Chloride (KCl) to induce stomatal closure and reduce transpiration.",
                    contingency_crop_switch="Sow short-duration horse gram or multi-cut fodder sorghum in fallow plots.",
                    livestock_fodder_advisory="Establish community cattle camps; ensure deworming and vaccination against heat-induced respiratory infections.",
                ),
            ),
            DroughtHotspot(
                hotspot_id="saurashtra_rajkot",
                district_name="Rajkot & Saurashtra Basalt Peninsula",
                state="Gujarat",
                latitude=22.3039,
                longitude=70.8022,
                agro_climatic_subzone="North Saurashtra Agro-Climatic Zone",
                primary_crops=["Bt Cotton", "Groundnut", "Sesame", "Castor"],
                severity=DroughtSeverity.ALERT_MODERATE_DROUGHT,
                meteorological=MeteorologicalDroughtIndices(
                    spi_1=-1.15,
                    spi_3=-1.42,
                    spi_6=-1.30,
                    rainfall_departure_lpa_pct=-36.0,
                    consecutive_dry_days=18,
                    drought_stage_verdict="Moderate Meteorological Drought (Yellow Alert)",
                ),
                soil_moisture=SoilMoistureStress(
                    root_zone_soil_moisture_pct=18.5,
                    field_capacity_pct=33.0,
                    permanent_wilting_point_pct=13.0,
                    available_water_capacity_mm=26.0,
                    smdi=-1.95,
                    crop_water_stress_index=0.68,
                    stress_level="Moderate Moisture Deficit in Medium Black Soils",
                ),
                groundwater=GroundwaterAquiferStatus(
                    depth_to_water_table_m_bgl=28.2,
                    stage_of_extraction_pct=98.0,
                    aquifer_category=CgwbGroundwaterCategory.CRITICAL,
                    annual_recharge_potential_mcm=190.0,
                    borewell_yield_trend=BorewellYieldTrend.DECLINING,
                    irrigation_rationing_status="Critical Deccan Trap Basalt Aquifer: Salinity ingress alert in coastal talukas.",
                ),
                agronomic_directives=AgronomicDroughtDirectives(
                    crop_stage_advisory="Bt cotton is at square and boll formation; groundnut at pod filling. Avoid moisture stress during boll development.",
                    irrigation_scheduling="Operate drip irrigation systems on alternate days with deficit irrigation regime (80% crop evapotranspiration).",
                    moisture_conservation="Apply plastic or straw mulch in cotton inter-rows. Foliar spray of 2% DAP + 1% KCl.",
                    contingency_crop_switch="Promote castor intercropping and drought-resistant sesame varieties.",
                    livestock_fodder_advisory="Promote hydroponic green fodder and silage pits for dairy cattle.",
                ),
            ),
            DroughtHotspot(
                hotspot_id="vidarbha_akola",
                district_name="Akola & Western Vidarbha Cotton Tract",
                state="Maharashtra",
                latitude=20.7002,
                longitude=77.0082,
                agro_climatic_subzone="Western Vidarbha Zone (Zone 7)",
                primary_crops=["Cotton", "Soybean", "Pigeonpea", "Green Gram"],
                severity=DroughtSeverity.WARNING_SEVERE_DROUGHT,
                meteorological=MeteorologicalDroughtIndices(
                    spi_1=-1.30,
                    spi_3=-1.55,
                    spi_6=-1.48,
                    rainfall_departure_lpa_pct=-39.0,
                    consecutive_dry_days=20,
                    drought_stage_verdict="Severe Meteorological Drought (Orange Category)",
                ),
                soil_moisture=SoilMoistureStress(
                    root_zone_soil_moisture_pct=17.8,
                    field_capacity_pct=36.0,
                    permanent_wilting_point_pct=14.0,
                    available_water_capacity_mm=24.5,
                    smdi=-2.20,
                    crop_water_stress_index=0.74,
                    stress_level="Severe Moisture Stress in Heavy Black Cotton Soils",
                ),
                groundwater=GroundwaterAquiferStatus(
                    depth_to_water_table_m_bgl=18.6,
                    stage_of_extraction_pct=89.5,
                    aquifer_category=CgwbGroundwaterCategory.SEMI_CRITICAL,
                    annual_recharge_potential_mcm=210.0,
                    borewell_yield_trend=BorewellYieldTrend.DECLINING,
                    irrigation_rationing_status="Semi-Critical Aquifer: Restrict flood irrigation; prioritize micro-irrigation subsidies.",
                ),
                agronomic_directives=AgronomicDroughtDirectives(
                    crop_stage_advisory="Cotton square formation and soybean flowering. Soil cracking beginning in deep vertisols.",
                    irrigation_scheduling="Carry out shallow intercultural operations to seal soil cracks and retard deep sub-surface moisture loss.",
                    moisture_conservation="Spray 1% Potassium Schoenite or 1.5% urea to support vegetative vigour under moisture stress.",
                    contingency_crop_switch="Sow fodder maize or Bajra if Kharif soybean has suffered irreversible damage.",
                    livestock_fodder_advisory="Distribute urea-molasses treated straw to sustain rural livestock herds.",
                ),
            ),
            DroughtHotspot(
                hotspot_id="thar_barmer",
                district_name="Barmer & Western Arid Sandy Plains",
                state="Rajasthan",
                latitude=25.7521,
                longitude=71.3967,
                agro_climatic_subzone="Hyper-Arid Partially Irrigated Western Plain (Zone I-A)",
                primary_crops=["Pearl Millet (Bajra)", "Clusterbean (Guar)", "Moth Bean", "Sesame"],
                severity=DroughtSeverity.EMERGENCY_EXTREME_DROUGHT,
                meteorological=MeteorologicalDroughtIndices(
                    spi_1=-1.85,
                    spi_3=-1.92,
                    spi_6=-2.10,
                    rainfall_departure_lpa_pct=-52.0,
                    consecutive_dry_days=35,
                    drought_stage_verdict="Extreme Meteorological Drought (Red Alert Emergency)",
                ),
                soil_moisture=SoilMoistureStress(
                    root_zone_soil_moisture_pct=8.4,
                    field_capacity_pct=16.0,
                    permanent_wilting_point_pct=8.0,
                    available_water_capacity_mm=6.2,
                    smdi=-3.80,
                    crop_water_stress_index=0.94,
                    stress_level="Extreme Soil Moisture Deficit — Complete Root-Zone Exhaustion",
                ),
                groundwater=GroundwaterAquiferStatus(
                    depth_to_water_table_m_bgl=86.0,
                    stage_of_extraction_pct=142.0,
                    aquifer_category=CgwbGroundwaterCategory.OVER_EXPLOITED,
                    annual_recharge_potential_mcm=65.0,
                    borewell_yield_trend=BorewellYieldTrend.DEPLETED,
                    irrigation_rationing_status="Critical Over-Exploited Fossil Aquifer: Severe groundwater depletion. Strict drinking water priority.",
                ),
                agronomic_directives=AgronomicDroughtDirectives(
                    crop_stage_advisory="Bajra grain filling; Guar pod formation. Scorching dry winds accelerating leaf scorching and yield collapse.",
                    irrigation_scheduling="Sprinkler irrigation in early dawn hours (4 AM to 7 AM) when wind speeds are minimal.",
                    moisture_conservation="Construct field bunding (Khadas) to capture any erratic runoff. Apply dry grass mulching.",
                    contingency_crop_switch="Switch to extreme drought-hardy Moth Bean (CZM-2) or desert grass (Cenchrus ciliaris / Dhaman).",
                    livestock_fodder_advisory="Emergency fodder supply for Marwari sheep, camel, and Tharparkar cattle. Establish water troughs.",
                ),
            ),
        ]

    def _generate_vernacular_bulletins(self, spot: DroughtHotspot) -> Dict[str, str]:
        sev_text = spot.severity.value.replace("_", " ")
        return {
            "en": (
                f"IMD & CGWB AGRICULTURAL DROUGHT ADVISORY: {spot.district_name} is under {sev_text}. "
                f"3-Month SPI is {spot.meteorological.spi_3:.2f} (Rainfall Departure: {spot.meteorological.rainfall_departure_lpa_pct:.0f}%). "
                f"Root zone soil moisture is at {spot.soil_moisture.root_zone_soil_moisture_pct:.1f}% with CWSI {spot.soil_moisture.crop_water_stress_index:.2f}. "
                f"Groundwater Extraction Stage: {spot.groundwater.stage_of_extraction_pct:.1f}% ({spot.groundwater.aquifer_category.value}). "
                f"Advisory: {spot.agronomic_directives.irrigation_scheduling}"
            ),
            "hi": (
                f"आईएमडी एवं सीजीडब्ल्यूबी सूखा व भूजल परामर्श: {spot.district_name} में {sev_text} की स्थिति। "
                f"3-माह एसपीआई {spot.meteorological.spi_3:.2f} (वर्षा कमी: {spot.meteorological.rainfall_departure_lpa_pct:.0f}%)। "
                f"जड़ क्षेत्र में मिट्टी की नमी {spot.soil_moisture.root_zone_soil_moisture_pct:.1f}% बची है। "
                f"भूजल दोहन स्तर {spot.groundwater.stage_of_extraction_pct:.1f}% ({spot.groundwater.aquifer_category.value})। "
                f"कृषि सलाह: {spot.agronomic_directives.irrigation_scheduling}"
            ),
            "mr": (
                f"आयएमडी आणि सीजीडब्ल्यूबी दुष्काळ व भूजल सल्ला: {spot.district_name} येथे {sev_text} जारी. "
                f"३-महिन्यांचा एसपीआई {spot.meteorological.spi_3:.2f} (पावसाची तूट: {spot.meteorological.rainfall_departure_lpa_pct:.0f}%). "
                f"मुळांच्या थरातील जमिनीतील ओलावा {spot.soil_moisture.root_zone_soil_moisture_pct:.1f}% वर घसरला आहे. "
                f"भूजल उपसा प्रमाण {spot.groundwater.stage_of_extraction_pct:.1f}% ({spot.groundwater.aquifer_category.value}). "
                f"शेतकरी सल्ला: {spot.agronomic_directives.irrigation_scheduling}"
            ),
            "te": (
                f"ఐఎండి మరియు సిజిడబ్ల్యుబి వ్యవసాయ కరువు సలహా: {spot.district_name} లో {sev_text} స్థితి నెలకొంది. "
                f"3-నెలల ఎస్పీఐ {spot.meteorological.spi_3:.2f} (వర్షపాత లోటు: {spot.meteorological.rainfall_departure_lpa_pct:.0f}%). "
                f"నేల తేమ శాతం {spot.soil_moisture.root_zone_soil_moisture_pct:.1f}% కి తగ్గింది. "
                f"భూగర్భ జలాల వినియోగం {spot.groundwater.stage_of_extraction_pct:.1f}% ({spot.groundwater.aquifer_category.value}). "
                f"రైతులకు సలహా: {spot.agronomic_directives.irrigation_scheduling}"
            ),
            "kn": (
                f"ಐಎಂಡಿ ಮತ್ತು ಸಿಜಿಡಬ್ಲ್ಯುಬಿ ಕೃಷಿ ಬರ ಮತ್ತು ಅಂತರ್ಜಲ ಎಚ್ಚರಿಕೆ: {spot.district_name} ವ್ಯಾಪ್ತಿಯಲ್ಲಿ {sev_text} ಸ್ಥಿತಿ. "
                f"೩-ತಿಂಗಳ ಎಸ್‍ಪಿಐ {spot.meteorological.spi_3:.2f} (ಮಳೆ ಕೊರತೆ: {spot.meteorological.rainfall_departure_lpa_pct:.0f}%). "
                f"ಮಣ್ಣಿನ ತೇವಾಂಶ ಮಟ್ಟ {spot.soil_moisture.root_zone_soil_moisture_pct:.1f}% ಕ್ಕೆ ಕುಸಿದಿದೆ. "
                f"ಅಂತರ್ಜಲ ಬಳಕೆ ಪ್ರಮಾಣ {spot.groundwater.stage_of_extraction_pct:.1f}% ({spot.groundwater.aquifer_category.value}). "
                f"ರೈತರಿಗೆ ಸಲಹೆ: {spot.agronomic_directives.irrigation_scheduling}"
            ),
        }

    def get_drought_assessment(
        self,
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        hotspot_id: Optional[str] = None,
    ) -> AgriculturalDroughtResponse:
        all_spots = self._build_hotspots()

        selected: Optional[DroughtHotspot] = None
        if hotspot_id:
            for s in all_spots:
                if s.hotspot_id.lower() == hotspot_id.lower():
                    selected = s
                    break

        if not selected and latitude is not None and longitude is not None:
            closest = min(all_spots, key=lambda s: _haversine_distance_km(latitude, longitude, s.latitude, s.longitude))
            selected = closest

        if not selected:
            selected = all_spots[0]  # default to Marathwada Latur

        bulletins = self._generate_vernacular_bulletins(selected)
        now_utc = datetime.now(timezone.utc).isoformat()

        return AgriculturalDroughtResponse(
            timestamp=now_utc,
            selected_hotspot=selected,
            all_hotspots=all_spots,
            vernacular_bulletins=bulletins,
            bulletin_number=f"IMD-CGWB/DROUGHT/{datetime.now(timezone.utc).strftime('%Y%m')}-AS{selected.hotspot_id[:3].upper()}",
            provenance="India Meteorological Department (IMD Agricultural Meteorology Division), Central Ground Water Board (CGWB) & ICAR-CRIDA",
            is_offline_cached=False,
        )


drought_service = DroughtAssessmentService()
