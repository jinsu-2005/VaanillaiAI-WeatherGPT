import math
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional, Tuple

from app.schemas.wind_energy import (
    AtmosphericAirDensityProfile,
    CorridorSummary,
    HourlyWindForecast,
    HubHeightWindVector,
    RepoweringPotential,
    TurbineGenerationProfile,
    TurbineOperatingState,
    WeibullParameters,
    WindEnergyResponse,
    WindParkCorridor,
    WindResourceTier,
)


class WindEnergyService:
    """
    NIWE (National Institute of Wind Energy, Chennai) & IMD
    Wind Resource Assessment, Hub-Height Shear & Utility Wind Farm Generation Engine.
    """

    # 16-point compass directions
    CARDINAL_DIRECTIONS = [
        "N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
        "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"
    ]

    # Standard heights modeled across NIWE wind mast campaigns
    HUB_HEIGHTS_M = [10, 50, 80, 100, 120, 140, 150]

    # Curated Indian Wind Energy Corridors
    WIND_CORRIDORS_DB: Dict[str, Dict[str, Any]] = {
        "muppandal_tamil_nadu": {
            "corridor_id": "muppandal_tamil_nadu",
            "corridor_name": "Muppandal Wind Farm (Kanyakumari / Tirunelveli)",
            "state": "Tamil Nadu",
            "installed_capacity_mw": 1500.0,
            "latitude": 8.2433,
            "longitude": 77.5456,
            "elevation_m": 75.0,
            "terrain_roughness_alpha": 0.20,
            "surface_wind_10m_ms": 6.4,
            "surface_wind_dir_deg": 245.0,
            "surface_temp_c": 29.5,
            "surface_pressure_hpa": 1008.0,
            "weibull_k": 2.25,
            "weibull_c_ms": 8.2,
            "annual_mean_speed_ms": 7.3,
            "wake_loss_pct": 7.5,
            "bop_loss_pct": 3.0,
            "soiling_loss_pct": 1.5,
            "legacy_turbine_kw": 400.0,
            "legacy_hub_m": 45,
            "modern_turbine_mw": 3.0,
            "modern_hub_m": 140,
        },
        "jaisalmer_rajasthan": {
            "corridor_id": "jaisalmer_rajasthan",
            "corridor_name": "Jaisalmer Wind Park (Thar Desert)",
            "state": "Rajasthan",
            "installed_capacity_mw": 1064.0,
            "latitude": 26.9157,
            "longitude": 70.9083,
            "elevation_m": 225.0,
            "terrain_roughness_alpha": 0.16,
            "surface_wind_10m_ms": 5.8,
            "surface_wind_dir_deg": 220.0,
            "surface_temp_c": 38.0,
            "surface_pressure_hpa": 988.0,
            "weibull_k": 2.10,
            "weibull_c_ms": 7.4,
            "annual_mean_speed_ms": 6.6,
            "wake_loss_pct": 8.0,
            "bop_loss_pct": 3.2,
            "soiling_loss_pct": 2.8,
            "legacy_turbine_kw": 500.0,
            "legacy_hub_m": 50,
            "modern_turbine_mw": 2.7,
            "modern_hub_m": 130,
        },
        "brahmanvel_maharashtra": {
            "corridor_id": "brahmanvel_maharashtra",
            "corridor_name": "Brahmanvel Wind Farm (Dhule / Nandurbar Ridge)",
            "state": "Maharashtra",
            "installed_capacity_mw": 528.0,
            "latitude": 21.3650,
            "longitude": 74.3412,
            "elevation_m": 420.0,
            "terrain_roughness_alpha": 0.19,
            "surface_wind_10m_ms": 5.6,
            "surface_wind_dir_deg": 255.0,
            "surface_temp_c": 31.0,
            "surface_pressure_hpa": 968.0,
            "weibull_k": 2.05,
            "weibull_c_ms": 7.1,
            "annual_mean_speed_ms": 6.3,
            "wake_loss_pct": 7.2,
            "bop_loss_pct": 3.0,
            "soiling_loss_pct": 1.8,
            "legacy_turbine_kw": 350.0,
            "legacy_hub_m": 40,
            "modern_turbine_mw": 2.7,
            "modern_hub_m": 120,
        },
        "damanjodi_odisha": {
            "corridor_id": "damanjodi_odisha",
            "corridor_name": "Damanjodi Wind Corridor (Koraput Hilltop)",
            "state": "Odisha",
            "installed_capacity_mw": 99.0,
            "latitude": 18.7712,
            "longitude": 82.8624,
            "elevation_m": 910.0,
            "terrain_roughness_alpha": 0.22,
            "surface_wind_10m_ms": 5.4,
            "surface_wind_dir_deg": 210.0,
            "surface_temp_c": 26.5,
            "surface_pressure_hpa": 915.0,
            "weibull_k": 1.95,
            "weibull_c_ms": 6.8,
            "annual_mean_speed_ms": 6.0,
            "wake_loss_pct": 6.8,
            "bop_loss_pct": 2.8,
            "soiling_loss_pct": 1.4,
            "legacy_turbine_kw": 250.0,
            "legacy_hub_m": 35,
            "modern_turbine_mw": 2.0,
            "modern_hub_m": 100,
        },
        "kayathar_tamil_nadu": {
            "corridor_id": "kayathar_tamil_nadu",
            "corridor_name": "Kayathar Wind Corridor (NIWE Test Station, Thoothukudi)",
            "state": "Tamil Nadu",
            "installed_capacity_mw": 300.0,
            "latitude": 8.9520,
            "longitude": 77.7710,
            "elevation_m": 95.0,
            "terrain_roughness_alpha": 0.18,
            "surface_wind_10m_ms": 6.1,
            "surface_wind_dir_deg": 260.0,
            "surface_temp_c": 30.5,
            "surface_pressure_hpa": 1005.0,
            "weibull_k": 2.20,
            "weibull_c_ms": 7.9,
            "annual_mean_speed_ms": 7.0,
            "wake_loss_pct": 7.0,
            "bop_loss_pct": 2.9,
            "soiling_loss_pct": 1.6,
            "legacy_turbine_kw": 350.0,
            "legacy_hub_m": 45,
            "modern_turbine_mw": 3.0,
            "modern_hub_m": 140,
        },
        "kutch_gujarat": {
            "corridor_id": "kutch_gujarat",
            "corridor_name": "Kutch Wind Corridor (Janki / Mandvi / Bhuj Coastal Belt)",
            "state": "Gujarat",
            "installed_capacity_mw": 1100.0,
            "latitude": 23.2420,
            "longitude": 69.6669,
            "elevation_m": 35.0,
            "terrain_roughness_alpha": 0.14,
            "surface_wind_10m_ms": 5.9,
            "surface_wind_dir_deg": 235.0,
            "surface_temp_c": 33.0,
            "surface_pressure_hpa": 1009.0,
            "weibull_k": 2.15,
            "weibull_c_ms": 7.6,
            "annual_mean_speed_ms": 6.8,
            "wake_loss_pct": 7.8,
            "bop_loss_pct": 3.1,
            "soiling_loss_pct": 2.2,
            "legacy_turbine_kw": 500.0,
            "legacy_hub_m": 50,
            "modern_turbine_mw": 3.0,
            "modern_hub_m": 140,
        },
        "chitradurga_karnataka": {
            "corridor_id": "chitradurga_karnataka",
            "corridor_name": "Chitradurga Wind Park (Central Deccan Ridge)",
            "state": "Karnataka",
            "installed_capacity_mw": 400.0,
            "latitude": 14.2251,
            "longitude": 76.4022,
            "elevation_m": 730.0,
            "terrain_roughness_alpha": 0.19,
            "surface_wind_10m_ms": 5.5,
            "surface_wind_dir_deg": 250.0,
            "surface_temp_c": 28.0,
            "surface_pressure_hpa": 932.0,
            "weibull_k": 2.08,
            "weibull_c_ms": 7.0,
            "annual_mean_speed_ms": 6.2,
            "wake_loss_pct": 7.4,
            "bop_loss_pct": 3.0,
            "soiling_loss_pct": 1.7,
            "legacy_turbine_kw": 350.0,
            "legacy_hub_m": 40,
            "modern_turbine_mw": 2.7,
            "modern_hub_m": 120,
        },
    }

    @classmethod
    def get_cardinal_direction(cls, degrees: float) -> str:
        """Converts wind azimuth degrees (0-360) into 16-point cardinal compass text."""
        val = int((degrees / 22.5) + 0.5)
        return cls.CARDINAL_DIRECTIONS[val % 16]

    @classmethod
    def calculate_power_law_speed(cls, v10: float, height_m: int, alpha: float) -> float:
        """
        Extrapolates wind speed to height z using Hellmann power-law:
        v(z) = v(10) * (z / 10)^alpha
        """
        if height_m <= 10:
            return round(v10, 2)
        ratio = height_m / 10.0
        v_z = v10 * math.pow(ratio, alpha)
        return round(v_z, 2)

    @classmethod
    def calculate_atmospheric_air_density(
        cls, surface_temp_c: float, surface_pressure_hpa: float, height_m: int
    ) -> Tuple[float, float, str]:
        """
        Calculates dry air density rho(z) at hub height:
        rho = (P * 100) / (R_d * (T + 273.15))
        where R_d = 287.05 J/(kg*K).
        Accounts for standard tropospheric lapse rate (-6.5 C/km).
        """
        # Lapse rate adjustment
        t_z_c = surface_temp_c - (0.0065 * height_m)
        # Barometric height adjustment
        p_z_hpa = surface_pressure_hpa * math.pow(1.0 - (0.0000225577 * height_m), 5.25588)
        
        t_kelvin = t_z_c + 273.15
        p_pascals = p_z_hpa * 100.0
        r_d = 287.05

        rho = p_pascals / (r_d * t_kelvin)
        rho = round(rho, 3)
        density_ratio = round(rho / 1.225, 3)

        if density_ratio < 0.90:
            note = f"High ambient heat/altitude reduces air density to {rho} kg/m³ ({round((1 - density_ratio) * 100, 1)}% kinetic flux penalty vs ISO standard)."
        elif density_ratio < 0.96:
            note = f"Moderate thermal air thinning ({rho} kg/m³), resulting in {round((1 - density_ratio) * 100, 1)}% aerodynamic derating."
        else:
            note = f"Favorable high air density ({rho} kg/m³) provides robust momentum transfer and optimal blade lift."

        return rho, density_ratio, note

    @classmethod
    def classify_wind_resource_tier(cls, wpd_wm2: float) -> WindResourceTier:
        """Classifies Wind Power Density (WPD) according to NIWE / MNRE Indian standards."""
        if wpd_wm2 >= 500.0:
            return WindResourceTier.OUTSTANDING
        elif wpd_wm2 >= 400.0:
            return WindResourceTier.EXCELLENT
        elif wpd_wm2 >= 300.0:
            return WindResourceTier.GOOD
        elif wpd_wm2 >= 250.0:
            return WindResourceTier.MODERATE
        elif wpd_wm2 >= 200.0:
            return WindResourceTier.MARGINAL
        else:
            return WindResourceTier.POOR

    @classmethod
    def calculate_wind_power_density(cls, wind_speed_ms: float, air_density_kgm3: float) -> float:
        """
        WPD = 0.5 * rho * v^3 in W/m^2
        """
        wpd = 0.5 * air_density_kgm3 * math.pow(wind_speed_ms, 3)
        return round(wpd, 1)

    @classmethod
    def evaluate_turbine_power(
        cls,
        model_name: str,
        rated_mw: float,
        rotor_diam_m: float,
        hub_m: int,
        wind_speed_ms: float,
        air_density_kgm3: float,
        wake_loss_pct: float,
        bop_loss_pct: float,
        soiling_loss_pct: float,
        cut_in_ms: float = 3.0,
        rated_ms: float = 11.5,
        cut_out_ms: float = 25.0,
    ) -> TurbineGenerationProfile:
        """
        Computes power curve state, gross aerodynamic power, BoP losses,
        net electrical output, and plant Capacity Utilization Factor (CUF %).
        """
        density_factor = air_density_kgm3 / 1.225

        if wind_speed_ms < cut_in_ms:
            state = TurbineOperatingState.BELOW_CUT_IN
            gross_mw = 0.0
        elif wind_speed_ms >= cut_out_ms:
            state = TurbineOperatingState.STORM_CUT_OUT
            gross_mw = 0.0
        elif wind_speed_ms >= rated_ms:
            state = TurbineOperatingState.RATED_FULL_LOAD
            gross_mw = rated_mw
        else:
            state = TurbineOperatingState.PARTIAL_LOAD_RAMP
            # Cubic interpolation between cut-in and rated
            cubic_term = (math.pow(wind_speed_ms, 3) - math.pow(cut_in_ms, 3)) / (
                math.pow(rated_ms, 3) - math.pow(cut_in_ms, 3)
            )
            gross_mw = rated_mw * cubic_term * density_factor
            gross_mw = min(gross_mw, rated_mw)

        gross_mw = round(gross_mw, 3)

        # Apply balance of plant, wake, and soiling loss chain
        loss_multiplier = (
            (1.0 - (wake_loss_pct / 100.0))
            * (1.0 - (bop_loss_pct / 100.0))
            * (1.0 - (soiling_loss_pct / 100.0))
        )
        net_mw = round(gross_mw * loss_multiplier, 3)
        daily_mwh = round(net_mw * 24.0, 2)
        cuf_pct = round((net_mw / rated_mw) * 100.0, 1) if rated_mw > 0 else 0.0

        return TurbineGenerationProfile(
            model_name=model_name,
            rated_power_mw=rated_mw,
            rotor_diameter_m=rotor_diam_m,
            hub_height_m=hub_m,
            cut_in_speed_ms=cut_in_ms,
            rated_speed_ms=rated_ms,
            cut_out_speed_ms=cut_out_ms,
            operating_state=state,
            gross_hourly_output_mw=gross_mw,
            wake_loss_pct=wake_loss_pct,
            bop_electrical_loss_pct=bop_loss_pct,
            blade_soiling_loss_pct=soiling_loss_pct,
            net_hourly_output_mw=net_mw,
            daily_generation_mwh=daily_mwh,
            capacity_utilization_factor_pct=cuf_pct,
        )

    @classmethod
    def compute_repowering_potential(
        cls,
        legacy_kw: float,
        legacy_hub_m: int,
        modern_mw: float,
        modern_hub_m: int,
        v10: float,
        alpha: float,
    ) -> RepoweringPotential:
        """
        Evaluates MNRE Wind Repowering Policy opportunity by comparing
        sub-MW legacy turbine generation against a modern 2.7-3.0 MW turbine on the same footprint.
        """
        v_legacy = cls.calculate_power_law_speed(v10, legacy_hub_m, alpha)
        v_modern = cls.calculate_power_law_speed(v10, modern_hub_m, alpha)

        # Kinetic energy ratio per swept area * capacity expansion factor
        speed_ratio = v_modern / max(v_legacy, 1.0)
        energy_multiplier = round((modern_mw / (legacy_kw / 1000.0)) * 0.45 * math.pow(speed_ratio, 2.2), 1)
        energy_multiplier = max(2.2, min(energy_multiplier, 4.2))

        # Incremental MWh/year * 0.82 tons CO2/MWh
        incremental_annual_mwh = (modern_mw * 2800.0) - ((legacy_kw / 1000.0) * 1800.0)
        co2_tons = round(max(500.0, incremental_annual_mwh * 0.82), 0)

        priority = "HIGH" if energy_multiplier >= 3.0 else ("MODERATE" if energy_multiplier >= 2.5 else "OPTIMIZED")

        return RepoweringPotential(
            legacy_turbine_rating_kw=legacy_kw,
            modern_turbine_rating_mw=modern_mw,
            energy_yield_multiplier=energy_multiplier,
            co2_abatement_tons_yr=co2_tons,
            repowering_priority=priority,
        )

    @classmethod
    def generate_hourly_forecast(
        cls, base_speed_100m: float, base_dir: float, modern_cuf: float
    ) -> List[HourlyWindForecast]:
        """
        Generates 24-hour diurnal wind and generation curve (diurnal peak in afternoon/evening).
        """
        forecast: List[HourlyWindForecast] = []
        diurnal_weights = [
            0.88, 0.85, 0.82, 0.80, 0.83, 0.87,
            0.92, 0.98, 1.04, 1.10, 1.14, 1.16,
            1.18, 1.20, 1.19, 1.15, 1.12, 1.08,
            1.04, 1.00, 0.96, 0.93, 0.90, 0.89
        ]
        hours = [f"{h:02d}:00" for h in range(24)]

        for i, h in enumerate(hours):
            w = diurnal_weights[i]
            speed = round(base_speed_100m * w, 1)
            direction = round((base_dir + ((i - 12) * 1.5)) % 360, 0)
            cuf = round(max(0.0, min(95.0, modern_cuf * math.pow(w, 2.5))), 1)
            # 100 MW representative park net generation
            net_mw = round(100.0 * (cuf / 100.0), 1)

            forecast.append(
                HourlyWindForecast(
                    hour=h,
                    wind_speed_100m_ms=speed,
                    wind_direction_deg=direction,
                    expected_net_mw=net_mw,
                    cuf_pct=cuf,
                )
            )

        return forecast

    @classmethod
    def find_nearest_corridor(cls, lat: float, lon: float) -> str:
        """Finds closest wind corridor using the Haversine great-circle distance."""
        def haversine(lat1, lon1, lat2, lon2):
            r = 6371.0
            dlat = math.radians(lat2 - lat1)
            dlon = math.radians(lon2 - lon1)
            a = math.sin(dlat / 2.0) ** 2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2.0) ** 2
            c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
            return r * c

        best_corridor = "muppandal_tamil_nadu"
        min_dist = float("inf")

        for c_id, data in cls.WIND_CORRIDORS_DB.items():
            dist = haversine(lat, lon, data["latitude"], data["longitude"])
            if dist < min_dist:
                min_dist = dist
                best_corridor = c_id

        return best_corridor

    @classmethod
    def generate_vernacular_bulletins(
        cls, corridor: WindParkCorridor, ref_vector: HubHeightWindVector, modern_turb: TurbineGenerationProfile
    ) -> Dict[str, str]:
        """Generates regional language operational advisories in 7 languages."""
        name = corridor.corridor_name
        speed = ref_vector.wind_speed_ms
        wpd = ref_vector.wind_power_density_wm2
        tier = ref_vector.resource_tier.value
        cuf = modern_turb.capacity_utilization_factor_pct

        return {
            "en": (
                f"NIWE-IMD WIND BULLETIN for {name}: 100m hub wind speed at {speed} m/s ({ref_vector.cardinal_direction}), "
                f"yielding {wpd} W/m² (Resource: {tier}). Projected plant Capacity Utilization Factor (CUF) is {cuf}%. "
                f"Turbine operating status: {modern_turb.operating_state.value}. Grid dispatch is optimal."
            ),
            "ta": (
                f"தேசிய காற்று ஆற்றல் நிறுவனம் (NIWE) & IMD அறிக்கை - {name}: 100 மீட்டர் உயரக் காற்றில் வேகம் {speed} மீ/வி "
                f"({ref_vector.cardinal_direction}), காற்று சக்தி அடர்த்தி {wpd} W/m² ({tier} தரம்). "
                f"எதிர்பார்க்கப்படும் ஆலை பயன்பாட்டுக் காரணி (CUF) {cuf}%. காற்றாலை மின் உற்பத்தி சீராக உள்ளது."
            ),
            "hi": (
                f"एनआईडब्ल्यूई-आईएमडी पवन ऊर्जा बुलेटिन - {name}: 100 मीटर हब ऊंचाई पर वायु गति {speed} मी/से "
                f"({ref_vector.cardinal_direction}), पवन ऊर्जा घनत्व {wpd} W/m² ({tier} श्रेणी)। "
                f"अनुमानित संयंत्र क्षमता उपयोग कारक (CUF) {cuf}% है। ग्रिड प्रेषण अनुकूल स्थिति में है।"
            ),
            "gu": (
                f"NIWE-IMD પવન ઊર્જા બુલેટિન - {name}: 100 મીટર હબ ઊંચાઈએ પવન ગતિ {speed} મી/સે "
                f"({ref_vector.cardinal_direction}), પવન શક્તિ ઘનતા {wpd} W/m² ({tier} વર્ગ). "
                f"પ્લાન્ટ ક્ષમતા ઉપયોગ પરિબળ (CUF) {cuf}% છે. વીજ ઉત્પાદન ઉત્તમ છે."
            ),
            "mr": (
                f"NIWE-IMD पवन ऊर्जा बुलेटिन - {name}: 100 मीटर हब उंचीवर हवेचा वेग {speed} मी/से "
                f"({ref_vector.cardinal_direction}), पवन ऊर्जा घनता {wpd} W/m² ({tier} दर्जा). "
                f"अपेक्षित क्षमता वापर घटक (CUF) {cuf}% आहे. पवनचक्की वीज निर्मिती सुरळीत सुरू आहे."
            ),
            "kn": (
                f"ರಾಷ್ಟ್ರೀಯ ಪವನ ಶಕ್ತಿ ಸಂಸ್ಥೆ (NIWE) & IMD ವರದಿ - {name}: 100 ಮೀಟರ್ ಎತ್ತರದ ಹಬ್ ವೇಗ {speed} ಮೀ/ಸೆ "
                f"({ref_vector.cardinal_direction}), ಪವನ ಶಕ್ತಿ ಸಾಂದ್ರತೆ {wpd} W/m² ({tier} ದರ್ಜೆ). "
                f"ನಿರೀಕ್ಷಿತ ಘಟಕ ಸಾಮರ್ಥ್ಯ ಬಳಕೆಯ ಅಂಶ (CUF) {cuf}%. ಗ್ರಿಡ್ ವಿದ್ಯುತ್ ಉತ್ಪಾದನೆ ಸುಸ್ಥಿತಿಯಲ್ಲಿದೆ."
            ),
            "od": (
                f"NIWE-IMD ପବନ ଶକ୍ତି ବୁଲେଟିନ୍ - {name}: 100 ମିଟର ଉଚ୍ଚତାରେ ପବନର ବେଗ {speed} ମି/ସେ "
                f"({ref_vector.cardinal_direction}), ପବନ ଶକ୍ତି ଘନତା {wpd} W/m² ({tier} ଶ୍ରେଣୀ). "
                f"ଆନୁମାନିକ କ୍ଷମତା ଉପଯୋଗ କାରକ (CUF) {cuf}% ଅଟେ । ଗ୍ରୀଡ୍ ଉତ୍ପାଦନ ସନ୍ତୋଷଜନକ ଅଛି ।"
            ),
        }

    @classmethod
    def get_assessment(
        cls, corridor_id: Optional[str] = None, latitude: Optional[float] = None, longitude: Optional[float] = None
    ) -> WindEnergyResponse:
        """
        Executes full aerodynamic assessment, hub-height shear profile,
        turbine generation calculations, and multi-lingual bulletins.
        """
        # 1. Resolve corridor
        if corridor_id and corridor_id in cls.WIND_CORRIDORS_DB:
            target_id = corridor_id
        elif latitude is not None and longitude is not None:
            target_id = cls.find_nearest_corridor(latitude, longitude)
        else:
            target_id = "muppandal_tamil_nadu"

        raw = cls.WIND_CORRIDORS_DB[target_id]

        v10 = raw["surface_wind_10m_ms"]
        dir10 = raw["surface_wind_dir_deg"]
        alpha = raw["terrain_roughness_alpha"]
        t_surf = raw["surface_temp_c"]
        p_surf = raw["surface_pressure_hpa"]

        # 2. Compute air density at 100m reference hub
        rho_100, dens_ratio, dens_note = cls.calculate_atmospheric_air_density(t_surf, p_surf, 100)

        density_profile = AtmosphericAirDensityProfile(
            surface_temperature_c=t_surf,
            surface_pressure_hpa=p_surf,
            air_density_kgm3=rho_100,
            standard_density_kgm3=1.225,
            density_ratio=dens_ratio,
            thermal_derating_note=dens_note,
        )

        # 3. Calculate hub-height vectors across standard heights
        hub_vectors: List[HubHeightWindVector] = []
        for h in cls.HUB_HEIGHTS_M:
            speed_ms = cls.calculate_power_law_speed(v10, h, alpha)
            speed_kmh = round(speed_ms * 3.6, 1)
            # Local density at height h
            rho_h, _, _ = cls.calculate_atmospheric_air_density(t_surf, p_surf, h)
            wpd = cls.calculate_wind_power_density(speed_ms, rho_h)
            tier = cls.classify_wind_resource_tier(wpd)
            # Slight veering with height due to Coriolis effect (Ekman spiral ~ +0.05 deg/m)
            dir_h = round((dir10 + (0.05 * (h - 10))) % 360, 1)
            cardinal = cls.get_cardinal_direction(dir_h)

            hub_vectors.append(
                HubHeightWindVector(
                    height_m=h,
                    wind_speed_ms=speed_ms,
                    wind_speed_kmh=speed_kmh,
                    wind_power_density_wm2=wpd,
                    wind_direction_deg=dir_h,
                    cardinal_direction=cardinal,
                    resource_tier=tier,
                )
            )

        # Reference vector at 100m
        ref_100m = next(v for v in hub_vectors if v.height_m == 100)

        # 4. Evaluate utility-scale turbine generation profiles
        # Profile A: Standard utility turbine (2.0 MW @ 100m hub, 100m rotor)
        turb_2mw = cls.evaluate_turbine_power(
            model_name="Standard Utility 2.0 MW Class (Rotor 100m)",
            rated_mw=2.0,
            rotor_diam_m=100.0,
            hub_m=100,
            wind_speed_ms=ref_100m.wind_speed_ms,
            air_density_kgm3=rho_100,
            wake_loss_pct=raw["wake_loss_pct"],
            bop_loss_pct=raw["bop_loss_pct"],
            soiling_loss_pct=raw["soiling_loss_pct"],
            cut_in_ms=3.0,
            rated_ms=11.5,
            cut_out_ms=25.0,
        )

        # Profile B: Advanced low-wind turbine (3.0 MW @ 140m hub, 140m rotor)
        ref_140m = next(v for v in hub_vectors if v.height_m == 140)
        rho_140, _, _ = cls.calculate_atmospheric_air_density(t_surf, p_surf, 140)
        turb_3mw = cls.evaluate_turbine_power(
            model_name="Next-Gen Low-Wind 3.0 MW Class (Rotor 140m)",
            rated_mw=3.0,
            rotor_diam_m=140.0,
            hub_m=140,
            wind_speed_ms=ref_140m.wind_speed_ms,
            air_density_kgm3=rho_140,
            wake_loss_pct=raw["wake_loss_pct"] * 0.95,  # Better pitch control
            bop_loss_pct=raw["bop_loss_pct"],
            soiling_loss_pct=raw["soiling_loss_pct"],
            cut_in_ms=2.8,
            rated_ms=10.5,
            cut_out_ms=25.0,
        )

        # 5. Repowering analysis
        repowering = cls.compute_repowering_potential(
            legacy_kw=raw["legacy_turbine_kw"],
            legacy_hub_m=raw["legacy_hub_m"],
            modern_mw=raw["modern_turbine_mw"],
            modern_hub_m=raw["modern_hub_m"],
            v10=v10,
            alpha=alpha,
        )

        # 6. Hourly forecast
        hourly = cls.generate_hourly_forecast(
            ref_100m.wind_speed_ms, dir10, turb_3mw.capacity_utilization_factor_pct
        )

        # 7. Construct selected corridor model
        selected = WindParkCorridor(
            corridor_id=raw["corridor_id"],
            corridor_name=raw["corridor_name"],
            state=raw["state"],
            installed_capacity_mw=raw["installed_capacity_mw"],
            latitude=raw["latitude"],
            longitude=raw["longitude"],
            elevation_m=raw["elevation_m"],
            terrain_roughness_alpha=alpha,
            resource_tier=ref_100m.resource_tier,
            surface_wind_10m_ms=v10,
            surface_wind_dir_deg=dir10,
            air_density=density_profile,
            weibull=WeibullParameters(
                shape_k=raw["weibull_k"],
                scale_c_ms=raw["weibull_c_ms"],
                annual_mean_speed_ms=raw["annual_mean_speed_ms"],
            ),
            hub_height_profiles=hub_vectors,
            turbine_profiles=[turb_2mw, turb_3mw],
            repowering=repowering,
            hourly_forecast=hourly,
        )

        # 8. Summary list of all corridors
        summaries: List[CorridorSummary] = []
        for c_id, c_data in cls.WIND_CORRIDORS_DB.items():
            s_v10 = c_data["surface_wind_10m_ms"]
            s_alpha = c_data["terrain_roughness_alpha"]
            s_speed_100 = cls.calculate_power_law_speed(s_v10, 100, s_alpha)
            s_rho, _, _ = cls.calculate_atmospheric_air_density(c_data["surface_temp_c"], c_data["surface_pressure_hpa"], 100)
            s_wpd = cls.calculate_wind_power_density(s_speed_100, s_rho)
            s_tier = cls.classify_wind_resource_tier(s_wpd)
            # Estimate representative 100m CUF
            s_cuf = round(min(52.0, max(18.0, (s_wpd / 10.5))), 1)

            summaries.append(
                CorridorSummary(
                    corridor_id=c_id,
                    corridor_name=c_data["corridor_name"],
                    state=c_data["state"],
                    installed_capacity_mw=c_data["installed_capacity_mw"],
                    resource_tier=s_tier,
                    reference_speed_100m_ms=s_speed_100,
                    reference_wpd_100m_wm2=s_wpd,
                    cuf_pct=s_cuf,
                )
            )

        # 9. Bulletins
        bulletins = cls.generate_vernacular_bulletins(selected, ref_100m, turb_3mw)

        return WindEnergyResponse(
            selected_corridor=selected,
            all_corridors=summaries,
            bulletins=bulletins,
            offline_cached=False,
            generated_at=datetime.now(timezone.utc).isoformat(),
        )
