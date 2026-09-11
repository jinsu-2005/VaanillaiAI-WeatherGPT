class MarineAdvisoryModel {
  final String locationName;
  final String coastalRegion;
  final String date;
  final String seaCondition;
  final String seaConditionColor;
  final double significantWaveHeightM;
  final double swellPeriodSeconds;
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
  final String fishermenWarningText;
  final int portWarningSignalNumber;
  final String portWarningSignalName;
  final String portWarningSignalDescription;
  final String tideHighTime;
  final double tideHighHeightM;
  final String tideLowTime;
  final double tideLowHeightM;
  final String officialAuthority;

  MarineAdvisoryModel({
    required this.locationName,
    required this.coastalRegion,
    required this.date,
    required this.seaCondition,
    required this.seaConditionColor,
    required this.significantWaveHeightM,
    required this.swellPeriodSeconds,
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
    required this.fishermenWarningText,
    required this.portWarningSignalNumber,
    required this.portWarningSignalName,
    required this.portWarningSignalDescription,
    required this.tideHighTime,
    required this.tideHighHeightM,
    required this.tideLowTime,
    required this.tideLowHeightM,
    this.officialAuthority = 'INCOIS (Indian National Centre for Ocean Information Services) & IMD Marine Division',
  });

  factory MarineAdvisoryModel.fromJson(Map<String, dynamic> json) {
    return MarineAdvisoryModel(
      locationName: json['location_name'] ?? 'Coastal Waters',
      coastalRegion: json['coastal_region'] ?? 'Peninsular Coastal Waters',
      date: json['date'] ?? '',
      seaCondition: json['sea_condition'] ?? 'Calm to Slight',
      seaConditionColor: json['sea_condition_color'] ?? 'Green',
      significantWaveHeightM: (json['significant_wave_height_m'] as num?)?.toDouble() ?? 1.2,
      swellPeriodSeconds: (json['swell_period_seconds'] as num?)?.toDouble() ?? 9.5,
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
      fishermenWarningText: json['fishermen_warning_text'] ?? 'Safe for coastal operations.',
      portWarningSignalNumber: (json['port_warning_signal_number'] as num?)?.toInt() ?? 0,
      portWarningSignalName: json['port_warning_signal_name'] ?? 'No Warning Hoisted',
      portWarningSignalDescription: json['port_warning_signal_description'] ?? 'Port operations normal.',
      tideHighTime: json['tide_high_time'] ?? '01:45 PM',
      tideHighHeightM: (json['tide_high_height_m'] as num?)?.toDouble() ?? 1.6,
      tideLowTime: json['tide_low_time'] ?? '07:20 PM',
      tideLowHeightM: (json['tide_low_height_m'] as num?)?.toDouble() ?? 0.4,
      officialAuthority: json['official_authority'] ?? 'INCOIS & IMD Marine Division',
    );
  }
}
