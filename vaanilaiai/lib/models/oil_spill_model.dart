class HydrodynamicDriftVectorModel {
  final double surfaceCurrentSpeedKnots;
  final double surfaceCurrentDirectionDeg;
  final double windSpeed10mKnots;
  final double windDirectionDeg;
  final double netDriftSpeedKnots;
  final double netDriftDirectionDeg;
  final double stokesDriftKnots;

  const HydrodynamicDriftVectorModel({
    required this.surfaceCurrentSpeedKnots,
    required this.surfaceCurrentDirectionDeg,
    required this.windSpeed10mKnots,
    required this.windDirectionDeg,
    required this.netDriftSpeedKnots,
    required this.netDriftDirectionDeg,
    required this.stokesDriftKnots,
  });

  factory HydrodynamicDriftVectorModel.fromJson(Map<String, dynamic> json) {
    return HydrodynamicDriftVectorModel(
      surfaceCurrentSpeedKnots:
          (json['surface_current_speed_knots'] as num?)?.toDouble() ?? 2.8,
      surfaceCurrentDirectionDeg:
          (json['surface_current_direction_deg'] as num?)?.toDouble() ?? 115.0,
      windSpeed10mKnots:
          (json['wind_speed_10m_knots'] as num?)?.toDouble() ?? 18.5,
      windDirectionDeg:
          (json['wind_direction_deg'] as num?)?.toDouble() ?? 290.0,
      netDriftSpeedKnots:
          (json['net_drift_speed_knots'] as num?)?.toDouble() ?? 3.2,
      netDriftDirectionDeg:
          (json['net_drift_direction_deg'] as num?)?.toDouble() ?? 108.0,
      stokesDriftKnots:
          (json['stokes_drift_knots'] as num?)?.toDouble() ?? 0.35,
    );
  }

  Map<String, dynamic> toJson() => {
        'surface_current_speed_knots': surfaceCurrentSpeedKnots,
        'surface_current_direction_deg': surfaceCurrentDirectionDeg,
        'wind_speed_10m_knots': windSpeed10mKnots,
        'wind_direction_deg': windDirectionDeg,
        'net_drift_speed_knots': netDriftSpeedKnots,
        'net_drift_direction_deg': netDriftDirectionDeg,
        'stokes_drift_knots': stokesDriftKnots,
      };
}

class TrajectoryWaypointModel {
  final int timeHorizonHours;
  final double latitude;
  final double longitude;
  final double distanceTraveledKm;
  final double slickAreaKm2;
  final double slickThicknessMicrons;
  final String appearanceCode;
  final String shorelineHitRisk;

  const TrajectoryWaypointModel({
    required this.timeHorizonHours,
    required this.latitude,
    required this.longitude,
    required this.distanceTraveledKm,
    required this.slickAreaKm2,
    required this.slickThicknessMicrons,
    required this.appearanceCode,
    required this.shorelineHitRisk,
  });

  factory TrajectoryWaypointModel.fromJson(Map<String, dynamic> json) {
    return TrajectoryWaypointModel(
      timeHorizonHours: json['time_horizon_hours'] as int? ?? 6,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 22.44,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 69.88,
      distanceTraveledKm:
          (json['distance_traveled_km'] as num?)?.toDouble() ?? 17.8,
      slickAreaKm2: (json['slick_area_km2'] as num?)?.toDouble() ?? 14.2,
      slickThicknessMicrons:
          (json['slick_thickness_microns'] as num?)?.toDouble() ?? 125.0,
      appearanceCode: json['appearance_code']?.toString() ?? 'CODE_4_DISCONTINUOUS_TRUE',
      shorelineHitRisk:
          json['shoreline_hit_risk']?.toString() ?? 'MODERATE_OFFSHORE',
    );
  }

  Map<String, dynamic> toJson() => {
        'time_horizon_hours': timeHorizonHours,
        'latitude': latitude,
        'longitude': longitude,
        'distance_traveled_km': distanceTraveledKm,
        'slick_area_km2': slickAreaKm2,
        'slick_thickness_microns': slickThicknessMicrons,
        'appearance_code': appearanceCode,
        'shoreline_hit_risk': shorelineHitRisk,
      };
}

class FaySpreadingMetricsModel {
  final String currentRegime;
  final double slickRadiusMeters;
  final double slickAreaKm2;
  final double averageThicknessMicrons;
  final String bonnCode;
  final double thickCoreAreaPct;

  const FaySpreadingMetricsModel({
    required this.currentRegime,
    required this.slickRadiusMeters,
    required this.slickAreaKm2,
    required this.averageThicknessMicrons,
    required this.bonnCode,
    required this.thickCoreAreaPct,
  });

  factory FaySpreadingMetricsModel.fromJson(Map<String, dynamic> json) {
    return FaySpreadingMetricsModel(
      currentRegime: json['current_regime']?.toString() ?? 'GRAVITY_VISCOUS_REGIME_II',
      slickRadiusMeters:
          (json['slick_radius_meters'] as num?)?.toDouble() ?? 3200.0,
      slickAreaKm2: (json['slick_area_km2'] as num?)?.toDouble() ?? 32.17,
      averageThicknessMicrons:
          (json['average_thickness_microns'] as num?)?.toDouble() ?? 82.5,
      bonnCode: json['bonn_code']?.toString() ?? 'CODE_4_DISCONTINUOUS_TRUE',
      thickCoreAreaPct:
          (json['thick_core_area_pct'] as num?)?.toDouble() ?? 15.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'current_regime': currentRegime,
        'slick_radius_meters': slickRadiusMeters,
        'slick_area_km2': slickAreaKm2,
        'average_thickness_microns': averageThicknessMicrons,
        'bonn_code': bonnCode,
        'thick_core_area_pct': thickCoreAreaPct,
      };
}

class WeatheringKineticsModel {
  final double evaporatedFractionPct;
  final double emulsifiedWaterFractionPct;
  final double emulsionViscosityCst;
  final double viscosityIncreaseFactor;
  final double naturalDispersionFractionPct;
  final String sedimentationSinkingRisk;
  final double flashPointCelsius;

  const WeatheringKineticsModel({
    required this.evaporatedFractionPct,
    required this.emulsifiedWaterFractionPct,
    required this.emulsionViscosityCst,
    required this.viscosityIncreaseFactor,
    required this.naturalDispersionFractionPct,
    required this.sedimentationSinkingRisk,
    required this.flashPointCelsius,
  });

  factory WeatheringKineticsModel.fromJson(Map<String, dynamic> json) {
    return WeatheringKineticsModel(
      evaporatedFractionPct:
          (json['evaporated_fraction_pct'] as num?)?.toDouble() ?? 34.2,
      emulsifiedWaterFractionPct:
          (json['emulsified_water_fraction_pct'] as num?)?.toDouble() ?? 62.0,
      emulsionViscosityCst:
          (json['emulsion_viscosity_cst'] as num?)?.toDouble() ?? 18500.0,
      viscosityIncreaseFactor:
          (json['viscosity_increase_factor'] as num?)?.toDouble() ?? 37.0,
      naturalDispersionFractionPct:
          (json['natural_dispersion_fraction_pct'] as num?)?.toDouble() ?? 8.4,
      sedimentationSinkingRisk: json['sedimentation_sinking_risk']?.toString() ??
          'MODERATE_NEARSHORE_SUSPENDED_SEDIMENT',
      flashPointCelsius:
          (json['flash_point_celsius'] as num?)?.toDouble() ?? 68.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'evaporated_fraction_pct': evaporatedFractionPct,
        'emulsified_water_fraction_pct': emulsifiedWaterFractionPct,
        'emulsion_viscosity_cst': emulsionViscosityCst,
        'viscosity_increase_factor': viscosityIncreaseFactor,
        'natural_dispersion_fraction_pct': naturalDispersionFractionPct,
        'sedimentation_sinking_risk': sedimentationSinkingRisk,
        'flash_point_celsius': flashPointCelsius,
      };
}

class SensitiveHabitatNodeModel {
  final String habitatId;
  final String habitatName;
  final String ecosystemType;
  final int esiRating;
  final double distanceFromSlickKm;
  final int estimatedImpactEtaHours;
  final String priorityProtectionRank;
  final String boomDefensePlan;

  const SensitiveHabitatNodeModel({
    required this.habitatId,
    required this.habitatName,
    required this.ecosystemType,
    required this.esiRating,
    required this.distanceFromSlickKm,
    required this.estimatedImpactEtaHours,
    required this.priorityProtectionRank,
    required this.boomDefensePlan,
  });

  factory SensitiveHabitatNodeModel.fromJson(Map<String, dynamic> json) {
    return SensitiveHabitatNodeModel(
      habitatId: json['habitat_id']?.toString() ?? 'habitat',
      habitatName: json['habitat_name']?.toString() ?? 'Sensitive Marine Habitat',
      ecosystemType: json['ecosystem_type']?.toString() ?? 'Coral Reefs',
      esiRating: json['esi_rating'] as int? ?? 10,
      distanceFromSlickKm:
          (json['distance_from_slick_km'] as num?)?.toDouble() ?? 14.5,
      estimatedImpactEtaHours: json['estimated_impact_eta_hours'] as int? ?? 9,
      priorityProtectionRank:
          json['priority_protection_rank']?.toString() ?? 'PRIORITY_1_IMMEDIATE_DEFENSE',
      boomDefensePlan: json['boom_defense_plan']?.toString() ?? 'Deploy containment booms',
    );
  }

  Map<String, dynamic> toJson() => {
        'habitat_id': habitatId,
        'habitat_name': habitatName,
        'ecosystem_type': ecosystemType,
        'esi_rating': esiRating,
        'distance_from_slick_km': distanceFromSlickKm,
        'estimated_impact_eta_hours': estimatedImpactEtaHours,
        'priority_protection_rank': priorityProtectionRank,
        'boom_defense_plan': boomDefensePlan,
      };
}

class IcgContainmentDirectivesModel {
  final String nosdcpActivationLevel;
  final String leadResponseAuthority;
  final String containmentBoomType;
  final double recommendedBoomLengthMeters;
  final double maximumTowingSpeedKnots;
  final String skimmerSelection;
  final String chemicalDispersantClearance;
  final String dispersantRestrictions;
  final String coastGuardEmergencyNo;

  const IcgContainmentDirectivesModel({
    required this.nosdcpActivationLevel,
    required this.leadResponseAuthority,
    required this.containmentBoomType,
    required this.recommendedBoomLengthMeters,
    required this.maximumTowingSpeedKnots,
    required this.skimmerSelection,
    required this.chemicalDispersantClearance,
    required this.dispersantRestrictions,
    required this.coastGuardEmergencyNo,
  });

  factory IcgContainmentDirectivesModel.fromJson(Map<String, dynamic> json) {
    return IcgContainmentDirectivesModel(
      nosdcpActivationLevel:
          json['nosdcp_activation_level']?.toString() ?? 'TIER_2_REGIONAL_COAST_GUARD',
      leadResponseAuthority: json['lead_response_authority']?.toString() ??
          'Indian Coast Guard District HQ No. 1 (Porbandar / Vadinar)',
      containmentBoomType: json['containment_boom_type']?.toString() ??
          'Offshore High-Buoyancy Inflatable Curtain Boom',
      recommendedBoomLengthMeters:
          (json['recommended_boom_length_meters'] as num?)?.toDouble() ?? 3500.0,
      maximumTowingSpeedKnots:
          (json['maximum_towing_speed_knots'] as num?)?.toDouble() ?? 0.75,
      skimmerSelection: json['skimmer_selection']?.toString() ??
          'Oleophilic Multi-Disc & Brush Skimmer',
      chemicalDispersantClearance: json['chemical_dispersant_clearance']?.toString() ??
          'CONDITIONAL: Permitted outside 5km buffer where depth >20m',
      dispersantRestrictions: json['dispersant_restrictions']?.toString() ??
          'PROHIBITED in coral lagoons and intertidal mudflats',
      coastGuardEmergencyNo:
          json['coast_guard_emergency_no']?.toString() ?? '1554',
    );
  }

  Map<String, dynamic> toJson() => {
        'nosdcp_activation_level': nosdcpActivationLevel,
        'lead_response_authority': leadResponseAuthority,
        'containment_boom_type': containmentBoomType,
        'recommended_boom_length_meters': recommendedBoomLengthMeters,
        'maximum_towing_speed_knots': maximumTowingSpeedKnots,
        'skimmer_selection': skimmerSelection,
        'chemical_dispersant_clearance': chemicalDispersantClearance,
        'dispersant_restrictions': dispersantRestrictions,
        'coast_guard_emergency_no': coastGuardEmergencyNo,
      };
}

class OilSpillCorridorModel {
  final String corridorId;
  final String corridorName;
  final String stateOrUt;
  final double latitude;
  final double longitude;
  final double spillVolumeTonnes;
  final String oilType;
  final String severityTier;
  final HydrodynamicDriftVectorModel driftVector;
  final List<TrajectoryWaypointModel> trajectoryWaypoints;
  final FaySpreadingMetricsModel faySpreading;
  final WeatheringKineticsModel weathering;
  final List<SensitiveHabitatNodeModel> sensitiveHabitats;
  final IcgContainmentDirectivesModel icgDirectives;

  const OilSpillCorridorModel({
    required this.corridorId,
    required this.corridorName,
    required this.stateOrUt,
    required this.latitude,
    required this.longitude,
    required this.spillVolumeTonnes,
    required this.oilType,
    required this.severityTier,
    required this.driftVector,
    required this.trajectoryWaypoints,
    required this.faySpreading,
    required this.weathering,
    required this.sensitiveHabitats,
    required this.icgDirectives,
  });

  factory OilSpillCorridorModel.fromJson(Map<String, dynamic> json) {
    return OilSpillCorridorModel(
      corridorId: json['corridor_id']?.toString() ?? 'gulf_of_kutch_vadinar',
      corridorName: json['corridor_name']?.toString() ??
          'Gulf of Kutch & Vadinar SBM Offshore Corridor',
      stateOrUt: json['state_or_ut']?.toString() ?? 'Gujarat',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 22.48,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 69.72,
      spillVolumeTonnes:
          (json['spill_volume_tonnes'] as num?)?.toDouble() ?? 3500.0,
      oilType: json['oil_type']?.toString() ?? 'MEDIUM_CRUDE_ARABIAN_LIGHT',
      severityTier:
          json['severity_tier']?.toString() ?? 'TIER_2_REGIONAL_COAST_GUARD',
      driftVector: HydrodynamicDriftVectorModel.fromJson(
          json['drift_vector'] as Map<String, dynamic>? ?? {}),
      trajectoryWaypoints: (json['trajectory_waypoints'] as List<dynamic>?)
              ?.map((e) =>
                  TrajectoryWaypointModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      faySpreading: FaySpreadingMetricsModel.fromJson(
          json['fay_spreading'] as Map<String, dynamic>? ?? {}),
      weathering: WeatheringKineticsModel.fromJson(
          json['weathering'] as Map<String, dynamic>? ?? {}),
      sensitiveHabitats: (json['sensitive_habitats'] as List<dynamic>?)
              ?.map((e) =>
                  SensitiveHabitatNodeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      icgDirectives: IcgContainmentDirectivesModel.fromJson(
          json['icg_directives'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'corridor_id': corridorId,
        'corridor_name': corridorName,
        'state_or_ut': stateOrUt,
        'latitude': latitude,
        'longitude': longitude,
        'spill_volume_tonnes': spillVolumeTonnes,
        'oil_type': oilType,
        'severity_tier': severityTier,
        'drift_vector': driftVector.toJson(),
        'trajectory_waypoints':
            trajectoryWaypoints.map((e) => e.toJson()).toList(),
        'fay_spreading': faySpreading.toJson(),
        'weathering': weathering.toJson(),
        'sensitive_habitats':
            sensitiveHabitats.map((e) => e.toJson()).toList(),
        'icg_directives': icgDirectives.toJson(),
      };
}

class CorridorSummaryModel {
  final String corridorId;
  final String corridorName;
  final String stateOrUt;
  final String severityTier;
  final String oilType;
  final double spillVolumeTonnes;
  final double slickAreaKm2;
  final int nearestHabitatEtaHours;

  const CorridorSummaryModel({
    required this.corridorId,
    required this.corridorName,
    required this.stateOrUt,
    required this.severityTier,
    required this.oilType,
    required this.spillVolumeTonnes,
    required this.slickAreaKm2,
    required this.nearestHabitatEtaHours,
  });

  factory CorridorSummaryModel.fromJson(Map<String, dynamic> json) {
    return CorridorSummaryModel(
      corridorId: json['corridor_id']?.toString() ?? '',
      corridorName: json['corridor_name']?.toString() ?? '',
      stateOrUt: json['state_or_ut']?.toString() ?? '',
      severityTier: json['severity_tier']?.toString() ?? 'TIER_1_LOCAL_PORT',
      oilType: json['oil_type']?.toString() ?? 'MEDIUM_CRUDE_ARABIAN_LIGHT',
      spillVolumeTonnes:
          (json['spill_volume_tonnes'] as num?)?.toDouble() ?? 0.0,
      slickAreaKm2: (json['slick_area_km2'] as num?)?.toDouble() ?? 0.0,
      nearestHabitatEtaHours: json['nearest_habitat_eta_hours'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'corridor_id': corridorId,
        'corridor_name': corridorName,
        'state_or_ut': stateOrUt,
        'severity_tier': severityTier,
        'oil_type': oilType,
        'spill_volume_tonnes': spillVolumeTonnes,
        'slick_area_km2': slickAreaKm2,
        'nearest_habitat_eta_hours': nearestHabitatEtaHours,
      };
}

class OilSpillResponseModel {
  final OilSpillCorridorModel selectedCorridor;
  final List<CorridorSummaryModel> allCorridors;
  final Map<String, String> bulletins;
  final bool offlineCached;
  final String generatedAt;

  const OilSpillResponseModel({
    required this.selectedCorridor,
    required this.allCorridors,
    required this.bulletins,
    required this.offlineCached,
    required this.generatedAt,
  });

  factory OilSpillResponseModel.fromJson(Map<String, dynamic> json) {
    return OilSpillResponseModel(
      selectedCorridor: OilSpillCorridorModel.fromJson(
          json['selected_corridor'] as Map<String, dynamic>? ?? {}),
      allCorridors: (json['all_corridors'] as List<dynamic>?)
              ?.map((e) => CorridorSummaryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      bulletins: (json['bulletins'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          {},
      offlineCached: json['offline_cached'] as bool? ?? false,
      generatedAt: json['generated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'selected_corridor': selectedCorridor.toJson(),
        'all_corridors': allCorridors.map((e) => e.toJson()).toList(),
        'bulletins': bulletins,
        'offline_cached': offlineCached,
        'generated_at': generatedAt,
      };

  factory OilSpillResponseModel.defaultFallback() {
    const drift = HydrodynamicDriftVectorModel(
      surfaceCurrentSpeedKnots: 2.8,
      surfaceCurrentDirectionDeg: 115.0,
      windSpeed10mKnots: 18.5,
      windDirectionDeg: 290.0,
      netDriftSpeedKnots: 3.2,
      netDriftDirectionDeg: 108.0,
      stokesDriftKnots: 0.35,
    );

    final waypoints = [
      const TrajectoryWaypointModel(
        timeHorizonHours: 6,
        latitude: 22.44,
        longitude: 69.88,
        distanceTraveledKm: 17.8,
        slickAreaKm2: 14.2,
        slickThicknessMicrons: 125.0,
        appearanceCode: 'CODE_4_DISCONTINUOUS_TRUE',
        shorelineHitRisk: 'MODERATE_OFFSHORE',
      ),
      const TrajectoryWaypointModel(
        timeHorizonHours: 12,
        latitude: 22.41,
        longitude: 70.04,
        distanceTraveledKm: 35.5,
        slickAreaKm2: 28.6,
        slickThicknessMicrons: 68.0,
        appearanceCode: 'CODE_4_DISCONTINUOUS_TRUE',
        shorelineHitRisk: 'HIGH_INTERTIDAL_REEF',
      ),
      const TrajectoryWaypointModel(
        timeHorizonHours: 24,
        latitude: 22.36,
        longitude: 70.32,
        distanceTraveledKm: 71.0,
        slickAreaKm2: 52.4,
        slickThicknessMicrons: 32.0,
        appearanceCode: 'CODE_3_METALLIC',
        shorelineHitRisk: 'IMMINENT_LANDFALL_NARARA',
      ),
      const TrajectoryWaypointModel(
        timeHorizonHours: 48,
        latitude: 22.30,
        longitude: 70.68,
        distanceTraveledKm: 138.0,
        slickAreaKm2: 86.0,
        slickThicknessMicrons: 12.0,
        appearanceCode: 'CODE_3_METALLIC',
        shorelineHitRisk: 'BEACHED_MANGROVES',
      ),
      const TrajectoryWaypointModel(
        timeHorizonHours: 72,
        latitude: 22.25,
        longitude: 70.95,
        distanceTraveledKm: 195.0,
        slickAreaKm2: 118.0,
        slickThicknessMicrons: 4.5,
        appearanceCode: 'CODE_2_RAINBOW',
        shorelineHitRisk: 'STRANDED_ESTUARINE_MUDFLAT',
      ),
    ];

    const fay = FaySpreadingMetricsModel(
      currentRegime: 'GRAVITY_VISCOUS_REGIME_II',
      slickRadiusMeters: 3200.0,
      slickAreaKm2: 32.17,
      averageThicknessMicrons: 82.5,
      bonnCode: 'CODE_4_DISCONTINUOUS_TRUE',
      thickCoreAreaPct: 15.0,
    );

    const weathering = WeatheringKineticsModel(
      evaporatedFractionPct: 34.2,
      emulsifiedWaterFractionPct: 62.0,
      emulsionViscosityCst: 18500.0,
      viscosityIncreaseFactor: 37.0,
      naturalDispersionFractionPct: 8.4,
      sedimentationSinkingRisk: 'MODERATE_NEARSHORE_SUSPENDED_SEDIMENT',
      flashPointCelsius: 68.0,
    );

    final habitats = [
      const SensitiveHabitatNodeModel(
        habitatId: 'marine_national_park_jamnagar',
        habitatName: 'Marine National Park & Coral Sanctuaries (Pirotan & Narara)',
        ecosystemType: 'Fringing Coral Reefs & Scleractinian Corals',
        esiRating: 10,
        distanceFromSlickKm: 14.5,
        estimatedImpactEtaHours: 9,
        priorityProtectionRank: 'PRIORITY_1_IMMEDIATE_DEFENSE',
        boomDefensePlan:
            'Deploy 2,400m Offshore Curtain Boom at Pirotan Channel mouth with deflection angle 45°.',
      ),
      const SensitiveHabitatNodeModel(
        habitatId: 'kutch_mangrove_creeks',
        habitatName: 'Avicennia Marina Mangrove Creeks (Mundra / Kandla)',
        ecosystemType: 'Intertidal Mangrove Mudflat Forest',
        esiRating: 10,
        distanceFromSlickKm: 28.0,
        estimatedImpactEtaHours: 18,
        priorityProtectionRank: 'PRIORITY_2_SHORELINE_EXCLUSION',
        boomDefensePlan:
            'Seal tidal creek inlets using multi-tube shore-sealing booms (SSB) anchored to mudflats.',
      ),
      const SensitiveHabitatNodeModel(
        habitatId: 'vadinar_crude_sbm_berths',
        habitatName: 'Vadinar IOCL/Nayara Single Buoy Moorings (SBM 1-3)',
        ecosystemType: 'Critical Deep-Water Hydrocarbon Infrastructure',
        esiRating: 7,
        distanceFromSlickKm: 6.2,
        estimatedImpactEtaHours: 4,
        priorityProtectionRank: 'PRIORITY_1_IMMEDIATE_DEFENSE',
        boomDefensePlan:
            'Surround SBM tanker loading berths with fast-deployment ocean containment booms and weir skimmers.',
      ),
    ];

    const icg = IcgContainmentDirectivesModel(
      nosdcpActivationLevel: 'TIER_2_REGIONAL_COAST_GUARD',
      leadResponseAuthority: 'Indian Coast Guard District HQ No. 1 (Porbandar / Vadinar)',
      containmentBoomType:
          'Offshore High-Buoyancy Inflatable Curtain Boom (1200mm skirt)',
      recommendedBoomLengthMeters: 3500.0,
      maximumTowingSpeedKnots: 0.75,
      skimmerSelection:
          'Oleophilic Multi-Disc & Brush Skimmer (Recovery capacity: 120 m³/h)',
      chemicalDispersantClearance:
          'CONDITIONAL: Permitted outside 5km Marine National Park buffer where depth >20m.',
      dispersantRestrictions:
          'PROHIBITED in coral lagoons, intertidal mudflats, and oyster beds of Pirotan.',
      coastGuardEmergencyNo: '1554',
    );

    final corridor = OilSpillCorridorModel(
      corridorId: 'gulf_of_kutch_vadinar',
      corridorName: 'Gulf of Kutch & Vadinar SBM Offshore Corridor',
      stateOrUt: 'Gujarat',
      latitude: 22.48,
      longitude: 69.72,
      spillVolumeTonnes: 3500.0,
      oilType: 'MEDIUM_CRUDE_ARABIAN_LIGHT',
      severityTier: 'TIER_2_REGIONAL_COAST_GUARD',
      driftVector: drift,
      trajectoryWaypoints: waypoints,
      faySpreading: fay,
      weathering: weathering,
      sensitiveHabitats: habitats,
      icgDirectives: icg,
    );

    final summaries = [
      const CorridorSummaryModel(
        corridorId: 'gulf_of_kutch_vadinar',
        corridorName: 'Gulf of Kutch & Vadinar SBM Offshore Corridor',
        stateOrUt: 'Gujarat',
        severityTier: 'TIER_2_REGIONAL_COAST_GUARD',
        oilType: 'MEDIUM_CRUDE_ARABIAN_LIGHT',
        spillVolumeTonnes: 3500.0,
        slickAreaKm2: 32.17,
        nearestHabitatEtaHours: 4,
      ),
      const CorridorSummaryModel(
        corridorId: 'mumbai_harbour_uran',
        corridorName: 'Mumbai Harbour & JNPT / Uran Mudflats Corridor',
        stateOrUt: 'Maharashtra',
        severityTier: 'TIER_2_REGIONAL_COAST_GUARD',
        oilType: 'HEAVY_BUNKER_FUEL_FO180',
        spillVolumeTonnes: 1200.0,
        slickAreaKm2: 13.85,
        nearestHabitatEtaHours: 6,
      ),
      const CorridorSummaryModel(
        corridorId: 'gulf_of_mannar_pamban',
        corridorName: 'Gulf of Mannar Biosphere & Pamban Island Corridor',
        stateOrUt: 'Tamil Nadu',
        severityTier: 'TIER_1_LOCAL_PORT',
        oilType: 'LIGHT_REFINED_DIESEL',
        spillVolumeTonnes: 450.0,
        slickAreaKm2: 6.15,
        nearestHabitatEtaHours: 7,
      ),
      const CorridorSummaryModel(
        corridorId: 'gahirmatha_olive_ridley',
        corridorName: 'Gahirmatha & Bhitarkanika Marine Sanctuary Corridor',
        stateOrUt: 'Odisha',
        severityTier: 'TIER_2_REGIONAL_COAST_GUARD',
        oilType: 'MEDIUM_CRUDE_ARABIAN_LIGHT',
        spillVolumeTonnes: 2200.0,
        slickAreaKm2: 21.23,
        nearestHabitatEtaHours: 8,
      ),
      const CorridorSummaryModel(
        corridorId: 'sundarbans_hooghly',
        corridorName: 'Sundarbans Biosphere & Hooghly Estuary Corridor',
        stateOrUt: 'West Bengal',
        severityTier: 'TIER_2_REGIONAL_COAST_GUARD',
        oilType: 'HEAVY_BUNKER_FUEL_FO180',
        spillVolumeTonnes: 1800.0,
        slickAreaKm2: 18.10,
        nearestHabitatEtaHours: 8,
      ),
      const CorridorSummaryModel(
        corridorId: 'vembanad_cochin',
        corridorName: 'Cochin Port & Vembanad Estuary Backwaters',
        stateOrUt: 'Kerala',
        severityTier: 'TIER_1_LOCAL_PORT',
        oilType: 'LIGHT_REFINED_DIESEL',
        spillVolumeTonnes: 350.0,
        slickAreaKm2: 4.52,
        nearestHabitatEtaHours: 5,
      ),
      const CorridorSummaryModel(
        corridorId: 'andaman_malacca_corridor',
        corridorName: 'Great Nicobar & Malacca Strait Tanker Sea Lane',
        stateOrUt: 'Andaman and Nicobar Islands',
        severityTier: 'TIER_3_NATIONAL_NOSDCP',
        oilType: 'MEDIUM_CRUDE_ARABIAN_LIGHT',
        spillVolumeTonnes: 12500.0,
        slickAreaKm2: 63.62,
        nearestHabitatEtaHours: 14,
      ),
    ];

    const bulletins = {
      'en':
          'INCOIS-ICG MARINE OIL SPILL ADVISORY for Gulf of Kutch & Vadinar: TIER 2 REGIONAL WARNING declared for 3,500 tonnes of Arabian Light crude. Surface slick drifting ESE at 3.2 kt towards Marine National Park reefs. Impact ETA 9 hours. Containment booms deployed; emergency hotline 1554.',
      'ta':
          'இன்கோயிஸ் - இந்திய கடலோர காவல்படை (ICG) எச்சரிக்கை: கட்ச் வளைகுடாவில் 3,500 டன் கச்சா எண்ணெய் கசிவு காரணமாக நிலை 2 (Tier 2) அவசரநிலை அறிவிக்கப்பட்டுள்ளது. எண்ணெய் படலம் 3.2 நாட்ஸ் வேகத்தில் பவளப்பாறைகளை நோக்கி நகர்கிறது. உதவி எண் 1554.',
      'bn':
          'ইনকোইস ও ভারতীয় উপকূলরক্ষী বাহিনী (ICG) সতর্কতা: কচ্ছ উপসাগরে ৩,৫০০ টন অশোধিত তেল নিঃসরণের জন্য টিয়ার ২ সতর্কতা জারি। তেলের স্তর ৩.২ নট বেগে এগোচ্ছে। প্রবাল প্রাচীর সুরক্ষায় ব্যারিকেড স্থাপন করা হয়েছে; হেল্পলাইন 1554।',
      'ml':
          'ഇൻകോയിസ് - കോസ്റ്റ് ഗാർഡ് എണ്ണ ചോർച്ച മുന്നറിയിപ്പ്: കച്ച് ഉൾക്കടലിൽ 3,500 ടൺ ക്രൂഡ് ഓയിൽ ചോർന്നതിനെ തുടർന്ന് ടയർ 2 ജാഗ്രത പ്രഖ്യാപിച്ചു. എണ്ണപ്പടലം 3.2 നോട്ട് വേഗതയിൽ നീങ്ങുന്നു. അടിയന്തര ഹെൽപ്പ് ലൈൻ 1554.',
      'gu':
          'ઇનકોઇસ અને ભારતીય કોસ્ટ ગાર્ડ ચેતવણી: કચ્છના અખાતમાં ૩,૫૦૦ ટન ક્રૂડ ઓઇલ ગળતર માટે ટાયર ૨ કટોકટી જાહેર. તેલનું સ્તર ૩.૨ નોટ્સની ઝડપે મરીન નેશનલ પાર્ક તરફ આગળ વધી રહ્યું છે. હેલ્પલાઇન 1554.',
      'mr':
          'इन्कॉईस व तटरक्षक दल इशारा: कच्छच्या आखातात ३,५०० टन तेल गळतीमुळे टियर २ आणीबाणी घोषित. तेल ३.२ नॉट्स वेगाने प्रवाहित होत आहे. प्रवाळ भित्तींच्या संरक्षणासाठी बूम्स तैनात; संपर्क 1554.',
      'od':
          'ଇନକୋଇସ ଓ ତଟରକ୍ଷୀ ବାହିନୀ ସତର୍କତା: କଚ୍ଛ ଉପସାଗରରେ ୩,୫୦୦ ଟନ୍ ତେଲ ନିର୍ଗମନ ଯୋଗୁଁ ଟିୟର ୨ ଜରୁରୀ ପରିସ୍ଥିତି ଘୋଷଣା। ତେଲ ପତଳା ସ୍ତର ୩.୨ ନଟ୍ ବେଗରେ ଗତି କରୁଛି। ହେଲ୍ପଲାଇନ୍ 1554.',
    };

    return OilSpillResponseModel(
      selectedCorridor: corridor,
      allCorridors: summaries,
      bulletins: bulletins,
      offlineCached: true,
      generatedAt: DateTime.now().toUtc().toIso8601String(),
    );
  }
}
