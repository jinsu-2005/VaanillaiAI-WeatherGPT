class SeaStateWaveMetricsModel {
  final double significantWaveHeightM;
  final double maximumWaveHeightM;
  final double peakWavePeriodS;
  final double meanWaveDirectionDeg;
  final double waveSteepnessRatio;
  final double seaSurfaceCurrentSpeedKnots;

  const SeaStateWaveMetricsModel({
    required this.significantWaveHeightM,
    required this.maximumWaveHeightM,
    required this.peakWavePeriodS,
    required this.meanWaveDirectionDeg,
    required this.waveSteepnessRatio,
    required this.seaSurfaceCurrentSpeedKnots,
  });

  factory SeaStateWaveMetricsModel.fromJson(Map<String, dynamic> json) {
    return SeaStateWaveMetricsModel(
      significantWaveHeightM: (json['significant_wave_height_m'] as num?)?.toDouble() ?? 2.0,
      maximumWaveHeightM: (json['maximum_wave_height_m'] as num?)?.toDouble() ?? 3.5,
      peakWavePeriodS: (json['peak_wave_period_s'] as num?)?.toDouble() ?? 12.0,
      meanWaveDirectionDeg: (json['mean_wave_direction_deg'] as num?)?.toDouble() ?? 190.0,
      waveSteepnessRatio: (json['wave_steepness_ratio'] as num?)?.toDouble() ?? 0.04,
      seaSurfaceCurrentSpeedKnots: (json['sea_surface_current_speed_knots'] as num?)?.toDouble() ?? 1.5,
    );
  }

  Map<String, dynamic> toJson() => {
        'significant_wave_height_m': significantWaveHeightM,
        'maximum_wave_height_m': maximumWaveHeightM,
        'peak_wave_period_s': peakWavePeriodS,
        'mean_wave_direction_deg': meanWaveDirectionDeg,
        'wave_steepness_ratio': waveSteepnessRatio,
        'sea_surface_current_speed_knots': seaSurfaceCurrentSpeedKnots,
      };
}

class SwellSurgeKallakkadalMetricsModel {
  final bool isKallakkadalActive;
  final String distantSourceBasin;
  final double swellWavePeriodS;
  final String coastalOverwashRisk;
  final String artisanCraftAnchoringDirective;

  const SwellSurgeKallakkadalMetricsModel({
    required this.isKallakkadalActive,
    required this.distantSourceBasin,
    required this.swellWavePeriodS,
    required this.coastalOverwashRisk,
    required this.artisanCraftAnchoringDirective,
  });

  factory SwellSurgeKallakkadalMetricsModel.fromJson(Map<String, dynamic> json) {
    return SwellSurgeKallakkadalMetricsModel(
      isKallakkadalActive: json['is_kallakkadal_active'] as bool? ?? false,
      distantSourceBasin: json['distant_source_basin'] as String? ?? 'Indian Ocean Swells',
      swellWavePeriodS: (json['swell_wave_period_s'] as num?)?.toDouble() ?? 12.0,
      coastalOverwashRisk: json['coastal_overwash_risk'] as String? ?? 'MODERATE',
      artisanCraftAnchoringDirective:
          json['artisan_craft_anchoring_directive'] as String? ?? 'Secure crafts above high water mark',
    );
  }

  Map<String, dynamic> toJson() => {
        'is_kallakkadal_active': isKallakkadalActive,
        'distant_source_basin': distantSourceBasin,
        'swell_wave_period_s': swellWavePeriodS,
        'coastal_overwash_risk': coastalOverwashRisk,
        'artisan_craft_anchoring_directive': artisanCraftAnchoringDirective,
      };
}

class RipCurrentMetricsModel {
  final String riskLevel;
  final double peakRipVelocityMs;
  final List<String> ripChannelLocations;
  final String ripSurvivalInstruction;

  const RipCurrentMetricsModel({
    required this.riskLevel,
    required this.peakRipVelocityMs,
    required this.ripChannelLocations,
    required this.ripSurvivalInstruction,
  });

  factory RipCurrentMetricsModel.fromJson(Map<String, dynamic> json) {
    return RipCurrentMetricsModel(
      riskLevel: json['risk_level'] as String? ?? 'MODERATE_CAUTION',
      peakRipVelocityMs: (json['peak_rip_velocity_ms'] as num?)?.toDouble() ?? 0.8,
      ripChannelLocations: (json['rip_channel_locations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      ripSurvivalInstruction: json['rip_survival_instruction'] as String? ??
          'Swim parallel to the shoreline until free of the rip channel, then swim diagonally back to the beach.',
    );
  }

  Map<String, dynamic> toJson() => {
        'risk_level': riskLevel,
        'peak_rip_velocity_ms': peakRipVelocityMs,
        'rip_channel_locations': ripChannelLocations,
        'rip_survival_instruction': ripSurvivalInstruction,
      };
}

class BeachSafetyAndMaritimeDirectivesModel {
  final String lifeguardFlag;
  final String bathingSwimmingAdvisory;
  final String waterSportsStatus;
  final String countryBoatCatamaranDirective;
  final String deepSeaTrawlerAdvisory;
  final int activeLifeguardTowersCount;

  const BeachSafetyAndMaritimeDirectivesModel({
    required this.lifeguardFlag,
    required this.bathingSwimmingAdvisory,
    required this.waterSportsStatus,
    required this.countryBoatCatamaranDirective,
    required this.deepSeaTrawlerAdvisory,
    required this.activeLifeguardTowersCount,
  });

  factory BeachSafetyAndMaritimeDirectivesModel.fromJson(Map<String, dynamic> json) {
    return BeachSafetyAndMaritimeDirectivesModel(
      lifeguardFlag: json['lifeguard_flag'] as String? ?? 'YELLOW_MEDIUM_HAZARD',
      bathingSwimmingAdvisory:
          json['bathing_swimming_advisory'] as String? ?? 'Swim only within designated lifeguard zones',
      waterSportsStatus: json['water_sports_status'] as String? ?? 'Operate with caution',
      countryBoatCatamaranDirective:
          json['country_boat_catamaran_directive'] as String? ?? 'Artisanal crafts maintain lookout',
      deepSeaTrawlerAdvisory:
          json['deep_sea_trawler_advisory'] as String? ?? 'Monitor coastal VHF frequencies',
      activeLifeguardTowersCount: (json['active_lifeguard_towers_count'] as num?)?.toInt() ?? 4,
    );
  }

  Map<String, dynamic> toJson() => {
        'lifeguard_flag': lifeguardFlag,
        'bathing_swimming_advisory': bathingSwimmingAdvisory,
        'water_sports_status': waterSportsStatus,
        'country_boat_catamaran_directive': countryBoatCatamaranDirective,
        'deep_sea_trawler_advisory': deepSeaTrawlerAdvisory,
        'active_lifeguard_towers_count': activeLifeguardTowersCount,
      };
}

class CoastalBeachSectorModel {
  final String beachId;
  final String beachName;
  final String coastalDistrict;
  final String state;
  final String waterBody;
  final double latitude;
  final double longitude;
  final String alertTier;
  final SeaStateWaveMetricsModel waveMetrics;
  final SwellSurgeKallakkadalMetricsModel swellSurge;
  final RipCurrentMetricsModel ripCurrent;
  final BeachSafetyAndMaritimeDirectivesModel directives;
  final Map<String, String> vernacularBroadcasts;

  const CoastalBeachSectorModel({
    required this.beachId,
    required this.beachName,
    required this.coastalDistrict,
    required this.state,
    required this.waterBody,
    required this.latitude,
    required this.longitude,
    required this.alertTier,
    required this.waveMetrics,
    required this.swellSurge,
    required this.ripCurrent,
    required this.directives,
    required this.vernacularBroadcasts,
  });

  factory CoastalBeachSectorModel.fromJson(Map<String, dynamic> json) {
    return CoastalBeachSectorModel(
      beachId: json['beach_id'] as String? ?? 'puri_golden_beach_or',
      beachName: json['beach_name'] as String? ?? 'Puri Golden Beach',
      coastalDistrict: json['coastal_district'] as String? ?? 'Puri',
      state: json['state'] as String? ?? 'Odisha',
      waterBody: json['water_body'] as String? ?? 'Bay of Bengal',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 19.80,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 85.82,
      alertTier: json['alert_tier'] as String? ?? 'ORANGE_ALERT',
      waveMetrics: SeaStateWaveMetricsModel.fromJson(
          json['wave_metrics'] as Map<String, dynamic>? ?? {}),
      swellSurge: SwellSurgeKallakkadalMetricsModel.fromJson(
          json['swell_surge'] as Map<String, dynamic>? ?? {}),
      ripCurrent: RipCurrentMetricsModel.fromJson(
          json['rip_current'] as Map<String, dynamic>? ?? {}),
      directives: BeachSafetyAndMaritimeDirectivesModel.fromJson(
          json['directives'] as Map<String, dynamic>? ?? {}),
      vernacularBroadcasts: (json['vernacular_broadcasts'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          const {},
    );
  }

  Map<String, dynamic> toJson() => {
        'beach_id': beachId,
        'beach_name': beachName,
        'coastal_district': coastalDistrict,
        'state': state,
        'water_body': waterBody,
        'latitude': latitude,
        'longitude': longitude,
        'alert_tier': alertTier,
        'wave_metrics': waveMetrics.toJson(),
        'swell_surge': swellSurge.toJson(),
        'rip_current': ripCurrent.toJson(),
        'directives': directives.toJson(),
        'vernacular_broadcasts': vernacularBroadcasts,
      };
}

class OceanStateResponseModel {
  final String timestamp;
  final String bulletinNumber;
  final String provenance;
  final String nationalSeaStateSynopsis;
  final CoastalBeachSectorModel selectedBeach;
  final List<CoastalBeachSectorModel> allBeaches;
  final String numericalModelWaveWatch;
  final Map<String, String> vernacularBroadcasts;
  final bool isOfflineCached;

  const OceanStateResponseModel({
    required this.timestamp,
    required this.bulletinNumber,
    required this.provenance,
    required this.nationalSeaStateSynopsis,
    required this.selectedBeach,
    required this.allBeaches,
    required this.numericalModelWaveWatch,
    required this.vernacularBroadcasts,
    this.isOfflineCached = false,
  });

  factory OceanStateResponseModel.fromJson(Map<String, dynamic> json) {
    return OceanStateResponseModel(
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      bulletinNumber: json['bulletin_number'] as String? ?? 'INCOIS-OSF/WAVE-RIP/OFFLINE',
      provenance: json['provenance'] as String? ??
          'INCOIS Ocean State Forecast (OSF) & Coastal Rip Current Warning System',
      nationalSeaStateSynopsis: json['national_sea_state_synopsis'] as String? ??
          'Indian Coastal Ocean State Forecast & Beach Lifeguard Monitoring Active',
      selectedBeach: CoastalBeachSectorModel.fromJson(
          json['selected_beach'] as Map<String, dynamic>? ?? {}),
      allBeaches: (json['all_beaches'] as List<dynamic>?)
              ?.map((e) => CoastalBeachSectorModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      numericalModelWaveWatch: json['numerical_model_wave_watch'] as String? ??
          'WAVEWATCH-III Global Ocean Wave Model + Nearshore SWAN Hydrodynamic Wave Simulation',
      vernacularBroadcasts: (json['vernacular_broadcasts'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          const {},
      isOfflineCached: json['is_offline_cached'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'bulletin_number': bulletinNumber,
        'provenance': provenance,
        'national_sea_state_synopsis': nationalSeaStateSynopsis,
        'selected_beach': selectedBeach.toJson(),
        'all_beaches': allBeaches.map((e) => e.toJson()).toList(),
        'numerical_model_wave_watch': numericalModelWaveWatch,
        'vernacular_broadcasts': vernacularBroadcasts,
        'is_offline_cached': isOfflineCached,
      };

  factory OceanStateResponseModel.defaultFallback() {
    const puri = CoastalBeachSectorModel(
      beachId: 'puri_golden_beach_or',
      beachName: 'Puri Golden Beach & Swargadwar',
      coastalDistrict: 'Puri',
      state: 'Odisha',
      waterBody: 'Bay of Bengal',
      latitude: 19.7983,
      longitude: 85.8249,
      alertTier: 'ORANGE_ALERT',
      waveMetrics: SeaStateWaveMetricsModel(
        significantWaveHeightM: 3.20,
        maximumWaveHeightM: 5.40,
        peakWavePeriodS: 13.5,
        meanWaveDirectionDeg: 195.0,
        waveSteepnessRatio: 0.042,
        seaSurfaceCurrentSpeedKnots: 2.4,
      ),
      swellSurge: SwellSurgeKallakkadalMetricsModel(
        isKallakkadalActive: false,
        distantSourceBasin: 'Central Bay of Bengal Wind Wave Forcing',
        swellWavePeriodS: 13.5,
        coastalOverwashRisk: 'HIGH',
        artisanCraftAnchoringDirective:
            'Artisanal country catamarans and FRP boats must be secured at least 15m inland above the high tide waterline.',
      ),
      ripCurrent: RipCurrentMetricsModel(
        riskLevel: 'HIGH_DEADLY',
        peakRipVelocityMs: 1.45,
        ripChannelLocations: [
          'Swargadwar Cremation Ghat Channel',
          'Digabareni Watchtower Sandbar Gap',
          'Chakratirtha Rocky Outcrop Confluence',
        ],
        ripSurvivalInstruction:
            'DO NOT swim directly against the seaward pull. Relax, float, and swim parallel to the shoreline until out of the narrow rip channel, then swim diagonally back to the beach.',
      ),
      directives: BeachSafetyAndMaritimeDirectivesModel(
        lifeguardFlag: 'RED_HIGH_HAZARD',
        bathingSwimmingAdvisory:
            'Sea bathing strictly discouraged. Holy pilgrim dips restricted to knee-depth only under direct supervision of trained Nulia community lifeguards.',
        waterSportsStatus: 'All recreational watercraft, speedboats, and beach dune buggies halted.',
        countryBoatCatamaranDirective:
            'Artisanal non-motorized fishing crafts prohibited from launching past breaking surf zone.',
        deepSeaTrawlerAdvisory:
            'Mechanized trawlers advised to monitor VHF Channel 16 for rough sea advisories.',
        activeLifeguardTowersCount: 8,
      ),
      vernacularBroadcasts: {
        'en':
            'HIGH WAVE & RIP CURRENT ALERT: Puri Golden Beach experiencing rough surf (Hs 3.2m) with deadly rip currents (1.45 m/s). Red warning flags hoisted. Avoid deep sea bathing; adhere strictly to Nulia lifeguard instructions.',
        'hi':
            'उच्च समुद्री लहर व रिप करंट चेतावनी: पुरी गोल्डन बीच पर 3.2 मीटर ऊंची लहरें और 1.45 मीटर/सेकंड का जानलेवा रिप करंट दर्ज। लाल झंडे लगाए गए हैं। गहरे पानी में स्नान पूरी तरह वर्जित है।',
        'or':
            'ଉଚ୍ଚ ଜୁଆର ଓ ରିପ୍ କରେଣ୍ଟ ଚେତାବନୀ: ପୁରୀ ସ୍ୱର୍ଣ୍ଣିମ ବେଳାଭୂମିରେ ସମୁଦ୍ର ଅଶାନ୍ତ ରହିଛି (ତରଙ୍ଗ ଉଚ୍ଚତା ୩.୨୦ ମିଟର)। ବିପଦଜନକ ଲୁକ୍କାୟିତ ଜଳସ୍ରୋତ ଯୋଗୁଁ ଗଭୀର ସମୁଦ୍ରରେ ସ୍ନାନ ସମ୍ପୂର୍ଣ୍ଣ ନିଷେଧ।',
      },
    );

    const kovalam = CoastalBeachSectorModel(
      beachId: 'kovalam_vizhinjam_kl',
      beachName: 'Kovalam Lighthouse Beach & Vizhinjam',
      coastalDistrict: 'Thiruvananthapuram',
      state: 'Kerala',
      waterBody: 'Arabian Sea & Laccadive Sea Confluence',
      latitude: 8.3988,
      longitude: 76.9785,
      alertTier: 'RED_WARNING',
      waveMetrics: SeaStateWaveMetricsModel(
        significantWaveHeightM: 3.85,
        maximumWaveHeightM: 6.30,
        peakWavePeriodS: 18.5,
        meanWaveDirectionDeg: 220.0,
        waveSteepnessRatio: 0.038,
        seaSurfaceCurrentSpeedKnots: 2.8,
      ),
      swellSurge: SwellSurgeKallakkadalMetricsModel(
        isKallakkadalActive: true,
        distantSourceBasin:
            'Southern Indian Ocean (48°S Roaring Forties Low-Pressure Cyclone Belt)',
        swellWavePeriodS: 18.5,
        coastalOverwashRisk: 'CRITICAL',
        artisanCraftAnchoringDirective:
            'MANDATORY: Evacuate all fishing crafts and beach shacks at least 25 meters inland. Extreme high energy swell overwash active.',
      ),
      ripCurrent: RipCurrentMetricsModel(
        riskLevel: 'HIGH_DEADLY',
        peakRipVelocityMs: 1.65,
        ripChannelLocations: [
          'Lighthouse Promontory Reef Gap',
          'Hawa Beach Headland Chute',
          'Vizhinjam Breakwater Shoreline',
        ],
        ripSurvivalInstruction:
            'Extreme rip channel. Never attempt swimming against the current. Signal for lifeguard rescue by waving one arm while treading water.',
      ),
      directives: BeachSafetyAndMaritimeDirectivesModel(
        lifeguardFlag: 'DOUBLE_RED_PROHIBITED',
        bathingSwimmingAdvisory:
            'BEACH CLOSED TO PUBLIC: High surge runup washing over promenade. Zero water contact permitted. Coastal police deployed to clear beachfront.',
        waterSportsStatus:
            'All surfing, kayaking, and coastal tourism vessels completely suspended.',
        countryBoatCatamaranDirective:
            'Artisanal country craft fishing completely banned. Trawlers secured behind Vizhinjam international seaport breakwater.',
        deepSeaTrawlerAdvisory: 'Offshore vessels must remain outside 50-meter depth contour.',
        activeLifeguardTowersCount: 6,
      ),
      vernacularBroadcasts: {
        'en':
            'KALLAKKADAL SWELL SURGE WARNING (RED ALERT): Kovalam & Vizhinjam experiencing severe long-period swell overwash (Tp 18.5s, Hs 3.85m) from distant Southern Ocean storms. Beach closed; all sea entry prohibited.',
        'hi':
            'कल्लाक्कदल महासागरीय लहर चेतावनी (रेड अलर्ट): कोवलम और विझिंजम तट पर दक्षिणी महासागर से उत्पन्न विनाशकारी लंबी अवधि की लहरें पहुंच रही हैं। समुद्र तट पूरी तरह बंद है; पानी में प्रवेश सख्त वर्जित है।',
        'ml':
            'കള്ളക്കടൽ മുന്നറിയിപ്പ് (ചുവപ്പ് ജാഗ്രത): ദക്ഷിണ ഇന്ത്യൻ മഹാസമുദ്രത്തിലെ അതിതീവ്ര കാറ്റിന്റെ ഫലമായി കോവളം, വിഴിഞ്ഞം തീരങ്ങളിൽ 3.85 മീറ്റർ ഉയർന്ന രാക്ഷസത്തിരകൾ കരയിലേക്ക് അടിച്ചുകയറുന്നു. ബീച്ചുകൾ പൂർണ്ണമായി അടച്ചു; കടലിൽ ഇറങ്ങുന്നത് നിരോധിച്ചു.',
      },
    );

    return OceanStateResponseModel(
      timestamp: '2026-09-12T06:00:00Z',
      bulletinNumber: 'INCOIS-OSF/WAVE-RIP/202609-PURI',
      provenance:
          'INCOIS Ocean State Forecast (OSF) & Coastal Rip Current Warning System',
      nationalSeaStateSynopsis:
          'ROUGH SURF: High Wave Threat & Hazardous Rip Channels (Orange Alert)',
      selectedBeach: puri,
      allBeaches: const [puri, kovalam],
      numericalModelWaveWatch:
          'WAVEWATCH-III Global Ocean Wave Model + Nearshore SWAN Hydrodynamic Wave Simulation',
      vernacularBroadcasts: puri.vernacularBroadcasts,
      isOfflineCached: true,
    );
  }
}
