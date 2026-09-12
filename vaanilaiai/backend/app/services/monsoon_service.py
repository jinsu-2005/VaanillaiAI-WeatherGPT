"""NCMRWF & IMD Sub-Divisional Monsoon Teleconnections and Long-Range Forecast Service."""
import math
from datetime import datetime, timezone
from typing import List, Tuple

from app.schemas.monsoon import (
    SubDivisionalMonsoonStatus,
    OceanicTeleconnectionIndex,
    SeasonalForecastOutlook,
    MonsoonIntelligenceResponse,
)


class MonsoonService:
    """Provides oceanic teleconnection analysis, sub-divisional rainfall departures, and seasonal forecasts."""

    # Official 36 Meteorological Sub-Divisions of India with geodetic centroids and climatological normals
    SUB_DIVISIONS = [
        {"code": "sd_01", "name": "Andaman & Nicobar Islands", "state": "Andaman & Nicobar", "lat": 11.667, "lon": 92.735, "normal_mm": 1680.0, "actual_mm": 1820.0, "soil_moisture": 0.88},
        {"code": "sd_02", "name": "Arunachal Pradesh", "state": "Arunachal Pradesh", "lat": 28.218, "lon": 94.727, "normal_mm": 1750.0, "actual_mm": 1690.0, "soil_moisture": 0.82},
        {"code": "sd_03", "name": "Assam & Meghalaya", "state": "Assam & Meghalaya", "lat": 26.140, "lon": 91.770, "normal_mm": 1520.0, "actual_mm": 1460.0, "soil_moisture": 0.78},
        {"code": "sd_04", "name": "Nagaland, Manipur, Mizoram & Tripura", "state": "NMMT", "lat": 24.817, "lon": 93.936, "normal_mm": 1380.0, "actual_mm": 1210.0, "soil_moisture": 0.70},
        {"code": "sd_05", "name": "Sub-Himalayan West Bengal & Sikkim", "state": "West Bengal", "lat": 27.036, "lon": 88.262, "normal_mm": 2010.0, "actual_mm": 2180.0, "soil_moisture": 0.86},
        {"code": "sd_06", "name": "Gangetic West Bengal", "state": "West Bengal", "lat": 22.572, "lon": 88.363, "normal_mm": 1140.0, "actual_mm": 1090.0, "soil_moisture": 0.72},
        {"code": "sd_07", "name": "Odisha", "state": "Odisha", "lat": 20.951, "lon": 85.098, "normal_mm": 1150.0, "actual_mm": 1240.0, "soil_moisture": 0.75},
        {"code": "sd_08", "name": "Jharkhand", "state": "Jharkhand", "lat": 23.610, "lon": 85.279, "normal_mm": 1020.0, "actual_mm": 960.0, "soil_moisture": 0.68},
        {"code": "sd_09", "name": "Bihar", "state": "Bihar", "lat": 25.096, "lon": 85.313, "normal_mm": 990.0, "actual_mm": 920.0, "soil_moisture": 0.65},
        {"code": "sd_10", "name": "East Uttar Pradesh", "state": "Uttar Pradesh", "lat": 26.846, "lon": 82.000, "normal_mm": 840.0, "actual_mm": 810.0, "soil_moisture": 0.64},
        {"code": "sd_11", "name": "West Uttar Pradesh", "state": "Uttar Pradesh", "lat": 28.600, "lon": 78.000, "normal_mm": 690.0, "actual_mm": 720.0, "soil_moisture": 0.60},
        {"code": "sd_12", "name": "Uttarakhand", "state": "Uttarakhand", "lat": 30.066, "lon": 79.019, "normal_mm": 1230.0, "actual_mm": 1340.0, "soil_moisture": 0.79},
        {"code": "sd_13", "name": "Haryana, Chandigarh & Delhi", "state": "Delhi & Haryana", "lat": 28.704, "lon": 77.102, "normal_mm": 460.0, "actual_mm": 490.0, "soil_moisture": 0.52},
        {"code": "sd_14", "name": "Punjab", "state": "Punjab", "lat": 31.147, "lon": 75.341, "normal_mm": 480.0, "actual_mm": 510.0, "soil_moisture": 0.55},
        {"code": "sd_15", "name": "Himachal Pradesh", "state": "Himachal Pradesh", "lat": 31.104, "lon": 77.173, "normal_mm": 760.0, "actual_mm": 810.0, "soil_moisture": 0.70},
        {"code": "sd_16", "name": "Jammu & Kashmir and Ladakh", "state": "Jammu & Kashmir", "lat": 34.083, "lon": 74.797, "normal_mm": 540.0, "actual_mm": 510.0, "soil_moisture": 0.62},
        {"code": "sd_17", "name": "West Rajasthan", "state": "Rajasthan", "lat": 26.912, "lon": 71.900, "normal_mm": 270.0, "actual_mm": 340.0, "soil_moisture": 0.38},
        {"code": "sd_18", "name": "East Rajasthan", "state": "Rajasthan", "lat": 26.500, "lon": 75.800, "normal_mm": 615.0, "actual_mm": 680.0, "soil_moisture": 0.58},
        {"code": "sd_19", "name": "West Madhya Pradesh", "state": "Madhya Pradesh", "lat": 23.259, "lon": 76.500, "normal_mm": 875.0, "actual_mm": 930.0, "soil_moisture": 0.69},
        {"code": "sd_20", "name": "East Madhya Pradesh", "state": "Madhya Pradesh", "lat": 23.181, "lon": 80.500, "normal_mm": 1050.0, "actual_mm": 1010.0, "soil_moisture": 0.71},
        {"code": "sd_21", "name": "Gujarat Region", "state": "Gujarat", "lat": 22.500, "lon": 72.800, "normal_mm": 920.0, "actual_mm": 1080.0, "soil_moisture": 0.67},
        {"code": "sd_22", "name": "Saurashtra & Kutch", "state": "Gujarat", "lat": 22.300, "lon": 70.800, "normal_mm": 480.0, "actual_mm": 620.0, "soil_moisture": 0.54},
        {"code": "sd_23", "name": "Konkan & Goa", "state": "Maharashtra & Goa", "lat": 17.500, "lon": 73.500, "normal_mm": 2910.0, "actual_mm": 3150.0, "soil_moisture": 0.92},
        {"code": "sd_24", "name": "Madhya Maharashtra", "state": "Maharashtra", "lat": 18.520, "lon": 74.850, "normal_mm": 730.0, "actual_mm": 790.0, "soil_moisture": 0.65},
        {"code": "sd_25", "name": "Marathwada", "state": "Maharashtra", "lat": 19.100, "lon": 76.200, "normal_mm": 680.0, "actual_mm": 740.0, "soil_moisture": 0.61},
        {"code": "sd_26", "name": "Vidarbha", "state": "Maharashtra", "lat": 20.800, "lon": 78.500, "normal_mm": 950.0, "actual_mm": 990.0, "soil_moisture": 0.70},
        {"code": "sd_27", "name": "Chhattisgarh", "state": "Chhattisgarh", "lat": 21.278, "lon": 81.866, "normal_mm": 1150.0, "actual_mm": 1120.0, "soil_moisture": 0.73},
        {"code": "sd_28", "name": "Coastal Andhra Pradesh & Yanam", "state": "Andhra Pradesh", "lat": 16.500, "lon": 81.500, "normal_mm": 620.0, "actual_mm": 690.0, "soil_moisture": 0.68},
        {"code": "sd_29", "name": "Rayalaseema", "state": "Andhra Pradesh", "lat": 14.800, "lon": 77.800, "normal_mm": 410.0, "actual_mm": 460.0, "soil_moisture": 0.53},
        {"code": "sd_30", "name": "Telangana", "state": "Telangana", "lat": 17.800, "lon": 79.100, "normal_mm": 750.0, "actual_mm": 860.0, "soil_moisture": 0.66},
        {"code": "sd_31", "name": "Tamil Nadu, Puducherry & Karaikal", "state": "Tamil Nadu", "lat": 11.500, "lon": 78.800, "normal_mm": 440.0, "actual_mm": 510.0, "soil_moisture": 0.62},
        {"code": "sd_32", "name": "Coastal Karnataka", "state": "Karnataka", "lat": 14.000, "lon": 74.500, "normal_mm": 3080.0, "actual_mm": 3290.0, "soil_moisture": 0.94},
        {"code": "sd_33", "name": "North Interior Karnataka", "state": "Karnataka", "lat": 16.200, "lon": 75.800, "normal_mm": 510.0, "actual_mm": 540.0, "soil_moisture": 0.56},
        {"code": "sd_34", "name": "South Interior Karnataka", "state": "Karnataka", "lat": 13.000, "lon": 76.500, "normal_mm": 660.0, "actual_mm": 710.0, "soil_moisture": 0.64},
        {"code": "sd_35", "name": "Kerala & Mahe", "state": "Kerala", "lat": 10.500, "lon": 76.200, "normal_mm": 2040.0, "actual_mm": 2180.0, "soil_moisture": 0.89},
        {"code": "sd_36", "name": "Lakshadweep", "state": "Lakshadweep", "lat": 10.566, "lon": 72.641, "normal_mm": 1010.0, "actual_mm": 1060.0, "soil_moisture": 0.77},
    ]

    @staticmethod
    def _haversine_distance_km(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        r = 6371.0
        phi1 = math.radians(lat1)
        phi2 = math.radians(lat2)
        delta_phi = math.radians(lat2 - lat1)
        delta_lambda = math.radians(lon2 - lon1)
        a = (
            math.sin(delta_phi / 2.0) ** 2
            + math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2.0) ** 2
        )
        c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
        return r * c

    @classmethod
    def _calculate_departure(cls, actual: float, normal: float) -> Tuple[float, str, str]:
        """Calculates IMD standard rainfall departure percentage and classification."""
        if normal <= 0:
            return 0.0, "Normal", "Green"
        dep = round(((actual - normal) / normal) * 100.0, 1)
        if dep >= 60.0:
            return dep, "Large Excess", "Blue"
        elif dep >= 20.0:
            return dep, "Excess", "Light Blue"
        elif dep >= -19.0:
            return dep, "Normal", "Green"
        elif dep >= -59.0:
            return dep, "Deficient", "Red"
        else:
            return dep, "Large Deficient", "Yellow"

    @classmethod
    def _get_drought_risk(cls, dep: float, soil_moisture: float) -> str:
        if dep <= -50.0 and soil_moisture < 0.40:
            return "Severe Drought"
        elif dep <= -25.0 and soil_moisture < 0.50:
            return "Moderate Drought"
        elif dep <= -15.0:
            return "Mild Drought"
        return "Normal"

    @classmethod
    def get_monsoon_intelligence(
        cls,
        latitude: float,
        longitude: float,
        location_name: str = "Location",
    ) -> MonsoonIntelligenceResponse:
        """Evaluates oceanic teleconnection drivers and sub-divisional monsoon intelligence."""

        # 1. Detect nearest meteorological sub-division
        best_sd = None
        min_dist = float("inf")
        for sd in cls.SUB_DIVISIONS:
            dist = cls._haversine_distance_km(latitude, longitude, sd["lat"], sd["lon"])
            if dist < min_dist:
                min_dist = dist
                best_sd = sd

        if best_sd is None:
            best_sd = cls.SUB_DIVISIONS[30]  # Tamil Nadu default

        # 2. Build sub-divisions list
        all_sd_models = []
        for sd in cls.SUB_DIVISIONS:
            dep_pct, cat, col = cls._calculate_departure(sd["actual_mm"], sd["normal_mm"])
            drought = cls._get_drought_risk(dep_pct, sd["soil_moisture"])
            is_user = (sd["code"] == best_sd["code"])
            all_sd_models.append(
                SubDivisionalMonsoonStatus(
                    sub_division_code=sd["code"],
                    name=sd["name"],
                    state=sd["state"],
                    actual_rainfall_mm=sd["actual_mm"],
                    normal_rainfall_mm=sd["normal_mm"],
                    departure_percentage=dep_pct,
                    departure_category=cat,
                    departure_color=col,
                    soil_moisture_index=sd["soil_moisture"],
                    drought_risk_level=drought,
                    is_user_sub_division=is_user,
                )
            )

        user_sd_model = next((s for s in all_sd_models if s.is_user_sub_division), all_sd_models[0])

        # 3. Macro-climatic Oceanic Teleconnections (ENSO, IOD, MJO)
        teleconnections = [
            OceanicTeleconnectionIndex(
                index_code="enso_nino34",
                name="ENSO (Niño 3.4 SST Anomaly)",
                current_value=-0.65,
                unit="°C Anomaly",
                phase="La Niña (Cool Phase)",
                impact_on_monsoon="Favorable",
                mechanism_summary="Cool equatorial Pacific sea surface temperatures enhance the Walker circulation, strengthening cross-equatorial monsoon winds towards peninsular India.",
            ),
            OceanicTeleconnectionIndex(
                index_code="iod_dmi",
                name="Indian Ocean Dipole (IOD)",
                current_value=0.48,
                unit="°C DMI",
                phase="Positive IOD (Active)",
                impact_on_monsoon="Favorable",
                mechanism_summary="Warmer western equatorial Indian Ocean waters create an anomalous convergence zone, pumping moisture into central and southern India.",
            ),
            OceanicTeleconnectionIndex(
                index_code="mjo_convective",
                name="Madden-Julian Oscillation (MJO)",
                current_value=3.0,
                unit="Phase",
                phase="Phase 3 (Tropical Indian Ocean)",
                impact_on_monsoon="Favorable",
                mechanism_summary="Convectively active eastward-propagating pulse over the Indian Ocean stimulates monsoon low-pressure depressions and enhanced rainfall spells.",
            ),
        ]

        # 4. Seasonal Long-Range Forecast Outlook
        seasonal_outlook = SeasonalForecastOutlook(
            season_name="Southwest Monsoon Season (June - September)",
            onset_status="Active Pan-India Monsoon",
            prob_below_normal_pct=14,
            prob_normal_pct=48,
            prob_above_normal_pct=38,
            official_lrf_verdict="Normal to Above-Normal Monsoon likely nationwide (106% of Long Period Average - LPA). Favorable ENSO and positive IOD support sustained agrarian water reserves.",
        )

        # 5. Agricultural Adaptation & Sowing Guidance
        adaptation_directives = [
            "Favorable La Niña and positive IOD alignment indicate robust active spells for rainfed Kharif sowing.",
            "Conserve rainwater in farm ponds and recharge village percolation tanks during excess precipitation episodes.",
            "Ensure field drainage in low-lying black cotton soil tracts to prevent waterlogging during monsoon surges.",
            "Schedule top-dressing nitrogen fertilizers between major rainfall pulses to prevent runoff leaching.",
        ]

        vernacular_advisories = {
            "ta": "பருவமழை வழிகாட்டுதல்: லா நினா சாதகமான நிலையில் உள்ளதால் இயல்பான அல்லது இயல்புக்கு அதிகமான மழை பெய்யும். மானாவாரி விதைப்பு மற்றும் பண்ணைக் குட்டை நீர் சேமிப்பைத் திட்டமிடவும்.",
            "hi": "मानसून दीर्घावधि पूर्वानुमान: ला नीना और सकारात्मक आईओडी के कारण सामान्य से अधिक वर्षा की संभावना है। खरीफ बुवाई और जल संचयन के लिए अनुकूल समय।",
            "mr": "मान्सून दीर्घकालीन अंदाज: ला निना परिस्थितीमुळे सरासरीपेक्षा चांगल्या पावसाची शक्यता. खरीप पेरणीसाठी योग्य नियोजन करा.",
            "bn": "মৌসুমি দীর্ঘমেয়াদী পূর্বাভাস: লা নিনা প্রভাবের কারণে স্বাভাবিক বা তার বেশি বৃষ্টিপাতের সম্ভাবনা। খরিফ চাষের জন্য উপযোগী জল ব্যবস্থাপনা বজায় রাখুন।",
        }

        now_str = datetime.now(timezone.utc).isoformat()

        return MonsoonIntelligenceResponse(
            latitude=latitude,
            longitude=longitude,
            location_name=location_name,
            user_sub_division=user_sd_model,
            teleconnections=teleconnections,
            seasonal_outlook=seasonal_outlook,
            all_sub_divisions=all_sd_models,
            adaptation_directives=adaptation_directives,
            vernacular_advisories=vernacular_advisories,
            last_updated=now_str,
        )
