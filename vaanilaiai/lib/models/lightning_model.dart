class LightningAlertModel {
  final String locationName;
  final String threatLevel;
  final double nearestStrikeKm;
  final int strikesLast30m;
  final String strikeTrend;
  final double capeThunderstormIndexJKg;
  final bool soundRumbleAudible;
  final String safetyRule3030;
  final List<String> fieldSafetyGuidance;
  final String lastUpdated;

  LightningAlertModel({
    required this.locationName,
    required this.threatLevel,
    required this.nearestStrikeKm,
    required this.strikesLast30m,
    required this.strikeTrend,
    required this.capeThunderstormIndexJKg,
    required this.soundRumbleAudible,
    required this.safetyRule3030,
    required this.fieldSafetyGuidance,
    required this.lastUpdated,
  });

  factory LightningAlertModel.fromJson(Map<String, dynamic> json) {
    return LightningAlertModel(
      locationName: json['location_name'] ?? 'Location',
      threatLevel: json['threat_level'] ?? 'Safe',
      nearestStrikeKm: (json['nearest_strike_km'] as num?)?.toDouble() ?? 42.0,
      strikesLast30m: (json['strikes_last_30m'] as num?)?.toInt() ?? 0,
      strikeTrend: json['strike_trend'] ?? 'Steady',
      capeThunderstormIndexJKg: (json['cape_thunderstorm_index_j_kg'] as num?)?.toDouble() ?? 350.0,
      soundRumbleAudible: json['sound_rumble_audible'] ?? false,
      safetyRule3030: json['safety_rule_30_30'] ?? 'Flash to bang under 30 seconds = Danger.',
      fieldSafetyGuidance: (json['field_safety_guidance'] as List?)?.map((e) => e.toString()).toList() ?? [],
      lastUpdated: json['last_updated'] ?? '',
    );
  }
}
