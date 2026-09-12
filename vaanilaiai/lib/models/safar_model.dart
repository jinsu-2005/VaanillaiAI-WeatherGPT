class PollutantMetricModel {
  final String pollutantCode;
  final String name;
  final double concentration;
  final String unit;
  final int cpcbSubIndex;
  final String subIndexCategory;
  final double cpcbSafeLimit;
  final bool isDominantPollutant;

  PollutantMetricModel({
    required this.pollutantCode,
    required this.name,
    required this.concentration,
    required this.unit,
    required this.cpcbSubIndex,
    required this.subIndexCategory,
    required this.cpcbSafeLimit,
    this.isDominantPollutant = false,
  });

  factory PollutantMetricModel.fromJson(Map<String, dynamic> json) {
    return PollutantMetricModel(
      pollutantCode: json['pollutant_code'] ?? '',
      name: json['name'] ?? '',
      concentration: (json['concentration'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? 'µg/m³',
      cpcbSubIndex: (json['cpcb_sub_index'] as num?)?.toInt() ?? 0,
      subIndexCategory: json['sub_index_category'] ?? 'Moderate',
      cpcbSafeLimit: (json['cpcb_safe_limit'] as num?)?.toDouble() ?? 60.0,
      isDominantPollutant: json['is_dominant_pollutant'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pollutant_code': pollutantCode,
      'name': name,
      'concentration': concentration,
      'unit': unit,
      'cpcb_sub_index': cpcbSubIndex,
      'sub_index_category': subIndexCategory,
      'cpcb_safe_limit': cpcbSafeLimit,
      'is_dominant_pollutant': isDominantPollutant,
    };
  }
}

class AtmosphericDispersionModel {
  final double mixingLayerHeightM;
  final double surfaceWindSpeedKmh;
  final double ventilationCoefficientM2s;
  final String dispersionCategory;
  final String inversionRisk;
  final String physicalDispersionSummary;

  AtmosphericDispersionModel({
    required this.mixingLayerHeightM,
    required this.surfaceWindSpeedKmh,
    required this.ventilationCoefficientM2s,
    required this.dispersionCategory,
    required this.inversionRisk,
    required this.physicalDispersionSummary,
  });

  factory AtmosphericDispersionModel.fromJson(Map<String, dynamic> json) {
    return AtmosphericDispersionModel(
      mixingLayerHeightM: (json['mixing_layer_height_m'] as num?)?.toDouble() ?? 500.0,
      surfaceWindSpeedKmh: (json['surface_wind_speed_kmh'] as num?)?.toDouble() ?? 10.0,
      ventilationCoefficientM2s: (json['ventilation_coefficient_m2s'] as num?)?.toDouble() ?? 1500.0,
      dispersionCategory: json['dispersion_category'] ?? 'Moderate',
      inversionRisk: json['inversion_risk'] ?? 'None',
      physicalDispersionSummary: json['physical_dispersion_summary'] ?? 'Steady atmospheric dispersion.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mixing_layer_height_m': mixingLayerHeightM,
      'surface_wind_speed_kmh': surfaceWindSpeedKmh,
      'ventilation_coefficient_m2s': ventilationCoefficientM2s,
      'dispersion_category': dispersionCategory,
      'inversion_risk': inversionRisk,
      'physical_dispersion_summary': physicalDispersionSummary,
    };
  }
}

class StubbleBiomassSmokeModel {
  final int activeFireCountRegional;
  final double fireRadiativePowerMw;
  final String transportWindDirection;
  final double transboundaryPm25ContributionPct;
  final String agrarianSmokeImpactLevel;

  StubbleBiomassSmokeModel({
    required this.activeFireCountRegional,
    required this.fireRadiativePowerMw,
    required this.transportWindDirection,
    required this.transboundaryPm25ContributionPct,
    required this.agrarianSmokeImpactLevel,
  });

  factory StubbleBiomassSmokeModel.fromJson(Map<String, dynamic> json) {
    return StubbleBiomassSmokeModel(
      activeFireCountRegional: (json['active_fire_count_regional'] as num?)?.toInt() ?? 0,
      fireRadiativePowerMw: (json['fire_radiative_power_mw'] as num?)?.toDouble() ?? 0.0,
      transportWindDirection: json['transport_wind_direction'] ?? 'Variable',
      transboundaryPm25ContributionPct: (json['transboundary_pm25_contribution_pct'] as num?)?.toDouble() ?? 0.0,
      agrarianSmokeImpactLevel: json['agrarian_smoke_impact_level'] ?? 'Low',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active_fire_count_regional': activeFireCountRegional,
      'fire_radiative_power_mw': fireRadiativePowerMw,
      'transport_wind_direction': transportWindDirection,
      'transboundary_pm25_contribution_pct': transboundaryPm25ContributionPct,
      'agrarian_smoke_impact_level': agrarianSmokeImpactLevel,
    };
  }
}

class SafarAqiForecastModel {
  final String forecastDay;
  final String date;
  final int predictedAqi;
  final String category;
  final String primaryDriver;

  SafarAqiForecastModel({
    required this.forecastDay,
    required this.date,
    required this.predictedAqi,
    required this.category,
    required this.primaryDriver,
  });

  factory SafarAqiForecastModel.fromJson(Map<String, dynamic> json) {
    return SafarAqiForecastModel(
      forecastDay: json['forecast_day'] ?? '',
      date: json['date'] ?? '',
      predictedAqi: (json['predicted_aqi'] as num?)?.toInt() ?? 100,
      category: json['category'] ?? 'Moderate',
      primaryDriver: json['primary_driver'] ?? 'Diurnal boundary layer dynamics',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'forecast_day': forecastDay,
      'date': date,
      'predicted_aqi': predictedAqi,
      'category': category,
      'primary_driver': primaryDriver,
    };
  }
}

class DemographicHealthAdvisoryModel {
  final String demographicGroup;
  final String vulnerabilityRiskLevel;
  final String actionableGuidance;
  final List<String> recommendedProtectiveMeasures;

  DemographicHealthAdvisoryModel({
    required this.demographicGroup,
    required this.vulnerabilityRiskLevel,
    required this.actionableGuidance,
    this.recommendedProtectiveMeasures = const [],
  });

  factory DemographicHealthAdvisoryModel.fromJson(Map<String, dynamic> json) {
    return DemographicHealthAdvisoryModel(
      demographicGroup: json['demographic_group'] ?? '',
      vulnerabilityRiskLevel: json['vulnerability_risk_level'] ?? 'Moderate',
      actionableGuidance: json['actionable_guidance'] ?? '',
      recommendedProtectiveMeasures: (json['recommended_protective_measures'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'demographic_group': demographicGroup,
      'vulnerability_risk_level': vulnerabilityRiskLevel,
      'actionable_guidance': actionableGuidance,
      'recommended_protective_measures': recommendedProtectiveMeasures,
    };
  }
}

class SafarAirQualityModel {
  final double latitude;
  final double longitude;
  final String locationName;
  final String? selectedCityCode;
  final int overallAqi;
  final String cpcbCategory;
  final String categoryColorHex;
  final String dominantPollutant;
  final List<PollutantMetricModel> pollutants;
  final AtmosphericDispersionModel atmosphericDispersion;
  final StubbleBiomassSmokeModel stubbleBiomassSmoke;
  final List<SafarAqiForecastModel> aqiForecast;
  final List<DemographicHealthAdvisoryModel> demographicAdvisories;
  final Map<String, String> vernacularHealthGuidance;
  final List<String> monitoringStations;
  final String provenanceAuthority;
  final String lastUpdated;
  final bool isOfflineCached;

  SafarAirQualityModel({
    required this.latitude,
    required this.longitude,
    required this.locationName,
    this.selectedCityCode,
    required this.overallAqi,
    required this.cpcbCategory,
    required this.categoryColorHex,
    required this.dominantPollutant,
    this.pollutants = const [],
    required this.atmosphericDispersion,
    required this.stubbleBiomassSmoke,
    this.aqiForecast = const [],
    this.demographicAdvisories = const [],
    this.vernacularHealthGuidance = const {},
    this.monitoringStations = const [],
    this.provenanceAuthority = 'IITM SAFAR & IMD AQEWS Operational Models',
    required this.lastUpdated,
    this.isOfflineCached = false,
  });

  factory SafarAirQualityModel.fromJson(Map<String, dynamic> json, {bool isOfflineCached = false}) {
    final rawPollutants = json['pollutants'] as List<dynamic>? ?? [];
    final rawForecast = json['aqi_forecast'] as List<dynamic>? ?? [];
    final rawDemographics = json['demographic_advisories'] as List<dynamic>? ?? [];
    final rawStations = json['monitoring_stations'] as List<dynamic>? ?? [];

    Map<String, String> vernMap = {};
    if (json['vernacular_health_guidance'] is Map) {
      (json['vernacular_health_guidance'] as Map).forEach((k, v) {
        vernMap[k.toString()] = v.toString();
      });
    }

    return SafarAirQualityModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      locationName: json['location_name'] ?? 'Location',
      selectedCityCode: json['selected_city_code'],
      overallAqi: (json['overall_aqi'] as num?)?.toInt() ?? 120,
      cpcbCategory: json['cpcb_category'] ?? 'Moderate',
      categoryColorHex: json['category_color_hex'] ?? '#EAB308',
      dominantPollutant: json['dominant_pollutant'] ?? 'PM2.5',
      pollutants: rawPollutants.map((e) => PollutantMetricModel.fromJson(e as Map<String, dynamic>)).toList(),
      atmosphericDispersion: json['atmospheric_dispersion'] != null
          ? AtmosphericDispersionModel.fromJson(json['atmospheric_dispersion'] as Map<String, dynamic>)
          : AtmosphericDispersionModel(
              mixingLayerHeightM: 520.0,
              surfaceWindSpeedKmh: 9.0,
              ventilationCoefficientM2s: 1300.0,
              dispersionCategory: 'Poor',
              inversionRisk: 'Mild Inversion',
              physicalDispersionSummary: 'Low boundary layer height slows particulate dispersion.',
            ),
      stubbleBiomassSmoke: json['stubble_biomass_smoke'] != null
          ? StubbleBiomassSmokeModel.fromJson(json['stubble_biomass_smoke'] as Map<String, dynamic>)
          : StubbleBiomassSmokeModel(
              activeFireCountRegional: 25,
              fireRadiativePowerMw: 110.0,
              transportWindDirection: 'North-Westerly',
              transboundaryPm25ContributionPct: 8.5,
              agrarianSmokeImpactLevel: 'Moderate',
            ),
      aqiForecast: rawForecast.map((e) => SafarAqiForecastModel.fromJson(e as Map<String, dynamic>)).toList(),
      demographicAdvisories: rawDemographics
          .map((e) => DemographicHealthAdvisoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      vernacularHealthGuidance: vernMap,
      monitoringStations: rawStations.map((e) => e.toString()).toList(),
      provenanceAuthority: json['provenance_authority'] ?? 'IITM SAFAR & IMD AQEWS Operational Models',
      lastUpdated: json['last_updated'] ?? DateTime.now().toUtc().toIso8601String(),
      isOfflineCached: isOfflineCached,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
      'selected_city_code': selectedCityCode,
      'overall_aqi': overallAqi,
      'cpcb_category': cpcbCategory,
      'category_color_hex': categoryColorHex,
      'dominant_pollutant': dominantPollutant,
      'pollutants': pollutants.map((e) => e.toJson()).toList(),
      'atmospheric_dispersion': atmosphericDispersion.toJson(),
      'stubble_biomass_smoke': stubbleBiomassSmoke.toJson(),
      'aqi_forecast': aqiForecast.map((e) => e.toJson()).toList(),
      'demographic_advisories': demographicAdvisories.map((e) => e.toJson()).toList(),
      'vernacular_health_guidance': vernacularHealthGuidance,
      'monitoring_stations': monitoringStations,
      'provenance_authority': provenanceAuthority,
      'last_updated': lastUpdated,
    };
  }

  factory SafarAirQualityModel.defaultFallback({
    double latitude = 28.6139,
    double longitude = 77.2090,
    String locationName = 'New Delhi',
    String cityCode = 'delhi',
  }) {
    final defaultPollutants = [
      PollutantMetricModel(
        pollutantCode: 'pm2_5',
        name: 'PM2.5 (Fine Particles)',
        concentration: 88.0,
        unit: 'µg/m³',
        cpcbSubIndex: 193,
        subIndexCategory: 'Moderate',
        cpcbSafeLimit: 60.0,
        isDominantPollutant: true,
      ),
      PollutantMetricModel(
        pollutantCode: 'pm10',
        name: 'PM10 (Coarse Particles)',
        concentration: 175.0,
        unit: 'µg/m³',
        cpcbSubIndex: 150,
        subIndexCategory: 'Moderate',
        cpcbSafeLimit: 100.0,
        isDominantPollutant: false,
      ),
      PollutantMetricModel(
        pollutantCode: 'no2',
        name: 'Nitrogen Dioxide (NO₂)',
        concentration: 48.0,
        unit: 'µg/m³',
        cpcbSubIndex: 60,
        subIndexCategory: 'Satisfactory',
        cpcbSafeLimit: 80.0,
        isDominantPollutant: false,
      ),
      PollutantMetricModel(
        pollutantCode: 'so2',
        name: 'Sulfur Dioxide (SO₂)',
        concentration: 18.0,
        unit: 'µg/m³',
        cpcbSubIndex: 23,
        subIndexCategory: 'Good',
        cpcbSafeLimit: 80.0,
        isDominantPollutant: false,
      ),
      PollutantMetricModel(
        pollutantCode: 'co',
        name: 'Carbon Monoxide (CO)',
        concentration: 1.4,
        unit: 'mg/m³',
        cpcbSubIndex: 70,
        subIndexCategory: 'Satisfactory',
        cpcbSafeLimit: 2.0,
        isDominantPollutant: false,
      ),
      PollutantMetricModel(
        pollutantCode: 'o3',
        name: 'Surface Ozone (O₃)',
        concentration: 42.0,
        unit: 'µg/m³',
        cpcbSubIndex: 42,
        subIndexCategory: 'Good',
        cpcbSafeLimit: 100.0,
        isDominantPollutant: false,
      ),
    ];

    final defaultDispersion = AtmosphericDispersionModel(
      mixingLayerHeightM: 480.0,
      surfaceWindSpeedKmh: 8.5,
      ventilationCoefficientM2s: 1133.3,
      dispersionCategory: 'Critical',
      inversionRisk: 'Mild Inversion',
      physicalDispersionSummary:
          'Shallow boundary layer (480m) suppresses vertical dilution; nocturnal inversion slows dispersion.',
    );

    final defaultStubble = StubbleBiomassSmokeModel(
      activeFireCountRegional: 142,
      fireRadiativePowerMw: 380.0,
      transportWindDirection: 'North-Westerly (315°)',
      transboundaryPm25ContributionPct: 22.5,
      agrarianSmokeImpactLevel: 'High',
    );

    final defaultForecast = [
      SafarAqiForecastModel(
        forecastDay: 'Tomorrow',
        date: '24h Projection',
        predictedAqi: 202,
        category: 'Poor',
        primaryDriver: 'Nocturnal boundary layer contraction and calm winds',
      ),
      SafarAqiForecastModel(
        forecastDay: 'Day After',
        date: '72h Projection',
        predictedAqi: 215,
        category: 'Poor',
        primaryDriver: 'Continued slow dispersion and transboundary biomass smoke',
      ),
    ];

    final defaultDemographics = [
      DemographicHealthAdvisoryModel(
        demographicGroup: 'Asthma & Respiratory Patients',
        vulnerabilityRiskLevel: 'High',
        actionableGuidance: 'Keep emergency bronchodilator inhalers handy. Avoid morning exercise before 9:00 AM.',
        recommendedProtectiveMeasures: [
          'Wear N95 / FFP2 particulate mask when stepping outdoors',
          'Operate HEPA room purifier in bedroom during night',
        ],
      ),
      DemographicHealthAdvisoryModel(
        demographicGroup: 'Cardiac & Hypertension Patients',
        vulnerabilityRiskLevel: 'Caution',
        actionableGuidance: 'Elevated PM2.5 can cause vasoconstriction; avoid heavy exertion in polluted traffic corridors.',
        recommendedProtectiveMeasures: [
          'Stay in air-filtered indoor spaces during peak traffic',
          'Monitor blood pressure regularly',
        ],
      ),
      DemographicHealthAdvisoryModel(
        demographicGroup: 'Elderly & Young Children',
        vulnerabilityRiskLevel: 'High',
        actionableGuidance: 'Sensitive lungs absorb fine particulates readily; minimize outdoor recess during morning hours.',
        recommendedProtectiveMeasures: [
          'Shift play activities indoors',
          'Keep windows closed during early morning inversion peak',
        ],
      ),
      DemographicHealthAdvisoryModel(
        demographicGroup: 'Outdoor Manual Workers & Commuters',
        vulnerabilityRiskLevel: 'Severe',
        actionableGuidance: 'Continuous 8-hour exposure requires active particulate filtration.',
        recommendedProtectiveMeasures: [
          'Mandatory N95 mask usage during road/construction shifts',
          'Take regular breaks in enclosed clean zones',
        ],
      ),
      DemographicHealthAdvisoryModel(
        demographicGroup: 'Morning Joggers & Cyclists',
        vulnerabilityRiskLevel: 'High',
        actionableGuidance: 'Deep inhalation of toxic smog during exercise increases lung burden by 4x.',
        recommendedProtectiveMeasures: [
          'Shift workouts to afternoon (1:00 PM – 4:00 PM) when mixing depth peaks',
          'Substitute with indoor cardio',
        ],
      ),
    ];

    return SafarAirQualityModel(
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      selectedCityCode: cityCode,
      overallAqi: 193,
      cpcbCategory: 'Moderate',
      categoryColorHex: '#EAB308',
      dominantPollutant: 'PM2.5',
      pollutants: defaultPollutants,
      atmosphericDispersion: defaultDispersion,
      stubbleBiomassSmoke: defaultStubble,
      aqiForecast: defaultForecast,
      demographicAdvisories: defaultDemographics,
      vernacularHealthGuidance: {
        'en': 'IITM SAFAR Advisory: AQI is 193 (Moderate) with PM2.5 as dominant pollutant. Ventilation coefficient is 1133 m²/s. Sensitive groups should wear N95 masks.',
        'ta': 'SAFAR காற்றுத் தர வழிகாட்டுதல்: காற்றுத் தரக் குறியீடு 193 (மிதமானது). முதன்மை மாசடைவு PM2.5. ஆஸ்துமா உள்ளவர்கள் N95 முகக்கவசம் அணியவும்.',
        'hi': 'सफ़र वायु गुणवत्ता परामर्श: समग्र एक्यूआई 193 (मध्यम) है, जिसमें मुख्य प्रदूषक PM2.5 है। संवेदनशील व्यक्ति N95 मास्क पहनें।',
        'pa': 'ਸਫ਼ਰ ਹਵਾ ਗੁਣਵੱਤਾ ਸਲਾਹ: ਏਅਰ ਕੁਆਲਿਟੀ ਇੰਡੈਕਸ 193 (ਦਰਮਿਆਨਾ) ਹੈ। ਦਮੇ ਦੇ ਮਰੀਜ਼ N95 ਮਾਸਕ ਦੀ ਵਰਤੋਂ ਕਰਨ।',
        'bn': 'সফর বায়ু মান নির্দেশিকা: সামগ্রিক একিউআই 193 (মাঝারি) এবং প্রধান দূষক PM2.5। সংবেদনশীল ব্যক্তিরা N95 মাস্ক ব্যবহার করুন।',
      },
      monitoringStations: [
        'Lodhi Road (HQ)',
        'Pusa IMD',
        'IIT Delhi',
        'Mathura Road',
        'IGI Airport T3',
        'Noida Sec-62',
        'Gurugram',
      ],
      provenanceAuthority: 'IITM SAFAR & IMD AQEWS High-Resolution Dispersion Modeling',
      lastUpdated: DateTime.now().toUtc().toIso8601String(),
      isOfflineCached: true,
    );
  }
}
