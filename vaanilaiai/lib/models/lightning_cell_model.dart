/// Data models for IITM & IMD Lightning Flash Density,
/// Total Lightning (IC vs CG), Thunderstorm Cell Lifecycle & Severe Downburst Nowcasting.
library;

class TotalLightningModel {
  final double totalFlashRatePerMin;
  final double intraCloudRatePerMin;
  final double cloudToGroundRatePerMin;
  final double icCgRatio;
  final double positiveCgPercentage;
  final double peakStrokeCurrentKa;
  final double continuingCurrentDurationMs;
  final bool isPositiveCgHazard;

  TotalLightningModel({
    required this.totalFlashRatePerMin,
    required this.intraCloudRatePerMin,
    required this.cloudToGroundRatePerMin,
    required this.icCgRatio,
    required this.positiveCgPercentage,
    required this.peakStrokeCurrentKa,
    required this.continuingCurrentDurationMs,
    required this.isPositiveCgHazard,
  });

  factory TotalLightningModel.fromJson(Map<String, dynamic> json) {
    return TotalLightningModel(
      totalFlashRatePerMin: (json['total_flash_rate_per_min'] as num?)?.toDouble() ?? 0.0,
      intraCloudRatePerMin: (json['intra_cloud_rate_per_min'] as num?)?.toDouble() ?? 0.0,
      cloudToGroundRatePerMin: (json['cloud_to_ground_rate_per_min'] as num?)?.toDouble() ?? 0.0,
      icCgRatio: (json['ic_cg_ratio'] as num?)?.toDouble() ?? 1.0,
      positiveCgPercentage: (json['positive_cg_percentage'] as num?)?.toDouble() ?? 0.0,
      peakStrokeCurrentKa: (json['peak_stroke_current_ka'] as num?)?.toDouble() ?? 0.0,
      continuingCurrentDurationMs: (json['continuing_current_duration_ms'] as num?)?.toDouble() ?? 0.0,
      isPositiveCgHazard: json['is_positive_cg_hazard'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'total_flash_rate_per_min': totalFlashRatePerMin,
    'intra_cloud_rate_per_min': intraCloudRatePerMin,
    'cloud_to_ground_rate_per_min': cloudToGroundRatePerMin,
    'ic_cg_ratio': icCgRatio,
    'positive_cg_percentage': positiveCgPercentage,
    'peak_stroke_current_ka': peakStrokeCurrentKa,
    'continuing_current_duration_ms': continuingCurrentDurationMs,
    'is_positive_cg_hazard': isPositiveCgHazard,
  };
}

class LightningJumpModel {
  final double deltaFlashRatePerMinSq;
  final bool jumpDetected;
  final String jumpSeverity;
  final int leadTimeMinutes;
  final double severeWeatherProbabilityPct;

  LightningJumpModel({
    required this.deltaFlashRatePerMinSq,
    required this.jumpDetected,
    required this.jumpSeverity,
    required this.leadTimeMinutes,
    required this.severeWeatherProbabilityPct,
  });

  factory LightningJumpModel.fromJson(Map<String, dynamic> json) {
    return LightningJumpModel(
      deltaFlashRatePerMinSq: (json['delta_flash_rate_per_min_sq'] as num?)?.toDouble() ?? 0.0,
      jumpDetected: json['jump_detected'] as bool? ?? false,
      jumpSeverity: json['jump_severity'] as String? ?? 'NONE',
      leadTimeMinutes: (json['lead_time_minutes'] as num?)?.toInt() ?? 0,
      severeWeatherProbabilityPct: (json['severe_weather_probability_pct'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'delta_flash_rate_per_min_sq': deltaFlashRatePerMinSq,
    'jump_detected': jumpDetected,
    'jump_severity': jumpSeverity,
    'lead_time_minutes': leadTimeMinutes,
    'severe_weather_probability_pct': severeWeatherProbabilityPct,
  };
}

class DownburstRiskModel {
  final double dcapeJKg;
  final double estimatedGustSpeedKmh;
  final String microburstCategory;
  final String damagePotential;

  DownburstRiskModel({
    required this.dcapeJKg,
    required this.estimatedGustSpeedKmh,
    required this.microburstCategory,
    required this.damagePotential,
  });

  factory DownburstRiskModel.fromJson(Map<String, dynamic> json) {
    return DownburstRiskModel(
      dcapeJKg: (json['dcape_j_kg'] as num?)?.toDouble() ?? 0.0,
      estimatedGustSpeedKmh: (json['estimated_gust_speed_kmh'] as num?)?.toDouble() ?? 0.0,
      microburstCategory: json['microburst_category'] as String? ?? 'LIGHT_OUTFLOW',
      damagePotential: json['damage_potential'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'dcape_j_kg': dcapeJKg,
    'estimated_gust_speed_kmh': estimatedGustSpeedKmh,
    'microburst_category': microburstCategory,
    'damage_potential': damagePotential,
  };
}

class DopplerRadarEchoModel {
  final String radarStation;
  final double reflectivityZhhDbz;
  final double differentialReflectivityZdrDb;
  final double correlationCoeffRhoHv;
  final String hydrometeorClassification;
  final bool hailCoreAloftDetected;

  DopplerRadarEchoModel({
    required this.radarStation,
    required this.reflectivityZhhDbz,
    required this.differentialReflectivityZdrDb,
    required this.correlationCoeffRhoHv,
    required this.hydrometeorClassification,
    required this.hailCoreAloftDetected,
  });

  factory DopplerRadarEchoModel.fromJson(Map<String, dynamic> json) {
    return DopplerRadarEchoModel(
      radarStation: json['radar_station'] as String? ?? '',
      reflectivityZhhDbz: (json['reflectivity_zhh_dbz'] as num?)?.toDouble() ?? 0.0,
      differentialReflectivityZdrDb: (json['differential_reflectivity_zdr_db'] as num?)?.toDouble() ?? 0.0,
      correlationCoeffRhoHv: (json['correlation_coeff_rho_hv'] as num?)?.toDouble() ?? 0.0,
      hydrometeorClassification: json['hydrometeor_classification'] as String? ?? 'HEAVY_RAIN',
      hailCoreAloftDetected: json['hail_core_aloft_detected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'radar_station': radarStation,
    'reflectivity_zhh_dbz': reflectivityZhhDbz,
    'differential_reflectivity_zdr_db': differentialReflectivityZdrDb,
    'correlation_coeff_rho_hv': correlationCoeffRhoHv,
    'hydrometeor_classification': hydrometeorClassification,
    'hail_core_aloft_detected': hailCoreAloftDetected,
  };
}

class ClimatologicalFlashDensityModel {
  final String districtName;
  final String stateName;
  final double annualFlashDensityPerSqKm;
  final double nationalHazardPercentile;
  final String climatologicalTier;
  final String fiveYearTrend;

  ClimatologicalFlashDensityModel({
    required this.districtName,
    required this.stateName,
    required this.annualFlashDensityPerSqKm,
    required this.nationalHazardPercentile,
    required this.climatologicalTier,
    required this.fiveYearTrend,
  });

  factory ClimatologicalFlashDensityModel.fromJson(Map<String, dynamic> json) {
    return ClimatologicalFlashDensityModel(
      districtName: json['district_name'] as String? ?? '',
      stateName: json['state_name'] as String? ?? '',
      annualFlashDensityPerSqKm: (json['annual_flash_density_per_sq_km'] as num?)?.toDouble() ?? 0.0,
      nationalHazardPercentile: (json['national_hazard_percentile'] as num?)?.toDouble() ?? 0.0,
      climatologicalTier: json['climatological_tier'] as String? ?? 'MODERATE_CORRIDOR',
      fiveYearTrend: json['five_year_trend'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'district_name': districtName,
    'state_name': stateName,
    'annual_flash_density_per_sq_km': annualFlashDensityPerSqKm,
    'national_hazard_percentile': nationalHazardPercentile,
    'climatological_tier': climatologicalTier,
    'five_year_trend': fiveYearTrend,
  };
}

class LightningHotspotCorridorModel {
  final String id;
  final String name;
  final String state;
  final double latitude;
  final double longitude;
  final String primaryDriver;
  final String nearestDwrStation;

  LightningHotspotCorridorModel({
    required this.id,
    required this.name,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.primaryDriver,
    required this.nearestDwrStation,
  });

  factory LightningHotspotCorridorModel.fromJson(Map<String, dynamic> json) {
    return LightningHotspotCorridorModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      state: json['state'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      primaryDriver: json['primary_driver'] as String? ?? '',
      nearestDwrStation: json['nearest_dwr_station'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'state': state,
    'latitude': latitude,
    'longitude': longitude,
    'primary_driver': primaryDriver,
    'nearest_dwr_station': nearestDwrStation,
  };
}

class LightningSafetyGuidelinesModel {
  final String antiTreeWarning;
  final String lightningCrouchPosture;
  final String metalImplementProhibition;
  final String indoorPuccaShelterGuidance;
  final String cprResuscitationGuideline;

  LightningSafetyGuidelinesModel({
    required this.antiTreeWarning,
    required this.lightningCrouchPosture,
    required this.metalImplementProhibition,
    required this.indoorPuccaShelterGuidance,
    required this.cprResuscitationGuideline,
  });

  factory LightningSafetyGuidelinesModel.fromJson(Map<String, dynamic> json) {
    return LightningSafetyGuidelinesModel(
      antiTreeWarning: json['anti_tree_warning'] as String? ?? '',
      lightningCrouchPosture: json['lightning_crouch_posture'] as String? ?? '',
      metalImplementProhibition: json['metal_implement_prohibition'] as String? ?? '',
      indoorPuccaShelterGuidance: json['indoor_pucca_shelter_guidance'] as String? ?? '',
      cprResuscitationGuideline: json['cpr_resuscitation_guideline'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'anti_tree_warning': antiTreeWarning,
    'lightning_crouch_posture': lightningCrouchPosture,
    'metal_implement_prohibition': metalImplementProhibition,
    'indoor_pucca_shelter_guidance': indoorPuccaShelterGuidance,
    'cpr_resuscitation_guideline': cprResuscitationGuideline,
  };
}

class LightningCellResponseModel {
  final LightningHotspotCorridorModel corridor;
  final String threatTier;
  final String cellStage;
  final double nearestCellDistanceKm;
  final double cellMovementHeadingDeg;
  final double cellSpeedKmh;
  final TotalLightningModel totalLightning;
  final LightningJumpModel lightningJump;
  final DownburstRiskModel downburstRisk;
  final DopplerRadarEchoModel radarEcho;
  final ClimatologicalFlashDensityModel climatology;
  final LightningSafetyGuidelinesModel ndmaGuidelines;
  final Map<String, String> vernacularBulletins;
  final String timestamp;
  final bool isOfflineFallback;

  LightningCellResponseModel({
    required this.corridor,
    required this.threatTier,
    required this.cellStage,
    required this.nearestCellDistanceKm,
    required this.cellMovementHeadingDeg,
    required this.cellSpeedKmh,
    required this.totalLightning,
    required this.lightningJump,
    required this.downburstRisk,
    required this.radarEcho,
    required this.climatology,
    required this.ndmaGuidelines,
    required this.vernacularBulletins,
    required this.timestamp,
    this.isOfflineFallback = false,
  });

  factory LightningCellResponseModel.fromJson(Map<String, dynamic> json) {
    final rawBulletins = json['vernacular_bulletins'] as Map<String, dynamic>?;
    final Map<String, String> bulletins = {};
    if (rawBulletins != null) {
      rawBulletins.forEach((k, v) {
        bulletins[k] = v.toString();
      });
    }

    return LightningCellResponseModel(
      corridor: LightningHotspotCorridorModel.fromJson(json['corridor'] as Map<String, dynamic>? ?? {}),
      threatTier: json['threat_tier'] as String? ?? 'MODERATE',
      cellStage: json['cell_stage'] as String? ?? 'MATURE_SUPERCELL',
      nearestCellDistanceKm: (json['nearest_cell_distance_km'] as num?)?.toDouble() ?? 10.0,
      cellMovementHeadingDeg: (json['cell_movement_heading_deg'] as num?)?.toDouble() ?? 90.0,
      cellSpeedKmh: (json['cell_speed_kmh'] as num?)?.toDouble() ?? 35.0,
      totalLightning: TotalLightningModel.fromJson(json['total_lightning'] as Map<String, dynamic>? ?? {}),
      lightningJump: LightningJumpModel.fromJson(json['lightning_jump'] as Map<String, dynamic>? ?? {}),
      downburstRisk: DownburstRiskModel.fromJson(json['downburst_risk'] as Map<String, dynamic>? ?? {}),
      radarEcho: DopplerRadarEchoModel.fromJson(json['radar_echo'] as Map<String, dynamic>? ?? {}),
      climatology: ClimatologicalFlashDensityModel.fromJson(json['climatology'] as Map<String, dynamic>? ?? {}),
      ndmaGuidelines: LightningSafetyGuidelinesModel.fromJson(json['ndma_guidelines'] as Map<String, dynamic>? ?? {}),
      vernacularBulletins: bulletins,
      timestamp: json['timestamp'] as String? ?? DateTime.now().toUtc().toIso8601String(),
      isOfflineFallback: json['is_offline_fallback'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'corridor': corridor.toJson(),
    'threat_tier': threatTier,
    'cell_stage': cellStage,
    'nearest_cell_distance_km': nearestCellDistanceKm,
    'cell_movement_heading_deg': cellMovementHeadingDeg,
    'cell_speed_kmh': cellSpeedKmh,
    'total_lightning': totalLightning.toJson(),
    'lightning_jump': lightningJump.toJson(),
    'downburst_risk': downburstRisk.toJson(),
    'radar_echo': radarEcho.toJson(),
    'climatology': climatology.toJson(),
    'ndma_guidelines': ndmaGuidelines.toJson(),
    'vernacular_bulletins': vernacularBulletins,
    'timestamp': timestamp,
    'is_offline_fallback': isOfflineFallback,
  };

  /// Resilient offline baseline fallback model
  factory LightningCellResponseModel.defaultFallback() {
    return LightningCellResponseModel(
      corridor: LightningHotspotCorridorModel(
        id: 'mayurbhanj_odisha',
        name: 'Mayurbhanj & Chota Nagpur Corridor',
        state: 'Odisha / Jharkhand',
        latitude: 21.93,
        longitude: 86.73,
        primaryDriver: 'Chota Nagpur elevated plateau heating & maritime squall line convergence',
        nearestDwrStation: 'DWR Paradip (Odisha)',
      ),
      threatTier: 'EXTREME',
      cellStage: 'MATURE_SUPERCELL',
      nearestCellDistanceKm: 6.8,
      cellMovementHeadingDeg: 125.0,
      cellSpeedKmh: 42.0,
      totalLightning: TotalLightningModel(
        totalFlashRatePerMin: 68.0,
        intraCloudRatePerMin: 51.0,
        cloudToGroundRatePerMin: 17.0,
        icCgRatio: 3.0,
        positiveCgPercentage: 18.5,
        peakStrokeCurrentKa: 128.0,
        continuingCurrentDurationMs: 52.0,
        isPositiveCgHazard: true,
      ),
      lightningJump: LightningJumpModel(
        deltaFlashRatePerMinSq: 16.5,
        jumpDetected: true,
        jumpSeverity: 'CRITICAL',
        leadTimeMinutes: 25,
        severeWeatherProbabilityPct: 92.0,
      ),
      downburstRisk: DownburstRiskModel(
        dcapeJKg: 1280.0,
        estimatedGustSpeedKmh: 309.1,
        microburstCategory: 'SEVERE_WET_MICROBURST',
        damagePotential: 'Roof de-sheeting, uprooting of large trees, collapse of tin sheds and transmission towers.',
      ),
      radarEcho: DopplerRadarEchoModel(
        radarStation: 'DWR Paradip (Odisha)',
        reflectivityZhhDbz: 61.2,
        differentialReflectivityZdrDb: 0.22,
        correlationCoeffRhoHv: 0.88,
        hydrometeorClassification: 'GRAUPEL_HAIL_CORE',
        hailCoreAloftDetected: true,
      ),
      climatology: ClimatologicalFlashDensityModel(
        districtName: 'Mayurbhanj',
        stateName: 'Odisha',
        annualFlashDensityPerSqKm: 38.4,
        nationalHazardPercentile: 99.2,
        climatologicalTier: 'EXTREME_CORRIDOR',
        fiveYearTrend: 'INCREASING (+14% over 5-yr baseline)',
      ),
      ndmaGuidelines: LightningSafetyGuidelinesModel(
        antiTreeWarning: 'CRITICAL WARNING: 71% of lightning fatalities occur under trees. NEVER shelter under trees or open sheds.',
        lightningCrouchPosture: 'Crouch low on balls of feet, heels touching, head tucked between knees. DO NOT lie flat on the ground.',
        metalImplementProhibition: 'Drop all iron sickles, hoes, axes, fishing rods, and umbrella with metal tips immediately.',
        indoorPuccaShelterGuidance: 'Seek enclosed pucca masonry building. Avoid plumbing, open verandas, and electrical cords.',
        cprResuscitationGuideline: 'VICTIMS RETAIN NO ELECTRIC CHARGE. Begin immediate Hands-Only CPR if pulse is absent and call 108/112.',
      ),
      vernacularBulletins: {
        'en': '[IMD/IITM Lightning Nowcast] EXTREME Threat. Gatlin-Goodman Lightning Jump detected! Severe downburst gusts expected.',
        'hi': '[आईएमडी/आईआईटीएम बिजली चेतावनी] अत्यंत गंभीर स्तर। बिजली कूद (Lightning Jump) दर्ज! तुरंत सुरक्षित पक्के भवन में जाएं।',
        'od': '[ଆଇଏମଡି/ଆଇଆଇଟିଏମ ବଜ୍ରପାତ ସତର୍କତା] ଅତ୍ୟନ୍ତ ବିପଦପୂର୍ଣ୍ଣ ସ୍ତର। ବିଜୁଳି ଲମ୍ଫ ସତର୍କତା! ଗଛ ମୂଳେ ଆଶ୍ରୟ ନିଅନ୍ତୁ ନାହିଁ।',
      },
      timestamp: DateTime.now().toUtc().toIso8601String(),
      isOfflineFallback: true,
    );
  }
}
