import math
from datetime import datetime, timezone
from typing import Dict, List, Optional, Tuple

from app.schemas.oil_spill import (
    BonnAppearanceCode,
    CorridorSummary,
    FaySpreadingMetrics,
    HydrodynamicDriftVector,
    IcgContainmentDirectives,
    OilSpillCorridor,
    OilSpillResponse,
    OilTypeClassification,
    SensitiveHabitatNode,
    SpillSeverityTier,
    TrajectoryWaypoint,
    WeatheringKinetics,
)


class OilSpillService:
    """INCOIS & Indian Coast Guard (ICG) National Oil Spill Disaster

    Contingency Plan (NOS-DCP) and Oil Spill Trajectory (OOSA) Engine.
    """

    def __init__(self):
        self._corridors_db = self._init_corridors_database()

    def get_oil_spill_assessment(
        self,
        corridor_id: Optional[str] = None,
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
    ) -> OilSpillResponse:
        """Resolves oil spill trajectory and environmental sensitivity telemetry

        for the requested corridor or geodetic nearest coastal maritime sector.
        """
        target_id = "gulf_of_kutch_vadinar"

        if corridor_id and corridor_id in self._corridors_db:
            target_id = corridor_id
        elif latitude is not None and longitude is not None:
            target_id = self._resolve_nearest_corridor(latitude, longitude)

        corridor_data = self._corridors_db[target_id]
        summaries = [self._build_summary(cid, cdata) for cid, cdata in self._corridors_db.items()]
        bulletins = self._build_vernacular_bulletins(corridor_data)

        return OilSpillResponse(
            selected_corridor=corridor_data,
            all_corridors=summaries,
            bulletins=bulletins,
            offline_cached=False,
            generated_at=datetime.now(timezone.utc).isoformat(),
        )

    def _resolve_nearest_corridor(self, lat: float, lon: float) -> str:
        """Finds closest monitored Indian marine corridor using Haversine

        geodesic distance.
        """
        best_id = "gulf_of_kutch_vadinar"
        min_dist = float("inf")

        for cid, data in self._corridors_db.items():
            dist = self._haversine_distance(lat, lon, data.latitude, data.longitude)
            if dist < min_dist:
                min_dist = dist
                best_id = cid

        return best_id

    @staticmethod
    def _haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """Computes great-circle distance in kilometers."""
        r = 6371.0
        dlat = math.radians(lat2 - lat1)
        dlon = math.radians(lon2 - lon1)
        a = (
            math.sin(dlat / 2.0) ** 2
            + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2.0) ** 2
        )
        c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
        return r * c

    def _build_summary(self, cid: str, corridor: OilSpillCorridor) -> CorridorSummary:
        earliest_eta = min((h.estimated_impact_eta_hours for h in corridor.sensitive_habitats), default=24)
        return CorridorSummary(
            corridor_id=cid,
            corridor_name=corridor.corridor_name,
            state_or_ut=corridor.state_or_ut,
            severity_tier=corridor.severity_tier,
            oil_type=corridor.oil_type,
            spill_volume_tonnes=corridor.spill_volume_tonnes,
            slick_area_km2=corridor.fay_spreading.slick_area_km2,
            nearest_habitat_eta_hours=earliest_eta,
        )

    def _build_vernacular_bulletins(self, corridor: OilSpillCorridor) -> Dict[str, str]:
        cname = corridor.corridor_name
        vol = corridor.spill_volume_tonnes
        tier_str = corridor.severity_tier.value
        oil_str = corridor.oil_type.value.replace("_", " ")
        speed = corridor.drift_vector.net_drift_speed_knots
        drift_dir = corridor.drift_vector.net_drift_direction_deg
        primary_hab = corridor.sensitive_habitats[0].habitat_name if corridor.sensitive_habitats else "Coastline"
        eta = corridor.sensitive_habitats[0].estimated_impact_eta_hours if corridor.sensitive_habitats else 12

        return {
            "en": (
                f"INCOIS-ICG MARINE OIL SPILL ADVISORY for {cname}: {tier_str} declared for {vol:,.0f} tonnes of "
                f"{oil_str}. Surface slick advecting at {speed:.1f} kt towards {drift_dir:.0f}°. "
                f"Impact ETA to {primary_hab} is {eta} hours. ICG deployed containment booms; emergency "
                f"hotline 1554 active."
            ),
            "ta": (
                f"இன்கோயிஸ் - இந்திய கடலோர காவல்படை (ICG) கடல்சார் எண்ணெய் கசிவு எச்சரிக்கை: {cname} பகுதியில் "
                f"{vol:,.0f} டன் {oil_str} கசிவு காரணமாக {tier_str} அவசரநிலை அறிவிக்கப்பட்டுள்ளது. எண்ணெய் படலம் "
                f"{speed:.1f} நாட்ஸ் வேகத்தில் நகர்கிறது. {primary_hab} பகுதியை அடைய {eta} மணிநேரம் ஆகும். "
                f"தடுப்பு மிதவைகள் (Booms) விரிக்கப்பட்டுள்ளன; அவசர உதவி எண் 1554."
            ),
            "bn": (
                f"ইনকোইস ও ভারতীয় উপকূলরক্ষী বাহিনী (ICG) তেল নিঃসরণ সতর্কবার্তা: {cname}-এ {vol:,.0f} টন "
                f"{oil_str} ছড়িয়ে পড়ার কারণে {tier_str} জরুরি অবস্থা জারি করা হয়েছে। তেলের স্তর "
                f"{speed:.1f} নট গতিতে এগোচ্ছে। {primary_hab}-এ পৌঁছাতে আনুমানিক {eta} ঘণ্টা সময় লাগবে। "
                f"সুরক্ষা ব্যারিকেড স্থাপন করা হয়েছে; জরুরি হেল্পলাইন 1554।"
            ),
            "ml": (
                f"ഇൻകോയിസ് - ഇന്ത്യൻ കോസ്റ്റ് ഗാർഡ് (ICG) എണ്ണ ചോർച്ച മുന്നറിയിപ്പ്: {cname} തീരത്ത് "
                f"{vol:,.0f} ടൺ {oil_str} ചോർന്നതിനെ തുടർന്ന് {tier_str} ജാഗ്രതാ നിർദ്ദേശം നൽകി. എണ്ണപ്പടലം "
                f"{speed:.1f} നോട്ട് വേഗതയിൽ നീങ്ങുന്നു. {primary_hab} തീരത്ത് എത്താൻ {eta} മണിക്കൂർ എടുക്കും. "
                f"കോസ്റ്റ് ഗാർഡ് കൺടെയ്ൻമെൻ്റ് ബൂമുകൾ വിന്യസിച്ചു; ഹെൽപ്പ് ലൈൻ 1554."
            ),
            "gu": (
                f"ઇનકોઇસ અને ભારતીય કોસ્ટ ગાર્ડ (ICG) દરિયાઈ તેલ ગળતર ચેતવણી: {cname} ખાતે {vol:,.0f} ટન "
                f"{oil_str} ગળતરને કારણે {tier_str} કટોકટી જાહેર કરાઈ છે. તેલનું સ્તર {speed:.1f} નોટ્સની ઝડપે "
                f"આગળ વધી રહ્યું છે. {primary_hab} સુધી પહોંચવાનો અંદાજિત સમય {eta} કલાક છે. ઇમરજન્સી હેલ્પલાઇન 1554."
            ),
            "mr": (
                f"इन्कॉईस आणि भारतीय तटरक्षक दल (ICG) सागरी तेल गळती इशारा: {cname} जवळ {vol:,.0f} टन "
                f"{oil_str} सांडल्यामुळे {tier_str} आणीबाणी घोषित करण्यात आली आहे. तेलाचा थर {speed:.1f} नॉट्स "
                f"वेगाने वाहत आहे. {primary_hab} परिसराला धोका निर्माण होण्यास {eta} तास उरले आहेत. आपत्कालीन संपर्क 1554."
            ),
            "od": (
                f"ଇନକୋଇସ ଓ ଭାରତୀୟ ତଟରକ୍ଷୀ ବାହିନୀ (ICG) ତୈଳ ନିର୍ଗମନ ସତର୍କତା: {cname} ନିକଟରେ {vol:,.0f} ଟନ୍ "
                f"{oil_str} ଭାସୁଥିବାରୁ {tier_str} ଜରୁରୀ ପରିସ୍ଥିତି ଘୋଷଣା କରାଯାଇଛି। ତେଲ ପତଳା ସ୍ତର {speed:.1f} ନଟ୍ ବେଗରେ "
                f"ଗତି କରୁଛି। {primary_hab} ଉପକୂଳରେ ପହଞ୍ଚିବାକୁ ଆନୁମାନିକ {eta} ଘଣ୍ଟା ସମୟ ଲାଗିବ। ଜରୁରୀ ସହାୟତା ନମ୍ବର 1554।"
            ),
        }

    def _init_corridors_database(self) -> Dict[str, OilSpillCorridor]:
        """Initializes calibrated data for 7 high-risk Indian maritime sectors."""
        return {
            "gulf_of_kutch_vadinar": OilSpillCorridor(
                corridor_id="gulf_of_kutch_vadinar",
                corridor_name="Gulf of Kutch & Vadinar SBM Offshore Corridor",
                state_or_ut="Gujarat",
                latitude=22.48,
                longitude=69.72,
                spill_volume_tonnes=3500.0,
                oil_type=OilTypeClassification.MEDIUM_CRUDE_ARABIAN_LIGHT,
                severity_tier=SpillSeverityTier.TIER_2_REGIONAL_COAST_GUARD,
                drift_vector=HydrodynamicDriftVector(
                    surface_current_speed_knots=2.8,
                    surface_current_direction_deg=115.0,
                    wind_speed_10m_knots=18.5,
                    wind_direction_deg=290.0,
                    net_drift_speed_knots=3.2,
                    net_drift_direction_deg=108.0,
                    stokes_drift_knots=0.35,
                ),
                trajectory_waypoints=[
                    TrajectoryWaypoint(
                        time_horizon_hours=6,
                        latitude=22.44,
                        longitude=69.88,
                        distance_traveled_km=17.8,
                        slick_area_km2=14.2,
                        slick_thickness_microns=125.0,
                        appearance_code=BonnAppearanceCode.CODE_4_DISCONTINUOUS_TRUE,
                        shoreline_hit_risk="MODERATE_OFFSHORE",
                    ),
                    TrajectoryWaypoint(
                        time_horizon_hours=12,
                        latitude=22.41,
                        longitude=70.04,
                        distance_traveled_km=35.5,
                        slick_area_km2=28.6,
                        slick_thickness_microns=68.0,
                        appearance_code=BonnAppearanceCode.CODE_4_DISCONTINUOUS_TRUE,
                        shoreline_hit_risk="HIGH_INTERTIDAL_REEF",
                    ),
                    TrajectoryWaypoint(
                        time_horizon_hours=24,
                        latitude=22.36,
                        longitude=70.32,
                        distance_traveled_km=71.0,
                        slick_area_km2=52.4,
                        slick_thickness_microns=32.0,
                        appearance_code=BonnAppearanceCode.CODE_3_METALLIC,
                        shoreline_hit_risk="IMMINENT_LANDFALL_NARARA",
                    ),
                    TrajectoryWaypoint(
                        time_horizon_hours=48,
                        latitude=22.30,
                        longitude=70.68,
                        distance_traveled_km=138.0,
                        slick_area_km2=86.0,
                        slick_thickness_microns=12.0,
                        appearance_code=BonnAppearanceCode.CODE_3_METALLIC,
                        shoreline_hit_risk="BEACHED_MANGROVES",
                    ),
                    TrajectoryWaypoint(
                        time_horizon_hours=72,
                        latitude=22.25,
                        longitude=70.95,
                        distance_traveled_km=195.0,
                        slick_area_km2=118.0,
                        slick_thickness_microns=4.5,
                        appearance_code=BonnAppearanceCode.CODE_2_RAINBOW,
                        shoreline_hit_risk="STRANDED_ESTUARINE_MUDFLAT",
                    ),
                ],
                fay_spreading=FaySpreadingMetrics(
                    current_regime="GRAVITY_VISCOUS_REGIME_II",
                    slick_radius_meters=3200.0,
                    slick_area_km2=32.17,
                    average_thickness_microns=82.5,
                    bonn_code=BonnAppearanceCode.CODE_4_DISCONTINUOUS_TRUE,
                    thick_core_area_pct=15.0,
                ),
                weathering=WeatheringKinetics(
                    evaporated_fraction_pct=34.2,
                    emulsified_water_fraction_pct=62.0,
                    emulsion_viscosity_cst=18500.0,
                    viscosity_increase_factor=37.0,
                    natural_dispersion_fraction_pct=8.4,
                    sedimentation_sinking_risk="MODERATE_NEARSHORE_SUSPENDED_SEDIMENT",
                    flash_point_celsius=68.0,
                ),
                sensitive_habitats=[
                    SensitiveHabitatNode(
                        habitat_id="marine_national_park_jamnagar",
                        habitat_name="Marine National Park & Coral Sanctuaries (Pirotan & Narara)",
                        ecosystem_type="Fringing Coral Reefs & Scleractinian Corals",
                        esi_rating=10,
                        distance_from_slick_km=14.5,
                        estimated_impact_eta_hours=9,
                        priority_protection_rank="PRIORITY_1_IMMEDIATE_DEFENSE",
                        boom_defense_plan="Deploy 2,400m Offshore Curtain Boom at Pirotan Channel mouth with deflection angle 45°.",
                    ),
                    SensitiveHabitatNode(
                        habitat_id="kutch_mangrove_creeks",
                        habitat_name="Avicennia Marina Mangrove Creeks (Mundra / Kandla)",
                        ecosystem_type="Intertidal Mangrove Mudflat Forest",
                        esi_rating=10,
                        distance_from_slick_km=28.0,
                        estimated_impact_eta_hours=18,
                        priority_protection_rank="PRIORITY_2_SHORELINE_EXCLUSION",
                        boom_defense_plan="Seal tidal creek inlets using multi-tube shore-sealing booms (SSB) anchored to mudflats.",
                    ),
                    SensitiveHabitatNode(
                        habitat_id="vadinar_crude_sbm_berths",
                        habitat_name="Vadinar IOCL/Nayara Single Buoy Moorings (SBM 1-3)",
                        ecosystem_type="Critical Deep-Water Hydrocarbon Infrastructure",
                        esi_rating=7,
                        distance_from_slick_km=6.2,
                        estimated_impact_eta_hours=4,
                        priority_protection_rank="PRIORITY_1_IMMEDIATE_DEFENSE",
                        boom_defense_plan="Surround SBM tanker loading berths with fast-deployment ocean containment booms and weir skimmers.",
                    ),
                ],
                icg_directives=IcgContainmentDirectives(
                    nosdcp_activation_level=SpillSeverityTier.TIER_2_REGIONAL_COAST_GUARD,
                    lead_response_authority="Indian Coast Guard District HQ No. 1 (Porbandar / Vadinar)",
                    containment_boom_type="Offshore High-Buoyancy Inflatable Curtain Boom (1200mm skirt)",
                    recommended_boom_length_meters=3500.0,
                    maximum_towing_speed_knots=0.75,
                    skimmer_selection="Oleophilic Multi-Disc & Brush Skimmer (Recovery capacity: 120 m³/h)",
                    chemical_dispersant_clearance="CONDITIONAL: Permitted outside 5km Marine National Park buffer where depth >20m.",
                    dispersant_restrictions="PROHIBITED in coral lagoons, intertidal mudflats, and oyster beds of Pirotan.",
                    coast_guard_emergency_no="1554",
                ),
            ),
            "mumbai_harbour_uran": OilSpillCorridor(
                corridor_id="mumbai_harbour_uran",
                corridor_name="Mumbai Harbour & JNPT / Uran Mudflats Corridor",
                state_or_ut="Maharashtra",
                latitude=18.92,
                longitude=72.85,
                spill_volume_tonnes=1200.0,
                oil_type=OilTypeClassification.HEAVY_BUNKER_FUEL_FO180,
                severity_tier=SpillSeverityTier.TIER_2_REGIONAL_COAST_GUARD,
                drift_vector=HydrodynamicDriftVector(
                    surface_current_speed_knots=2.1,
                    surface_current_direction_deg=75.0,
                    wind_speed_10m_knots=14.0,
                    wind_direction_deg=250.0,
                    net_drift_speed_knots=2.4,
                    net_drift_direction_deg=72.0,
                    stokes_drift_knots=0.22,
                ),
                trajectory_waypoints=[
                    TrajectoryWaypoint(
                        time_horizon_hours=6,
                        latitude=18.94,
                        longitude=72.93,
                        distance_traveled_km=11.2,
                        slick_area_km2=8.4,
                        slick_thickness_microns=195.0,
                        appearance_code=BonnAppearanceCode.CODE_4_DISCONTINUOUS_TRUE,
                        shoreline_hit_risk="HARBOUR_CHANNEL_APPROACH",
                    ),
                    TrajectoryWaypoint(
                        time_horizon_hours=12,
                        latitude=18.96,
                        longitude=73.01,
                        distance_traveled_km=22.5,
                        slick_area_km2=16.8,
                        slick_thickness_microns=110.0,
                        appearance_code=BonnAppearanceCode.CODE_4_DISCONTINUOUS_TRUE,
                        shoreline_hit_risk="IMMINENT_ELEPHANTA_ISLAND",
                    ),
                    TrajectoryWaypoint(
                        time_horizon_hours=24,
                        latitude=18.98,
                        longitude=73.12,
                        distance_traveled_km=45.0,
                        slick_area_km2=28.0,
                        slick_thickness_microns=58.0,
                        appearance_code=BonnAppearanceCode.CODE_3_METALLIC,
                        shoreline_hit_risk="URAN_MUDFLATS_IMPACT",
                    ),
                    TrajectoryWaypoint(
                        time_horizon_hours=48,
                        latitude=19.01,
                        longitude=73.22,
                        distance_traveled_km=78.0,
                        slick_area_km2=42.0,
                        slick_thickness_microns=24.0,
                        appearance_code=BonnAppearanceCode.CODE_3_METALLIC,
                        shoreline_hit_risk="THANE_CREEK_MANGROVE_SANCTUARY",
                    ),
                    TrajectoryWaypoint(
                        time_horizon_hours=72,
                        latitude=19.03,
                        longitude=73.30,
                        distance_traveled_km=105.0,
                        slick_area_km2=55.0,
                        slick_thickness_microns=8.0,
                        appearance_code=BonnAppearanceCode.CODE_2_RAINBOW,
                        shoreline_hit_risk="PERSISTENT_TAR_STRANDING",
                    ),
                ],
                fay_spreading=FaySpreadingMetrics(
                    current_regime="GRAVITY_VISCOUS_REGIME_II",
                    slick_radius_meters=2100.0,
                    slick_area_km2=13.85,
                    average_thickness_microns=145.0,
                    bonn_code=BonnAppearanceCode.CODE_4_DISCONTINUOUS_TRUE,
                    thick_core_area_pct=25.0,
                ),
                weathering=WeatheringKinetics(
                    evaporated_fraction_pct=11.5,
                    emulsified_water_fraction_pct=48.0,
                    emulsion_viscosity_cst=32000.0,
                    viscosity_increase_factor=45.0,
                    natural_dispersion_fraction_pct=4.2,
                    sedimentation_sinking_risk="HIGH_TAR_BALL_COASTAL_DEPOSITION",
                    flash_point_celsius=92.0,
                ),
                sensitive_habitats=[
                    SensitiveHabitatNode(
                        habitat_id="elephanta_unesco_reefs",
                        habitat_name="Elephanta Island Heritage Shoreline",
                        ecosystem_type="Intertidal Rocky Reef & Cultural Heritage Site",
                        esi_rating=8,
                        distance_from_slick_km=8.5,
                        estimated_impact_eta_hours=6,
                        priority_protection_rank="PRIORITY_1_IMMEDIATE_DEFENSE",
                        boom_defense_plan="Anchor 1,800m shoreline deflection booms south of Elephanta jetty.",
                    ),
                    SensitiveHabitatNode(
                        habitat_id="uran_flamingo_mudflats",
                        habitat_name="Uran & Panje Coastal Mudflats",
                        ecosystem_type="Migratory Wetland & Greater Flamingo Habitat",
                        esi_rating=9,
                        distance_from_slick_km=14.0,
                        estimated_impact_eta_hours=10,
                        priority_protection_rank="PRIORITY_1_IMMEDIATE_DEFENSE",
                        boom_defense_plan="Deploy intertidal sorbent booms and seal creek channels before high tide.",
                    ),
                    SensitiveHabitatNode(
                        habitat_id="jnpt_container_berths",
                        habitat_name="JNPT Nhava Sheva Container Terminals",
                        ecosystem_type="Major National Commercial Sea Port",
                        esi_rating=5,
                        distance_from_slick_km=11.0,
                        estimated_impact_eta_hours=8,
                        priority_protection_rank="PRIORITY_2_INFRASTRUCTURE_DEFENSE",
                        boom_defense_plan="Install fast-water boom sweeps across navigation channel to protect port berths.",
                    ),
                ],
                icg_directives=IcgContainmentDirectives(
                    nosdcp_activation_level=SpillSeverityTier.TIER_2_REGIONAL_COAST_GUARD,
                    lead_response_authority="Indian Coast Guard Region (West) HQ Mumbai & Mumbai Port Trust",
                    containment_boom_type="Heavy-Duty Fence Boom with PVC Ballast Weights",
                    recommended_boom_length_meters=2800.0,
                    maximum_towing_speed_knots=0.75,
                    skimmer_selection="Heavy-Oil Dynamic Viscous Screw / Toothed Drum Skimmer",
                    chemical_dispersant_clearance="PROHIBITED: Heavy Bunker FO-180 does not disperse chemically; mechanical recovery only.",
                    dispersant_restrictions="Dispersant use banned within enclosed Mumbai Harbour basin.",
                    coast_guard_emergency_no="1554",
                ),
            ),
            "gulf_of_mannar_pamban": OilSpillCorridor(
                corridor_id="gulf_of_mannar_pamban",
                corridor_name="Gulf of Mannar Biosphere & Pamban Island Corridor",
                state_or_ut="Tamil Nadu",
                latitude=9.28,
                longitude=79.12,
                spill_volume_tonnes=450.0,
                oil_type=OilTypeClassification.LIGHT_REFINED_DIESEL,
                severity_tier=SpillSeverityTier.TIER_1_LOCAL_PORT,
                drift_vector=HydrodynamicDriftVector(
                    surface_current_speed_knots=1.6,
                    surface_current_direction_deg=205.0,
                    wind_speed_10m_knots=12.0,
                    wind_direction_deg=40.0,
                    net_drift_speed_knots=1.9,
                    net_drift_direction_deg=208.0,
                    stokes_drift_knots=0.18,
                ),
                trajectory_waypoints=[
                    TrajectoryWaypoint(
                        time_horizon_hours=6,
                        latitude=9.18,
                        longitude=79.05,
                        distance_traveled_km=14.5,
                        slick_area_km2=6.8,
                        slick_thickness_microns=18.0,
                        appearance_code=BonnAppearanceCode.CODE_3_METALLIC,
                        shoreline_hit_risk="APPROACHING_CORAL_ISLANDS",
                    ),
                    TrajectoryWaypoint(
                        time_horizon_hours=12,
                        latitude=9.08,
                        longitude=78.98,
                        distance_traveled_km=29.0,
                        slick_area_km2=14.5,
                        slick_thickness_microns=7.5,
                        appearance_code=BonnAppearanceCode.CODE_2_RAINBOW,
                        shoreline_hit_risk="KURUSADAI_ISLAND_FRINGE",
                    ),
                    TrajectoryWaypoint(
                        time_horizon_hours=24,
                        latitude=8.88,
                        longitude=78.85,
                        distance_traveled_km=58.0,
                        slick_area_km2=24.0,
                        slick_thickness_microns=2.2,
                        appearance_code=BonnAppearanceCode.CODE_2_RAINBOW,
                        shoreline_hit_risk="SEAGRASS_BED_DRIFT",
                    ),
                ],
                fay_spreading=FaySpreadingMetrics(
                    current_regime="VISCOUS_SURFACE_TENSION_REGIME_III",
                    slick_radius_meters=1400.0,
                    slick_area_km2=6.15,
                    average_thickness_microns=22.0,
                    bonn_code=BonnAppearanceCode.CODE_3_METALLIC,
                    thick_core_area_pct=8.0,
                ),
                weathering=WeatheringKinetics(
                    evaporated_fraction_pct=58.5,
                    emulsified_water_fraction_pct=14.0,
                    emulsion_viscosity_cst=450.0,
                    viscosity_increase_factor=4.5,
                    natural_dispersion_fraction_pct=26.0,
                    sedimentation_sinking_risk="LOW_HIGHLY_VOLATILE",
                    flash_point_celsius=52.0,
                ),
                sensitive_habitats=[
                    SensitiveHabitatNode(
                        habitat_id="kurusadai_coral_reserve",
                        habitat_name="Kurusadai Island Coral Reef Sanctuary",
                        ecosystem_type="Pristine Acropora Coral Reefs & Seagrass Meadow",
                        esi_rating=10,
                        distance_from_slick_km=11.2,
                        estimated_impact_eta_hours=7,
                        priority_protection_rank="PRIORITY_1_IMMEDIATE_DEFENSE",
                        boom_defense_plan="Deploy exclusion sorbent booms around reef crest; zero chemical dispersants.",
                    ),
                    SensitiveHabitatNode(
                        habitat_id="dugong_feeding_meadows",
                        habitat_name="Dugong Dugon (Sea Cow) Grazing Meadows",
                        ecosystem_type="Subtidal Halophila Seagrass Beds",
                        esi_rating=10,
                        distance_from_slick_km=18.0,
                        estimated_impact_eta_hours=12,
                        priority_protection_rank="PRIORITY_1_IMMEDIATE_DEFENSE",
                        boom_defense_plan="Maintain surface sorbent sweeps and visual marine mammal watch vessels.",
                    ),
                ],
                icg_directives=IcgContainmentDirectives(
                    nosdcp_activation_level=SpillSeverityTier.TIER_1_LOCAL_PORT,
                    lead_response_authority="ICG Station Mandapam & Tuticorin Port Trust",
                    containment_boom_type="Lightweight Fast-Water Curtain Boom & Sorbent Booms",
                    recommended_boom_length_meters=1500.0,
                    maximum_towing_speed_knots=0.75,
                    skimmer_selection="Weir Skimmer with Sorbent Pad Manual Mop-Up",
                    chemical_dispersant_clearance="STRICTLY PROHIBITED: Eco-sensitive marine biosphere; chemical dispersants banned.",
                    dispersant_restrictions="Absolute ban within 20 km of Gulf of Mannar Marine National Park.",
                    coast_guard_emergency_no="1554",
                ),
            ),
            "gahirmatha_olive_ridley": OilSpillCorridor(
                corridor_id="gahirmatha_olive_ridley",
                corridor_name="Gahirmatha & Bhitarkanika Marine Sanctuary Corridor",
                state_or_ut="Odisha",
                latitude=20.72,
                longitude=87.05,
                spill_volume_tonnes=2200.0,
                oil_type=OilTypeClassification.MEDIUM_CRUDE_ARABIAN_LIGHT,
                severity_tier=SpillSeverityTier.TIER_2_REGIONAL_COAST_GUARD,
                drift_vector=HydrodynamicDriftVector(
                    surface_current_speed_knots=2.4,
                    surface_current_direction_deg=250.0,
                    wind_speed_10m_knots=16.0,
                    wind_direction_deg=70.0,
                    net_drift_speed_knots=2.8,
                    net_drift_direction_deg=246.0,
                    stokes_drift_knots=0.30,
                ),
                trajectory_waypoints=[
                    TrajectoryWaypoint(
                        time_horizon_hours=6,
                        latitude=20.65,
                        longitude=86.92,
                        distance_traveled_km=15.6,
                        slick_area_km2=12.5,
                        slick_thickness_microns=130.0,
                        appearance_code=BonnAppearanceCode.CODE_4_DISCONTINUOUS_TRUE,
                        shoreline_hit_risk="APPROACHING_NESTING_BEACH",
                    ),
                    TrajectoryWaypoint(
                        time_horizon_hours=12,
                        latitude=20.58,
                        longitude=86.79,
                        distance_traveled_km=31.2,
                        slick_area_km2=25.0,
                        slick_thickness_microns=72.0,
                        appearance_code=BonnAppearanceCode.CODE_4_DISCONTINUOUS_TRUE,
                        shoreline_hit_risk="IMMINENT_ARRIBADA_SHORELINE",
                    ),
                    TrajectoryWaypoint(
                        time_horizon_hours=24,
                        latitude=20.45,
                        longitude=86.52,
                        distance_traveled_km=62.4,
                        slick_area_km2=48.0,
                        slick_thickness_microns=36.0,
                        appearance_code=BonnAppearanceCode.CODE_3_METALLIC,
                        shoreline_hit_risk="BHITARKANIKA_CREEK_MOUTH",
                    ),
                ],
                fay_spreading=FaySpreadingMetrics(
                    current_regime="GRAVITY_VISCOUS_REGIME_II",
                    slick_radius_meters=2600.0,
                    slick_area_km2=21.23,
                    average_thickness_microns=95.0,
                    bonn_code=BonnAppearanceCode.CODE_4_DISCONTINUOUS_TRUE,
                    thick_core_area_pct=18.0,
                ),
                weathering=WeatheringKinetics(
                    evaporated_fraction_pct=28.5,
                    emulsified_water_fraction_pct=58.0,
                    emulsion_viscosity_cst=14200.0,
                    viscosity_increase_factor=28.0,
                    natural_dispersion_fraction_pct=9.0,
                    sedimentation_sinking_risk="MODERATE_ESTUARINE_SILT_LOADING",
                    flash_point_celsius=64.0,
                ),
                sensitive_habitats=[
                    SensitiveHabitatNode(
                        habitat_id="gahirmatha_turtle_rookery",
                        habitat_name="Gahirmatha Olive Ridley Mass Nesting Beach (Arribada)",
                        ecosystem_type="World's Largest Sea Turtle Nesting Ground",
                        esi_rating=10,
                        distance_from_slick_km=12.8,
                        estimated_impact_eta_hours=8,
                        priority_protection_rank="PRIORITY_1_IMMEDIATE_DEFENSE",
                        boom_defense_plan="Deploy offshore exclusion boom chain 2km seaward of nesting beaches; zero bright lights at night.",
                    ),
                    SensitiveHabitatNode(
                        habitat_id="bhitarkanika_mangrove_ramsar",
                        habitat_name="Bhitarkanika Mangroves (Ramsar Site No. 1205)",
                        ecosystem_type="Estuarine Mangroves & Saltwater Crocodile Habitat",
                        esi_rating=10,
                        distance_from_slick_km=22.0,
                        estimated_impact_eta_hours=14,
                        priority_protection_rank="PRIORITY_1_IMMEDIATE_DEFENSE",
                        boom_defense_plan="Seal Dhamra and Maipura river mouths with tidal deflection booms to block ingress.",
                    ),
                ],
                icg_directives=IcgContainmentDirectives(
                    nosdcp_activation_level=SpillSeverityTier.TIER_2_REGIONAL_COAST_GUARD,
                    lead_response_authority="ICG District HQ No. 7 (Paradip) & Odisha Forest Dept",
                    containment_boom_type="Offshore Curtain Boom & Shoreline Inflatable Tubes",
                    recommended_boom_length_meters=3200.0,
                    maximum_towing_speed_knots=0.75,
                    skimmer_selection="Oleophilic Brush Skimmer with Heavy Mudflats Vacuum Units",
                    chemical_dispersant_clearance="PROHIBITED within 15 km of Gahirmatha turtle mating & nesting sanctuaries.",
                    dispersant_restrictions="Absolute ban to prevent egg shell contamination and hatchling toxicity.",
                    coast_guard_emergency_no="1554",
                ),
            ),
            "sundarbans_hooghly": OilSpillCorridor(
                corridor_id="sundarbans_hooghly",
                corridor_name="Sundarbans Biosphere & Hooghly Estuary Corridor",
                state_or_ut="West Bengal",
                latitude=21.65,
                longitude=88.08,
                spill_volume_tonnes=1800.0,
                oil_type=OilTypeClassification.HEAVY_BUNKER_FUEL_FO180,
                severity_tier=SpillSeverityTier.TIER_2_REGIONAL_COAST_GUARD,
                drift_vector=HydrodynamicDriftVector(
                    surface_current_speed_knots=3.2,
                    surface_current_direction_deg=35.0,
                    wind_speed_10m_knots=15.0,
                    wind_direction_deg=210.0,
                    net_drift_speed_knots=3.6,
                    net_drift_direction_deg=32.0,
                    stokes_drift_knots=0.25,
                ),
                trajectory_waypoints=[
                    TrajectoryWaypoint(
                        time_horizon_hours=6,
                        latitude=21.78,
                        longitude=88.16,
                        distance_traveled_km=20.0,
                        slick_area_km2=14.0,
                        slick_thickness_microns=165.0,
                        appearance_code=BonnAppearanceCode.CODE_4_DISCONTINUOUS_TRUE,
                        shoreline_hit_risk="SAGAR_ISLAND_EASTERN_CREEK",
                    ),
                    TrajectoryWaypoint(
                        time_horizon_hours=12,
                        latitude=21.91,
                        longitude=88.24,
                        distance_traveled_km=40.0,
                        slick_area_km2=26.0,
                        slick_thickness_microns=92.0,
                        appearance_code=BonnAppearanceCode.CODE_4_DISCONTINUOUS_TRUE,
                        shoreline_hit_risk="SUNDARBANS_BUFFER_MANGROVE_ENTRY",
                    ),
                    TrajectoryWaypoint(
                        time_horizon_hours=24,
                        latitude=22.15,
                        longitude=88.42,
                        distance_traveled_km=80.0,
                        slick_area_km2=45.0,
                        slick_thickness_microns=48.0,
                        appearance_code=BonnAppearanceCode.CODE_3_METALLIC,
                        shoreline_hit_risk="TIDAL_CANAL_DEBRIS_DISPERSION",
                    ),
                ],
                fay_spreading=FaySpreadingMetrics(
                    current_regime="GRAVITY_VISCOUS_REGIME_II",
                    slick_radius_meters=2400.0,
                    slick_area_km2=18.10,
                    average_thickness_microns=120.0,
                    bonn_code=BonnAppearanceCode.CODE_4_DISCONTINUOUS_TRUE,
                    thick_core_area_pct=22.0,
                ),
                weathering=WeatheringKinetics(
                    evaporated_fraction_pct=14.0,
                    emulsified_water_fraction_pct=52.0,
                    emulsion_viscosity_cst=26000.0,
                    viscosity_increase_factor=38.0,
                    natural_dispersion_fraction_pct=5.5,
                    sedimentation_sinking_risk="HIGH_BENTHIC_SILT_AGGLOMERATION",
                    flash_point_celsius=88.0,
                ),
                sensitive_habitats=[
                    SensitiveHabitatNode(
                        habitat_id="sundarbans_tiger_mangroves",
                        habitat_name="Sundarbans World Heritage Mangrove Delta",
                        ecosystem_type="Tidal Halophytic Mangroves & Royal Bengal Tiger Reserve",
                        esi_rating=10,
                        distance_from_slick_km=16.5,
                        estimated_impact_eta_hours=8,
                        priority_protection_rank="PRIORITY_1_IMMEDIATE_DEFENSE",
                        boom_defense_plan="Deploy heavy tidal booms across Muriganga and Saptamukhi river entrances.",
                    ),
                    SensitiveHabitatNode(
                        habitat_id="haldia_oil_dock_basin",
                        habitat_name="Haldia Dock Complex & Oil Jetty",
                        ecosystem_type="Major Chemical & Petroleum Port Hub",
                        esi_rating=6,
                        distance_from_slick_km=28.0,
                        estimated_impact_eta_hours=13,
                        priority_protection_rank="PRIORITY_2_INFRASTRUCTURE_DEFENSE",
                        boom_defense_plan="Station recovery catamarans and protective gate booms across lock entrances.",
                    ),
                ],
                icg_directives=IcgContainmentDirectives(
                    nosdcp_activation_level=SpillSeverityTier.TIER_2_REGIONAL_COAST_GUARD,
                    lead_response_authority="ICG District HQ No. 8 (Haldia) & Kolkata Port Trust (Syama Prasad Mookerjee Port)",
                    containment_boom_type="High-Tidal Fast-Water Boom with Reinforced Skirt",
                    recommended_boom_length_meters=3000.0,
                    maximum_towing_speed_knots=0.75,
                    skimmer_selection="Oleophilic Toothed-Disc Skimmer & Shoreline Vacuum Tankers",
                    chemical_dispersant_clearance="STRICTLY PROHIBITED in shallow brackish waters of Sundarbans Delta.",
                    dispersant_restrictions="Absolute ban due to danger to Gangetic dolphins, mudskippers, and mangrove pneumatophores.",
                    coast_guard_emergency_no="1554",
                ),
            ),
            "vembanad_cochin": OilSpillCorridor(
                corridor_id="vembanad_cochin",
                corridor_name="Cochin Port & Vembanad Estuary Backwaters",
                state_or_ut="Kerala",
                latitude=9.96,
                longitude=76.24,
                spill_volume_tonnes=350.0,
                oil_type=OilTypeClassification.LIGHT_REFINED_DIESEL,
                severity_tier=SpillSeverityTier.TIER_1_LOCAL_PORT,
                drift_vector=HydrodynamicDriftVector(
                    surface_current_speed_knots=1.8,
                    surface_current_direction_deg=145.0,
                    wind_speed_10m_knots=11.0,
                    wind_direction_deg=310.0,
                    net_drift_speed_knots=2.1,
                    net_drift_direction_deg=142.0,
                    stokes_drift_knots=0.15,
                ),
                trajectory_waypoints=[
                    TrajectoryWaypoint(
                        time_horizon_hours=6,
                        latitude=9.88,
                        longitude=76.31,
                        distance_traveled_km=11.5,
                        slick_area_km2=5.2,
                        slick_thickness_microns=24.0,
                        appearance_code=BonnAppearanceCode.CODE_3_METALLIC,
                        shoreline_hit_risk="WILLINGDON_ISLAND_CHANNEL",
                    ),
                    TrajectoryWaypoint(
                        time_horizon_hours=12,
                        latitude=9.80,
                        longitude=76.38,
                        distance_traveled_km=23.0,
                        slick_area_km2=11.0,
                        slick_thickness_microns=9.5,
                        appearance_code=BonnAppearanceCode.CODE_2_RAINBOW,
                        shoreline_hit_risk="VEMBANAD_BACKWATER_INGRESS",
                    ),
                ],
                fay_spreading=FaySpreadingMetrics(
                    current_regime="VISCOUS_SURFACE_TENSION_REGIME_III",
                    slick_radius_meters=1200.0,
                    slick_area_km2=4.52,
                    average_thickness_microns=28.0,
                    bonn_code=BonnAppearanceCode.CODE_3_METALLIC,
                    thick_core_area_pct=10.0,
                ),
                weathering=WeatheringKinetics(
                    evaporated_fraction_pct=62.0,
                    emulsified_water_fraction_pct=12.0,
                    emulsion_viscosity_cst=320.0,
                    viscosity_increase_factor=3.2,
                    natural_dispersion_fraction_pct=24.0,
                    sedimentation_sinking_risk="LOW_HIGHLY_VOLATILE",
                    flash_point_celsius=54.0,
                ),
                sensitive_habitats=[
                    SensitiveHabitatNode(
                        habitat_id="vembanad_ramsar_backwaters",
                        habitat_name="Vembanad-Kol Wetland Backwaters (Ramsar Site No. 1214)",
                        ecosystem_type="Estuarine Clam Fisheries & Mangrove Patches",
                        esi_rating=10,
                        distance_from_slick_km=9.8,
                        estimated_impact_eta_hours=5,
                        priority_protection_rank="PRIORITY_1_IMMEDIATE_DEFENSE",
                        boom_defense_plan="Lock harbour entrance gates and stretch sorbent booms across shipping mouth.",
                    ),
                ],
                icg_directives=IcgContainmentDirectives(
                    nosdcp_activation_level=SpillSeverityTier.TIER_1_LOCAL_PORT,
                    lead_response_authority="Cochin Port Trust & ICG District HQ No. 4 (Kochi)",
                    containment_boom_type="Inshore Curtain Boom & Sorbent Booms",
                    recommended_boom_length_meters=1400.0,
                    maximum_towing_speed_knots=0.75,
                    skimmer_selection="Weir Skimmer with Sorbent Mop Deployment",
                    chemical_dispersant_clearance="PROHIBITED in inland backwaters and near fish breeding shoals.",
                    dispersant_restrictions="Zero chemical application within Cochin harbour.",
                    coast_guard_emergency_no="1554",
                ),
            ),
            "andaman_malacca_corridor": OilSpillCorridor(
                corridor_id="andaman_malacca_corridor",
                corridor_name="Great Nicobar & Malacca Strait Tanker Sea Lane",
                state_or_ut="Andaman and Nicobar Islands",
                latitude=6.85,
                longitude=93.85,
                spill_volume_tonnes=12500.0,
                oil_type=OilTypeClassification.MEDIUM_CRUDE_ARABIAN_LIGHT,
                severity_tier=SpillSeverityTier.TIER_3_NATIONAL_NOSDCP,
                drift_vector=HydrodynamicDriftVector(
                    surface_current_speed_knots=3.0,
                    surface_current_direction_deg=280.0,
                    wind_speed_10m_knots=22.0,
                    wind_direction_deg=105.0,
                    net_drift_speed_knots=3.7,
                    net_drift_direction_deg=282.0,
                    stokes_drift_knots=0.45,
                ),
                trajectory_waypoints=[
                    TrajectoryWaypoint(
                        time_horizon_hours=6,
                        latitude=6.87,
                        longitude=93.68,
                        distance_traveled_km=20.5,
                        slick_area_km2=28.0,
                        slick_thickness_microns=240.0,
                        appearance_code=BonnAppearanceCode.CODE_5_CONTINUOUS_TRUE,
                        shoreline_hit_risk="DEEP_OCEANIC_SPREAD",
                    ),
                    TrajectoryWaypoint(
                        time_horizon_hours=12,
                        latitude=6.90,
                        longitude=93.51,
                        distance_traveled_km=41.0,
                        slick_area_km2=55.0,
                        slick_thickness_microns=135.0,
                        appearance_code=BonnAppearanceCode.CODE_4_DISCONTINUOUS_TRUE,
                        shoreline_hit_risk="APPROACHING_INDIRA_POINT_REEFS",
                    ),
                    TrajectoryWaypoint(
                        time_horizon_hours=24,
                        latitude=6.95,
                        longitude=93.18,
                        distance_traveled_km=82.0,
                        slick_area_km2=105.0,
                        slick_thickness_microns=70.0,
                        appearance_code=BonnAppearanceCode.CODE_4_DISCONTINUOUS_TRUE,
                        shoreline_hit_risk="IMMINENT_CORAL_ATOLL_IMPACT",
                    ),
                    TrajectoryWaypoint(
                        time_horizon_hours=48,
                        latitude=7.05,
                        longitude=92.52,
                        distance_traveled_km=164.0,
                        slick_area_km2=190.0,
                        slick_thickness_microns=28.0,
                        appearance_code=BonnAppearanceCode.CODE_3_METALLIC,
                        shoreline_hit_risk="OPEN_ANDAMAN_SEA_DISPERSION",
                    ),
                ],
                fay_spreading=FaySpreadingMetrics(
                    current_regime="GRAVITY_INERTIA_REGIME_I",
                    slick_radius_meters=4500.0,
                    slick_area_km2=63.62,
                    average_thickness_microns=185.0,
                    bonn_code=BonnAppearanceCode.CODE_4_DISCONTINUOUS_TRUE,
                    thick_core_area_pct=28.0,
                ),
                weathering=WeatheringKinetics(
                    evaporated_fraction_pct=30.5,
                    emulsified_water_fraction_pct=64.0,
                    emulsion_viscosity_cst=22000.0,
                    viscosity_increase_factor=40.0,
                    natural_dispersion_fraction_pct=11.0,
                    sedimentation_sinking_risk="LOW_DEEP_OCEAN_PELAGIC",
                    flash_point_celsius=66.0,
                ),
                sensitive_habitats=[
                    SensitiveHabitatNode(
                        habitat_id="great_nicobar_coral_atolls",
                        habitat_name="Great Nicobar Biosphere Reserve & Coral Atolls",
                        ecosystem_type="Pristine Oceanic Fringing Reefs & Leatherback Turtle Nesting",
                        esi_rating=10,
                        distance_from_slick_km=26.0,
                        estimated_impact_eta_hours=14,
                        priority_protection_rank="PRIORITY_1_IMMEDIATE_DEFENSE",
                        boom_defense_plan="Deploy ICG Pollution Control Vessels (PCVs) with oceanic sweeping arms and aerial dispersant spraying outside reef margin.",
                    ),
                ],
                icg_directives=IcgContainmentDirectives(
                    nosdcp_activation_level=SpillSeverityTier.TIER_3_NATIONAL_NOSDCP,
                    lead_response_authority="DG Coast Guard (National Coordinating Authority) & ICG Region (A&N) Port Blair",
                    containment_boom_type="Oceanic Ro-Boom & Heavy Inflatable High-Sea Sweeping Arms",
                    recommended_boom_length_meters=6000.0,
                    maximum_towing_speed_knots=0.75,
                    skimmer_selection="High-Volume Heavy Ocean Skimmers (300 m³/h capacity)",
                    chemical_dispersant_clearance="APPROVED: Aerial Type-III Concentrate spraying cleared by DG ICG in deep water (>50m depth).",
                    dispersant_restrictions="Maintain strict 5km standoff distance from coral reef margins and shallow bays.",
                    coast_guard_emergency_no="1554",
                ),
            ),
        }
