// Models for IMD & CWC Flash Drought, Rapid Soil Desiccation
// & Atmospheric Evaporative Demand Engine (FLASH-DROUGHT).

class AtmosphericEvaporativeDemandTelemetryModel {
  final double referenceEvapotranspirationE0MmDay;
  final double eddi2week;
  final double eddi4week;
  final String evaporativeDemandTier;
  final double vaporPressureDeficitKpa;
  final double airTemperatureMaxC;
  final double tempMaxDepartureC;
  final double solarRadiationMjM2Day;
  final double windSpeed2mMs;

  const AtmosphericEvaporativeDemandTelemetryModel({
    required this.referenceEvapotranspirationE0MmDay,
    required this.eddi2week,
    required this.eddi4week,
    required this.evaporativeDemandTier,
    required this.vaporPressureDeficitKpa,
    required this.airTemperatureMaxC,
    required this.tempMaxDepartureC,
    required this.solarRadiationMjM2Day,
    required this.windSpeed2mMs,
  });

  factory AtmosphericEvaporativeDemandTelemetryModel.fromJson(
      Map<String, dynamic> json) {
    return AtmosphericEvaporativeDemandTelemetryModel(
      referenceEvapotranspirationE0MmDay:
          (json['reference_evapotranspiration_e0_mm_day'] as num?)?.toDouble() ??
              6.5,
      eddi2week: (json['eddi_2week'] as num?)?.toDouble() ?? 1.65,
      eddi4week: (json['eddi_4week'] as num?)?.toDouble() ?? 1.45,
      evaporativeDemandTier: json['evaporative_demand_tier'] as String? ??
          'SEVERE_EVAPORATIVE_DEMAND',
      vaporPressureDeficitKpa:
          (json['vapor_pressure_deficit_kpa'] as num?)?.toDouble() ?? 2.8,
      airTemperatureMaxC:
          (json['air_temperature_max_c'] as num?)?.toDouble() ?? 38.5,
      tempMaxDepartureC:
          (json['temp_max_departure_c'] as num?)?.toDouble() ?? 4.2,
      solarRadiationMjM2Day:
          (json['solar_radiation_mj_m2_day'] as num?)?.toDouble() ?? 24.5,
      windSpeed2mMs: (json['wind_speed_2m_ms'] as num?)?.toDouble() ?? 4.2,
    );
  }

  Map<String, dynamic> toJson() => {
        'reference_evapotranspiration_e0_mm_day':
            referenceEvapotranspirationE0MmDay,
        'eddi_2week': eddi2week,
        'eddi_4week': eddi4week,
        'evaporative_demand_tier': evaporativeDemandTier,
        'vapor_pressure_deficit_kpa': vaporPressureDeficitKpa,
        'air_temperature_max_c': airTemperatureMaxC,
        'temp_max_departure_c': tempMaxDepartureC,
        'solar_radiation_mj_m2_day': solarRadiationMjM2Day,
        'wind_speed_2m_ms': windSpeed2mMs,
      };
}

class SoilMoistureDesiccationMetricsModel {
  final double topsoilMoisture010cmPct;
  final double rootzoneMoisture1040cmPct;
  final double rootzonePercentile;
  final double percentileDrop14days;
  final double desiccationRatePctPerDay;
  final String desiccationVelocity;
  final double evaporativeStressIndexEsi;
  final int consecutiveRainlessDays;

  const SoilMoistureDesiccationMetricsModel({
    required this.topsoilMoisture010cmPct,
    required this.rootzoneMoisture1040cmPct,
    required this.rootzonePercentile,
    required this.percentileDrop14days,
    required this.desiccationRatePctPerDay,
    required this.desiccationVelocity,
    required this.evaporativeStressIndexEsi,
    required this.consecutiveRainlessDays,
  });

  factory SoilMoistureDesiccationMetricsModel.fromJson(
      Map<String, dynamic> json) {
    return SoilMoistureDesiccationMetricsModel(
      topsoilMoisture010cmPct:
          (json['topsoil_moisture_0_10cm_pct'] as num?)?.toDouble() ?? 10.5,
      rootzoneMoisture1040cmPct:
          (json['rootzone_moisture_10_40cm_pct'] as num?)?.toDouble() ?? 16.2,
      rootzonePercentile:
          (json['rootzone_percentile'] as num?)?.toDouble() ?? 12.0,
      percentileDrop14days:
          (json['percentile_drop_14days'] as num?)?.toDouble() ?? 32.0,
      desiccationRatePctPerDay:
          (json['desiccation_rate_pct_per_day'] as num?)?.toDouble() ?? 1.15,
      desiccationVelocity:
          json['desiccation_velocity'] as String? ?? 'ACCELERATED_HIGH',
      evaporativeStressIndexEsi:
          (json['evaporative_stress_index_esi'] as num?)?.toDouble() ?? 0.28,
      consecutiveRainlessDays: json['consecutive_rainless_days'] as int? ?? 16,
    );
  }

  Map<String, dynamic> toJson() => {
        'topsoil_moisture_0_10cm_pct': topsoilMoisture010cmPct,
        'rootzone_moisture_10_40cm_pct': rootzoneMoisture1040cmPct,
        'rootzone_percentile': rootzonePercentile,
        'percentile_drop_14days': percentileDrop14days,
        'desiccation_rate_pct_per_day': desiccationRatePctPerDay,
        'desiccation_velocity': desiccationVelocity,
        'evaporative_stress_index_esi': evaporativeStressIndexEsi,
        'consecutive_rainless_days': consecutiveRainlessDays,
      };
}

class CropPhenologyVulnerabilityIndexModel {
  final String primaryCrop;
  final String currentGrowthStage;
  final String vulnerabilityTier;
  final double yieldLossRiskPct;
  final double damageMultiplier;
  final String transpirationalStressLabel;

  const CropPhenologyVulnerabilityIndexModel({
    required this.primaryCrop,
    required this.currentGrowthStage,
    required this.vulnerabilityTier,
    required this.yieldLossRiskPct,
    required this.damageMultiplier,
    required this.transpirationalStressLabel,
  });

  factory CropPhenologyVulnerabilityIndexModel.fromJson(
      Map<String, dynamic> json) {
    return CropPhenologyVulnerabilityIndexModel(
      primaryCrop: json['primary_crop'] as String? ?? 'Soybean',
      currentGrowthStage: json['current_growth_stage'] as String? ??
          'R1-R3 Early Flowering & Pod Initiation',
      vulnerabilityTier: json['vulnerability_tier'] as String? ??
          'CRITICAL_REPRODUCTIVE_SUSCEPTIBILITY',
      yieldLossRiskPct:
          (json['yield_loss_risk_pct'] as num?)?.toDouble() ?? 45.0,
      damageMultiplier:
          (json['damage_multiplier'] as num?)?.toDouble() ?? 1.85,
      transpirationalStressLabel:
          json['transpirational_stress_label'] as String? ??
              'Severe midday floral bud abortion, petiole wilting, and stomatal closure.',
    );
  }

  Map<String, dynamic> toJson() => {
        'primary_crop': primaryCrop,
        'current_growth_stage': currentGrowthStage,
        'vulnerability_tier': vulnerabilityTier,
        'yield_loss_risk_pct': yieldLossRiskPct,
        'damage_multiplier': damageMultiplier,
        'transpirational_stress_label': transpirationalStressLabel,
      };
}

class FlashDroughtDirectivesModel {
  final String antiTranspirantSprayRecommendation;
  final String mulchingDirective;
  final String microIrrigationPulseSchedule;
  final String salvageAction;
  final List<String> actionableBulletPoints;

  const FlashDroughtDirectivesModel({
    required this.antiTranspirantSprayRecommendation,
    required this.mulchingDirective,
    required this.microIrrigationPulseSchedule,
    required this.salvageAction,
    required this.actionableBulletPoints,
  });

  factory FlashDroughtDirectivesModel.fromJson(Map<String, dynamic> json) {
    return FlashDroughtDirectivesModel(
      antiTranspirantSprayRecommendation:
          json['anti_transpirant_spray_recommendation'] as String? ??
              'Spray 1% Potassium Nitrate (KNO3) foliar solution early morning.',
      mulchingDirective: json['mulching_directive'] as String? ??
          'Execute straw mulching (5 tonnes/ha) or dust mulching to seal vertical soil cracks.',
      microIrrigationPulseSchedule:
          json['micro_irrigation_pulse_schedule'] as String? ??
              'DEFICIT PULSE IRRIGATION: Schedule micro-irrigation strictly during nocturnal hours (22:00-05:00 IST).',
      salvageAction: json['salvage_action'] as String? ??
          'Thin out alternate crop rows if rainless break exceeds 21 days.',
      actionableBulletPoints: (json['actionable_bullet_points'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'anti_transpirant_spray_recommendation':
            antiTranspirantSprayRecommendation,
        'mulching_directive': mulchingDirective,
        'micro_irrigation_pulse_schedule': microIrrigationPulseSchedule,
        'salvage_action': salvageAction,
        'actionable_bullet_points': actionableBulletPoints,
      };
}

class FlashDroughtHotspotModel {
  final String hotspotId;
  final String name;
  final List<String> districts;
  final String state;
  final double latitude;
  final double longitude;
  final String soilType;
  final List<String> primaryKharifCrops;
  final double irrigationCoveragePct;

  const FlashDroughtHotspotModel({
    required this.hotspotId,
    required this.name,
    required this.districts,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.soilType,
    required this.primaryKharifCrops,
    required this.irrigationCoveragePct,
  });

  factory FlashDroughtHotspotModel.fromJson(Map<String, dynamic> json) {
    return FlashDroughtHotspotModel(
      hotspotId: json['hotspot_id'] as String? ?? 'VIDARBHA_HOTSPOT',
      name: json['name'] as String? ?? 'Vidarbha Agro-Ecological Hotspot',
      districts: (json['districts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['Amravati', 'Yavatmal', 'Akola', 'Wardha'],
      state: json['state'] as String? ?? 'Maharashtra',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 20.9374,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 77.7796,
      soilType: json['soil_type'] as String? ??
          'Deep Black Cotton Soils (Vertisols)',
      primaryKharifCrops: (json['primary_kharif_crops'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['Soybean', 'Cotton', 'Pigeon Pea (Tur)'],
      irrigationCoveragePct:
          (json['irrigation_coverage_pct'] as num?)?.toDouble() ?? 14.5,
    );
  }

  Map<String, dynamic> toJson() => {
        'hotspot_id': hotspotId,
        'name': name,
        'districts': districts,
        'state': state,
        'latitude': latitude,
        'longitude': longitude,
        'soil_type': soilType,
        'primary_kharif_crops': primaryKharifCrops,
        'irrigation_coverage_pct': irrigationCoveragePct,
      };
}

class HotspotSummaryModel {
  final String hotspotId;
  final String name;
  final String state;
  final String intensityTier;
  final double eddi2week;
  final double rootzonePercentile;
  final String primaryCrop;

  const HotspotSummaryModel({
    required this.hotspotId,
    required this.name,
    required this.state,
    required this.intensityTier,
    required this.eddi2week,
    required this.rootzonePercentile,
    required this.primaryCrop,
  });

  factory HotspotSummaryModel.fromJson(Map<String, dynamic> json) {
    return HotspotSummaryModel(
      hotspotId: json['hotspot_id'] as String? ?? 'VIDARBHA_HOTSPOT',
      name: json['name'] as String? ?? 'Vidarbha Hotspot',
      state: json['state'] as String? ?? 'Maharashtra',
      intensityTier: json['intensity_tier'] as String? ?? 'SEVERE_FLASH_DROUGHT',
      eddi2week: (json['eddi_2week'] as num?)?.toDouble() ?? 1.65,
      rootzonePercentile:
          (json['rootzone_percentile'] as num?)?.toDouble() ?? 12.0,
      primaryCrop: json['primary_crop'] as String? ?? 'Soybean',
    );
  }

  Map<String, dynamic> toJson() => {
        'hotspot_id': hotspotId,
        'name': name,
        'state': state,
        'intensity_tier': intensityTier,
        'eddi_2week': eddi2week,
        'rootzone_percentile': rootzonePercentile,
        'primary_crop': primaryCrop,
      };
}

class FlashDroughtResponseModel {
  final FlashDroughtHotspotModel hotspot;
  final String assessmentTimestamp;
  final String overallIntensityTier;
  final bool rapidIntensificationDetected;
  final AtmosphericEvaporativeDemandTelemetryModel atmosphericDemand;
  final SoilMoistureDesiccationMetricsModel soilDesiccation;
  final CropPhenologyVulnerabilityIndexModel cropVulnerability;
  final FlashDroughtDirectivesModel directives;
  final List<HotspotSummaryModel> monitoredHotspots;
  final Map<String, String> vernacularBulletins;
  final Map<String, String> metadata;

  const FlashDroughtResponseModel({
    required this.hotspot,
    required this.assessmentTimestamp,
    required this.overallIntensityTier,
    required this.rapidIntensificationDetected,
    required this.atmosphericDemand,
    required this.soilDesiccation,
    required this.cropVulnerability,
    required this.directives,
    required this.monitoredHotspots,
    required this.vernacularBulletins,
    required this.metadata,
  });

  factory FlashDroughtResponseModel.fromJson(Map<String, dynamic> json) {
    return FlashDroughtResponseModel(
      hotspot: json['hotspot'] != null
          ? FlashDroughtHotspotModel.fromJson(
              json['hotspot'] as Map<String, dynamic>)
          : FlashDroughtResponseModel.defaultFallback().hotspot,
      assessmentTimestamp: json['assessment_timestamp'] as String? ??
          DateTime.now().toUtc().toIso8601String(),
      overallIntensityTier: json['overall_intensity_tier'] as String? ??
          'SEVERE_FLASH_DROUGHT',
      rapidIntensificationDetected:
          json['rapid_intensification_detected'] as bool? ?? true,
      atmosphericDemand: json['atmospheric_demand'] != null
          ? AtmosphericEvaporativeDemandTelemetryModel.fromJson(
              json['atmospheric_demand'] as Map<String, dynamic>)
          : FlashDroughtResponseModel.defaultFallback().atmosphericDemand,
      soilDesiccation: json['soil_desiccation'] != null
          ? SoilMoistureDesiccationMetricsModel.fromJson(
              json['soil_desiccation'] as Map<String, dynamic>)
          : FlashDroughtResponseModel.defaultFallback().soilDesiccation,
      cropVulnerability: json['crop_vulnerability'] != null
          ? CropPhenologyVulnerabilityIndexModel.fromJson(
              json['crop_vulnerability'] as Map<String, dynamic>)
          : FlashDroughtResponseModel.defaultFallback().cropVulnerability,
      directives: json['directives'] != null
          ? FlashDroughtDirectivesModel.fromJson(
              json['directives'] as Map<String, dynamic>)
          : FlashDroughtResponseModel.defaultFallback().directives,
      monitoredHotspots: (json['monitored_hotspots'] as List<dynamic>?)
              ?.map((e) =>
                  HotspotSummaryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          FlashDroughtResponseModel.defaultFallback().monitoredHotspots,
      vernacularBulletins: (json['vernacular_bulletins'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          FlashDroughtResponseModel.defaultFallback().vernacularBulletins,
      metadata: (json['metadata'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          FlashDroughtResponseModel.defaultFallback().metadata,
    );
  }

  Map<String, dynamic> toJson() => {
        'hotspot': hotspot.toJson(),
        'assessment_timestamp': assessmentTimestamp,
        'overall_intensity_tier': overallIntensityTier,
        'rapid_intensification_detected': rapidIntensificationDetected,
        'atmospheric_demand': atmosphericDemand.toJson(),
        'soil_desiccation': soilDesiccation.toJson(),
        'crop_vulnerability': cropVulnerability.toJson(),
        'directives': directives.toJson(),
        'monitored_hotspots':
            monitoredHotspots.map((e) => e.toJson()).toList(),
        'vernacular_bulletins': vernacularBulletins,
        'metadata': metadata,
      };

  factory FlashDroughtResponseModel.defaultFallback() {
    return const FlashDroughtResponseModel(
      hotspot: FlashDroughtHotspotModel(
        hotspotId: 'VIDARBHA_HOTSPOT',
        name: 'Vidarbha Agro-Ecological Hotspot',
        districts: ['Amravati', 'Yavatmal', 'Akola', 'Wardha'],
        state: 'Maharashtra',
        latitude: 20.9374,
        longitude: 77.7796,
        soilType: 'Deep Black Cotton Soils (Vertisols)',
        primaryKharifCrops: ['Soybean', 'Cotton', 'Pigeon Pea (Tur)'],
        irrigationCoveragePct: 14.5,
      ),
      assessmentTimestamp: '2026-09-12T06:00:00Z',
      overallIntensityTier: 'SEVERE_FLASH_DROUGHT',
      rapidIntensificationDetected: true,
      atmosphericDemand: AtmosphericEvaporativeDemandTelemetryModel(
        referenceEvapotranspirationE0MmDay: 6.85,
        eddi2week: 1.75,
        eddi4week: 1.50,
        evaporativeDemandTier: 'SEVERE_EVAPORATIVE_DEMAND',
        vaporPressureDeficitKpa: 2.85,
        airTemperatureMaxC: 38.6,
        tempMaxDepartureC: 4.2,
        solarRadiationMjM2Day: 24.2,
        windSpeed2mMs: 4.1,
      ),
      soilDesiccation: SoilMoistureDesiccationMetricsModel(
        topsoilMoisture010cmPct: 10.2,
        rootzoneMoisture1040cmPct: 15.8,
        rootzonePercentile: 11.5,
        percentileDrop14days: 34.0,
        desiccationRatePctPerDay: 1.25,
        desiccationVelocity: 'CRITICAL_EXPLOSIVE',
        evaporativeStressIndexEsi: 0.24,
        consecutiveRainlessDays: 17,
      ),
      cropVulnerability: CropPhenologyVulnerabilityIndexModel(
        primaryCrop: 'Soybean',
        currentGrowthStage: 'R1-R3 Early Flowering & Pod Initiation',
        vulnerabilityTier: 'CRITICAL_REPRODUCTIVE_SUSCEPTIBILITY',
        yieldLossRiskPct: 48.0,
        damageMultiplier: 1.85,
        transpirationalStressLabel:
            'Severe midday floral bud abortion, petiole wilting, and stomatal closure.',
      ),
      directives: FlashDroughtDirectivesModel(
        antiTranspirantSprayRecommendation:
            'Spray 1% Potassium Nitrate (KNO3) or 2% Urea foliar solution early morning (06:00-08:30 IST) to maintain canopy cell turgor.',
        mulchingDirective:
            'Apply straw/crop residue mulching (5 tonnes/ha) or execute shallow inter-culture dust mulching on Deep Black Cotton Soils to seal vertical cracks.',
        microIrrigationPulseSchedule:
            'DEFICIT PULSE IRRIGATION: Restrict micro-irrigation/sprinklers strictly to nocturnal hours (22:00 to 05:00 IST) in 2-hour split pulses.',
        salvageAction:
            'If rainless break exceeds 21 days, thin out every third crop row (alternate row removal) to conserve remaining subsoil moisture.',
        actionableBulletPoints: [
          'Spray 1% Potassium Nitrate (KNO3) or 2% Urea foliar solution early morning (06:00-08:30 IST).',
          'Execute shallow inter-culture dust mulching to break capillary soil pore evaporation.',
          'DEFICIT PULSE IRRIGATION: Restrict micro-irrigation strictly to nocturnal hours (22:00 to 05:00 IST).',
          'Thin out alternate crop rows if dry spell exceeds 21 days, utilizing green biomass as cattle fodder.',
          'Protect sensitive phenological phase (R1-R3 Early Flowering) against irreversible flower drop.',
        ],
      ),
      monitoredHotspots: [
        HotspotSummaryModel(
          hotspotId: 'VIDARBHA_HOTSPOT',
          name: 'Vidarbha Hotspot',
          state: 'Maharashtra',
          intensityTier: 'SEVERE_FLASH_DROUGHT',
          eddi2week: 1.75,
          rootzonePercentile: 11.5,
          primaryCrop: 'Soybean',
        ),
        HotspotSummaryModel(
          hotspotId: 'MARATHWADA_HOTSPOT',
          name: 'Marathwada Basin',
          state: 'Maharashtra',
          intensityTier: 'SEVERE_FLASH_DROUGHT',
          eddi2week: 1.62,
          rootzonePercentile: 14.0,
          primaryCrop: 'Cotton',
        ),
        HotspotSummaryModel(
          hotspotId: 'RAYALASEEMA_BASIN',
          name: 'Rayalaseema Basin',
          state: 'Andhra Pradesh',
          intensityTier: 'EXTREME_FLASH_DROUGHT',
          eddi2week: 2.10,
          rootzonePercentile: 7.5,
          primaryCrop: 'Groundnut',
        ),
        HotspotSummaryModel(
          hotspotId: 'NORTH_INTERIOR_KARNATAKA',
          name: 'North Interior Karnataka',
          state: 'Karnataka',
          intensityTier: 'MODERATE_FLASH_DROUGHT',
          eddi2week: 1.25,
          rootzonePercentile: 24.0,
          primaryCrop: 'Maize',
        ),
        HotspotSummaryModel(
          hotspotId: 'SAURASHTRA_PENINSULA',
          name: 'Saurashtra Peninsula',
          state: 'Gujarat',
          intensityTier: 'SEVERE_FLASH_DROUGHT',
          eddi2week: 1.80,
          rootzonePercentile: 13.0,
          primaryCrop: 'Groundnut',
        ),
        HotspotSummaryModel(
          hotspotId: 'BUNDELKHAND_PLATEAU',
          name: 'Bundelkhand Plateau',
          state: 'Uttar Pradesh',
          intensityTier: 'MODERATE_FLASH_DROUGHT',
          eddi2week: 1.15,
          rootzonePercentile: 26.5,
          primaryCrop: 'Black Gram',
        ),
        HotspotSummaryModel(
          hotspotId: 'TELANGANA_DRYLANDS',
          name: 'Telangana Drylands',
          state: 'Telangana',
          intensityTier: 'SEVERE_FLASH_DROUGHT',
          eddi2week: 1.55,
          rootzonePercentile: 16.0,
          primaryCrop: 'Cotton',
        ),
      ],
      vernacularBulletins: {
        'en':
            'IMD-CWC FLASH DROUGHT ALERT for Vidarbha Agro-Ecological Hotspot: Rapid drought intensification detected (SEVERE_FLASH_DROUGHT). Evaporative Demand EDDI is +1.75, root-zone soil moisture has plummeted by 34.0% in 14 days (VPD 2.85 kPa). Immediate application of 1% KNO3 foliar spray and night pulse irrigation mandated for Soybean.',
        'hi':
            'आईएमडी-सीडब्ल्यूसी आकस्मिक सूखा चेतावनी (विदर्भ कृषि परिक्षेत्र): तीव्र गति से भूमि में नमी ह्रास (SEVERE_FLASH_DROUGHT) दर्ज किया गया है। वाष्पोत्सर्जन मांग सूचकांक (EDDI) +1.75 तथा जड़ क्षेत्र नमी में 14 दिनों में 34.0% की गिरावट आई है। सोयाबीन की फसल में तत्काल 1% पोटेशियम नाइट्रेट का पर्णीय छिड़काव करें।',
        'mr':
            'आयएमडी-सीडब्ल्यूसी अचानक दुष्काळ चेतावणी (विदर्भ परिक्षेत्र): वेगाने जमिनीतील ओलावा नष्ट होत असून तीव्रता \'SEVERE_FLASH_DROUGHT\' आहे. वातावरणातील बाष्पीभवन तहान (EDDI) +1.75 असून १४ दिवसांत मुळांच्या थरातील ओलावा ३४.०% घसरला आहे. सोयाबीन पिकासाठी १% पोटॅशियम नायट्रेट फवारणी व रात्रीचे ठिबक सिंचन तातडीने करा.',
        'te':
            'ఐఎండి-సిడబ్ల్యుసి ఫ్లాష్ కరువు హెచ్చరిక (విదర్భ ప్రాంతం): నేలలో తేమ అత్యంత వేగంగా ఆవిరైపోతున్నది (SEVERE_FLASH_DROUGHT). బాష్పోత్సేక సూచిక EDDI +1.75, 14 రోజుల్లో వేరు మండల తేమ 34.0% పడిపోయింది. సోయాబీన్ పంట రక్షణకు వెంటనే 1% పొటాషియం నైట్రేట్ పిచికారీ చేయండి.',
        'kn':
            'ಐಎಂಡಿ-ಸಿಡಬ್ಲ್ಯೂಸಿ ಫ್ಲ್ಯಾಶ್ ಬರ ಮುನ್ನೆಚ್ಚರಿಕೆ (ವಿದರ್ಭ ವಲಯ): ಮಣ್ಣಿನ ತೇವಾಂಶವು ಅತಿ ವೇಗವಾಗಿ ಇಳಿಕೆಯಾಗುತ್ತಿದೆ (SEVERE_FLASH_DROUGHT). ಬಾಷ್ಪೀಕರಣ ಸೂಚ್ಯಂಕ EDDI +1.75 ಮತ್ತು 14 ದಿನಗಳಲ್ಲಿ ಬೇರಿನ ವಲಯದ ತೇವಾಂಶ 34.0% ಕುಸಿದಿದೆ. ಸೋಯಾಬೀನ್ ಬೆಳೆಗೆ ತಕ್ಷಣ 1% ಪೊಟ್ಯಾಸಿಯಮ್ ನೈಟ್ರೇಟ್ ಸಿಂಪಡಿಸಿ.',
        'gu':
            'આઈએમડી-સીડબ્લ્યુસી ફ્લેશ દુષ્કાળ ચેતવણી (વિદર્ભ વિસ્તાર): જમીનમાં ભેજનું ઝડપી શોષણ (SEVERE_FLASH_DROUGHT) નોંધાયું છે. બાષ્પીભવન તરસ સૂચકાંક EDDI +1.75 અને ૧૪ દિવસમાં મૂળ વિસ્તારના ભેજમાં 34.0% નો ઘટાડો થયો છે. સોયાબીન પાક માટે ૧% પોટેશિયમ નાઇટ્રેટનો છંટકાવ કરો.',
        'bn':
            'আইএমডি-সিডব্লিউসি ফ্ল্যাশ খরা সতর্কতা (বিদর্ভ অঞ্চল): মাটিতে আর্দ্রতার দ্রুত হ্রাস (SEVERE_FLASH_DROUGHT) শনাক্ত হয়েছে। বাষ্পীভবন চাহিদা EDDI +1.75 এবং ১৪ দিনে শিকড় অঞ্চলের আর্দ্রতা ৩৪.০% কমেছে। সয়াবিন ফসলে অবিলম্বে ১% পটাশিয়াম নাইট্রেট স্প্রে করুন।',
      },
      metadata: {
        'source_authority':
            'IMD Agromet Division, Central Water Commission (CWC) & ICAR-CRIDA',
        'scientific_framework':
            'Evaporative Demand Drought Index (EDDI - Hobbins et al.) & Flash Drought Rapid Intensification (Otkin & Mishra et al.)',
        'evapotranspiration_standard':
            'FAO-56 Penman-Monteith Net Radiation & Vapor Pressure Deficit Formulation',
        'agronomic_guidelines':
            'ICAR-CRIDA National Innovations on Climate Resilient Agriculture (NICRA) Contingency Protocols',
      },
    );
  }
}
