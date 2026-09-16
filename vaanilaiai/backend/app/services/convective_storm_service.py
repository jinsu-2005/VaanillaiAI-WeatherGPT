import math
from datetime import datetime, timezone
from typing import Dict, List, Optional

from app.schemas.convective_storm import (
    StormPhenomenonType,
    ConvectiveWarningStage,
    ThermodynamicInstability,
    HaboobDensityCurrent,
    AviationGridImpact,
    ConvectiveStormHotspot,
    ConvectiveStormResponse,
)


def _haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    R = 6371.0  # Earth's radius in km
    d_lat = math.radians(lat2 - lat1)
    d_lon = math.radians(lon2 - lon1)
    a = (
        math.sin(d_lat / 2.0) ** 2
        + math.cos(math.radians(lat1))
        * math.cos(math.radians(lat2))
        * math.sin(d_lon / 2.0) ** 2
    )
    c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
    return R * c


class ConvectiveStormService:
    """
    Operational IMD Thunderstorm & Convective Nowcasting Division
    and WMO/IMD SWFDP Severe Convective Storm Warning Engine.
    """

    def __init__(self):
        self._hotspots: List[ConvectiveStormHotspot] = self._init_hotspots()

    def _init_hotspots(self) -> List[ConvectiveStormHotspot]:
        return [
            ConvectiveStormHotspot(
                hotspot_id="kolkata_gangetic_wb",
                hotspot_name="Kolkata & Gangetic West Bengal Corridor",
                state="West Bengal",
                latitude=22.5726,
                longitude=88.3639,
                phenomenon=StormPhenomenonType.KALBAISHAKHI_NORWESTER,
                warning_stage=ConvectiveWarningStage.STAGE_4_RED_SEVERE_WARNING,
                headline="Red Alert: Severe Kalbaishakhi squall line advancing from Chhotanagpur Plateau with gale winds up to 95 km/h, intense lightning, and severe hail.",
                thermodynamics=ThermodynamicInstability(
                    cape_j_kg=3650.0,
                    lifted_index_c=-7.2,
                    k_index_c=41.0,
                    total_totals_c=56.0,
                    sweat_index=415.0,
                    bulk_wind_shear_0_6km_kt=52.0,
                    cin_j_kg=15.0,
                ),
                density_current=HaboobDensityCurrent(
                    gust_front_speed_kmh=95.0,
                    dust_wall_height_m=450.0,
                    minimum_visibility_m=150.0,
                    pm10_surge_ug_m3=420.0,
                    cold_pool_temp_drop_c=10.5,
                    downdraft_spread_direction="North-West to South-East",
                ),
                aviation_grid=AviationGridImpact(
                    microburst_risk="Severe Microburst Alert — Low-Level Wind Shear >45 kt",
                    power_grid_risk="Extreme risk of 400kV / 220kV transmission line tripping and insulator damage",
                    airport_alert="CCU (Kolkata Airport) ground operations cautioned; crosswind limit exceedance",
                    structural_damage_risk="High risk of tree uprooting, tin roof detachment, and billboard collapse",
                ),
                radar_reflectivity_dbz=62.0,
                nowcast_validity_hours=3,
            ),
            ConvectiveStormHotspot(
                hotspot_id="bhubaneswar_coastal_odisha",
                hotspot_name="Bhubaneswar & Coastal Odisha Corridor",
                state="Odisha",
                latitude=20.2961,
                longitude=85.8245,
                phenomenon=StormPhenomenonType.KALBAISHAKHI_NORWESTER,
                warning_stage=ConvectiveWarningStage.STAGE_3_ORANGE_WARNING,
                headline="Orange Warning: Nor'wester multicell cluster bringing wind gusts of 75-85 km/h and frequent cloud-to-ground lightning across Khordha, Cuttack, and Puri.",
                thermodynamics=ThermodynamicInstability(
                    cape_j_kg=2980.0,
                    lifted_index_c=-5.8,
                    k_index_c=37.5,
                    total_totals_c=52.5,
                    sweat_index=360.0,
                    bulk_wind_shear_0_6km_kt=44.0,
                    cin_j_kg=30.0,
                ),
                density_current=HaboobDensityCurrent(
                    gust_front_speed_kmh=82.0,
                    dust_wall_height_m=300.0,
                    minimum_visibility_m=350.0,
                    pm10_surge_ug_m3=280.0,
                    cold_pool_temp_drop_c=8.0,
                    downdraft_spread_direction="North-West to South-East",
                ),
                aviation_grid=AviationGridImpact(
                    microburst_risk="Moderate Microburst Risk — Gust front wind shear 35-40 kt",
                    power_grid_risk="Elevated risk of rural 33kV distribution feeder tripping",
                    airport_alert="BBI Airport cautioned for sudden wind shifts and heavy rain rates",
                    structural_damage_risk="Minor damage to kutcha structures, banana plantations, and overhead wires",
                ),
                radar_reflectivity_dbz=56.0,
                nowcast_validity_hours=3,
            ),
            ConvectiveStormHotspot(
                hotspot_id="guwahati_brahmaputra",
                hotspot_name="Guwahati & Lower Brahmaputra Valley",
                state="Assam",
                latitude=26.1445,
                longitude=91.7362,
                phenomenon=StormPhenomenonType.SEVERE_SQUALL_LINE,
                warning_stage=ConvectiveWarningStage.STAGE_3_ORANGE_WARNING,
                headline="Orange Warning: Pre-monsoon Bordoichila squall line crossing Kamrup with torrential rain downbursts and squally winds up to 80 km/h.",
                thermodynamics=ThermodynamicInstability(
                    cape_j_kg=3120.0,
                    lifted_index_c=-6.1,
                    k_index_c=39.0,
                    total_totals_c=53.0,
                    sweat_index=375.0,
                    bulk_wind_shear_0_6km_kt=46.0,
                    cin_j_kg=20.0,
                ),
                density_current=HaboobDensityCurrent(
                    gust_front_speed_kmh=78.0,
                    dust_wall_height_m=250.0,
                    minimum_visibility_m=200.0,
                    pm10_surge_ug_m3=180.0,
                    cold_pool_temp_drop_c=7.5,
                    downdraft_spread_direction="South-West to North-East",
                ),
                aviation_grid=AviationGridImpact(
                    microburst_risk="Moderate to Severe Microburst in valley funneling zone",
                    power_grid_risk="Disruption of local power supply due to fallen trees across transmission lines",
                    airport_alert="GAU (Guwahati Airport) approach wind shear warning issued",
                    structural_damage_risk="Damage to thatched roofs, standing crops, and tea garden shade trees",
                ),
                radar_reflectivity_dbz=58.0,
                nowcast_validity_hours=3,
            ),
            ConvectiveStormHotspot(
                hotspot_id="bikaner_thar_desert",
                hotspot_name="Bikaner & Western Thar Desert Sector",
                state="Rajasthan",
                latitude=28.0229,
                longitude=73.3119,
                phenomenon=StormPhenomenonType.HABOOB_ANDHI_DUST_STORM,
                warning_stage=ConvectiveWarningStage.STAGE_4_RED_SEVERE_WARNING,
                headline="Red Alert: Massive convective Haboob dust wall (>2,500m height) advancing across Thar Desert. Zero optical visibility (<50m) and severe PM10 particulate surge.",
                thermodynamics=ThermodynamicInstability(
                    cape_j_kg=2150.0,
                    lifted_index_c=-4.2,
                    k_index_c=32.0,
                    total_totals_c=54.0,
                    sweat_index=340.0,
                    bulk_wind_shear_0_6km_kt=40.0,
                    cin_j_kg=60.0,
                ),
                density_current=HaboobDensityCurrent(
                    gust_front_speed_kmh=88.0,
                    dust_wall_height_m=2600.0,
                    minimum_visibility_m=40.0,
                    pm10_surge_ug_m3=1850.0,
                    cold_pool_temp_drop_c=11.0,
                    downdraft_spread_direction="West to East-North-East",
                ),
                aviation_grid=AviationGridImpact(
                    microburst_risk="Extreme convective dust downdraft; flight operations suspended",
                    power_grid_risk="Severe particulate pollution insulator flashovers and transmission tower bending torque",
                    airport_alert="Runway visual range collapsed; all regional traffic advised holding or diversion",
                    structural_damage_risk="Severe dust penetration, total blinding on National Highways, and acute respiratory crisis",
                ),
                radar_reflectivity_dbz=48.0,
                nowcast_validity_hours=3,
            ),
            ConvectiveStormHotspot(
                hotspot_id="hisar_south_haryana",
                hotspot_name="Hisar & South Haryana Plains Corridor",
                state="Haryana",
                latitude=29.1492,
                longitude=75.7217,
                phenomenon=StormPhenomenonType.HABOOB_ANDHI_DUST_STORM,
                warning_stage=ConvectiveWarningStage.STAGE_3_ORANGE_WARNING,
                headline="Orange Warning: Severe convective Andhi with surface wind gusts of 70-80 km/h, sharp visibility drop below 200m, and intense dust blowing.",
                thermodynamics=ThermodynamicInstability(
                    cape_j_kg=2400.0,
                    lifted_index_c=-5.0,
                    k_index_c=34.0,
                    total_totals_c=52.0,
                    sweat_index=330.0,
                    bulk_wind_shear_0_6km_kt=38.0,
                    cin_j_kg=45.0,
                ),
                density_current=HaboobDensityCurrent(
                    gust_front_speed_kmh=76.0,
                    dust_wall_height_m=1600.0,
                    minimum_visibility_m=180.0,
                    pm10_surge_ug_m3=1200.0,
                    cold_pool_temp_drop_c=8.5,
                    downdraft_spread_direction="North-West to South-East",
                ),
                aviation_grid=AviationGridImpact(
                    microburst_risk="Elevated microburst risk across southern Haryana flight paths",
                    power_grid_risk="Power outages likely due to tree branches snapping onto distribution poles",
                    airport_alert="Low visibility advisory for regional airfields and NHAI highway transit",
                    structural_damage_risk="Blowing dust causing traffic pileup hazards; stay indoors",
                ),
                radar_reflectivity_dbz=50.0,
                nowcast_validity_hours=3,
            ),
            ConvectiveStormHotspot(
                hotspot_id="delhi_ncr_convective",
                hotspot_name="Delhi-NCR Convective Convergence Hub",
                state="Delhi NCR",
                latitude=28.6139,
                longitude=77.2090,
                phenomenon=StormPhenomenonType.GUST_FRONT_MICROBURST,
                warning_stage=ConvectiveWarningStage.STAGE_3_ORANGE_WARNING,
                headline="Orange Warning: Severe gust front collision over Delhi-NCR. Sudden wind shear up to 80 km/h followed by thunderstorm rain and hail.",
                thermodynamics=ThermodynamicInstability(
                    cape_j_kg=2750.0,
                    lifted_index_c=-5.5,
                    k_index_c=36.0,
                    total_totals_c=53.5,
                    sweat_index=355.0,
                    bulk_wind_shear_0_6km_kt=42.0,
                    cin_j_kg=35.0,
                ),
                density_current=HaboobDensityCurrent(
                    gust_front_speed_kmh=82.0,
                    dust_wall_height_m=1200.0,
                    minimum_visibility_m=300.0,
                    pm10_surge_ug_m3=950.0,
                    cold_pool_temp_drop_c=9.0,
                    downdraft_spread_direction="West-North-West to East-South-East",
                ),
                aviation_grid=AviationGridImpact(
                    microburst_risk="DEL IGI Airport Wind Shear Alert active for Runways 28/29",
                    power_grid_risk="Metro overhead line trips possible; DISCOM emergency teams alerted",
                    airport_alert="Ground boarding suspended during peak squall transit across Palam & Hindon",
                    structural_damage_risk="Traffic disruptions, traffic signal failures, and localized waterlogging",
                ),
                radar_reflectivity_dbz=54.0,
                nowcast_validity_hours=3,
            ),
            ConvectiveStormHotspot(
                hotspot_id="patna_middle_ganga",
                hotspot_name="Patna & Middle Gangetic Basin",
                state="Bihar",
                latitude=25.5941,
                longitude=85.1376,
                phenomenon=StormPhenomenonType.HAILSTORM_SUPERCELL,
                warning_stage=ConvectiveWarningStage.STAGE_3_ORANGE_WARNING,
                headline="Orange Warning: Severe multicell hailstorm cluster moving across Patna and Vaishali with large hail (2-4 cm) and squally winds.",
                thermodynamics=ThermodynamicInstability(
                    cape_j_kg=3200.0,
                    lifted_index_c=-6.5,
                    k_index_c=38.0,
                    total_totals_c=55.0,
                    sweat_index=390.0,
                    bulk_wind_shear_0_6km_kt=48.0,
                    cin_j_kg=25.0,
                ),
                density_current=HaboobDensityCurrent(
                    gust_front_speed_kmh=75.0,
                    dust_wall_height_m=500.0,
                    minimum_visibility_m=400.0,
                    pm10_surge_ug_m3=320.0,
                    cold_pool_temp_drop_c=8.0,
                    downdraft_spread_direction="North-West to South-East",
                ),
                aviation_grid=AviationGridImpact(
                    microburst_risk="Severe hail impact and moderate microburst risk",
                    power_grid_risk="Hail impact damage to solar arrays and overhead lines",
                    airport_alert="PAT (Patna Airport) aircraft operations advised delay",
                    structural_damage_risk="Significant damage to standing Rabi crops (wheat, mango blossoms, vegetables)",
                ),
                radar_reflectivity_dbz=60.0,
                nowcast_validity_hours=3,
            ),
        ]

    def _generate_vernacular_bulletins(self, hotspot: ConvectiveStormHotspot) -> Dict[str, str]:
        stage = hotspot.warning_stage.value.replace("_", " ")
        phenom = hotspot.phenomenon.value.replace("_", " ")

        return {
            "en": (
                f"IMD SEVERE CONVECTIVE NOWCAST: {hotspot.hotspot_name} is under {stage} for {phenom}. "
                f"Leading gust front speed: {hotspot.density_current.gust_front_speed_kmh:.0f} km/h, CAPE: {hotspot.thermodynamics.cape_j_kg:.0f} J/kg. "
                f"Minimum visibility: {hotspot.density_current.minimum_visibility_m:.0f} m. {hotspot.aviation_grid.power_grid_risk}. "
                f"Valid for next {hotspot.nowcast_validity_hours} hours. Stay indoors away from electrical lines and tin sheds."
            ),
            "hi": (
                f"आईएमडी गंभीर तूफ़ान चेतावनी: {hotspot.hotspot_name} में {phenom} के लिए {stage} जारी किया गया है। "
                f"हवा की गति: {hotspot.density_current.gust_front_speed_kmh:.0f} किमी/घंटा, सीएपीई: {hotspot.thermodynamics.cape_j_kg:.0f} J/kg। "
                f"दृश्यता: {hotspot.density_current.minimum_visibility_m:.0f} मीटर। अगले {hotspot.nowcast_validity_hours} घंटे के लिए मान्य। "
                f"बिजली के खंभों और टीन की छतों से दूर सुरक्षित पक्के मकान में रहें।"
            ),
            "bn": (
                f"আইএমডি তীব্র কালবৈশাখী ও বজ্রঝড় সতর্কতা: {hotspot.hotspot_name}-এ {phenom} এর জন্য {stage} জারি করা হয়েছে। "
                f"ঝড়ের গতিবেগ: {hotspot.density_current.gust_front_speed_kmh:.0f} কিমি/ঘণ্টা, কেপ (CAPE): {hotspot.thermodynamics.cape_j_kg:.0f} J/kg। "
                f"দৃশ্যমানতা: {hotspot.density_current.minimum_visibility_m:.0f} মিটার। পরবর্তী {hotspot.nowcast_validity_hours} ঘণ্টার জন্য সতর্ক থাকুন। "
                f"গাছ ও বিদ্যুতের তারের নিচে আশ্রয় নেবেন না।"
            ),
            "or": (
                f"ଆଇଏମଡି ଭୀଷଣ କାଳବୈଶାଖୀ ସତର୍କତା: {hotspot.hotspot_name} ରେ {phenom} ପାଇଁ {stage} ଜାରି କରାଯାଇଛି। "
                f"ପବନର ବେଗ: {hotspot.density_current.gust_front_speed_kmh:.0f} କିମି/ଘଣ୍ଟା, ସର୍ବନିମ୍ନ ଦୃଶ୍ୟମାନତା: {hotspot.density_current.minimum_visibility_m:.0f} ମିଟର। "
                f"ଆଗାମୀ {hotspot.nowcast_validity_hours} ଘଣ୍ଟା ପାଇଁ ଘର ଭିତରେ ସୁରକ୍ଷିତ ରୁହନ୍ତୁ।"
            ),
            "as": (
                f"আইএমডি তীব্র বৰদৈচিলা ও ধুমুহা সতৰ্কবাণী: {hotspot.hotspot_name}ত {phenom}ৰ বাবে {stage} জাৰি কৰা হৈছে। "
                f"বতাহৰ গতিবেগ: {hotspot.density_current.gust_front_speed_kmh:.0f} কিমি/ঘণ্টা, দৃশ্যমানতা: {hotspot.density_current.minimum_visibility_m:.0f} মিটাৰ। "
                f"অহা {hotspot.nowcast_validity_hours} ঘণ্টাৰ বাবে সাৱধান হওক আৰু নিৰাপদ স্থানত আশ্ৰয় লওক।"
            ),
        }

    def get_convective_storm_assessment(
        self,
        latitude: Optional[float] = None,
        longitude: Optional[float] = None,
        hotspot_id: Optional[str] = None,
    ) -> ConvectiveStormResponse:
        """
        Resolves severe convective thunderstorm / Haboob nowcast by hotspot_id
        or geodetically matches the closest regional monitoring corridor.
        """
        selected_hotspot: ConvectiveStormHotspot

        if hotspot_id:
            match = next((h for h in self._hotspots if h.hotspot_id == hotspot_id), None)
            if match:
                selected_hotspot = match
            else:
                selected_hotspot = self._hotspots[0]
        elif latitude is not None and longitude is not None:
            selected_hotspot = min(
                self._hotspots,
                key=lambda h: _haversine_distance(latitude, longitude, h.latitude, h.longitude),
            )
        else:
            # Default to Kolkata Kalbaishakhi corridor
            selected_hotspot = self._hotspots[0]

        bulletins = self._generate_vernacular_bulletins(selected_hotspot)
        ref_no = f"IMD-SWFDP/NOWCAST/2026-ST-{datetime.now(timezone.utc).strftime('%m%d%H')}"

        return ConvectiveStormResponse(
            timestamp=datetime.now(timezone.utc).isoformat(),
            selected_hotspot=selected_hotspot,
            all_hotspots=self._hotspots,
            vernacular_bulletins=bulletins,
            imd_bulletin_reference=ref_no,
            provenance="India Meteorological Department (IMD) & WMO Severe Weather Forecasting Demonstration Project",
        )


convective_storm_service = ConvectiveStormService()
