class DvorakTelemetryModel {
  final double tNumber;
  final double ciNumber;
  final double centralPressureHpa;
  final double pressureDeficitHpa;
  final double maxSustainedWindKt;
  final double maxSustainedWindKmh;
  final double gustSpeedKmh;
  final String intensityStage;
  final String intensityCode;

  DvorakTelemetryModel({
    required this.tNumber,
    required this.ciNumber,
    required this.centralPressureHpa,
    required this.pressureDeficitHpa,
    required this.maxSustainedWindKt,
    required this.maxSustainedWindKmh,
    required this.gustSpeedKmh,
    required this.intensityStage,
    required this.intensityCode,
  });

  factory DvorakTelemetryModel.fromJson(Map<String, dynamic> json) {
    return DvorakTelemetryModel(
      tNumber: (json['t_number'] as num?)?.toDouble() ?? 3.5,
      ciNumber: (json['ci_number'] as num?)?.toDouble() ?? 3.5,
      centralPressureHpa: (json['central_pressure_hpa'] as num?)?.toDouble() ?? 990.0,
      pressureDeficitHpa: (json['pressure_deficit_hpa'] as num?)?.toDouble() ?? 20.0,
      maxSustainedWindKt: (json['max_sustained_wind_kt'] as num?)?.toDouble() ?? 55.0,
      maxSustainedWindKmh: (json['max_sustained_wind_kmh'] as num?)?.toDouble() ?? 100.0,
      gustSpeedKmh: (json['gust_speed_kmh'] as num?)?.toDouble() ?? 125.0,
      intensityStage: json['intensity_stage'] ?? 'Severe Cyclonic Storm (SCS)',
      intensityCode: json['intensity_code'] ?? 'SCS',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      't_number': tNumber,
      'ci_number': ciNumber,
      'central_pressure_hpa': centralPressureHpa,
      'pressure_deficit_hpa': pressureDeficitHpa,
      'max_sustained_wind_kt': maxSustainedWindKt,
      'max_sustained_wind_kmh': maxSustainedWindKmh,
      'gust_speed_kmh': gustSpeedKmh,
      'intensity_stage': intensityStage,
      'intensity_code': intensityCode,
    };
  }
}

class GaleWindRadiiModel {
  final double radius34ktNeKm;
  final double radius34ktSeKm;
  final double radius34ktSwKm;
  final double radius34ktNwKm;
  final double radius50ktNeKm;
  final double radius50ktSeKm;
  final double radius50ktSwKm;
  final double radius50ktNwKm;
  final double radius64ktNeKm;
  final double radius64ktSeKm;
  final double radius64ktSwKm;
  final double radius64ktNwKm;

  GaleWindRadiiModel({
    required this.radius34ktNeKm,
    required this.radius34ktSeKm,
    required this.radius34ktSwKm,
    required this.radius34ktNwKm,
    required this.radius50ktNeKm,
    required this.radius50ktSeKm,
    required this.radius50ktSwKm,
    required this.radius50ktNwKm,
    required this.radius64ktNeKm,
    required this.radius64ktSeKm,
    required this.radius64ktSwKm,
    required this.radius64ktNwKm,
  });

  factory GaleWindRadiiModel.fromJson(Map<String, dynamic> json) {
    return GaleWindRadiiModel(
      radius34ktNeKm: (json['radius_34kt_ne_km'] as num?)?.toDouble() ?? 200.0,
      radius34ktSeKm: (json['radius_34kt_se_km'] as num?)?.toDouble() ?? 160.0,
      radius34ktSwKm: (json['radius_34kt_sw_km'] as num?)?.toDouble() ?? 120.0,
      radius34ktNwKm: (json['radius_34kt_nw_km'] as num?)?.toDouble() ?? 150.0,
      radius50ktNeKm: (json['radius_50kt_ne_km'] as num?)?.toDouble() ?? 100.0,
      radius50ktSeKm: (json['radius_50kt_se_km'] as num?)?.toDouble() ?? 80.0,
      radius50ktSwKm: (json['radius_50kt_sw_km'] as num?)?.toDouble() ?? 60.0,
      radius50ktNwKm: (json['radius_50kt_nw_km'] as num?)?.toDouble() ?? 70.0,
      radius64ktNeKm: (json['radius_64kt_ne_km'] as num?)?.toDouble() ?? 40.0,
      radius64ktSeKm: (json['radius_64kt_se_km'] as num?)?.toDouble() ?? 30.0,
      radius64ktSwKm: (json['radius_64kt_sw_km'] as num?)?.toDouble() ?? 20.0,
      radius64ktNwKm: (json['radius_64kt_nw_km'] as num?)?.toDouble() ?? 25.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'radius_34kt_ne_km': radius34ktNeKm,
      'radius_34kt_se_km': radius34ktSeKm,
      'radius_34kt_sw_km': radius34ktSwKm,
      'radius_34kt_nw_km': radius34ktNwKm,
      'radius_50kt_ne_km': radius50ktNeKm,
      'radius_50kt_se_km': radius50ktSeKm,
      'radius_50kt_sw_km': radius50ktSwKm,
      'radius_50kt_nw_km': radius50ktNwKm,
      'radius_64kt_ne_km': radius64ktNeKm,
      'radius_64kt_se_km': radius64ktSeKm,
      'radius_64kt_sw_km': radius64ktSwKm,
      'radius_64kt_nw_km': radius64ktNwKm,
    };
  }
}

class CycloneTrackPointModel {
  final int forecastHour;
  final String timestampIso;
  final double latitude;
  final double longitude;
  final String stageCode;
  final String stageName;
  final double centralPressureHpa;
  final double maxWindKmh;
  final String status;
  final double coneOfUncertaintyKm;

  CycloneTrackPointModel({
    required this.forecastHour,
    required this.timestampIso,
    required this.latitude,
    required this.longitude,
    required this.stageCode,
    required this.stageName,
    required this.centralPressureHpa,
    required this.maxWindKmh,
    required this.status,
    required this.coneOfUncertaintyKm,
  });

  factory CycloneTrackPointModel.fromJson(Map<String, dynamic> json) {
    return CycloneTrackPointModel(
      forecastHour: (json['forecast_hour'] as num?)?.toInt() ?? 0,
      timestampIso: json['timestamp_iso'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      stageCode: json['stage_code'] ?? '',
      stageName: json['stage_name'] ?? '',
      centralPressureHpa: (json['central_pressure_hpa'] as num?)?.toDouble() ?? 1000.0,
      maxWindKmh: (json['max_wind_kmh'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'Forecast',
      coneOfUncertaintyKm: (json['cone_of_uncertainty_km'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'forecast_hour': forecastHour,
      'timestamp_iso': timestampIso,
      'latitude': latitude,
      'longitude': longitude,
      'stage_code': stageCode,
      'stage_name': stageName,
      'central_pressure_hpa': centralPressureHpa,
      'max_wind_kmh': maxWindKmh,
      'status': status,
      'cone_of_uncertainty_km': coneOfUncertaintyKm,
    };
  }
}

class StormSurgeInundationModel {
  final String coastalDistrict;
  final double astronomicalTideM;
  final double peakSurgeM;
  final double totalWaterLevelM;
  final double inlandInundationKm;
  final String surgeRiskTier;
  final String surgeWarningNote;

  StormSurgeInundationModel({
    required this.coastalDistrict,
    required this.astronomicalTideM,
    required this.peakSurgeM,
    required this.totalWaterLevelM,
    required this.inlandInundationKm,
    required this.surgeRiskTier,
    required this.surgeWarningNote,
  });

  factory StormSurgeInundationModel.fromJson(Map<String, dynamic> json) {
    return StormSurgeInundationModel(
      coastalDistrict: json['coastal_district'] ?? '',
      astronomicalTideM: (json['astronomical_tide_m'] as num?)?.toDouble() ?? 0.8,
      peakSurgeM: (json['peak_surge_m'] as num?)?.toDouble() ?? 1.5,
      totalWaterLevelM: (json['total_water_level_m'] as num?)?.toDouble() ?? 2.3,
      inlandInundationKm: (json['inland_inundation_km'] as num?)?.toDouble() ?? 3.0,
      surgeRiskTier: json['surge_risk_tier'] ?? 'Moderate',
      surgeWarningNote: json['surge_warning_note'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coastal_district': coastalDistrict,
      'astronomical_tide_m': astronomicalTideM,
      'peak_surge_m': peakSurgeM,
      'total_water_level_m': totalWaterLevelM,
      'inland_inundation_km': inlandInundationKm,
      'surge_risk_tier': surgeRiskTier,
      'surge_warning_note': surgeWarningNote,
    };
  }
}

class EvacuationDirectiveModel {
  final String redZoneAction;
  final String orangeZoneAction;
  final String yellowZoneAction;
  final int portWarningSignal;
  final String portSignalMeaning;
  final int sheltersActiveCount;

  EvacuationDirectiveModel({
    required this.redZoneAction,
    required this.orangeZoneAction,
    required this.yellowZoneAction,
    required this.portWarningSignal,
    required this.portSignalMeaning,
    required this.sheltersActiveCount,
  });

  factory EvacuationDirectiveModel.fromJson(Map<String, dynamic> json) {
    return EvacuationDirectiveModel(
      redZoneAction: json['red_zone_action'] ?? '',
      orangeZoneAction: json['orange_zone_action'] ?? '',
      yellowZoneAction: json['yellow_zone_action'] ?? '',
      portWarningSignal: (json['port_warning_signal'] as num?)?.toInt() ?? 9,
      portSignalMeaning: json['port_signal_meaning'] ?? '',
      sheltersActiveCount: (json['shelters_active_count'] as num?)?.toInt() ?? 150,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'red_zone_action': redZoneAction,
      'orange_zone_action': orangeZoneAction,
      'yellow_zone_action': yellowZoneAction,
      'port_warning_signal': portWarningSignal,
      'port_signal_meaning': portSignalMeaning,
      'shelters_active_count': sheltersActiveCount,
    };
  }
}

class CycloneSystemModel {
  final String systemId;
  final String name;
  final String basin;
  final bool isActive;
  final String warningStage;
  final String stageColorHex;
  final DvorakTelemetryModel dvorak;
  final double currentLatitude;
  final double currentLongitude;
  final String movementDirection;
  final double movementSpeedKmh;
  final double? distanceToUserKm;
  final String projectedLandfallLocation;
  final String projectedLandfallTime;
  final double? landfallEtaHours;
  final List<CycloneTrackPointModel> trackPoints;
  final GaleWindRadiiModel galeRadii;
  final List<StormSurgeInundationModel> stormSurgeForecasts;
  final EvacuationDirectiveModel evacuation;
  final Map<String, String> vernacularBulletin;

  CycloneSystemModel({
    required this.systemId,
    required this.name,
    required this.basin,
    this.isActive = true,
    required this.warningStage,
    required this.stageColorHex,
    required this.dvorak,
    required this.currentLatitude,
    required this.currentLongitude,
    required this.movementDirection,
    required this.movementSpeedKmh,
    this.distanceToUserKm,
    required this.projectedLandfallLocation,
    required this.projectedLandfallTime,
    this.landfallEtaHours,
    this.trackPoints = const [],
    required this.galeRadii,
    this.stormSurgeForecasts = const [],
    required this.evacuation,
    this.vernacularBulletin = const {},
  });

  factory CycloneSystemModel.fromJson(Map<String, dynamic> json) {
    return CycloneSystemModel(
      systemId: json['system_id'] ?? '',
      name: json['name'] ?? 'Cyclone',
      basin: json['basin'] ?? 'Bay of Bengal',
      isActive: json['is_active'] ?? true,
      warningStage: json['warning_stage'] ?? 'Stage 3: Cyclone Warning',
      stageColorHex: json['stage_color_hex'] ?? '#D32F2F',
      dvorak: DvorakTelemetryModel.fromJson(json['dvorak'] ?? {}),
      currentLatitude: (json['current_latitude'] as num?)?.toDouble() ?? 13.0,
      currentLongitude: (json['current_longitude'] as num?)?.toDouble() ?? 80.0,
      movementDirection: json['movement_direction'] ?? 'North-Northwest (NNW)',
      movementSpeedKmh: (json['movement_speed_kmh'] as num?)?.toDouble() ?? 12.0,
      distanceToUserKm: (json['distance_to_user_km'] as num?)?.toDouble(),
      projectedLandfallLocation: json['projected_landfall_location'] ?? 'South Andhra Coast',
      projectedLandfallTime: json['projected_landfall_time'] ?? '',
      landfallEtaHours: (json['landfall_eta_hours'] as num?)?.toDouble(),
      trackPoints: (json['track_points'] as List<dynamic>?)
              ?.map((e) => CycloneTrackPointModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      galeRadii: GaleWindRadiiModel.fromJson(json['gale_radii'] ?? {}),
      stormSurgeForecasts: (json['storm_surge_forecasts'] as List<dynamic>?)
              ?.map((e) => StormSurgeInundationModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      evacuation: EvacuationDirectiveModel.fromJson(json['evacuation'] ?? {}),
      vernacularBulletin: (json['vernacular_bulletin'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'system_id': systemId,
      'name': name,
      'basin': basin,
      'is_active': isActive,
      'warning_stage': warningStage,
      'stage_color_hex': stageColorHex,
      'dvorak': dvorak.toJson(),
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'movement_direction': movementDirection,
      'movement_speed_kmh': movementSpeedKmh,
      'distance_to_user_km': distanceToUserKm,
      'projected_landfall_location': projectedLandfallLocation,
      'projected_landfall_time': projectedLandfallTime,
      'landfall_eta_hours': landfallEtaHours,
      'track_points': trackPoints.map((e) => e.toJson()).toList(),
      'gale_radii': galeRadii.toJson(),
      'storm_surge_forecasts': stormSurgeForecasts.map((e) => e.toJson()).toList(),
      'evacuation': evacuation.toJson(),
      'vernacular_bulletin': vernacularBulletin,
    };
  }
}

class CycloneTrackerResponseModel {
  final String basinStatus;
  final int activeSystemsCount;
  final CycloneSystemModel selectedSystem;
  final List<CycloneSystemModel> availableSystems;
  final double? nearestSystemDistanceKm;
  final String basinReadinessSummary;
  final String rsmcBulletinNo;
  final String issuedAt;
  final String authorityDisclaimer;
  final bool isOfflineCached;

  CycloneTrackerResponseModel({
    required this.basinStatus,
    required this.activeSystemsCount,
    required this.selectedSystem,
    this.availableSystems = const [],
    this.nearestSystemDistanceKm,
    required this.basinReadinessSummary,
    required this.rsmcBulletinNo,
    required this.issuedAt,
    required this.authorityDisclaimer,
    this.isOfflineCached = false,
  });

  factory CycloneTrackerResponseModel.fromJson(Map<String, dynamic> json, {bool isOffline = false}) {
    return CycloneTrackerResponseModel(
      basinStatus: json['basin_status'] ?? 'Active Cyclone Alert',
      activeSystemsCount: (json['active_systems_count'] as num?)?.toInt() ?? 1,
      selectedSystem: CycloneSystemModel.fromJson(json['selected_system'] ?? {}),
      availableSystems: (json['available_systems'] as List<dynamic>?)
              ?.map((e) => CycloneSystemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      nearestSystemDistanceKm: (json['nearest_system_distance_km'] as num?)?.toDouble(),
      basinReadinessSummary: json['basin_readiness_summary'] ?? '',
      rsmcBulletinNo: json['rsmc_bulletin_no'] ?? 'RSMC/NIO/CYC',
      issuedAt: json['issued_at'] ?? '',
      authorityDisclaimer: json['authority_disclaimer'] ?? 'RSMC New Delhi / IMD MoES',
      isOfflineCached: isOffline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'basin_status': basinStatus,
      'active_systems_count': activeSystemsCount,
      'selected_system': selectedSystem.toJson(),
      'available_systems': availableSystems.map((e) => e.toJson()).toList(),
      'nearest_system_distance_km': nearestSystemDistanceKm,
      'basin_readiness_summary': basinReadinessSummary,
      'rsmc_bulletin_no': rsmcBulletinNo,
      'issued_at': issuedAt,
      'authority_disclaimer': authorityDisclaimer,
    };
  }

  factory CycloneTrackerResponseModel.defaultFallback() {
    final dvorak = DvorakTelemetryModel(
      tNumber: 4.0,
      ciNumber: 4.0,
      centralPressureHpa: 988.0,
      pressureDeficitHpa: 22.0,
      maxSustainedWindKt: 65.0,
      maxSustainedWindKmh: 120.0,
      gustSpeedKmh: 145.0,
      intensityStage: 'Very Severe Cyclonic Storm (VSCS)',
      intensityCode: 'VSCS',
    );

    final gale = GaleWindRadiiModel(
      radius34ktNeKm: 220.0,
      radius34ktSeKm: 180.0,
      radius34ktSwKm: 130.0,
      radius34ktNwKm: 160.0,
      radius50ktNeKm: 110.0,
      radius50ktSeKm: 85.0,
      radius50ktSwKm: 60.0,
      radius50ktNwKm: 75.0,
      radius64ktNeKm: 45.0,
      radius64ktSeKm: 35.0,
      radius64ktSwKm: 25.0,
      radius64ktNwKm: 30.0,
    );

    final track = [
      CycloneTrackPointModel(
        forecastHour: -6,
        timestampIso: '2023-12-04T12:00:00Z',
        latitude: 13.7,
        longitude: 80.5,
        stageCode: 'SCS',
        stageName: 'Severe Cyclonic Storm',
        centralPressureHpa: 990.0,
        maxWindKmh: 100.0,
        status: 'Past',
        coneOfUncertaintyKm: 0.0,
      ),
      CycloneTrackPointModel(
        forecastHour: 0,
        timestampIso: '2023-12-04T18:00:00Z',
        latitude: 14.2,
        longitude: 80.3,
        stageCode: 'VSCS',
        stageName: 'Very Severe Cyclonic Storm',
        centralPressureHpa: 988.0,
        maxWindKmh: 120.0,
        status: 'Current',
        coneOfUncertaintyKm: 25.0,
      ),
      CycloneTrackPointModel(
        forecastHour: 12,
        timestampIso: '2023-12-05T06:00:00Z',
        latitude: 15.7,
        longitude: 80.2,
        stageCode: 'VSCS',
        stageName: 'Landfall near Bapatla',
        centralPressureHpa: 984.0,
        maxWindKmh: 115.0,
        status: 'Forecast',
        coneOfUncertaintyKm: 65.0,
      ),
    ];

    final surge = [
      StormSurgeInundationModel(
        coastalDistrict: 'Bapatla, Andhra Pradesh',
        astronomicalTideM: 0.9,
        peakSurgeM: 1.6,
        totalWaterLevelM: 2.5,
        inlandInundationKm: 3.4,
        surgeRiskTier: 'High',
        surgeWarningNote: 'Inundation of low lying coastal areas during landfall near Bapatla with seawall overtopping.',
      ),
      StormSurgeInundationModel(
        coastalDistrict: 'Nellore, Andhra Pradesh',
        astronomicalTideM: 0.8,
        peakSurgeM: 1.3,
        totalWaterLevelM: 2.1,
        inlandInundationKm: 2.8,
        surgeRiskTier: 'Moderate',
        surgeWarningNote: 'Backwater flooding in Swarnamukhi and Buckingham Canal creeks.',
      ),
    ];

    final evac = EvacuationDirectiveModel(
      redZoneAction: 'Mandatory evacuation of thatched and kutcha houses within 5 km to Multi-Purpose Cyclone Shelters (MPCS).',
      orangeZoneAction: 'Move to pucca RCC structures, prepare 72h potable water and non-perishable food.',
      yellowZoneAction: 'Secure rooftop antennas and tin sheds. Avoid venturing outdoors during squalls.',
      portWarningSignal: 9,
      portSignalMeaning: 'Great Danger Signal 9 (Port will experience severe weather from cyclone expected to move to the right/over port).',
      sheltersActiveCount: 214,
    );

    final bulletins = {
      'en': 'IMD RSMC Alert: Severe Cyclonic Storm over Westcentral Bay of Bengal moving NNW. Landfall expected near Bapatla with gale winds of 90-110 km/h. Suspension of fishing operations.',
      'ta': 'இந்திய வானிலை மையம்: மேற்கு மத்திய வங்கக்கடலில் புயல் வட-வடமேற்கு நோக்கி நகர்கிறது. பாபட்லா அருகே கரையை கடக்கும். மீனவர்கள் கடலுக்குச் செல்ல வேண்டாம்.',
      'hi': 'आईएमडी चेतावनी: पश्चिम-मध्य बंगाल की खाड़ी में गंभीर चक्रवाती तूफान बापटला की ओर बढ़ रहा है। मछुआरे समुद्र में न जाएं।',
      'bn': 'আইএমডি সতর্কতা: পশ্চিম-মধ্য বঙ্গোপসাগরে তীব্র ঘূর্ণিঝড় বাপটলার দিকে অগ্রসর হচ্ছে। সমুদ্রে যাবেন না।',
      'or': 'ଭାରତୀୟ ପାଣିପାଗ ବିଭାଗ ସତର୍କତା: ବଙ୍ଗୋପସାଗରରେ ବାତ୍ୟା ବାପଟଲା ନିକଟରେ ସ୍ଥଳଭାଗ ଛୁଇଁବ।',
    };

    final system = CycloneSystemModel(
      systemId: 'michaung-2023',
      name: 'MICHAUNG',
      basin: 'Bay of Bengal',
      isActive: true,
      warningStage: 'Stage 3: Cyclone Warning',
      stageColorHex: '#D32F2F',
      dvorak: dvorak,
      currentLatitude: 14.2,
      currentLongitude: 80.3,
      movementDirection: 'North-Northwest (NNW)',
      movementSpeedKmh: 12.0,
      distanceToUserKm: 130.0,
      projectedLandfallLocation: 'South Andhra Pradesh Coast (Near Bapatla)',
      projectedLandfallTime: '05 Dec 2023, 11:30 IST',
      landfallEtaHours: 11.5,
      trackPoints: track,
      galeRadii: gale,
      stormSurgeForecasts: surge,
      evacuation: evac,
      vernacularBulletin: bulletins,
    );

    return CycloneTrackerResponseModel(
      basinStatus: 'Active Cyclone Alert',
      activeSystemsCount: 1,
      selectedSystem: system,
      availableSystems: [system],
      nearestSystemDistanceKm: 130.0,
      basinReadinessSummary: 'North Indian Ocean under RSMC New Delhi cyclone watch. Emergency disaster mitigation protocols active.',
      rsmcBulletinNo: 'RSMC/NIO/CYC-OFFLINE',
      issuedAt: 'Calibrated Emergency Baseline',
      authorityDisclaimer: 'Official RSMC New Delhi / IMD MoES Cyclone Warning Protocol',
      isOfflineCached: true,
    );
  }
}
