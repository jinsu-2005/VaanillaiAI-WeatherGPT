class HighwaySafetyAdvisoryModel {
  final String expresswayName;
  final int advisedSpeedKmh;
  final int normalSpeedLimitKmh;
  final String followingDistanceMultiplier;
  final String hazardLightsDirective;
  final String pileupRiskLevel;
  final String nearestLaybyParking;
  final String actionSummary;

  HighwaySafetyAdvisoryModel({
    required this.expresswayName,
    required this.advisedSpeedKmh,
    required this.normalSpeedLimitKmh,
    required this.followingDistanceMultiplier,
    required this.hazardLightsDirective,
    required this.pileupRiskLevel,
    required this.nearestLaybyParking,
    required this.actionSummary,
  });

  factory HighwaySafetyAdvisoryModel.fromJson(Map<String, dynamic> json) {
    return HighwaySafetyAdvisoryModel(
      expresswayName: json['expressway_name'] ?? 'National Expressway',
      advisedSpeedKmh: (json['advised_speed_kmh'] as num?)?.toInt() ?? 30,
      normalSpeedLimitKmh: (json['normal_speed_limit_kmh'] as num?)?.toInt() ?? 100,
      followingDistanceMultiplier: json['following_distance_multiplier'] ?? '4x normal spacing',
      hazardLightsDirective: json['hazard_lights_directive'] ?? 'Use low-beam fog lamps',
      pileupRiskLevel: json['pileup_risk_level'] ?? 'High',
      nearestLaybyParking: json['nearest_layby_parking'] ?? 'Nearest Toll Plaza / Rest Area',
      actionSummary: json['action_summary'] ?? 'Drive with extreme caution in dense fog.',
    );
  }

  Map<String, dynamic> toJson() => {
    'expressway_name': expresswayName,
    'advised_speed_kmh': advisedSpeedKmh,
    'normal_speed_limit_kmh': normalSpeedLimitKmh,
    'following_distance_multiplier': followingDistanceMultiplier,
    'hazard_lights_directive': hazardLightsDirective,
    'pileup_risk_level': pileupRiskLevel,
    'nearest_layby_parking': nearestLaybyParking,
    'action_summary': actionSummary,
  };
}

class RailwayFogPassTelemetryModel {
  final bool fogpassActive;
  final int locomotiveSpeedCapKmh;
  final String railCorridor;
  final String signalVisibility;
  final String expectedDelayBracket;
  final bool detonatorRuleActive;

  RailwayFogPassTelemetryModel({
    required this.fogpassActive,
    required this.locomotiveSpeedCapKmh,
    required this.railCorridor,
    required this.signalVisibility,
    required this.expectedDelayBracket,
    required this.detonatorRuleActive,
  });

  factory RailwayFogPassTelemetryModel.fromJson(Map<String, dynamic> json) {
    return RailwayFogPassTelemetryModel(
      fogpassActive: json['fogpass_active'] ?? true,
      locomotiveSpeedCapKmh: (json['locomotive_speed_cap_kmh'] as num?)?.toInt() ?? 60,
      railCorridor: json['rail_corridor'] ?? 'Northern Railway Trunk Line',
      signalVisibility: json['signal_visibility'] ?? 'Signals obscured — FogPass GPS active',
      expectedDelayBracket: json['expected_delay_bracket'] ?? '1 to 3 hours delay expected',
      detonatorRuleActive: json['detonator_rule_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'fogpass_active': fogpassActive,
    'locomotive_speed_cap_kmh': locomotiveSpeedCapKmh,
    'rail_corridor': railCorridor,
    'signal_visibility': signalVisibility,
    'expected_delay_bracket': expectedDelayBracket,
    'detonator_rule_active': detonatorRuleActive,
  };
}

class FogPhysicsMetricsModel {
  final double airTemperatureC;
  final double dewPointC;
  final double dewPointDepressionC;
  final double relativeHumidityPercent;
  final double surfaceWindSpeedKmh;
  final String radiationInversionIntensity;
  final String fogType;
  final String formationOnsetTime;
  final String dissipationExpectedTime;

  FogPhysicsMetricsModel({
    required this.airTemperatureC,
    required this.dewPointC,
    required this.dewPointDepressionC,
    required this.relativeHumidityPercent,
    required this.surfaceWindSpeedKmh,
    required this.radiationInversionIntensity,
    required this.fogType,
    required this.formationOnsetTime,
    required this.dissipationExpectedTime,
  });

  factory FogPhysicsMetricsModel.fromJson(Map<String, dynamic> json) {
    return FogPhysicsMetricsModel(
      airTemperatureC: (json['air_temperature_c'] as num?)?.toDouble() ?? 10.0,
      dewPointC: (json['dew_point_c'] as num?)?.toDouble() ?? 9.5,
      dewPointDepressionC: (json['dew_point_depression_c'] as num?)?.toDouble() ?? 0.5,
      relativeHumidityPercent: (json['relative_humidity_percent'] as num?)?.toDouble() ?? 95.0,
      surfaceWindSpeedKmh: (json['surface_wind_speed_kmh'] as num?)?.toDouble() ?? 4.0,
      radiationInversionIntensity: json['radiation_inversion_intensity'] ?? 'Strong Nocturnal Ground Inversion',
      fogType: json['fog_type'] ?? 'Radiation Fog',
      formationOnsetTime: json['formation_onset_time'] ?? '02:30 IST',
      dissipationExpectedTime: json['dissipation_expected_time'] ?? '10:00 IST',
    );
  }

  Map<String, dynamic> toJson() => {
    'air_temperature_c': airTemperatureC,
    'dew_point_c': dewPointC,
    'dew_point_depression_c': dewPointDepressionC,
    'relative_humidity_percent': relativeHumidityPercent,
    'surface_wind_speed_kmh': surfaceWindSpeedKmh,
    'radiation_inversion_intensity': radiationInversionIntensity,
    'fog_type': fogType,
    'formation_onset_time': formationOnsetTime,
    'dissipation_expected_time': dissipationExpectedTime,
  };
}

class CorridorStationModel {
  final String stationId;
  final String stationName;
  final String state;
  final double latitude;
  final double longitude;
  final int visibilityMeters;
  final String visibilityTier;
  final String rvrCategory;
  final bool isAirport;
  final double? distanceKm;

  CorridorStationModel({
    required this.stationId,
    required this.stationName,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.visibilityMeters,
    required this.visibilityTier,
    required this.rvrCategory,
    required this.isAirport,
    this.distanceKm,
  });

  factory CorridorStationModel.fromJson(Map<String, dynamic> json) {
    return CorridorStationModel(
      stationId: json['station_id'] ?? '',
      stationName: json['station_name'] ?? 'Station',
      state: json['state'] ?? 'India',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      visibilityMeters: (json['visibility_meters'] as num?)?.toInt() ?? 500,
      visibilityTier: json['visibility_tier'] ?? 'Moderate Fog',
      rvrCategory: json['rvr_category'] ?? 'CAT II (Low Visibility)',
      isAirport: json['is_airport'] ?? true,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'station_id': stationId,
    'station_name': stationName,
    'state': state,
    'latitude': latitude,
    'longitude': longitude,
    'visibility_meters': visibilityMeters,
    'visibility_tier': visibilityTier,
    'rvr_category': rvrCategory,
    'is_airport': isAirport,
    'distance_km': distanceKm,
  };
}

class FogNowcastResponseModel {
  final String locationName;
  final double latitude;
  final double longitude;
  final int visibilityMeters;
  final String visibilityTier;
  final String severityColorHex;
  final String rvrStatus;
  final String rvrAlertSummary;
  final FogPhysicsMetricsModel physics;
  final HighwaySafetyAdvisoryModel highwayAdvisory;
  final RailwayFogPassTelemetryModel railwayFogpass;
  final List<CorridorStationModel> corridorStations;
  final Map<String, String> vernacularAdvisories;
  final String sourceProvenance;
  final String generatedAt;

  FogNowcastResponseModel({
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.visibilityMeters,
    required this.visibilityTier,
    required this.severityColorHex,
    required this.rvrStatus,
    required this.rvrAlertSummary,
    required this.physics,
    required this.highwayAdvisory,
    required this.railwayFogpass,
    required this.corridorStations,
    required this.vernacularAdvisories,
    required this.sourceProvenance,
    required this.generatedAt,
  });

  factory FogNowcastResponseModel.fromJson(Map<String, dynamic> json) {
    return FogNowcastResponseModel(
      locationName: json['location_name'] ?? 'Indo-Gangetic Corridor',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 28.5665,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 77.1031,
      visibilityMeters: (json['visibility_meters'] as num?)?.toInt() ?? 150,
      visibilityTier: json['visibility_tier'] ?? 'Dense Fog',
      severityColorHex: json['severity_color_hex'] ?? '#D32F2F',
      rvrStatus: json['rvr_status'] ?? 'CAT IIIB (Blind Autoland)',
      rvrAlertSummary: json['rvr_alert_summary'] ?? 'CAT IIIB Low visibility procedures active.',
      physics: FogPhysicsMetricsModel.fromJson(json['physics'] as Map<String, dynamic>? ?? {}),
      highwayAdvisory: HighwaySafetyAdvisoryModel.fromJson(json['highway_advisory'] as Map<String, dynamic>? ?? {}),
      railwayFogpass: RailwayFogPassTelemetryModel.fromJson(json['railway_fogpass'] as Map<String, dynamic>? ?? {}),
      corridorStations: (json['corridor_stations'] as List<dynamic>? ?? [])
          .map((e) => CorridorStationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      vernacularAdvisories: (json['vernacular_advisories'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, v.toString())),
      sourceProvenance: json['source_provenance'] ?? 'IMD Winter Fog Experiment (WiFEX) & MoRTH / NHAI',
      generatedAt: json['generated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'location_name': locationName,
    'latitude': latitude,
    'longitude': longitude,
    'visibility_meters': visibilityMeters,
    'visibility_tier': visibilityTier,
    'severity_color_hex': severityColorHex,
    'rvr_status': rvrStatus,
    'rvr_alert_summary': rvrAlertSummary,
    'physics': physics.toJson(),
    'highway_advisory': highwayAdvisory.toJson(),
    'railway_fogpass': railwayFogpass.toJson(),
    'corridor_stations': corridorStations.map((e) => e.toJson()).toList(),
    'vernacular_advisories': vernacularAdvisories,
    'source_provenance': sourceProvenance,
    'generated_at': generatedAt,
  };

  factory FogNowcastResponseModel.defaultFallback({
    String location = 'New Delhi (IGI Airport)',
    double lat = 28.5665,
    double lon = 77.1031,
  }) {
    return FogNowcastResponseModel(
      locationName: location,
      latitude: lat,
      longitude: lon,
      visibilityMeters: 120,
      visibilityTier: 'Dense Fog',
      severityColorHex: '#D32F2F',
      rvrStatus: 'CAT IIIB (Blind Autoland)',
      rvrAlertSummary: 'RVR 120m: CAT-IIIB Precision Autoland Active. Flight holding patterns in effect.',
      physics: FogPhysicsMetricsModel(
        airTemperatureC: 11.2,
        dewPointC: 10.6,
        dewPointDepressionC: 0.6,
        relativeHumidityPercent: 96.0,
        surfaceWindSpeedKmh: 3.2,
        radiationInversionIntensity: 'Strong Nocturnal Ground Inversion',
        fogType: 'Dense Radiation Fog',
        formationOnsetTime: '02:30 IST',
        dissipationExpectedTime: '10:00 IST',
      ),
      highwayAdvisory: HighwaySafetyAdvisoryModel(
        expresswayName: 'Yamuna & Eastern Peripheral Expressways',
        advisedSpeedKmh: 30,
        normalSpeedLimitKmh: 100,
        followingDistanceMultiplier: '4x normal spacing (min 100 meters)',
        hazardLightsDirective: 'Use low-beam yellow fog lamps. Avoid high beams (glare blinding).',
        pileupRiskLevel: 'High',
        nearestLaybyParking: 'Jewar Toll Plaza Lay-by / Expressway Wayside Rest Area',
        actionSummary: 'Dense fog corridor. Max 30 km/h speed limit. Follow lane line delineators.',
      ),
      railwayFogpass: RailwayFogPassTelemetryModel(
        fogpassActive: true,
        locomotiveSpeedCapKmh: 60,
        railCorridor: 'Delhi-Kanpur-Prayagraj Main Trunk Route',
        signalVisibility: 'Signals obscured beyond 40 meters — GPS FogPass active',
        expectedDelayBracket: '2 to 4 hours delay expected on North-bound trains',
        detonatorRuleActive: true,
      ),
      corridorStations: [
        CorridorStationModel(
          stationId: '42182',
          stationName: 'New Delhi (IGI Airport & Yamuna Expressway)',
          state: 'Delhi NCR',
          latitude: 28.5665,
          longitude: 77.1031,
          visibilityMeters: 120,
          visibilityTier: 'Dense Fog',
          rvrCategory: 'CAT IIIB (Blind Autoland)',
          isAirport: true,
          distanceKm: 0.0,
        ),
        CorridorStationModel(
          stationId: '42071',
          stationName: 'Amritsar (GT Road / NH-44 Hub)',
          state: 'Punjab',
          latitude: 31.7096,
          longitude: 74.7973,
          visibilityMeters: 80,
          visibilityTier: 'Dense Fog',
          rvrCategory: 'CAT IIIB (Blind Autoland)',
          isAirport: true,
          distanceKm: 395.0,
        ),
        CorridorStationModel(
          stationId: '42369',
          stationName: 'Lucknow (Agra-Lucknow Expressway)',
          state: 'Uttar Pradesh',
          latitude: 26.7606,
          longitude: 80.8893,
          visibilityMeters: 160,
          visibilityTier: 'Dense Fog',
          rvrCategory: 'CAT IIIA (Precision Touchdown)',
          isAirport: true,
          distanceKm: 420.0,
        ),
        CorridorStationModel(
          stationId: '42261',
          stationName: 'Agra (Yamuna Expressway Confluence)',
          state: 'Uttar Pradesh',
          latitude: 27.1558,
          longitude: 77.9609,
          visibilityMeters: 90,
          visibilityTier: 'Dense Fog',
          rvrCategory: 'CAT IIIB (Blind Autoland)',
          isAirport: false,
          distanceKm: 180.0,
        ),
      ],
      vernacularAdvisories: {
        'en': 'CRITICAL FOG ALERT: Visibility down to 120m. Max safe speed 30 km/h. Keep low-beam fog lamps ON.',
        'hi': 'अत्यधिक घना कोहरा चेतावनी: दृश्यता केवल 120 मीटर है। अधिकतम सुरक्षित गति 30 किमी/घंटा। लो-बीम लाइट जलाएं।',
        'pa': 'ਬਹੁਤ ਸੰਘਣੀ ਧੁੰਦ ਚੇਤਾਵਨੀ: ਵਿਜ਼ੀਬਿਲਟੀ ਸਿਰਫ਼ 120 ਮੀਟਰ ਹੈ। ਵੱਧ ਤੋਂ ਵੱਧ ਗਤੀ 30 ਕਿਲੋਮੀਟਰ/ਘੰਟਾ ਰੱਖੋ।',
        'bn': 'ঘন কুয়াশা সতর্কতা: দৃশ্যমানতা মাত্র ১২০ মিটার। এক্সপ্রেসওয়েতে সর্বোচ্চ গতি ৩০ কিমি/ঘণ্টা বজায় রাখুন।',
        'ta': 'அடர்ந்த மூடுபனி எச்சரிக்கை: பார்வை திறன் 120 மீட்டராக குறைந்துள்ளது. பாதுகாப்பான வேகம் 30 கிமீ/மணி.',
      },
      sourceProvenance: 'IMD Winter Fog Experiment (WiFEX) & MoRTH / NHAI Highway Safety Protocol',
      generatedAt: DateTime.now().toIso8601String(),
    );
  }
}
