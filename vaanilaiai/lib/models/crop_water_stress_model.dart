class SoilMoistureProfileModel {
  final double topsoil10cmPct;
  final double rootZone40cmPct;
  final double subsoil100cmPct;
  final double fieldCapacityPct;
  final double wiltingPointPct;
  final double relativeAvailableSoilMoisturePct;

  const SoilMoistureProfileModel({
    required this.topsoil10cmPct,
    required this.rootZone40cmPct,
    required this.subsoil100cmPct,
    required this.fieldCapacityPct,
    required this.wiltingPointPct,
    required this.relativeAvailableSoilMoisturePct,
  });

  factory SoilMoistureProfileModel.fromJson(Map<String, dynamic> json) {
    return SoilMoistureProfileModel(
      topsoil10cmPct: (json['topsoil_10cm_pct'] as num?)?.toDouble() ?? 15.0,
      rootZone40cmPct: (json['root_zone_40cm_pct'] as num?)?.toDouble() ?? 20.0,
      subsoil100cmPct: (json['subsoil_100cm_pct'] as num?)?.toDouble() ?? 25.0,
      fieldCapacityPct: (json['field_capacity_pct'] as num?)?.toDouble() ?? 35.0,
      wiltingPointPct: (json['wilting_point_pct'] as num?)?.toDouble() ?? 15.0,
      relativeAvailableSoilMoisturePct: (json['relative_available_soil_moisture_pct'] as num?)?.toDouble() ?? 30.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'topsoil_10cm_pct': topsoil10cmPct,
        'root_zone_40cm_pct': rootZone40cmPct,
        'subsoil_100cm_pct': subsoil100cmPct,
        'field_capacity_pct': fieldCapacityPct,
        'wilting_point_pct': wiltingPointPct,
        'relative_available_soil_moisture_pct': relativeAvailableSoilMoisturePct,
      };
}

class EvapotranspirationMetricsModel {
  final double referenceEt0MmDay;
  final double cropCoefficientKc;
  final double actualEtcMmDay;
  final double canopyTemperatureC;
  final double ambientAirTemperatureC;
  final double canopyAirTempDepartureC;
  final double cropWaterStressIndexCwsi;

  const EvapotranspirationMetricsModel({
    required this.referenceEt0MmDay,
    required this.cropCoefficientKc,
    required this.actualEtcMmDay,
    required this.canopyTemperatureC,
    required this.ambientAirTemperatureC,
    required this.canopyAirTempDepartureC,
    required this.cropWaterStressIndexCwsi,
  });

  factory EvapotranspirationMetricsModel.fromJson(Map<String, dynamic> json) {
    return EvapotranspirationMetricsModel(
      referenceEt0MmDay: (json['reference_et0_mm_day'] as num?)?.toDouble() ?? 5.0,
      cropCoefficientKc: (json['crop_coefficient_kc'] as num?)?.toDouble() ?? 1.1,
      actualEtcMmDay: (json['actual_etc_mm_day'] as num?)?.toDouble() ?? 4.5,
      canopyTemperatureC: (json['canopy_temperature_c'] as num?)?.toDouble() ?? 32.0,
      ambientAirTemperatureC: (json['ambient_air_temperature_c'] as num?)?.toDouble() ?? 30.0,
      canopyAirTempDepartureC: (json['canopy_air_temp_departure_c'] as num?)?.toDouble() ?? 2.0,
      cropWaterStressIndexCwsi: (json['crop_water_stress_index_cwsi'] as num?)?.toDouble() ?? 0.5,
    );
  }

  Map<String, dynamic> toJson() => {
        'reference_et0_mm_day': referenceEt0MmDay,
        'crop_coefficient_kc': cropCoefficientKc,
        'actual_etc_mm_day': actualEtcMmDay,
        'canopy_temperature_c': canopyTemperatureC,
        'ambient_air_temperature_c': ambientAirTemperatureC,
        'canopy_air_temp_departure_c': canopyAirTempDepartureC,
        'crop_water_stress_index_cwsi': cropWaterStressIndexCwsi,
      };
}

class PrecisionIrrigationDirectiveModel {
  final double recommendedIrrigationDepthMm;
  final double dripRunTimeHours;
  final String criticalGrowthStage;
  final String antiTranspirantSpray;
  final String mulchRecommendation;
  final String intercultivationTillage;

  const PrecisionIrrigationDirectiveModel({
    required this.recommendedIrrigationDepthMm,
    required this.dripRunTimeHours,
    required this.criticalGrowthStage,
    required this.antiTranspirantSpray,
    required this.mulchRecommendation,
    required this.intercultivationTillage,
  });

  factory PrecisionIrrigationDirectiveModel.fromJson(Map<String, dynamic> json) {
    return PrecisionIrrigationDirectiveModel(
      recommendedIrrigationDepthMm: (json['recommended_irrigation_depth_mm'] as num?)?.toDouble() ?? 30.0,
      dripRunTimeHours: (json['drip_run_time_hours'] as num?)?.toDouble() ?? 3.0,
      criticalGrowthStage: json['critical_growth_stage'] as String? ?? 'Flowering / Pod Formation',
      antiTranspirantSpray: json['anti_transpirant_spray'] as String? ?? 'Foliar spray of 1% KNO3',
      mulchRecommendation: json['mulch_recommendation'] as String? ?? 'Straw mulch on soil surface',
      intercultivationTillage: json['intercultivation_tillage'] as String? ?? 'Shallow hoeing between rows',
    );
  }

  Map<String, dynamic> toJson() => {
        'recommended_irrigation_depth_mm': recommendedIrrigationDepthMm,
        'drip_run_time_hours': dripRunTimeHours,
        'critical_growth_stage': criticalGrowthStage,
        'anti_transpirant_spray': antiTranspirantSpray,
        'mulch_recommendation': mulchRecommendation,
        'intercultivation_tillage': intercultivationTillage,
      };
}

class AgroClimaticZoneModel {
  final String zoneId;
  final String zoneName;
  final String state;
  final String district;
  final String primaryCrop;
  final String growthStage;
  final double latitude;
  final double longitude;
  final String soilTexture;
  final String stressTier;
  final SoilMoistureProfileModel soilMoisture;
  final EvapotranspirationMetricsModel evapotranspiration;
  final PrecisionIrrigationDirectiveModel irrigationDirectives;
  final Map<String, String> localizedBulletins;

  const AgroClimaticZoneModel({
    required this.zoneId,
    required this.zoneName,
    required this.state,
    required this.district,
    required this.primaryCrop,
    required this.growthStage,
    required this.latitude,
    required this.longitude,
    required this.soilTexture,
    required this.stressTier,
    required this.soilMoisture,
    required this.evapotranspiration,
    required this.irrigationDirectives,
    required this.localizedBulletins,
  });

  factory AgroClimaticZoneModel.fromJson(Map<String, dynamic> json) {
    return AgroClimaticZoneModel(
      zoneId: json['zone_id'] as String? ?? 'vidarbha_cotton_vertisol',
      zoneName: json['zone_name'] as String? ?? 'Vidarbha Rainfed Cotton-Soybean Vertisol Belt',
      state: json['state'] as String? ?? 'Maharashtra',
      district: json['district'] as String? ?? 'Yavatmal / Nagpur',
      primaryCrop: json['primary_crop'] as String? ?? 'Bt Cotton',
      growthStage: json['growth_stage'] as String? ?? 'Boll Formation',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 20.3888,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 78.1204,
      soilTexture: json['soil_texture'] as String? ?? 'BLACK_COTTON_VERTISOL',
      stressTier: json['stress_tier'] as String? ?? 'MODERATE_DEFICIT',
      soilMoisture: SoilMoistureProfileModel.fromJson(
        json['soil_moisture'] as Map<String, dynamic>? ?? {},
      ),
      evapotranspiration: EvapotranspirationMetricsModel.fromJson(
        json['evapotranspiration'] as Map<String, dynamic>? ?? {},
      ),
      irrigationDirectives: PrecisionIrrigationDirectiveModel.fromJson(
        json['irrigation_directives'] as Map<String, dynamic>? ?? {},
      ),
      localizedBulletins: (json['localized_bulletins'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          const {},
    );
  }

  Map<String, dynamic> toJson() => {
        'zone_id': zoneId,
        'zone_name': zoneName,
        'state': state,
        'district': district,
        'primary_crop': primaryCrop,
        'growth_stage': growthStage,
        'latitude': latitude,
        'longitude': longitude,
        'soil_texture': soilTexture,
        'stress_tier': stressTier,
        'soil_moisture': soilMoisture.toJson(),
        'evapotranspiration': evapotranspiration.toJson(),
        'irrigation_directives': irrigationDirectives.toJson(),
        'localized_bulletins': localizedBulletins,
      };
}

class CropWaterStressResponseModel {
  final String timestamp;
  final String bulletinNumber;
  final String provenance;
  final AgroClimaticZoneModel selectedZone;
  final List<AgroClimaticZoneModel> allZones;
  final Map<String, String> vernacularBulletins;
  final bool isOfflineCached;

  const CropWaterStressResponseModel({
    required this.timestamp,
    required this.bulletinNumber,
    required this.provenance,
    required this.selectedZone,
    required this.allZones,
    required this.vernacularBulletins,
    this.isOfflineCached = false,
  });

  factory CropWaterStressResponseModel.fromJson(
    Map<String, dynamic> json, {
    bool isOfflineCached = false,
  }) {
    return CropWaterStressResponseModel(
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      bulletinNumber: json['bulletin_number'] as String? ?? 'ICAR-IMD/CWSI/202609-VIDARB',
      provenance: json['provenance'] as String? ??
          'ICAR-CRIDA & IMD Division of Agricultural Meteorology Crop Water Stress Monitoring System',
      selectedZone: AgroClimaticZoneModel.fromJson(
        json['selected_zone'] as Map<String, dynamic>? ?? {},
      ),
      allZones: (json['all_zones'] as List<dynamic>?)
              ?.map((e) => AgroClimaticZoneModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      vernacularBulletins: (json['vernacular_bulletins'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          const {},
      isOfflineCached: isOfflineCached || (json['is_offline_cached'] as bool? ?? false),
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'bulletin_number': bulletinNumber,
        'provenance': provenance,
        'selected_zone': selectedZone.toJson(),
        'all_zones': allZones.map((e) => e.toJson()).toList(),
        'vernacular_bulletins': vernacularBulletins,
        'is_offline_cached': isOfflineCached,
      };

  CropWaterStressResponseModel copyWithOfflineCached(bool cached) {
    return CropWaterStressResponseModel(
      timestamp: timestamp,
      bulletinNumber: bulletinNumber,
      provenance: provenance,
      selectedZone: selectedZone,
      allZones: allZones,
      vernacularBulletins: vernacularBulletins,
      isOfflineCached: cached,
    );
  }

  static CropWaterStressResponseModel defaultFallback() {
    final vidarbhaZone = AgroClimaticZoneModel(
      zoneId: 'vidarbha_cotton_vertisol',
      zoneName: 'Vidarbha Rainfed Cotton-Soybean Vertisol Belt',
      state: 'Maharashtra',
      district: 'Yavatmal / Nagpur',
      primaryCrop: 'Bt Cotton (Gossypium hirsutum)',
      growthStage: 'Square & Early Boll Formation',
      latitude: 20.3888,
      longitude: 78.1204,
      soilTexture: 'BLACK_COTTON_VERTISOL',
      stressTier: 'MODERATE_DEFICIT',
      soilMoisture: const SoilMoistureProfileModel(
        topsoil10cmPct: 14.5,
        rootZone40cmPct: 19.8,
        subsoil100cmPct: 26.2,
        fieldCapacityPct: 38.0,
        wiltingPointPct: 18.0,
        relativeAvailableSoilMoisturePct: 22.5,
      ),
      evapotranspiration: const EvapotranspirationMetricsModel(
        referenceEt0MmDay: 5.8,
        cropCoefficientKc: 1.15,
        actualEtcMmDay: 4.6,
        canopyTemperatureC: 34.2,
        ambientAirTemperatureC: 31.8,
        canopyAirTempDepartureC: 2.4,
        cropWaterStressIndexCwsi: 0.68,
      ),
      irrigationDirectives: const PrecisionIrrigationDirectiveModel(
        recommendedIrrigationDepthMm: 35.0,
        dripRunTimeHours: 3.5,
        criticalGrowthStage: 'Boll setting (moisture deficit causes squaring drop & flower shedding)',
        antiTranspirantSpray: 'Foliar spray of 1% Potassium Nitrate (KNO3) or 2% DAP to sustain turgor',
        mulchRecommendation: 'Spreading of cotton stalks or soybean straw mulch at 5 tonnes/ha',
        intercultivationTillage: 'Shallow hoeing (Kolpa) between rows to break soil surface capillaries',
      ),
      localizedBulletins: const {
        'en': 'MODERATE CROP WATER STRESS: Bt Cotton in Vidarbha experiencing critical moisture deficit during boll formation (CWSI 0.68, canopy heated +2.4°C above air). Immediate supplemental drip irrigation of 35mm recommended. Apply 1% KNO3 foliar spray.',
        'hi': 'मध्यम फसल जल तनाव: विदर्भ में कपास की फसल में गूलर बनने की अवस्था में नमी की भारी कमी (CWSI 0.68)। फूल और गूलर गिरने से रोकने के लिए 35 मिमी ड्रिप सिंचाई दें और 1% पोटैशियम नाइट्रेट का छिड़काव करें।',
        'mr': 'मध्यम पीक जल ताण: विदर्भातील कापूस पिकात बोंडे भरण्याच्या नाजूक टप्प्यावर जमिनीतील ओलावा घटला आहे (CWSI 0.68). पाते व बोंड गळ रोखण्यासाठी तात्काळ 35 मिमी ठिबक सिंचन द्यावे व 1% पोटॅशियम नायट्रेटची फवारणी करावी.',
      },
    );

    final punjabZone = AgroClimaticZoneModel(
      zoneId: 'punjab_wheat_rice_alluvium',
      zoneName: 'Punjab Central Alluvial Cropping Plain',
      state: 'Punjab',
      district: 'Ludhiana / Bathinda',
      primaryCrop: 'Wheat (Triticum aestivum)',
      growthStage: 'Crown Root Initiation (CRI) & Tillering',
      latitude: 30.9010,
      longitude: 75.8573,
      soilTexture: 'INDO_GANGETIC_ALLUVIAL',
      stressTier: 'OPTIMAL_TURGOR',
      soilMoisture: const SoilMoistureProfileModel(
        topsoil10cmPct: 28.2,
        rootZone40cmPct: 29.5,
        subsoil100cmPct: 30.8,
        fieldCapacityPct: 32.0,
        wiltingPointPct: 12.0,
        relativeAvailableSoilMoisturePct: 81.0,
      ),
      evapotranspiration: const EvapotranspirationMetricsModel(
        referenceEt0MmDay: 3.2,
        cropCoefficientKc: 0.85,
        actualEtcMmDay: 2.7,
        canopyTemperatureC: 18.2,
        ambientAirTemperatureC: 20.0,
        canopyAirTempDepartureC: -1.8,
        cropWaterStressIndexCwsi: 0.18,
      ),
      irrigationDirectives: const PrecisionIrrigationDirectiveModel(
        recommendedIrrigationDepthMm: 0.0,
        dripRunTimeHours: 0.0,
        criticalGrowthStage: 'Crown Root Initiation (Adequately hydrated)',
        antiTranspirantSpray: 'Not required under optimal moisture regime',
        mulchRecommendation: 'Happy Seeder in-situ paddy straw residue active on soil surface',
        intercultivationTillage: 'Avoid tillage to preserve root anchorage',
      ),
      localizedBulletins: const {
        'en': 'OPTIMAL TURGOR: Punjab wheat canopy well-hydrated with high transpirational cooling (CWSI 0.18, canopy cooler by -1.8°C). Soil moisture at 81% RASM. No supplemental irrigation needed for the next 6 days.',
        'pa': 'ਅਨੁਕੂਲ ਨਮੀ: ਪੰਜਾਬ ਵਿੱਚ ਕਣਕ ਦੀ ਫਸਲ ਵਿੱਚ ਨਮੀ ਦੀ ਸਥਿਤੀ ਬਹੁਤ ਵਧੀਆ ਹੈ (CWSI 0.18)। ਜ਼ਮੀਨ ਵਿੱਚ 81% ਪਾਣੀ ਮੌਜੂਦ ਹੈ। ਅਗਲੇ 6 ਦਿਨਾਂ ਤੱਕ ਸਿੰਚਾਈ ਦੀ ਕੋਈ ਲੋੜ ਨਹੀਂ ਹੈ।',
      },
    );

    return CropWaterStressResponseModel(
      timestamp: DateTime.now().toIso8601String(),
      bulletinNumber: 'ICAR-IMD/CWSI/202609-VIDARB',
      provenance: 'ICAR-CRIDA & IMD Division of Agricultural Meteorology Crop Water Stress Monitoring System',
      selectedZone: vidarbhaZone,
      allZones: [vidarbhaZone, punjabZone],
      vernacularBulletins: vidarbhaZone.localizedBulletins,
      isOfflineCached: true,
    );
  }
}
