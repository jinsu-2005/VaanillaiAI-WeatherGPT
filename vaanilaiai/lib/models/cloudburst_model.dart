class OrographicPrecipitationModel {
  final double rainRateMmHr;
  final double accumulated3hMm;
  final double accumulated24hMm;
  final double condensationLevelM;
  final double cloudTopHeightKm;
  final double radarReflectivityDbz;
  final String cloudburstCategory;

  const OrographicPrecipitationModel({
    required this.rainRateMmHr,
    required this.accumulated3hMm,
    required this.accumulated24hMm,
    required this.condensationLevelM,
    required this.cloudTopHeightKm,
    required this.radarReflectivityDbz,
    required this.cloudburstCategory,
  });

  factory OrographicPrecipitationModel.fromJson(Map<String, dynamic> json) {
    return OrographicPrecipitationModel(
      rainRateMmHr: (json['rain_rate_mm_hr'] as num?)?.toDouble() ?? 0.0,
      accumulated3hMm: (json['accumulated_3h_mm'] as num?)?.toDouble() ?? 0.0,
      accumulated24hMm: (json['accumulated_24h_mm'] as num?)?.toDouble() ?? 0.0,
      condensationLevelM: (json['condensation_level_m'] as num?)?.toDouble() ?? 1500.0,
      cloudTopHeightKm: (json['cloud_top_height_km'] as num?)?.toDouble() ?? 10.0,
      radarReflectivityDbz: (json['radar_reflectivity_dbz'] as num?)?.toDouble() ?? 30.0,
      cloudburstCategory: json['cloudburst_category'] as String? ?? 'NORMAL_RAIN',
    );
  }

  Map<String, dynamic> toJson() => {
        'rain_rate_mm_hr': rainRateMmHr,
        'accumulated_3h_mm': accumulated3hMm,
        'accumulated_24h_mm': accumulated24hMm,
        'condensation_level_m': condensationLevelM,
        'cloud_top_height_km': cloudTopHeightKm,
        'radar_reflectivity_dbz': radarReflectivityDbz,
        'cloudburst_category': cloudburstCategory,
      };
}

class SlopeStabilityModel {
  final double slopeAngleDegrees;
  final double ari3dayMm;
  final double ari15dayMm;
  final double poreWaterPressureRatio;
  final double factorOfSafety;
  final String landslideRiskTier;

  const SlopeStabilityModel({
    required this.slopeAngleDegrees,
    required this.ari3dayMm,
    required this.ari15dayMm,
    required this.poreWaterPressureRatio,
    required this.factorOfSafety,
    required this.landslideRiskTier,
  });

  factory SlopeStabilityModel.fromJson(Map<String, dynamic> json) {
    return SlopeStabilityModel(
      slopeAngleDegrees: (json['slope_angle_degrees'] as num?)?.toDouble() ?? 30.0,
      ari3dayMm: (json['ari_3day_mm'] as num?)?.toDouble() ?? 50.0,
      ari15dayMm: (json['ari_15day_mm'] as num?)?.toDouble() ?? 150.0,
      poreWaterPressureRatio: (json['pore_water_pressure_ratio'] as num?)?.toDouble() ?? 0.5,
      factorOfSafety: (json['factor_of_safety'] as num?)?.toDouble() ?? 1.5,
      landslideRiskTier: json['landslide_risk_tier'] as String? ?? 'LOW_STABLE',
    );
  }

  Map<String, dynamic> toJson() => {
        'slope_angle_degrees': slopeAngleDegrees,
        'ari_3day_mm': ari3dayMm,
        'ari_15day_mm': ari15dayMm,
        'pore_water_pressure_ratio': poreWaterPressureRatio,
        'factor_of_safety': factorOfSafety,
        'landslide_risk_tier': landslideRiskTier,
      };
}

class DebrisFlowHydrodynamicsModel {
  final double peakDischargeM3S;
  final double debrisSlurryVolumeM3;
  final double boulderVelocityMS;
  final String bridgeScourThreat;
  final String flashFloodStage;

  const DebrisFlowHydrodynamicsModel({
    required this.peakDischargeM3S,
    required this.debrisSlurryVolumeM3,
    required this.boulderVelocityMS,
    required this.bridgeScourThreat,
    required this.flashFloodStage,
  });

  factory DebrisFlowHydrodynamicsModel.fromJson(Map<String, dynamic> json) {
    return DebrisFlowHydrodynamicsModel(
      peakDischargeM3S: (json['peak_discharge_m3_s'] as num?)?.toDouble() ?? 100.0,
      debrisSlurryVolumeM3: (json['debris_slurry_volume_m3'] as num?)?.toDouble() ?? 5000.0,
      boulderVelocityMS: (json['boulder_velocity_m_s'] as num?)?.toDouble() ?? 2.0,
      bridgeScourThreat: json['bridge_scour_threat'] as String? ?? 'Minimal Scour',
      flashFloodStage: json['flash_flood_stage'] as String? ?? 'NORMAL_FLOW',
    );
  }

  Map<String, dynamic> toJson() => {
        'peak_discharge_m3_s': peakDischargeM3S,
        'debris_slurry_volume_m3': debrisSlurryVolumeM3,
        'boulder_velocity_m_s': boulderVelocityMS,
        'bridge_scour_threat': bridgeScourThreat,
        'flash_flood_stage': flashFloodStage,
      };
}

class MountainSafetyDirectivesModel {
  final String evacuationOrder;
  final String pilgrimageTransitAdvisory;
  final String ghatRoadTransitStatus;
  final String plantationWorkerProtocol;

  const MountainSafetyDirectivesModel({
    required this.evacuationOrder,
    required this.pilgrimageTransitAdvisory,
    required this.ghatRoadTransitStatus,
    required this.plantationWorkerProtocol,
  });

  factory MountainSafetyDirectivesModel.fromJson(Map<String, dynamic> json) {
    return MountainSafetyDirectivesModel(
      evacuationOrder: json['evacuation_order'] as String? ?? 'Monitor local hill alerts.',
      pilgrimageTransitAdvisory:
          json['pilgrimage_transit_advisory'] as String? ?? 'Check mountain pass clearances before departures.',
      ghatRoadTransitStatus: json['ghat_road_transit_status'] as String? ?? 'All ghat roads currently passable.',
      plantationWorkerProtocol:
          json['plantation_worker_protocol'] as String? ?? 'Normal slope operations with caution.',
    );
  }

  Map<String, dynamic> toJson() => {
        'evacuation_order': evacuationOrder,
        'pilgrimage_transit_advisory': pilgrimageTransitAdvisory,
        'ghat_road_transit_status': ghatRoadTransitStatus,
        'plantation_worker_protocol': plantationWorkerProtocol,
      };
}

class MountainCatchmentModel {
  final String catchmentId;
  final String catchmentName;
  final String mountainRange;
  final String state;
  final int elevationM;
  final double latitude;
  final double longitude;
  final String dominantLithology;
  final OrographicPrecipitationModel orographicPrecipitation;
  final SlopeStabilityModel slopeStability;
  final DebrisFlowHydrodynamicsModel hydrodynamics;
  final MountainSafetyDirectivesModel directives;
  final Map<String, String> bulletins;

  const MountainCatchmentModel({
    required this.catchmentId,
    required this.catchmentName,
    required this.mountainRange,
    required this.state,
    required this.elevationM,
    required this.latitude,
    required this.longitude,
    required this.dominantLithology,
    required this.orographicPrecipitation,
    required this.slopeStability,
    required this.hydrodynamics,
    required this.directives,
    required this.bulletins,
  });

  factory MountainCatchmentModel.fromJson(Map<String, dynamic> json) {
    final rawBulletins = json['bulletins'] as Map<String, dynamic>? ?? {};
    final bulletins = rawBulletins.map((k, v) => MapEntry(k, v.toString()));

    return MountainCatchmentModel(
      catchmentId: json['catchment_id'] as String? ?? 'kedarnath_mandakini',
      catchmentName: json['catchment_name'] as String? ?? 'Mandakini Valley & Kedarnath Basin',
      mountainRange: json['mountain_range'] as String? ?? 'Garhwal Higher Himalayas',
      state: json['state'] as String? ?? 'Uttarakhand',
      elevationM: (json['elevation_m'] as num?)?.toInt() ?? 3584,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 30.7352,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 79.0669,
      dominantLithology: json['dominant_lithology'] as String? ?? 'Central Crystalline Gneiss & Loose Moraine Deposits',
      orographicPrecipitation: OrographicPrecipitationModel.fromJson(
          json['orographic_precipitation'] as Map<String, dynamic>? ?? {}),
      slopeStability: SlopeStabilityModel.fromJson(json['slope_stability'] as Map<String, dynamic>? ?? {}),
      hydrodynamics: DebrisFlowHydrodynamicsModel.fromJson(json['hydrodynamics'] as Map<String, dynamic>? ?? {}),
      directives: MountainSafetyDirectivesModel.fromJson(json['directives'] as Map<String, dynamic>? ?? {}),
      bulletins: bulletins,
    );
  }

  Map<String, dynamic> toJson() => {
        'catchment_id': catchmentId,
        'catchment_name': catchmentName,
        'mountain_range': mountainRange,
        'state': state,
        'elevation_m': elevationM,
        'latitude': latitude,
        'longitude': longitude,
        'dominant_lithology': dominantLithology,
        'orographic_precipitation': orographicPrecipitation.toJson(),
        'slope_stability': slopeStability.toJson(),
        'hydrodynamics': hydrodynamics.toJson(),
        'directives': directives.toJson(),
        'bulletins': bulletins,
      };
}

class CloudburstResponseModel {
  final String timestamp;
  final MountainCatchmentModel selectedCatchment;
  final List<MountainCatchmentModel> allCatchments;
  final Map<String, String> vernacularBulletins;
  final String bulletinNumber;
  final String provenance;
  final bool isOfflineCached;

  const CloudburstResponseModel({
    required this.timestamp,
    required this.selectedCatchment,
    required this.allCatchments,
    required this.vernacularBulletins,
    required this.bulletinNumber,
    required this.provenance,
    this.isOfflineCached = false,
  });

  factory CloudburstResponseModel.fromJson(Map<String, dynamic> json, {bool isOfflineCached = false}) {
    final rawCatchments = json['all_catchments'] as List<dynamic>? ?? [];
    final catchments = rawCatchments.map((e) => MountainCatchmentModel.fromJson(e as Map<String, dynamic>)).toList();

    final rawBulletins = json['vernacular_bulletins'] as Map<String, dynamic>? ?? {};
    final bulletins = rawBulletins.map((k, v) => MapEntry(k, v.toString()));

    return CloudburstResponseModel(
      timestamp: json['timestamp'] as String? ?? DateTime.now().toUtc().toIso8601String(),
      selectedCatchment: MountainCatchmentModel.fromJson(json['selected_catchment'] as Map<String, dynamic>? ?? {}),
      allCatchments: catchments,
      vernacularBulletins: bulletins,
      bulletinNumber: json['bulletin_number'] as String? ?? 'IMD-GSI/OC-FFLDE/DEFAULT',
      provenance: json['provenance'] as String? ??
          'IMD Mountain Meteorology Division & Geological Survey of India (GSI) NLEWS',
      isOfflineCached: isOfflineCached || (json['is_offline_cached'] as bool? ?? false),
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'selected_catchment': selectedCatchment.toJson(),
        'all_catchments': allCatchments.map((e) => e.toJson()).toList(),
        'vernacular_bulletins': vernacularBulletins,
        'bulletin_number': bulletinNumber,
        'provenance': provenance,
        'is_offline_cached': isOfflineCached,
      };

  static CloudburstResponseModel defaultFallback() {
    const kedarnath = MountainCatchmentModel(
      catchmentId: 'kedarnath_mandakini',
      catchmentName: 'Mandakini Valley & Kedarnath Basin',
      mountainRange: 'Garhwal Higher Himalayas',
      state: 'Uttarakhand',
      elevationM: 3584,
      latitude: 30.7352,
      longitude: 79.0669,
      dominantLithology: 'Central Crystalline Gneiss & Loose Moraine Deposits',
      orographicPrecipitation: OrographicPrecipitationModel(
        rainRateMmHr: 112.0,
        accumulated3hMm: 185.0,
        accumulated24hMm: 310.0,
        condensationLevelM: 2400.0,
        cloudTopHeightKm: 14.5,
        radarReflectivityDbz: 58.5,
        cloudburstCategory: 'CLOUDBURST',
      ),
      slopeStability: SlopeStabilityModel(
        slopeAngleDegrees: 38.0,
        ari3dayMm: 165.0,
        ari15dayMm: 390.0,
        poreWaterPressureRatio: 0.94,
        factorOfSafety: 0.82,
        landslideRiskTier: 'CRITICAL_IMMINENT_FAILURE',
      ),
      hydrodynamics: DebrisFlowHydrodynamicsModel(
        peakDischargeM3S: 850.0,
        debrisSlurryVolumeM3: 125000.0,
        boulderVelocityMS: 8.5,
        bridgeScourThreat: 'Catastrophic Pier Undermining & Span Overtopping',
        flashFloodStage: 'CATASTROPHIC_DEBRIS_FLOW',
      ),
      directives: MountainSafetyDirectivesModel(
        evacuationOrder: 'RED ALERT: Immediate evacuation of Mandakini riverbed settlements between Gaurikund and Sonprayag.',
        pilgrimageTransitAdvisory: 'Char Dham Yatra Kedarnath trek halted at all checkpoints. Move to reinforced high-elevation shelter structures.',
        ghatRoadTransitStatus: 'NH-109 Rudraprayag-Gaurikund blocked by mudslides at Sirobagarh and Phata. Transit strictly prohibited.',
        plantationWorkerProtocol: 'All construction, trail portering, and mule operations suspended immediately.',
      ),
      bulletins: {
        'en': 'IMD & GSI EMERGENCY CLOUDBURST BULLETIN: Mandakini Valley under active CLOUDBURST (112 mm/hr). Debris flow Factor of Safety 0.82 indicates catastrophic landslide failure. Halt Char Dham trek immediately.',
        'hi': 'आईएमडी और जीएसआई आपातकालीन बादल फटने का बुलेटिन: मंदाकिनी घाटी में सक्रिय बादल फटा (112 मिमी/घंटा)। ढलान स्थिरता 0.82 भूस्खलन और मलबे के तीव्र बहाव का संकेत देती है। केदारनाथ यात्रा तत्काल रोकें।',
        'ml': 'ഐഎംഡി & ജിഎസ്ഐ മേഘവിസ്ഫോടന മുന്നറിയിപ്പ്: മന്ദാകിനി താഴ്‌വരയിൽ മേഘവിസ്ഫോടനം (112 mm/hr). മണ്ണിടിച്ചിൽ സാദ്ധ്യത അതീവ ഗുരുതരം. കേദാർനാഥ് തീർത്ഥാടനം അടിയന്തിരമായി നിർത്തിവെക്കുക.',
        'mr': 'आयएमडी व जीएसआय ढगफुटी इशारा: मंदाकिनी खोऱ्यात तीव्र ढगफुटी (११२ मिमी/तास). भूस्खलनाचा प्रचंड धोका. केदारनाथ यात्रा त्वरित थांबवावी.',
        'ta': 'வானிலை ஆய்வு மையம் மற்றும் ஜிஎஸ்ஐ மேகவெடிப்பு எச்சரிக்கை: மந்தாகினி பள்ளத்தாக்கில் தீவிர மேகவெடிப்பு (112 மிமீ/மணி). நிலச்சரிவு மற்றும் பாறை உருளல் ஆபத்து மிக அதிகம். கேதார்நாத் யாத்திரை உடனடியாக நிறுத்தம்.',
      },
    );

    const wayanad = MountainCatchmentModel(
      catchmentId: 'wayanad_vythiri_meppadi',
      catchmentName: 'Vellarimala, Meppadi & Chooralmala Catchment',
      mountainRange: 'Western Ghats Sahyadri (Camel\'s Hump Complex)',
      state: 'Kerala',
      elevationM: 850,
      latitude: 11.5372,
      longitude: 76.1264,
      dominantLithology: 'Deep Weathered Laterite Regolith over Granulitic Charnockite',
      orographicPrecipitation: OrographicPrecipitationModel(
        rainRateMmHr: 94.0,
        accumulated3hMm: 210.0,
        accumulated24hMm: 372.0,
        condensationLevelM: 700.0,
        cloudTopHeightKm: 12.8,
        radarReflectivityDbz: 54.0,
        cloudburstCategory: 'MINI_CLOUDBURST',
      ),
      slopeStability: SlopeStabilityModel(
        slopeAngleDegrees: 34.0,
        ari3dayMm: 240.0,
        ari15dayMm: 580.0,
        poreWaterPressureRatio: 0.98,
        factorOfSafety: 0.78,
        landslideRiskTier: 'CRITICAL_IMMINENT_FAILURE',
      ),
      hydrodynamics: DebrisFlowHydrodynamicsModel(
        peakDischargeM3S: 640.0,
        debrisSlurryVolumeM3: 280000.0,
        boulderVelocityMS: 7.8,
        bridgeScourThreat: 'Total Submersion & Multi-ton Boulder Impact on Span Piles',
        flashFloodStage: 'CATASTROPHIC_DEBRIS_FLOW',
      ),
      directives: MountainSafetyDirectivesModel(
        evacuationOrder: 'LIFE SAFETY EMERGENCY: Evacuate all settlements along Chooralmala, Mundakkai, and Attamala ravines immediately.',
        pilgrimageTransitAdvisory: 'Sabarimala mountain routes in central Kerala placed on high alert; Wayanad ghat tourist travel banned.',
        ghatRoadTransitStatus: 'Thamarassery Churam (NH-766) and Meppadi-Vaduvanchal route closed due to debris flows and fallen trees.',
        plantationWorkerProtocol: 'Strict cessation of all tea plucking, estate line-room occupation, and stream crossings.',
      ),
      bulletins: {
        'en': 'GSI & KSDMA CRITICAL LANDSLIDE BULLETIN: Vellarimala-Meppadi catchment saturated with 372 mm/24h. Slope Factor of Safety 0.78 indicates imminent regolith liquefaction and catastrophic debris torrent.',
        'hi': 'वायनाड मेप्पाडी आपातकालीन भूस्खलन बुलेटिन: 372 मिमी अत्यधिक वर्षा के कारण ढलान स्थिरता 0.78 पर गिरी। मलबे के बहाव का भारी खतरा। नदी तटों से तुरंत सुरक्षित स्थान पर जाएं।',
        'ml': 'ജിഎസ്ഐ & ദുരന്ത നിവാരണ അതോറിറ്റി അടിയന്തര മുന്നറിയിപ്പ്: മേപ്പാടി-ചൂരൽമല മേഖലയിൽ 372 മില്ലിമീറ്റർ കനത്ത മഴ. മണ്ണിടിച്ചിൽ സൂചിക 0.78 ആയി താഴ്ന്നു. പുഴയോരങ്ങളിൽ നിന്ന് ഉടനടി ഒഴിഞ്ഞുപോകുക.',
        'mr': 'वायनाड मेप्पाडी दरड कोसळण्याचा अतिदक्षतेचा इशारा: २४ तासांत ३७२ मिमी पाऊस. उतारावरील माती खचण्याचा अत्यंत गंभीर धोका. त्वरित स्थलांतर करा.',
        'ta': 'வயநாடு மேப்பாடி அவசர நிலச்சரிவு எச்சரிக்கை: 24 மணி நேரத்தில் 372 மிமீ தீவிர மழை. மண் பாறை சரிவு காரணி 0.78 ஆக சரிந்துள்ளது. ஆற்றங்கரை குடியிருப்பு மக்கள் உடனடியாக வெளியேறவும்.',
      },
    );

    return const CloudburstResponseModel(
      timestamp: '2026-09-12T06:00:00Z',
      selectedCatchment: kedarnath,
      allCatchments: [kedarnath, wayanad],
      vernacularBulletins: {
        'en': 'IMD & GSI EMERGENCY CLOUDBURST BULLETIN: Mandakini Valley under active CLOUDBURST (112 mm/hr). Debris flow Factor of Safety 0.82 indicates catastrophic landslide failure. Halt Char Dham trek immediately.',
        'hi': 'आईएमडी और जीएसआई आपातकालीन बादल फटने का बुलेटिन: मंदाकिनी घाटी में सक्रिय बादल फटा (112 मिमी/घंटा)। ढलान स्थिरता 0.82 भूस्खलन और मलबे के तीव्र बहाव का संकेत देती है। केदारनाथ यात्रा तत्काल रोकें।',
        'ml': 'ഐഎംഡി & ജിഎസ്ഐ മേഘവിസ്ഫോടന മുന്നറിയിപ്പ്: മന്ദാകിനി താഴ്‌വരയിൽ മേഘവിസ്ഫോടനം (112 mm/hr). മണ്ണിടിച്ചിൽ സാദ്ധ്യത അതീവ ഗുരുതരം. കേദാർനാഥ് തീർത്ഥാടനം അടിയന്തിരമായി നിർത്തിവെക്കുക.',
        'mr': 'आयएमडी व जीएसआय ढगफुटी इशारा: मंदाकिनी खोऱ्यात तीव्र ढगफुटी (११२ मिमी/तास). भूस्खलनाचा प्रचंड धोका. केदारनाथ यात्रा त्वरित थांबवावी.',
        'ta': 'வானிலை ஆய்வு மையம் மற்றும் ஜிஎஸ்ஐ மேகவெடிப்பு எச்சரிக்கை: மந்தாகினி பள்ளத்தாக்கில் தீவிர மேகவெடிப்பு (112 மிமீ/மணி). நிலச்சரிவு மற்றும் பாறை உருளல் ஆபத்து மிக அதிகம். கேதார்நாத் யாத்திரை உடனடியாக நிறுத்தம்.',
      },
      bulletinNumber: 'IMD-GSI/OC-FFLDE/202609-KEDARN',
      provenance: 'IMD Mountain Meteorology Division & Geological Survey of India (GSI) NLEWS',
      isOfflineCached: true,
    );
  }
}
