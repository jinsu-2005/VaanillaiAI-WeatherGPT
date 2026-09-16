class SeismicSourceParametersModel {
  final double momentMagnitudeMw;
  final double focalDepthKm;
  final double epicenterLatitude;
  final double epicenterLongitude;
  final String originTimeUtc;
  final String subductionZone;
  final String ruptureMechanism;

  const SeismicSourceParametersModel({
    required this.momentMagnitudeMw,
    required this.focalDepthKm,
    required this.epicenterLatitude,
    required this.epicenterLongitude,
    required this.originTimeUtc,
    required this.subductionZone,
    required this.ruptureMechanism,
  });

  factory SeismicSourceParametersModel.fromJson(Map<String, dynamic> json) {
    return SeismicSourceParametersModel(
      momentMagnitudeMw: (json['moment_magnitude_mw'] as num?)?.toDouble() ?? 8.0,
      focalDepthKm: (json['focal_depth_km'] as num?)?.toDouble() ?? 20.0,
      epicenterLatitude: (json['epicenter_latitude'] as num?)?.toDouble() ?? 9.0,
      epicenterLongitude: (json['epicenter_longitude'] as num?)?.toDouble() ?? 93.0,
      originTimeUtc: json['origin_time_utc'] as String? ?? DateTime.now().toIso8601String(),
      subductionZone: json['subduction_zone'] as String? ?? 'ANDAMAN_SUMATRA_TRENCH',
      ruptureMechanism: json['rupture_mechanism'] as String? ?? 'Underthrust Megathrust Faulting',
    );
  }

  Map<String, dynamic> toJson() => {
        'moment_magnitude_mw': momentMagnitudeMw,
        'focal_depth_km': focalDepthKm,
        'epicenter_latitude': epicenterLatitude,
        'epicenter_longitude': epicenterLongitude,
        'origin_time_utc': originTimeUtc,
        'subduction_zone': subductionZone,
        'rupture_mechanism': ruptureMechanism,
      };
}

class DeepOceanDartBuoyModel {
  final String buoyId;
  final String seaBasin;
  final double latitude;
  final double longitude;
  final double waterDepthM;
  final double pressureAnomalyHpa;
  final double deepOceanWaveAmplitudeCm;
  final bool isEventModeTriggered;

  const DeepOceanDartBuoyModel({
    required this.buoyId,
    required this.seaBasin,
    required this.latitude,
    required this.longitude,
    required this.waterDepthM,
    required this.pressureAnomalyHpa,
    required this.deepOceanWaveAmplitudeCm,
    required this.isEventModeTriggered,
  });

  factory DeepOceanDartBuoyModel.fromJson(Map<String, dynamic> json) {
    return DeepOceanDartBuoyModel(
      buoyId: json['buoy_id'] as String? ?? 'BPR-TB01',
      seaBasin: json['sea_basin'] as String? ?? 'East Bay of Bengal',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 13.5,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 89.2,
      waterDepthM: (json['water_depth_m'] as num?)?.toDouble() ?? 3300.0,
      pressureAnomalyHpa: (json['pressure_anomaly_hpa'] as num?)?.toDouble() ?? 5.0,
      deepOceanWaveAmplitudeCm: (json['deep_ocean_wave_amplitude_cm'] as num?)?.toDouble() ?? 20.0,
      isEventModeTriggered: json['is_event_mode_triggered'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'buoy_id': buoyId,
        'sea_basin': seaBasin,
        'latitude': latitude,
        'longitude': longitude,
        'water_depth_m': waterDepthM,
        'pressure_anomaly_hpa': pressureAnomalyHpa,
        'deep_ocean_wave_amplitude_cm': deepOceanWaveAmplitudeCm,
        'is_event_mode_triggered': isEventModeTriggered,
      };
}

class CoastalTideGaugeTelemetryModel {
  final String stationId;
  final String stationName;
  final double observedSeaLevelM;
  final double astronomicalTideM;
  final double tsunamiResidualAmplitudeM;
  final String lastSampleTimeUtc;

  const CoastalTideGaugeTelemetryModel({
    required this.stationId,
    required this.stationName,
    required this.observedSeaLevelM,
    required this.astronomicalTideM,
    required this.tsunamiResidualAmplitudeM,
    required this.lastSampleTimeUtc,
  });

  factory CoastalTideGaugeTelemetryModel.fromJson(Map<String, dynamic> json) {
    return CoastalTideGaugeTelemetryModel(
      stationId: json['station_id'] as String? ?? 'INCOIS-TG-MAA',
      stationName: json['station_name'] as String? ?? 'Chennai Port Tide Gauge',
      observedSeaLevelM: (json['observed_sea_level_m'] as num?)?.toDouble() ?? 1.2,
      astronomicalTideM: (json['astronomical_tide_m'] as num?)?.toDouble() ?? 1.0,
      tsunamiResidualAmplitudeM: (json['tsunami_residual_amplitude_m'] as num?)?.toDouble() ?? 0.2,
      lastSampleTimeUtc: json['last_sample_time_utc'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => {
        'station_id': stationId,
        'station_name': stationName,
        'observed_sea_level_m': observedSeaLevelM,
        'astronomical_tide_m': astronomicalTideM,
        'tsunami_residual_amplitude_m': tsunamiResidualAmplitudeM,
        'last_sample_time_utc': lastSampleTimeUtc,
      };
}

class CoastalTsunamiWaveMetricsModel {
  final String estimatedTimeOfArrivalEta;
  final int timeToFirstWaveMinutes;
  final double maximumExpectedWaveAmplitudeM;
  final double deepWaterPropagationSpeedKmh;
  final double estimatedInundationDistanceM;
  final double shoalingAmplificationFactor;

  const CoastalTsunamiWaveMetricsModel({
    required this.estimatedTimeOfArrivalEta,
    required this.timeToFirstWaveMinutes,
    required this.maximumExpectedWaveAmplitudeM,
    required this.deepWaterPropagationSpeedKmh,
    required this.estimatedInundationDistanceM,
    required this.shoalingAmplificationFactor,
  });

  factory CoastalTsunamiWaveMetricsModel.fromJson(Map<String, dynamic> json) {
    return CoastalTsunamiWaveMetricsModel(
      estimatedTimeOfArrivalEta: json['estimated_time_of_arrival_eta'] as String? ?? '05:00 UTC',
      timeToFirstWaveMinutes: (json['time_to_first_wave_minutes'] as num?)?.toInt() ?? 60,
      maximumExpectedWaveAmplitudeM: (json['maximum_expected_wave_amplitude_m'] as num?)?.toDouble() ?? 2.0,
      deepWaterPropagationSpeedKmh: (json['deep_water_propagation_speed_kmh'] as num?)?.toDouble() ?? 700.0,
      estimatedInundationDistanceM: (json['estimated_inundation_distance_m'] as num?)?.toDouble() ?? 400.0,
      shoalingAmplificationFactor: (json['shoaling_amplification_factor'] as num?)?.toDouble() ?? 4.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'estimated_time_of_arrival_eta': estimatedTimeOfArrivalEta,
        'time_to_first_wave_minutes': timeToFirstWaveMinutes,
        'maximum_expected_wave_amplitude_m': maximumExpectedWaveAmplitudeM,
        'deep_water_propagation_speed_kmh': deepWaterPropagationSpeedKmh,
        'estimated_inundation_distance_m': estimatedInundationDistanceM,
        'shoaling_amplification_factor': shoalingAmplificationFactor,
      };
}

class EvacuationAndMaritimeDirectivesModel {
  final double verticalEvacuationAltitudeM;
  final double horizontalEvacuationDistanceKm;
  final String deepSeaVesselDirective;
  final String coastalSirenNetworkStatus;
  final String portCargoOperationsStatus;
  final List<String> designatedSafeShelterLocations;

  const EvacuationAndMaritimeDirectivesModel({
    required this.verticalEvacuationAltitudeM,
    required this.horizontalEvacuationDistanceKm,
    required this.deepSeaVesselDirective,
    required this.coastalSirenNetworkStatus,
    required this.portCargoOperationsStatus,
    required this.designatedSafeShelterLocations,
  });

  factory EvacuationAndMaritimeDirectivesModel.fromJson(Map<String, dynamic> json) {
    return EvacuationAndMaritimeDirectivesModel(
      verticalEvacuationAltitudeM: (json['vertical_evacuation_altitude_m'] as num?)?.toDouble() ?? 15.0,
      horizontalEvacuationDistanceKm: (json['horizontal_evacuation_distance_km'] as num?)?.toDouble() ?? 1.0,
      deepSeaVesselDirective: json['deep_sea_vessel_directive'] as String? ?? 'Vessels move to deep sea (>100m depth)',
      coastalSirenNetworkStatus: json['coastal_siren_network_status'] as String? ?? 'ACTIVE',
      portCargoOperationsStatus: json['port_cargo_operations_status'] as String? ?? 'SUSPENDED',
      designatedSafeShelterLocations: (json['designated_safe_shelter_locations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Designated Elevated Cyclone/Tsunami Shelter'],
    );
  }

  Map<String, dynamic> toJson() => {
        'vertical_evacuation_altitude_m': verticalEvacuationAltitudeM,
        'horizontal_evacuation_distance_km': horizontalEvacuationDistanceKm,
        'deep_sea_vessel_directive': deepSeaVesselDirective,
        'coastal_siren_network_status': coastalSirenNetworkStatus,
        'port_cargo_operations_status': portCargoOperationsStatus,
        'designated_safe_shelter_locations': designatedSafeShelterLocations,
      };
}

class CoastalForecastSectorModel {
  final String sectorId;
  final String sectorName;
  final String state;
  final List<String> keyCoastalNodes;
  final double latitude;
  final double longitude;
  final String alertTier;
  final SeismicSourceParametersModel seismicSource;
  final CoastalTsunamiWaveMetricsModel waveMetrics;
  final List<DeepOceanDartBuoyModel> dartBuoys;
  final List<CoastalTideGaugeTelemetryModel> tideGauges;
  final EvacuationAndMaritimeDirectivesModel evacuationDirectives;
  final Map<String, String> localizedBulletins;

  const CoastalForecastSectorModel({
    required this.sectorId,
    required this.sectorName,
    required this.state,
    required this.keyCoastalNodes,
    required this.latitude,
    required this.longitude,
    required this.alertTier,
    required this.seismicSource,
    required this.waveMetrics,
    required this.dartBuoys,
    required this.tideGauges,
    required this.evacuationDirectives,
    required this.localizedBulletins,
  });

  factory CoastalForecastSectorModel.fromJson(Map<String, dynamic> json) {
    return CoastalForecastSectorModel(
      sectorId: json['sector_id'] as String? ?? 'andaman_nicobar_islands',
      sectorName: json['sector_name'] as String? ?? 'Andaman & Nicobar Islands',
      state: json['state'] as String? ?? 'Andaman & Nicobar Islands (UT)',
      keyCoastalNodes: (json['key_coastal_nodes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Port Blair', 'Car Nicobar'],
      latitude: (json['latitude'] as num?)?.toDouble() ?? 11.6670,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 92.7350,
      alertTier: json['alert_tier'] as String? ?? 'WARNING_RED',
      seismicSource: SeismicSourceParametersModel.fromJson(
        json['seismic_source'] as Map<String, dynamic>? ?? {},
      ),
      waveMetrics: CoastalTsunamiWaveMetricsModel.fromJson(
        json['wave_metrics'] as Map<String, dynamic>? ?? {},
      ),
      dartBuoys: (json['dart_buoys'] as List<dynamic>?)
              ?.map((e) => DeepOceanDartBuoyModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tideGauges: (json['tide_gauges'] as List<dynamic>?)
              ?.map((e) => CoastalTideGaugeTelemetryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      evacuationDirectives: EvacuationAndMaritimeDirectivesModel.fromJson(
        json['evacuation_directives'] as Map<String, dynamic>? ?? {},
      ),
      localizedBulletins: (json['localized_bulletins'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          const {},
    );
  }

  Map<String, dynamic> toJson() => {
        'sector_id': sectorId,
        'sector_name': sectorName,
        'state': state,
        'key_coastal_nodes': keyCoastalNodes,
        'latitude': latitude,
        'longitude': longitude,
        'alert_tier': alertTier,
        'seismic_source': seismicSource.toJson(),
        'wave_metrics': waveMetrics.toJson(),
        'dart_buoys': dartBuoys.map((e) => e.toJson()).toList(),
        'tide_gauges': tideGauges.map((e) => e.toJson()).toList(),
        'evacuation_directives': evacuationDirectives.toJson(),
        'localized_bulletins': localizedBulletins,
      };
}

class TsunamiWarningResponseModel {
  final String timestamp;
  final String bulletinNumber;
  final String provenance;
  final String threatStatus;
  final CoastalForecastSectorModel selectedSector;
  final List<CoastalForecastSectorModel> allSectors;
  final Map<String, String> vernacularBulletins;
  final bool isOfflineCached;

  const TsunamiWarningResponseModel({
    required this.timestamp,
    required this.bulletinNumber,
    required this.provenance,
    required this.threatStatus,
    required this.selectedSector,
    required this.allSectors,
    required this.vernacularBulletins,
    this.isOfflineCached = false,
  });

  factory TsunamiWarningResponseModel.fromJson(
    Map<String, dynamic> json, {
    bool isOfflineCached = false,
  }) {
    return TsunamiWarningResponseModel(
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      bulletinNumber: json['bulletin_number'] as String? ?? 'INCOIS-ITEWS/TSU-WARN/202609-ANDAMA',
      provenance: json['provenance'] as String? ??
          'Indian National Centre for Ocean Information Services (INCOIS) & National Tsunami Early Warning Centre (ITEWS)',
      threatStatus: json['threat_status'] as String? ??
          'CRITICAL: Coastal Inundation Threat (Red Alert) Active',
      selectedSector: CoastalForecastSectorModel.fromJson(
        json['selected_sector'] as Map<String, dynamic>? ?? {},
      ),
      allSectors: (json['all_sectors'] as List<dynamic>?)
              ?.map((e) => CoastalForecastSectorModel.fromJson(e as Map<String, dynamic>))
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
        'threat_status': threatStatus,
        'selected_sector': selectedSector.toJson(),
        'all_sectors': allSectors.map((e) => e.toJson()).toList(),
        'vernacular_bulletins': vernacularBulletins,
        'is_offline_cached': isOfflineCached,
      };

  TsunamiWarningResponseModel copyWithOfflineCached(bool cached) {
    return TsunamiWarningResponseModel(
      timestamp: timestamp,
      bulletinNumber: bulletinNumber,
      provenance: provenance,
      threatStatus: threatStatus,
      selectedSector: selectedSector,
      allSectors: allSectors,
      vernacularBulletins: vernacularBulletins,
      isOfflineCached: cached,
    );
  }

  static TsunamiWarningResponseModel defaultFallback() {
    final andamanSector = CoastalForecastSectorModel(
      sectorId: 'andaman_nicobar_islands',
      sectorName: 'Andaman & Nicobar Islands (Near-Field Trench)',
      state: 'Andaman & Nicobar Islands (UT)',
      keyCoastalNodes: const ['Port Blair', 'Car Nicobar', 'Hut Bay', 'Campbell Bay'],
      latitude: 11.6670,
      longitude: 92.7350,
      alertTier: 'WARNING_RED',
      seismicSource: const SeismicSourceParametersModel(
        momentMagnitudeMw: 8.4,
        focalDepthKm: 18.0,
        epicenterLatitude: 9.2500,
        epicenterLongitude: 93.8500,
        originTimeUtc: '2026-09-12T04:15:00Z',
        subductionZone: 'ANDAMAN_SUMATRA_TRENCH',
        ruptureMechanism: 'Underthrust Megathrust Faulting (Subduction Zone)',
      ),
      waveMetrics: const CoastalTsunamiWaveMetricsModel(
        estimatedTimeOfArrivalEta: '04:43 UTC (28 min elapsed)',
        timeToFirstWaveMinutes: 28,
        maximumExpectedWaveAmplitudeM: 4.2,
        deepWaterPropagationSpeedKmh: 725.0,
        estimatedInundationDistanceM: 850.0,
        shoalingAmplificationFactor: 5.8,
      ),
      dartBuoys: const [
        DeepOceanDartBuoyModel(
          buoyId: 'BPR-TB02',
          seaBasin: 'Andaman Sea Trench',
          latitude: 10.8200,
          longitude: 93.4100,
          waterDepthM: 2850.0,
          pressureAnomalyHpa: 14.8,
          deepOceanWaveAmplitudeCm: 42.5,
          isEventModeTriggered: true,
        ),
        DeepOceanDartBuoyModel(
          buoyId: 'BPR-TB01',
          seaBasin: 'East Bay of Bengal',
          latitude: 13.5000,
          longitude: 89.2000,
          waterDepthM: 3320.0,
          pressureAnomalyHpa: 8.6,
          deepOceanWaveAmplitudeCm: 28.0,
          isEventModeTriggered: true,
        ),
      ],
      tideGauges: const [
        CoastalTideGaugeTelemetryModel(
          stationId: 'INCOIS-TG-PBLR',
          stationName: 'Port Blair Phoenix Bay Jetty',
          observedSeaLevelM: 2.45,
          astronomicalTideM: 0.82,
          tsunamiResidualAmplitudeM: 1.63,
          lastSampleTimeUtc: '2026-09-12T04:32:00Z',
        ),
      ],
      evacuationDirectives: const EvacuationAndMaritimeDirectivesModel(
        verticalEvacuationAltitudeM: 20.0,
        horizontalEvacuationDistanceKm: 1.5,
        deepSeaVesselDirective: 'Vessels in harbor MUST evacuate crews immediately and head to open sea (>100m depth).',
        coastalSirenNetworkStatus: 'HIGH ALERT: Coastal sirens sounding in Port Blair.',
        portCargoOperationsStatus: 'SUSPENDED: Ferry and port operations halted immediately.',
        designatedSafeShelterLocations: [
          'Mount Harriet High Ground Tsunami Refuge',
          'Car Nicobar Air Force Station Elevated Ridge',
          'Hut Bay Primary Tsunami Evacuation Tower',
        ],
      ),
      localizedBulletins: const {
        'en': 'CRITICAL TSUNAMI WARNING (RED ALERT): Major tsunamigenic earthquake (Mw 8.4) in Andaman-Sumatra trench. Maximum tsunami wave amplitude 4.2m expected. Immediate vertical evacuation to elevation >20m required across Andaman & Nicobar coastal sectors.',
        'hi': 'अति गंभीर सुनामी चेतावनी (लाल अलर्ट): अंडमान-सुमात्रा गर्त में 8.4 तीव्रता का सुनामी भूकंप। 4.2 मीटर ऊंची सुनामी लहरें उठने की आशंका। तटीय क्षेत्रों के लोग तुरंत 20 मीटर से अधिक ऊंचाई वाले सुरक्षित स्थानों पर जाएं।',
        'ta': 'சுனாமி சிவப்பு எச்சரிக்கை: அந்தமான்-சுமத்ரா அகழியில் 8.4 ரிக்டர் நிலநடுக்கம். 4.2 மீட்டர் உயர சுனாமி அலைகள் தாக்கக்கூடும். கடலோர மக்கள் உடனடியாக 20 மீட்டருக்கு மேல் உயரமான இடங்களுக்கு வெளியேறவும்.',
      },
    );

    final tamilNaduSector = CoastalForecastSectorModel(
      sectorId: 'tamil_nadu_coromandel_coast',
      sectorName: 'Tamil Nadu & Puducherry Coromandel Coast',
      state: 'Tamil Nadu & Puducherry',
      keyCoastalNodes: const ['Nagapattinam', 'Cuddalore', 'Chennai Marina', 'Tuticorin'],
      latitude: 10.7670,
      longitude: 79.8420,
      alertTier: 'WARNING_RED',
      seismicSource: const SeismicSourceParametersModel(
        momentMagnitudeMw: 8.4,
        focalDepthKm: 18.0,
        epicenterLatitude: 9.2500,
        epicenterLongitude: 93.8500,
        originTimeUtc: '2026-09-12T04:15:00Z',
        subductionZone: 'ANDAMAN_SUMATRA_TRENCH',
        ruptureMechanism: 'Underthrust Megathrust Faulting (Subduction Zone)',
      ),
      waveMetrics: const CoastalTsunamiWaveMetricsModel(
        estimatedTimeOfArrivalEta: '06:10 UTC (115 min remaining)',
        timeToFirstWaveMinutes: 115,
        maximumExpectedWaveAmplitudeM: 2.8,
        deepWaterPropagationSpeedKmh: 710.0,
        estimatedInundationDistanceM: 620.0,
        shoalingAmplificationFactor: 4.6,
      ),
      dartBuoys: const [
        DeepOceanDartBuoyModel(
          buoyId: 'BPR-TB01',
          seaBasin: 'East Bay of Bengal',
          latitude: 13.5000,
          longitude: 89.2000,
          waterDepthM: 3320.0,
          pressureAnomalyHpa: 8.6,
          deepOceanWaveAmplitudeCm: 28.0,
          isEventModeTriggered: true,
        ),
      ],
      tideGauges: const [
        CoastalTideGaugeTelemetryModel(
          stationId: 'INCOIS-TG-MAA',
          stationName: 'Chennai Port Trust Tide Gauge',
          observedSeaLevelM: 1.15,
          astronomicalTideM: 0.95,
          tsunamiResidualAmplitudeM: 0.20,
          lastSampleTimeUtc: '2026-09-12T04:40:00Z',
        ),
      ],
      evacuationDirectives: const EvacuationAndMaritimeDirectivesModel(
        verticalEvacuationAltitudeM: 15.0,
        horizontalEvacuationDistanceKm: 1.0,
        deepSeaVesselDirective: 'All fishing boats and commercial vessels out to sea (>100m depth). Clear Marina and Nagapattinam beaches immediately.',
        coastalSirenNetworkStatus: 'ACTIVATED: Coromandel sirens broadcasting evacuation tone.',
        portCargoOperationsStatus: 'SUSPENDED: Chennai and VOC Tuticorin ports de-berthing oil tankers.',
        designatedSafeShelterLocations: [
          'Nagapattinam Multi-Purpose Tsunami Shelter',
          'Cuddalore Silver Beach Cyclone/Tsunami Refuge',
        ],
      ),
      localizedBulletins: const {
        'en': 'TSUNAMI WARNING (RED ALERT): Coromandel coast on high alert. Peak tsunami wave amplitude 2.8m arriving Nagapattinam/Chennai around 06:10 UTC.',
        'ta': 'சுனாமி சிவப்பு எச்சரிக்கை: நாகப்பட்டினம், கடலூர், சென்னை கடற்கரைகளுக்கு 2.8 மீ உயர சுனாமி அலைகள் வரக்கூடும். மக்கள் கடற்கரையிலிருந்து 1 கி.மீ தூரத்திற்கு அப்பால் செல்லவும்.',
      },
    );

    return TsunamiWarningResponseModel(
      timestamp: DateTime.now().toIso8601String(),
      bulletinNumber: 'INCOIS-ITEWS/TSU-WARN/202609-ANDAMA',
      provenance: 'Indian National Centre for Ocean Information Services (INCOIS) & National Tsunami Early Warning Centre (ITEWS)',
      threatStatus: 'CRITICAL: Coastal Inundation Threat (Red Alert) Active',
      selectedSector: andamanSector,
      allSectors: [andamanSector, tamilNaduSector],
      vernacularBulletins: andamanSector.localizedBulletins,
      isOfflineCached: true,
    );
  }
}
