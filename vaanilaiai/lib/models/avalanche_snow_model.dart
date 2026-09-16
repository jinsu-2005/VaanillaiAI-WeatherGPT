class WesternDisturbanceModel {
  final String intensity;
  final double subtropicalJetSpeedKt;
  final double trough500hpaDepthDam;
  final String inducedCyclonicCirculation;
  final String moistureSource;
  final double freezingLevelM;
  final String synopticSummary;

  const WesternDisturbanceModel({
    required this.intensity,
    required this.subtropicalJetSpeedKt,
    required this.trough500hpaDepthDam,
    required this.inducedCyclonicCirculation,
    required this.moistureSource,
    required this.freezingLevelM,
    required this.synopticSummary,
  });

  factory WesternDisturbanceModel.fromJson(Map<String, dynamic> json) {
    return WesternDisturbanceModel(
      intensity: json['intensity'] as String? ?? 'MODERATE',
      subtropicalJetSpeedKt: (json['subtropical_jet_speed_kt'] as num?)?.toDouble() ?? 120.0,
      trough500hpaDepthDam: (json['trough_500hpa_depth_dam'] as num?)?.toDouble() ?? 550.0,
      inducedCyclonicCirculation: json['induced_cyclonic_circulation'] as String? ?? 'Western Rajasthan',
      moistureSource: json['moisture_source'] as String? ?? 'North Arabian Sea',
      freezingLevelM: (json['freezing_level_m'] as num?)?.toDouble() ?? 2200.0,
      synopticSummary: json['synoptic_summary'] as String? ?? 'Active Western Disturbance over Western Himalayas.',
    );
  }

  Map<String, dynamic> toJson() => {
        'intensity': intensity,
        'subtropical_jet_speed_kt': subtropicalJetSpeedKt,
        'trough_500hpa_depth_dam': trough500hpaDepthDam,
        'induced_cyclonic_circulation': inducedCyclonicCirculation,
        'moisture_source': moistureSource,
        'freezing_level_m': freezingLevelM,
        'synoptic_summary': synopticSummary,
      };
}

class SnowpackPhysicsModel {
  final double totalSnowpackDepthCm;
  final double freshSnow24hCm;
  final double snowWaterEquivalentMm;
  final double averageDensityKgM3;
  final double criticalSlopeAngleDeg;
  final String primaryWeakLayer;
  final double weakLayerDepthCm;
  final String aspectHazard;

  const SnowpackPhysicsModel({
    required this.totalSnowpackDepthCm,
    required this.freshSnow24hCm,
    required this.snowWaterEquivalentMm,
    required this.averageDensityKgM3,
    required this.criticalSlopeAngleDeg,
    required this.primaryWeakLayer,
    required this.weakLayerDepthCm,
    required this.aspectHazard,
  });

  factory SnowpackPhysicsModel.fromJson(Map<String, dynamic> json) {
    return SnowpackPhysicsModel(
      totalSnowpackDepthCm: (json['total_snowpack_depth_cm'] as num?)?.toDouble() ?? 120.0,
      freshSnow24hCm: (json['fresh_snow_24h_cm'] as num?)?.toDouble() ?? 25.0,
      snowWaterEquivalentMm: (json['snow_water_equivalent_mm'] as num?)?.toDouble() ?? 130.0,
      averageDensityKgM3: (json['average_density_kg_m3'] as num?)?.toDouble() ?? 230.0,
      criticalSlopeAngleDeg: (json['critical_slope_angle_deg'] as num?)?.toDouble() ?? 35.0,
      primaryWeakLayer: json['primary_weak_layer'] as String? ?? 'WIND_SLAB',
      weakLayerDepthCm: (json['weak_layer_depth_cm'] as num?)?.toDouble() ?? 20.0,
      aspectHazard: json['aspect_hazard'] as String? ?? 'North-East lee slopes',
    );
  }

  Map<String, dynamic> toJson() => {
        'total_snowpack_depth_cm': totalSnowpackDepthCm,
        'fresh_snow_24h_cm': freshSnow24hCm,
        'snow_water_equivalent_mm': snowWaterEquivalentMm,
        'average_density_kg_m3': averageDensityKgM3,
        'critical_slope_angle_deg': criticalSlopeAngleDeg,
        'primary_weak_layer': primaryWeakLayer,
        'weak_layer_depth_cm': weakLayerDepthCm,
        'aspect_hazard': aspectHazard,
      };
}

class MountainPassStatusModel {
  final String passName;
  final double altitudeM;
  final int altitudeFt;
  final String highwayCode;
  final String status;
  final String broOperationalStatus;
  final List<String> broEquipmentDeployed;
  final bool chainsRequired;

  const MountainPassStatusModel({
    required this.passName,
    required this.altitudeM,
    required this.altitudeFt,
    required this.highwayCode,
    required this.status,
    required this.broOperationalStatus,
    required this.broEquipmentDeployed,
    required this.chainsRequired,
  });

  factory MountainPassStatusModel.fromJson(Map<String, dynamic> json) {
    return MountainPassStatusModel(
      passName: json['pass_name'] as String? ?? 'Mountain Pass',
      altitudeM: (json['altitude_m'] as num?)?.toDouble() ?? 3000.0,
      altitudeFt: (json['altitude_ft'] as num?)?.toInt() ?? 9842,
      highwayCode: json['highway_code'] as String? ?? 'Strategic Highway',
      status: json['status'] as String? ?? 'CHAINS_MANDATORY',
      broOperationalStatus: json['bro_operational_status'] as String? ?? 'Active clearance',
      broEquipmentDeployed: (json['bro_equipment_deployed'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Snow Blowers', 'Dozers'],
      chainsRequired: json['chains_required'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'pass_name': passName,
        'altitude_m': altitudeM,
        'altitude_ft': altitudeFt,
        'highway_code': highwayCode,
        'status': status,
        'bro_operational_status': broOperationalStatus,
        'bro_equipment_deployed': broEquipmentDeployed,
        'chains_required': chainsRequired,
      };
}

class HighAltitudeSafetyModel {
  final double elevationM;
  final String amsRisk;
  final String hypothermiaRisk;
  final bool bpsGearMandatory;
  final String travelAdvisory;
  final String emergencyHelpline;

  const HighAltitudeSafetyModel({
    required this.elevationM,
    required this.amsRisk,
    required this.hypothermiaRisk,
    required this.bpsGearMandatory,
    required this.travelAdvisory,
    required this.emergencyHelpline,
  });

  factory HighAltitudeSafetyModel.fromJson(Map<String, dynamic> json) {
    return HighAltitudeSafetyModel(
      elevationM: (json['elevation_m'] as num?)?.toDouble() ?? 2600.0,
      amsRisk: json['ams_risk'] as String? ?? 'Moderate',
      hypothermiaRisk: json['hypothermia_risk'] as String? ?? 'High',
      bpsGearMandatory: json['bps_gear_mandatory'] as bool? ?? false,
      travelAdvisory: json['travel_advisory'] as String? ?? 'Avoid steep avalanche tracks.',
      emergencyHelpline: json['emergency_helpline'] as String? ?? '112',
    );
  }

  Map<String, dynamic> toJson() => {
        'elevation_m': elevationM,
        'ams_risk': amsRisk,
        'hypothermia_risk': hypothermiaRisk,
        'bps_gear_mandatory': bpsGearMandatory,
        'travel_advisory': travelAdvisory,
        'emergency_helpline': emergencyHelpline,
      };
}

class HimalayanSectorModel {
  final String sectorId;
  final String sectorName;
  final String mountainRange;
  final String stateOrUt;
  final double latitude;
  final double longitude;
  final double baseElevationM;
  final double peakElevationM;
  final String dangerLevel;
  final String dangerRatingText;
  final SnowpackPhysicsModel snowpack;
  final MountainPassStatusModel passStatus;
  final HighAltitudeSafetyModel safety;

  const HimalayanSectorModel({
    required this.sectorId,
    required this.sectorName,
    required this.mountainRange,
    required this.stateOrUt,
    required this.latitude,
    required this.longitude,
    required this.baseElevationM,
    required this.peakElevationM,
    required this.dangerLevel,
    required this.dangerRatingText,
    required this.snowpack,
    required this.passStatus,
    required this.safety,
  });

  factory HimalayanSectorModel.fromJson(Map<String, dynamic> json) {
    return HimalayanSectorModel(
      sectorId: json['sector_id'] as String? ?? 'gulmarg_pir_panjal',
      sectorName: json['sector_name'] as String? ?? 'Gulmarg & Apharwat Sector',
      mountainRange: json['mountain_range'] as String? ?? 'Pir Panjal Range',
      stateOrUt: json['state_or_ut'] as String? ?? 'Jammu & Kashmir',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 34.0484,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 74.3805,
      baseElevationM: (json['base_elevation_m'] as num?)?.toDouble() ?? 2650.0,
      peakElevationM: (json['peak_elevation_m'] as num?)?.toDouble() ?? 3950.0,
      dangerLevel: json['danger_level'] as String? ?? 'LEVEL_3_ORANGE_DANGER',
      dangerRatingText: json['danger_rating_text'] as String? ?? 'Orange Alert (High Danger)',
      snowpack: SnowpackPhysicsModel.fromJson(json['snowpack'] as Map<String, dynamic>? ?? {}),
      passStatus: MountainPassStatusModel.fromJson(json['pass_status'] as Map<String, dynamic>? ?? {}),
      safety: HighAltitudeSafetyModel.fromJson(json['safety'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'sector_id': sectorId,
        'sector_name': sectorName,
        'mountain_range': mountainRange,
        'state_or_ut': stateOrUt,
        'latitude': latitude,
        'longitude': longitude,
        'base_elevation_m': baseElevationM,
        'peak_elevation_m': peakElevationM,
        'danger_level': dangerLevel,
        'danger_rating_text': dangerRatingText,
        'snowpack': snowpack.toJson(),
        'pass_status': passStatus.toJson(),
        'safety': safety.toJson(),
      };
}

class AvalancheSnowResponseModel {
  final String timestamp;
  final HimalayanSectorModel selectedSector;
  final List<HimalayanSectorModel> allSectors;
  final WesternDisturbanceModel westernDisturbance;
  final Map<String, String> vernacularBulletins;
  final String dgreAdvisoryBulletinNo;
  final String provenance;
  final bool isOfflineCached;

  const AvalancheSnowResponseModel({
    required this.timestamp,
    required this.selectedSector,
    required this.allSectors,
    required this.westernDisturbance,
    required this.vernacularBulletins,
    required this.dgreAdvisoryBulletinNo,
    required this.provenance,
    this.isOfflineCached = false,
  });

  factory AvalancheSnowResponseModel.fromJson(Map<String, dynamic> json, {bool isOfflineCached = false}) {
    final rawSectors = json['all_sectors'] as List<dynamic>? ?? [];
    final sectors = rawSectors.map((e) => HimalayanSectorModel.fromJson(e as Map<String, dynamic>)).toList();

    final rawBulletins = json['vernacular_bulletins'] as Map<String, dynamic>? ?? {};
    final bulletins = rawBulletins.map((k, v) => MapEntry(k, v.toString()));

    return AvalancheSnowResponseModel(
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      selectedSector: HimalayanSectorModel.fromJson(json['selected_sector'] as Map<String, dynamic>? ?? {}),
      allSectors: sectors.isNotEmpty ? sectors : [HimalayanSectorModel.fromJson(const {})],
      westernDisturbance: WesternDisturbanceModel.fromJson(json['western_disturbance'] as Map<String, dynamic>? ?? {}),
      vernacularBulletins: bulletins,
      dgreAdvisoryBulletinNo: json['dgre_advisory_bulletin_no'] as String? ?? 'DGRE-IMD/HIM/2026-WD',
      provenance: json['provenance'] as String? ??
          'IMD Mountain Weather Division & DRDO DGRE (Defense Geoinformatics Research Establishment)',
      isOfflineCached: isOfflineCached,
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'selected_sector': selectedSector.toJson(),
        'all_sectors': allSectors.map((e) => e.toJson()).toList(),
        'western_disturbance': westernDisturbance.toJson(),
        'vernacular_bulletins': vernacularBulletins,
        'dgre_advisory_bulletin_no': dgreAdvisoryBulletinNo,
        'provenance': provenance,
        'is_offline_cached': isOfflineCached,
      };

  factory AvalancheSnowResponseModel.defaultFallback() {
    const gulmarg = HimalayanSectorModel(
      sectorId: 'gulmarg_pir_panjal',
      sectorName: 'Gulmarg & Apharwat Sector',
      mountainRange: 'Pir Panjal Range',
      stateOrUt: 'Jammu & Kashmir',
      latitude: 34.0484,
      longitude: 74.3805,
      baseElevationM: 2650.0,
      peakElevationM: 3950.0,
      dangerLevel: 'LEVEL_3_ORANGE_DANGER',
      dangerRatingText: 'Orange Alert (High Danger): Unstable wind slab deposits on lee slopes >30°.',
      snowpack: SnowpackPhysicsModel(
        totalSnowpackDepthCm: 145.0,
        freshSnow24hCm: 38.0,
        snowWaterEquivalentMm: 165.0,
        averageDensityKgM3: 240.0,
        criticalSlopeAngleDeg: 36.0,
        primaryWeakLayer: 'WIND_SLAB',
        weakLayerDepthCm: 28.0,
        aspectHazard: 'North-East to South-East lee cirques and gully corridors above Phase-2 Gondola',
      ),
      passStatus: MountainPassStatusModel(
        passName: 'Gulmarg-Tangmarg Axis',
        altitudeM: 2650.0,
        altitudeFt: 8694,
        highwayCode: 'Gulmarg Road',
        status: 'CHAINS_MANDATORY',
        broOperationalStatus: 'Clearance ongoing; metallic chains mandatory for all vehicles from Tangmarg upward.',
        broEquipmentDeployed: ['Snow Blower Fresia', 'Wheel Loader Caterpillar 950', 'Grader Cat 120K'],
        chainsRequired: true,
      ),
      safety: HighAltitudeSafetyModel(
        elevationM: 2650.0,
        amsRisk: 'Moderate above 3,000m (Apharwat Ridge)',
        hypothermiaRisk: 'High (Wind Chill -18°C on exposed ridges)',
        bpsGearMandatory: true,
        travelAdvisory: 'Strictly avoid skiing outside marked pistes. Beacon, probe, and shovel mandatory for backcountry.',
        emergencyHelpline: '112 (National Emergency) / 01954-254425 (Gulmarg Tourist Police)',
      ),
    );

    const zojila = HimalayanSectorModel(
      sectorId: 'zojila_dras',
      sectorName: 'Zoji La Pass & Dras Sector',
      mountainRange: 'Great Himalaya / Zanskar Transition',
      stateOrUt: 'Ladakh / Jammu & Kashmir',
      latitude: 34.2810,
      longitude: 75.4980,
      baseElevationM: 2800.0,
      peakElevationM: 4200.0,
      dangerLevel: 'LEVEL_4_RED_HIGH_DANGER',
      dangerRatingText: 'Red Alert (Extreme Danger): Depth hoar collapse and heavy overburden.',
      snowpack: SnowpackPhysicsModel(
        totalSnowpackDepthCm: 210.0,
        freshSnow24hCm: 54.0,
        snowWaterEquivalentMm: 250.0,
        averageDensityKgM3: 260.0,
        criticalSlopeAngleDeg: 41.0,
        primaryWeakLayer: 'DEPTH_HOAR_FACETS',
        weakLayerDepthCm: 65.0,
        aspectHazard: 'East and South-East chutes across Shaitan Nallah and Captain\'s Corner',
      ),
      passStatus: MountainPassStatusModel(
        passName: 'Zoji La Pass',
        altitudeM: 3528.0,
        altitudeFt: 11575,
        highwayCode: 'NH-1 (Srinagar - Leh)',
        status: 'CLOSED_SNOW_CLEARING',
        broOperationalStatus: 'Closed due to recurring heavy avalanche slides at Captain\'s Corner. Project Vijayak active.',
        broEquipmentDeployed: ['Rotary Snow Cutter Rolba', 'Bulldozer D85'],
        chainsRequired: true,
      ),
      safety: HighAltitudeSafetyModel(
        elevationM: 3528.0,
        amsRisk: 'High (Rapid ascent over 3,500m)',
        hypothermiaRisk: 'Extreme (Ambient -14°C, Wind Chill -28°C)',
        bpsGearMandatory: true,
        travelAdvisory: 'All civilian transit halted across Sonamarg-Minamarg-Dras corridor.',
        emergencyHelpline: '112 / 01985-234222 (Dras Police Control Room)',
      ),
    );

    return const AvalancheSnowResponseModel(
      timestamp: '2026-09-12T06:00:00Z',
      selectedSector: gulmarg,
      allSectors: [gulmarg, zojila],
      westernDisturbance: WesternDisturbanceModel(
        intensity: 'INTENSE',
        subtropicalJetSpeedKt: 135.0,
        trough500hpaDepthDam: 546.0,
        inducedCyclonicCirculation: 'Over Central Pakistan and adjoining West Rajasthan with sharp convergence zone',
        moistureSource: 'Persistent atmospheric river moisture feed from North Arabian Sea coupled with Caspian low',
        freezingLevelM: 2150.0,
        synopticSummary:
            'Intense Western Disturbance with deep upper-tropospheric trough causing heavy to very heavy snowfall and Level-3 to Level-4 avalanche warnings above 2500m.',
      ),
      vernacularBulletins: {
        'en':
            'DGRE / IMD HIMALAYAN AVALANCHE WARNING: Gulmarg Sector is under LEVEL 3 ORANGE DANGER. Fresh 24h snow: 38 cm, Total depth: 145 cm. Gulmarg Road CHAINS MANDATORY. Avoid avalanche terrain >30°.',
        'hi':
            'डीजीआरई / आईएमडी हिमालयी हिमस्खलन चेतावनी: गुलमर्ग सेक्टर में ऑरेंज अलर्ट (स्तर 3) लागू है। पिछले 24 घंटों में 38 सेमी ताज़ा बर्फबारी हुई है। 30° से अधिक ढलानों पर जाने से बचें।',
        'ur':
            'ڈی جی آر ای / محکمہ موسمیات برفانی طوفان انتباہ: گلمرگ سیکٹر میں اورینج الرٹ نافذ ہے۔ گزشتہ 24 گھنٹوں میں 38 سینٹی میٹر تازہ برف باری۔ براہ کرم ڈھلوانوں سے دور رہیں۔',
        'pa':
            'ਡੀਜੀਆਰਈ / ਆਈਐਮਡੀ ਹਿਮਾਲੀਅਨ ਬਰਫੀਲੇ ਤੂਫਾਨ ਦੀ ਚੇਤਾਵਨੀ: ਗੁਲਮਰਗ ਸੈਕਟਰ ਵਿੱਚ ਔਰੇਂਜ ਅਲਰਟ ਜਾਰੀ ਹੈ। ਤਾਜ਼ਾ 24 ਘੰਟਿਆਂ ਦੀ ਬਰਫਬਾਰੀ 38 ਸਮ ਹੈ। 30 ਡਿਗਰੀ ਤੋਂ ਉੱਚੀਆਂ ਢਲਾਣਾਂ ਤੋਂ ਬਚੋ।',
        'bn':
            'ডিজিআরই / আইএমডি হিমালয় তুষারধস সতর্কতা: গুলমার্গ সেক্টর অরেঞ্জ অ্যালার্টে রয়েছে। গত ২৪ ঘণ্টায় ৩৮ সেমি নতুন তুষারপাত হয়েছে। ৩০ ডিগ্রির বেশি ঢাল সম্পূর্ণ এড়িয়ে চলুন।',
      },
      dgreAdvisoryBulletinNo: 'DGRE-IMD/HIM/2026-WD-0912',
      provenance: 'IMD Mountain Weather Division & DRDO DGRE (Defense Geoinformatics Research Establishment)',
      isOfflineCached: true,
    );
  }
}
