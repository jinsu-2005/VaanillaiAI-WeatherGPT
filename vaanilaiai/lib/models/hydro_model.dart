class RiverGaugeStationModel {
  final String stationCode;
  final String name;
  final String river;
  final String basin;
  final String state;
  final double latitude;
  final double longitude;
  final double currentLevelM;
  final double warningLevelM;
  final double dangerLevelM;
  final double highestFloodLevelM;
  final String trend; // Rising, Steady, Falling
  final String floodStage; // Normal, Warning, Danger, Extreme
  final double? distanceKm;

  RiverGaugeStationModel({
    required this.stationCode,
    required this.name,
    required this.river,
    required this.basin,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.currentLevelM,
    required this.warningLevelM,
    required this.dangerLevelM,
    required this.highestFloodLevelM,
    this.trend = 'Steady',
    this.floodStage = 'Normal',
    this.distanceKm,
  });

  factory RiverGaugeStationModel.fromJson(Map<String, dynamic> json) {
    return RiverGaugeStationModel(
      stationCode: json['station_code'] ?? '',
      name: json['name'] ?? '',
      river: json['river'] ?? '',
      basin: json['basin'] ?? '',
      state: json['state'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      currentLevelM: (json['current_level_m'] as num?)?.toDouble() ?? 0.0,
      warningLevelM: (json['warning_level_m'] as num?)?.toDouble() ?? 0.0,
      dangerLevelM: (json['danger_level_m'] as num?)?.toDouble() ?? 0.0,
      highestFloodLevelM: (json['highest_flood_level_m'] as num?)?.toDouble() ?? 0.0,
      trend: json['trend'] ?? 'Steady',
      floodStage: json['flood_stage'] ?? 'Normal',
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'station_code': stationCode,
      'name': name,
      'river': river,
      'basin': basin,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'current_level_m': currentLevelM,
      'warning_level_m': warningLevelM,
      'danger_level_m': dangerLevelM,
      'highest_flood_level_m': highestFloodLevelM,
      'trend': trend,
      'flood_stage': floodStage,
      'distance_km': distanceKm,
    };
  }
}

class DamReservoirModel {
  final String reservoirCode;
  final String name;
  final String river;
  final String basin;
  final String state;
  final double latitude;
  final double longitude;
  final double fullReservoirLevelM;
  final double currentLevelM;
  final double liveStorageCapacityTmc;
  final double currentStorageTmc;
  final double storagePercent;
  final double inflowCusecs;
  final double outflowCusecs;
  final int spillwayGatesOpen;
  final String spillwayStatus;
  final String downstreamAlert;
  final double? distanceKm;

  DamReservoirModel({
    required this.reservoirCode,
    required this.name,
    required this.river,
    required this.basin,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.fullReservoirLevelM,
    required this.currentLevelM,
    required this.liveStorageCapacityTmc,
    required this.currentStorageTmc,
    required this.storagePercent,
    required this.inflowCusecs,
    required this.outflowCusecs,
    this.spillwayGatesOpen = 0,
    this.spillwayStatus = 'Closed',
    required this.downstreamAlert,
    this.distanceKm,
  });

  factory DamReservoirModel.fromJson(Map<String, dynamic> json) {
    return DamReservoirModel(
      reservoirCode: json['reservoir_code'] ?? '',
      name: json['name'] ?? '',
      river: json['river'] ?? '',
      basin: json['basin'] ?? '',
      state: json['state'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      fullReservoirLevelM: (json['full_reservoir_level_m'] as num?)?.toDouble() ?? 0.0,
      currentLevelM: (json['current_level_m'] as num?)?.toDouble() ?? 0.0,
      liveStorageCapacityTmc: (json['live_storage_capacity_tmc'] as num?)?.toDouble() ?? 0.0,
      currentStorageTmc: (json['current_storage_tmc'] as num?)?.toDouble() ?? 0.0,
      storagePercent: (json['storage_percent'] as num?)?.toDouble() ?? 0.0,
      inflowCusecs: (json['inflow_cusecs'] as num?)?.toDouble() ?? 0.0,
      outflowCusecs: (json['outflow_cusecs'] as num?)?.toDouble() ?? 0.0,
      spillwayGatesOpen: (json['spillway_gates_open'] as num?)?.toInt() ?? 0,
      spillwayStatus: json['spillway_status'] ?? 'Closed',
      downstreamAlert: json['downstream_alert'] ?? '',
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reservoir_code': reservoirCode,
      'name': name,
      'river': river,
      'basin': basin,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'full_reservoir_level_m': fullReservoirLevelM,
      'current_level_m': currentLevelM,
      'live_storage_capacity_tmc': liveStorageCapacityTmc,
      'current_storage_tmc': currentStorageTmc,
      'storage_percent': storagePercent,
      'inflow_cusecs': inflowCusecs,
      'outflow_cusecs': outflowCusecs,
      'spillway_gates_open': spillwayGatesOpen,
      'spillway_status': spillwayStatus,
      'downstream_alert': downstreamAlert,
      'distance_km': distanceKm,
    };
  }
}

class RiverBasinSummaryModel {
  final String basinName;
  final List<String> majorRivers;
  final int totalStations;
  final int stationsInDanger;
  final int stationsInWarning;
  final int highCapacityDamsCount;
  final String synopticFloodRisk;

  RiverBasinSummaryModel({
    required this.basinName,
    this.majorRivers = const [],
    this.totalStations = 0,
    this.stationsInDanger = 0,
    this.stationsInWarning = 0,
    this.highCapacityDamsCount = 0,
    this.synopticFloodRisk = 'Low',
  });

  factory RiverBasinSummaryModel.fromJson(Map<String, dynamic> json) {
    return RiverBasinSummaryModel(
      basinName: json['basin_name'] ?? '',
      majorRivers: (json['major_rivers'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      totalStations: (json['total_stations'] as num?)?.toInt() ?? 0,
      stationsInDanger: (json['stations_in_danger'] as num?)?.toInt() ?? 0,
      stationsInWarning: (json['stations_in_warning'] as num?)?.toInt() ?? 0,
      highCapacityDamsCount: (json['high_capacity_dams_count'] as num?)?.toInt() ?? 0,
      synopticFloodRisk: json['synoptic_flood_risk'] ?? 'Low',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'basin_name': basinName,
      'major_rivers': majorRivers,
      'total_stations': totalStations,
      'stations_in_danger': stationsInDanger,
      'stations_in_warning': stationsInWarning,
      'high_capacity_dams_count': highCapacityDamsCount,
      'synoptic_flood_risk': synopticFloodRisk,
    };
  }
}

class CwcHydroOverviewModel {
  final double latitude;
  final double longitude;
  final String locationName;
  final String selectedBasin;
  final List<String> availableBasins;
  final RiverGaugeStationModel? nearestGaugeStation;
  final DamReservoirModel? nearestReservoir;
  final RiverBasinSummaryModel basinSummary;
  final List<RiverGaugeStationModel> gaugeStations;
  final List<DamReservoirModel> reservoirs;
  final List<String> downstreamDirectives;
  final Map<String, dynamic> vernacularRiparianAlerts;
  final String provenanceAuthority;
  final String lastUpdated;
  final bool isOfflineCached;

  CwcHydroOverviewModel({
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.selectedBasin,
    this.availableBasins = const [],
    this.nearestGaugeStation,
    this.nearestReservoir,
    required this.basinSummary,
    this.gaugeStations = const [],
    this.reservoirs = const [],
    this.downstreamDirectives = const [],
    this.vernacularRiparianAlerts = const {},
    this.provenanceAuthority = 'Central Water Commission (CWC) & Ministry of Jal Shakti Hydro-Telemetry',
    required this.lastUpdated,
    this.isOfflineCached = false,
  });

  factory CwcHydroOverviewModel.fromJson(Map<String, dynamic> json, {bool isOfflineCached = false}) {
    return CwcHydroOverviewModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      locationName: json['location_name'] ?? 'Location',
      selectedBasin: json['selected_basin'] ?? 'Ganga',
      availableBasins: (json['available_basins'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [
        'Ganga', 'Brahmaputra', 'Godavari', 'Krishna', 'Cauvery', 'Narmada', 'Mahanadi', 'Periyar & Pamba'
      ],
      nearestGaugeStation: json['nearest_gauge_station'] != null
          ? RiverGaugeStationModel.fromJson(json['nearest_gauge_station'])
          : null,
      nearestReservoir: json['nearest_reservoir'] != null
          ? DamReservoirModel.fromJson(json['nearest_reservoir'])
          : null,
      basinSummary: json['basin_summary'] != null
          ? RiverBasinSummaryModel.fromJson(json['basin_summary'])
          : RiverBasinSummaryModel(basinName: json['selected_basin'] ?? 'Ganga'),
      gaugeStations: (json['gauge_stations'] as List<dynamic>?)
              ?.map((e) => RiverGaugeStationModel.fromJson(e))
              .toList() ??
          [],
      reservoirs: (json['reservoirs'] as List<dynamic>?)
              ?.map((e) => DamReservoirModel.fromJson(e))
              .toList() ??
          [],
      downstreamDirectives: (json['downstream_directives'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      vernacularRiparianAlerts: json['vernacular_riparian_alerts'] != null && json['vernacular_riparian_alerts'] is Map
          ? Map<String, dynamic>.from(json['vernacular_riparian_alerts'])
          : {},
      provenanceAuthority: json['provenance_authority'] ??
          'Central Water Commission (CWC) & Ministry of Jal Shakti Hydro-Telemetry',
      lastUpdated: json['last_updated'] ?? DateTime.now().toIso8601String(),
      isOfflineCached: isOfflineCached,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
      'selected_basin': selectedBasin,
      'available_basins': availableBasins,
      'nearest_gauge_station': nearestGaugeStation?.toJson(),
      'nearest_reservoir': nearestReservoir?.toJson(),
      'basin_summary': basinSummary.toJson(),
      'gauge_stations': gaugeStations.map((e) => e.toJson()).toList(),
      'reservoirs': reservoirs.map((e) => e.toJson()).toList(),
      'downstream_directives': downstreamDirectives,
      'vernacular_riparian_alerts': vernacularRiparianAlerts,
      'provenance_authority': provenanceAuthority,
      'last_updated': lastUpdated,
      'is_offline_cached': isOfflineCached,
    };
  }

  /// Calibrated built-in fallback for offline scenarios
  factory CwcHydroOverviewModel.defaultFallback({
    double latitude = 25.3076,
    double longitude = 83.0104,
    String locationName = 'Varanasi',
    String basinName = 'Ganga',
  }) {
    final nowStr = DateTime.now().toIso8601String();

    final defaultStation = RiverGaugeStationModel(
      stationCode: 'cwc_ganga_varanasi',
      name: 'Varanasi (Dashashwamedh Ghat)',
      river: 'Ganga',
      basin: 'Ganga',
      state: 'Uttar Pradesh',
      latitude: 25.3076,
      longitude: 83.0104,
      currentLevelM: 70.85,
      warningLevelM: 70.26,
      dangerLevelM: 71.26,
      highestFloodLevelM: 73.90,
      trend: 'Rising',
      floodStage: 'Warning',
      distanceKm: 0.0,
    );

    final defaultDam = DamReservoirModel(
      reservoirCode: 'dam_tehri',
      name: 'Tehri Dam',
      river: 'Bhagirathi',
      basin: 'Ganga',
      state: 'Uttarakhand',
      latitude: 30.3783,
      longitude: 78.4800,
      fullReservoirLevelM: 830.0,
      currentLevelM: 818.4,
      liveStorageCapacityTmc: 124.2,
      currentStorageTmc: 102.5,
      storagePercent: 82.5,
      inflowCusecs: 18500.0,
      outflowCusecs: 12000.0,
      spillwayGatesOpen: 2,
      spillwayStatus: 'Controlled Discharge',
      downstreamAlert: 'Controlled irrigation & flood buffer discharge. Riparian areas cautioned.',
      distanceKm: 680.0,
    );

    return CwcHydroOverviewModel(
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      selectedBasin: basinName,
      availableBasins: [
        'Ganga', 'Brahmaputra', 'Godavari', 'Krishna', 'Cauvery', 'Narmada', 'Mahanadi', 'Periyar & Pamba'
      ],
      nearestGaugeStation: defaultStation,
      nearestReservoir: defaultDam,
      basinSummary: RiverBasinSummaryModel(
        basinName: basinName,
        majorRivers: ['Ganga', 'Yamuna', 'Ghaghara'],
        totalStations: 5,
        stationsInDanger: 0,
        stationsInWarning: 2,
        highCapacityDamsCount: 1,
        synopticFloodRisk: 'Moderate',
      ),
      gaugeStations: [
        defaultStation,
        RiverGaugeStationModel(
          stationCode: 'cwc_ganga_prayagraj',
          name: 'Prayagraj (Sangam / Phaphamau)',
          river: 'Ganga',
          basin: 'Ganga',
          state: 'Uttar Pradesh',
          latitude: 25.4358,
          longitude: 81.8463,
          currentLevelM: 83.95,
          warningLevelM: 83.73,
          dangerLevelM: 84.73,
          highestFloodLevelM: 87.99,
          trend: 'Rising',
          floodStage: 'Warning',
          distanceKm: 120.0,
        ),
        RiverGaugeStationModel(
          stationCode: 'cwc_ganga_patna',
          name: 'Patna (Digha Ghat)',
          river: 'Ganga',
          basin: 'Ganga',
          state: 'Bihar',
          latitude: 25.6560,
          longitude: 85.0930,
          currentLevelM: 49.80,
          warningLevelM: 49.42,
          dangerLevelM: 50.45,
          highestFloodLevelM: 52.52,
          trend: 'Steady',
          floodStage: 'Warning',
          distanceKm: 210.0,
        ),
      ],
      reservoirs: [
        defaultDam,
        DamReservoirModel(
          reservoirCode: 'dam_bhakra',
          name: 'Bhakra Dam (Gobind Sagar)',
          river: 'Sutlej',
          basin: 'Ganga',
          state: 'Himachal Pradesh',
          latitude: 31.4100,
          longitude: 76.4350,
          fullReservoirLevelM: 515.1,
          currentLevelM: 508.6,
          liveStorageCapacityTmc: 218.0,
          currentStorageTmc: 183.0,
          storagePercent: 83.9,
          inflowCusecs: 24000.0,
          outflowCusecs: 19000.0,
          spillwayGatesOpen: 1,
          spillwayStatus: 'Controlled Discharge',
          downstreamAlert: 'Controlled irrigation & flood buffer discharge. Riparian areas cautioned.',
          distanceKm: 850.0,
        ),
      ],
      downstreamDirectives: [
        'Maintain vigilance along low-lying riverbanks and active floodplain sandbars.',
        'Do not attempt to ford or drive across submerged causeways or low bridges.',
        'Keep livestock evacuated to elevated embankments when dam spillway gates are opened.',
        'Fisherfolk and sand miners must avoid river channels during surplus discharge.',
      ],
      vernacularRiparianAlerts: {
        'ta': 'ஆற்றுப்படுகை வெள்ள எச்சரிக்கை: அணை நீர் வெளியேற்றத்தின் போது தாழ்வான கரையோரப் பகுதிகளைத் தவிர்க்கவும். ஆற்றில் இறங்க வேண்டாம்.',
        'hi': 'नदी कछार बाढ़ चेतावनी: बांध से पानी छोड़े जाने के दौरान निचले तटवर्ती क्षेत्रों से दूर रहें और मवेशियों को सुरक्षित ऊंचे स्थानों पर ले जाएं।',
        'bn': 'নদী অববাহিকা বন্যা সতর্কতা: বাঁধ থেকে জল ছাড়ার সময় নদীর তীরবর্তী নিচু এলাকা এড়িয়ে চলুন এবং নিরাপদ স্থানে আশ্রয় নিন।',
        'as': 'নৈপৰীয়া বান সতৰ্কতা: বান্ধৰ পৰা পানী এৰি দিয়াৰ সময়ত নৈৰ কাষৰীয়া চাপৰি অঞ্চলৰ পৰা সাৱধান হওক।',
      },
      provenanceAuthority: 'Central Water Commission (CWC) & Ministry of Jal Shakti Hydro-Telemetry (Offline Baseline)',
      lastUpdated: nowStr,
      isOfflineCached: true,
    );
  }
}
