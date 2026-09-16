class AtmosphericDispersionModel {
  final double windSpeedMS;
  final double windDirectionDegrees;
  final String windDirectionCardinal;
  final String pasquillStabilityClass;
  final double mixingHeightM;
  final double ambientTempC;
  final double relativeHumidityPct;
  final double solarRadiationWM2;
  final bool inversionLayerPresent;

  const AtmosphericDispersionModel({
    required this.windSpeedMS,
    required this.windDirectionDegrees,
    required this.windDirectionCardinal,
    required this.pasquillStabilityClass,
    required this.mixingHeightM,
    required this.ambientTempC,
    required this.relativeHumidityPct,
    required this.solarRadiationWM2,
    required this.inversionLayerPresent,
  });

  factory AtmosphericDispersionModel.fromJson(Map<String, dynamic> json) {
    return AtmosphericDispersionModel(
      windSpeedMS: (json['wind_speed_m_s'] as num?)?.toDouble() ?? 3.0,
      windDirectionDegrees: (json['wind_direction_degrees'] as num?)?.toDouble() ?? 240.0,
      windDirectionCardinal: json['wind_direction_cardinal'] as String? ?? 'WSW',
      pasquillStabilityClass: json['pasquill_stability_class'] as String? ?? 'CLASS_D_NEUTRAL',
      mixingHeightM: (json['mixing_height_m'] as num?)?.toDouble() ?? 400.0,
      ambientTempC: (json['ambient_temp_c'] as num?)?.toDouble() ?? 30.0,
      relativeHumidityPct: (json['relative_humidity_pct'] as num?)?.toDouble() ?? 70.0,
      solarRadiationWM2: (json['solar_radiation_w_m2'] as num?)?.toDouble() ?? 200.0,
      inversionLayerPresent: json['inversion_layer_present'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'wind_speed_m_s': windSpeedMS,
        'wind_direction_degrees': windDirectionDegrees,
        'wind_direction_cardinal': windDirectionCardinal,
        'pasquill_stability_class': pasquillStabilityClass,
        'mixing_height_m': mixingHeightM,
        'ambient_temp_c': ambientTempC,
        'relative_humidity_pct': relativeHumidityPct,
        'solar_radiation_w_m2': solarRadiationWM2,
        'inversion_layer_present': inversionLayerPresent,
      };
}

class GasToxicityModel {
  final String species;
  final String commonName;
  final String chemicalFormula;
  final String casNumber;
  final double molecularWeightGMol;
  final double vaporDensityAirRatio;
  final double odorThresholdPpm;
  final double aegl1Ppm;
  final double aegl2Ppm;
  final double aegl3Ppm;
  final double idlhPpm;

  const GasToxicityModel({
    required this.species,
    required this.commonName,
    required this.chemicalFormula,
    required this.casNumber,
    required this.molecularWeightGMol,
    required this.vaporDensityAirRatio,
    required this.odorThresholdPpm,
    required this.aegl1Ppm,
    required this.aegl2Ppm,
    required this.aegl3Ppm,
    required this.idlhPpm,
  });

  factory GasToxicityModel.fromJson(Map<String, dynamic> json) {
    return GasToxicityModel(
      species: json['species'] as String? ?? 'CHLORINE_CL2',
      commonName: json['common_name'] as String? ?? 'Chlorine Gas',
      chemicalFormula: json['chemical_formula'] as String? ?? 'Cl2',
      casNumber: json['cas_number'] as String? ?? '7782-50-5',
      molecularWeightGMol: (json['molecular_weight_g_mol'] as num?)?.toDouble() ?? 70.9,
      vaporDensityAirRatio: (json['vapor_density_air_ratio'] as num?)?.toDouble() ?? 2.45,
      odorThresholdPpm: (json['odor_threshold_ppm'] as num?)?.toDouble() ?? 0.31,
      aegl1Ppm: (json['aegl_1_ppm'] as num?)?.toDouble() ?? 0.50,
      aegl2Ppm: (json['aegl_2_ppm'] as num?)?.toDouble() ?? 2.00,
      aegl3Ppm: (json['aegl_3_ppm'] as num?)?.toDouble() ?? 20.00,
      idlhPpm: (json['idlh_ppm'] as num?)?.toDouble() ?? 10.00,
    );
  }

  Map<String, dynamic> toJson() => {
        'species': species,
        'common_name': commonName,
        'chemical_formula': chemicalFormula,
        'cas_number': casNumber,
        'molecular_weight_g_mol': molecularWeightGMol,
        'vapor_density_air_ratio': vaporDensityAirRatio,
        'odor_threshold_ppm': odorThresholdPpm,
        'aegl_1_ppm': aegl1Ppm,
        'aegl_2_ppm': aegl2Ppm,
        'aegl_3_ppm': aegl3Ppm,
        'idlh_ppm': idlhPpm,
      };
}

class PlumeDispersionModel {
  final double releaseRateKgS;
  final double releaseHeightM;
  final double centerlinePeakConcentrationPpm;
  final double protectiveActionDistanceKm;
  final double initialIsolationZoneM;
  final double plumeWidth1kmM;
  final double transitTimeBufferMin;
  final String severityTier;

  const PlumeDispersionModel({
    required this.releaseRateKgS,
    required this.releaseHeightM,
    required this.centerlinePeakConcentrationPpm,
    required this.protectiveActionDistanceKm,
    required this.initialIsolationZoneM,
    required this.plumeWidth1kmM,
    required this.transitTimeBufferMin,
    required this.severityTier,
  });

  factory PlumeDispersionModel.fromJson(Map<String, dynamic> json) {
    return PlumeDispersionModel(
      releaseRateKgS: (json['release_rate_kg_s'] as num?)?.toDouble() ?? 10.0,
      releaseHeightM: (json['release_height_m'] as num?)?.toDouble() ?? 8.0,
      centerlinePeakConcentrationPpm: (json['centerline_peak_concentration_ppm'] as num?)?.toDouble() ?? 45.0,
      protectiveActionDistanceKm: (json['protective_action_distance_km'] as num?)?.toDouble() ?? 4.0,
      initialIsolationZoneM: (json['initial_isolation_zone_m'] as num?)?.toDouble() ?? 350.0,
      plumeWidth1kmM: (json['plume_width_1km_m'] as num?)?.toDouble() ?? 300.0,
      transitTimeBufferMin: (json['transit_time_buffer_min'] as num?)?.toDouble() ?? 15.0,
      severityTier: json['severity_tier'] as String? ?? 'SIGNIFICANT_TANK_LEAK',
    );
  }

  Map<String, dynamic> toJson() => {
        'release_rate_kg_s': releaseRateKgS,
        'release_height_m': releaseHeightM,
        'centerline_peak_concentration_ppm': centerlinePeakConcentrationPpm,
        'protective_action_distance_km': protectiveActionDistanceKm,
        'initial_isolation_zone_m': initialIsolationZoneM,
        'plume_width_1km_m': plumeWidth1kmM,
        'transit_time_buffer_min': transitTimeBufferMin,
        'severity_tier': severityTier,
      };
}

class EmergencyResponseProtocolModel {
  final String crosswindEscapeDirection;
  final String shelterInPlaceDirectives;
  final String recommendedPpe;
  final String medicalCountermeasures;
  final bool waterSprayCurtainRecommended;

  const EmergencyResponseProtocolModel({
    required this.crosswindEscapeDirection,
    required this.shelterInPlaceDirectives,
    required this.recommendedPpe,
    required this.medicalCountermeasures,
    required this.waterSprayCurtainRecommended,
  });

  factory EmergencyResponseProtocolModel.fromJson(Map<String, dynamic> json) {
    return EmergencyResponseProtocolModel(
      crosswindEscapeDirection: json['crosswind_escape_direction'] as String? ?? '',
      shelterInPlaceDirectives: json['shelter_in_place_directives'] as String? ?? '',
      recommendedPpe: json['recommended_ppe'] as String? ?? '',
      medicalCountermeasures: json['medical_countermeasures'] as String? ?? '',
      waterSprayCurtainRecommended: json['water_spray_curtain_recommended'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'crosswind_escape_direction': crosswindEscapeDirection,
        'shelter_in_place_directives': shelterInPlaceDirectives,
        'recommended_ppe': recommendedPpe,
        'medical_countermeasures': medicalCountermeasures,
        'water_spray_curtain_recommended': waterSprayCurtainRecommended,
      };
}

class IndustrialChemicalClusterModel {
  final String clusterId;
  final String clusterName;
  final String state;
  final String district;
  final double latitude;
  final double longitude;
  final List<String> majorIndustrialSectors;
  final GasToxicityModel activeGasProfile;
  final AtmosphericDispersionModel atmosphericTelemetry;
  final PlumeDispersionModel dispersionMetrics;
  final EmergencyResponseProtocolModel emergencyProtocol;
  final List<String> sensitiveDownwindReceptors;
  final Map<String, String> localizedBulletins;

  const IndustrialChemicalClusterModel({
    required this.clusterId,
    required this.clusterName,
    required this.state,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.majorIndustrialSectors,
    required this.activeGasProfile,
    required this.atmosphericTelemetry,
    required this.dispersionMetrics,
    required this.emergencyProtocol,
    required this.sensitiveDownwindReceptors,
    required this.localizedBulletins,
  });

  factory IndustrialChemicalClusterModel.fromJson(Map<String, dynamic> json) {
    return IndustrialChemicalClusterModel(
      clusterId: json['cluster_id'] as String? ?? 'dahej_pcpir_gujarat',
      clusterName: json['cluster_name'] as String? ?? 'Dahej PCPIR',
      state: json['state'] as String? ?? 'Gujarat',
      district: json['district'] as String? ?? 'Bharuch',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 21.7133,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 72.5833,
      majorIndustrialSectors: (json['major_industrial_sectors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      activeGasProfile: GasToxicityModel.fromJson(
          json['active_gas_profile'] as Map<String, dynamic>? ?? {}),
      atmosphericTelemetry: AtmosphericDispersionModel.fromJson(
          json['atmospheric_telemetry'] as Map<String, dynamic>? ?? {}),
      dispersionMetrics: PlumeDispersionModel.fromJson(
          json['dispersion_metrics'] as Map<String, dynamic>? ?? {}),
      emergencyProtocol: EmergencyResponseProtocolModel.fromJson(
          json['emergency_protocol'] as Map<String, dynamic>? ?? {}),
      sensitiveDownwindReceptors: (json['sensitive_downwind_receptors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      localizedBulletins: (json['localized_bulletins'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          {},
    );
  }

  Map<String, dynamic> toJson() => {
        'cluster_id': clusterId,
        'cluster_name': clusterName,
        'state': state,
        'district': district,
        'latitude': latitude,
        'longitude': longitude,
        'major_industrial_sectors': majorIndustrialSectors,
        'active_gas_profile': activeGasProfile.toJson(),
        'atmospheric_telemetry': atmosphericTelemetry.toJson(),
        'dispersion_metrics': dispersionMetrics.toJson(),
        'emergency_protocol': emergencyProtocol.toJson(),
        'sensitive_downwind_receptors': sensitiveDownwindReceptors,
        'localized_bulletins': localizedBulletins,
      };
}

class HazmatDispersionResponse {
  final String timestamp;
  final String bulletinNumber;
  final String provenance;
  final IndustrialChemicalClusterModel selectedCluster;
  final List<IndustrialChemicalClusterModel> allClusters;
  final Map<String, String> vernacularBulletins;
  final bool isOfflineCached;

  const HazmatDispersionResponse({
    required this.timestamp,
    required this.bulletinNumber,
    required this.provenance,
    required this.selectedCluster,
    required this.allClusters,
    required this.vernacularBulletins,
    this.isOfflineCached = false,
  });

  factory HazmatDispersionResponse.fromJson(
    Map<String, dynamic> json, {
    bool isOfflineCached = false,
  }) {
    final clustersRaw = json['all_clusters'] as List<dynamic>? ?? [];
    final clusters = clustersRaw
        .map((c) => IndustrialChemicalClusterModel.fromJson(c as Map<String, dynamic>))
        .toList();

    final selected = json['selected_cluster'] != null
        ? IndustrialChemicalClusterModel.fromJson(
            json['selected_cluster'] as Map<String, dynamic>)
        : (clusters.isNotEmpty ? clusters.first : defaultFallback().selectedCluster);

    final bulletinsRaw = json['vernacular_bulletins'] as Map<String, dynamic>? ?? {};
    final bulletins = bulletinsRaw.map((k, v) => MapEntry(k, v.toString()));

    return HazmatDispersionResponse(
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      bulletinNumber: json['bulletin_number'] as String? ?? 'CPCB-IMD/HAZMAT-ADPE/2026-DEFAULT',
      provenance: json['provenance'] as String? ??
          'CPCB Central Pollution Control Board & IMD Emergency Response Decision Support System',
      selectedCluster: selected,
      allClusters: clusters.isNotEmpty ? clusters : [selected],
      vernacularBulletins: bulletins,
      isOfflineCached: isOfflineCached,
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'bulletin_number': bulletinNumber,
        'provenance': provenance,
        'selected_cluster': selectedCluster.toJson(),
        'all_clusters': allClusters.map((c) => c.toJson()).toList(),
        'vernacular_bulletins': vernacularBulletins,
        'is_offline_cached': isOfflineCached,
      };

  static HazmatDispersionResponse defaultFallback() {
    const dahejCluster = IndustrialChemicalClusterModel(
      clusterId: 'dahej_pcpir_gujarat',
      clusterName: 'Dahej Petroleum, Chemicals & Petrochemicals Investment Region (PCPIR)',
      state: 'Gujarat',
      district: 'Bharuch',
      latitude: 21.7133,
      longitude: 72.5833,
      majorIndustrialSectors: [
        'Chlor-Alkali & Caustic Soda',
        'Vinyl Chloride Monomer (VCM)',
        'Petrochemical Cracking & Aromatics',
        'Agrochemical Technical Intermediates',
      ],
      activeGasProfile: GasToxicityModel(
        species: 'CHLORINE_CL2',
        commonName: 'Chlorine Gas',
        chemicalFormula: 'Cl2',
        casNumber: '7782-50-5',
        molecularWeightGMol: 70.9,
        vaporDensityAirRatio: 2.45,
        odorThresholdPpm: 0.31,
        aegl1Ppm: 0.50,
        aegl2Ppm: 2.00,
        aegl3Ppm: 20.00,
        idlhPpm: 10.00,
      ),
      atmosphericTelemetry: AtmosphericDispersionModel(
        windSpeedMS: 3.2,
        windDirectionDegrees: 245.0,
        windDirectionCardinal: 'WSW',
        pasquillStabilityClass: 'CLASS_E_SLIGHTLY_STABLE',
        mixingHeightM: 350.0,
        ambientTempC: 32.5,
        relativeHumidityPct: 74.0,
        solarRadiationWM2: 120.0,
        inversionLayerPresent: true,
      ),
      dispersionMetrics: PlumeDispersionModel(
        releaseRateKgS: 12.5,
        releaseHeightM: 8.0,
        centerlinePeakConcentrationPpm: 48.6,
        protectiveActionDistanceKm: 4.2,
        initialIsolationZoneM: 400.0,
        plumeWidth1kmM: 320.0,
        transitTimeBufferMin: 14.5,
        severityTier: 'SIGNIFICANT_TANK_LEAK',
      ),
      emergencyProtocol: EmergencyResponseProtocolModel(
        crosswindEscapeDirection:
            'EVACUATE PERPENDICULAR TO WIND: Move North-Northwest (NNW) towards Luvara. Do NOT flee downwind.',
        shelterInPlaceDirectives:
            'Shelter indoors on higher floors (dense chlorine sinks). Seal doors with damp cloths. Switch off ACs.',
        recommendedPpe:
            'Level A fully encapsulating vapor-protective suit with positive-pressure SCBA.',
        medicalCountermeasures:
            'Immediate humidified oxygen therapy, nebulized 0.5% sodium bicarbonate solution, inhaled bronchodilators.',
        waterSprayCurtainRecommended: true,
      ),
      sensitiveDownwindReceptors: [
        'Dahej Port Township (2.4 km ENE)',
        'Jageshwar Coastal Habitation (3.8 km ENE)',
        'GIDC Industrial Housing Colony (1.8 km NE)',
      ],
      localizedBulletins: {
        'en':
            'WARNING: Significant Chlorine (Cl2) plume dispersion detected at Dahej PCPIR. Low nocturnal mixing depth (350m, Class E) is trapping dense vapor near ground level. Evacuate 400m initial isolation zone immediately crosswind towards NNW.',
        'gu':
            'ચેતવણી: દહેજ પીસીપીઆઇઆરમાં ક્લોરિન વાયુનું ગંભીર લીકેજ નોંધાયું છે. વાતાવરણમાં સ્થિરતા હોવાથી ઝેરી વાદળ જમીન નજીક ફેલાઈ રહ્યું છે. પવનની વિરુદ્ધ દિશામાં ખસી જાઓ અને 400 મીટર વિસ્તાર તાત્કાલિક ખાલી કરો.',
        'hi':
            'चेतावनी: दहेज पीसीपीआईआर में क्लोरीन गैस के फैलाव का गंभीर अलर्ट। कम मिश्रण ऊंचाई के कारण भारी क्लोरीन गैस जमीन के पास फैल रही है। 400 मीटर के दायरे को तत्काल खाली करें।',
        'ta':
            'எச்சரிக்கை: குஜராத் தஹேஜ் பெட்ரோ கெமிக்கல் மண்டலத்தில் குளோரின் நச்சு வாயு கசிவு பதிவாகியுள்ளது. உடனடியாக 400 மீட்டர் சுற்றளவை விட்டு விலகி குறுக்கு திசையில் வெளியேறவும்.',
        'te':
            'హెచ్చరిక: దహేజ్ పీసీపీఐఆర్ పారిశ్రామిక ప్రాంతంలో క్లోరిన్ గ్యాస్ లీకేజ్ నమోదైంది. తక్షణమే 400 మీటర్ల పరిధిని ఖాళీ చేసి గాలి వీచే దిశకు అడ్డంగా తరలివెళ్ళండి.',
      },
    );

    const manaliCluster = IndustrialChemicalClusterModel(
      clusterId: 'manali_industrial_corridor_chennai',
      clusterName: 'Manali Petrochemical & Fertilizer Complex (Chennai)',
      state: 'Tamil Nadu',
      district: 'Chennai / Tiruvallur',
      latitude: 13.1667,
      longitude: 80.2667,
      majorIndustrialSectors: [
        'Nitrogenous Fertilizer (Urea / Ammonia)',
        'Petroleum Refining (CPCL)',
        'Epichlorohydrin & Polyols',
        'Synthetic Rubbers & Polybutenes',
      ],
      activeGasProfile: GasToxicityModel(
        species: 'AMMONIA_NH3',
        commonName: 'Anhydrous Ammonia',
        chemicalFormula: 'NH3',
        casNumber: '7664-41-7',
        molecularWeightGMol: 17.03,
        vaporDensityAirRatio: 0.59,
        odorThresholdPpm: 5.0,
        aegl1Ppm: 30.0,
        aegl2Ppm: 160.0,
        aegl3Ppm: 1100.0,
        idlhPpm: 300.0,
      ),
      atmosphericTelemetry: AtmosphericDispersionModel(
        windSpeedMS: 4.5,
        windDirectionDegrees: 65.0,
        windDirectionCardinal: 'ENE',
        pasquillStabilityClass: 'CLASS_D_NEUTRAL',
        mixingHeightM: 600.0,
        ambientTempC: 31.0,
        relativeHumidityPct: 82.0,
        solarRadiationWM2: 450.0,
        inversionLayerPresent: false,
      ),
      dispersionMetrics: PlumeDispersionModel(
        releaseRateKgS: 25.0,
        releaseHeightM: 12.0,
        centerlinePeakConcentrationPpm: 340.0,
        protectiveActionDistanceKm: 3.5,
        initialIsolationZoneM: 300.0,
        plumeWidth1kmM: 290.0,
        transitTimeBufferMin: 11.2,
        severityTier: 'SIGNIFICANT_TANK_LEAK',
      ),
      emergencyProtocol: EmergencyResponseProtocolModel(
        crosswindEscapeDirection:
            'EVACUATE CROSSWIND: Move North-Northwest towards Madhavaram or South-Southeast toward Thiruvottiyur.',
        shelterInPlaceDirectives:
            'Stay indoors, close windows, shut down split ACs. Hold a wet cloth over nose and mouth (ammonia is water-soluble).',
        recommendedPpe:
            'Level B splash suit with positive-pressure airline respirator or SCBA with ammonia canisters.',
        medicalCountermeasures:
            'Flush eyes and skin with water for at least 15 minutes. Administer humidified oxygen.',
        waterSprayCurtainRecommended: true,
      ),
      sensitiveDownwindReceptors: [
        'Manali New Town Habitations (1.5 km WSW)',
        'Madhavaram Milk Colony Residential Buffer (3.1 km WSW)',
        'Kaviarasu Kannadasan Nagar (3.4 km SW)',
      ],
      localizedBulletins: {
        'en':
            'EMERGENCY: High-concentration Ammonia (NH3) vapor release at Manali Petrochemical Corridor. Peak concentration exceeds IDLH (340 ppm vs 300 ppm threshold). Maintain 300m initial isolation; cover nose and mouth with wet fabric.',
        'ta':
            'அவசர எச்சரிக்கை: மணலி தொழிற்பேட்டையில் அம்மோனியா வாயு கசிவு (340 ppm) அபாய அளவை தாண்டியுள்ளது. 300 மீட்டர் சுற்றளவை உடனடியாக காலி செய்யவும். ஈரமான துணியால் மூக்கை மூடிக்கொண்டு வெளியேறவும்.',
        'hi':
            'आपातकालीन चेतावनी: मनाली पेट्रोकेमिकल परिसर (चेन्नई) में अमोनिया गैस का भारी रिसाव। 300 मीटर आइसोलेशन क्षेत्र खाली करें और गीले कपड़े से मुंह-नाक ढकें।',
        'gu':
            'તાત્કાલિક ચેતવણી: મનાલી પેટ્રોકેમિકલ કોરિડોરમાં એમોનિયા ગેસનું લીકેજ. 300 મીટર સુરક્ષિત અંતર જાળવો.',
        'te':
            'అత్యవసర హెచ్చరిక: మనాలి పెట్రోకెమికల్ కారిడార్‌లో అమ్మోనియా గ్యాస్ లీకేజ్. 300 మీటర్ల పరిధిని ఖాళీ చేయండి.',
      },
    );

    return const HazmatDispersionResponse(
      timestamp: '2026-09-12T04:15:00Z',
      bulletinNumber: 'CPCB-IMD/HAZMAT-ADPE/2026-DAHEJ',
      provenance:
          'CPCB Central Pollution Control Board & IMD Emergency Response Decision Support System',
      selectedCluster: dahejCluster,
      allClusters: [dahejCluster, manaliCluster],
      vernacularBulletins: {
        'en':
            'WARNING: Significant Chlorine (Cl2) plume dispersion detected at Dahej PCPIR. Low nocturnal mixing depth (350m, Class E) is trapping dense vapor near ground level. Evacuate 400m initial isolation zone immediately crosswind towards NNW.',
        'gu':
            'ચેતવણી: દહેજ પીસીપીઆઇઆરમાં ક્લોરિન વાયુનું ગંભીર લીકેજ નોંધાયું છે. પવનની વિરુદ્ધ દિશામાં ખસી જાઓ અને 400 મીટર વિસ્તાર તાત્કાલિક ખાલી કરો.',
        'hi':
            'चेतावनी: दहेज पीसीपीआईआर में क्लोरीन गैस के फैलाव का गंभीर अलर्ट। 400 मीटर के दायरे को तत्काल खाली करें।',
        'ta':
            'எச்சரிக்கை: குஜராத் தஹேஜ் பெட்ரோ கெமிக்கல் மண்டலத்தில் குளோரின் நச்சு வாயு கசிவு பதிவாகியுள்ளது. உடனடியாக 400 மீட்டர் சுற்றளவை விட்டு விலகவும்.',
        'te':
            'హెచ్చరిక: దహేజ్ పీసీపీఐఆర్ పారిశ్రామిక ప్రాంతంలో క్లోరిన్ గ్యాస్ లీకేజ్ నమోదైంది. తక్షణమే 400 మీటర్ల పరిధిని ఖాళీ చేయండి.',
      },
      isOfflineCached: true,
    );
  }
}
