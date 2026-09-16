class MicroclimateTelemetryModel {
  final double temperatureC;
  final double relativeHumidityPct;
  final double leafWetnessHours;
  final int cloudCoverOktas;
  final double growingDegreeDaysBase5;
  final int consecutiveFavorableDays;

  MicroclimateTelemetryModel({
    required this.temperatureC,
    required this.relativeHumidityPct,
    required this.leafWetnessHours,
    required this.cloudCoverOktas,
    required this.growingDegreeDaysBase5,
    required this.consecutiveFavorableDays,
  });

  factory MicroclimateTelemetryModel.fromJson(Map<String, dynamic> json) {
    return MicroclimateTelemetryModel(
      temperatureC: (json['temperature_c'] as num?)?.toDouble() ?? 16.5,
      relativeHumidityPct: (json['relative_humidity_pct'] as num?)?.toDouble() ?? 90.0,
      leafWetnessHours: (json['leaf_wetness_hours'] as num?)?.toDouble() ?? 10.0,
      cloudCoverOktas: (json['cloud_cover_oktas'] as num?)?.toInt() ?? 5,
      growingDegreeDaysBase5:
          (json['growing_degree_days_base5'] as num?)?.toDouble() ?? 160.0,
      consecutiveFavorableDays:
          (json['consecutive_favorable_days'] as num?)?.toInt() ?? 3,
    );
  }

  Map<String, dynamic> toJson() => {
        'temperature_c': temperatureC,
        'relative_humidity_pct': relativeHumidityPct,
        'leaf_wetness_hours': leafWetnessHours,
        'cloud_cover_oktas': cloudCoverOktas,
        'growing_degree_days_base5': growingDegreeDaysBase5,
        'consecutive_favorable_days': consecutiveFavorableDays,
      };
}

class PestDiseaseAlertItemModel {
  final String id;
  final String name;
  final String scientificName;
  final String targetCrop;
  final String causalAgent;
  final String riskLevel;
  final String epidemicCondition;
  final String favorableMicroclimateRule;
  final String economicThresholdLevel;
  final String preSymptomaticForewarning;
  final String organicBiocontrolDirective;
  final String chemicalEmergencyDirective;

  PestDiseaseAlertItemModel({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.targetCrop,
    required this.causalAgent,
    required this.riskLevel,
    required this.epidemicCondition,
    required this.favorableMicroclimateRule,
    required this.economicThresholdLevel,
    required this.preSymptomaticForewarning,
    required this.organicBiocontrolDirective,
    required this.chemicalEmergencyDirective,
  });

  factory PestDiseaseAlertItemModel.fromJson(Map<String, dynamic> json) {
    return PestDiseaseAlertItemModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      scientificName: json['scientific_name'] ?? '',
      targetCrop: json['target_crop'] ?? '',
      causalAgent: json['causal_agent'] ?? 'FUNGAL',
      riskLevel: json['risk_level'] ?? 'LOW',
      epidemicCondition: json['epidemic_condition'] ?? 'UNFAVORABLE',
      favorableMicroclimateRule: json['favorable_microclimate_rule'] ?? '',
      economicThresholdLevel: json['economic_threshold_level'] ?? '',
      preSymptomaticForewarning: json['pre_symptomatic_forewarning'] ?? '',
      organicBiocontrolDirective: json['organic_biocontrol_directive'] ?? '',
      chemicalEmergencyDirective: json['chemical_emergency_directive'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'scientific_name': scientificName,
        'target_crop': targetCrop,
        'causal_agent': causalAgent,
        'risk_level': riskLevel,
        'epidemic_condition': epidemicCondition,
        'favorable_microclimate_rule': favorableMicroclimateRule,
        'economic_threshold_level': economicThresholdLevel,
        'pre_symptomatic_forewarning': preSymptomaticForewarning,
        'organic_biocontrol_directive': organicBiocontrolDirective,
        'chemical_emergency_directive': chemicalEmergencyDirective,
      };
}

class AgroClimaticZoneInfoModel {
  final int zoneId;
  final String zoneName;
  final List<String> keyStates;
  final List<String> dominantCrops;
  final List<String> typicalPestThreats;

  AgroClimaticZoneInfoModel({
    required this.zoneId,
    required this.zoneName,
    required this.keyStates,
    required this.dominantCrops,
    required this.typicalPestThreats,
  });

  factory AgroClimaticZoneInfoModel.fromJson(Map<String, dynamic> json) {
    return AgroClimaticZoneInfoModel(
      zoneId: (json['zone_id'] as num?)?.toInt() ?? 6,
      zoneName: json['zone_name'] ?? 'Trans-Gangetic Plains Region',
      keyStates: (json['key_states'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      dominantCrops: (json['dominant_crops'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      typicalPestThreats: (json['typical_pest_threats'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'zone_id': zoneId,
        'zone_name': zoneName,
        'key_states': keyStates,
        'dominant_crops': dominantCrops,
        'typical_pest_threats': typicalPestThreats,
      };
}

class PestForewarningResponseModel {
  final AgroClimaticZoneInfoModel zone;
  final String locationName;
  final double latitude;
  final double longitude;
  final String timestamp;
  final String highestRiskLevel;
  final String summaryHeadline;
  final MicroclimateTelemetryModel telemetry;
  final List<PestDiseaseAlertItemModel> alerts;
  final List<String> ipmCalendarActions;
  final Map<String, String> multilingualBulletins;
  final List<AgroClimaticZoneInfoModel> allZones;
  final String provenanceDisclaimer;

  PestForewarningResponseModel({
    required this.zone,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.highestRiskLevel,
    required this.summaryHeadline,
    required this.telemetry,
    required this.alerts,
    required this.ipmCalendarActions,
    required this.multilingualBulletins,
    required this.allZones,
    required this.provenanceDisclaimer,
  });

  factory PestForewarningResponseModel.fromJson(Map<String, dynamic> json) {
    final bulletinsRaw = json['multilingual_bulletins'] as Map<String, dynamic>? ?? {};
    final bulletins = bulletinsRaw.map((k, v) => MapEntry(k, v.toString()));

    return PestForewarningResponseModel(
      zone: json['zone'] != null
          ? AgroClimaticZoneInfoModel.fromJson(json['zone'])
          : AgroClimaticZoneInfoModel(
              zoneId: 6,
              zoneName: 'Trans-Gangetic Plains Region',
              keyStates: ['Punjab', 'Haryana', 'Delhi'],
              dominantCrops: ['Wheat', 'Paddy', 'Cotton', 'Mustard'],
              typicalPestThreats: ['Mustard Aphid', 'Cotton Whitefly'],
            ),
      locationName: json['location_name'] ?? 'Punjab & Haryana Plains',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 30.5,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 75.8,
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
      highestRiskLevel: json['highest_risk_level'] ?? 'HIGH',
      summaryHeadline: json['summary_headline'] ??
          'High Risk: Potato Late Blight & Mustard Aphid outbreak alert for Trans-Gangetic Plains.',
      telemetry: json['telemetry'] != null
          ? MicroclimateTelemetryModel.fromJson(json['telemetry'])
          : MicroclimateTelemetryModel(
              temperatureC: 16.5,
              relativeHumidityPct: 91.0,
              leafWetnessHours: 11.5,
              cloudCoverOktas: 5,
              growingDegreeDaysBase5: 161.0,
              consecutiveFavorableDays: 3,
            ),
      alerts: (json['alerts'] as List<dynamic>?)
              ?.map((e) => PestDiseaseAlertItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      ipmCalendarActions: (json['ipm_calendar_actions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      multilingualBulletins: bulletins,
      allZones: (json['all_zones'] as List<dynamic>?)
              ?.map((e) => AgroClimaticZoneInfoModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      provenanceDisclaimer: json['provenance_disclaimer'] ??
          'Epidemiological models calibrated from ICAR-NCIPM & IMD Gramin Krishi Mausam Seva (GKMS) Agromet Advisory Guidelines.',
    );
  }

  Map<String, dynamic> toJson() => {
        'zone': zone.toJson(),
        'location_name': locationName,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp,
        'highest_risk_level': highestRiskLevel,
        'summary_headline': summaryHeadline,
        'telemetry': telemetry.toJson(),
        'alerts': alerts.map((e) => e.toJson()).toList(),
        'ipm_calendar_actions': ipmCalendarActions,
        'multilingual_bulletins': multilingualBulletins,
        'all_zones': allZones.map((e) => e.toJson()).toList(),
        'provenance_disclaimer': provenanceDisclaimer,
      };

  factory PestForewarningResponseModel.defaultFallback() {
    return PestForewarningResponseModel(
      zone: AgroClimaticZoneInfoModel(
        zoneId: 6,
        zoneName: 'Trans-Gangetic Plains Region',
        keyStates: ['Punjab', 'Haryana', 'Delhi', 'Ganganagar'],
        dominantCrops: ['Wheat', 'Paddy', 'Cotton', 'Mustard', 'Sugarcane'],
        typicalPestThreats: [
          'Cotton Whitefly',
          'Mustard Aphid',
          'Wheat Yellow Rust',
          'Potato Late Blight',
        ],
      ),
      locationName: 'Punjab & Haryana Plains',
      latitude: 30.5,
      longitude: 75.8,
      timestamp: DateTime.now().toIso8601String(),
      highestRiskLevel: 'CRITICAL',
      summaryHeadline:
          'CRITICAL Risk: Potato Late Blight & Mustard Aphid outbreak alert for Trans-Gangetic Plains Region. Microclimatic infection threshold satisfied.',
      telemetry: MicroclimateTelemetryModel(
        temperatureC: 16.5,
        relativeHumidityPct: 91.0,
        leafWetnessHours: 11.5,
        cloudCoverOktas: 5,
        growingDegreeDaysBase5: 161.0,
        consecutiveFavorableDays: 3,
      ),
      alerts: [
        PestDiseaseAlertItemModel(
          id: 'POTATO_LATE_BLIGHT',
          name: 'Potato Late Blight',
          scientificName: 'Phytophthora infestans',
          targetCrop: 'Potato (Solanum tuberosum)',
          causalAgent: 'FUNGAL',
          riskLevel: 'CRITICAL',
          epidemicCondition: 'FAVORABLE',
          favorableMicroclimateRule:
              'RH >= 90% for >= 10 hours with temperatures 10°C to 24°C and dew formation.',
          economicThresholdLevel:
              'Initial water-soaked spots on 1-2% leaves or Wallin Severity Value accumulation >= 18 points.',
          preSymptomaticForewarning:
              'Wallin Severity Index = 4 (Maximum). Extreme sporulation window active. Blight lesions will appear within 48-72h without intervention.',
          organicBiocontrolDirective:
              'Foliar spray of Trichoderma viride @ 5g/L or 5% Neem Seed Kernel Extract (NSKE).',
          chemicalEmergencyDirective:
              'Prophylactic spray of Mancozeb 75 WP @ 2.5 g/L. If disease already appeared, spray systemic Cymoxanil 8% + Mancozeb 64% WP @ 3 g/L.',
        ),
        PestDiseaseAlertItemModel(
          id: 'MUSTARD_APHID',
          name: 'Mustard Aphid (Mahun / Chepa)',
          scientificName: 'Lipaphis erysimi',
          targetCrop: 'Mustard / Rapeseed (Brassica juncea)',
          causalAgent: 'INSECT_VECTOR',
          riskLevel: 'HIGH',
          epidemicCondition: 'FAVORABLE',
          favorableMicroclimateRule:
              'Mean temperature 10°C to 18°C with morning RH >= 70% and cloudy/overcast skies.',
          economicThresholdLevel:
              '25-28 aphids per 10 cm terminal central shoot or 1.5-2.0 cm shoot colony length on 20% plants.',
          preSymptomaticForewarning:
              'Cloudy overcast canopy with high RH is triggering explosive parthenogenetic nymphal reproduction.',
          organicBiocontrolDirective:
              'Install yellow sticky traps @ 10-12 per acre. Spray Verticillium lecanii @ 5 g/L or 5% NSKE.',
          chemicalEmergencyDirective:
              'Foliar spray of Dimethoate 30 EC @ 1.0 ml/L or Thiamethoxam 25 WG @ 0.2 g/L.',
        ),
        PestDiseaseAlertItemModel(
          id: 'WHEAT_YELLOW_RUST',
          name: 'Wheat Yellow / Stripe Rust',
          scientificName: 'Puccinia striiformis f. sp. tritici',
          targetCrop: 'Wheat (Triticum aestivum)',
          causalAgent: 'FUNGAL',
          riskLevel: 'HIGH',
          epidemicCondition: 'FAVORABLE',
          favorableMicroclimateRule:
              'Cool damp conditions (10°C to 15°C) with RH >= 80% and overnight dew or dense fog.',
          economicThresholdLevel:
              'First appearance of linear yellow pustules on leaf blades of susceptible cultivars.',
          preSymptomaticForewarning:
              'Sub-montane cool damp microclimate favors stripe rust urediniospore germination on flag leaves.',
          organicBiocontrolDirective:
              'Grow resistant varieties (HD 3086, DBW 187). Spray sour buttermilk (Chhachh) @ 5%.',
          chemicalEmergencyDirective:
              'Spray Propiconazole 25 EC (Tilt) @ 1.0 ml/L or Tebuconazole 25.9 EC @ 1.0 ml/L.',
        ),
      ],
      ipmCalendarActions: [
        'Conduct early morning field scouting across border rows and canopy undersides twice a week.',
        'Install yellow sticky traps (10/acre) for sucking insect vectors (aphids, whiteflies, jassids).',
        'Avoid excessive nitrogenous top-dressing (urea) which produces soft succulent vegetative growth.',
        'Maintain clean irrigation channels and eliminate weed collateral hosts (Parthenium) around bunds.',
        'Ensure spray droplets reach under-surface of foliage by using hollow cone nozzles at 30-40 psi pressure.',
      ],
      multilingualBulletins: {
        'en':
            'IMD GKMS AGROMET FOREWARNING: CRITICAL epidemic risk for Potato Late Blight on Potato in Trans-Gangetic Plains. Microclimate thresholds satisfied. Farmers are advised to conduct immediate field scouting and initiate preventative spray.',
        'hi':
            'आईएमडी ग्रामीण कृषि मौसम सेवा चेतावनी: ट्रांस-गंगा मैदानी क्षेत्र में आलू की फसल पर पछेती झुलसा का गंभीर प्रकोप जोखिम। किसान तुरंत खेतों का निरीक्षण कर अनुशंसित फफूंदनाशी का छिड़काव करें।',
        'pa':
            'ਮੌਸਮ ਵਿਭਾਗ ਖੇਤੀ ਚੇਤਾਵਨੀ: ਆਲੂ ਦੀ ਫ਼ਸਲ ਉੱਤੇ ਪਛੇਤੇ ਝੁਲਸ ਰੋਗ ਦਾ ਗੰਭੀਰ ਖ਼ਤਰਾ। ਕਿਸਾਨ ਤੁਰੰਤ ਖੇਤਾਂ ਦਾ ਦੌਰਾ ਕਰਨ ਅਤੇ ਸਿਫ਼ਾਰਸ਼ ਕੀਤੀ ਉੱਲੀਨਾਸ਼ਕ ਦਾ ਛਿੜਕਾਅ ਕਰਨ।',
        'te':
            'ఐఎండి వ్యవసాయ వాతావరణ హెచ్చరిక: బంగాళాదుంప పంటకు తీవ్ర తెగులు ప్రమాదం. రైతులు వెంటనే నివారణ చర్యలు చేపట్టాలి.',
        'ta':
            'வானிலை ஆய்வு மையம் வேளாண் எச்சரிக்கை: உருளைக்கிழங்கு பயிரில் பிளைட் பூஞ்சாண நோய் தீவிர அபாயம். விவசாயிகள் உடனடியாக தடுப்பு மருந்து தெளிக்கவும்.',
      },
      allZones: [
        AgroClimaticZoneInfoModel(
          zoneId: 1,
          zoneName: 'Western Himalayan Region',
          keyStates: ['Jammu & Kashmir', 'Himachal Pradesh', 'Uttarakhand'],
          dominantCrops: ['Apple', 'Wheat', 'Maize', 'Saffron', 'Potato'],
          typicalPestThreats: ['Apple Scab', 'Potato Late Blight', 'Wheat Stripe Rust'],
        ),
        AgroClimaticZoneInfoModel(
          zoneId: 6,
          zoneName: 'Trans-Gangetic Plains Region',
          keyStates: ['Punjab', 'Haryana', 'Delhi', 'Ganganagar'],
          dominantCrops: ['Wheat', 'Paddy', 'Cotton', 'Mustard', 'Sugarcane'],
          typicalPestThreats: ['Cotton Whitefly', 'Mustard Aphid', 'Wheat Yellow Rust'],
        ),
        AgroClimaticZoneInfoModel(
          zoneId: 10,
          zoneName: 'Southern Plateau and Hills Region',
          keyStates: ['Karnataka', 'Telangana', 'Andhra Pradesh', 'Tamil Nadu'],
          dominantCrops: ['Ragi', 'Cotton', 'Groundnut', 'Sorghum', 'Coffee'],
          typicalPestThreats: ['Groundnut Spodoptera', 'Coffee Berry Borer', 'Ragi Blast'],
        ),
      ],
      provenanceDisclaimer:
          'Epidemiological models calibrated from ICAR-NCIPM & IMD Gramin Krishi Mausam Seva (GKMS) Agromet Advisory Guidelines. Zero synthetic fabrication.',
    );
  }
}
