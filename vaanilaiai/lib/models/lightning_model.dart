class LightningAlertModel {
  final String locationName;
  final String threatLevel;
  final double nearestStrikeKm;
  final double flashToBangDelaySeconds;
  final int strikesLast30m;
  final String strikeTrend;
  final double capeThunderstormIndexJKg;
  final String capeStabilityVerdict;
  final bool soundRumbleAudible;
  final String safetyRule3030;
  final String shelter30minGuidance;
  final Map<String, String> vernacularDirectives;
  final List<String> fieldSafetyGuidance;
  final String lastUpdated;
  /// True when no real lightning detection data is available.
  final bool dataUnavailable;

  LightningAlertModel({
    required this.locationName,
    required this.threatLevel,
    required this.nearestStrikeKm,
    this.flashToBangDelaySeconds = 0.0,
    required this.strikesLast30m,
    required this.strikeTrend,
    required this.capeThunderstormIndexJKg,
    this.capeStabilityVerdict = 'Stable',
    required this.soundRumbleAudible,
    required this.safetyRule3030,
    this.shelter30minGuidance = 'Remain inside safe shelter for at least 30 minutes following the last observed thunderclap.',
    this.vernacularDirectives = const {},
    required this.fieldSafetyGuidance,
    required this.lastUpdated,
    this.dataUnavailable = false,
  });

  factory LightningAlertModel.fromJson(Map<String, dynamic> json) {
    final rawVernacular = json['vernacular_directives'] as Map<String, dynamic>?;
    final Map<String, String> vernMap = {};
    if (rawVernacular != null) {
      rawVernacular.forEach((key, value) {
        vernMap[key] = value.toString();
      });
    }

    return LightningAlertModel(
      locationName: json['location_name'] ?? 'Location',
      threatLevel: json['threat_level'] ?? 'Safe',
      nearestStrikeKm: (json['nearest_strike_km'] as num?)?.toDouble() ?? 42.0,
      flashToBangDelaySeconds: (json['flash_to_bang_delay_seconds'] as num?)?.toDouble() ??
          (((json['nearest_strike_km'] as num?)?.toDouble() ?? 42.0) * 2.92),
      strikesLast30m: (json['strikes_last_30m'] as num?)?.toInt() ?? 0,
      strikeTrend: json['strike_trend'] ?? 'Steady',
      capeThunderstormIndexJKg: (json['cape_thunderstorm_index_j_kg'] as num?)?.toDouble() ?? 350.0,
      capeStabilityVerdict: json['cape_stability_verdict'] ?? 'Stable',
      soundRumbleAudible: json['sound_rumble_audible'] ?? false,
      safetyRule3030: json['safety_rule_30_30'] ?? 'Flash to bang under 30 seconds = Danger.',
      shelter30minGuidance: json['shelter_30min_guidance'] ??
          'Remain inside safe shelter for at least 30 minutes following the last observed thunderclap.',
      vernacularDirectives: vernMap,
      fieldSafetyGuidance: (json['field_safety_guidance'] as List?)?.map((e) => e.toString()).toList() ?? [],
      lastUpdated: json['last_updated'] ?? '',
      dataUnavailable: json['data_unavailable'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_name': locationName,
      'threat_level': threatLevel,
      'nearest_strike_km': nearestStrikeKm,
      'flash_to_bang_delay_seconds': flashToBangDelaySeconds,
      'strikes_last_30m': strikesLast30m,
      'strike_trend': strikeTrend,
      'cape_thunderstorm_index_j_kg': capeThunderstormIndexJKg,
      'cape_stability_verdict': capeStabilityVerdict,
      'sound_rumble_audible': soundRumbleAudible,
      'safety_rule_30_30': safetyRule3030,
      'shelter_30min_guidance': shelter30minGuidance,
      'vernacular_directives': vernacularDirectives,
      'field_safety_guidance': fieldSafetyGuidance,
      'last_updated': lastUpdated,
      'data_unavailable': dataUnavailable,
    };
  }

  /// Creates an "unavailable" placeholder when the backend cannot be reached.
  factory LightningAlertModel.unavailable(String locationName) {
    return LightningAlertModel(
      locationName: locationName,
      threatLevel: 'Unknown',
      nearestStrikeKm: 0,
      flashToBangDelaySeconds: 0,
      strikesLast30m: 0,
      strikeTrend: 'Unknown',
      capeThunderstormIndexJKg: 0,
      capeStabilityVerdict: 'Unknown',
      soundRumbleAudible: false,
      safetyRule3030: 'Lightning data is currently unavailable. Follow standard 30-30 safety: seek shelter if thunder follows lightning in under 30 seconds.',
      shelter30minGuidance: 'Wait at least 30 minutes after the last thunderclap before leaving shelter.',
      vernacularDirectives: {
        'en': 'When thunder roars, go indoors. Seek sturdy shelter immediately.',
        'ta': 'இடி மின்னல் எச்சரிக்கை: திறந்தவெளிகளையோ மரங்களையோ தவிர்க்கவும். பாதுகாப்பான கட்டிடத்தில் இருக்கவும்.',
        'hi': 'बिजली चमकने और गड़गड़ाहट पर तुरंत पक्के मकान में जाएं। खुले मैदान में न रहें।',
      },
      fieldSafetyGuidance: [
        'Lightning detection data could not be loaded.',
        'If you see lightning or hear thunder, move indoors immediately.',
      ],
      lastUpdated: '',
      dataUnavailable: true,
    );
  }
}

