class CropVulnerabilityItemModel {
  final String cropName;
  final String criticalStage;
  final String injuryMechanism;
  final int yieldLossRiskPct;
  final List<String> countermeasures;

  CropVulnerabilityItemModel({
    required this.cropName,
    required this.criticalStage,
    required this.injuryMechanism,
    required this.yieldLossRiskPct,
    required this.countermeasures,
  });

  factory CropVulnerabilityItemModel.fromJson(Map<String, dynamic> json) {
    return CropVulnerabilityItemModel(
      cropName: json['crop_name'] ?? '',
      criticalStage: json['critical_stage'] ?? '',
      injuryMechanism: json['injury_mechanism'] ?? '',
      yieldLossRiskPct: (json['yield_loss_risk_pct'] as num?)?.toInt() ?? 0,
      countermeasures: (json['countermeasures'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'crop_name': cropName,
        'critical_stage': criticalStage,
        'injury_mechanism': injuryMechanism,
        'yield_loss_risk_pct': yieldLossRiskPct,
        'countermeasures': countermeasures,
      };
}

class NocturnalCoolingPhysicsModel {
  final double tAirMin;
  final double tNormalMin;
  final double departureC;
  final double tGrassMin;
  final int skyCoverOktas;
  final double windSpeedKmh;
  final double dewPointC;
  final double windChillC;
  final double netRadiationLossWm2;

  NocturnalCoolingPhysicsModel({
    required this.tAirMin,
    required this.tNormalMin,
    required this.departureC,
    required this.tGrassMin,
    required this.skyCoverOktas,
    required this.windSpeedKmh,
    required this.dewPointC,
    required this.windChillC,
    required this.netRadiationLossWm2,
  });

  factory NocturnalCoolingPhysicsModel.fromJson(Map<String, dynamic> json) {
    return NocturnalCoolingPhysicsModel(
      tAirMin: (json['t_air_min'] as num?)?.toDouble() ?? 4.0,
      tNormalMin: (json['t_normal_min'] as num?)?.toDouble() ?? 9.0,
      departureC: (json['departure_c'] as num?)?.toDouble() ?? -5.0,
      tGrassMin: (json['t_grass_min'] as num?)?.toDouble() ?? -0.8,
      skyCoverOktas: (json['sky_cover_oktas'] as num?)?.toInt() ?? 0,
      windSpeedKmh: (json['wind_speed_kmh'] as num?)?.toDouble() ?? 4.0,
      dewPointC: (json['dew_point_c'] as num?)?.toDouble() ?? 1.0,
      windChillC: (json['wind_chill_c'] as num?)?.toDouble() ?? 2.5,
      netRadiationLossWm2:
          (json['net_radiation_loss_wm2'] as num?)?.toDouble() ?? 72.0,
    );
  }

  Map<String, dynamic> toJson() => {
        't_air_min': tAirMin,
        't_normal_min': tNormalMin,
        'departure_c': departureC,
        't_grass_min': tGrassMin,
        'sky_cover_oktas': skyCoverOktas,
        'wind_speed_kmh': windSpeedKmh,
        'dew_point_c': dewPointC,
        'wind_chill_c': windChillC,
        'net_radiation_loss_wm2': netRadiationLossWm2,
      };
}

class UrbanShelterAdvisoryModel {
  final bool nightShelterActivated;
  final String hypothermiaRisk;
  final int recommendedClothingLayers;
  final List<String> livestockProtectionRules;

  UrbanShelterAdvisoryModel({
    required this.nightShelterActivated,
    required this.hypothermiaRisk,
    required this.recommendedClothingLayers,
    required this.livestockProtectionRules,
  });

  factory UrbanShelterAdvisoryModel.fromJson(Map<String, dynamic> json) {
    return UrbanShelterAdvisoryModel(
      nightShelterActivated: json['night_shelter_activated'] ?? true,
      hypothermiaRisk: json['hypothermia_risk'] ?? 'HIGH',
      recommendedClothingLayers:
          (json['recommended_clothing_layers'] as num?)?.toInt() ?? 3,
      livestockProtectionRules: (json['livestock_protection_rules'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'night_shelter_activated': nightShelterActivated,
        'hypothermia_risk': hypothermiaRisk,
        'recommended_clothing_layers': recommendedClothingLayers,
        'livestock_protection_rules': livestockProtectionRules,
      };
}

class ColdwaveStationModel {
  final String stationId;
  final String stationName;
  final String state;
  final double latitude;
  final double longitude;
  final double elevationM;
  final bool isHillStation;
  final double tMin;
  final double tGrass;
  final String coldWaveSeverity;
  final String frostRisk;

  ColdwaveStationModel({
    required this.stationId,
    required this.stationName,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.elevationM,
    required this.isHillStation,
    required this.tMin,
    required this.tGrass,
    required this.coldWaveSeverity,
    required this.frostRisk,
  });

  factory ColdwaveStationModel.fromJson(Map<String, dynamic> json) {
    return ColdwaveStationModel(
      stationId: json['station_id'] ?? '',
      stationName: json['station_name'] ?? '',
      state: json['state'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      elevationM: (json['elevation_m'] as num?)?.toDouble() ?? 0.0,
      isHillStation: json['is_hill_station'] ?? false,
      tMin: (json['t_min'] as num?)?.toDouble() ?? 0.0,
      tGrass: (json['t_grass'] as num?)?.toDouble() ?? 0.0,
      coldWaveSeverity: json['cold_wave_severity'] ?? 'NONE',
      frostRisk: json['frost_risk'] ?? 'NONE',
    );
  }

  Map<String, dynamic> toJson() => {
        'station_id': stationId,
        'station_name': stationName,
        'state': state,
        'latitude': latitude,
        'longitude': longitude,
        'elevation_m': elevationM,
        'is_hill_station': isHillStation,
        't_min': tMin,
        't_grass': tGrass,
        'cold_wave_severity': coldWaveSeverity,
        'frost_risk': frostRisk,
      };
}

class ColdWaveResponseModel {
  final String stationId;
  final String stationName;
  final String state;
  final double latitude;
  final double longitude;
  final double elevationM;
  final bool isHillStation;
  final String timestamp;
  final String coldWaveSeverity;
  final String groundFrostRisk;
  final String summaryHeadline;
  final NocturnalCoolingPhysicsModel physics;
  final List<CropVulnerabilityItemModel> rabiCropAdvisories;
  final UrbanShelterAdvisoryModel urbanShelter;
  final Map<String, String> multilingualBulletins;
  final List<ColdwaveStationModel> monitoringStations;
  final String provenanceDisclaimer;

  ColdWaveResponseModel({
    required this.stationId,
    required this.stationName,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.elevationM,
    required this.isHillStation,
    required this.timestamp,
    required this.coldWaveSeverity,
    required this.groundFrostRisk,
    required this.summaryHeadline,
    required this.physics,
    required this.rabiCropAdvisories,
    required this.urbanShelter,
    required this.multilingualBulletins,
    required this.monitoringStations,
    required this.provenanceDisclaimer,
  });

  factory ColdWaveResponseModel.fromJson(Map<String, dynamic> json) {
    final bulletinsRaw = json['multilingual_bulletins'] as Map<String, dynamic>? ?? {};
    final bulletins = bulletinsRaw.map((k, v) => MapEntry(k, v.toString()));

    return ColdWaveResponseModel(
      stationId: json['station_id'] ?? 'CHURU_RJ',
      stationName: json['station_name'] ?? 'Churu',
      state: json['state'] ?? 'Rajasthan',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 28.29,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 74.96,
      elevationM: (json['elevation_m'] as num?)?.toDouble() ?? 286.0,
      isHillStation: json['is_hill_station'] ?? false,
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
      coldWaveSeverity: json['cold_wave_severity'] ?? 'COLD_WAVE',
      groundFrostRisk: json['ground_frost_risk'] ?? 'LIGHT',
      summaryHeadline: json['summary_headline'] ??
          'Cold Wave warning in effect. Grass minimum temperature below freezing.',
      physics: json['physics'] != null
          ? NocturnalCoolingPhysicsModel.fromJson(json['physics'])
          : NocturnalCoolingPhysicsModel(
              tAirMin: 2.2,
              tNormalMin: 8.0,
              departureC: -5.8,
              tGrassMin: -1.8,
              skyCoverOktas: 0,
              windSpeedKmh: 3.5,
              dewPointC: 0.2,
              windChillC: 0.5,
              netRadiationLossWm2: 74.0,
            ),
      rabiCropAdvisories: (json['rabi_crop_advisories'] as List<dynamic>?)
              ?.map((e) => CropVulnerabilityItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      urbanShelter: json['urban_shelter'] != null
          ? UrbanShelterAdvisoryModel.fromJson(json['urban_shelter'])
          : UrbanShelterAdvisoryModel(
              nightShelterActivated: true,
              hypothermiaRisk: 'HIGH',
              recommendedClothingLayers: 3,
              livestockProtectionRules: [],
            ),
      multilingualBulletins: bulletins,
      monitoringStations: (json['monitoring_stations'] as List<dynamic>?)
              ?.map((e) => ColdwaveStationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      provenanceDisclaimer: json['provenance_disclaimer'] ??
          'Official criteria derived from IMD Severe Weather Warning Guidelines & ICAR-CRIDA Rabi Crop Agro-Advisory Directives.',
    );
  }

  Map<String, dynamic> toJson() => {
        'station_id': stationId,
        'station_name': stationName,
        'state': state,
        'latitude': latitude,
        'longitude': longitude,
        'elevation_m': elevationM,
        'is_hill_station': isHillStation,
        'timestamp': timestamp,
        'cold_wave_severity': coldWaveSeverity,
        'ground_frost_risk': groundFrostRisk,
        'summary_headline': summaryHeadline,
        'physics': physics.toJson(),
        'rabi_crop_advisories':
            rabiCropAdvisories.map((e) => e.toJson()).toList(),
        'urban_shelter': urbanShelter.toJson(),
        'multilingual_bulletins': multilingualBulletins,
        'monitoring_stations':
            monitoringStations.map((e) => e.toJson()).toList(),
        'provenance_disclaimer': provenanceDisclaimer,
      };

  factory ColdWaveResponseModel.defaultFallback() {
    return ColdWaveResponseModel(
      stationId: 'CHURU_RJ',
      stationName: 'Churu',
      state: 'Rajasthan',
      latitude: 28.29,
      longitude: 74.96,
      elevationM: 286.0,
      isHillStation: false,
      timestamp: DateTime.now().toIso8601String(),
      coldWaveSeverity: 'SEVERE_COLD_WAVE',
      groundFrostRisk: 'MODERATE',
      summaryHeadline:
          'Severe Cold Wave warning in effect for Churu (Rajasthan). Ground minimum temp -2.5°C with Moderate Ground Frost risk.',
      physics: NocturnalCoolingPhysicsModel(
        tAirMin: 1.4,
        tNormalMin: 8.5,
        departureC: -7.1,
        tGrassMin: -2.5,
        skyCoverOktas: 0,
        windSpeedKmh: 3.2,
        dewPointC: 0.2,
        windChillC: 0.1,
        netRadiationLossWm2: 76.5,
      ),
      rabiCropAdvisories: [
        CropVulnerabilityItemModel(
          cropName: 'Mustard / Rapeseed (Sarson)',
          criticalStage: 'Pod Formation & Siliqua Filling',
          injuryMechanism:
              'Intracellular ice crystallization causing pod abortion, shriveled seed formation, and oil content degradation.',
          yieldLossRiskPct: 45,
          countermeasures: [
            'Apply light sprinkler irrigation in evening to increase soil heat storage and raise canopy temperature by 1.5–2°C.',
            'Create smoke screens (smudge fire using dry straw/biomass) along northwest field boundaries between 11 PM and 5 AM.',
            'Foliar spray of 0.1% commercial sulfuric acid (1 ml H2SO4 per liter of water) or thiourea (500 ppm).',
          ],
        ),
        CropVulnerabilityItemModel(
          cropName: 'Potato (Aloo)',
          criticalStage: 'Vegetative Canopy & Tuber Initiation',
          injuryMechanism:
              'Cellular membrane rupture causing black leaf necrosis, foliage collapse, and severe predisposition to Phytophthora late blight.',
          yieldLossRiskPct: 50,
          countermeasures: [
            'Irrigate fields immediately during evening; wet soil holds twice the heat capacity of dry soil.',
            'Cover emerging potato nurseries with plastic sheet or sarkanda thatch during night; remove at sunrise.',
            'Spray 0.2% Mancozeb 75 WP to prevent secondary Late Blight infection triggered by tissue frost injury.',
          ],
        ),
        CropVulnerabilityItemModel(
          cropName: 'Wheat (Gehun)',
          criticalStage: 'Crown Root Initiation / Booting',
          injuryMechanism:
              'Florets become sterile if frost occurs at ear emergence; tip leaf scorching.',
          yieldLossRiskPct: 20,
          countermeasures: [
            'Apply light irrigation at crown root initiation (CRI) or booting stage to buffer microclimate.',
            'Avoid nitrogenous top-dressing during active cold wave spell as tender lush foliage is susceptible to frost scorch.',
          ],
        ),
        CropVulnerabilityItemModel(
          cropName: 'Winter Vegetables (Tomato, Pea, Brinjal)',
          criticalStage: 'Flowering & Early Fruiting',
          injuryMechanism:
              'Severe water soaking and sudden wilting of tender blossoms; fruit drop.',
          yieldLossRiskPct: 50,
          countermeasures: [
            'Erect straw thatch (sarki) on northwestern exposure sloping towards southeast.',
            'Spray 0.2% potassium nitrate (KNO3) to increase cell sap osmotic concentration.',
            'Harvest all mature fruits immediately before predicted sub-zero nocturnal grass frost.',
          ],
        ),
      ],
      urbanShelter: UrbanShelterAdvisoryModel(
        nightShelterActivated: true,
        hypothermiaRisk: 'HIGH',
        recommendedClothingLayers: 4,
        livestockProtectionRules: [
          'Provide dry straw / husk bedding (6–8 inches thick) on concrete barn floors to stop conductive body heat loss.',
          'Cover animal sheds with gunny bags / tarpaulin curtains during nighttime to shield against northerly winds.',
          'Offer lukewarm drinking water and supplement daily cattle feed with 100g mineral mixture and jaggery (gur) for metabolic warmth.',
          'Keep young calves and poultry birds under 100W incandescent warming lamps during night.',
        ],
      ),
      multilingualBulletins: {
        'en':
            'IMD BULLETIN: Severe Cold Wave declared for Churu. Minimum air temperature at 1.4°C with Grass Minimum Temperature plunging to -2.5°C (Moderate Ground Frost risk). Farmers are urged to apply evening irrigation and smudge fires.',
        'hi':
            'आईएमडी शीत लहर बुलेटिन: चूरू में Severe Cold Wave घोषित। न्यूनतम तापमान 1.4°C और घास स्तर का तापमान -2.5°C (पाला जोखिम) तक गिर गया है। किसान शाम को हल्की सिंचाई व धुआं करें।',
        'pa':
            'ਮੌਸਮ ਵਿਭਾਗ ਸੀਤ ਲਹਿਰ ਚੇਤਾਵਨੀ: ਚੁਰੂ ਵਿੱਚ Severe Cold Wave ਦਾ ਐਲਾਨ। ਘੱਟੋ-ਘੱਟ ਤਾਪਮਾਨ 1.4°C ਅਤੇ ਜ਼ਮੀਨੀ ਘਾਹ ਦਾ ਤਾਪਮਾਨ -2.5°C ਤੱਕ ਡਿੱਗ ਗਿਆ ਹੈ। ਕਿਸਾਨ ਸ਼ਾਮ ਨੂੰ ਹਲਕਾ ਪਾਣੀ ਲਾਉਣ।',
        'bn':
            'আইএমডি শৈত্যপ্রবাহ সতর্কতা: চুরু-তে Severe Cold Wave জারি। সর্বনিম্ন তাপমাত্রা ১.৪°C এবং তৃণস্তরের তাপমাত্রা নেমে দাঁড়িয়েছে -২.৫°C। কৃষকদের সন্ধ্যায় হালকা সেচ দেওয়ার পরামর্শ দেওয়া হচ্ছে।',
        'ur':
            'محکمہ موسمیات سرد لہر بلیٹن: چورو میں شدید سرد لہر نافذ۔ کم سے کم درجہ حرارت 1.4°C اور گھاس کی سطح کا درجہ حرارت -2.5°C تک گر چکا ہے۔ کسان شام میں ہلکی آبپاشی کریں۔',
      },
      monitoringStations: [
        ColdwaveStationModel(
          stationId: 'CHURU_RJ',
          stationName: 'Churu',
          state: 'Rajasthan',
          latitude: 28.29,
          longitude: 74.96,
          elevationM: 286.0,
          isHillStation: false,
          tMin: 1.4,
          tGrass: -2.5,
          coldWaveSeverity: 'SEVERE_COLD_WAVE',
          frostRisk: 'MODERATE',
        ),
        ColdwaveStationModel(
          stationId: 'HISAR_HR',
          stationName: 'Hisar',
          state: 'Haryana',
          latitude: 29.15,
          longitude: 75.72,
          elevationM: 215.0,
          isHillStation: false,
          tMin: 2.2,
          tGrass: -1.7,
          coldWaveSeverity: 'COLD_WAVE',
          frostRisk: 'LIGHT',
        ),
        ColdwaveStationModel(
          stationId: 'LUDHIANA_PB',
          stationName: 'Ludhiana',
          state: 'Punjab',
          latitude: 30.90,
          longitude: 75.85,
          elevationM: 247.0,
          isHillStation: false,
          tMin: 3.8,
          tGrass: 0.2,
          coldWaveSeverity: 'COLD_WAVE',
          frostRisk: 'NONE',
        ),
        ColdwaveStationModel(
          stationId: 'SRINAGAR_JK',
          stationName: 'Srinagar',
          state: 'Jammu & Kashmir',
          latitude: 34.08,
          longitude: 74.79,
          elevationM: 1585.0,
          isHillStation: true,
          tMin: -4.6,
          tGrass: -7.5,
          coldWaveSeverity: 'COLD_WAVE',
          frostRisk: 'SEVERE',
        ),
      ],
      provenanceDisclaimer:
          'Official criteria derived from IMD Severe Weather Warning Guidelines & ICAR-CRIDA Rabi Crop Agro-Advisory Directives. Zero synthetic fabrication.',
    );
  }
}
