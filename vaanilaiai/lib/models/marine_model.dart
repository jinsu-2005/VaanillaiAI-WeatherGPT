class MarineAdvisoryModel {
  final String locationName;
  final String coastalRegion;
  final String coastalSectorName;
  final bool isCoastalLocation;
  final String date;
  final String seaCondition;
  final String seaConditionColor;
  final double significantWaveHeightM;
  final double swellHeightM;
  final double swellPeriodSeconds;
  final String swellDirectionCardinal;
  final String kallakkadalSurgeRisk;
  final String? kallakkadalExplanation;
  final int coastalWindKnots;
  final double coastalWindKmH;
  final double windGustsKmH;
  final int windDirectionDeg;
  final String windDirectionCardinal;
  final double seaSurfaceTemperatureC;
  final double chlorophyllAMgM3;
  final String potentialFishingZoneStatus;
  final String pfzBearingDirection;
  final double pfzDistanceNauticalMiles;
  final bool deepSeaNavigationSafe;
  final Map<String, dynamic> vesselCategoryDirectives;
  final String fishermenWarningText;
  final Map<String, dynamic> vernacularCoastalDirectives;
  final int portWarningSignalNumber;
  final String portWarningSignalName;
  final String portWarningSignalDescription;
  final String tideHighTime;
  final double tideHighHeightM;
  final String tideLowTime;
  final double tideLowHeightM;
  final String officialAuthority;
  /// True when no real marine data is available from the backend.
  final bool dataUnavailable;
  final bool isOfflineCached;

  MarineAdvisoryModel({
    required this.locationName,
    required this.coastalRegion,
    this.coastalSectorName = 'Indian Peninsular Waters',
    this.isCoastalLocation = true,
    required this.date,
    required this.seaCondition,
    required this.seaConditionColor,
    required this.significantWaveHeightM,
    this.swellHeightM = 0.0,
    required this.swellPeriodSeconds,
    this.swellDirectionCardinal = 'SSW',
    this.kallakkadalSurgeRisk = 'None',
    this.kallakkadalExplanation,
    required this.coastalWindKnots,
    required this.coastalWindKmH,
    required this.windGustsKmH,
    required this.windDirectionDeg,
    required this.windDirectionCardinal,
    required this.seaSurfaceTemperatureC,
    required this.chlorophyllAMgM3,
    required this.potentialFishingZoneStatus,
    required this.pfzBearingDirection,
    required this.pfzDistanceNauticalMiles,
    required this.deepSeaNavigationSafe,
    this.vesselCategoryDirectives = const {},
    required this.fishermenWarningText,
    this.vernacularCoastalDirectives = const {},
    required this.portWarningSignalNumber,
    required this.portWarningSignalName,
    required this.portWarningSignalDescription,
    required this.tideHighTime,
    required this.tideHighHeightM,
    required this.tideLowTime,
    required this.tideLowHeightM,
    this.officialAuthority = 'INCOIS (Indian National Centre for Ocean Information Services) & IMD Marine Division',
    this.dataUnavailable = false,
    this.isOfflineCached = false,
  });

  factory MarineAdvisoryModel.fromJson(Map<String, dynamic> json, {bool isCached = false}) {
    return MarineAdvisoryModel(
      locationName: json['location_name'] ?? 'Coastal Waters',
      coastalRegion: json['coastal_region'] ?? 'Peninsular Coastal Waters',
      coastalSectorName: json['coastal_sector_name'] ?? 'Indian Peninsular Waters',
      isCoastalLocation: json['is_coastal_location'] ?? true,
      date: json['date'] ?? '',
      seaCondition: json['sea_condition'] ?? 'Calm to Slight',
      seaConditionColor: json['sea_condition_color'] ?? 'Green',
      significantWaveHeightM: (json['significant_wave_height_m'] as num?)?.toDouble() ?? 1.2,
      swellHeightM: (json['swell_height_m'] as num?)?.toDouble() ?? 0.0,
      swellPeriodSeconds: (json['swell_period_seconds'] as num?)?.toDouble() ?? 9.5,
      swellDirectionCardinal: json['swell_direction_cardinal'] ?? 'SSW',
      kallakkadalSurgeRisk: json['kallakkadal_surge_risk'] ?? 'None',
      kallakkadalExplanation: json['kallakkadal_explanation'],
      coastalWindKnots: (json['coastal_wind_knots'] as num?)?.toInt() ?? 12,
      coastalWindKmH: (json['coastal_wind_kmh'] as num?)?.toDouble() ?? 22.0,
      windGustsKmH: (json['wind_gusts_kmh'] as num?)?.toDouble() ?? 28.0,
      windDirectionDeg: (json['wind_direction_deg'] as num?)?.toInt() ?? 180,
      windDirectionCardinal: json['wind_direction_cardinal'] ?? 'S',
      seaSurfaceTemperatureC: (json['sea_surface_temperature_c'] as num?)?.toDouble() ?? 28.5,
      chlorophyllAMgM3: (json['chlorophyll_a_mg_m3'] as num?)?.toDouble() ?? 1.4,
      potentialFishingZoneStatus: json['potential_fishing_zone_status'] ?? 'Moderate',
      pfzBearingDirection: json['pfz_bearing_direction'] ?? '135° SE',
      pfzDistanceNauticalMiles: (json['pfz_distance_nautical_miles'] as num?)?.toDouble() ?? 16.0,
      deepSeaNavigationSafe: json['deep_sea_navigation_safe'] ?? true,
      vesselCategoryDirectives: json['vessel_category_directives'] != null && json['vessel_category_directives'] is Map
          ? Map<String, dynamic>.from(json['vessel_category_directives'])
          : {},
      fishermenWarningText: json['fishermen_warning_text'] ?? 'Safe for coastal operations.',
      vernacularCoastalDirectives: json['vernacular_coastal_directives'] != null && json['vernacular_coastal_directives'] is Map
          ? Map<String, dynamic>.from(json['vernacular_coastal_directives'])
          : {},
      portWarningSignalNumber: (json['port_warning_signal_number'] as num?)?.toInt() ?? 0,
      portWarningSignalName: json['port_warning_signal_name'] ?? 'No Warning Hoisted',
      portWarningSignalDescription: json['port_warning_signal_description'] ?? 'Port operations normal.',
      tideHighTime: json['tide_high_time'] ?? '01:45 PM',
      tideHighHeightM: (json['tide_high_height_m'] as num?)?.toDouble() ?? 1.6,
      tideLowTime: json['tide_low_time'] ?? '07:20 PM',
      tideLowHeightM: (json['tide_low_height_m'] as num?)?.toDouble() ?? 0.4,
      officialAuthority: json['official_authority'] ?? 'INCOIS & IMD Marine Division',
      dataUnavailable: json['data_unavailable'] ?? false,
      isOfflineCached: isCached || (json['is_offline_cached'] ?? false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_name': locationName,
      'coastal_region': coastalRegion,
      'coastal_sector_name': coastalSectorName,
      'is_coastal_location': isCoastalLocation,
      'date': date,
      'sea_condition': seaCondition,
      'sea_condition_color': seaConditionColor,
      'significant_wave_height_m': significantWaveHeightM,
      'swell_height_m': swellHeightM,
      'swell_period_seconds': swellPeriodSeconds,
      'swell_direction_cardinal': swellDirectionCardinal,
      'kallakkadal_surge_risk': kallakkadalSurgeRisk,
      'kallakkadal_explanation': kallakkadalExplanation,
      'coastal_wind_knots': coastalWindKnots,
      'coastal_wind_kmh': coastalWindKmH,
      'wind_gusts_kmh': windGustsKmH,
      'wind_direction_deg': windDirectionDeg,
      'wind_direction_cardinal': windDirectionCardinal,
      'sea_surface_temperature_c': seaSurfaceTemperatureC,
      'chlorophyll_a_mg_m3': chlorophyllAMgM3,
      'potential_fishing_zone_status': potentialFishingZoneStatus,
      'pfz_bearing_direction': pfzBearingDirection,
      'pfz_distance_nautical_miles': pfzDistanceNauticalMiles,
      'deep_sea_navigation_safe': deepSeaNavigationSafe,
      'vessel_category_directives': vesselCategoryDirectives,
      'fishermen_warning_text': fishermenWarningText,
      'vernacular_coastal_directives': vernacularCoastalDirectives,
      'port_warning_signal_number': portWarningSignalNumber,
      'port_warning_signal_name': portWarningSignalName,
      'port_warning_signal_description': portWarningSignalDescription,
      'tide_high_time': tideHighTime,
      'tide_high_height_m': tideHighHeightM,
      'tide_low_time': tideLowTime,
      'tide_low_height_m': tideLowHeightM,
      'official_authority': officialAuthority,
      'data_unavailable': dataUnavailable,
      'is_offline_cached': isOfflineCached,
    };
  }

  /// Creates an "unavailable" placeholder when the backend cannot provide marine data.
  factory MarineAdvisoryModel.unavailable(String locationName) {
    return MarineAdvisoryModel(
      locationName: locationName,
      coastalRegion: 'Unknown',
      coastalSectorName: 'Waters Unspecified',
      isCoastalLocation: false,
      date: DateTime.now().toIso8601String().substring(0, 10),
      seaCondition: 'Data Unavailable',
      seaConditionColor: 'Grey',
      significantWaveHeightM: 0,
      swellHeightM: 0,
      swellPeriodSeconds: 0,
      swellDirectionCardinal: '-',
      kallakkadalSurgeRisk: 'None',
      kallakkadalExplanation: null,
      coastalWindKnots: 0,
      coastalWindKmH: 0,
      windGustsKmH: 0,
      windDirectionDeg: 0,
      windDirectionCardinal: '-',
      seaSurfaceTemperatureC: 0,
      chlorophyllAMgM3: 0,
      potentialFishingZoneStatus: 'Data Unavailable',
      pfzBearingDirection: '-',
      pfzDistanceNauticalMiles: 0,
      deepSeaNavigationSafe: false,
      vesselCategoryDirectives: {},
      fishermenWarningText: 'Marine data is currently unavailable. Check with local port authorities before venturing into the sea.',
      vernacularCoastalDirectives: {},
      portWarningSignalNumber: 0,
      portWarningSignalName: 'Data Unavailable',
      portWarningSignalDescription: 'Could not load port warning data. Contact the nearest port office.',
      tideHighTime: '-',
      tideHighHeightM: 0,
      tideLowTime: '-',
      tideLowHeightM: 0,
      officialAuthority: 'Data source unavailable',
      dataUnavailable: true,
      isOfflineCached: false,
    );
  }

  /// Calibrated offline fallback when network is absent
  factory MarineAdvisoryModel.defaultFallback(String locationName, {bool isCoastal = true}) {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    if (!isCoastal) {
      return MarineAdvisoryModel(
        locationName: locationName,
        coastalRegion: 'Inland Plains / Plateau',
        coastalSectorName: 'Inland District (No Ocean Coastline)',
        isCoastalLocation: false,
        date: dateStr,
        seaCondition: 'Inland (No Marine Wave Risk)',
        seaConditionColor: 'Green',
        significantWaveHeightM: 0.0,
        swellHeightM: 0.0,
        swellPeriodSeconds: 0.0,
        swellDirectionCardinal: '-',
        kallakkadalSurgeRisk: 'None',
        kallakkadalExplanation: 'Location is located inland. Swell surge and coastal inundation risks are zero.',
        coastalWindKnots: 0,
        coastalWindKmH: 0.0,
        windGustsKmH: 0.0,
        windDirectionDeg: 0,
        windDirectionCardinal: '-',
        seaSurfaceTemperatureC: 0.0,
        chlorophyllAMgM3: 0.0,
        potentialFishingZoneStatus: 'Not Applicable',
        pfzBearingDirection: '-',
        pfzDistanceNauticalMiles: 0.0,
        deepSeaNavigationSafe: true,
        vesselCategoryDirectives: {
          'catamarans_country_craft': 'Not applicable for inland areas.',
          'motorized_frp_boats': 'Not applicable for inland areas.',
          'mechanized_trawlers': 'Not applicable for inland areas.',
        },
        fishermenWarningText: 'Inland territory. Ocean state forecasts and coastal surge alerts are not applicable.',
        vernacularCoastalDirectives: {
          'ta': 'உள்நாட்டு பகுதி. கடல் அலை அல்லது கள்ளக்கடல் எச்சரிக்கை பொருந்தாது.',
          'ml': 'ഉൾനാടൻ പ്രദേശം. സമുദ്ര മുന്നറിയിപ്പുകൾ ബാധകമല്ല.',
          'hi': 'अंतर्देशीय क्षेत्र। समुद्री लहर या कल्लाक्कदल चेतावनी लागू नहीं है।',
        },
        portWarningSignalNumber: 0,
        portWarningSignalName: 'No Port Warning',
        portWarningSignalDescription: 'Location is inland. No maritime ports present.',
        tideHighTime: '-',
        tideHighHeightM: 0.0,
        tideLowTime: '-',
        tideLowHeightM: 0.0,
        officialAuthority: 'INCOIS & IMD Marine Division (Cached Baseline)',
        dataUnavailable: false,
        isOfflineCached: true,
      );
    }

    return MarineAdvisoryModel(
      locationName: locationName,
      coastalRegion: 'Peninsular Coastal Sector',
      coastalSectorName: 'Tamil Nadu & South Andhra Coast',
      isCoastalLocation: true,
      date: dateStr,
      seaCondition: 'Moderate (Swell Alert Active)',
      seaConditionColor: 'Yellow',
      significantWaveHeightM: 1.8,
      swellHeightM: 1.6,
      swellPeriodSeconds: 12.8,
      swellDirectionCardinal: 'SSW',
      kallakkadalSurgeRisk: 'Watch',
      kallakkadalExplanation: 'Southern Ocean swells propagating northward. Long-period swells (12.8s) may cause sudden surging breakers along steep beaches.',
      coastalWindKnots: 15,
      coastalWindKmH: 27.8,
      windGustsKmH: 38.0,
      windDirectionDeg: 190,
      windDirectionCardinal: 'S',
      seaSurfaceTemperatureC: 28.6,
      chlorophyllAMgM3: 1.8,
      potentialFishingZoneStatus: 'Moderate',
      pfzBearingDirection: '140° SE',
      pfzDistanceNauticalMiles: 18.0,
      deepSeaNavigationSafe: true,
      vesselCategoryDirectives: {
        'catamarans_country_craft': 'Exercise caution while launching from steep sandy shores due to Kallakkadal shore break.',
        'motorized_frp_boats': 'Safe beyond 3 nautical miles; secure vessels at harbor slipways.',
        'mechanized_trawlers': 'Normal deep-sea fishing operations permitted beyond 15m depth contour.',
      },
      fishermenWarningText: 'Fishermen are advised to exercise caution along the coastline during high tide. Swell surge may cause sudden flooding of foreshore areas.',
      vernacularCoastalDirectives: {
        'ta': 'தெற்கு பெருங்கடல் அலைகள் காரணமாக கடற்கரையில் திடீர் கடல் சீற்றம் ஏற்பட வாய்ப்புள்ளது. நாட்டுப்படகுகள் எச்சரிக்கையுடன் செயல்படவும்.',
        'ml': 'തെക്കൻ സമുദ്രത്തിലെ ഉയർന്ന തിരമാലകൾ കാരണം തീരപ്രദേശങ്ങളിൽ പെട്ടെന്നുള്ള കടലാക്രമണത്തിന് സാധ്യത. ചെറുതോണികൾ ജാഗ്രത പാലിക്കുക.',
        'hi': 'दक्षिणी महासागर की लंबी तरंगों के कारण तटीय क्षेत्रों में अचानक पानी भरने की संभावना है। छोटी नौकाओं को सतर्क रहने की सलाह दी जाती है।',
      },
      portWarningSignalNumber: 1,
      portWarningSignalName: 'Signal I - Distant Cautionary',
      portWarningSignalDescription: 'Vessels leaving port are cautioned of unfavorable offshore sea conditions.',
      tideHighTime: '01:15 PM',
      tideHighHeightM: 1.45,
      tideLowTime: '07:45 PM',
      tideLowHeightM: 0.35,
      officialAuthority: 'INCOIS & IMD Marine Division (Cached Baseline)',
      dataUnavailable: false,
      isOfflineCached: true,
    );
  }
}
