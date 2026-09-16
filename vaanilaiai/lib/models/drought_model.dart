class MeteorologicalDroughtIndicesModel {
  final double spi1;
  final double spi3;
  final double spi6;
  final double rainfallDepartureLpaPct;
  final int consecutiveDryDays;
  final String droughtStageVerdict;

  const MeteorologicalDroughtIndicesModel({
    required this.spi1,
    required this.spi3,
    required this.spi6,
    required this.rainfallDepartureLpaPct,
    required this.consecutiveDryDays,
    required this.droughtStageVerdict,
  });

  factory MeteorologicalDroughtIndicesModel.fromJson(Map<String, dynamic> json) {
    return MeteorologicalDroughtIndicesModel(
      spi1: (json['spi_1'] as num?)?.toDouble() ?? -1.5,
      spi3: (json['spi_3'] as num?)?.toDouble() ?? -1.8,
      spi6: (json['spi_6'] as num?)?.toDouble() ?? -1.6,
      rainfallDepartureLpaPct: (json['rainfall_departure_lpa_pct'] as num?)?.toDouble() ?? -45.0,
      consecutiveDryDays: (json['consecutive_dry_days'] as num?)?.toInt() ?? 20,
      droughtStageVerdict: json['drought_stage_verdict'] as String? ?? 'Severe Meteorological Drought',
    );
  }

  Map<String, dynamic> toJson() => {
        'spi_1': spi1,
        'spi_3': spi3,
        'spi_6': spi6,
        'rainfall_departure_lpa_pct': rainfallDepartureLpaPct,
        'consecutive_dry_days': consecutiveDryDays,
        'drought_stage_verdict': droughtStageVerdict,
      };
}

class SoilMoistureStressModel {
  final double rootZoneSoilMoisturePct;
  final double fieldCapacityPct;
  final double permanentWiltingPointPct;
  final double availableWaterCapacityMm;
  final double smdi;
  final double cropWaterStressIndex;
  final String stressLevel;

  const SoilMoistureStressModel({
    required this.rootZoneSoilMoisturePct,
    required this.fieldCapacityPct,
    required this.permanentWiltingPointPct,
    required this.availableWaterCapacityMm,
    required this.smdi,
    required this.cropWaterStressIndex,
    required this.stressLevel,
  });

  factory SoilMoistureStressModel.fromJson(Map<String, dynamic> json) {
    return SoilMoistureStressModel(
      rootZoneSoilMoisturePct: (json['root_zone_soil_moisture_pct'] as num?)?.toDouble() ?? 15.0,
      fieldCapacityPct: (json['field_capacity_pct'] as num?)?.toDouble() ?? 35.0,
      permanentWiltingPointPct: (json['permanent_wilting_point_pct'] as num?)?.toDouble() ?? 12.0,
      availableWaterCapacityMm: (json['available_water_capacity_mm'] as num?)?.toDouble() ?? 20.0,
      smdi: (json['smdi'] as num?)?.toDouble() ?? -2.5,
      cropWaterStressIndex: (json['crop_water_stress_index'] as num?)?.toDouble() ?? 0.8,
      stressLevel: json['stress_level'] as String? ?? 'Severe Root-Zone Desiccation',
    );
  }

  Map<String, dynamic> toJson() => {
        'root_zone_soil_moisture_pct': rootZoneSoilMoisturePct,
        'field_capacity_pct': fieldCapacityPct,
        'permanent_wilting_point_pct': permanentWiltingPointPct,
        'available_water_capacity_mm': availableWaterCapacityMm,
        'smdi': smdi,
        'crop_water_stress_index': cropWaterStressIndex,
        'stress_level': stressLevel,
      };
}

class GroundwaterAquiferStatusModel {
  final double depthToWaterTableMBgl;
  final double stageOfExtractionPct;
  final String aquiferCategory;
  final double annualRechargePotentialMcm;
  final String borewellYieldTrend;
  final String irrigationRationingStatus;

  const GroundwaterAquiferStatusModel({
    required this.depthToWaterTableMBgl,
    required this.stageOfExtractionPct,
    required this.aquiferCategory,
    required this.annualRechargePotentialMcm,
    required this.borewellYieldTrend,
    required this.irrigationRationingStatus,
  });

  factory GroundwaterAquiferStatusModel.fromJson(Map<String, dynamic> json) {
    return GroundwaterAquiferStatusModel(
      depthToWaterTableMBgl: (json['depth_to_water_table_m_bgl'] as num?)?.toDouble() ?? 25.0,
      stageOfExtractionPct: (json['stage_of_extraction_pct'] as num?)?.toDouble() ?? 105.0,
      aquiferCategory: json['aquifer_category'] as String? ?? 'OVER_EXPLOITED',
      annualRechargePotentialMcm: (json['annual_recharge_potential_mcm'] as num?)?.toDouble() ?? 150.0,
      borewellYieldTrend: json['borewell_yield_trend'] as String? ?? 'DECLINING',
      irrigationRationingStatus: json['irrigation_rationing_status'] as String? ?? 'Restrict borewell extraction.',
    );
  }

  Map<String, dynamic> toJson() => {
        'depth_to_water_table_m_bgl': depthToWaterTableMBgl,
        'stage_of_extraction_pct': stageOfExtractionPct,
        'aquifer_category': aquiferCategory,
        'annual_recharge_potential_mcm': annualRechargePotentialMcm,
        'borewell_yield_trend': borewellYieldTrend,
        'irrigation_rationing_status': irrigationRationingStatus,
      };
}

class AgronomicDroughtDirectivesModel {
  final String cropStageAdvisory;
  final String irrigationScheduling;
  final String moistureConservation;
  final String contingencyCropSwitch;
  final String livestockFodderAdvisory;

  const AgronomicDroughtDirectivesModel({
    required this.cropStageAdvisory,
    required this.irrigationScheduling,
    required this.moistureConservation,
    required this.contingencyCropSwitch,
    required this.livestockFodderAdvisory,
  });

  factory AgronomicDroughtDirectivesModel.fromJson(Map<String, dynamic> json) {
    return AgronomicDroughtDirectivesModel(
      cropStageAdvisory: json['crop_stage_advisory'] as String? ?? 'Protect crops at critical stages.',
      irrigationScheduling: json['irrigation_scheduling'] as String? ?? 'Use micro-irrigation systems.',
      moistureConservation: json['moisture_conservation'] as String? ?? 'Apply straw mulching.',
      contingencyCropSwitch: json['contingency_crop_switch'] as String? ?? 'Switch to drought-hardy crops if needed.',
      livestockFodderAdvisory: json['livestock_fodder_advisory'] as String? ?? 'Ensure silage and fodder storage.',
    );
  }

  Map<String, dynamic> toJson() => {
        'crop_stage_advisory': cropStageAdvisory,
        'irrigation_scheduling': irrigationScheduling,
        'moisture_conservation': moistureConservation,
        'contingency_crop_switch': contingencyCropSwitch,
        'livestock_fodder_advisory': livestockFodderAdvisory,
      };
}

class DroughtHotspotModel {
  final String hotspotId;
  final String districtName;
  final String state;
  final double latitude;
  final double longitude;
  final String agroClimaticSubzone;
  final List<String> primaryCrops;
  final String severity;
  final MeteorologicalDroughtIndicesModel meteorological;
  final SoilMoistureStressModel soilMoisture;
  final GroundwaterAquiferStatusModel groundwater;
  final AgronomicDroughtDirectivesModel agronomicDirectives;

  const DroughtHotspotModel({
    required this.hotspotId,
    required this.districtName,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.agroClimaticSubzone,
    required this.primaryCrops,
    required this.severity,
    required this.meteorological,
    required this.soilMoisture,
    required this.groundwater,
    required this.agronomicDirectives,
  });

  factory DroughtHotspotModel.fromJson(Map<String, dynamic> json) {
    return DroughtHotspotModel(
      hotspotId: json['hotspot_id'] as String? ?? 'marathwada_latur',
      districtName: json['district_name'] as String? ?? 'Latur & Marathwada Rain-Shadow Zone',
      state: json['state'] as String? ?? 'Maharashtra',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 18.4088,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 76.5604,
      agroClimaticSubzone: json['agro_climatic_subzone'] as String? ?? 'Central Maharashtra Plateau Zone',
      primaryCrops: (json['primary_crops'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          ['Soybean', 'Pigeonpea', 'Sorghum'],
      severity: json['severity'] as String? ?? 'WARNING_SEVERE_DROUGHT',
      meteorological: MeteorologicalDroughtIndicesModel.fromJson(json['meteorological'] as Map<String, dynamic>? ?? {}),
      soilMoisture: SoilMoistureStressModel.fromJson(json['soil_moisture'] as Map<String, dynamic>? ?? {}),
      groundwater: GroundwaterAquiferStatusModel.fromJson(json['groundwater'] as Map<String, dynamic>? ?? {}),
      agronomicDirectives:
          AgronomicDroughtDirectivesModel.fromJson(json['agronomic_directives'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'hotspot_id': hotspotId,
        'district_name': districtName,
        'state': state,
        'latitude': latitude,
        'longitude': longitude,
        'agro_climatic_subzone': agroClimaticSubzone,
        'primary_crops': primaryCrops,
        'severity': severity,
        'meteorological': meteorological.toJson(),
        'soil_moisture': soilMoisture.toJson(),
        'groundwater': groundwater.toJson(),
        'agronomic_directives': agronomicDirectives.toJson(),
      };
}

class AgriculturalDroughtResponseModel {
  final String timestamp;
  final DroughtHotspotModel selectedHotspot;
  final List<DroughtHotspotModel> allHotspots;
  final Map<String, String> vernacularBulletins;
  final String bulletinNumber;
  final String provenance;
  final bool isOfflineCached;

  const AgriculturalDroughtResponseModel({
    required this.timestamp,
    required this.selectedHotspot,
    required this.allHotspots,
    required this.vernacularBulletins,
    required this.bulletinNumber,
    required this.provenance,
    this.isOfflineCached = false,
  });

  factory AgriculturalDroughtResponseModel.fromJson(Map<String, dynamic> json, {bool isOfflineCached = false}) {
    final rawHotspots = json['all_hotspots'] as List<dynamic>? ?? [];
    final hotspots = rawHotspots.map((e) => DroughtHotspotModel.fromJson(e as Map<String, dynamic>)).toList();

    final rawBulletins = json['vernacular_bulletins'] as Map<String, dynamic>? ?? {};
    final bulletins = rawBulletins.map((k, v) => MapEntry(k, v.toString()));

    return AgriculturalDroughtResponseModel(
      timestamp: json['timestamp'] as String? ?? DateTime.now().toUtc().toIso8601String(),
      selectedHotspot: DroughtHotspotModel.fromJson(json['selected_hotspot'] as Map<String, dynamic>? ?? {}),
      allHotspots: hotspots,
      vernacularBulletins: bulletins,
      bulletinNumber: json['bulletin_number'] as String? ?? 'IMD-CGWB/DROUGHT/2026-DEFAULT',
      provenance: json['provenance'] as String? ??
          'India Meteorological Department (Agricultural Meteorology Division), Central Ground Water Board (CGWB) & ICAR-CRIDA',
      isOfflineCached: isOfflineCached || (json['is_offline_cached'] as bool? ?? false),
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'selected_hotspot': selectedHotspot.toJson(),
        'all_hotspots': allHotspots.map((e) => e.toJson()).toList(),
        'vernacular_bulletins': vernacularBulletins,
        'bulletin_number': bulletinNumber,
        'provenance': provenance,
        'is_offline_cached': isOfflineCached,
      };

  static AgriculturalDroughtResponseModel defaultFallback() {
    const latur = DroughtHotspotModel(
      hotspotId: 'marathwada_latur',
      districtName: 'Latur & Marathwada Rain-Shadow Zone',
      state: 'Maharashtra',
      latitude: 18.4088,
      longitude: 76.5604,
      agroClimaticSubzone: 'Central Maharashtra Plateau Zone (Zone 8)',
      primaryCrops: ['Soybean', 'Pigeonpea (Tur)', 'Sorghum', 'Cotton'],
      severity: 'WARNING_SEVERE_DROUGHT',
      meteorological: MeteorologicalDroughtIndicesModel(
        spi1: -1.45,
        spi3: -1.82,
        spi6: -1.68,
        rainfallDepartureLpaPct: -48.0,
        consecutiveDryDays: 24,
        droughtStageVerdict: 'Severe Meteorological Drought (Orange Category)',
      ),
      soilMoisture: SoilMoistureStressModel(
        rootZoneSoilMoisturePct: 14.5,
        fieldCapacityPct: 34.0,
        permanentWiltingPointPct: 12.0,
        availableWaterCapacityMm: 18.2,
        smdi: -2.85,
        cropWaterStressIndex: 0.82,
        stressLevel: 'Severe Root-Zone Desiccation — Wilting Imminent',
      ),
      groundwater: GroundwaterAquiferStatusModel(
        depthToWaterTableMBgl: 24.8,
        stageOfExtractionPct: 108.5,
        aquiferCategory: 'OVER_EXPLOITED',
        annualRechargePotentialMcm: 142.5,
        borewellYieldTrend: 'DECLINING',
        irrigationRationingStatus:
            'Over-Exploited Aquifer: Restrict borewell pumping to critical life-saving intervals only.',
      ),
      agronomicDirectives: AgronomicDroughtDirectivesModel(
        cropStageAdvisory:
            'Soybean is at flowering to early pod fill; pigeonpea is at branching. High risk of flower drop under severe moisture stress.',
        irrigationScheduling:
            'Apply protective life-saving irrigation (5 cm depth) via micro-sprinkler or alternate-furrow irrigation. Avoid flood irrigation.',
        moistureConservation:
            'Spray 1% Potassium Nitrate (KNO3) foliar spray to alleviate thermal stress. Spread crop residue mulch across rows.',
        contingencyCropSwitch:
            'If main crop fails, prepare field for contingency horse gram (Kulthi), moth bean, or fodder pearl millet.',
        livestockFodderAdvisory:
            'Store green fodder silage; procure dry sorghum stover. Provide shaded cattle corrals with cool drinking water.',
      ),
    );

    const anantapur = DroughtHotspotModel(
      hotspotId: 'rayalaseema_anantapur',
      districtName: 'Anantapuramu & Rayalaseema Arid Belt',
      state: 'Andhra Pradesh',
      latitude: 14.6819,
      longitude: 77.6006,
      agroClimaticSubzone: 'Southern Semi-Arid Scarce Rainfall Zone (Zone 10)',
      primaryCrops: ['Groundnut (Peanut)', 'Castor', 'Pigeonpea', 'Foxtail Millet'],
      severity: 'EMERGENCY_EXTREME_DROUGHT',
      meteorological: MeteorologicalDroughtIndicesModel(
        spi1: -2.10,
        spi3: -2.15,
        spi6: -2.30,
        rainfallDepartureLpaPct: -58.0,
        consecutiveDryDays: 31,
        droughtStageVerdict: 'Extreme Meteorological Drought (Red Alert Emergency)',
      ),
      soilMoisture: SoilMoistureStressModel(
        rootZoneSoilMoisturePct: 10.2,
        fieldCapacityPct: 24.0,
        permanentWiltingPointPct: 11.0,
        availableWaterCapacityMm: 8.5,
        smdi: -3.60,
        cropWaterStressIndex: 0.91,
        stressLevel: 'Critical Soil Moisture Depletion — Below Permanent Wilting Point',
      ),
      groundwater: GroundwaterAquiferStatusModel(
        depthToWaterTableMBgl: 38.5,
        stageOfExtractionPct: 124.0,
        aquiferCategory: 'OVER_EXPLOITED',
        annualRechargePotentialMcm: 115.0,
        borewellYieldTrend: 'DEPLETED',
        irrigationRationingStatus:
            'Severe Groundwater Depletion: More than 60% of agricultural borewells running dry. Ban non-essential extraction.',
      ),
      agronomicDirectives: AgronomicDroughtDirectivesModel(
        cropStageAdvisory:
            'Groundnut is at peg penetration and pod development. Soil hardening is halting peg penetration, risking complete pod yield loss.',
        irrigationScheduling:
            'Operate mobile rain-gun or drip systems during night or early morning hours. Minimum 20 mm moisture needed for peg entry.',
        moistureConservation:
            'Foliar spray with 5% Kaolin clay reflective anti-transpirant. Apply coir pith or crop residue mulch to preserve scarce moisture.',
        contingencyCropSwitch:
            'Transition entirely to drought-hardy millets (Korralu / Foxtail millet) or fodder cowpea for surviving livestock.',
        livestockFodderAdvisory:
            'Coordinate with district fodder banks. Administer mineral blocks to prevent livestock dehydration and cachexia.',
      ),
    );

    return const AgriculturalDroughtResponseModel(
      timestamp: '2026-09-12T06:00:00Z',
      selectedHotspot: latur,
      allHotspots: [latur, anantapur],
      vernacularBulletins: {
        'en':
            'IMD & CGWB AGRICULTURAL DROUGHT ADVISORY: Latur & Marathwada is under WARNING SEVERE DROUGHT. 3-Month SPI is -1.82. Root zone soil moisture is at 14.5% with CWSI 0.82. Groundwater Extraction Stage: 108.5% (OVER_EXPLOITED). Apply protective life-saving irrigation via micro-sprinkler.',
        'hi':
            'आईएमडी एवं सीजीडब्ल्यूबी सूखा व भूजल परामर्श: लातूर व मराठवाड़ा में गंभीर सूखा चेतावनी। 3-माह एसपीआई -1.82 (वर्षा कमी: -48%)। जड़ क्षेत्र में नमी 14.5% बची है। भूजल दोहन स्तर 108.5% (अति-शोषित)। सूक्ष्म फव्वारा सिंचाई से जीवनरक्षक पानी दें।',
        'mr':
            'आयएमडी आणि सीजीडब्ल्यूबी दुष्काळ व भूजल सल्ला: लातूर आणि मराठवाड्यात तीव्र दुष्काळ इशारा. ३-महिन्यांचा एसपीआई -1.82 (पावसाची तूट: -48%). मुळांच्या थरातील ओलावा 14.5% वर घसरला आहे. भूजल उपसा प्रमाण 108.5% (अति-शोषित). तुषार किंवा ठिबक सिंचनाने संरक्षित पाणी द्या.',
        'te':
            'ఐఎండి మరియు సిజిడబ్ల్యుబి వ్యవసాయ కరువు సలహా: లాతూర్ మరియు మరాఠ్వాడా ప్రాంతంలో తీవ్ర కరువు హెచ్చరిక. 3-నెలల ఎస్పీఐ -1.82. నేల తేమ 14.5% కి తగ్గింది. భూగర్భ జలాల వినియోగం 108.5%. బిందు లేదా తుంపర సేద్యం ద్వారా రక్షక తడులు ఇవ్వండి.',
        'kn':
            'ಐಎಂಡಿ ಮತ್ತು ಸಿಜಿಡಬ್ಲ್ಯುಬಿ ಕೃಷಿ ಬರ ಮತ್ತು ಅಂತರ್ಜಲ ಎಚ್ಚರಿಕೆ: ಲಾತೂರ್ ಮತ್ತು ಮರಾಠವಾಡ ವ್ಯಾಪ್ತಿಯಲ್ಲಿ ತೀವ್ರ ಬರ ಎಚ್ಚರಿಕೆ. ೩-ತಿಂಗಳ ಎಸ್‍ಪಿಐ -1.82. ಮಣ್ಣಿನ ತೇವಾಂಶ ಮಟ್ಟ 14.5% ಕ್ಕೆ ಕುಸಿದಿದೆ. ಅಂತರ್ಜಲ ಬಳಕೆ 108.5%. ಹನಿ ಅಥವಾ ತುಂತುರು ನೀರಾವರಿ ಮೂಲಕ ರಕ್ಷಕ ನೀರು ಒದಗಿಸಿ.',
      },
      bulletinNumber: 'IMD-CGWB/DROUGHT/202609-ASLAT',
      provenance:
          'India Meteorological Department (Agricultural Meteorology Division), Central Ground Water Board (CGWB) & ICAR-CRIDA',
      isOfflineCached: true,
    );
  }
}
