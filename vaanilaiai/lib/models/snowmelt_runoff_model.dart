// Models for IMD, CWC & DGRE Himalayan Snowmelt Runoff,
// Snow Cover Area (SCA) & Glacial Hydrology Engine (SNOWMELT-HYDRO).

class ElevationZonalBandModel {
  final String bandId;
  final String elevationRangeLabel;
  final double elevationMinM;
  final double elevationMaxM;
  final double zonalAreaSqKm;
  final double snowCoverAreaPct;
  final double meanTemperatureC;
  final double degreeDayFactorCmPerDegCDay;
  final double dailyMeltVolumeMcm;

  const ElevationZonalBandModel({
    required this.bandId,
    required this.elevationRangeLabel,
    required this.elevationMinM,
    required this.elevationMaxM,
    required this.zonalAreaSqKm,
    required this.snowCoverAreaPct,
    required this.meanTemperatureC,
    required this.degreeDayFactorCmPerDegCDay,
    required this.dailyMeltVolumeMcm,
  });

  factory ElevationZonalBandModel.fromJson(Map<String, dynamic> json) {
    return ElevationZonalBandModel(
      bandId: json['band_id'] as String? ?? 'ZONE_A',
      elevationRangeLabel:
          json['elevation_range_label'] as String? ?? 'Elevation Band',
      elevationMinM: (json['elevation_min_m'] as num?)?.toDouble() ?? 1500.0,
      elevationMaxM: (json['elevation_max_m'] as num?)?.toDouble() ?? 2500.0,
      zonalAreaSqKm: (json['zonal_area_sq_km'] as num?)?.toDouble() ?? 5000.0,
      snowCoverAreaPct:
          (json['snow_cover_area_pct'] as num?)?.toDouble() ?? 10.0,
      meanTemperatureC:
          (json['mean_temperature_c'] as num?)?.toDouble() ?? 12.0,
      degreeDayFactorCmPerDegCDay:
          (json['degree_day_factor_cm_per_deg_c_day'] as num?)?.toDouble() ??
              0.45,
      dailyMeltVolumeMcm:
          (json['daily_melt_volume_mcm'] as num?)?.toDouble() ?? 5.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'band_id': bandId,
        'elevation_range_label': elevationRangeLabel,
        'elevation_min_m': elevationMinM,
        'elevation_max_m': elevationMaxM,
        'zonal_area_sq_km': zonalAreaSqKm,
        'snow_cover_area_pct': snowCoverAreaPct,
        'mean_temperature_c': meanTemperatureC,
        'degree_day_factor_cm_per_deg_c_day': degreeDayFactorCmPerDegCDay,
        'daily_melt_volume_mcm': dailyMeltVolumeMcm,
      };
}

class SnowpackCryosphereTelemetryModel {
  final double snowLineAltitudeM;
  final double equilibriumLineAltitudeM;
  final double freezingLevelIsothermM;
  final double basinSnowWaterEquivalentMm;
  final double freshSnow24hCm;
  final double satelliteNdsiCoveragePct;

  const SnowpackCryosphereTelemetryModel({
    required this.snowLineAltitudeM,
    required this.equilibriumLineAltitudeM,
    required this.freezingLevelIsothermM,
    required this.basinSnowWaterEquivalentMm,
    required this.freshSnow24hCm,
    required this.satelliteNdsiCoveragePct,
  });

  factory SnowpackCryosphereTelemetryModel.fromJson(Map<String, dynamic> json) {
    return SnowpackCryosphereTelemetryModel(
      snowLineAltitudeM:
          (json['snow_line_altitude_m'] as num?)?.toDouble() ?? 3200.0,
      equilibriumLineAltitudeM:
          (json['equilibrium_line_altitude_m'] as num?)?.toDouble() ?? 4800.0,
      freezingLevelIsothermM:
          (json['freezing_level_isotherm_m'] as num?)?.toDouble() ?? 4500.0,
      basinSnowWaterEquivalentMm:
          (json['basin_snow_water_equivalent_mm'] as num?)?.toDouble() ?? 250.0,
      freshSnow24hCm: (json['fresh_snow_24h_cm'] as num?)?.toDouble() ?? 0.0,
      satelliteNdsiCoveragePct:
          (json['satellite_ndsi_coverage_pct'] as num?)?.toDouble() ?? 92.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'snow_line_altitude_m': snowLineAltitudeM,
        'equilibrium_line_altitude_m': equilibriumLineAltitudeM,
        'freezing_level_isotherm_m': freezingLevelIsothermM,
        'basin_snow_water_equivalent_mm': basinSnowWaterEquivalentMm,
        'fresh_snow_24h_cm': freshSnow24hCm,
        'satellite_ndsi_coverage_pct': satelliteNdsiCoveragePct,
      };
}

class CatchmentRunoffMetricsModel {
  final double dailyDischargeCumecs;
  final double snowmeltFractionPct;
  final double rainfallContributionPct;
  final double baseflowContributionPct;
  final String peakDiurnalHourIst;
  final double peakDiurnalDischargeCumecs;
  final double diurnalDischargeAmplitudePct;

  const CatchmentRunoffMetricsModel({
    required this.dailyDischargeCumecs,
    required this.snowmeltFractionPct,
    required this.rainfallContributionPct,
    required this.baseflowContributionPct,
    required this.peakDiurnalHourIst,
    required this.peakDiurnalDischargeCumecs,
    required this.diurnalDischargeAmplitudePct,
  });

  factory CatchmentRunoffMetricsModel.fromJson(Map<String, dynamic> json) {
    return CatchmentRunoffMetricsModel(
      dailyDischargeCumecs:
          (json['daily_discharge_cumecs'] as num?)?.toDouble() ?? 1000.0,
      snowmeltFractionPct:
          (json['snowmelt_fraction_pct'] as num?)?.toDouble() ?? 60.0,
      rainfallContributionPct:
          (json['rainfall_contribution_pct'] as num?)?.toDouble() ?? 20.0,
      baseflowContributionPct:
          (json['baseflow_contribution_pct'] as num?)?.toDouble() ?? 20.0,
      peakDiurnalHourIst:
          json['peak_diurnal_hour_ist'] as String? ?? '18:00 IST',
      peakDiurnalDischargeCumecs:
          (json['peak_diurnal_discharge_cumecs'] as num?)?.toDouble() ?? 1300.0,
      diurnalDischargeAmplitudePct:
          (json['diurnal_discharge_amplitude_pct'] as num?)?.toDouble() ?? 40.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'daily_discharge_cumecs': dailyDischargeCumecs,
        'snowmelt_fraction_pct': snowmeltFractionPct,
        'rainfall_contribution_pct': rainfallContributionPct,
        'baseflow_contribution_pct': baseflowContributionPct,
        'peak_diurnal_hour_ist': peakDiurnalHourIst,
        'peak_diurnal_discharge_cumecs': peakDiurnalDischargeCumecs,
        'diurnal_discharge_amplitude_pct': diurnalDischargeAmplitudePct,
      };
}

class DownstreamHydropowerInflowModel {
  final String damName;
  final String riverBasin;
  final double installedCapacityMw;
  final double liveInflowCumecs;
  final double generationCapacityUtilizedPct;
  final double dailyStorageGainMcm;
  final double spillwayClearanceMarginM;
  final String inflowStatus;

  const DownstreamHydropowerInflowModel({
    required this.damName,
    required this.riverBasin,
    required this.installedCapacityMw,
    required this.liveInflowCumecs,
    required this.generationCapacityUtilizedPct,
    required this.dailyStorageGainMcm,
    required this.spillwayClearanceMarginM,
    required this.inflowStatus,
  });

  factory DownstreamHydropowerInflowModel.fromJson(Map<String, dynamic> json) {
    return DownstreamHydropowerInflowModel(
      damName: json['dam_name'] as String? ?? 'Hydropower Reservoir',
      riverBasin: json['river_basin'] as String? ?? 'River Basin',
      installedCapacityMw:
          (json['installed_capacity_mw'] as num?)?.toDouble() ?? 1000.0,
      liveInflowCumecs:
          (json['live_inflow_cumecs'] as num?)?.toDouble() ?? 1000.0,
      generationCapacityUtilizedPct:
          (json['generation_capacity_utilized_pct'] as num?)?.toDouble() ??
              90.0,
      dailyStorageGainMcm:
          (json['daily_storage_gain_mcm'] as num?)?.toDouble() ?? 20.0,
      spillwayClearanceMarginM:
          (json['spillway_clearance_margin_m'] as num?)?.toDouble() ?? 8.0,
      inflowStatus:
          json['inflow_status'] as String? ?? 'OPTIMAL_GENERATION_SURGE',
    );
  }

  Map<String, dynamic> toJson() => {
        'dam_name': damName,
        'river_basin': riverBasin,
        'installed_capacity_mw': installedCapacityMw,
        'live_inflow_cumecs': liveInflowCumecs,
        'generation_capacity_utilized_pct': generationCapacityUtilizedPct,
        'daily_storage_gain_mcm': dailyStorageGainMcm,
        'spillway_clearance_margin_m': spillwayClearanceMarginM,
        'inflow_status': inflowStatus,
      };
}

class SnowmeltBasinModel {
  final String basinId;
  final String basinName;
  final String state;
  final String mountainRange;
  final double drainageAreaSqKm;
  final String currentRegime;
  final List<ElevationZonalBandModel> elevationBands;
  final SnowpackCryosphereTelemetryModel cryosphereTelemetry;
  final CatchmentRunoffMetricsModel runoffMetrics;
  final List<DownstreamHydropowerInflowModel> hydropowerInflows;
  final String riparianSafetyAdvisory;
  final Map<String, String> vernacularBulletins;

  const SnowmeltBasinModel({
    required this.basinId,
    required this.basinName,
    required this.state,
    required this.mountainRange,
    required this.drainageAreaSqKm,
    required this.currentRegime,
    required this.elevationBands,
    required this.cryosphereTelemetry,
    required this.runoffMetrics,
    required this.hydropowerInflows,
    required this.riparianSafetyAdvisory,
    required this.vernacularBulletins,
  });

  factory SnowmeltBasinModel.fromJson(Map<String, dynamic> json) {
    return SnowmeltBasinModel(
      basinId: json['basin_id'] as String? ?? 'satluj_bhakra',
      basinName: json['basin_name'] as String? ??
          'Satluj Basin & Bhakra Reservoir Catchment',
      state: json['state'] as String? ?? 'Himachal Pradesh',
      mountainRange: json['mountain_range'] as String? ??
          'Western Himalaya (Pir Panjal & Great Himalaya)',
      drainageAreaSqKm:
          (json['drainage_area_sq_km'] as num?)?.toDouble() ?? 56874.0,
      currentRegime:
          json['current_regime'] as String? ?? 'SEASONAL_SNOWMELT_SURGE',
      elevationBands: (json['elevation_bands'] as List<dynamic>?)
              ?.map((e) =>
                  ElevationZonalBandModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      cryosphereTelemetry: json['cryosphere_telemetry'] != null
          ? SnowpackCryosphereTelemetryModel.fromJson(
              json['cryosphere_telemetry'] as Map<String, dynamic>)
          : const SnowpackCryosphereTelemetryModel(
              snowLineAltitudeM: 3250.0,
              equilibriumLineAltitudeM: 4750.0,
              freezingLevelIsothermM: 4620.0,
              basinSnowWaterEquivalentMm: 285.0,
              freshSnow24hCm: 0.0,
              satelliteNdsiCoveragePct: 94.5,
            ),
      runoffMetrics: json['runoff_metrics'] != null
          ? CatchmentRunoffMetricsModel.fromJson(
              json['runoff_metrics'] as Map<String, dynamic>)
          : const CatchmentRunoffMetricsModel(
              dailyDischargeCumecs: 1420.0,
              snowmeltFractionPct: 64.5,
              rainfallContributionPct: 18.5,
              baseflowContributionPct: 17.0,
              peakDiurnalHourIst: '18:00 IST',
              peakDiurnalDischargeCumecs: 1780.0,
              diurnalDischargeAmplitudePct: 42.0,
            ),
      hydropowerInflows: (json['hydropower_inflows'] as List<dynamic>?)
              ?.map((e) => DownstreamHydropowerInflowModel.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
      riparianSafetyAdvisory: json['riparian_safety_advisory'] as String? ??
          'Late-afternoon diurnal snowmelt peak between 17:00 and 20:00 IST.',
      vernacularBulletins:
          (json['vernacular_bulletins'] as Map<String, dynamic>?)
                  ?.map((k, v) => MapEntry(k, v.toString())) ??
              {},
    );
  }

  Map<String, dynamic> toJson() => {
        'basin_id': basinId,
        'basin_name': basinName,
        'state': state,
        'mountain_range': mountainRange,
        'drainage_area_sq_km': drainageAreaSqKm,
        'current_regime': currentRegime,
        'elevation_bands': elevationBands.map((e) => e.toJson()).toList(),
        'cryosphere_telemetry': cryosphereTelemetry.toJson(),
        'runoff_metrics': runoffMetrics.toJson(),
        'hydropower_inflows':
            hydropowerInflows.map((e) => e.toJson()).toList(),
        'riparian_safety_advisory': riparianSafetyAdvisory,
        'vernacular_bulletins': vernacularBulletins,
      };
}

class BasinSummaryModel {
  final String basinId;
  final String basinName;
  final String state;
  final String riverSystem;
  final double dailyDischargeCumecs;
  final double snowmeltFractionPct;
  final String inflowStatus;

  const BasinSummaryModel({
    required this.basinId,
    required this.basinName,
    required this.state,
    required this.riverSystem,
    required this.dailyDischargeCumecs,
    required this.snowmeltFractionPct,
    required this.inflowStatus,
  });

  factory BasinSummaryModel.fromJson(Map<String, dynamic> json) {
    return BasinSummaryModel(
      basinId: json['basin_id'] as String? ?? 'satluj_bhakra',
      basinName: json['basin_name'] as String? ?? 'Satluj Basin',
      state: json['state'] as String? ?? 'Himachal Pradesh',
      riverSystem: json['river_system'] as String? ?? 'Western Himalaya',
      dailyDischargeCumecs:
          (json['daily_discharge_cumecs'] as num?)?.toDouble() ?? 1420.0,
      snowmeltFractionPct:
          (json['snowmelt_fraction_pct'] as num?)?.toDouble() ?? 64.5,
      inflowStatus:
          json['inflow_status'] as String? ?? 'OPTIMAL_GENERATION_SURGE',
    );
  }

  Map<String, dynamic> toJson() => {
        'basin_id': basinId,
        'basin_name': basinName,
        'state': state,
        'river_system': riverSystem,
        'daily_discharge_cumecs': dailyDischargeCumecs,
        'snowmelt_fraction_pct': snowmeltFractionPct,
        'inflow_status': inflowStatus,
      };
}

class SnowmeltRunoffResponseModel {
  final String basinId;
  final String basinName;
  final String state;
  final SnowmeltBasinModel currentBasin;
  final List<BasinSummaryModel> allBasins;
  final String lastUpdatedUtc;
  final String dataSource;

  const SnowmeltRunoffResponseModel({
    required this.basinId,
    required this.basinName,
    required this.state,
    required this.currentBasin,
    required this.allBasins,
    required this.lastUpdatedUtc,
    required this.dataSource,
  });

  factory SnowmeltRunoffResponseModel.fromJson(Map<String, dynamic> json) {
    return SnowmeltRunoffResponseModel(
      basinId: json['basin_id'] as String? ?? 'satluj_bhakra',
      basinName: json['basin_name'] as String? ??
          'Satluj Basin & Bhakra Reservoir Catchment',
      state: json['state'] as String? ?? 'Himachal Pradesh',
      currentBasin: json['current_basin'] != null
          ? SnowmeltBasinModel.fromJson(
              json['current_basin'] as Map<String, dynamic>)
          : SnowmeltRunoffResponseModel.defaultFallback().currentBasin,
      allBasins: (json['all_basins'] as List<dynamic>?)
              ?.map((e) => BasinSummaryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          SnowmeltRunoffResponseModel.defaultFallback().allBasins,
      lastUpdatedUtc: json['last_updated_utc'] as String? ??
          DateTime.now().toUtc().toIso8601String(),
      dataSource: json['data_source'] as String? ??
          'IMD Mountain Weather Division, CWC (Ministry of Jal Shakti), DRDO-DGRE & NRSC-ISRO',
    );
  }

  Map<String, dynamic> toJson() => {
        'basin_id': basinId,
        'basin_name': basinName,
        'state': state,
        'current_basin': currentBasin.toJson(),
        'all_basins': allBasins.map((e) => e.toJson()).toList(),
        'last_updated_utc': lastUpdatedUtc,
        'data_source': dataSource,
      };

  factory SnowmeltRunoffResponseModel.defaultFallback() {
    return const SnowmeltRunoffResponseModel(
      basinId: 'satluj_bhakra',
      basinName: 'Satluj Basin & Bhakra Reservoir Catchment',
      state: 'Himachal Pradesh',
      currentBasin: SnowmeltBasinModel(
        basinId: 'satluj_bhakra',
        basinName: 'Satluj Basin & Bhakra Reservoir Catchment',
        state: 'Himachal Pradesh',
        mountainRange: 'Western Himalaya (Pir Panjal & Great Himalaya)',
        drainageAreaSqKm: 56874.0,
        currentRegime: 'SEASONAL_SNOWMELT_SURGE',
        elevationBands: [
          ElevationZonalBandModel(
            bandId: 'ZONE_A',
            elevationRangeLabel: '1,500m - 2,500m AMSL (Lower Valley)',
            elevationMinM: 1500.0,
            elevationMaxM: 2500.0,
            zonalAreaSqKm: 8530.0,
            snowCoverAreaPct: 12.0,
            meanTemperatureC: 16.5,
            degreeDayFactorCmPerDegCDay: 0.38,
            dailyMeltVolumeMcm: 6.4,
          ),
          ElevationZonalBandModel(
            bandId: 'ZONE_B',
            elevationRangeLabel:
                '2,500m - 3,500m AMSL (Mid-Elevation Snowpack)',
            elevationMinM: 2500.0,
            elevationMaxM: 3500.0,
            zonalAreaSqKm: 14220.0,
            snowCoverAreaPct: 52.0,
            meanTemperatureC: 10.2,
            degreeDayFactorCmPerDegCDay: 0.48,
            dailyMeltVolumeMcm: 36.2,
          ),
          ElevationZonalBandModel(
            bandId: 'ZONE_C',
            elevationRangeLabel:
                '3,500m - 4,500m AMSL (Sub-Glacial Firn Zone)',
            elevationMinM: 3500.0,
            elevationMaxM: 4500.0,
            zonalAreaSqKm: 18200.0,
            snowCoverAreaPct: 84.0,
            meanTemperatureC: 4.8,
            degreeDayFactorCmPerDegCDay: 0.62,
            dailyMeltVolumeMcm: 45.5,
          ),
          ElevationZonalBandModel(
            bandId: 'ZONE_D',
            elevationRangeLabel:
                '> 4,500m AMSL (Perpetual Cryosphere & Glaciers)',
            elevationMinM: 4500.0,
            elevationMaxM: 6800.0,
            zonalAreaSqKm: 15924.0,
            snowCoverAreaPct: 96.0,
            meanTemperatureC: -1.2,
            degreeDayFactorCmPerDegCDay: 0.75,
            dailyMeltVolumeMcm: 14.8,
          ),
        ],
        cryosphereTelemetry: SnowpackCryosphereTelemetryModel(
          snowLineAltitudeM: 3250.0,
          equilibriumLineAltitudeM: 4750.0,
          freezingLevelIsothermM: 4620.0,
          basinSnowWaterEquivalentMm: 285.0,
          freshSnow24hCm: 0.0,
          satelliteNdsiCoveragePct: 94.5,
        ),
        runoffMetrics: CatchmentRunoffMetricsModel(
          dailyDischargeCumecs: 1420.0,
          snowmeltFractionPct: 64.5,
          rainfallContributionPct: 18.5,
          baseflowContributionPct: 17.0,
          peakDiurnalHourIst: '18:00 IST',
          peakDiurnalDischargeCumecs: 1780.0,
          diurnalDischargeAmplitudePct: 42.0,
        ),
        hydropowerInflows: [
          DownstreamHydropowerInflowModel(
            damName: 'Bhakra Dam (Gobind Sagar)',
            riverBasin: 'Satluj River Basin',
            installedCapacityMw: 1325.0,
            liveInflowCumecs: 1340.0,
            generationCapacityUtilizedPct: 92.0,
            dailyStorageGainMcm: 84.5,
            spillwayClearanceMarginM: 8.4,
            inflowStatus: 'OPTIMAL_GENERATION_SURGE',
          ),
          DownstreamHydropowerInflowModel(
            damName: 'Nathpa Jhakri Hydroelectric Plant',
            riverBasin: 'Upper Satluj Gorge',
            installedCapacityMw: 1500.0,
            liveInflowCumecs: 1180.0,
            generationCapacityUtilizedPct: 98.0,
            dailyStorageGainMcm: 12.0,
            spillwayClearanceMarginM: 4.2,
            inflowStatus: 'OPTIMAL_GENERATION_SURGE',
          ),
        ],
        riparianSafetyAdvisory:
            'Late-afternoon diurnal snowmelt peak between 17:00 and 20:00 IST. Downstream riverbed activities, fishing, and unregulated bathing prohibited along Satluj gorge from Rampur Bushahr to Bilaspur.',
        vernacularBulletins: {
          'en':
              'IMD-CWC SATLUJ SNOWMELT BULLETIN: Diurnal snowmelt discharge surge active in Zone B & C (2,500m-4,500m) with total river inflow of 1,420 cumecs at Bhakra Reservoir. Gobind Sagar storage filling rapidly (+84.5 MCM/day). Downstream riverbed warning in effect for late afternoon hours.',
          'hi':
              'आईएमडी-सीडब्ल्यूसी सतलुज हिमद्रवण बुलेटिन: 2,500 से 4,500 मीटर की ऊंचाई पर बर्फ पिघलने की दर तेज है। भाखड़ा जलाशय में 1,420 क्यूमेक का कुल जलप्रवाह दर्ज किया गया है। गोविंद सागर में दैनिक 84.5 एमसीएम पानी जमा हो रहा है। शाम 5 से 8 बजे के बीच नदी किनारे न जाएं।',
          'pa':
              'ਸਤਲੁਜ ਬੇਸਿਨ ਬਰਫ਼ ਪਿਘਲਣ ਬੁਲੇਟਿਨ: 2,500-4,500 ਮੀਟਰ ਉਚਾਈ ਤੇ ਤੇਜ਼ੀ ਨਾਲ ਬਰਫ਼ ਪਿਘਲਣ ਕਾਰਨ ਭਾਖੜਾ ਡੈਮ ਵਿੱਚ 1,420 ਕਿਊਮਿਕ ਪਾਣੀ ਆ ਰਿਹਾ ਹੈ। ਗੋਬਿੰਦ ਸਾਗਰ ਝੀਲ ਤੇਜ਼ੀ ਨਾਲ ਭਰ ਰਹੀ ਹੈ। ਸ਼ਾਮ ਵੇਲੇ ਦਰਿਆ ਕੰਢੇ ਜਾਣ ਤੋਂ ਗੁਰੇਜ਼ ਕਰੋ।',
          'ne':
              'सतलुज जलाधार हिउँ पग्लने चेतावनी: उच्च हिमाली क्षेत्रमा तापक्रम वृद्धिसँगै भाखड़ा जलाशयमा १४२० क्युमेक जलप्रवाह पुगेको छ। साँझको समयमा नदी तटीय क्षेत्रमा नजानुहोला।',
          'ks':
              'ستلج سنو میلٹ بلیٹن: بھاکھڑا ڈیمس منز چھُ 1,420 کیومکس آب جمع گژھان۔ شامن پیٹھہٕ کٔنٛڈؠن ترٛاونہٕ نش پرہیز کٔرِو۔',
          'bn':
              'শতদ্রু অববাহিকা তুষারগলন বুলেটিন: উচ্চ হিমালয়ে তীব্র তুষারগলনের ফলে ভাকরা জলাধারে ১৪২০ কিউমেক জলপ্রবাহ রেকর্ড করা হয়েছে। নদী তীরবর্তী অঞ্চলে বিকেলে সতর্কতা জারি।',
          'bo':
              'གཙང་པོ་སཏ་ལུཇ་གི་ཁངས་ཞུ་བའི་ཉེན་བརྡ། བྷཀྲ་རགས་ཆེན་དུ་ཆུ་རྒྱུན་ཤུགས་ཆེན་འབབ་བཞིན་ཡོད། དགོང་མོའི་དུས་སུ་ཆུ་འགྲམ་དུ་མ་འགྲོ།',
        },
      ),
      allBasins: [
        BasinSummaryModel(
          basinId: 'satluj_bhakra',
          basinName: 'Satluj Basin & Bhakra Reservoir Catchment',
          state: 'Himachal Pradesh',
          riverSystem: 'Western Himalaya (Pir Panjal & Great Himalaya)',
          dailyDischargeCumecs: 1420.0,
          snowmeltFractionPct: 64.5,
          inflowStatus: 'OPTIMAL_GENERATION_SURGE',
        ),
        BasinSummaryModel(
          basinId: 'bhagirathi_tehri',
          basinName: 'Bhagirathi & Alaknanda Basin (Tehri Dam Catchment)',
          state: 'Uttarakhand',
          riverSystem: 'Garhwal Himalaya',
          dailyDischargeCumecs: 890.0,
          snowmeltFractionPct: 58.0,
          inflowStatus: 'NORMAL_STORAGE_FILL',
        ),
        BasinSummaryModel(
          basinId: 'chenab_baglihar',
          basinName: 'Chenab Basin (Baglihar & Salal Dam Catchment)',
          state: 'Jammu & Kashmir',
          riverSystem: 'Zanskar & Pir Panjal Ranges',
          dailyDischargeCumecs: 1180.0,
          snowmeltFractionPct: 68.0,
          inflowStatus: 'OPTIMAL_GENERATION_SURGE',
        ),
        BasinSummaryModel(
          basinId: 'beas_pong',
          basinName: 'Beas Basin & Pong Reservoir Catchment',
          state: 'Himachal Pradesh',
          riverSystem: 'Dhauladhar & Pir Panjal Ranges',
          dailyDischargeCumecs: 740.0,
          snowmeltFractionPct: 61.0,
          inflowStatus: 'NORMAL_STORAGE_FILL',
        ),
        BasinSummaryModel(
          basinId: 'jhelum_uri',
          basinName: 'Jhelum & Kishanganga Basin (Uri-I & II HEP)',
          state: 'Jammu & Kashmir',
          riverSystem: 'Kashmir Himalaya & Shamshabari',
          dailyDischargeCumecs: 580.0,
          snowmeltFractionPct: 52.0,
          inflowStatus: 'OPTIMAL_GENERATION_SURGE',
        ),
        BasinSummaryModel(
          basinId: 'teesta_v',
          basinName: 'Teesta Basin & Teesta-V HEP Catchment',
          state: 'Sikkim',
          riverSystem: 'Eastern Himalaya (Kanchenjunga Massif)',
          dailyDischargeCumecs: 960.0,
          snowmeltFractionPct: 46.0,
          inflowStatus: 'SPILLWAY_DISCHARGE_WARNING',
        ),
        BasinSummaryModel(
          basinId: 'subansiri_lower',
          basinName: 'Subansiri Basin (Subansiri Lower HEP Catchment)',
          state: 'Arunachal Pradesh & Assam',
          riverSystem: 'Eastern Himalaya & Trans-Himalayan Plateau',
          dailyDischargeCumecs: 2150.0,
          snowmeltFractionPct: 42.0,
          inflowStatus: 'OPTIMAL_GENERATION_SURGE',
        ),
      ],
      lastUpdatedUtc: '2026-09-12T12:00:00Z',
      dataSource:
          'IMD Mountain Weather Division, CWC (Ministry of Jal Shakti), DRDO-DGRE & NRSC-ISRO',
    );
  }
}
