class MicroclimateBiometeorologyModel {
  final double dryBulbTemperatureC;
  final double relativeHumidityPct;
  final double dewPointTemperatureC;
  final double windSpeedMs;
  final double solarRadiationWm2;
  final double temperatureHumidityIndexThi;
  final double blackGlobeHumidityIndexBgthi;

  const MicroclimateBiometeorologyModel({
    required this.dryBulbTemperatureC,
    required this.relativeHumidityPct,
    required this.dewPointTemperatureC,
    required this.windSpeedMs,
    required this.solarRadiationWm2,
    required this.temperatureHumidityIndexThi,
    required this.blackGlobeHumidityIndexBgthi,
  });

  factory MicroclimateBiometeorologyModel.fromJson(Map<String, dynamic> json) {
    return MicroclimateBiometeorologyModel(
      dryBulbTemperatureC: (json['dry_bulb_temperature_c'] as num?)?.toDouble() ?? 38.0,
      relativeHumidityPct: (json['relative_humidity_pct'] as num?)?.toDouble() ?? 55.0,
      dewPointTemperatureC: (json['dew_point_temperature_c'] as num?)?.toDouble() ?? 26.0,
      windSpeedMs: (json['wind_speed_ms'] as num?)?.toDouble() ?? 2.0,
      solarRadiationWm2: (json['solar_radiation_wm2'] as num?)?.toDouble() ?? 800.0,
      temperatureHumidityIndexThi: (json['temperature_humidity_index_thi'] as num?)?.toDouble() ?? 84.0,
      blackGlobeHumidityIndexBgthi: (json['black_globe_humidity_index_bgthi'] as num?)?.toDouble() ?? 88.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'dry_bulb_temperature_c': dryBulbTemperatureC,
        'relative_humidity_pct': relativeHumidityPct,
        'dew_point_temperature_c': dewPointTemperatureC,
        'wind_speed_ms': windSpeedMs,
        'solar_radiation_wm2': solarRadiationWm2,
        'temperature_humidity_index_thi': temperatureHumidityIndexThi,
        'black_globe_humidity_index_bgthi': blackGlobeHumidityIndexBgthi,
      };
}

class SpeciesVulnerabilityProfileModel {
  final String speciesCategory;
  final String breedName;
  final int respirationRateBpm;
  final double rectalTemperatureC;
  final double estimatedMilkYieldDropPct;
  final double dryMatterIntakeReductionPct;
  final double conceptionRatePenaltyPct;

  const SpeciesVulnerabilityProfileModel({
    required this.speciesCategory,
    required this.breedName,
    required this.respirationRateBpm,
    required this.rectalTemperatureC,
    required this.estimatedMilkYieldDropPct,
    required this.dryMatterIntakeReductionPct,
    required this.conceptionRatePenaltyPct,
  });

  factory SpeciesVulnerabilityProfileModel.fromJson(Map<String, dynamic> json) {
    return SpeciesVulnerabilityProfileModel(
      speciesCategory: json['species_category']?.toString() ?? 'CROSSBRED_HF_JERSEY',
      breedName: json['breed_name']?.toString() ?? 'Crossbred Cattle',
      respirationRateBpm: (json['respiration_rate_bpm'] as num?)?.toInt() ?? 60,
      rectalTemperatureC: (json['rectal_temperature_c'] as num?)?.toDouble() ?? 39.0,
      estimatedMilkYieldDropPct: (json['estimated_milk_yield_drop_pct'] as num?)?.toDouble() ?? 15.0,
      dryMatterIntakeReductionPct: (json['dry_matter_intake_reduction_pct'] as num?)?.toDouble() ?? 12.0,
      conceptionRatePenaltyPct: (json['conception_rate_penalty_pct'] as num?)?.toDouble() ?? 25.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'species_category': speciesCategory,
        'breed_name': breedName,
        'respiration_rate_bpm': respirationRateBpm,
        'rectal_temperature_c': rectalTemperatureC,
        'estimated_milk_yield_drop_pct': estimatedMilkYieldDropPct,
        'dry_matter_intake_reduction_pct': dryMatterIntakeReductionPct,
        'conception_rate_penalty_pct': conceptionRatePenaltyPct,
      };
}

class FarmShelterAndNutritionDirectivesModel {
  final String shedCoolingProtocol;
  final String wallowingPondRecommendation;
  final double waterRequirementLitersPerAnimal;
  final String dietaryRationAdjustment;
  final String grazingCurfewHours;
  final List<String> veterinaryEmergencySigns;

  const FarmShelterAndNutritionDirectivesModel({
    required this.shedCoolingProtocol,
    required this.wallowingPondRecommendation,
    required this.waterRequirementLitersPerAnimal,
    required this.dietaryRationAdjustment,
    required this.grazingCurfewHours,
    required this.veterinaryEmergencySigns,
  });

  factory FarmShelterAndNutritionDirectivesModel.fromJson(Map<String, dynamic> json) {
    return FarmShelterAndNutritionDirectivesModel(
      shedCoolingProtocol: json['shed_cooling_protocol']?.toString() ?? 'Operate ceiling fans and micro-foggers.',
      wallowingPondRecommendation: json['wallowing_pond_recommendation']?.toString() ?? 'Provide freshwater wallowing.',
      waterRequirementLitersPerAnimal: (json['water_requirement_liters_per_animal'] as num?)?.toDouble() ?? 110.0,
      dietaryRationAdjustment: json['dietary_ration_adjustment']?.toString() ?? 'Offer green fodder during cooler hours.',
      grazingCurfewHours: json['grazing_curfew_hours']?.toString() ?? 'Strict curfew between 10:30 AM and 4:30 PM.',
      veterinaryEmergencySigns: (json['veterinary_emergency_signs'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [
            'Excessive open-mouth panting with tongue protruding and frothy salivation',
            'Rectal body temperature exceeding 40.5°C with cessation of rumination',
            'Inability to stand, glazed sunken eyes, or muscle tremors',
          ],
    );
  }

  Map<String, dynamic> toJson() => {
        'shed_cooling_protocol': shedCoolingProtocol,
        'wallowing_pond_recommendation': wallowingPondRecommendation,
        'water_requirement_liters_per_animal': waterRequirementLitersPerAnimal,
        'dietary_ration_adjustment': dietaryRationAdjustment,
        'grazing_curfew_hours': grazingCurfewHours,
        'veterinary_emergency_signs': veterinaryEmergencySigns,
      };
}

class DairyCorridorBasinModel {
  final String basinId;
  final String basinName;
  final String state;
  final String prominentDairyCluster;
  final double latitude;
  final double longitude;
  final String stressTier;
  final MicroclimateBiometeorologyModel microclimate;
  final List<SpeciesVulnerabilityProfileModel> speciesProfiles;
  final FarmShelterAndNutritionDirectivesModel directives;
  final Map<String, String> vernacularBulletins;

  const DairyCorridorBasinModel({
    required this.basinId,
    required this.basinName,
    required this.state,
    required this.prominentDairyCluster,
    required this.latitude,
    required this.longitude,
    required this.stressTier,
    required this.microclimate,
    required this.speciesProfiles,
    required this.directives,
    required this.vernacularBulletins,
  });

  factory DairyCorridorBasinModel.fromJson(Map<String, dynamic> json) {
    return DairyCorridorBasinModel(
      basinId: json['basin_id']?.toString() ?? '',
      basinName: json['basin_name']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      prominentDairyCluster: json['prominent_dairy_cluster']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      stressTier: json['stress_tier']?.toString() ?? 'NORMAL_COMFORT',
      microclimate: MicroclimateBiometeorologyModel.fromJson(
        (json['microclimate'] as Map<String, dynamic>?) ?? {},
      ),
      speciesProfiles: (json['species_profiles'] as List<dynamic>?)
              ?.map((e) => SpeciesVulnerabilityProfileModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      directives: FarmShelterAndNutritionDirectivesModel.fromJson(
        (json['directives'] as Map<String, dynamic>?) ?? {},
      ),
      vernacularBulletins: (json['vernacular_bulletins'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          {},
    );
  }

  Map<String, dynamic> toJson() => {
        'basin_id': basinId,
        'basin_name': basinName,
        'state': state,
        'prominent_dairy_cluster': prominentDairyCluster,
        'latitude': latitude,
        'longitude': longitude,
        'stress_tier': stressTier,
        'microclimate': microclimate.toJson(),
        'species_profiles': speciesProfiles.map((p) => p.toJson()).toList(),
        'directives': directives.toJson(),
        'vernacular_bulletins': vernacularBulletins,
      };
}

class LivestockHeatStressResponseModel {
  final String timestamp;
  final String bulletinNumber;
  final String provenance;
  final String nationalPastoralSummary;
  final DairyCorridorBasinModel selectedBasin;
  final List<DairyCorridorBasinModel> allBasins;
  final String bioclimaticModel;
  final Map<String, String> vernacularBulletins;
  final bool isOfflineCached;

  const LivestockHeatStressResponseModel({
    required this.timestamp,
    required this.bulletinNumber,
    required this.provenance,
    required this.nationalPastoralSummary,
    required this.selectedBasin,
    required this.allBasins,
    required this.bioclimaticModel,
    required this.vernacularBulletins,
    this.isOfflineCached = false,
  });

  factory LivestockHeatStressResponseModel.fromJson(Map<String, dynamic> json, {bool isOffline = false}) {
    return LivestockHeatStressResponseModel(
      timestamp: json['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
      bulletinNumber: json['bulletin_number']?.toString() ?? 'ICAR-NDRI/THI-WARN/LIVE',
      provenance: json['provenance']?.toString() ??
          'ICAR-National Dairy Research Institute (NDRI) & IMD Agromet Livestock Division',
      nationalPastoralSummary: json['national_pastoral_summary']?.toString() ??
          'WARNING: Indian Dairy Livestock Thermal Stress Surveillance Active',
      selectedBasin: DairyCorridorBasinModel.fromJson(
        (json['selected_basin'] as Map<String, dynamic>?) ?? {},
      ),
      allBasins: (json['all_basins'] as List<dynamic>?)
              ?.map((e) => DairyCorridorBasinModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      bioclimaticModel: json['bioclimatic_model']?.toString() ??
          'Thom (1959) & NRC (1971) Temperature-Humidity Index: THI = 0.8*Tdb + (RH/100)*(Tdb - 14.4) + 46.4',
      vernacularBulletins: (json['vernacular_bulletins'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          {},
      isOfflineCached: isOffline || (json['is_offline_cached'] as bool? ?? false),
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'bulletin_number': bulletinNumber,
        'provenance': provenance,
        'national_pastoral_summary': nationalPastoralSummary,
        'selected_basin': selectedBasin.toJson(),
        'all_basins': allBasins.map((b) => b.toJson()).toList(),
        'bioclimatic_model': bioclimaticModel,
        'vernacular_bulletins': vernacularBulletins,
        'is_offline_cached': isOfflineCached,
      };

  static LivestockHeatStressResponseModel defaultFallback() {
    const karnalBasin = DairyCorridorBasinModel(
      basinId: 'karnal_kurukshetra_hr',
      basinName: 'Karnal & Kurukshetra Basin',
      state: 'Haryana',
      prominentDairyCluster: 'ICAR-National Dairy Research Institute (NDRI) & Murrah Buffalo Tract',
      latitude: 29.6857,
      longitude: 76.9905,
      stressTier: 'MODERATE_STRESS',
      microclimate: MicroclimateBiometeorologyModel(
        dryBulbTemperatureC: 41.5,
        relativeHumidityPct: 58.0,
        dewPointTemperatureC: 31.8,
        windSpeedMs: 1.8,
        solarRadiationWm2: 880.0,
        temperatureHumidityIndexThi: 87.2,
        blackGlobeHumidityIndexBgthi: 91.5,
      ),
      speciesProfiles: [
        SpeciesVulnerabilityProfileModel(
          speciesCategory: 'MURRAH_WATER_BUFFALO',
          breedName: 'Murrah Water Buffalo',
          respirationRateBpm: 78,
          rectalTemperatureC: 39.8,
          estimatedMilkYieldDropPct: 22.0,
          dryMatterIntakeReductionPct: 18.0,
          conceptionRatePenaltyPct: 32.0,
        ),
        SpeciesVulnerabilityProfileModel(
          speciesCategory: 'CROSSBRED_HF_JERSEY',
          breedName: 'Karan Fries (HF x Tharparkar Crossbred)',
          respirationRateBpm: 88,
          rectalTemperatureC: 40.2,
          estimatedMilkYieldDropPct: 26.5,
          dryMatterIntakeReductionPct: 22.0,
          conceptionRatePenaltyPct: 38.0,
        ),
        SpeciesVulnerabilityProfileModel(
          speciesCategory: 'INDIGENOUS_ZEBU_CATTLE',
          breedName: 'Sahiwal Indigenous Zebu',
          respirationRateBpm: 46,
          rectalTemperatureC: 38.9,
          estimatedMilkYieldDropPct: 9.5,
          dryMatterIntakeReductionPct: 8.0,
          conceptionRatePenaltyPct: 12.0,
        ),
      ],
      directives: FarmShelterAndNutritionDirectivesModel(
        shedCoolingProtocol:
            'Continuous 1.5 m/s ceiling ventilation fans with high-pressure micro-misters operating for 15 minutes every hour from 10:00 to 17:30 IST.',
        wallowingPondRecommendation:
            'Mandatory freshwater wallowing or manual water hosing for Murrah buffaloes at 10:30 and 15:00 IST for 30 minutes each session.',
        waterRequirementLitersPerAnimal: 125.0,
        dietaryRationAdjustment:
            'Provide 70% of daily total mixed ration (TMR) between 19:00 and 06:00 IST; add 100g sodium bicarbonate and 30g potassium chloride per head.',
        grazingCurfewHours: 'Strict field grazing ban between 09:30 and 17:30 IST; provide shaded loafing yard.',
        veterinaryEmergencySigns: [
          'Excessive open-mouth panting with tongue protruding and continuous frothy salivation',
          'Rectal temperature exceeding 40.5°C with complete cessation of rumination (>12 hours)',
          'Recumbency, staggering gait, refusal to drink, or sunken eyes indicating heat apoplexy',
        ],
      ),
      vernacularBulletins: {
        'en': 'ICAR-NDRI BIOMET BULLETIN: Karnal-Kurukshetra dairy belt under MODERATE HEAT STRESS (THI 87.2). Crossbred cows and Murrah buffaloes face up to 26% milk drop. Mist sheds and shift feeding to night hours.',
        'hi': 'भाकृअनुप-एनडीआरआई करनाल पशु मौसम बुलेटिन: करनाल-कुरुक्षेत्र दुग्ध क्षेत्र में मध्यम ताप तनाव (टीएचआई 87.2)। संकर गायों और मुर्रा भैंसों में 26% तक दूध गिरावट की आशंका। शेड में फव्वारे चलाएं और रात में चारा दें।',
        'pa': 'ਆਈਸੀਏਆਰ-ਐਨਡੀਆਰਆਈ ਡੇਅਰੀ ਬੁਲੇਟਿਨ: ਕਰਨਾਲ ਖੇਤਰ ਵਿੱਚ ਗੰਭੀਰ ਗਰਮੀ ਤਣਾਅ (THI 87.2)। ਮੁਰ੍ਹਾ ਮੱਝਾਂ ਅਤੇ ਵਿਦੇਸ਼ੀ ਗਾਵਾਂ ਦੇ ਦੁੱਧ ਵਿੱਚ 26% ਗਿਰਾਵਟ ਦਾ ਖ਼ਤਰਾ। ਸ਼ੈੱਡ ਵਿੱਚ ਪੱਖੇ ਤੇ ਫ਼ੁਹਾਰੇ ਚਲਾਓ ਅਤੇ ਰਾਤ ਨੂੰ ਚਾਰਾ ਦਿਓ।',
      },
    );

    const anandBasin = DairyCorridorBasinModel(
      basinId: 'anand_mehsana_gj',
      basinName: 'Anand & Mehsana Dairy Belt',
      state: 'Gujarat',
      prominentDairyCluster: 'Amul (GCMMF) Cooperative Milk Federation & Mehsani Buffalo Tract',
      latitude: 22.5645,
      longitude: 72.9289,
      stressTier: 'MODERATE_STRESS',
      microclimate: MicroclimateBiometeorologyModel(
        dryBulbTemperatureC: 39.2,
        relativeHumidityPct: 64.0,
        dewPointTemperatureC: 31.0,
        windSpeedMs: 2.1,
        solarRadiationWm2: 850.0,
        temperatureHumidityIndexThi: 85.8,
        blackGlobeHumidityIndexBgthi: 89.8,
      ),
      speciesProfiles: [
        SpeciesVulnerabilityProfileModel(
          speciesCategory: 'MURRAH_WATER_BUFFALO',
          breedName: 'Surti / Mehsana Water Buffalo',
          respirationRateBpm: 84,
          rectalTemperatureC: 40.1,
          estimatedMilkYieldDropPct: 25.0,
          dryMatterIntakeReductionPct: 21.0,
          conceptionRatePenaltyPct: 36.0,
        ),
        SpeciesVulnerabilityProfileModel(
          speciesCategory: 'CROSSBRED_HF_JERSEY',
          breedName: 'Holstein Friesian Crossbred',
          respirationRateBpm: 96,
          rectalTemperatureC: 40.6,
          estimatedMilkYieldDropPct: 31.0,
          dryMatterIntakeReductionPct: 26.0,
          conceptionRatePenaltyPct: 44.0,
        ),
        SpeciesVulnerabilityProfileModel(
          speciesCategory: 'INDIGENOUS_ZEBU_CATTLE',
          breedName: 'Gir Indigenous Cattle',
          respirationRateBpm: 50,
          rectalTemperatureC: 39.0,
          estimatedMilkYieldDropPct: 11.0,
          dryMatterIntakeReductionPct: 9.0,
          conceptionRatePenaltyPct: 14.0,
        ),
      ],
      directives: FarmShelterAndNutritionDirectivesModel(
        shedCoolingProtocol:
            'URGENT: Constant cross-ventilation, rooftop thatch/sprinkler wetting, and mist foggers active 10:00 to 18:00 IST.',
        wallowingPondRecommendation:
            'Mandatory freshwater wallowing twice daily or continuous cold-water spray every 2 hours.',
        waterRequirementLitersPerAnimal: 130.0,
        dietaryRationAdjustment:
            'Feed bypass fat (150-200g/day) and mineral mixture enriched with zinc and chromium; supplement electrolytes in drinking water.',
        grazingCurfewHours: 'Absolute curfew on open grazing 09:00 to 18:00 IST.',
        veterinaryEmergencySigns: [
          'Extreme respiratory distress with tongue protrusion and collapse',
          'Rectal temp > 41°C indicating immediate heat stroke',
          'Complete drop in water intake and non-responsiveness',
        ],
      ),
      vernacularBulletins: {
        'en': 'AMUL/NDRI CRITICAL ALERT: Severe thermal stress (THI 89.4) across Anand-Kheda dairy corridor. High risk of heat stroke in crossbred dairy cattle and buffaloes. Keep animals under cool thatched sheds with ad libitum chilled water.',
        'gu': 'અમૂલ ડેરી પશુ હવામાન ચેતવણી: આણંદ-ખેડા વિસ્તારમાં અતિ તીવ્ર ગરમી તણાવ (THI 89.4)। સંકર ગાયો અને સુરતી-મહેસાણી ભેંસોમાં હીટ સ્ટ્રોકનું જોખમ। શેડ પર પાણી છાંટો અને 24 કલાક ઠંડુ પીવાનું પાણી ઉપલબ્ધ કરાવો।',
      },
    );

    return const LivestockHeatStressResponseModel(
      timestamp: '2026-09-12T10:30:00Z',
      bulletinNumber: 'ICAR-NDRI/THI-WARN/202609-KARNAL',
      provenance: 'ICAR-National Dairy Research Institute (NDRI) & IMD Agromet Livestock Division',
      nationalPastoralSummary:
          'WARNING: Moderate to Severe Livestock Heat Stress (THI 79-90) active across Indo-Gangetic and Western Dairy Belts.',
      selectedBasin: karnalBasin,
      allBasins: [karnalBasin, anandBasin],
      bioclimaticModel:
          'Thom (1959) & NRC (1971) Temperature-Humidity Index: THI = 0.8*Tdb + (RH/100)*(Tdb - 14.4) + 46.4',
      vernacularBulletins: {
        'en': 'ICAR-NDRI BIOMET BULLETIN: Karnal-Kurukshetra dairy belt under MODERATE HEAT STRESS (THI 87.2). Crossbred cows and Murrah buffaloes face up to 26% milk drop. Mist sheds and shift feeding to night hours.',
        'hi': 'भाकृअनुप-एनडीआरआई करनाल पशु मौसम बुलेटिन: करनाल-कुरुक्षेत्र दुग्ध क्षेत्र में मध्यम ताप तनाव (टीएचआई 87.2)। संकर गायों और मुर्रा भैंसों में 26% तक दूध गिरावट की आशंका। शेड में फव्वारे चलाएं और रात में चारा दें।',
        'pa': 'ਆਈਸੀਏਆਰ-ਐਨਡੀਆਰਆਈ ਡੇਅਰੀ ਬੁਲੇਟਿਨ: ਕਰਨਾਲ ਖੇਤਰ ਵਿੱਚ ਗੰਭੀਰ ਗਰਮੀ ਤਣਾਅ (THI 87.2)। ਮੁਰ੍ਹਾ ਮੱਝਾਂ ਅਤੇ ਵਿਦੇਸ਼ੀ ਗਾਵਾਂ ਦੇ ਦੁੱਧ ਵਿੱਚ 26% ਗਿਰਾਵਟ ਦਾ ਖ਼ਤਰਾ। ਸ਼ੈੱਡ ਵਿੱਚ ਪੱਖੇ ਤੇ ਫ਼ੁਹਾਰੇ ਚਲਾਓ ਅਤੇ ਰਾਤ ਨੂੰ ਚਾਰਾ ਦਿਓ।',
      },
      isOfflineCached: true,
    );
  }
}
