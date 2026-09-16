// Models for IMD & ICAR Post-Harvest Mandi Weather Defense,
// Grain Moisture & Open-Godown Spoilage Engine (AGRI-STORAGE).

class CropHygroscopicMetricsModel {
  final String cropName;
  final double currentMoistureContentPct;
  final double equilibriumMoistureContentPct;
  final double safeStorageLimitPct;
  final double moistureSurplusDeficitPct;
  final String moistureState;
  final double hendersonThompsonK;
  final double hendersonThompsonC;
  final double hendersonThompsonN;

  const CropHygroscopicMetricsModel({
    required this.cropName,
    required this.currentMoistureContentPct,
    required this.equilibriumMoistureContentPct,
    required this.safeStorageLimitPct,
    required this.moistureSurplusDeficitPct,
    required this.moistureState,
    required this.hendersonThompsonK,
    required this.hendersonThompsonC,
    required this.hendersonThompsonN,
  });

  factory CropHygroscopicMetricsModel.fromJson(Map<String, dynamic> json) {
    return CropHygroscopicMetricsModel(
      cropName: json['crop_name'] as String? ?? 'Wheat',
      currentMoistureContentPct:
          (json['current_moisture_content_pct'] as num?)?.toDouble() ?? 12.0,
      equilibriumMoistureContentPct:
          (json['equilibrium_moisture_content_pct'] as num?)?.toDouble() ?? 12.5,
      safeStorageLimitPct:
          (json['safe_storage_limit_pct'] as num?)?.toDouble() ?? 12.0,
      moistureSurplusDeficitPct:
          (json['moisture_surplus_deficit_pct'] as num?)?.toDouble() ?? 0.0,
      moistureState: json['moisture_state'] as String? ?? 'ACCEPTABLE_STABLE',
      hendersonThompsonK:
          (json['henderson_thompson_k'] as num?)?.toDouble() ?? 2.3e-5,
      hendersonThompsonC:
          (json['henderson_thompson_c'] as num?)?.toDouble() ?? 55.8,
      hendersonThompsonN:
          (json['henderson_thompson_n'] as num?)?.toDouble() ?? 2.29,
    );
  }

  Map<String, dynamic> toJson() => {
        'crop_name': cropName,
        'current_moisture_content_pct': currentMoistureContentPct,
        'equilibrium_moisture_content_pct': equilibriumMoistureContentPct,
        'safe_storage_limit_pct': safeStorageLimitPct,
        'moisture_surplus_deficit_pct': moistureSurplusDeficitPct,
        'moisture_state': moistureState,
        'henderson_thompson_k': hendersonThompsonK,
        'henderson_thompson_c': hendersonThompsonC,
        'henderson_thompson_n': hendersonThompsonN,
      };
}

class OpenMandiYardTelemetryModel {
  final String yardTypeLabel;
  final double surfaceInundationRiskPct;
  final double forecastRain24hMm;
  final double forecastHailProbabilityPct;
  final double windGustKmh;
  final double dunnagePalletElevationCm;
  final double waterloggingClearanceHours;

  const OpenMandiYardTelemetryModel({
    required this.yardTypeLabel,
    required this.surfaceInundationRiskPct,
    required this.forecastRain24hMm,
    required this.forecastHailProbabilityPct,
    required this.windGustKmh,
    required this.dunnagePalletElevationCm,
    required this.waterloggingClearanceHours,
  });

  factory OpenMandiYardTelemetryModel.fromJson(Map<String, dynamic> json) {
    return OpenMandiYardTelemetryModel(
      yardTypeLabel: json['yard_type_label'] as String? ??
          'Open Plinth / CAP Storage Yard',
      surfaceInundationRiskPct:
          (json['surface_inundation_risk_pct'] as num?)?.toDouble() ?? 15.0,
      forecastRain24hMm:
          (json['forecast_rain_24h_mm'] as num?)?.toDouble() ?? 0.0,
      forecastHailProbabilityPct:
          (json['forecast_hail_probability_pct'] as num?)?.toDouble() ?? 5.0,
      windGustKmh: (json['wind_gust_kmh'] as num?)?.toDouble() ?? 22.0,
      dunnagePalletElevationCm:
          (json['dunnage_pallet_elevation_cm'] as num?)?.toDouble() ?? 15.0,
      waterloggingClearanceHours:
          (json['waterlogging_clearance_hours'] as num?)?.toDouble() ?? 2.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'yard_type_label': yardTypeLabel,
        'surface_inundation_risk_pct': surfaceInundationRiskPct,
        'forecast_rain_24h_mm': forecastRain24hMm,
        'forecast_hail_probability_pct': forecastHailProbabilityPct,
        'wind_gust_kmh': windGustKmh,
        'dunnage_pallet_elevation_cm': dunnagePalletElevationCm,
        'waterlogging_clearance_hours': waterloggingClearanceHours,
      };
}

class FungalMycotoxinTelemetryModel {
  final String aflatoxinB1RiskLevel;
  final String optimalGrowthTempRange;
  final double ambientTempC;
  final double relativeHumidityPct;
  final double moldSporeIncubationIndex;
  final double fssaiLimitUgPerKg;
  final double projectedAflatoxinPpb;

  const FungalMycotoxinTelemetryModel({
    required this.aflatoxinB1RiskLevel,
    required this.optimalGrowthTempRange,
    required this.ambientTempC,
    required this.relativeHumidityPct,
    required this.moldSporeIncubationIndex,
    required this.fssaiLimitUgPerKg,
    required this.projectedAflatoxinPpb,
  });

  factory FungalMycotoxinTelemetryModel.fromJson(Map<String, dynamic> json) {
    return FungalMycotoxinTelemetryModel(
      aflatoxinB1RiskLevel:
          json['aflatoxin_b1_risk_level'] as String? ?? 'MINIMAL_MYCOTOXIN_RISK',
      optimalGrowthTempRange:
          json['optimal_growth_temp_range'] as String? ?? '25°C - 37°C',
      ambientTempC: (json['ambient_temp_c'] as num?)?.toDouble() ?? 28.0,
      relativeHumidityPct:
          (json['relative_humidity_pct'] as num?)?.toDouble() ?? 65.0,
      moldSporeIncubationIndex:
          (json['mold_spore_incubation_index'] as num?)?.toDouble() ?? 2.4,
      fssaiLimitUgPerKg:
          (json['fssai_limit_ug_per_kg'] as num?)?.toDouble() ?? 15.0,
      projectedAflatoxinPpb:
          (json['projected_aflatoxin_ppb'] as num?)?.toDouble() ?? 4.5,
    );
  }

  Map<String, dynamic> toJson() => {
        'aflatoxin_b1_risk_level': aflatoxinB1RiskLevel,
        'optimal_growth_temp_range': optimalGrowthTempRange,
        'ambient_temp_c': ambientTempC,
        'relative_humidity_pct': relativeHumidityPct,
        'mold_spore_incubation_index': moldSporeIncubationIndex,
        'fssai_limit_ug_per_kg': fssaiLimitUgPerKg,
        'projected_aflatoxin_ppb': projectedAflatoxinPpb,
      };
}

class MandiStorageDirectivesModel {
  final String tarpaulinStatus;
  final double dunnagePalletHeightRecommendationCm;
  final String aerationFanScheduleRecommendation;
  final bool openPlatformEvacuationNeeded;
  final List<String> recommendedActions;

  const MandiStorageDirectivesModel({
    required this.tarpaulinStatus,
    required this.dunnagePalletHeightRecommendationCm,
    required this.aerationFanScheduleRecommendation,
    required this.openPlatformEvacuationNeeded,
    required this.recommendedActions,
  });

  factory MandiStorageDirectivesModel.fromJson(Map<String, dynamic> json) {
    return MandiStorageDirectivesModel(
      tarpaulinStatus:
          json['tarpaulin_status'] as String? ?? 'STANDBY_MONITORING',
      dunnagePalletHeightRecommendationCm:
          (json['dunnage_pallet_height_recommendation_cm'] as num?)
                  ?.toDouble() ??
              15.0,
      aerationFanScheduleRecommendation:
          json['aeration_fan_schedule_recommendation'] as String? ??
              'Operate aeration fans during safe humidity windows (<70% RH).',
      openPlatformEvacuationNeeded:
          json['open_platform_evacuation_needed'] as bool? ?? false,
      recommendedActions: (json['recommended_actions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'tarpaulin_status': tarpaulinStatus,
        'dunnage_pallet_height_recommendation_cm':
            dunnagePalletHeightRecommendationCm,
        'aeration_fan_schedule_recommendation':
            aerationFanScheduleRecommendation,
        'open_platform_evacuation_needed': openPlatformEvacuationNeeded,
        'recommended_actions': recommendedActions,
      };
}

class MandiHubModel {
  final String mandiId;
  final String name;
  final String district;
  final String state;
  final double latitude;
  final double longitude;
  final List<String> primaryCommodities;
  final double dailyArrivalMetricTonnes;
  final double storageCapacityMetricTonnes;
  final double openPlinthPct;

  const MandiHubModel({
    required this.mandiId,
    required this.name,
    required this.district,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.primaryCommodities,
    required this.dailyArrivalMetricTonnes,
    required this.storageCapacityMetricTonnes,
    required this.openPlinthPct,
  });

  factory MandiHubModel.fromJson(Map<String, dynamic> json) {
    return MandiHubModel(
      mandiId: json['mandi_id'] as String? ?? 'KHANNA_APMC',
      name: json['name'] as String? ?? 'Khanna APMC Grain Market',
      district: json['district'] as String? ?? 'Ludhiana',
      state: json['state'] as String? ?? 'Punjab',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 30.7020,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 76.2160,
      primaryCommodities: (json['primary_commodities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['Wheat', 'Paddy', 'Maize'],
      dailyArrivalMetricTonnes:
          (json['daily_arrival_metric_tonnes'] as num?)?.toDouble() ?? 18500.0,
      storageCapacityMetricTonnes:
          (json['storage_capacity_metric_tonnes'] as num?)?.toDouble() ??
              120000.0,
      openPlinthPct: (json['open_plinth_pct'] as num?)?.toDouble() ?? 38.5,
    );
  }

  Map<String, dynamic> toJson() => {
        'mandi_id': mandiId,
        'name': name,
        'district': district,
        'state': state,
        'latitude': latitude,
        'longitude': longitude,
        'primary_commodities': primaryCommodities,
        'daily_arrival_metric_tonnes': dailyArrivalMetricTonnes,
        'storage_capacity_metric_tonnes': storageCapacityMetricTonnes,
        'open_plinth_pct': openPlinthPct,
      };
}

class MandiSummaryModel {
  final String mandiId;
  final String name;
  final String state;
  final String riskTier;
  final String predominantCrop;
  final double currentAmbientRhPct;
  final String tarpaulinStatus;

  const MandiSummaryModel({
    required this.mandiId,
    required this.name,
    required this.state,
    required this.riskTier,
    required this.predominantCrop,
    required this.currentAmbientRhPct,
    required this.tarpaulinStatus,
  });

  factory MandiSummaryModel.fromJson(Map<String, dynamic> json) {
    return MandiSummaryModel(
      mandiId: json['mandi_id'] as String? ?? 'KHANNA_APMC',
      name: json['name'] as String? ?? 'Khanna APMC',
      state: json['state'] as String? ?? 'Punjab',
      riskTier: json['risk_tier'] as String? ?? 'SAFE_STORAGE_OPTIMAL',
      predominantCrop: json['predominant_crop'] as String? ?? 'Wheat',
      currentAmbientRhPct:
          (json['current_ambient_rh_pct'] as num?)?.toDouble() ?? 65.0,
      tarpaulinStatus:
          json['tarpaulin_status'] as String? ?? 'STANDBY_MONITORING',
    );
  }

  Map<String, dynamic> toJson() => {
        'mandi_id': mandiId,
        'name': name,
        'state': state,
        'risk_tier': riskTier,
        'predominant_crop': predominantCrop,
        'current_ambient_rh_pct': currentAmbientRhPct,
        'tarpaulin_status': tarpaulinStatus,
      };
}

class AgriStorageResponseModel {
  final MandiHubModel mandi;
  final String assessmentTimestamp;
  final String overallRiskTier;
  final double ambientTemperatureC;
  final double ambientRelativeHumidityPct;
  final String weatherCondition;
  final List<CropHygroscopicMetricsModel> cropHygroscopicMetrics;
  final OpenMandiYardTelemetryModel openYardTelemetry;
  final FungalMycotoxinTelemetryModel fungalMycotoxinTelemetry;
  final MandiStorageDirectivesModel storageDirectives;
  final List<MandiSummaryModel> monitoredMandis;
  final Map<String, String> vernacularBulletins;
  final Map<String, String> metadata;

  const AgriStorageResponseModel({
    required this.mandi,
    required this.assessmentTimestamp,
    required this.overallRiskTier,
    required this.ambientTemperatureC,
    required this.ambientRelativeHumidityPct,
    required this.weatherCondition,
    required this.cropHygroscopicMetrics,
    required this.openYardTelemetry,
    required this.fungalMycotoxinTelemetry,
    required this.storageDirectives,
    required this.monitoredMandis,
    required this.vernacularBulletins,
    required this.metadata,
  });

  factory AgriStorageResponseModel.fromJson(Map<String, dynamic> json) {
    return AgriStorageResponseModel(
      mandi: json['mandi'] != null
          ? MandiHubModel.fromJson(json['mandi'] as Map<String, dynamic>)
          : AgriStorageResponseModel.defaultFallback().mandi,
      assessmentTimestamp: json['assessment_timestamp'] as String? ??
          DateTime.now().toUtc().toIso8601String(),
      overallRiskTier:
          json['overall_risk_tier'] as String? ?? 'MODERATE_WEATHER_ALERT',
      ambientTemperatureC:
          (json['ambient_temperature_c'] as num?)?.toDouble() ?? 28.5,
      ambientRelativeHumidityPct:
          (json['ambient_relative_humidity_pct'] as num?)?.toDouble() ?? 68.0,
      weatherCondition: json['weather_condition'] as String? ??
          'Humid Overcast Sky with High Spoilage Vapor',
      cropHygroscopicMetrics: (json['crop_hygroscopic_metrics'] as List<dynamic>?)
              ?.map((e) =>
                  CropHygroscopicMetricsModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          AgriStorageResponseModel.defaultFallback().cropHygroscopicMetrics,
      openYardTelemetry: json['open_yard_telemetry'] != null
          ? OpenMandiYardTelemetryModel.fromJson(
              json['open_yard_telemetry'] as Map<String, dynamic>)
          : AgriStorageResponseModel.defaultFallback().openYardTelemetry,
      fungalMycotoxinTelemetry: json['fungal_mycotoxin_telemetry'] != null
          ? FungalMycotoxinTelemetryModel.fromJson(
              json['fungal_mycotoxin_telemetry'] as Map<String, dynamic>)
          : AgriStorageResponseModel.defaultFallback().fungalMycotoxinTelemetry,
      storageDirectives: json['storage_directives'] != null
          ? MandiStorageDirectivesModel.fromJson(
              json['storage_directives'] as Map<String, dynamic>)
          : AgriStorageResponseModel.defaultFallback().storageDirectives,
      monitoredMandis: (json['monitored_mandis'] as List<dynamic>?)
              ?.map((e) =>
                  MandiSummaryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          AgriStorageResponseModel.defaultFallback().monitoredMandis,
      vernacularBulletins: (json['vernacular_bulletins'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          AgriStorageResponseModel.defaultFallback().vernacularBulletins,
      metadata: (json['metadata'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          AgriStorageResponseModel.defaultFallback().metadata,
    );
  }

  Map<String, dynamic> toJson() => {
        'mandi': mandi.toJson(),
        'assessment_timestamp': assessmentTimestamp,
        'overall_risk_tier': overallRiskTier,
        'ambient_temperature_c': ambientTemperatureC,
        'ambient_relative_humidity_pct': ambientRelativeHumidityPct,
        'weather_condition': weatherCondition,
        'crop_hygroscopic_metrics':
            cropHygroscopicMetrics.map((e) => e.toJson()).toList(),
        'open_yard_telemetry': openYardTelemetry.toJson(),
        'fungal_mycotoxin_telemetry': fungalMycotoxinTelemetry.toJson(),
        'storage_directives': storageDirectives.toJson(),
        'monitored_mandis': monitoredMandis.map((e) => e.toJson()).toList(),
        'vernacular_bulletins': vernacularBulletins,
        'metadata': metadata,
      };

  factory AgriStorageResponseModel.defaultFallback() {
    return const AgriStorageResponseModel(
      mandi: MandiHubModel(
        mandiId: 'KHANNA_APMC',
        name: 'Khanna APMC Grain Market',
        district: 'Ludhiana',
        state: 'Punjab',
        latitude: 30.7020,
        longitude: 76.2160,
        primaryCommodities: ['Wheat', 'Paddy', 'Maize'],
        dailyArrivalMetricTonnes: 18500.0,
        storageCapacityMetricTonnes: 120000.0,
        openPlinthPct: 38.5,
      ),
      assessmentTimestamp: '2026-09-12T06:00:00Z',
      overallRiskTier: 'HIGH_MOISTURE_SURGE',
      ambientTemperatureC: 28.5,
      ambientRelativeHumidityPct: 76.0,
      weatherCondition: 'Scattered Moderate Rains with Gusty Winds',
      cropHygroscopicMetrics: [
        CropHygroscopicMetricsModel(
          cropName: 'Wheat',
          currentMoistureContentPct: 13.8,
          equilibriumMoistureContentPct: 14.2,
          safeStorageLimitPct: 12.0,
          moistureSurplusDeficitPct: 1.8,
          moistureState: 'UNSAFE_ELEVATED_MOISTURE',
          hendersonThompsonK: 2.3e-5,
          hendersonThompsonC: 55.8,
          hendersonThompsonN: 2.29,
        ),
        CropHygroscopicMetricsModel(
          cropName: 'Paddy',
          currentMoistureContentPct: 15.6,
          equilibriumMoistureContentPct: 15.8,
          safeStorageLimitPct: 14.0,
          moistureSurplusDeficitPct: 1.6,
          moistureState: 'UNSAFE_ELEVATED_MOISTURE',
          hendersonThompsonK: 1.9e-5,
          hendersonThompsonC: 35.7,
          hendersonThompsonN: 2.15,
        ),
        CropHygroscopicMetricsModel(
          cropName: 'Maize',
          currentMoistureContentPct: 14.1,
          equilibriumMoistureContentPct: 14.5,
          safeStorageLimitPct: 13.0,
          moistureSurplusDeficitPct: 1.1,
          moistureState: 'UNSAFE_ELEVATED_MOISTURE',
          hendersonThompsonK: 3.2e-5,
          hendersonThompsonC: 46.5,
          hendersonThompsonN: 1.98,
        ),
      ],
      openYardTelemetry: OpenMandiYardTelemetryModel(
        yardTypeLabel: 'Open Plinth / CAP Storage Yard',
        surfaceInundationRiskPct: 48.0,
        forecastRain24hMm: 18.5,
        forecastHailProbabilityPct: 25.0,
        windGustKmh: 42.0,
        dunnagePalletElevationCm: 12.0,
        waterloggingClearanceHours: 3.5,
      ),
      fungalMycotoxinTelemetry: FungalMycotoxinTelemetryModel(
        aflatoxinB1RiskLevel: 'HIGH_FUNGAL_PROLIFERATION',
        optimalGrowthTempRange: '25°C - 37°C',
        ambientTempC: 28.5,
        relativeHumidityPct: 76.0,
        moldSporeIncubationIndex: 6.8,
        fssaiLimitUgPerKg: 15.0,
        projectedAflatoxinPpb: 14.2,
      ),
      storageDirectives: MandiStorageDirectivesModel(
        tarpaulinStatus: 'IMMEDIATE_TIRPAL_DEPLOYMENT',
        dunnagePalletHeightRecommendationCm: 15.0,
        aerationFanScheduleRecommendation:
            'SHUT DOWN AERATION FANS IMMEDIATELY: Ambient humidity (>75%) will drive moisture into dry grain stacks.',
        openPlatformEvacuationNeeded: false,
        recommendedActions: [
          'Maintain minimum 15.0 cm wooden dunnage crates beneath all bag stacks to eliminate floor capillary wicking.',
          'Fasten HDPE 250+ GSM tarpaulins (tirpals) over all open plinth lots using sandbag ballasts against wind gusts.',
          'SHUT DOWN AERATION FANS IMMEDIATELY: High ambient relative humidity (>70%) will pump atmospheric moisture into grain stacks.',
          'Inspect grain heaps with digital moisture meters every 4 hours during peak diurnal humidity shifts.',
        ],
      ),
      monitoredMandis: [
        MandiSummaryModel(
          mandiId: 'KHANNA_APMC',
          name: 'Khanna APMC Grain Market',
          state: 'Punjab',
          riskTier: 'HIGH_MOISTURE_SURGE',
          predominantCrop: 'Wheat',
          currentAmbientRhPct: 76.0,
          tarpaulinStatus: 'IMMEDIATE_TIRPAL_DEPLOYMENT',
        ),
        MandiSummaryModel(
          mandiId: 'KARNAL_APMC',
          name: 'Karnal New Grain Market',
          state: 'Haryana',
          riskTier: 'MODERATE_WEATHER_ALERT',
          predominantCrop: 'Paddy',
          currentAmbientRhPct: 71.0,
          tarpaulinStatus: 'STANDBY_MONITORING',
        ),
        MandiSummaryModel(
          mandiId: 'NEEMUCH_APMC',
          name: 'Neemuch Krishi Upaj Mandi',
          state: 'Madhya Pradesh',
          riskTier: 'SAFE_STORAGE_OPTIMAL',
          predominantCrop: 'Soybean',
          currentAmbientRhPct: 58.0,
          tarpaulinStatus: 'NO_DEPLOYMENT_NEEDED',
        ),
        MandiSummaryModel(
          mandiId: 'LATUR_APMC',
          name: 'Latur APMC',
          state: 'Maharashtra',
          riskTier: 'SAFE_STORAGE_OPTIMAL',
          predominantCrop: 'Soybean',
          currentAmbientRhPct: 62.0,
          tarpaulinStatus: 'NO_DEPLOYMENT_NEEDED',
        ),
        MandiSummaryModel(
          mandiId: 'NIZAMABAD_APMC',
          name: 'Nizamabad Agricultural Market',
          state: 'Telangana',
          riskTier: 'MODERATE_WEATHER_ALERT',
          predominantCrop: 'Paddy',
          currentAmbientRhPct: 69.0,
          tarpaulinStatus: 'STANDBY_MONITORING',
        ),
        MandiSummaryModel(
          mandiId: 'GUNTUR_MIRCHI',
          name: 'Guntur Mirchi Yard',
          state: 'Andhra Pradesh',
          riskTier: 'HIGH_MOISTURE_SURGE',
          predominantCrop: 'Paddy',
          currentAmbientRhPct: 78.0,
          tarpaulinStatus: 'HIGH_PRIORITY_PREPOSITIONING',
        ),
        MandiSummaryModel(
          mandiId: 'KOTA_BHAMASHAH',
          name: 'Kota Bhamashah Krishi Mandi',
          state: 'Rajasthan',
          riskTier: 'SAFE_STORAGE_OPTIMAL',
          predominantCrop: 'Mustard',
          currentAmbientRhPct: 55.0,
          tarpaulinStatus: 'NO_DEPLOYMENT_NEEDED',
        ),
      ],
      vernacularBulletins: {
        'en':
            'IMD-ICAR MANDI ALERT for Khanna APMC Grain Market: Overall spoilage threat is HIGH_MOISTURE_SURGE. Ambient RH is 76.0%, 24h rain forecast is 18.5 mm. Tarpaulin status: IMMEDIATE_TIRPAL_DEPLOYMENT. Ensure 15cm dunnage elevation and adhere to grain aeration schedules.',
        'hi':
            'भाकृअनुप-आईएमडी मंडी भंडारण चेतावनी (खन्ना मंडी): समग्र भंडारण जोखिम \'HIGH_MOISTURE_SURGE\' है। हवा में नमी 76.0% तथा बारिश का अनुमान है। तिरपाल तत्काल ढकें तथा बोरियों को 15 सेमी ऊंचे क्रेट्स पर रखें।',
        'pa':
            'ਆਈਐਮਡੀ-ਆਈਸੀਏਆਰ ਮੰਡੀ ਭੰਡਾਰਨ ਚਿਤਾਵਨੀ (ਖੰਨਾ ਮੰਡੀ): ਅਨਾਜ ਨੁਕਸਾਨ ਦਾ ਖਤਰਾ \'HIGH_MOISTURE_SURGE\' ਹੈ। ਨਮੀ 76.0% ਅਤੇ ਮੀਂਹ ਸੰਭਵ ਹੈ। ਦਾਣਿਆਂ ਦੀਆਂ ਬੋਰੀਆਂ ਨੂੰ ਲੱਕੜ ਦੇ ਤਖਤਿਆਂ (15 ਸੈਂਟੀਮੀਟਰ) \'ਤੇ ਰੱਖੋ ਅਤੇ ਤਰਪਾਲਾਂ ਨਾਲ ਢੱਕੋ।',
        'mr':
            'आयसीएआर-आयएमडी कृषी बाजार चेतावणी (खन्ना मंडी): धान्य नासाडीचा धोका असून हवेतील आर्द्रता 76.0% आहे. ताडपत्री तातडीने बांधा आणि पोत्याखाली १५ सेमी लाकडी क्रेट्स वापरा.',
        'te':
            'ఐసీఏఆర్-ఐఎండి మార్కెట్ యార్డ్ భద్రతా హెచ్చరిక (ఖన్నా మార్కెట్): గాలిలో తేమ 76.0%. ధాన్యపు బస్తాలను 15 సెం.మీ ఎత్తు గల చెక్క క్రేట్లపై ఉంచి టార్పాలిన్లతో కప్పండి.',
        'gu':
            'આઈસીએઆર-આઈએમડી માર્કેટ યાર્ડ સંગ્રહ ચેતવણી (ખન્ના માર્કેટ): વાતાવરણમાં ભેજ 76.0% છે. તાલપત્રી તરત ઢાંકો અને થપ્પી નીચે 15 સેમી ડનેજ રાખો.',
        'bn':
            'আইসিএআর-আইএমডি মান্ডি গুদাম সতর্কতা (খান্না মান্ডি): আর্দ্রতা 76.0%। অবিলম্বে ত্রিপল বাঁধুন এবং ১৫ সেমি উঁচু মাচার উপর বস্তা রাখুন।',
      },
      metadata: {
        'source_authority':
            'IMD Agromet Division & ICAR-CIPHET (Central Institute of Post-Harvest Engineering & Technology)',
        'statutory_reference':
            'Food Safety and Standards Authority of India (FSSAI) Maximum Limit for Aflatoxin B1 (15 ppb)',
        'formulation':
            'Modified Henderson-Thompson Equilibrium Moisture Content (ASABE D245.7 Standards)',
        'operational_standard':
            'Food Corporation of India (FCI) & Central Warehousing Corporation (CWC) CAP Storage Code of Practice',
      },
    );
  }
}
