class HubHeightWindVectorModel {
  final int heightM;
  final double windSpeedMs;
  final double windSpeedKmh;
  final double windPowerDensityWm2;
  final double windDirectionDeg;
  final String cardinalDirection;
  final String resourceTier;

  const HubHeightWindVectorModel({
    required this.heightM,
    required this.windSpeedMs,
    required this.windSpeedKmh,
    required this.windPowerDensityWm2,
    required this.windDirectionDeg,
    required this.cardinalDirection,
    required this.resourceTier,
  });

  factory HubHeightWindVectorModel.fromJson(Map<String, dynamic> json) {
    return HubHeightWindVectorModel(
      heightM: json['height_m'] as int? ?? 100,
      windSpeedMs: (json['wind_speed_ms'] as num?)?.toDouble() ?? 8.0,
      windSpeedKmh: (json['wind_speed_kmh'] as num?)?.toDouble() ?? 28.8,
      windPowerDensityWm2: (json['wind_power_density_wm2'] as num?)?.toDouble() ?? 350.0,
      windDirectionDeg: (json['wind_direction_deg'] as num?)?.toDouble() ?? 245.0,
      cardinalDirection: json['cardinal_direction']?.toString() ?? 'WSW',
      resourceTier: json['resource_tier']?.toString() ?? 'GOOD',
    );
  }

  Map<String, dynamic> toJson() => {
        'height_m': heightM,
        'wind_speed_ms': windSpeedMs,
        'wind_speed_kmh': windSpeedKmh,
        'wind_power_density_wm2': windPowerDensityWm2,
        'wind_direction_deg': windDirectionDeg,
        'cardinal_direction': cardinalDirection,
        'resource_tier': resourceTier,
      };
}

class AtmosphericAirDensityProfileModel {
  final double surfaceTemperatureC;
  final double surfacePressureHpa;
  final double airDensityKgm3;
  final double standardDensityKgm3;
  final double densityRatio;
  final String thermalDeratingNote;

  const AtmosphericAirDensityProfileModel({
    required this.surfaceTemperatureC,
    required this.surfacePressureHpa,
    required this.airDensityKgm3,
    required this.standardDensityKgm3,
    required this.densityRatio,
    required this.thermalDeratingNote,
  });

  factory AtmosphericAirDensityProfileModel.fromJson(Map<String, dynamic> json) {
    return AtmosphericAirDensityProfileModel(
      surfaceTemperatureC: (json['surface_temperature_c'] as num?)?.toDouble() ?? 30.0,
      surfacePressureHpa: (json['surface_pressure_hpa'] as num?)?.toDouble() ?? 1008.0,
      airDensityKgm3: (json['air_density_kgm3'] as num?)?.toDouble() ?? 1.157,
      standardDensityKgm3: (json['standard_density_kgm3'] as num?)?.toDouble() ?? 1.225,
      densityRatio: (json['density_ratio'] as num?)?.toDouble() ?? 0.945,
      thermalDeratingNote: json['thermal_derating_note']?.toString() ??
          'Moderate thermal air thinning, resulting in minor aerodynamic derating.',
    );
  }

  Map<String, dynamic> toJson() => {
        'surface_temperature_c': surfaceTemperatureC,
        'surface_pressure_hpa': surfacePressureHpa,
        'air_density_kgm3': airDensityKgm3,
        'standard_density_kgm3': standardDensityKgm3,
        'density_ratio': densityRatio,
        'thermal_derating_note': thermalDeratingNote,
      };
}

class WeibullParametersModel {
  final double shapeK;
  final double scaleCMs;
  final double annualMeanSpeedMs;

  const WeibullParametersModel({
    required this.shapeK,
    required this.scaleCMs,
    required this.annualMeanSpeedMs,
  });

  factory WeibullParametersModel.fromJson(Map<String, dynamic> json) {
    return WeibullParametersModel(
      shapeK: (json['shape_k'] as num?)?.toDouble() ?? 2.2,
      scaleCMs: (json['scale_c_ms'] as num?)?.toDouble() ?? 8.0,
      annualMeanSpeedMs: (json['annual_mean_speed_ms'] as num?)?.toDouble() ?? 7.1,
    );
  }

  Map<String, dynamic> toJson() => {
        'shape_k': shapeK,
        'scale_c_ms': scaleCMs,
        'annual_mean_speed_ms': annualMeanSpeedMs,
      };
}

class TurbineGenerationProfileModel {
  final String modelName;
  final double ratedPowerMw;
  final double rotorDiameterM;
  final int hubHeightM;
  final double cutInSpeedMs;
  final double ratedSpeedMs;
  final double cutOutSpeedMs;
  final String operatingState;
  final double grossHourlyOutputMw;
  final double wakeLossPct;
  final double bopElectricalLossPct;
  final double bladeSoilingLossPct;
  final double netHourlyOutputMw;
  final double dailyGenerationMwh;
  final double capacityUtilizationFactorPct;

  const TurbineGenerationProfileModel({
    required this.modelName,
    required this.ratedPowerMw,
    required this.rotorDiameterM,
    required this.hubHeightM,
    required this.cutInSpeedMs,
    required this.ratedSpeedMs,
    required this.cutOutSpeedMs,
    required this.operatingState,
    required this.grossHourlyOutputMw,
    required this.wakeLossPct,
    required this.bopElectricalLossPct,
    required this.bladeSoilingLossPct,
    required this.netHourlyOutputMw,
    required this.dailyGenerationMwh,
    required this.capacityUtilizationFactorPct,
  });

  factory TurbineGenerationProfileModel.fromJson(Map<String, dynamic> json) {
    return TurbineGenerationProfileModel(
      modelName: json['model_name']?.toString() ?? 'Utility Wind Turbine',
      ratedPowerMw: (json['rated_power_mw'] as num?)?.toDouble() ?? 2.0,
      rotorDiameterM: (json['rotor_diameter_m'] as num?)?.toDouble() ?? 100.0,
      hubHeightM: json['hub_height_m'] as int? ?? 100,
      cutInSpeedMs: (json['cut_in_speed_ms'] as num?)?.toDouble() ?? 3.0,
      ratedSpeedMs: (json['rated_speed_ms'] as num?)?.toDouble() ?? 11.5,
      cutOutSpeedMs: (json['cut_out_speed_ms'] as num?)?.toDouble() ?? 25.0,
      operatingState: json['operating_state']?.toString() ?? 'PARTIAL_LOAD_RAMP',
      grossHourlyOutputMw: (json['gross_hourly_output_mw'] as num?)?.toDouble() ?? 1.2,
      wakeLossPct: (json['wake_loss_pct'] as num?)?.toDouble() ?? 7.5,
      bopElectricalLossPct: (json['bop_electrical_loss_pct'] as num?)?.toDouble() ?? 3.0,
      bladeSoilingLossPct: (json['blade_soiling_loss_pct'] as num?)?.toDouble() ?? 1.5,
      netHourlyOutputMw: (json['net_hourly_output_mw'] as num?)?.toDouble() ?? 1.06,
      dailyGenerationMwh: (json['daily_generation_mwh'] as num?)?.toDouble() ?? 25.4,
      capacityUtilizationFactorPct:
          (json['capacity_utilization_factor_pct'] as num?)?.toDouble() ?? 35.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'model_name': modelName,
        'rated_power_mw': ratedPowerMw,
        'rotor_diameter_m': rotorDiameterM,
        'hub_height_m': hubHeightM,
        'cut_in_speed_ms': cutInSpeedMs,
        'rated_speed_ms': ratedSpeedMs,
        'cut_out_speed_ms': cutOutSpeedMs,
        'operating_state': operatingState,
        'gross_hourly_output_mw': grossHourlyOutputMw,
        'wake_loss_pct': wakeLossPct,
        'bop_electrical_loss_pct': bopElectricalLossPct,
        'blade_soiling_loss_pct': bladeSoilingLossPct,
        'net_hourly_output_mw': netHourlyOutputMw,
        'daily_generation_mwh': dailyGenerationMwh,
        'capacity_utilization_factor_pct': capacityUtilizationFactorPct,
      };
}

class RepoweringPotentialModel {
  final double legacyTurbineRatingKw;
  final double modernTurbineRatingMw;
  final double energyYieldMultiplier;
  final double co2AbatementTonsYr;
  final String repoweringPriority;

  const RepoweringPotentialModel({
    required this.legacyTurbineRatingKw,
    required this.modernTurbineRatingMw,
    required this.energyYieldMultiplier,
    required this.co2AbatementTonsYr,
    required this.repoweringPriority,
  });

  factory RepoweringPotentialModel.fromJson(Map<String, dynamic> json) {
    return RepoweringPotentialModel(
      legacyTurbineRatingKw: (json['legacy_turbine_rating_kw'] as num?)?.toDouble() ?? 400.0,
      modernTurbineRatingMw: (json['modern_turbine_rating_mw'] as num?)?.toDouble() ?? 3.0,
      energyYieldMultiplier: (json['energy_yield_multiplier'] as num?)?.toDouble() ?? 3.2,
      co2AbatementTonsYr: (json['co2_abatement_tons_yr'] as num?)?.toDouble() ?? 4500.0,
      repoweringPriority: json['repowering_priority']?.toString() ?? 'HIGH',
    );
  }

  Map<String, dynamic> toJson() => {
        'legacy_turbine_rating_kw': legacyTurbineRatingKw,
        'modern_turbine_rating_mw': modernTurbineRatingMw,
        'energy_yield_multiplier': energyYieldMultiplier,
        'co2_abatement_tons_yr': co2AbatementTonsYr,
        'repowering_priority': repoweringPriority,
      };
}

class HourlyWindForecastModel {
  final String hour;
  final double windSpeed100mMs;
  final double windDirectionDeg;
  final double expectedNetMw;
  final double cufPct;

  const HourlyWindForecastModel({
    required this.hour,
    required this.windSpeed100mMs,
    required this.windDirectionDeg,
    required this.expectedNetMw,
    required this.cufPct,
  });

  factory HourlyWindForecastModel.fromJson(Map<String, dynamic> json) {
    return HourlyWindForecastModel(
      hour: json['hour']?.toString() ?? '12:00',
      windSpeed100mMs: (json['wind_speed_100m_ms'] as num?)?.toDouble() ?? 8.5,
      windDirectionDeg: (json['wind_direction_deg'] as num?)?.toDouble() ?? 245.0,
      expectedNetMw: (json['expected_net_mw'] as num?)?.toDouble() ?? 42.0,
      cufPct: (json['cuf_pct'] as num?)?.toDouble() ?? 42.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'hour': hour,
        'wind_speed_100m_ms': windSpeed100mMs,
        'wind_direction_deg': windDirectionDeg,
        'expected_net_mw': expectedNetMw,
        'cuf_pct': cufPct,
      };
}

class WindParkCorridorModel {
  final String corridorId;
  final String corridorName;
  final String state;
  final double installedCapacityMw;
  final double latitude;
  final double longitude;
  final double elevationM;
  final double terrainRoughnessAlpha;
  final String resourceTier;
  final double surfaceWind10mMs;
  final double surfaceWindDirDeg;
  final AtmosphericAirDensityProfileModel airDensity;
  final WeibullParametersModel weibull;
  final List<HubHeightWindVectorModel> hubHeightProfiles;
  final List<TurbineGenerationProfileModel> turbineProfiles;
  final RepoweringPotentialModel repowering;
  final List<HourlyWindForecastModel> hourlyForecast;

  const WindParkCorridorModel({
    required this.corridorId,
    required this.corridorName,
    required this.state,
    required this.installedCapacityMw,
    required this.latitude,
    required this.longitude,
    required this.elevationM,
    required this.terrainRoughnessAlpha,
    required this.resourceTier,
    required this.surfaceWind10mMs,
    required this.surfaceWindDirDeg,
    required this.airDensity,
    required this.weibull,
    required this.hubHeightProfiles,
    required this.turbineProfiles,
    required this.repowering,
    required this.hourlyForecast,
  });

  factory WindParkCorridorModel.fromJson(Map<String, dynamic> json) {
    return WindParkCorridorModel(
      corridorId: json['corridor_id']?.toString() ?? 'muppandal_tamil_nadu',
      corridorName: json['corridor_name']?.toString() ?? 'Muppandal Wind Farm',
      state: json['state']?.toString() ?? 'Tamil Nadu',
      installedCapacityMw: (json['installed_capacity_mw'] as num?)?.toDouble() ?? 1500.0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 8.2433,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 77.5456,
      elevationM: (json['elevation_m'] as num?)?.toDouble() ?? 75.0,
      terrainRoughnessAlpha: (json['terrain_roughness_alpha'] as num?)?.toDouble() ?? 0.20,
      resourceTier: json['resource_tier']?.toString() ?? 'EXCELLENT',
      surfaceWind10mMs: (json['surface_wind_10m_ms'] as num?)?.toDouble() ?? 6.4,
      surfaceWindDirDeg: (json['surface_wind_dir_deg'] as num?)?.toDouble() ?? 245.0,
      airDensity: AtmosphericAirDensityProfileModel.fromJson(
          json['air_density'] as Map<String, dynamic>? ?? {}),
      weibull: WeibullParametersModel.fromJson(
          json['weibull'] as Map<String, dynamic>? ?? {}),
      hubHeightProfiles: (json['hub_height_profiles'] as List<dynamic>?)
              ?.map((e) => HubHeightWindVectorModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      turbineProfiles: (json['turbine_profiles'] as List<dynamic>?)
              ?.map((e) => TurbineGenerationProfileModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      repowering: RepoweringPotentialModel.fromJson(
          json['repowering'] as Map<String, dynamic>? ?? {}),
      hourlyForecast: (json['hourly_forecast'] as List<dynamic>?)
              ?.map((e) => HourlyWindForecastModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'corridor_id': corridorId,
        'corridor_name': corridorName,
        'state': state,
        'installed_capacity_mw': installedCapacityMw,
        'latitude': latitude,
        'longitude': longitude,
        'elevation_m': elevationM,
        'terrain_roughness_alpha': terrainRoughnessAlpha,
        'resource_tier': resourceTier,
        'surface_wind_10m_ms': surfaceWind10mMs,
        'surface_wind_dir_deg': surfaceWindDirDeg,
        'air_density': airDensity.toJson(),
        'weibull': weibull.toJson(),
        'hub_height_profiles': hubHeightProfiles.map((e) => e.toJson()).toList(),
        'turbine_profiles': turbineProfiles.map((e) => e.toJson()).toList(),
        'repowering': repowering.toJson(),
        'hourly_forecast': hourlyForecast.map((e) => e.toJson()).toList(),
      };
}

class CorridorSummaryModel {
  final String corridorId;
  final String corridorName;
  final String state;
  final double installedCapacityMw;
  final String resourceTier;
  final double referenceSpeed100mMs;
  final double referenceWpd100mWm2;
  final double cufPct;

  const CorridorSummaryModel({
    required this.corridorId,
    required this.corridorName,
    required this.state,
    required this.installedCapacityMw,
    required this.resourceTier,
    required this.referenceSpeed100mMs,
    required this.referenceWpd100mWm2,
    required this.cufPct,
  });

  factory CorridorSummaryModel.fromJson(Map<String, dynamic> json) {
    return CorridorSummaryModel(
      corridorId: json['corridor_id']?.toString() ?? '',
      corridorName: json['corridor_name']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      installedCapacityMw: (json['installed_capacity_mw'] as num?)?.toDouble() ?? 0.0,
      resourceTier: json['resource_tier']?.toString() ?? 'GOOD',
      referenceSpeed100mMs: (json['reference_speed_100m_ms'] as num?)?.toDouble() ?? 0.0,
      referenceWpd100mWm2: (json['reference_wpd_100m_wm2'] as num?)?.toDouble() ?? 0.0,
      cufPct: (json['cuf_pct'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'corridor_id': corridorId,
        'corridor_name': corridorName,
        'state': state,
        'installed_capacity_mw': installedCapacityMw,
        'resource_tier': resourceTier,
        'reference_speed_100m_ms': referenceSpeed100mMs,
        'reference_wpd_100m_wm2': referenceWpd100mWm2,
        'cuf_pct': cufPct,
      };
}

class WindEnergyResponseModel {
  final WindParkCorridorModel selectedCorridor;
  final List<CorridorSummaryModel> allCorridors;
  final Map<String, String> bulletins;
  final bool offlineCached;
  final String generatedAt;

  const WindEnergyResponseModel({
    required this.selectedCorridor,
    required this.allCorridors,
    required this.bulletins,
    required this.offlineCached,
    required this.generatedAt,
  });

  factory WindEnergyResponseModel.fromJson(Map<String, dynamic> json) {
    return WindEnergyResponseModel(
      selectedCorridor: WindParkCorridorModel.fromJson(
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

  factory WindEnergyResponseModel.defaultFallback() {
    const hubProfiles = [
      HubHeightWindVectorModel(
        heightM: 10,
        windSpeedMs: 6.4,
        windSpeedKmh: 23.0,
        windPowerDensityWm2: 153.2,
        windDirectionDeg: 245.0,
        cardinalDirection: 'WSW',
        resourceTier: 'POOR',
      ),
      HubHeightWindVectorModel(
        heightM: 50,
        windSpeedMs: 8.83,
        windSpeedKmh: 31.8,
        windPowerDensityWm2: 396.4,
        windDirectionDeg: 247.0,
        cardinalDirection: 'WSW',
        resourceTier: 'GOOD',
      ),
      HubHeightWindVectorModel(
        heightM: 80,
        windSpeedMs: 9.7,
        windSpeedKmh: 34.9,
        windPowerDensityWm2: 521.6,
        windDirectionDeg: 248.5,
        cardinalDirection: 'WSW',
        resourceTier: 'OUTSTANDING',
      ),
      HubHeightWindVectorModel(
        heightM: 100,
        windSpeedMs: 10.15,
        windSpeedKmh: 36.5,
        windPowerDensityWm2: 597.4,
        windDirectionDeg: 249.5,
        cardinalDirection: 'WSW',
        resourceTier: 'OUTSTANDING',
      ),
      HubHeightWindVectorModel(
        heightM: 120,
        windSpeedMs: 10.52,
        windSpeedKmh: 37.9,
        windPowerDensityWm2: 665.2,
        windDirectionDeg: 250.5,
        cardinalDirection: 'WSW',
        resourceTier: 'OUTSTANDING',
      ),
      HubHeightWindVectorModel(
        heightM: 140,
        windSpeedMs: 10.85,
        windSpeedKmh: 39.1,
        windPowerDensityWm2: 730.0,
        windDirectionDeg: 251.5,
        cardinalDirection: 'WSW',
        resourceTier: 'OUTSTANDING',
      ),
      HubHeightWindVectorModel(
        heightM: 150,
        windSpeedMs: 11.0,
        windSpeedKmh: 39.6,
        windPowerDensityWm2: 760.8,
        windDirectionDeg: 252.0,
        cardinalDirection: 'WSW',
        resourceTier: 'OUTSTANDING',
      ),
    ];

    const turbProfiles = [
      TurbineGenerationProfileModel(
        modelName: 'Standard Utility 2.0 MW Class (Rotor 100m)',
        ratedPowerMw: 2.0,
        rotorDiameterM: 100.0,
        hubHeightM: 100,
        cutInSpeedMs: 3.0,
        ratedSpeedMs: 11.5,
        cutOutSpeedMs: 25.0,
        operatingState: 'PARTIAL_LOAD_RAMP',
        grossHourlyOutputMw: 1.34,
        wakeLossPct: 7.5,
        bopElectricalLossPct: 3.0,
        bladeSoilingLossPct: 1.5,
        netHourlyOutputMw: 1.18,
        dailyGenerationMwh: 28.32,
        capacityUtilizationFactorPct: 59.0,
      ),
      TurbineGenerationProfileModel(
        modelName: 'Next-Gen Low-Wind 3.0 MW Class (Rotor 140m)',
        ratedPowerMw: 3.0,
        rotorDiameterM: 140.0,
        hubHeightM: 140,
        cutInSpeedMs: 2.8,
        ratedSpeedMs: 10.5,
        cutOutSpeedMs: 25.0,
        operatingState: 'RATED_FULL_LOAD',
        grossHourlyOutputMw: 3.0,
        wakeLossPct: 7.1,
        bopElectricalLossPct: 3.0,
        bladeSoilingLossPct: 1.5,
        netHourlyOutputMw: 2.66,
        dailyGenerationMwh: 63.84,
        capacityUtilizationFactorPct: 88.7,
      ),
    ];

    final corridor = WindParkCorridorModel(
      corridorId: 'muppandal_tamil_nadu',
      corridorName: 'Muppandal Wind Farm (Kanyakumari / Tirunelveli)',
      state: 'Tamil Nadu',
      installedCapacityMw: 1500.0,
      latitude: 8.2433,
      longitude: 77.5456,
      elevationM: 75.0,
      terrainRoughnessAlpha: 0.20,
      resourceTier: 'OUTSTANDING',
      surfaceWind10mMs: 6.4,
      surfaceWindDirDeg: 245.0,
      airDensity: const AtmosphericAirDensityProfileModel(
        surfaceTemperatureC: 29.5,
        surfacePressureHpa: 1008.0,
        airDensityKgm3: 1.157,
        standardDensityKgm3: 1.225,
        densityRatio: 0.945,
        thermalDeratingNote:
            'Moderate thermal air thinning, resulting in 5.5% aerodynamic derating vs ISO standard.',
      ),
      weibull: const WeibullParametersModel(
        shapeK: 2.25,
        scaleCMs: 8.2,
        annualMeanSpeedMs: 7.3,
      ),
      hubHeightProfiles: hubProfiles,
      turbineProfiles: turbProfiles,
      repowering: const RepoweringPotentialModel(
        legacyTurbineRatingKw: 400.0,
        modernTurbineRatingMw: 3.0,
        energyYieldMultiplier: 3.2,
        co2AbatementTonsYr: 4500.0,
        repoweringPriority: 'HIGH',
      ),
      hourlyForecast: List.generate(
        24,
        (i) => HourlyWindForecastModel(
          hour: '${i.toString().padLeft(2, '0')}:00',
          windSpeed100mMs: 9.5 + (i % 4) * 0.4,
          windDirectionDeg: 245.0,
          expectedNetMw: 55.0 + (i % 5) * 5.0,
          cufPct: 55.0 + (i % 5) * 5.0,
        ),
      ),
    );

    const summaries = [
      CorridorSummaryModel(
        corridorId: 'muppandal_tamil_nadu',
        corridorName: 'Muppandal Wind Farm (Kanyakumari / Tirunelveli)',
        state: 'Tamil Nadu',
        installedCapacityMw: 1500.0,
        resourceTier: 'OUTSTANDING',
        referenceSpeed100mMs: 10.15,
        referenceWpd100mWm2: 597.4,
        cufPct: 42.5,
      ),
      CorridorSummaryModel(
        corridorId: 'jaisalmer_rajasthan',
        corridorName: 'Jaisalmer Wind Park (Thar Desert)',
        state: 'Rajasthan',
        installedCapacityMw: 1064.0,
        resourceTier: 'GOOD',
        referenceSpeed100mMs: 8.38,
        referenceWpd100mWm2: 325.0,
        cufPct: 31.0,
      ),
      CorridorSummaryModel(
        corridorId: 'brahmanvel_maharashtra',
        corridorName: 'Brahmanvel Wind Farm (Dhule / Nandurbar Ridge)',
        state: 'Maharashtra',
        installedCapacityMw: 528.0,
        resourceTier: 'MODERATE',
        referenceSpeed100mMs: 8.68,
        referenceWpd100mWm2: 345.0,
        cufPct: 33.0,
      ),
      CorridorSummaryModel(
        corridorId: 'damanjodi_odisha',
        corridorName: 'Damanjodi Wind Corridor (Koraput Hilltop)',
        state: 'Odisha',
        installedCapacityMw: 99.0,
        resourceTier: 'GOOD',
        referenceSpeed100mMs: 8.96,
        referenceWpd100mWm2: 365.0,
        cufPct: 34.5,
      ),
      CorridorSummaryModel(
        corridorId: 'kayathar_tamil_nadu',
        corridorName: 'Kayathar Wind Corridor (NIWE Test Station, Thoothukudi)',
        state: 'Tamil Nadu',
        installedCapacityMw: 300.0,
        resourceTier: 'EXCELLENT',
        referenceSpeed100mMs: 9.23,
        referenceWpd100mWm2: 440.0,
        cufPct: 38.0,
      ),
      CorridorSummaryModel(
        corridorId: 'kutch_gujarat',
        corridorName: 'Kutch Wind Corridor (Janki / Mandvi / Bhuj Coastal Belt)',
        state: 'Gujarat',
        installedCapacityMw: 1100.0,
        resourceTier: 'GOOD',
        referenceSpeed100mMs: 8.14,
        referenceWpd100mWm2: 310.0,
        cufPct: 29.5,
      ),
      CorridorSummaryModel(
        corridorId: 'chitradurga_karnataka',
        corridorName: 'Chitradurga Wind Park (Central Deccan Ridge)',
        state: 'Karnataka',
        installedCapacityMw: 400.0,
        resourceTier: 'MODERATE',
        referenceSpeed100mMs: 8.52,
        referenceWpd100mWm2: 330.0,
        cufPct: 31.5,
      ),
    ];

    const bulletins = {
      'en':
          'NIWE-IMD WIND BULLETIN for Muppandal Wind Farm: 100m hub wind speed at 10.15 m/s (WSW), yielding 597.4 W/m² (Resource: OUTSTANDING). Projected plant Capacity Utilization Factor (CUF) is 88.7%. Turbine operating status: RATED_FULL_LOAD. Grid dispatch is optimal.',
      'ta':
          'தேசிய காற்று ஆற்றல் நிறுவனம் (NIWE) & IMD அறிக்கை - Muppandal Wind Farm: 100 மீட்டர் உயரக் காற்றில் வேகம் 10.15 மீ/வி (WSW), காற்று சக்தி அடர்த்தி 597.4 W/m² (OUTSTANDING தரம்). எதிர்பார்க்கப்படும் ஆலை பயன்பாட்டுக் காரணி (CUF) 88.7%. காற்றாலை மின் உற்பத்தி சீராக உள்ளது.',
      'hi':
          'एनआईडब्ल्यूई-आईएमडी पवन ऊर्जा बुलेटिन - Muppandal Wind Farm: 100 मीटर हब ऊंचाई पर वायु गति 10.15 मी/से (WSW), पवन ऊर्जा घनत्व 597.4 W/m² (OUTSTANDING श्रेणी)। अनुमानित संयंत्र क्षमता उपयोग कारक (CUF) 88.7% है। ग्रिड प्रेषण अनुकूल स्थिति में है।',
      'gu':
          'NIWE-IMD પવન ઊર્જા બુલેટિન - Muppandal Wind Farm: 100 મીટર હબ ઊંચાઈએ પવન ગતિ 10.15 મી/સે (WSW), પવન શક્તિ ઘનતા 597.4 W/m² (OUTSTANDING વર્ગ). પ્લાન્ટ ક્ષમતા ઉપયોગ પરિબળ (CUF) 88.7% છે. વીજ ઉત્પાદન ઉત્તમ છે.',
      'mr':
          'NIWE-IMD पवन ऊर्जा बुलेटिन - Muppandal Wind Farm: 100 मीटर हब उंचीवर हवेचा वेग 10.15 मी/से (WSW), पवन ऊर्जा घनता 597.4 W/m² (OUTSTANDING दर्जा). अपेक्षित क्षमता वापर घटक (CUF) 88.7% आहे. पवनचक्की वीज निर्मिती सुरळीत सुरू आहे.',
      'kn':
          'ರಾಷ್ಟ್ರೀಯ ಪವನ ಶಕ್ತಿ ಸಂಸ್ಥೆ (NIWE) & IMD ವರದಿ - Muppandal Wind Farm: 100 ಮೀಟರ್ ಎತ್ತರದ ಹಬ್ ವೇಗ 10.15 ಮೀ/ಸೆ (WSW), ಪವನ ಶಕ್ತಿ ಸಾಂದ್ರತೆ 597.4 W/m² (OUTSTANDING ದರ್ಜೆ). ನಿರೀಕ್ಷಿತ ಘಟಕ ಸಾಮರ್ಥ್ಯ ಬಳಕೆಯ ಅಂಶ (CUF) 88.7%. ಗ್ರಿಡ್ ವಿದ್ಯುತ್ ಉತ್ಪಾದನೆ ಸುಸ್ಥಿತಿಯಲ್ಲಿದೆ.',
      'od':
          'NIWE-IMD ପବନ ଶକ୍ତି ବୁଲେଟିନ୍ - Muppandal Wind Farm: 100 ମିଟର ଉଚ୍ଚତାରେ ପବନର ବେଗ 10.15 ମି/ସେ (WSW), ପବନ ଶକ୍ତି ଘନତା 597.4 W/m² (OUTSTANDING ଶ୍ରେଣୀ). ଆନୁମାନିକ କ୍ଷମତା ଉପଯୋଗ କାରକ (CUF) 88.7% ଅଟେ । ଗ୍ରୀଡ୍ ଉତ୍ପାଦନ ସନ୍ତୋଷଜନକ ଅଛି ।',
    };

    return WindEnergyResponseModel(
      selectedCorridor: corridor,
      allCorridors: summaries,
      bulletins: bulletins,
      offlineCached: true,
      generatedAt: DateTime.now().toUtc().toIso8601String(),
    );
  }
}
