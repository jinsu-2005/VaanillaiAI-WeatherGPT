// Models for IMD & CWC National Flood Forecasting,
// Hydrological Rating Curve & Embankment Breach Telemetry Engine (HYDRO-RATING).

class CwcBenchmarkLevelsModel {
  final double zeroFlowDatumM;
  final double warningLevelM;
  final double dangerLevelM;
  final double highestFloodLevelHflM;
  final int hflRecordYear;
  final double embankmentCrestM;

  CwcBenchmarkLevelsModel({
    required this.zeroFlowDatumM,
    required this.warningLevelM,
    required this.dangerLevelM,
    required this.highestFloodLevelHflM,
    required this.hflRecordYear,
    required this.embankmentCrestM,
  });

  factory CwcBenchmarkLevelsModel.fromJson(Map<String, dynamic> json) {
    return CwcBenchmarkLevelsModel(
      zeroFlowDatumM: (json['zero_flow_datum_m'] as num).toDouble(),
      warningLevelM: (json['warning_level_m'] as num).toDouble(),
      dangerLevelM: (json['danger_level_m'] as num).toDouble(),
      highestFloodLevelHflM: (json['highest_flood_level_hfl_m'] as num).toDouble(),
      hflRecordYear: (json['hfl_record_year'] as num).toInt(),
      embankmentCrestM: (json['embankment_crest_m'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'zero_flow_datum_m': zeroFlowDatumM,
        'warning_level_m': warningLevelM,
        'danger_level_m': dangerLevelM,
        'highest_flood_level_hfl_m': highestFloodLevelHflM,
        'hfl_record_year': hflRecordYear,
        'embankment_crest_m': embankmentCrestM,
      };
}

class HydrologicalRatingCurveTelemetryModel {
  final double stageHeightM;
  final double zeroFlowDatumH0M;
  final double effectiveHeadM;
  final double ratingCoefficientA;
  final double hydraulicExponentB;
  final double computedDischargeCumecs;
  final double wettedCrossSectionAreaM2;
  final double hydraulicRadiusM;
  final double manningRoughnessN;
  final double channelEnergySlope;
  final double meanFlowVelocityMps;

  HydrologicalRatingCurveTelemetryModel({
    required this.stageHeightM,
    required this.zeroFlowDatumH0M,
    required this.effectiveHeadM,
    required this.ratingCoefficientA,
    required this.hydraulicExponentB,
    required this.computedDischargeCumecs,
    required this.wettedCrossSectionAreaM2,
    required this.hydraulicRadiusM,
    required this.manningRoughnessN,
    required this.channelEnergySlope,
    required this.meanFlowVelocityMps,
  });

  factory HydrologicalRatingCurveTelemetryModel.fromJson(Map<String, dynamic> json) {
    return HydrologicalRatingCurveTelemetryModel(
      stageHeightM: (json['stage_height_m'] as num).toDouble(),
      zeroFlowDatumH0M: (json['zero_flow_datum_h0_m'] as num).toDouble(),
      effectiveHeadM: (json['effective_head_m'] as num).toDouble(),
      ratingCoefficientA: (json['rating_coefficient_a'] as num).toDouble(),
      hydraulicExponentB: (json['hydraulic_exponent_b'] as num).toDouble(),
      computedDischargeCumecs: (json['computed_discharge_cumecs'] as num).toDouble(),
      wettedCrossSectionAreaM2: (json['wetted_cross_section_area_m2'] as num).toDouble(),
      hydraulicRadiusM: (json['hydraulic_radius_m'] as num).toDouble(),
      manningRoughnessN: (json['manning_roughness_n'] as num).toDouble(),
      channelEnergySlope: (json['channel_energy_slope'] as num).toDouble(),
      meanFlowVelocityMps: (json['mean_flow_velocity_mps'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'stage_height_m': stageHeightM,
        'zero_flow_datum_h0_m': zeroFlowDatumH0M,
        'effective_head_m': effectiveHeadM,
        'rating_coefficient_a': ratingCoefficientA,
        'hydraulic_exponent_b': hydraulicExponentB,
        'computed_discharge_cumecs': computedDischargeCumecs,
        'wetted_cross_section_area_m2': wettedCrossSectionAreaM2,
        'hydraulic_radius_m': hydraulicRadiusM,
        'manning_roughness_n': manningRoughnessN,
        'channel_energy_slope': channelEnergySlope,
        'mean_flow_velocity_mps': meanFlowVelocityMps,
      };
}

class EmbankmentStructuralSafetyMetricsModel {
  final double embankmentCrestLevelM;
  final double countrysideToeLevelM;
  final double freeboardMarginM;
  final String freeboardTier;
  final double seepagePathLengthM;
  final double exitHydraulicGradient;
  final double criticalHydraulicGradient;
  final double pipingFactorOfSafety;
  final String pipingRiskTier;
  final bool sandBoilDetected;

  EmbankmentStructuralSafetyMetricsModel({
    required this.embankmentCrestLevelM,
    required this.countrysideToeLevelM,
    required this.freeboardMarginM,
    required this.freeboardTier,
    required this.seepagePathLengthM,
    required this.exitHydraulicGradient,
    required this.criticalHydraulicGradient,
    required this.pipingFactorOfSafety,
    required this.pipingRiskTier,
    required this.sandBoilDetected,
  });

  factory EmbankmentStructuralSafetyMetricsModel.fromJson(Map<String, dynamic> json) {
    return EmbankmentStructuralSafetyMetricsModel(
      embankmentCrestLevelM: (json['embankment_crest_level_m'] as num).toDouble(),
      countrysideToeLevelM: (json['countryside_toe_level_m'] as num).toDouble(),
      freeboardMarginM: (json['freeboard_margin_m'] as num).toDouble(),
      freeboardTier: json['freeboard_tier'] as String? ?? 'OPTIMAL_FREEBOARD',
      seepagePathLengthM: (json['seepage_path_length_m'] as num).toDouble(),
      exitHydraulicGradient: (json['exit_hydraulic_gradient'] as num).toDouble(),
      criticalHydraulicGradient: (json['critical_hydraulic_gradient'] as num).toDouble(),
      pipingFactorOfSafety: (json['piping_factor_of_safety'] as num).toDouble(),
      pipingRiskTier: json['piping_risk_tier'] as String? ?? 'SAFE_STABLE',
      sandBoilDetected: json['sand_boil_detected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'embankment_crest_level_m': embankmentCrestLevelM,
        'countryside_toe_level_m': countrysideToeLevelM,
        'freeboard_margin_m': freeboardMarginM,
        'freeboard_tier': freeboardTier,
        'seepage_path_length_m': seepagePathLengthM,
        'exit_hydraulic_gradient': exitHydraulicGradient,
        'critical_hydraulic_gradient': criticalHydraulicGradient,
        'piping_factor_of_safety': pipingFactorOfSafety,
        'piping_risk_tier': pipingRiskTier,
        'sand_boil_detected': sandBoilDetected,
      };
}

class GumbelFrequencyAnalysisModel {
  final double discharge10yrCumecs;
  final double discharge25yrCumecs;
  final double discharge50yrCumecs;
  final double discharge100yrCumecs;
  final String currentReturnPeriod;
  final double annualExceedanceProbabilityPct;

  GumbelFrequencyAnalysisModel({
    required this.discharge10yrCumecs,
    required this.discharge25yrCumecs,
    required this.discharge50yrCumecs,
    required this.discharge100yrCumecs,
    required this.currentReturnPeriod,
    required this.annualExceedanceProbabilityPct,
  });

  factory GumbelFrequencyAnalysisModel.fromJson(Map<String, dynamic> json) {
    return GumbelFrequencyAnalysisModel(
      discharge10yrCumecs: (json['discharge_10yr_cumecs'] as num).toDouble(),
      discharge25yrCumecs: (json['discharge_25yr_cumecs'] as num).toDouble(),
      discharge50yrCumecs: (json['discharge_50yr_cumecs'] as num).toDouble(),
      discharge100yrCumecs: (json['discharge_100yr_cumecs'] as num).toDouble(),
      currentReturnPeriod: json['current_return_period'] as String? ?? 'LESS_THAN_10_YEAR',
      annualExceedanceProbabilityPct: (json['annual_exceedance_probability_pct'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'discharge_10yr_cumecs': discharge10yrCumecs,
        'discharge_25yr_cumecs': discharge25yrCumecs,
        'discharge_50yr_cumecs': discharge50yrCumecs,
        'discharge_100yr_cumecs': discharge100yrCumecs,
        'current_return_period': currentReturnPeriod,
        'annual_exceedance_probability_pct': annualExceedanceProbabilityPct,
      };
}

class RiparianDefenseDirectivesModel {
  final String floodWarningColor;
  final String evacuationUrgencyLevel;
  final String embankmentPatrolFrequency;
  final String pipingCountermeasureDirective;
  final String riparianSafetyProtocol;
  final String drinkingWaterSanitationAdvisory;

  RiparianDefenseDirectivesModel({
    required this.floodWarningColor,
    required this.evacuationUrgencyLevel,
    required this.embankmentPatrolFrequency,
    required this.pipingCountermeasureDirective,
    required this.riparianSafetyProtocol,
    required this.drinkingWaterSanitationAdvisory,
  });

  factory RiparianDefenseDirectivesModel.fromJson(Map<String, dynamic> json) {
    return RiparianDefenseDirectivesModel(
      floodWarningColor: json['flood_warning_color'] as String? ?? '#DC2626',
      evacuationUrgencyLevel: json['evacuation_urgency_level'] as String? ?? 'IMMEDIATE',
      embankmentPatrolFrequency: json['embankment_patrol_frequency'] as String? ?? 'Continuous 24x7',
      pipingCountermeasureDirective: json['piping_countermeasure_directive'] as String? ?? '',
      riparianSafetyProtocol: json['riparian_safety_protocol'] as String? ?? '',
      drinkingWaterSanitationAdvisory: json['drinking_water_sanitation_advisory'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'flood_warning_color': floodWarningColor,
        'evacuation_urgency_level': evacuationUrgencyLevel,
        'embankment_patrol_frequency': embankmentPatrolFrequency,
        'piping_countermeasure_directive': pipingCountermeasureDirective,
        'riparian_safety_protocol': riparianSafetyProtocol,
        'drinking_water_sanitation_advisory': drinkingWaterSanitationAdvisory,
      };
}

class RiverBasinHydroStationModel {
  final String stationId;
  final String stationName;
  final String riverName;
  final String stateName;
  final double latitude;
  final double longitude;
  final String cwcDivision;
  final String floodStageTier;
  final CwcBenchmarkLevelsModel benchmarks;
  final HydrologicalRatingCurveTelemetryModel ratingCurve;
  final EmbankmentStructuralSafetyMetricsModel embankmentSafety;
  final GumbelFrequencyAnalysisModel gumbelFrequency;
  final RiparianDefenseDirectivesModel directives;

  RiverBasinHydroStationModel({
    required this.stationId,
    required this.stationName,
    required this.riverName,
    required this.stateName,
    required this.latitude,
    required this.longitude,
    required this.cwcDivision,
    required this.floodStageTier,
    required this.benchmarks,
    required this.ratingCurve,
    required this.embankmentSafety,
    required this.gumbelFrequency,
    required this.directives,
  });

  factory RiverBasinHydroStationModel.fromJson(Map<String, dynamic> json) {
    return RiverBasinHydroStationModel(
      stationId: json['station_id'] as String? ?? '',
      stationName: json['station_name'] as String? ?? '',
      riverName: json['river_name'] as String? ?? '',
      stateName: json['state_name'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      cwcDivision: json['cwc_division'] as String? ?? '',
      floodStageTier: json['flood_stage_tier'] as String? ?? 'DANGER_STAGE',
      benchmarks: CwcBenchmarkLevelsModel.fromJson(json['benchmarks'] as Map<String, dynamic>),
      ratingCurve: HydrologicalRatingCurveTelemetryModel.fromJson(json['rating_curve'] as Map<String, dynamic>),
      embankmentSafety: EmbankmentStructuralSafetyMetricsModel.fromJson(json['embankment_safety'] as Map<String, dynamic>),
      gumbelFrequency: GumbelFrequencyAnalysisModel.fromJson(json['gumbel_frequency'] as Map<String, dynamic>),
      directives: RiparianDefenseDirectivesModel.fromJson(json['directives'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'station_id': stationId,
        'station_name': stationName,
        'river_name': riverName,
        'state_name': stateName,
        'latitude': latitude,
        'longitude': longitude,
        'cwc_division': cwcDivision,
        'flood_stage_tier': floodStageTier,
        'benchmarks': benchmarks.toJson(),
        'rating_curve': ratingCurve.toJson(),
        'embankment_safety': embankmentSafety.toJson(),
        'gumbel_frequency': gumbelFrequency.toJson(),
        'directives': directives.toJson(),
      };
}

class BasinSummaryModel {
  final String stationId;
  final String stationName;
  final String riverName;
  final String stateName;
  final double stageHeightM;
  final double dangerLevelM;
  final String floodStageTier;
  final double freeboardMarginM;
  final String pipingRiskTier;

  BasinSummaryModel({
    required this.stationId,
    required this.stationName,
    required this.riverName,
    required this.stateName,
    required this.stageHeightM,
    required this.dangerLevelM,
    required this.floodStageTier,
    required this.freeboardMarginM,
    required this.pipingRiskTier,
  });

  factory BasinSummaryModel.fromJson(Map<String, dynamic> json) {
    return BasinSummaryModel(
      stationId: json['station_id'] as String? ?? '',
      stationName: json['station_name'] as String? ?? '',
      riverName: json['river_name'] as String? ?? '',
      stateName: json['state_name'] as String? ?? '',
      stageHeightM: (json['stage_height_m'] as num).toDouble(),
      dangerLevelM: (json['danger_level_m'] as num).toDouble(),
      floodStageTier: json['flood_stage_tier'] as String? ?? 'NORMAL_FLOW',
      freeboardMarginM: (json['freeboard_margin_m'] as num).toDouble(),
      pipingRiskTier: json['piping_risk_tier'] as String? ?? 'SAFE_STABLE',
    );
  }

  Map<String, dynamic> toJson() => {
        'station_id': stationId,
        'station_name': stationName,
        'river_name': riverName,
        'state_name': stateName,
        'stage_height_m': stageHeightM,
        'danger_level_m': dangerLevelM,
        'flood_stage_tier': floodStageTier,
        'freeboard_margin_m': freeboardMarginM,
        'piping_risk_tier': pipingRiskTier,
      };
}

class HydroRatingResponseModel {
  final String timestamp;
  final RiverBasinHydroStationModel activeStation;
  final List<BasinSummaryModel> allStations;
  final Map<String, String> vernacularBulletins;
  final String dataSource;
  final bool isOfflineCached;

  HydroRatingResponseModel({
    required this.timestamp,
    required this.activeStation,
    required this.allStations,
    required this.vernacularBulletins,
    required this.dataSource,
    this.isOfflineCached = false,
  });

  factory HydroRatingResponseModel.fromJson(Map<String, dynamic> json, {bool isOfflineCached = false}) {
    return HydroRatingResponseModel(
      timestamp: json['timestamp'] as String? ?? '',
      activeStation: RiverBasinHydroStationModel.fromJson(json['active_station'] as Map<String, dynamic>),
      allStations: (json['all_stations'] as List<dynamic>?)
              ?.map((e) => BasinSummaryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      vernacularBulletins: (json['vernacular_bulletins'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          {},
      dataSource: json['dataSource'] as String? ?? 'Central Water Commission (CWC) & IMD Hydromet',
      isOfflineCached: isOfflineCached,
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'active_station': activeStation.toJson(),
        'all_stations': allStations.map((e) => e.toJson()).toList(),
        'vernacular_bulletins': vernacularBulletins,
        'dataSource': dataSource,
      };

  factory HydroRatingResponseModel.defaultFallback() {
    final benchmarks = CwcBenchmarkLevelsModel(
      zeroFlowDatumM: 28.50,
      warningLevelM: 33.85,
      dangerLevelM: 34.75,
      highestFloodLevelHflM: 36.40,
      hflRecordYear: 2008,
      embankmentCrestM: 37.80,
    );

    final ratingCurve = HydrologicalRatingCurveTelemetryModel(
      stageHeightM: 35.15,
      zeroFlowDatumH0M: 28.50,
      effectiveHeadM: 6.65,
      ratingCoefficientA: 64.20,
      hydraulicExponentB: 1.92,
      computedDischargeCumecs: 2478.4,
      wettedCrossSectionAreaM2: 1538.2,
      hydraulicRadiusM: 3.08,
      manningRoughnessN: 0.034,
      channelEnergySlope: 0.00030,
      meanFlowVelocityMps: 1.61,
    );

    final embankmentSafety = EmbankmentStructuralSafetyMetricsModel(
      embankmentCrestLevelM: 37.80,
      countrysideToeLevelM: 30.20,
      freeboardMarginM: 2.65,
      freeboardTier: 'OPTIMAL_FREEBOARD',
      seepagePathLengthM: 32.0,
      exitHydraulicGradient: 0.155,
      criticalHydraulicGradient: 1.0,
      pipingFactorOfSafety: 6.45,
      pipingRiskTier: 'SAFE_STABLE',
      sandBoilDetected: false,
    );

    final gumbel = GumbelFrequencyAnalysisModel(
      discharge10yrCumecs: 14500.0,
      discharge25yrCumecs: 18200.0,
      discharge50yrCumecs: 21400.0,
      discharge100yrCumecs: 24800.0,
      currentReturnPeriod: 'LESS_THAN_10_YEAR',
      annualExceedanceProbabilityPct: 25.0,
    );

    final directives = RiparianDefenseDirectivesModel(
      floodWarningColor: '#DC2626',
      evacuationUrgencyLevel: 'IMMEDIATE_RIPARIAN_EVACUATION',
      embankmentPatrolFrequency: 'High Vigil (2-Hour Patrol Intervals)',
      pipingCountermeasureDirective: 'Deploy geo-textile filter rolls and monitor seepage turbidity at toe.',
      riparianSafetyProtocol: 'River stage (35.15m) exceeds Danger Level (34.75m). Evacuate chars and diaras to relief shelters.',
      drinkingWaterSanitationAdvisory: 'Super-chlorinate all borewells (bleaching powder 2.5 kg/1000L). Use halogen tablets.',
    );

    final activeStation = RiverBasinHydroStationModel(
      stationId: 'kosi_baltara',
      stationName: 'Baltara Gauge Station',
      riverName: 'Kosi River',
      stateName: 'Bihar',
      latitude: 25.68,
      longitude: 86.68,
      cwcDivision: 'Middle Ganga Division III, Patna',
      floodStageTier: 'DANGER_STAGE',
      benchmarks: benchmarks,
      ratingCurve: ratingCurve,
      embankmentSafety: embankmentSafety,
      gumbelFrequency: gumbel,
      directives: directives,
    );

    return HydroRatingResponseModel(
      timestamp: DateTime.now().toUtc().toIso8601String(),
      activeStation: activeStation,
      allStations: [
        BasinSummaryModel(
          stationId: 'kosi_baltara',
          stationName: 'Baltara Gauge Station',
          riverName: 'Kosi River',
          stateName: 'Bihar',
          stageHeightM: 35.15,
          dangerLevelM: 34.75,
          floodStageTier: 'DANGER_STAGE',
          freeboardMarginM: 2.65,
          pipingRiskTier: 'SAFE_STABLE',
        ),
        BasinSummaryModel(
          stationId: 'brahmaputra_pandu',
          stationName: 'Pandu Gauge Station',
          riverName: 'Brahmaputra River',
          stateName: 'Assam',
          stageHeightM: 50.12,
          dangerLevelM: 49.68,
          floodStageTier: 'DANGER_STAGE',
          freeboardMarginM: 2.68,
          pipingRiskTier: 'HIGH_SANDBOIL_RISK',
        ),
        BasinSummaryModel(
          stationId: 'ganga_farakka',
          stationName: 'Farakka Barrage Gauge Site',
          riverName: 'Ganga River',
          stateName: 'West Bengal',
          stageHeightM: 21.80,
          dangerLevelM: 22.25,
          floodStageTier: 'WARNING_STAGE',
          freeboardMarginM: 3.40,
          pipingRiskTier: 'SAFE_STABLE',
        ),
        BasinSummaryModel(
          stationId: 'godavari_dowleswaram',
          stationName: 'Sir Arthur Cotton Barrage',
          riverName: 'Godavari River',
          stateName: 'Andhra Pradesh',
          stageHeightM: 14.60,
          dangerLevelM: 15.25,
          floodStageTier: 'WARNING_STAGE',
          freeboardMarginM: 4.90,
          pipingRiskTier: 'SAFE_STABLE',
        ),
        BasinSummaryModel(
          stationId: 'mahanadi_mundali',
          stationName: 'Mundali Barrage Gauge Station',
          riverName: 'Mahanadi River',
          stateName: 'Odisha',
          stageHeightM: 25.10,
          dangerLevelM: 26.25,
          floodStageTier: 'ABOVE_NORMAL',
          freeboardMarginM: 3.80,
          pipingRiskTier: 'SAFE_STABLE',
        ),
        BasinSummaryModel(
          stationId: 'yamuna_delhi',
          stationName: 'Old Railway Bridge (ORB)',
          riverName: 'Yamuna River',
          stateName: 'Delhi NCR',
          stageHeightM: 205.85,
          dangerLevelM: 205.33,
          floodStageTier: 'DANGER_STAGE',
          freeboardMarginM: 3.65,
          pipingRiskTier: 'SAFE_STABLE',
        ),
        BasinSummaryModel(
          stationId: 'narmada_golden_bridge',
          stationName: 'Golden Bridge Gauge Site',
          riverName: 'Narmada River',
          stateName: 'Gujarat',
          stageHeightM: 8.45,
          dangerLevelM: 9.14,
          floodStageTier: 'WARNING_STAGE',
          freeboardMarginM: 5.75,
          pipingRiskTier: 'SAFE_STABLE',
        ),
      ],
      vernacularBulletins: {
        'EN': 'CWC & IMD FLOOD BULLETIN: Kosi River at Baltara is flowing at 35.15m MSL (Danger Level: 34.75m). Rating curve discharge: 2478.4 cumecs. Embankment freeboard margin is 2.65m. Riparian communities in low-lying diaras must evacuate to designated shelters.',
        'HI': 'केंद्रीय जल आयोग (CWC) एवं IMD बाढ़ चेतावनी: बलतारा पर कोसी नदी का जलस्तर 35.15 मीटर MSL पर प्रवाहित हो रहा है (खतरा निशान: 34.75 मीटर)। अनुमानित जल बहाव 2478.4 क्यूमेक्स है। दियारा क्षेत्र के निवासी तत्काल सुरक्षित बाढ़ आश्रयों में शरण लें।',
        'AS': 'কেন্দ্ৰীয় জল আয়োগ (CWC) আৰু IMD বান সতৰ্কবাৰ্তা: নদীৰ জলস্তৰ বৃদ্ধি পাইছে। দাঁতিকাষৰীয়া অঞ্চলৰ ৰাইজক উচ্চ সুৰক্ষিত স্থানলৈ যাবলৈ আহ্বান।',
        'BN': 'কেন্দ্রীয় জল কমিশন (CWC) ও IMD বন্যা বুলেটিন: নদী তীরবর্তী চর ও প্লাবনভূমির বাসিন্দাদের অবিলম্বে নিরাপদ আশ্রয়কেন্দ্রে পৌঁছানোর পরামর্শ দেওয়া হচ্ছে।',
        'OD': 'କେନ୍ଦ୍ରୀୟ ଜଳ ଆୟୋଗ (CWC) ଓ IMD ବନ୍ୟା ସତର୍କତା: ତଳିଆ ଅଞ୍ଚଳ ବାସୀ ସୁରକ୍ଷିତ ଆଶ୍ରୟସ୍ଥଳକୁ ଯାଆନ୍ତୁ।',
        'TE': 'కేంద్ర జల సంఘం (CWC) & IMD వరద హెచ్చరిక: లంక గ్రామాలు మరియు లోతట్టు ప్రాంతాల ప్రజలు వెంటనే సహాయక శిబిరాలకు తరలివెళ్లాలి.',
        'GU': 'સેન્ટ્રલ વોટર કમિશન (CWC) અને IMD પૂર બુલેટિન: નદીકાંઠાના નીચાણવાળા વિસ્તારોના લોકોએ તાત્કાલિક સુરક્ષિત સ્થળે ખસી જવું.',
      },
      dataSource: 'Central Water Commission (CWC Flood Forecast Network) & IMD Hydromet Division [Offline Baseline]',
      isOfflineCached: true,
    );
  }
}
