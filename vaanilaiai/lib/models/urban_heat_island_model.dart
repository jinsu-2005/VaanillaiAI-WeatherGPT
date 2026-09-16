class SurfaceThermalTelemetryModel {
  final double lstUrbanCelsius;
  final double lstRuralBaselineCelsius;
  final double uhiThermalAnomalyDeltaC;
  final double canopyAirTempCelsius;
  final double tropicalNightMinTempCelsius;
  final bool tropicalNightFlag;
  final bool severeTropicalNightFlag;

  const SurfaceThermalTelemetryModel({
    required this.lstUrbanCelsius,
    required this.lstRuralBaselineCelsius,
    required this.uhiThermalAnomalyDeltaC,
    required this.canopyAirTempCelsius,
    required this.tropicalNightMinTempCelsius,
    required this.tropicalNightFlag,
    required this.severeTropicalNightFlag,
  });

  factory SurfaceThermalTelemetryModel.fromJson(Map<String, dynamic> json) {
    return SurfaceThermalTelemetryModel(
      lstUrbanCelsius: (json['lst_urban_celsius'] as num?)?.toDouble() ?? 48.5,
      lstRuralBaselineCelsius: (json['lst_rural_baseline_celsius'] as num?)?.toDouble() ?? 41.7,
      uhiThermalAnomalyDeltaC: (json['uhi_thermal_anomaly_delta_c'] as num?)?.toDouble() ?? 6.8,
      canopyAirTempCelsius: (json['canopy_air_temp_celsius'] as num?)?.toDouble() ?? 43.2,
      tropicalNightMinTempCelsius: (json['tropical_night_min_temp_celsius'] as num?)?.toDouble() ?? 29.8,
      tropicalNightFlag: json['tropical_night_flag'] as bool? ?? true,
      severeTropicalNightFlag: json['severe_tropical_night_flag'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'lst_urban_celsius': lstUrbanCelsius,
        'lst_rural_baseline_celsius': lstRuralBaselineCelsius,
        'uhi_thermal_anomaly_delta_c': uhiThermalAnomalyDeltaC,
        'canopy_air_temp_celsius': canopyAirTempCelsius,
        'tropical_night_min_temp_celsius': tropicalNightMinTempCelsius,
        'tropical_night_flag': tropicalNightFlag,
        'severe_tropical_night_flag': severeTropicalNightFlag,
      };
}

class BiophysicalCanopyMetricsModel {
  final double imperviousSurfaceFractionPct;
  final double ndviUrbanCore;
  final double ndviRuralBaseline;
  final double vegetationCoolingDeficitDeltaC;
  final double skyViewFactorSvf;
  final double anthropogenicHeatFluxWM2;

  const BiophysicalCanopyMetricsModel({
    required this.imperviousSurfaceFractionPct,
    required this.ndviUrbanCore,
    required this.ndviRuralBaseline,
    required this.vegetationCoolingDeficitDeltaC,
    required this.skyViewFactorSvf,
    required this.anthropogenicHeatFluxWM2,
  });

  factory BiophysicalCanopyMetricsModel.fromJson(Map<String, dynamic> json) {
    return BiophysicalCanopyMetricsModel(
      imperviousSurfaceFractionPct:
          (json['impervious_surface_fraction_pct'] as num?)?.toDouble() ?? 88.5,
      ndviUrbanCore: (json['ndvi_urban_core'] as num?)?.toDouble() ?? 0.11,
      ndviRuralBaseline: (json['ndvi_rural_baseline'] as num?)?.toDouble() ?? 0.46,
      vegetationCoolingDeficitDeltaC:
          (json['vegetation_cooling_deficit_delta_c'] as num?)?.toDouble() ?? 2.6,
      skyViewFactorSvf: (json['sky_view_factor_svf'] as num?)?.toDouble() ?? 0.38,
      anthropogenicHeatFluxWM2:
          (json['anthropogenic_heat_flux_w_m2'] as num?)?.toDouble() ?? 96.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'impervious_surface_fraction_pct': imperviousSurfaceFractionPct,
        'ndvi_urban_core': ndviUrbanCore,
        'ndvi_rural_baseline': ndviRuralBaseline,
        'vegetation_cooling_deficit_delta_c': vegetationCoolingDeficitDeltaC,
        'sky_view_factor_svf': skyViewFactorSvf,
        'anthropogenic_heat_flux_w_m2': anthropogenicHeatFluxWM2,
      };
}

class CoolRoofSimulationModel {
  final String roofMaterial;
  final int solarReflectanceIndexSri;
  final double solarReflectanceAlpha;
  final double thermalEmittanceEpsilon;
  final double surfaceTemperatureCelsius;
  final double surfaceTempReductionDeltaC;
  final double indoorCoolingBenefitDeltaC;
  final double acEnergyLoadReductionPct;
  final bool ndmaCoolRoofCompliant;

  const CoolRoofSimulationModel({
    required this.roofMaterial,
    required this.solarReflectanceIndexSri,
    required this.solarReflectanceAlpha,
    required this.thermalEmittanceEpsilon,
    required this.surfaceTemperatureCelsius,
    required this.surfaceTempReductionDeltaC,
    required this.indoorCoolingBenefitDeltaC,
    required this.acEnergyLoadReductionPct,
    required this.ndmaCoolRoofCompliant,
  });

  factory CoolRoofSimulationModel.fromJson(Map<String, dynamic> json) {
    return CoolRoofSimulationModel(
      roofMaterial: json['roof_material'] as String? ?? 'HIGH_ALBEDO_ELASTOMERIC_WHITE',
      solarReflectanceIndexSri: json['solar_reflectance_index_sri'] as int? ?? 104,
      solarReflectanceAlpha: (json['solar_reflectance_alpha'] as num?)?.toDouble() ?? 0.85,
      thermalEmittanceEpsilon: (json['thermal_emittance_epsilon'] as num?)?.toDouble() ?? 0.90,
      surfaceTemperatureCelsius:
          (json['surface_temperature_celsius'] as num?)?.toDouble() ?? 36.5,
      surfaceTempReductionDeltaC:
          (json['surface_temp_reduction_delta_c'] as num?)?.toDouble() ?? 22.5,
      indoorCoolingBenefitDeltaC:
          (json['indoor_cooling_benefit_delta_c'] as num?)?.toDouble() ?? -3.5,
      acEnergyLoadReductionPct:
          (json['ac_energy_load_reduction_pct'] as num?)?.toDouble() ?? 24.5,
      ndmaCoolRoofCompliant: json['ndma_cool_roof_compliant'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'roof_material': roofMaterial,
        'solar_reflectance_index_sri': solarReflectanceIndexSri,
        'solar_reflectance_alpha': solarReflectanceAlpha,
        'thermal_emittance_epsilon': thermalEmittanceEpsilon,
        'surface_temperature_celsius': surfaceTemperatureCelsius,
        'surface_temp_reduction_delta_c': surfaceTempReductionDeltaC,
        'indoor_cooling_benefit_delta_c': indoorCoolingBenefitDeltaC,
        'ac_energy_load_reduction_pct': acEnergyLoadReductionPct,
        'ndma_cool_roof_compliant': ndmaCoolRoofCompliant,
      };
}

class MicroclimateHotspotModel {
  final String hotspotId;
  final String hotspotName;
  final String morphology;
  final double lstCelsius;
  final double thermalAnomalyDeltaC;
  final String vulnerabilityRank;
  final int coolingShelterDistanceM;

  const MicroclimateHotspotModel({
    required this.hotspotId,
    required this.hotspotName,
    required this.morphology,
    required this.lstCelsius,
    required this.thermalAnomalyDeltaC,
    required this.vulnerabilityRank,
    required this.coolingShelterDistanceM,
  });

  factory MicroclimateHotspotModel.fromJson(Map<String, dynamic> json) {
    return MicroclimateHotspotModel(
      hotspotId: json['hotspot_id'] as String? ?? 'hotspot',
      hotspotName: json['hotspot_name'] as String? ?? 'Urban Hotspot',
      morphology: json['morphology'] as String? ?? 'HIGH_DENSITY_CONCRETE_CORE',
      lstCelsius: (json['lst_celsius'] as num?)?.toDouble() ?? 49.0,
      thermalAnomalyDeltaC: (json['thermal_anomaly_delta_c'] as num?)?.toDouble() ?? 7.0,
      vulnerabilityRank: json['vulnerability_rank'] as String? ?? 'HIGH',
      coolingShelterDistanceM: json['cooling_shelter_distance_m'] as int? ?? 300,
    );
  }

  Map<String, dynamic> toJson() => {
        'hotspot_id': hotspotId,
        'hotspot_name': hotspotName,
        'morphology': morphology,
        'lst_celsius': lstCelsius,
        'thermal_anomaly_delta_c': thermalAnomalyDeltaC,
        'vulnerability_rank': vulnerabilityRank,
        'cooling_shelter_distance_m': coolingShelterDistanceM,
      };
}

class MunicipalUhiDirectivesModel {
  final String coolRoofPolicyStatus;
  final int coolRoofTargetSqMeters;
  final double urbanForestryCorridorKm;
  final int transitMistingStationsCount;
  final bool constructionHeatShiftEnforced;
  final int publicPyausDrinkingWaterPoints;
  final int emergencyCoolingSheltersActive;

  const MunicipalUhiDirectivesModel({
    required this.coolRoofPolicyStatus,
    required this.coolRoofTargetSqMeters,
    required this.urbanForestryCorridorKm,
    required this.transitMistingStationsCount,
    required this.constructionHeatShiftEnforced,
    required this.publicPyausDrinkingWaterPoints,
    required this.emergencyCoolingSheltersActive,
  });

  factory MunicipalUhiDirectivesModel.fromJson(Map<String, dynamic> json) {
    return MunicipalUhiDirectivesModel(
      coolRoofPolicyStatus:
          json['cool_roof_policy_status'] as String? ?? 'ACTIVE_MANDATORY_COMMERCIAL',
      coolRoofTargetSqMeters: json['cool_roof_target_sq_meters'] as int? ?? 1200000,
      urbanForestryCorridorKm:
          (json['urban_forestry_corridor_km'] as num?)?.toDouble() ?? 45.0,
      transitMistingStationsCount: json['transit_misting_stations_count'] as int? ?? 65,
      constructionHeatShiftEnforced:
          json['construction_heat_shift_enforced'] as bool? ?? true,
      publicPyausDrinkingWaterPoints:
          json['public_pyaus_drinking_water_points'] as int? ?? 820,
      emergencyCoolingSheltersActive:
          json['emergency_cooling_shelters_active'] as int? ?? 140,
    );
  }

  Map<String, dynamic> toJson() => {
        'cool_roof_policy_status': coolRoofPolicyStatus,
        'cool_roof_target_sq_meters': coolRoofTargetSqMeters,
        'urban_forestry_corridor_km': urbanForestryCorridorKm,
        'transit_misting_stations_count': transitMistingStationsCount,
        'construction_heat_shift_enforced': constructionHeatShiftEnforced,
        'public_pyaus_drinking_water_points': publicPyausDrinkingWaterPoints,
        'emergency_cooling_shelters_active': emergencyCoolingSheltersActive,
      };
}

class UrbanHeatIslandCorridorModel {
  final String corridorId;
  final String cityName;
  final String state;
  final double latitude;
  final double longitude;
  final String climateZone;
  final String dominantMorphology;
  final String threatLevel;
  final SurfaceThermalTelemetryModel surfaceTelemetry;
  final BiophysicalCanopyMetricsModel biophysicalMetrics;
  final CoolRoofSimulationModel coolRoofSimulation;
  final List<MicroclimateHotspotModel> hotspots;
  final MunicipalUhiDirectivesModel directives;
  final Map<String, String> vernacularBulletins;

  const UrbanHeatIslandCorridorModel({
    required this.corridorId,
    required this.cityName,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.climateZone,
    required this.dominantMorphology,
    required this.threatLevel,
    required this.surfaceTelemetry,
    required this.biophysicalMetrics,
    required this.coolRoofSimulation,
    required this.hotspots,
    required this.directives,
    required this.vernacularBulletins,
  });

  factory UrbanHeatIslandCorridorModel.fromJson(Map<String, dynamic> json) {
    return UrbanHeatIslandCorridorModel(
      corridorId: json['corridor_id'] as String? ?? 'delhi_ncr',
      cityName: json['city_name'] as String? ?? 'Delhi-NCR',
      state: json['state'] as String? ?? 'Delhi-NCR',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 28.6304,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 77.2177,
      climateZone: json['climate_zone'] as String? ?? 'Composite Semi-Arid',
      dominantMorphology:
          json['dominant_morphology'] as String? ?? 'HIGH_DENSITY_CONCRETE_CORE',
      threatLevel: json['threat_level'] as String? ?? 'CRITICAL_EXTREME',
      surfaceTelemetry: json['surface_telemetry'] != null
          ? SurfaceThermalTelemetryModel.fromJson(
              json['surface_telemetry'] as Map<String, dynamic>)
          : const SurfaceThermalTelemetryModel(
              lstUrbanCelsius: 48.5,
              lstRuralBaselineCelsius: 41.7,
              uhiThermalAnomalyDeltaC: 6.8,
              canopyAirTempCelsius: 43.2,
              tropicalNightMinTempCelsius: 29.8,
              tropicalNightFlag: true,
              severeTropicalNightFlag: true,
            ),
      biophysicalMetrics: json['biophysical_metrics'] != null
          ? BiophysicalCanopyMetricsModel.fromJson(
              json['biophysical_metrics'] as Map<String, dynamic>)
          : const BiophysicalCanopyMetricsModel(
              imperviousSurfaceFractionPct: 88.5,
              ndviUrbanCore: 0.11,
              ndviRuralBaseline: 0.46,
              vegetationCoolingDeficitDeltaC: 2.6,
              skyViewFactorSvf: 0.38,
              anthropogenicHeatFluxWM2: 96.0,
            ),
      coolRoofSimulation: json['cool_roof_simulation'] != null
          ? CoolRoofSimulationModel.fromJson(
              json['cool_roof_simulation'] as Map<String, dynamic>)
          : const CoolRoofSimulationModel(
              roofMaterial: 'HIGH_ALBEDO_ELASTOMERIC_WHITE',
              solarReflectanceIndexSri: 104,
              solarReflectanceAlpha: 0.85,
              thermalEmittanceEpsilon: 0.90,
              surfaceTemperatureCelsius: 36.5,
              surfaceTempReductionDeltaC: 22.5,
              indoorCoolingBenefitDeltaC: -3.5,
              acEnergyLoadReductionPct: 24.5,
              ndmaCoolRoofCompliant: true,
            ),
      hotspots: (json['hotspots'] as List<dynamic>?)
              ?.map((h) => MicroclimateHotspotModel.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
      directives: json['directives'] != null
          ? MunicipalUhiDirectivesModel.fromJson(
              json['directives'] as Map<String, dynamic>)
          : const MunicipalUhiDirectivesModel(
              coolRoofPolicyStatus: 'ACTIVE_MANDATORY_COMMERCIAL',
              coolRoofTargetSqMeters: 1200000,
              urbanForestryCorridorKm: 45.0,
              transitMistingStationsCount: 65,
              constructionHeatShiftEnforced: true,
              publicPyausDrinkingWaterPoints: 820,
              emergencyCoolingSheltersActive: 140,
            ),
      vernacularBulletins: (json['vernacular_bulletins'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          {},
    );
  }

  Map<String, dynamic> toJson() => {
        'corridor_id': corridorId,
        'city_name': cityName,
        'state': state,
        'latitude': latitude,
        'longitude': longitude,
        'climate_zone': climateZone,
        'dominant_morphology': dominantMorphology,
        'threat_level': threatLevel,
        'surface_telemetry': surfaceTelemetry.toJson(),
        'biophysical_metrics': biophysicalMetrics.toJson(),
        'cool_roof_simulation': coolRoofSimulation.toJson(),
        'hotspots': hotspots.map((h) => h.toJson()).toList(),
        'directives': directives.toJson(),
        'vernacular_bulletins': vernacularBulletins,
      };
}

class CorridorSummaryModel {
  final String corridorId;
  final String cityName;
  final String state;
  final String threatLevel;
  final double uhiThermalAnomalyDeltaC;
  final double lstUrbanCelsius;
  final bool tropicalNightFlag;

  const CorridorSummaryModel({
    required this.corridorId,
    required this.cityName,
    required this.state,
    required this.threatLevel,
    required this.uhiThermalAnomalyDeltaC,
    required this.lstUrbanCelsius,
    required this.tropicalNightFlag,
  });

  factory CorridorSummaryModel.fromJson(Map<String, dynamic> json) {
    return CorridorSummaryModel(
      corridorId: json['corridor_id'] as String? ?? 'delhi_ncr',
      cityName: json['city_name'] as String? ?? 'Delhi-NCR',
      state: json['state'] as String? ?? 'Delhi-NCR',
      threatLevel: json['threat_level'] as String? ?? 'CRITICAL_EXTREME',
      uhiThermalAnomalyDeltaC:
          (json['uhi_thermal_anomaly_delta_c'] as num?)?.toDouble() ?? 6.8,
      lstUrbanCelsius: (json['lst_urban_celsius'] as num?)?.toDouble() ?? 48.5,
      tropicalNightFlag: json['tropical_night_flag'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'corridor_id': corridorId,
        'city_name': cityName,
        'state': state,
        'threat_level': threatLevel,
        'uhi_thermal_anomaly_delta_c': uhiThermalAnomalyDeltaC,
        'lst_urban_celsius': lstUrbanCelsius,
        'tropical_night_flag': tropicalNightFlag,
      };
}

class UrbanHeatIslandResponseModel {
  final String corridorId;
  final String cityName;
  final String state;
  final UrbanHeatIslandCorridorModel currentCorridor;
  final List<CorridorSummaryModel> allCorridors;
  final String lastUpdatedUtc;
  final String dataSource;

  const UrbanHeatIslandResponseModel({
    required this.corridorId,
    required this.cityName,
    required this.state,
    required this.currentCorridor,
    required this.allCorridors,
    required this.lastUpdatedUtc,
    required this.dataSource,
  });

  factory UrbanHeatIslandResponseModel.fromJson(Map<String, dynamic> json) {
    return UrbanHeatIslandResponseModel(
      corridorId: json['corridor_id'] as String? ?? 'delhi_ncr',
      cityName: json['city_name'] as String? ?? 'Delhi-NCR',
      state: json['state'] as String? ?? 'Delhi-NCR',
      currentCorridor: json['current_corridor'] != null
          ? UrbanHeatIslandCorridorModel.fromJson(
              json['current_corridor'] as Map<String, dynamic>)
          : UrbanHeatIslandResponseModel.defaultFallback().currentCorridor,
      allCorridors: (json['all_corridors'] as List<dynamic>?)
              ?.map((c) => CorridorSummaryModel.fromJson(c as Map<String, dynamic>))
              .toList() ??
          UrbanHeatIslandResponseModel.defaultFallback().allCorridors,
      lastUpdatedUtc:
          json['last_updated_utc'] as String? ?? DateTime.now().toUtc().toIso8601String(),
      dataSource: json['data_source'] as String? ??
          'IMD Urban Meteorology Mesonet & NDMA Mission Cool Roofs Telemetry',
    );
  }

  Map<String, dynamic> toJson() => {
        'corridor_id': corridorId,
        'city_name': cityName,
        'state': state,
        'current_corridor': currentCorridor.toJson(),
        'all_corridors': allCorridors.map((c) => c.toJson()).toList(),
        'last_updated_utc': lastUpdatedUtc,
        'data_source': dataSource,
      };

  factory UrbanHeatIslandResponseModel.defaultFallback() {
    return UrbanHeatIslandResponseModel(
      corridorId: 'delhi_ncr',
      cityName: 'Delhi-NCR',
      state: 'Delhi-NCR',
      currentCorridor: UrbanHeatIslandCorridorModel(
        corridorId: 'delhi_ncr',
        cityName: 'Delhi-NCR',
        state: 'Delhi-NCR',
        latitude: 28.6304,
        longitude: 77.2177,
        climateZone: 'Composite Semi-Arid',
        dominantMorphology: 'HIGH_DENSITY_CONCRETE_CORE',
        threatLevel: 'CRITICAL_EXTREME',
        surfaceTelemetry: const SurfaceThermalTelemetryModel(
          lstUrbanCelsius: 48.5,
          lstRuralBaselineCelsius: 41.7,
          uhiThermalAnomalyDeltaC: 6.8,
          canopyAirTempCelsius: 43.2,
          tropicalNightMinTempCelsius: 29.8,
          tropicalNightFlag: true,
          severeTropicalNightFlag: true,
        ),
        biophysicalMetrics: const BiophysicalCanopyMetricsModel(
          imperviousSurfaceFractionPct: 88.5,
          ndviUrbanCore: 0.11,
          ndviRuralBaseline: 0.46,
          vegetationCoolingDeficitDeltaC: 2.6,
          skyViewFactorSvf: 0.38,
          anthropogenicHeatFluxWM2: 96.0,
        ),
        coolRoofSimulation: const CoolRoofSimulationModel(
          roofMaterial: 'HIGH_ALBEDO_ELASTOMERIC_WHITE',
          solarReflectanceIndexSri: 104,
          solarReflectanceAlpha: 0.85,
          thermalEmittanceEpsilon: 0.90,
          surfaceTemperatureCelsius: 36.5,
          surfaceTempReductionDeltaC: 22.5,
          indoorCoolingBenefitDeltaC: -3.5,
          acEnergyLoadReductionPct: 24.5,
          ndmaCoolRoofCompliant: true,
        ),
        hotspots: const [
          MicroclimateHotspotModel(
            hotspotId: 'dl_anand_vihar',
            hotspotName: 'Anand Vihar ISBT & Railway Hub',
            morphology: 'INDUSTRIAL_ASPHALT_ZONE',
            lstCelsius: 49.8,
            thermalAnomalyDeltaC: 8.1,
            vulnerabilityRank: 'VERY_HIGH',
            coolingShelterDistanceM: 350,
          ),
          MicroclimateHotspotModel(
            hotspotId: 'dl_chandni_chowk',
            hotspotName: 'Chandni Chowk Old Walled City',
            morphology: 'HIGH_DENSITY_CONCRETE_CORE',
            lstCelsius: 48.9,
            thermalAnomalyDeltaC: 7.2,
            vulnerabilityRank: 'VERY_HIGH',
            coolingShelterDistanceM: 200,
          ),
          MicroclimateHotspotModel(
            hotspotId: 'dl_okhla_ind',
            hotspotName: 'Okhla Industrial Phase-III',
            morphology: 'INDUSTRIAL_ASPHALT_ZONE',
            lstCelsius: 50.2,
            thermalAnomalyDeltaC: 8.5,
            vulnerabilityRank: 'VERY_HIGH',
            coolingShelterDistanceM: 600,
          ),
          MicroclimateHotspotModel(
            hotspotId: 'dl_connaught_place',
            hotspotName: 'Connaught Place Inner Radial',
            morphology: 'COMMERCIAL_GLASS_CANYON',
            lstCelsius: 48.1,
            thermalAnomalyDeltaC: 6.4,
            vulnerabilityRank: 'HIGH',
            coolingShelterDistanceM: 150,
          ),
        ],
        directives: const MunicipalUhiDirectivesModel(
          coolRoofPolicyStatus: 'ACTIVE_MANDATORY_COMMERCIAL',
          coolRoofTargetSqMeters: 1200000,
          urbanForestryCorridorKm: 45.0,
          transitMistingStationsCount: 65,
          constructionHeatShiftEnforced: true,
          publicPyausDrinkingWaterPoints: 820,
          emergencyCoolingSheltersActive: 140,
        ),
        vernacularBulletins: const {
          'en':
              'DELHI-NCR UHI ADVISORY: Land surface temperature reached 48.5°C with a critical +6.8°C thermal anomaly. Nocturnal minimum stayed at 29.8°C, triggering a Severe Tropical Night with continuous physiological heat stress. High-albedo cool roofs (SRI>=78) provide up to 3.5°C indoor cooling relief. Strenuous outdoor labor is strictly prohibited from 12:00 to 16:00.',
          'hi':
              'दिल्ली-एनसीआर शहरी ताप द्वीप (UHI) चेतावनी: भूमि की सतह का तापमान 48.5°C तक पहुंच गया है (+6.8°C ताप विसंगति)। रात का न्यूनतम तापमान 29.8°C रहा, जिससे गंभीर "ट्रॉपिकल नाइट" बनी हुई है। एसआरआई 78+ कूल रूफ कोटिंग से कमरों का तापमान 3.5°C तक कम किया जा सकता है। दोपहर 12 से 4 बजे तक भारी मजदूरी प्रतिबंधित है।',
          'gu':
              'દિલ્હી-એનસીઆર અર્બન હીટ આઇલેન્ડ ચેતવણી: જમીનનું સપાટી તાપમાન 48.5°C પર પહોંચ્યું છે (+6.8°C વિસંગતતા). રાત્રિનું લઘુત્તમ તાપમાન 29.8°C રહેતા ગંભીર ટ્રોપિકલ નાઇટ જાહેર કરાઈ છે. કૂલ રૂફ ટેકનોલોજીથી ઘરોમાં 3.5°C સુધી રાહત મળી શકે છે.',
          'mr':
              'दिल्ली-एनसीआर अर्बन हीट आयलंड इशारा: जमिनीचे पृष्ठभाग तापमान 48.5°C नोंदवले गेले असून +6.8°C थर्मल ॲनोमली आहे. रात्रीचे किमान तापमान 29.8°C राहिल्याने शरीराला उष्णतेपासून विश्रांती मिळत नाही. कुल रूफ कोटिंगमुळे 3.5°C पर्यंत थंडावा मिळतो.',
          'kn':
              'ದೆಹಲಿ-ಎನ್‌ಸಿಆರ್ ಅರ್ಬನ್ ಹೀಟ್ ಐಲ್ಯಾಂಡ್ ಎಚ್ಚರಿಕೆ: ಭೂ ಮೇಲ್ಮೈ ತಾಪಮಾನವು 48.5°C ತಲುಪಿದ್ದು +6.8°C ವ್ಯತ್ಯಾಸವಿದೆ. ರಾತ್ರಿಯ ಕನಿಷ್ಠ ತಾಪಮಾನ 29.8°C ಆಗಿದ್ದು ತೀವ್ರ ಉಷ್ಣತೆಯಿದೆ. ಕೂಲ್ ರೂಫ್ ಲೇಪನವು 3.5°C ಒಳಾಂಗಣ ತಂಪನ್ನು ನೀಡುತ್ತದೆ.',
          'ta':
              'டெல்லி-என்சிஆர் நகர்ப்புற வெப்ப தீவு (UHI) எச்சரிக்கை: நில மேற்பரப்பு வெப்பநிலை 48.5°C (+6.8°C முரண்பாடு) எட்டியுள்ளது. இரவு குறைந்தபட்ச வெப்பநிலை 29.8°C ஆக பதிவாகியுள்ளது. கூல் ரூஃப் (SRI>=78) பூச்சு உட்புற வெப்பநிலையை 3.5°C வரை குறைக்கும்.',
          'bn':
              'দিল্লি-এনসিআর আরবান হিট আইল্যান্ড সতর্কতা: ভূপৃষ্ঠের তাপমাত্রা রেকর্ড করা হয়েছে 48.5°C (+6.8°C অ্যানোমালি)। রাতের সর্বনিম্ন তাপমাত্রা 29.8°C থাকায় শরীর স্বাভাবিক হতে পারছে না। কুল রুফ কোটিং 3.5°C পর্যন্ত তাপমাত্রা কমায়।',
        },
      ),
      allCorridors: const [
        CorridorSummaryModel(
          corridorId: 'delhi_ncr',
          cityName: 'Delhi-NCR',
          state: 'Delhi-NCR',
          threatLevel: 'CRITICAL_EXTREME',
          uhiThermalAnomalyDeltaC: 6.8,
          lstUrbanCelsius: 48.5,
          tropicalNightFlag: true,
        ),
        CorridorSummaryModel(
          corridorId: 'ahmedabad_amc',
          cityName: 'Ahmedabad AMC',
          state: 'Gujarat',
          threatLevel: 'HIGH_SEVERE',
          uhiThermalAnomalyDeltaC: 5.9,
          lstUrbanCelsius: 47.2,
          tropicalNightFlag: true,
        ),
        CorridorSummaryModel(
          corridorId: 'mumbai_mmr',
          cityName: 'Mumbai MMR',
          state: 'Maharashtra',
          threatLevel: 'HIGH_SEVERE',
          uhiThermalAnomalyDeltaC: 4.8,
          lstUrbanCelsius: 41.6,
          tropicalNightFlag: true,
        ),
        CorridorSummaryModel(
          corridorId: 'bengaluru_bbmp',
          cityName: 'Bengaluru BBMP',
          state: 'Karnataka',
          threatLevel: 'HIGH_SEVERE',
          uhiThermalAnomalyDeltaC: 4.2,
          lstUrbanCelsius: 37.8,
          tropicalNightFlag: false,
        ),
        CorridorSummaryModel(
          corridorId: 'hyderabad_ghmc',
          cityName: 'Hyderabad GHMC',
          state: 'Telangana',
          threatLevel: 'HIGH_SEVERE',
          uhiThermalAnomalyDeltaC: 5.2,
          lstUrbanCelsius: 44.2,
          tropicalNightFlag: true,
        ),
        CorridorSummaryModel(
          corridorId: 'chennai_gcc',
          cityName: 'Chennai GCC',
          state: 'Tamil Nadu',
          threatLevel: 'HIGH_SEVERE',
          uhiThermalAnomalyDeltaC: 4.5,
          lstUrbanCelsius: 42.1,
          tropicalNightFlag: true,
        ),
        CorridorSummaryModel(
          corridorId: 'kolkata_kmc',
          cityName: 'Kolkata KMC',
          state: 'West Bengal',
          threatLevel: 'HIGH_SEVERE',
          uhiThermalAnomalyDeltaC: 4.9,
          lstUrbanCelsius: 43.4,
          tropicalNightFlag: true,
        ),
      ],
      lastUpdatedUtc: '2026-09-12T12:00:00Z',
      dataSource:
          'IMD Urban Meteorology Mesonet & NDMA Mission Cool Roofs Telemetry',
    );
  }
}
