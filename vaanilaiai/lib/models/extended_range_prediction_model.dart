class WeeklyErpForecastModel {
  final int weekNumber;
  final String dateRangeLabel;
  final double rainfallLpaDeparturePct;
  final String departureTier;
  final double rainfallForecastMm;
  final double normalLpaRainfallMm;
  final double maxTempAnomalyC;
  final double minTempAnomalyC;
  final double heatwaveColdwaveProbabilityPct;
  final String monsoonSpellState;

  const WeeklyErpForecastModel({
    required this.weekNumber,
    required this.dateRangeLabel,
    required this.rainfallLpaDeparturePct,
    required this.departureTier,
    required this.rainfallForecastMm,
    required this.normalLpaRainfallMm,
    required this.maxTempAnomalyC,
    required this.minTempAnomalyC,
    required this.heatwaveColdwaveProbabilityPct,
    required this.monsoonSpellState,
  });

  factory WeeklyErpForecastModel.fromJson(Map<String, dynamic> json) {
    return WeeklyErpForecastModel(
      weekNumber: json['week_number'] as int? ?? 1,
      dateRangeLabel: json['date_range_label'] as String? ?? 'Week 1',
      rainfallLpaDeparturePct:
          (json['rainfall_lpa_departure_pct'] as num?)?.toDouble() ?? 0.0,
      departureTier: json['departure_tier'] as String? ?? 'NORMAL',
      rainfallForecastMm:
          (json['rainfall_forecast_mm'] as num?)?.toDouble() ?? 30.0,
      normalLpaRainfallMm:
          (json['normal_lpa_rainfall_mm'] as num?)?.toDouble() ?? 35.0,
      maxTempAnomalyC:
          (json['max_temp_anomaly_c'] as num?)?.toDouble() ?? 0.0,
      minTempAnomalyC:
          (json['min_temp_anomaly_c'] as num?)?.toDouble() ?? 0.0,
      heatwaveColdwaveProbabilityPct:
          (json['heatwave_coldwave_probability_pct'] as num?)?.toDouble() ?? 0.0,
      monsoonSpellState: json['monsoon_spell_state'] as String? ?? 'NORMAL_MONSOON',
    );
  }

  Map<String, dynamic> toJson() => {
        'week_number': weekNumber,
        'date_range_label': dateRangeLabel,
        'rainfall_lpa_departure_pct': rainfallLpaDeparturePct,
        'departure_tier': departureTier,
        'rainfall_forecast_mm': rainfallForecastMm,
        'normal_lpa_rainfall_mm': normalLpaRainfallMm,
        'max_temp_anomaly_c': maxTempAnomalyC,
        'min_temp_anomaly_c': minTempAnomalyC,
        'heatwave_coldwave_probability_pct': heatwaveColdwaveProbabilityPct,
        'monsoon_spell_state': monsoonSpellState,
      };
}

class IntraSeasonalPulseTelemetryModel {
  final String bsisoMode;
  final int bsisoActivePhase;
  final double bsisoAmplitude;
  final double northwardPropagationSpeedDegPerDay;
  final String mjoPhase;
  final double mjoAmplitude;
  final double findlaterJetSpeedKt;
  final double monsoonTroughPositionLatitude;
  final bool breakSpellRisk;

  const IntraSeasonalPulseTelemetryModel({
    required this.bsisoMode,
    required this.bsisoActivePhase,
    required this.bsisoAmplitude,
    required this.northwardPropagationSpeedDegPerDay,
    required this.mjoPhase,
    required this.mjoAmplitude,
    required this.findlaterJetSpeedKt,
    required this.monsoonTroughPositionLatitude,
    required this.breakSpellRisk,
  });

  factory IntraSeasonalPulseTelemetryModel.fromJson(Map<String, dynamic> json) {
    return IntraSeasonalPulseTelemetryModel(
      bsisoMode: json['bsiso_mode'] as String? ?? 'BSISO_1_CANONICAL_30_60D',
      bsisoActivePhase: json['bsiso_active_phase'] as int? ?? 7,
      bsisoAmplitude: (json['bsiso_amplitude'] as num?)?.toDouble() ?? 1.75,
      northwardPropagationSpeedDegPerDay:
          (json['northward_propagation_speed_deg_per_day'] as num?)?.toDouble() ?? 1.25,
      mjoPhase: json['mjo_phase'] as String? ?? 'PHASE_6_WESTERN_PACIFIC',
      mjoAmplitude: (json['mjo_amplitude'] as num?)?.toDouble() ?? 1.45,
      findlaterJetSpeedKt:
          (json['findlater_jet_speed_kt'] as num?)?.toDouble() ?? 18.5,
      monsoonTroughPositionLatitude:
          (json['monsoon_trough_position_latitude'] as num?)?.toDouble() ?? 28.5,
      breakSpellRisk: json['break_spell_risk'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'bsiso_mode': bsisoMode,
        'bsiso_active_phase': bsisoActivePhase,
        'bsiso_amplitude': bsisoAmplitude,
        'northward_propagation_speed_deg_per_day':
            northwardPropagationSpeedDegPerDay,
        'mjo_phase': mjoPhase,
        'mjo_amplitude': mjoAmplitude,
        'findlater_jet_speed_kt': findlaterJetSpeedKt,
        'monsoon_trough_position_latitude': monsoonTroughPositionLatitude,
        'break_spell_risk': breakSpellRisk,
      };
}

class IcarDistrictContingencyModel {
  final String stressLevel;
  final String sowingWindowStatus;
  final List<String> contingencyCropAlternatives;
  final String irrigationMitigationDirective;
  final String inSituMoistureConservation;
  final String standingCropIntervention;

  const IcarDistrictContingencyModel({
    required this.stressLevel,
    required this.sowingWindowStatus,
    required this.contingencyCropAlternatives,
    required this.irrigationMitigationDirective,
    required this.inSituMoistureConservation,
    required this.standingCropIntervention,
  });

  factory IcarDistrictContingencyModel.fromJson(Map<String, dynamic> json) {
    return IcarDistrictContingencyModel(
      stressLevel: json['stress_level'] as String? ?? 'WARNING_PROLONGED_DRY_SPELL',
      sowingWindowStatus: json['sowing_window_status'] as String? ??
          'Mid-Season Vegetative Dry Spell in Central Rainfed Tract',
      contingencyCropAlternatives: (json['contingency_crop_alternatives'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [
            'Maintain intercropped Pigeonpea (Arhar) + Soybean in 1:2 ratio',
            'Sow drought-tolerant Greengram (BM 2003-2) in fallow patches',
          ],
      irrigationMitigationDirective: json['irrigation_mitigation_directive'] as String? ??
          'Provide protective life-saving micro-sprinkler irrigation from farm ponds (Amrit Sarovar).',
      inSituMoistureConservation: json['in_situ_moisture_conservation'] as String? ??
          'Adopt Broad Bed Furrow (BBF) or shallow intercultivation dust mulching to break capillary pores.',
      standingCropIntervention: json['standing_crop_intervention'] as String? ??
          'Foliar spray of 2% Urea or 1% Potassium Nitrate (13:0:45) on standing Soybean/Cotton.',
    );
  }

  Map<String, dynamic> toJson() => {
        'stress_level': stressLevel,
        'sowing_window_status': sowingWindowStatus,
        'contingency_crop_alternatives': contingencyCropAlternatives,
        'irrigation_mitigation_directive': irrigationMitigationDirective,
        'in_situ_moisture_conservation': inSituMoistureConservation,
        'standing_crop_intervention': standingCropIntervention,
      };
}

class ErpZoneModel {
  final String zoneId;
  final String zoneName;
  final String state;
  final String subDivisionName;
  final double latitude;
  final double longitude;
  final List<String> dominantCrops;
  final List<WeeklyErpForecastModel> fourWeekForecast;
  final IntraSeasonalPulseTelemetryModel intraSeasonalPulse;
  final IcarDistrictContingencyModel agriculturalContingency;
  final Map<String, String> vernacularBulletins;

  const ErpZoneModel({
    required this.zoneId,
    required this.zoneName,
    required this.state,
    required this.subDivisionName,
    required this.latitude,
    required this.longitude,
    required this.dominantCrops,
    required this.fourWeekForecast,
    required this.intraSeasonalPulse,
    required this.agriculturalContingency,
    required this.vernacularBulletins,
  });

  factory ErpZoneModel.fromJson(Map<String, dynamic> json) {
    return ErpZoneModel(
      zoneId: json['zone_id'] as String? ?? 'vidarbha_central_rainfed',
      zoneName: json['zone_name'] as String? ??
          'Central India Rainfed Soybean-Cotton Zone',
      state: json['state'] as String? ?? 'Maharashtra',
      subDivisionName: json['sub_division_name'] as String? ??
          'Vidarbha & West Madhya Pradesh',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 21.1458,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 79.0882,
      dominantCrops: (json['dominant_crops'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['Soybean', 'Bt Cotton', 'Pigeonpea', 'Gram'],
      fourWeekForecast: (json['four_week_forecast'] as List<dynamic>?)
              ?.map((e) =>
                  WeeklyErpForecastModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      intraSeasonalPulse: json['intra_seasonal_pulse'] != null
          ? IntraSeasonalPulseTelemetryModel.fromJson(
              json['intra_seasonal_pulse'] as Map<String, dynamic>)
          : const IntraSeasonalPulseTelemetryModel(
              bsisoMode: 'BSISO_1_CANONICAL_30_60D',
              bsisoActivePhase: 7,
              bsisoAmplitude: 1.75,
              northwardPropagationSpeedDegPerDay: 1.25,
              mjoPhase: 'PHASE_6_WESTERN_PACIFIC',
              mjoAmplitude: 1.45,
              findlaterJetSpeedKt: 18.5,
              monsoonTroughPositionLatitude: 28.5,
              breakSpellRisk: true,
            ),
      agriculturalContingency: json['agricultural_contingency'] != null
          ? IcarDistrictContingencyModel.fromJson(
              json['agricultural_contingency'] as Map<String, dynamic>)
          : const IcarDistrictContingencyModel(
              stressLevel: 'WARNING_PROLONGED_DRY_SPELL',
              sowingWindowStatus:
                  'Mid-Season Vegetative Dry Spell in Central Rainfed Tract',
              contingencyCropAlternatives: [
                'Maintain intercropped Pigeonpea + Soybean in 1:2 ratio',
                'Sow drought-tolerant Greengram in fallow patches',
              ],
              irrigationMitigationDirective:
                  'Provide protective life-saving micro-sprinkler irrigation from farm ponds.',
              inSituMoistureConservation:
                  'Adopt Broad Bed Furrow (BBF) or shallow dust mulching.',
              standingCropIntervention:
                  'Foliar spray of 2% Urea or 1% Potassium Nitrate (13:0:45).',
            ),
      vernacularBulletins:
          (json['vernacular_bulletins'] as Map<String, dynamic>?)
                  ?.map((k, v) => MapEntry(k, v.toString())) ??
              {},
    );
  }

  Map<String, dynamic> toJson() => {
        'zone_id': zoneId,
        'zone_name': zoneName,
        'state': state,
        'sub_division_name': subDivisionName,
        'latitude': latitude,
        'longitude': longitude,
        'dominant_crops': dominantCrops,
        'four_week_forecast': fourWeekForecast.map((e) => e.toJson()).toList(),
        'intra_seasonal_pulse': intraSeasonalPulse.toJson(),
        'agricultural_contingency': agriculturalContingency.toJson(),
        'vernacular_bulletins': vernacularBulletins,
      };
}

class ErpZoneSummaryModel {
  final String zoneId;
  final String zoneName;
  final String state;
  final String subDivisionName;
  final String currentMonsoonSpell;
  final double week1DeparturePct;
  final double week2DeparturePct;
  final bool contingencyAlertActive;

  const ErpZoneSummaryModel({
    required this.zoneId,
    required this.zoneName,
    required this.state,
    required this.subDivisionName,
    required this.currentMonsoonSpell,
    required this.week1DeparturePct,
    required this.week2DeparturePct,
    required this.contingencyAlertActive,
  });

  factory ErpZoneSummaryModel.fromJson(Map<String, dynamic> json) {
    return ErpZoneSummaryModel(
      zoneId: json['zone_id'] as String? ?? 'vidarbha_central_rainfed',
      zoneName: json['zone_name'] as String? ?? 'Central India',
      state: json['state'] as String? ?? 'Maharashtra',
      subDivisionName: json['sub_division_name'] as String? ?? 'Vidarbha',
      currentMonsoonSpell: json['current_monsoon_spell'] as String? ?? 'BREAK_MONSOON_CRITICAL',
      week1DeparturePct: (json['week1_departure_pct'] as num?)?.toDouble() ?? -42.0,
      week2DeparturePct: (json['week2_departure_pct'] as num?)?.toDouble() ?? -25.0,
      contingencyAlertActive: json['contingency_alert_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'zone_id': zoneId,
        'zone_name': zoneName,
        'state': state,
        'sub_division_name': subDivisionName,
        'current_monsoon_spell': currentMonsoonSpell,
        'week1_departure_pct': week1DeparturePct,
        'week2_departure_pct': week2DeparturePct,
        'contingency_alert_active': contingencyAlertActive,
      };
}

class ErpResponseModel {
  final String zoneId;
  final String zoneName;
  final String state;
  final ErpZoneModel currentZone;
  final List<ErpZoneSummaryModel> allZones;
  final double mmeModelConsensusPct;
  final String lastUpdatedUtc;
  final String dataSource;

  const ErpResponseModel({
    required this.zoneId,
    required this.zoneName,
    required this.state,
    required this.currentZone,
    required this.allZones,
    required this.mmeModelConsensusPct,
    required this.lastUpdatedUtc,
    required this.dataSource,
  });

  factory ErpResponseModel.fromJson(Map<String, dynamic> json) {
    return ErpResponseModel(
      zoneId: json['zone_id'] as String? ?? 'vidarbha_central_rainfed',
      zoneName: json['zone_name'] as String? ??
          'Central India Rainfed Soybean-Cotton Zone',
      state: json['state'] as String? ?? 'Maharashtra',
      currentZone: json['current_zone'] != null
          ? ErpZoneModel.fromJson(json['current_zone'] as Map<String, dynamic>)
          : ErpResponseModel.defaultFallback().currentZone,
      allZones: (json['all_zones'] as List<dynamic>?)
              ?.map((e) =>
                  ErpZoneSummaryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          ErpResponseModel.defaultFallback().allZones,
      mmeModelConsensusPct:
          (json['mme_model_consensus_pct'] as num?)?.toDouble() ?? 85.5,
      lastUpdatedUtc: json['last_updated_utc'] as String? ??
          DateTime.now().toUtc().toIso8601String(),
      dataSource: json['data_source'] as String? ??
          'IMD-NCMRWF-IITM Extended Range Multi-Model Ensemble (CFSv2 / NCUM-ER) & ICAR-CRIDA',
    );
  }

  Map<String, dynamic> toJson() => {
        'zone_id': zoneId,
        'zone_name': zoneName,
        'state': state,
        'current_zone': currentZone.toJson(),
        'all_zones': allZones.map((e) => e.toJson()).toList(),
        'mme_model_consensus_pct': mmeModelConsensusPct,
        'last_updated_utc': lastUpdatedUtc,
        'data_source': dataSource,
      };

  factory ErpResponseModel.defaultFallback() {
    return const ErpResponseModel(
      zoneId: 'vidarbha_central_rainfed',
      zoneName: 'Central India Rainfed Soybean-Cotton Zone',
      state: 'Maharashtra',
      currentZone: ErpZoneModel(
        zoneId: 'vidarbha_central_rainfed',
        zoneName: 'Central India Rainfed Soybean-Cotton Zone',
        state: 'Maharashtra',
        subDivisionName: 'Vidarbha & West Madhya Pradesh',
        latitude: 21.1458,
        longitude: 79.0882,
        dominantCrops: [
          'Soybean (JS 335, JS 9560)',
          'Bt Cotton',
          'Pigeonpea (Tur / Arhar)',
          'Chickpea (Rabi Gram)',
        ],
        fourWeekForecast: [
          WeeklyErpForecastModel(
            weekNumber: 1,
            dateRangeLabel: 'Week 1: Days 1–7 (12–18 Sep)',
            rainfallLpaDeparturePct: -42.0,
            departureTier: 'DEFICIENT',
            rainfallForecastMm: 28.5,
            normalLpaRainfallMm: 49.1,
            maxTempAnomalyC: 1.8,
            minTempAnomalyC: 1.1,
            heatwaveColdwaveProbabilityPct: 25.0,
            monsoonSpellState: 'BREAK_MONSOON_CRITICAL',
          ),
          WeeklyErpForecastModel(
            weekNumber: 2,
            dateRangeLabel: 'Week 2: Days 8–14 (19–25 Sep)',
            rainfallLpaDeparturePct: -25.0,
            departureTier: 'DEFICIENT',
            rainfallForecastMm: 32.0,
            normalLpaRainfallMm: 42.7,
            maxTempAnomalyC: 1.2,
            minTempAnomalyC: 0.8,
            heatwaveColdwaveProbabilityPct: 15.0,
            monsoonSpellState: 'WEAK_MONSOON',
          ),
          WeeklyErpForecastModel(
            weekNumber: 3,
            dateRangeLabel: 'Week 3: Days 15–21 (26 Sep – 02 Oct)',
            rainfallLpaDeparturePct: 15.0,
            departureTier: 'NORMAL',
            rainfallForecastMm: 44.0,
            normalLpaRainfallMm: 38.3,
            maxTempAnomalyC: -0.4,
            minTempAnomalyC: 0.1,
            heatwaveColdwaveProbabilityPct: 5.0,
            monsoonSpellState: 'POST_BREAK_REVIVAL',
          ),
          WeeklyErpForecastModel(
            weekNumber: 4,
            dateRangeLabel: 'Week 4: Days 22–28 (03–09 Oct)',
            rainfallLpaDeparturePct: 28.0,
            departureTier: 'EXCESS',
            rainfallForecastMm: 46.5,
            normalLpaRainfallMm: 36.3,
            maxTempAnomalyC: -0.8,
            minTempAnomalyC: -0.2,
            heatwaveColdwaveProbabilityPct: 0.0,
            monsoonSpellState: 'ACTIVE_SURGE',
          ),
        ],
        intraSeasonalPulse: IntraSeasonalPulseTelemetryModel(
          bsisoMode: 'BSISO_1_CANONICAL_30_60D',
          bsisoActivePhase: 7,
          bsisoAmplitude: 1.75,
          northwardPropagationSpeedDegPerDay: 1.25,
          mjoPhase: 'PHASE_6_WESTERN_PACIFIC',
          mjoAmplitude: 1.45,
          findlaterJetSpeedKt: 18.5,
          monsoonTroughPositionLatitude: 28.5,
          breakSpellRisk: true,
        ),
        agriculturalContingency: IcarDistrictContingencyModel(
          stressLevel: 'WARNING_PROLONGED_DRY_SPELL',
          sowingWindowStatus:
              'Mid-Season Vegetative Dry Spell (18 Days Subdued Precipitation)',
          contingencyCropAlternatives: [
            'Maintain intercropped Pigeonpea (Arhar) + Soybean in 1:2 pattern to spread risk',
            'For barren patches, sow drought-tolerant Greengram (BM 2003-2) or Blackgram (TAU 1)',
            'Prepare field bunds for anticipated Week 3-4 monsoon revival to harvest run-off',
          ],
          irrigationMitigationDirective:
              'Provide protective life-saving micro-sprinkler irrigation from farm ponds (Amrit Sarovars / Khet Talab) during calm early mornings.',
          inSituMoistureConservation:
              'Implement Broad Bed Furrow (BBF) or shallow intercultivation dust mulching to break capillary soil pores and retard evaporative moisture loss.',
          standingCropIntervention:
              'Foliar spray of 2% Urea or 1% Potassium Nitrate (13:0:45) on standing Soybean/Cotton to mitigate moisture stress and prevent flower/boll abortion.',
        ),
        vernacularBulletins: {
          'en':
              'IMD-NCMRWF EXTENDED RANGE BULLETIN: Central India faces an active break monsoon spell in Week 1 (-42% LPA departure) and Week 2 (-25%). BSISO Phase 7 and MJO Phase 6 indicate suppressed convective activity. Strong revival indicated from Week 3 (+15%) into Week 4 (+28%). ICAR-CRIDA advises life-saving farm pond sprinkler irrigation and 1% KNO3 foliar sprays for standing Soybean and Cotton.',
          'hi':
              'आईएमडी-एनसीएमआरडब्ल्यूएफ विस्तारित पूर्वानुमान बुलेटिन: मध्य भारत में सप्ताह 1 (-42% एलपीए) और सप्ताह 2 में मानसून ब्रेक की स्थिति बनी रहेगी। सप्ताह 3 (+15%) और सप्ताह 4 (+28%) से बंगाल की खाड़ी से मानसूनी बारिश के मजबूत पुनरुद्धार की संभावना है। किसान भाई अमृत सरोवर से सोयाबीन व कपास में जीवनरक्षक सिंचाई करें एवं 1% पोटेशियम नाइट्रेट का छिड़काव करें।',
          'mr':
              'विदर्भ व मध्य भारत हवामान अंदाज: आठवडा १ (-४२% पाऊस) व आठवडा २ मध्ये मान्सून खंड (Break Monsoon) ची स्थिती राहील. आठवडा ३ (+१५%) व आठवडा ४ पासून जोरदार पाऊस परतण्याचे संकेत आहेत. शेततळ्यांमधून तुषार सिंचनाने संरक्षित पाणी द्यावे व २% युरिया किंवा १% पोटॅशियम नायट्रेटची फवारणी करावी.',
          'te':
              'విదర్భ మరియు మధ్య భారత వర్షపాత సూచన: రాబోయే 1-2 వారాలలో వర్షపాతం సాధారణం కంటే తక్కువగా (-42%) నమోదు కావచ్చు. 3-4వ వారాల్లో వర్షాలు బలంగా పుంజుకుంటాయి. పంటకుంటల ద్వారా పొలాలకు ప్రాణరక్షణ నీరు అందించండి.',
          'pa':
              'ਮੱਧ ਭਾਰਤ ਮੌਨਸੂਨ ਬੁਲੇਟਿਨ: ਪਹਿਲੇ ਅਤੇ ਦੂਜੇ ਹਫ਼ਤੇ ਦੌਰਾਨ ਮੌਨਸੂਨ ਕਮਜ਼ੋਰ ਰਹੇਗਾ। ਤੀਜੇ ਅਤੇ ਚੌਥੇ ਹਫ਼ਤੇ ਮੀਂਹ ਪੈਣ ਦੇ ਚੰਗੇ ਆਸਾਰ ਹਨ। ਨਮੀ ਬਚਾਉਣ ਲਈ ਮਲਚਿੰਗ ਅਤੇ ਸੰਜਮ ਨਾਲ ਸਿੰਚਾਈ ਕਰੋ।',
          'bn':
              'আইএমডি মধ্য ভারত বর্ধিত পূর্বাভাষ: প্রথম দুই সপ্তাহে বৃষ্টির ঘাটতি থাকবে (-৪২%)। তবে তৃতীয় সপ্তাহ থেকে মৌসুমী বায়ু পুনরায় সক্রিয় হবে। তুলা ও সয়াবিনে পরিপূرক সেচ প্রয়োগের পরামর্শ দেওয়া হচ্ছে।',
          'gu':
              'મધ્ય ભારત વિસ્તૃત આગાહી: પ્રથમ સપ્તાહમાં ચોમાસામાં મોટો વિરામ રહેશે (-42%). સપ્તાહ 3 અને 4માં ભારે વરસાદ સાથે ચોમાસું ફરી સક્રિય થશે. ખેડૂતોએ પાકમાં હળવી પિયત આપવી.',
          'kn':
              'ವಿದರ್ಭ ಹಾಗೂ ಮಧ್ಯ ಭಾರತ ವಿಸ್ತೃತ ಮುನ್ಸೂಚನೆ: ಮೊದಲ 2 ವಾರಗಳಲ್ಲಿ ಮಳೆ ಕೊರತೆ ಇರಲಿದ್ದು, 3ನೇ ವಾರದಿಂದ ಮುಂಗಾರು ಚುರುಕಾಗಲಿದೆ. ಕೃಷಿ ಹೊಂಡಗಳಿಂದ ಲಘು ನೀರಾವರಿ ಒದಗಿಸಿ.',
        },
      ),
      allZones: [
        ErpZoneSummaryModel(
          zoneId: 'vidarbha_central_rainfed',
          zoneName: 'Central India Rainfed Soybean-Cotton Zone',
          state: 'Maharashtra',
          subDivisionName: 'Vidarbha & West Madhya Pradesh',
          currentMonsoonSpell: 'BREAK_MONSOON_CRITICAL',
          week1DeparturePct: -42.0,
          week2DeparturePct: -25.0,
          contingencyAlertActive: true,
        ),
        ErpZoneSummaryModel(
          zoneId: 'indo_gangetic_breadbasket',
          zoneName: 'North-Western Indo-Gangetic Breadbasket',
          state: 'Punjab',
          subDivisionName: 'Punjab, Haryana, Chandigarh & Delhi',
          currentMonsoonSpell: 'NORMAL_MONSOON',
          week1DeparturePct: 12.0,
          week2DeparturePct: 4.0,
          contingencyAlertActive: false,
        ),
        ErpZoneSummaryModel(
          zoneId: 'eastern_gangetic_rice_basin',
          zoneName: 'Eastern Gangetic Rice & Pulse Basin',
          state: 'Bihar',
          subDivisionName: 'Bihar & East Uttar Pradesh',
          currentMonsoonSpell: 'ACTIVE_SURGE',
          week1DeparturePct: 65.0,
          week2DeparturePct: 35.0,
          contingencyAlertActive: false,
        ),
        ErpZoneSummaryModel(
          zoneId: 'southern_peninsular_millet',
          zoneName: 'Southern Peninsular Semi-Arid Millet & Oilseed Belt',
          state: 'Telangana',
          subDivisionName: 'Telangana & Rayalaseema',
          currentMonsoonSpell: 'WEAK_MONSOON',
          week1DeparturePct: -38.0,
          week2DeparturePct: -18.0,
          contingencyAlertActive: false,
        ),
        ErpZoneSummaryModel(
          zoneId: 'konkan_malabar_coastal',
          zoneName: 'Western Coastal Ghats & Konkan-Malabar Maritime Zone',
          state: 'Goa',
          subDivisionName: 'Konkan & Goa, Coastal Karnataka',
          currentMonsoonSpell: 'ACTIVE_SURGE',
          week1DeparturePct: 24.0,
          week2DeparturePct: 18.0,
          contingencyAlertActive: false,
        ),
        ErpZoneSummaryModel(
          zoneId: 'northeastern_brahmaputra_fluvial',
          zoneName: 'Northeastern Brahmaputra Humid Fluvial Zone',
          state: 'Assam',
          subDivisionName: 'Assam & Meghalaya',
          currentMonsoonSpell: 'ACTIVE_SURGE',
          week1DeparturePct: 72.0,
          week2DeparturePct: 48.0,
          contingencyAlertActive: false,
        ),
        ErpZoneSummaryModel(
          zoneId: 'western_arid_coarse_grain',
          zoneName: 'Western Arid & Semi-Arid Coarse Grain Zone',
          state: 'Rajasthan',
          subDivisionName: 'West Rajasthan & Saurashtra',
          currentMonsoonSpell: 'BREAK_MONSOON_CRITICAL',
          week1DeparturePct: -55.0,
          week2DeparturePct: -35.0,
          contingencyAlertActive: true,
        ),
      ],
      mmeModelConsensusPct: 85.5,
      lastUpdatedUtc: '2026-09-12T12:00:00Z',
      dataSource:
          'IMD-NCMRWF-IITM Extended Range Multi-Model Ensemble (CFSv2 / NCUM-ER) & ICAR-CRIDA',
    );
  }
}
