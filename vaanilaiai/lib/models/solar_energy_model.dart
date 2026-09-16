class SolarIrradianceComponentsModel {
  final double ghiWm2;
  final double dniWm2;
  final double dhiWm2;
  final double solarZenithAngleDeg;
  final double clearnessIndexKt;
  final double cloudAttenuationPct;

  const SolarIrradianceComponentsModel({
    required this.ghiWm2,
    required this.dniWm2,
    required this.dhiWm2,
    required this.solarZenithAngleDeg,
    required this.clearnessIndexKt,
    required this.cloudAttenuationPct,
  });

  factory SolarIrradianceComponentsModel.fromJson(Map<String, dynamic> json) {
    return SolarIrradianceComponentsModel(
      ghiWm2: (json['ghi_wm2'] as num?)?.toDouble() ?? 800.0,
      dniWm2: (json['dni_wm2'] as num?)?.toDouble() ?? 700.0,
      dhiWm2: (json['dhi_wm2'] as num?)?.toDouble() ?? 150.0,
      solarZenithAngleDeg: (json['solar_zenith_angle_deg'] as num?)?.toDouble() ?? 25.0,
      clearnessIndexKt: (json['clearness_index_kt'] as num?)?.toDouble() ?? 0.70,
      cloudAttenuationPct: (json['cloud_attenuation_pct'] as num?)?.toDouble() ?? 5.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'ghi_wm2': ghiWm2,
        'dni_wm2': dniWm2,
        'dhi_wm2': dhiWm2,
        'solar_zenith_angle_deg': solarZenithAngleDeg,
        'clearness_index_kt': clearnessIndexKt,
        'cloud_attenuation_pct': cloudAttenuationPct,
      };
}

class PhotovoltaicPerformanceModel {
  final double ambientTemperatureC;
  final double pvCellTemperatureC;
  final double temperatureDeratingPct;
  final double performanceRatioPct;
  final double specificYieldKwhPerKwp;

  const PhotovoltaicPerformanceModel({
    required this.ambientTemperatureC,
    required this.pvCellTemperatureC,
    required this.temperatureDeratingPct,
    required this.performanceRatioPct,
    required this.specificYieldKwhPerKwp,
  });

  factory PhotovoltaicPerformanceModel.fromJson(Map<String, dynamic> json) {
    return PhotovoltaicPerformanceModel(
      ambientTemperatureC: (json['ambient_temperature_c'] as num?)?.toDouble() ?? 35.0,
      pvCellTemperatureC: (json['pv_cell_temperature_c'] as num?)?.toDouble() ?? 55.0,
      temperatureDeratingPct: (json['temperature_derating_pct'] as num?)?.toDouble() ?? -11.4,
      performanceRatioPct: (json['performance_ratio_pct'] as num?)?.toDouble() ?? 80.0,
      specificYieldKwhPerKwp: (json['specific_yield_kwh_per_kwp'] as num?)?.toDouble() ?? 5.4,
    );
  }

  Map<String, dynamic> toJson() => {
        'ambient_temperature_c': ambientTemperatureC,
        'pv_cell_temperature_c': pvCellTemperatureC,
        'temperature_derating_pct': temperatureDeratingPct,
        'performance_ratio_pct': performanceRatioPct,
        'specific_yield_kwh_per_kwp': specificYieldKwhPerKwp,
      };
}

class SoilingAndCleaningAdvisoryModel {
  final double soilingLossPct;
  final bool cleaningRecommended;
  final String cleaningUrgency;
  final String nextRainWashoutForecast;
  final String optimalCleaningWindow;

  const SoilingAndCleaningAdvisoryModel({
    required this.soilingLossPct,
    required this.cleaningRecommended,
    required this.cleaningUrgency,
    required this.nextRainWashoutForecast,
    required this.optimalCleaningWindow,
  });

  factory SoilingAndCleaningAdvisoryModel.fromJson(Map<String, dynamic> json) {
    return SoilingAndCleaningAdvisoryModel(
      soilingLossPct: (json['soiling_loss_pct'] as num?)?.toDouble() ?? 8.0,
      cleaningRecommended: json['cleaning_recommended'] as bool? ?? false,
      cleaningUrgency: json['cleaning_urgency']?.toString() ?? 'ROUTINE',
      nextRainWashoutForecast: json['next_rain_washout_forecast']?.toString() ?? 'No rain expected in 48h.',
      optimalCleaningWindow: json['optimal_cleaning_window']?.toString() ?? 'Early dawn (05:30 - 06:45 IST).',
    );
  }

  Map<String, dynamic> toJson() => {
        'soiling_loss_pct': soilingLossPct,
        'cleaning_recommended': cleaningRecommended,
        'cleaning_urgency': cleaningUrgency,
        'next_rain_washout_forecast': nextRainWashoutForecast,
        'optimal_cleaning_window': optimalCleaningWindow,
      };
}

class HourlySolarForecastModel {
  final String hour;
  final double ghiWm2;
  final double cellTemperatureC;
  final double estimatedGenerationKwhPerKwp;

  const HourlySolarForecastModel({
    required this.hour,
    required this.ghiWm2,
    required this.cellTemperatureC,
    required this.estimatedGenerationKwhPerKwp,
  });

  factory HourlySolarForecastModel.fromJson(Map<String, dynamic> json) {
    return HourlySolarForecastModel(
      hour: json['hour']?.toString() ?? '12:00',
      ghiWm2: (json['ghi_wm2'] as num?)?.toDouble() ?? 800.0,
      cellTemperatureC: (json['cell_temperature_c'] as num?)?.toDouble() ?? 50.0,
      estimatedGenerationKwhPerKwp: (json['estimated_generation_kwh_per_kwp'] as num?)?.toDouble() ?? 0.75,
    );
  }

  Map<String, dynamic> toJson() => {
        'hour': hour,
        'ghi_wm2': ghiWm2,
        'cell_temperature_c': cellTemperatureC,
        'estimated_generation_kwh_per_kwp': estimatedGenerationKwhPerKwp,
      };
}

class RooftopCapacityMetricsModel {
  final double capacityKwp;
  final double dailyGenerationKwh;
  final double monthlyGenerationKwh;
  final double monthlySavingsInr;
  final double co2OffsetKgPerMonth;

  const RooftopCapacityMetricsModel({
    required this.capacityKwp,
    required this.dailyGenerationKwh,
    required this.monthlyGenerationKwh,
    required this.monthlySavingsInr,
    required this.co2OffsetKgPerMonth,
  });

  factory RooftopCapacityMetricsModel.fromJson(Map<String, dynamic> json) {
    return RooftopCapacityMetricsModel(
      capacityKwp: (json['capacity_kwp'] as num?)?.toDouble() ?? 3.0,
      dailyGenerationKwh: (json['daily_generation_kwh'] as num?)?.toDouble() ?? 16.2,
      monthlyGenerationKwh: (json['monthly_generation_kwh'] as num?)?.toDouble() ?? 486.0,
      monthlySavingsInr: (json['monthly_savings_inr'] as num?)?.toDouble() ?? 3500.0,
      co2OffsetKgPerMonth: (json['co2_offset_kg_per_month'] as num?)?.toDouble() ?? 398.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'capacity_kwp': capacityKwp,
        'daily_generation_kwh': dailyGenerationKwh,
        'monthly_generation_kwh': monthlyGenerationKwh,
        'monthly_savings_inr': monthlySavingsInr,
        'co2_offset_kg_per_month': co2OffsetKgPerMonth,
      };
}

class SolarParkSectorModel {
  final String parkId;
  final String parkName;
  final String state;
  final double installedCapacityMw;
  final double latitude;
  final double longitude;
  final String radiationTier;
  final SolarIrradianceComponentsModel irradiance;
  final PhotovoltaicPerformanceModel pvPerformance;
  final SoilingAndCleaningAdvisoryModel soilingAdvisory;
  final List<RooftopCapacityMetricsModel> rooftopEconomics;
  final List<HourlySolarForecastModel> hourlyForecast;
  final Map<String, String> vernacularBulletins;

  const SolarParkSectorModel({
    required this.parkId,
    required this.parkName,
    required this.state,
    required this.installedCapacityMw,
    required this.latitude,
    required this.longitude,
    required this.radiationTier,
    required this.irradiance,
    required this.pvPerformance,
    required this.soilingAdvisory,
    required this.rooftopEconomics,
    required this.hourlyForecast,
    required this.vernacularBulletins,
  });

  factory SolarParkSectorModel.fromJson(Map<String, dynamic> json) {
    return SolarParkSectorModel(
      parkId: json['park_id']?.toString() ?? 'bhadla_rajasthan',
      parkName: json['park_name']?.toString() ?? 'Bhadla Mega Solar Park',
      state: json['state']?.toString() ?? 'Rajasthan',
      installedCapacityMw: (json['installed_capacity_mw'] as num?)?.toDouble() ?? 2245.0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 27.5386,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 71.9174,
      radiationTier: json['radiation_tier']?.toString() ?? 'EXCELLENT',
      irradiance: json['irradiance'] != null
          ? SolarIrradianceComponentsModel.fromJson(json['irradiance'] as Map<String, dynamic>)
          : const SolarIrradianceComponentsModel(
              ghiWm2: 950.0,
              dniWm2: 850.0,
              dhiWm2: 150.0,
              solarZenithAngleDeg: 23.0,
              clearnessIndexKt: 0.72,
              cloudAttenuationPct: 3.0,
            ),
      pvPerformance: json['pv_performance'] != null
          ? PhotovoltaicPerformanceModel.fromJson(json['pv_performance'] as Map<String, dynamic>)
          : const PhotovoltaicPerformanceModel(
              ambientTemperatureC: 38.0,
              pvCellTemperatureC: 58.0,
              temperatureDeratingPct: -12.5,
              performanceRatioPct: 80.0,
              specificYieldKwhPerKwp: 5.6,
            ),
      soilingAdvisory: json['soiling_advisory'] != null
          ? SoilingAndCleaningAdvisoryModel.fromJson(json['soiling_advisory'] as Map<String, dynamic>)
          : const SoilingAndCleaningAdvisoryModel(
              soilingLossPct: 8.5,
              cleaningRecommended: false,
              cleaningUrgency: 'ROUTINE',
              nextRainWashoutForecast: 'Dry spell continuing.',
              optimalCleaningWindow: 'Dawn (05:30 - 06:45 IST)',
            ),
      rooftopEconomics: (json['rooftop_economics'] as List<dynamic>?)
              ?.map((e) => RooftopCapacityMetricsModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hourlyForecast: (json['hourly_forecast'] as List<dynamic>?)
              ?.map((e) => HourlySolarForecastModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      vernacularBulletins: (json['vernacular_bulletins'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() => {
        'park_id': parkId,
        'park_name': parkName,
        'state': state,
        'installed_capacity_mw': installedCapacityMw,
        'latitude': latitude,
        'longitude': longitude,
        'radiation_tier': radiationTier,
        'irradiance': irradiance.toJson(),
        'pv_performance': pvPerformance.toJson(),
        'soiling_advisory': soilingAdvisory.toJson(),
        'rooftop_economics': rooftopEconomics.map((e) => e.toJson()).toList(),
        'hourly_forecast': hourlyForecast.map((e) => e.toJson()).toList(),
        'vernacular_bulletins': vernacularBulletins,
      };
}

class SolarEnergyResponseModel {
  final String timestamp;
  final String bulletinNumber;
  final String provenance;
  final String nationalSolarOverview;
  final SolarParkSectorModel selectedSector;
  final List<SolarParkSectorModel> allSectors;
  final String solarPhysicsModel;
  final Map<String, String> vernacularBulletins;
  final bool isOfflineCached;

  const SolarEnergyResponseModel({
    required this.timestamp,
    required this.bulletinNumber,
    required this.provenance,
    required this.nationalSolarOverview,
    required this.selectedSector,
    required this.allSectors,
    required this.solarPhysicsModel,
    required this.vernacularBulletins,
    this.isOfflineCached = false,
  });

  factory SolarEnergyResponseModel.fromJson(
    Map<String, dynamic> json, {
    bool isOffline = false,
  }) {
    return SolarEnergyResponseModel(
      timestamp: json['timestamp']?.toString() ?? '2026-09-12T06:00:00Z',
      bulletinNumber: json['bulletin_number']?.toString() ?? 'NISE-IMD/SOLAR-PV/2026-DEFAULT',
      provenance: json['provenance']?.toString() ??
          'National Institute of Solar Energy (NISE), MNRE & IMD Solar Radiation Network',
      nationalSolarOverview: json['national_solar_overview']?.toString() ??
          'HIGH-YIELD SOLAR REGIME: Strong pre-monsoon radiation persisting across major solar corridors.',
      selectedSector: json['selected_sector'] != null
          ? SolarParkSectorModel.fromJson(json['selected_sector'] as Map<String, dynamic>)
          : defaultFallback().selectedSector,
      allSectors: (json['all_sectors'] as List<dynamic>?)
              ?.map((e) => SolarParkSectorModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      solarPhysicsModel: json['solar_physics_model']?.toString() ??
          'Perez Diffuse Model; Sandia PV Cell Formula; Silicon Derating',
      vernacularBulletins: (json['vernacular_bulletins'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          {},
      isOfflineCached: isOffline || (json['is_offline_cached'] as bool? ?? false),
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'bulletin_number': bulletinNumber,
        'provenance': provenance,
        'national_solar_overview': nationalSolarOverview,
        'selected_sector': selectedSector.toJson(),
        'all_sectors': allSectors.map((e) => e.toJson()).toList(),
        'solar_physics_model': solarPhysicsModel,
        'vernacular_bulletins': vernacularBulletins,
        'is_offline_cached': isOfflineCached,
      };

  static SolarEnergyResponseModel defaultFallback() {
    const bhadlaSector = SolarParkSectorModel(
      parkId: 'bhadla_rajasthan',
      parkName: 'Bhadla Mega Solar Park (Phalodi)',
      state: 'Rajasthan',
      installedCapacityMw: 2245.0,
      latitude: 27.5386,
      longitude: 71.9174,
      radiationTier: 'EXCELLENT',
      irradiance: SolarIrradianceComponentsModel(
        ghiWm2: 985.0,
        dniWm2: 890.0,
        dhiWm2: 145.0,
        solarZenithAngleDeg: 22.4,
        clearnessIndexKt: 0.74,
        cloudAttenuationPct: 2.5,
      ),
      pvPerformance: PhotovoltaicPerformanceModel(
        ambientTemperatureC: 41.5,
        pvCellTemperatureC: 62.4,
        temperatureDeratingPct: -14.2,
        performanceRatioPct: 79.5,
        specificYieldKwhPerKwp: 5.85,
      ),
      soilingAdvisory: SoilingAndCleaningAdvisoryModel(
        soilingLossPct: 12.8,
        cleaningRecommended: true,
        cleaningUrgency: 'URGENT_CLEANING_REQUIRED',
        nextRainWashoutForecast: 'No precipitation expected in 7 days. Dry arid conditions active.',
        optimalCleaningWindow: 'Early dawn (05:00 - 06:30 IST) before thermal shock risk.',
      ),
      rooftopEconomics: [
        RooftopCapacityMetricsModel(
          capacityKwp: 1.0,
          dailyGenerationKwh: 5.85,
          monthlyGenerationKwh: 175.5,
          monthlySavingsInr: 1264.0,
          co2OffsetKgPerMonth: 143.9,
        ),
        RooftopCapacityMetricsModel(
          capacityKwp: 3.0,
          dailyGenerationKwh: 17.55,
          monthlyGenerationKwh: 526.5,
          monthlySavingsInr: 3791.0,
          co2OffsetKgPerMonth: 431.7,
        ),
        RooftopCapacityMetricsModel(
          capacityKwp: 5.0,
          dailyGenerationKwh: 29.25,
          monthlyGenerationKwh: 877.5,
          monthlySavingsInr: 6318.0,
          co2OffsetKgPerMonth: 719.6,
        ),
        RooftopCapacityMetricsModel(
          capacityKwp: 10.0,
          dailyGenerationKwh: 58.50,
          monthlyGenerationKwh: 1755.0,
          monthlySavingsInr: 12636.0,
          co2OffsetKgPerMonth: 1439.1,
        ),
      ],
      hourlyForecast: [
        HourlySolarForecastModel(hour: '06:00', ghiWm2: 78.8, cellTemperatureC: 26.0, estimatedGenerationKwhPerKwp: 0.06),
        HourlySolarForecastModel(hour: '08:00', ghiWm2: 443.3, cellTemperatureC: 32.0, estimatedGenerationKwhPerKwp: 0.35),
        HourlySolarForecastModel(hour: '10:00', ghiWm2: 837.3, cellTemperatureC: 45.0, estimatedGenerationKwhPerKwp: 0.66),
        HourlySolarForecastModel(hour: '12:00', ghiWm2: 985.0, cellTemperatureC: 56.0, estimatedGenerationKwhPerKwp: 0.78),
        HourlySolarForecastModel(hour: '14:00', ghiWm2: 866.8, cellTemperatureC: 55.0, estimatedGenerationKwhPerKwp: 0.69),
        HourlySolarForecastModel(hour: '16:00', ghiWm2: 492.5, cellTemperatureC: 42.0, estimatedGenerationKwhPerKwp: 0.39),
        HourlySolarForecastModel(hour: '18:00', ghiWm2: 78.8, cellTemperatureC: 30.0, estimatedGenerationKwhPerKwp: 0.06),
      ],
      vernacularBulletins: {
        'en': 'NISE/IMD SOLAR FORECAST: Bhadla Solar Park operating at EXCELLENT irradiance (985 W/m²). High cell temperature (62.4°C) causing 14.2% thermal derating. Desert dust deposition (12.8% loss). Urgent panel cleaning recommended at dawn.',
        'hi': 'एनआईएसई/आईएमडी सौर पूर्वानुमान: भडला सोलर पार्क में उत्कृष्ट विकिरण (985 W/m²)। उच्च सेल तापमान (62.4°C) के कारण 14.2% थर्मल हानि। 12.8% धूल जमाव — सुबह जल्दी सोलर पैनल धोने की सलाह दी जाती है।',
      },
    );

    return const SolarEnergyResponseModel(
      timestamp: '2026-09-12T06:00:00Z',
      bulletinNumber: 'NISE-IMD/SOLAR-PV/20260912-BHADLA',
      provenance: 'National Institute of Solar Energy (NISE), MNRE & IMD Solar Radiation Network',
      nationalSolarOverview:
          'HIGH-YIELD SOLAR REGIME: Strong clear-sky radiation persisting across Western Thar and Deccan Plateau with peak GHI exceeding 950 W/m².',
      selectedSector: bhadlaSector,
      allSectors: [bhadlaSector],
      solarPhysicsModel:
          'Perez Diffuse Model; Sandia PV Cell Temperature Formula; Silicon Derating (γ = -0.38%/°C)',
      vernacularBulletins: {
        'en': 'NISE/IMD SOLAR FORECAST: Bhadla Solar Park operating at EXCELLENT irradiance (985 W/m²). High cell temperature (62.4°C) causing 14.2% thermal derating.',
        'hi': 'एनआईएसई/आईएमडी सौर पूर्वानुमान: भडला सोलर पार्क में उत्कृष्ट विकिरण (985 W/m²)। 14.2% थर्मल हानि।',
      },
      isOfflineCached: true,
    );
  }
}
