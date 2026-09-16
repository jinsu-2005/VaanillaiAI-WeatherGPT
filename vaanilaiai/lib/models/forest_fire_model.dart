class FireWeatherIndicesModel {
  final double ffmcFineFuelMoisture;
  final double dmcDuffMoisture;
  final double dcDroughtCode;
  final double isiInitialSpreadIndex;
  final double buiBuildupIndex;
  final double fwiFireWeatherIndex;
  final String dangerTier;

  const FireWeatherIndicesModel({
    required this.ffmcFineFuelMoisture,
    required this.dmcDuffMoisture,
    required this.dcDroughtCode,
    required this.isiInitialSpreadIndex,
    required this.buiBuildupIndex,
    required this.fwiFireWeatherIndex,
    required this.dangerTier,
  });

  factory FireWeatherIndicesModel.fromJson(Map<String, dynamic> json) {
    return FireWeatherIndicesModel(
      ffmcFineFuelMoisture: (json['ffmc_fine_fuel_moisture'] as num?)?.toDouble() ?? 85.0,
      dmcDuffMoisture: (json['dmc_duff_moisture'] as num?)?.toDouble() ?? 50.0,
      dcDroughtCode: (json['dc_drought_code'] as num?)?.toDouble() ?? 350.0,
      isiInitialSpreadIndex: (json['isi_initial_spread_index'] as num?)?.toDouble() ?? 10.0,
      buiBuildupIndex: (json['bui_buildup_index'] as num?)?.toDouble() ?? 75.0,
      fwiFireWeatherIndex: (json['fwi_fire_weather_index'] as num?)?.toDouble() ?? 25.0,
      dangerTier: json['danger_tier'] as String? ?? 'HIGH',
    );
  }

  Map<String, dynamic> toJson() => {
        'ffmc_fine_fuel_moisture': ffmcFineFuelMoisture,
        'dmc_duff_moisture': dmcDuffMoisture,
        'dc_drought_code': dcDroughtCode,
        'isi_initial_spread_index': isiInitialSpreadIndex,
        'bui_buildup_index': buiBuildupIndex,
        'fwi_fire_weather_index': fwiFireWeatherIndex,
        'danger_tier': dangerTier,
      };
}

class ActiveThermalAnomalyModel {
  final String sensor;
  final String detectionTimestamp;
  final double latitude;
  final double longitude;
  final double brightnessTempKelvin;
  final double fireRadiativePowerMw;
  final double confidencePct;

  const ActiveThermalAnomalyModel({
    required this.sensor,
    required this.detectionTimestamp,
    required this.latitude,
    required this.longitude,
    required this.brightnessTempKelvin,
    required this.fireRadiativePowerMw,
    required this.confidencePct,
  });

  factory ActiveThermalAnomalyModel.fromJson(Map<String, dynamic> json) {
    return ActiveThermalAnomalyModel(
      sensor: json['sensor'] as String? ?? 'SNPP_VIIRS_375M',
      detectionTimestamp: json['detection_timestamp'] as String? ?? DateTime.now().toIso8601String(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      brightnessTempKelvin: (json['brightness_temp_kelvin'] as num?)?.toDouble() ?? 350.0,
      fireRadiativePowerMw: (json['fire_radiative_power_mw'] as num?)?.toDouble() ?? 20.0,
      confidencePct: (json['confidence_pct'] as num?)?.toDouble() ?? 80.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'sensor': sensor,
        'detection_timestamp': detectionTimestamp,
        'latitude': latitude,
        'longitude': longitude,
        'brightness_temp_kelvin': brightnessTempKelvin,
        'fire_radiative_power_mw': fireRadiativePowerMw,
        'confidence_pct': confidencePct,
      };
}

class FireBehaviorMetricsModel {
  final double estimatedRateOfSpreadMHr;
  final double flameLengthM;
  final double firelineIntensityKwM;
  final bool crownFireRisk;
  final double spotFireProbabilityPct;

  const FireBehaviorMetricsModel({
    required this.estimatedRateOfSpreadMHr,
    required this.flameLengthM,
    required this.firelineIntensityKwM,
    required this.crownFireRisk,
    required this.spotFireProbabilityPct,
  });

  factory FireBehaviorMetricsModel.fromJson(Map<String, dynamic> json) {
    return FireBehaviorMetricsModel(
      estimatedRateOfSpreadMHr: (json['estimated_rate_of_spread_m_hr'] as num?)?.toDouble() ?? 400.0,
      flameLengthM: (json['flame_length_m'] as num?)?.toDouble() ?? 2.5,
      firelineIntensityKwM: (json['fireline_intensity_kw_m'] as num?)?.toDouble() ?? 1500.0,
      crownFireRisk: json['crown_fire_risk'] as bool? ?? false,
      spotFireProbabilityPct: (json['spot_fire_probability_pct'] as num?)?.toDouble() ?? 35.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'estimated_rate_of_spread_m_hr': estimatedRateOfSpreadMHr,
        'flame_length_m': flameLengthM,
        'fireline_intensity_kw_m': firelineIntensityKwM,
        'crown_fire_risk': crownFireRisk,
        'spot_fire_probability_pct': spotFireProbabilityPct,
      };
}

class ForestryProtectionDirectivesModel {
  final String rangerDeploymentAlert;
  final double firebreakClearanceWidthM;
  final String wildlifeCorridorStatus;
  final String tribalNtfpCollectionDirective;
  final bool aerialWaterBombingStandby;

  const ForestryProtectionDirectivesModel({
    required this.rangerDeploymentAlert,
    required this.firebreakClearanceWidthM,
    required this.wildlifeCorridorStatus,
    required this.tribalNtfpCollectionDirective,
    required this.aerialWaterBombingStandby,
  });

  factory ForestryProtectionDirectivesModel.fromJson(Map<String, dynamic> json) {
    return ForestryProtectionDirectivesModel(
      rangerDeploymentAlert: json['ranger_deployment_alert'] as String? ?? '',
      firebreakClearanceWidthM: (json['firebreak_clearance_width_m'] as num?)?.toDouble() ?? 10.0,
      wildlifeCorridorStatus: json['wildlife_corridor_status'] as String? ?? '',
      tribalNtfpCollectionDirective: json['tribal_ntfp_collection_directive'] as String? ?? '',
      aerialWaterBombingStandby: json['aerial_water_bombing_standby'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'ranger_deployment_alert': rangerDeploymentAlert,
        'firebreak_clearance_width_m': firebreakClearanceWidthM,
        'wildlife_corridor_status': wildlifeCorridorStatus,
        'tribal_ntfp_collection_directive': tribalNtfpCollectionDirective,
        'aerial_water_bombing_standby': aerialWaterBombingStandby,
      };
}

class ForestFireZoneHotspotModel {
  final String zoneId;
  final String zoneName;
  final String state;
  final String reserveName;
  final double latitude;
  final double longitude;
  final String biomeType;
  final FireWeatherIndicesModel indices;
  final List<ActiveThermalAnomalyModel> activeThermalHotspots;
  final double totalFrpMw;
  final FireBehaviorMetricsModel behavior;
  final ForestryProtectionDirectivesModel directives;
  final Map<String, String> localizedBulletins;

  const ForestFireZoneHotspotModel({
    required this.zoneId,
    required this.zoneName,
    required this.state,
    required this.reserveName,
    required this.latitude,
    required this.longitude,
    required this.biomeType,
    required this.indices,
    required this.activeThermalHotspots,
    required this.totalFrpMw,
    required this.behavior,
    required this.directives,
    required this.localizedBulletins,
  });

  factory ForestFireZoneHotspotModel.fromJson(Map<String, dynamic> json) {
    return ForestFireZoneHotspotModel(
      zoneId: json['zone_id'] as String? ?? 'uttarakhand_garhwal_pine',
      zoneName: json['zone_name'] as String? ?? 'Garhwal & Kumaon Chir Pine Forests',
      state: json['state'] as String? ?? 'Uttarakhand',
      reserveName: json['reserve_name'] as String? ?? 'Almora Forest Division',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 29.62,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 79.66,
      biomeType: json['biome_type'] as String? ?? 'CHIR_PINE_CONIFEROUS',
      indices: FireWeatherIndicesModel.fromJson(
          json['indices'] as Map<String, dynamic>? ?? {}),
      activeThermalHotspots: (json['active_thermal_hotspots'] as List<dynamic>?)
              ?.map((a) => ActiveThermalAnomalyModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      totalFrpMw: (json['total_frp_mw'] as num?)?.toDouble() ?? 100.0,
      behavior: FireBehaviorMetricsModel.fromJson(
          json['behavior'] as Map<String, dynamic>? ?? {}),
      directives: ForestryProtectionDirectivesModel.fromJson(
          json['directives'] as Map<String, dynamic>? ?? {}),
      localizedBulletins: (json['localized_bulletins'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          {},
    );
  }

  Map<String, dynamic> toJson() => {
        'zone_id': zoneId,
        'zone_name': zoneName,
        'state': state,
        'reserve_name': reserveName,
        'latitude': latitude,
        'longitude': longitude,
        'biome_type': biomeType,
        'indices': indices.toJson(),
        'active_thermal_hotspots': activeThermalHotspots.map((a) => a.toJson()).toList(),
        'total_frp_mw': totalFrpMw,
        'behavior': behavior.toJson(),
        'directives': directives.toJson(),
        'localized_bulletins': localizedBulletins,
      };
}

class ForestFireResponse {
  final String timestamp;
  final String bulletinNumber;
  final String provenance;
  final ForestFireZoneHotspotModel selectedZone;
  final List<ForestFireZoneHotspotModel> allZones;
  final Map<String, String> vernacularBulletins;
  final bool isOfflineCached;

  const ForestFireResponse({
    required this.timestamp,
    required this.bulletinNumber,
    required this.provenance,
    required this.selectedZone,
    required this.allZones,
    required this.vernacularBulletins,
    this.isOfflineCached = false,
  });

  factory ForestFireResponse.fromJson(
    Map<String, dynamic> json, {
    bool isOfflineCached = false,
  }) {
    final zonesRaw = json['all_zones'] as List<dynamic>? ?? [];
    final zones = zonesRaw
        .map((z) => ForestFireZoneHotspotModel.fromJson(z as Map<String, dynamic>))
        .toList();

    final selected = json['selected_zone'] != null
        ? ForestFireZoneHotspotModel.fromJson(
            json['selected_zone'] as Map<String, dynamic>)
        : (zones.isNotEmpty ? zones.first : defaultFallback().selectedZone);

    final bulletinsRaw = json['vernacular_bulletins'] as Map<String, dynamic>? ?? {};
    final bulletins = bulletinsRaw.map((k, v) => MapEntry(k, v.toString()));

    return ForestFireResponse(
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      bulletinNumber: json['bulletin_number'] as String? ?? 'FSI-ISRO/FF-FWIE/2026-DEFAULT',
      provenance: json['provenance'] as String? ??
          'Forest Survey of India (Van Agni 2.0) & ISRO-Bhuvan Fire Weather Early Warning',
      selectedZone: selected,
      allZones: zones.isNotEmpty ? zones : [selected],
      vernacularBulletins: bulletins,
      isOfflineCached: isOfflineCached,
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'bulletin_number': bulletinNumber,
        'provenance': provenance,
        'selected_zone': selectedZone.toJson(),
        'all_zones': allZones.map((z) => z.toJson()).toList(),
        'vernacular_bulletins': vernacularBulletins,
        'is_offline_cached': isOfflineCached,
      };

  static ForestFireResponse defaultFallback() {
    const garhwalZone = ForestFireZoneHotspotModel(
      zoneId: 'uttarakhand_garhwal_pine',
      zoneName: 'Garhwal & Kumaon Chir Pine Forests',
      state: 'Uttarakhand',
      reserveName: 'Almora, Pauri & Nainital Forest Divisions',
      latitude: 29.6200,
      longitude: 79.6600,
      biomeType: 'CHIR_PINE_CONIFEROUS',
      indices: FireWeatherIndicesModel(
        ffmcFineFuelMoisture: 92.4,
        dmcDuffMoisture: 68.0,
        dcDroughtCode: 410.0,
        isiInitialSpreadIndex: 14.8,
        buiBuildupIndex: 95.0,
        fwiFireWeatherIndex: 38.6,
        dangerTier: 'VERY_HIGH',
      ),
      activeThermalHotspots: [
        ActiveThermalAnomalyModel(
          sensor: 'SNPP_VIIRS_375M',
          detectionTimestamp: '2026-09-12T03:30:00Z',
          latitude: 29.6350,
          longitude: 79.6720,
          brightnessTempKelvin: 365.4,
          fireRadiativePowerMw: 24.8,
          confidencePct: 92.0,
        ),
      ],
      totalFrpMw: 145.2,
      behavior: FireBehaviorMetricsModel(
        estimatedRateOfSpreadMHr: 620.0,
        flameLengthM: 3.8,
        firelineIntensityKwM: 3200.0,
        crownFireRisk: true,
        spotFireProbabilityPct: 65.0,
      ),
      directives: ForestryProtectionDirectivesModel(
        rangerDeploymentAlert:
            'STAGE-3 VAN SAMITI MOBILIZATION: Immediate beat guard rapid response deployment across pine needle ridges.',
        firebreakClearanceWidthM: 15.0,
        wildlifeCorridorStatus:
            'Wildlife moving toward lower river basins; water troughs replenished in Almora division.',
        tribalNtfpCollectionDirective:
            'Strict prohibition on open flame, beedi smoking, and agricultural residue burning on terraced slopes.',
        aerialWaterBombingStandby: true,
      ),
      localizedBulletins: {
        'en':
            'CRITICAL ALERT: Very High Fire Weather Index (FWI 38.6) in Garhwal-Kumaon Chir Pine forest divisions. Resinous pine needles are producing rapid uphill flame spread (620 m/hr) with spotting risk. Forest fire lines activated.',
        'hi':
            'गंभीर चेतावनी: गढ़वाल और कुमाऊं के चीड़ वनों में अत्यधिक वनाग्नि जोखिम (FWI 38.6)। सूखी चीड़ की पत्तियों (पिरुल) के कारण आग तेजी से ढलानों पर फैल रही है। वन पंचायतों और गश्ती दलों को तुरंत आग बुझाने में लगाया गया है।',
        'kn':
            'ಎಚ್ಚರಿಕೆ: ಗರ್ಹ್ವಾಲ್ ಪೈನ್ ಅರಣ್ಯಗಳಲ್ಲಿ ತೀವ್ರ ಕಾಡ್ಗಿಚ್ಚಿನ ಅಪಾಯ (FWI 38.6). ಬೆಂಕಿ ಹರಡುವ ವೇಗ ಹೆಚ್ಚಾಗಿದ್ದು ನಿಯಂತ್ರಣ ರೇಖೆಗಳನ್ನು ತೆರವುಗೊಳಿಸಲಾಗಿದೆ.',
        'or':
            'ଚେତାବନୀ: ଗଡ଼ୱାଲ ଏବଂ କୁମାଉଁ ପାଇନ ଜଙ୍ଗଲରେ ଭୟଙ୍କର ବଣନିଆଁ ଚେତାବନୀ (FWI 38.6)। ପିରୁଲ ଶୁଖିଲା ପତ୍ର ଯୋଗୁଁ ନିଆଁ ଦ୍ରୁତ ଗତିରେ ମାଡୁଛି।',
        'ta':
            'எச்சரிக்கை: கர்வால்-குமாவோன் பைன் காடுகளில் கடுமையான காட்டுத்தீ அபாயம் (FWI 38.6). காற்று வேகத்தால் தீ மலை முகடுகளில் வேகமாக பரவி வருகிறது.',
      },
    );

    const similipalZone = ForestFireZoneHotspotModel(
      zoneId: 'similipal_tiger_reserve',
      zoneName: 'Similipal Biosphere Reserve & Tiger Sanctuary',
      state: 'Odisha',
      reserveName: 'Similipal Tiger Reserve',
      latitude: 21.8500,
      longitude: 86.3500,
      biomeType: 'DRY_DECIDUOUS_SAL',
      indices: FireWeatherIndicesModel(
        ffmcFineFuelMoisture: 94.2,
        dmcDuffMoisture: 76.5,
        dcDroughtCode: 520.0,
        isiInitialSpreadIndex: 18.2,
        buiBuildupIndex: 112.0,
        fwiFireWeatherIndex: 48.5,
        dangerTier: 'EXTREME',
      ),
      activeThermalHotspots: [
        ActiveThermalAnomalyModel(
          sensor: 'SNPP_VIIRS_375M',
          detectionTimestamp: '2026-09-12T03:45:00Z',
          latitude: 21.8620,
          longitude: 86.3680,
          brightnessTempKelvin: 382.0,
          fireRadiativePowerMw: 45.6,
          confidencePct: 98.0,
        ),
      ],
      totalFrpMw: 210.8,
      behavior: FireBehaviorMetricsModel(
        estimatedRateOfSpreadMHr: 840.0,
        flameLengthM: 4.5,
        firelineIntensityKwM: 4600.0,
        crownFireRisk: true,
        spotFireProbabilityPct: 78.0,
      ),
      directives: ForestryProtectionDirectivesModel(
        rangerDeploymentAlert:
            'RED EMERGENCY PROTOCOL: Full mobilization of Odisha Forest Protection Force and ODRAF squads across Similipal core.',
        firebreakClearanceWidthM: 20.0,
        wildlifeCorridorStatus:
            'Major elephant migration corridor between Barehipani and Chahala active with waterhole solar pump support.',
        tribalNtfpCollectionDirective:
            'Complete moratorium on Mahua flower and Sal seed collection inside core zone until fire danger abates.',
        aerialWaterBombingStandby: true,
      ),
      localizedBulletins: {
        'en':
            'EMERGENCY: Extreme Forest Fire Danger (FWI 48.5) at Similipal Tiger Reserve. Deciduous Sal leaf litter causing high-intensity crown fires (4600 kW/m). Evacuate forest fringe tourist lodges; ODRAF teams deployed.',
        'or':
            'ଜରୁରୀ ସତର୍କତା: ଶିମିଳିପାଳ ବ୍ୟାଘ୍ର ଅଭୟାରଣ୍ୟରେ ଚରମ ବଣନିଆଁ ବିପଦ (FWI 48.5)। ଶାଳ ପତ୍ର ଶୁଖିଲା ଥିବାରୁ ନିଆଁ ଦ୍ରୁତ ବେଗରେ ମାଡୁଛି।',
        'hi':
            'आपातकालीन चेतावनी: सिमलीपाल टाइगर रिजर्व में चरम वनाग्नि अलर्ट (FWI 48.5)। साल के पत्तों के जलने से 4.5 मीटर ऊंची लपटें उठ रही हैं।',
        'kn':
            'ತುರ್ತು ಎಚ್ಚರಿಕೆ: ಸಿಮಿಲಿಪಾಲ್ ಹುಲಿ ಸಂರಕ್ಷಿತ ಪ್ರದೇಶದಲ್ಲಿ ತೀವ್ರ ಕಾಡ್ಗಿಚ್ಚು (FWI 48.5).',
        'ta':
            'அவசர எச்சரிக்கை: சிமிலிபால் புலிகள் காப்பகத்தில் உச்சக்கட்ட காட்டுத்தீ ஆபத்து (FWI 48.5).',
      },
    );

    return const ForestFireResponse(
      timestamp: '2026-09-12T04:30:00Z',
      bulletinNumber: 'FSI-ISRO/FF-FWIE/2026-GARHWAL',
      provenance:
          'Forest Survey of India (Van Agni 2.0) & ISRO-Bhuvan Fire Weather Early Warning',
      selectedZone: garhwalZone,
      allZones: [garhwalZone, similipalZone],
      vernacularBulletins: {
        'en':
            'CRITICAL ALERT: Very High Fire Weather Index (FWI 38.6) in Garhwal-Kumaon Chir Pine forest divisions. Resinous pine needles are producing rapid uphill flame spread (620 m/hr) with spotting risk. Forest fire lines activated.',
        'hi':
            'गंभीर चेतावनी: गढ़वाल और कुमाऊं के चीड़ वनों में अत्यधिक वनाग्नि जोखिम (FWI 38.6)। सूखी चीड़ की पत्तियों (पिरुल) के कारण आग तेजी से ढलानों पर फैल रही है।',
        'kn':
            'ಎಚ್ಚರಿಕೆ: ಗರ್ಹ್ವಾಲ್ ಪೈನ್ ಅರಣ್ಯಗಳಲ್ಲಿ ತೀವ್ರ ಕಾಡ್ಗಿಚ್ಚಿನ ಅಪಾಯ (FWI 38.6). ಬೆಂಕಿ ಹರಡುವ ವೇಗ ಹೆಚ್ಚಾಗಿದ್ದು ನಿಯಂತ್ರಣ ರೇಖೆಗಳನ್ನು ತೆರವುಗೊಳಿಸಲಾಗಿದೆ.',
        'or':
            'ଚେତାବନୀ: ଗଡ଼ୱାଲ ଏବଂ କୁମାଉଁ ପାଇନ ଜଙ୍ଗଲରେ ଭୟଙ୍କର ବଣନିଆଁ ଚେତାବନୀ (FWI 38.6)।',
        'ta':
            'எச்சரிக்கை: கர்வால்-குமாவோன் பைன் காடுகளில் கடுமையான காட்டுத்தீ அபாயம் (FWI 38.6).',
      },
      isOfflineCached: true,
    );
  }
}
