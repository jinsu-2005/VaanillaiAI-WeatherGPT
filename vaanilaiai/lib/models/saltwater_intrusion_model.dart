// Models for IMD, INCOIS & CGWB Coastal Estuarine Saltwater Intrusion,
// Tidal Prism & Groundwater Salinization Engine (SALTWATER-TIDE).

class EstuarineSalineWedgeTelemetryModel {
  final String estuaryName;
  final double riverMouthDistanceKm;
  final double salineWedgeLengthKm;
  final double upstreamFreshwaterDischargeCumecs;
  final double estuaryChannelDepthM;
  final double densimetricFroudeNumber;
  final double surfaceSalinityPpt;
  final double bottomBedSalinityPpt;
  final double astronomicalTidalRangeM;
  final String tidalPrismPhase;
  final double tidalPrismVolumeMillionM3;

  EstuarineSalineWedgeTelemetryModel({
    required this.estuaryName,
    required this.riverMouthDistanceKm,
    required this.salineWedgeLengthKm,
    required this.upstreamFreshwaterDischargeCumecs,
    required this.estuaryChannelDepthM,
    required this.densimetricFroudeNumber,
    required this.surfaceSalinityPpt,
    required this.bottomBedSalinityPpt,
    required this.astronomicalTidalRangeM,
    required this.tidalPrismPhase,
    required this.tidalPrismVolumeMillionM3,
  });

  factory EstuarineSalineWedgeTelemetryModel.fromJson(Map<String, dynamic> json) {
    return EstuarineSalineWedgeTelemetryModel(
      estuaryName: json['estuary_name'] as String? ?? '',
      riverMouthDistanceKm: (json['river_mouth_distance_km'] as num).toDouble(),
      salineWedgeLengthKm: (json['saline_wedge_length_km'] as num).toDouble(),
      upstreamFreshwaterDischargeCumecs: (json['upstream_freshwater_discharge_cumecs'] as num).toDouble(),
      estuaryChannelDepthM: (json['estuary_channel_depth_m'] as num).toDouble(),
      densimetricFroudeNumber: (json['densimetric_froude_number'] as num).toDouble(),
      surfaceSalinityPpt: (json['surface_salinity_ppt'] as num).toDouble(),
      bottomBedSalinityPpt: (json['bottom_bed_salinity_ppt'] as num).toDouble(),
      astronomicalTidalRangeM: (json['astronomical_tidal_range_m'] as num).toDouble(),
      tidalPrismPhase: json['tidal_prism_phase'] as String? ?? 'SPRING_HIGH_TIDE',
      tidalPrismVolumeMillionM3: (json['tidal_prism_volume_million_m3'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'estuary_name': estuaryName,
        'river_mouth_distance_km': riverMouthDistanceKm,
        'saline_wedge_length_km': salineWedgeLengthKm,
        'upstream_freshwater_discharge_cumecs': upstreamFreshwaterDischargeCumecs,
        'estuary_channel_depth_m': estuaryChannelDepthM,
        'densimetric_froude_number': densimetricFroudeNumber,
        'surface_salinity_ppt': surfaceSalinityPpt,
        'bottom_bed_salinity_ppt': bottomBedSalinityPpt,
        'astronomical_tidal_range_m': astronomicalTidalRangeM,
        'tidal_prism_phase': tidalPrismPhase,
        'tidal_prism_volume_million_m3': tidalPrismVolumeMillionM3,
      };
}

class GhybenHerzbergAquiferMetricsModel {
  final double freshwaterPiezometricHeadMMsl;
  final double theoreticalFreshwaterLensDepthM;
  final double measuredSalineInterfaceDepthM;
  final double salineUpconingVelocityCmWeek;
  final String aquiferVulnerabilityTier;
  final double electricalConductivityUsCm;
  final double totalDissolvedSolidsMgL;
  final double sodiumAdsorptionRatioSar;
  final double chlorideConcentrationMgL;

  GhybenHerzbergAquiferMetricsModel({
    required this.freshwaterPiezometricHeadMMsl,
    required this.theoreticalFreshwaterLensDepthM,
    required this.measuredSalineInterfaceDepthM,
    required this.salineUpconingVelocityCmWeek,
    required this.aquiferVulnerabilityTier,
    required this.electricalConductivityUsCm,
    required this.totalDissolvedSolidsMgL,
    required this.sodiumAdsorptionRatioSar,
    required this.chlorideConcentrationMgL,
  });

  factory GhybenHerzbergAquiferMetricsModel.fromJson(Map<String, dynamic> json) {
    return GhybenHerzbergAquiferMetricsModel(
      freshwaterPiezometricHeadMMsl: (json['freshwater_piezometric_head_m_msl'] as num).toDouble(),
      theoreticalFreshwaterLensDepthM: (json['theoretical_freshwater_lens_depth_m'] as num).toDouble(),
      measuredSalineInterfaceDepthM: (json['measured_saline_interface_depth_m'] as num).toDouble(),
      salineUpconingVelocityCmWeek: (json['saline_upconing_velocity_cm_week'] as num).toDouble(),
      aquiferVulnerabilityTier: json['aquifer_vulnerability_tier'] as String? ?? 'ACTIVE_SALINE_UPCONING',
      electricalConductivityUsCm: (json['electrical_conductivity_us_cm'] as num).toDouble(),
      totalDissolvedSolidsMgL: (json['total_dissolved_solids_mg_l'] as num).toDouble(),
      sodiumAdsorptionRatioSar: (json['sodium_adsorption_ratio_sar'] as num).toDouble(),
      chlorideConcentrationMgL: (json['chloride_concentration_mg_l'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'freshwater_piezometric_head_m_msl': freshwaterPiezometricHeadMMsl,
        'theoretical_freshwater_lens_depth_m': theoreticalFreshwaterLensDepthM,
        'measured_saline_interface_depth_m': measuredSalineInterfaceDepthM,
        'saline_upconing_velocity_cm_week': salineUpconingVelocityCmWeek,
        'aquifer_vulnerability_tier': aquiferVulnerabilityTier,
        'electrical_conductivity_us_cm': electricalConductivityUsCm,
        'total_dissolved_solids_mg_l': totalDissolvedSolidsMgL,
        'sodium_adsorption_ratio_sar': sodiumAdsorptionRatioSar,
        'chloride_concentration_mg_l': chlorideConcentrationMgL,
      };
}

class CoastalAgricultureDirectivesModel {
  final String sluiceFlapGateStatus;
  final String sluiceClosureTimingNotice;
  final double borewellPumpingLimitHours;
  final List<String> recommendedSaltTolerantCrops;
  final double gypsumAmendmentDosageTonsHa;
  final String potableRoMembraneAlert;
  final String irrigationSuitabilityAdvice;

  CoastalAgricultureDirectivesModel({
    required this.sluiceFlapGateStatus,
    required this.sluiceClosureTimingNotice,
    required this.borewellPumpingLimitHours,
    required this.recommendedSaltTolerantCrops,
    required this.gypsumAmendmentDosageTonsHa,
    required this.potableRoMembraneAlert,
    required this.irrigationSuitabilityAdvice,
  });

  factory CoastalAgricultureDirectivesModel.fromJson(Map<String, dynamic> json) {
    return CoastalAgricultureDirectivesModel(
      sluiceFlapGateStatus: json['sluice_flap_gate_status'] as String? ?? 'CLOSED',
      sluiceClosureTimingNotice: json['sluice_closure_timing_notice'] as String? ?? '',
      borewellPumpingLimitHours: (json['borewell_pumping_limit_hours'] as num).toDouble(),
      recommendedSaltTolerantCrops: (json['recommended_salt_tolerant_crops'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      gypsumAmendmentDosageTonsHa: (json['gypsum_amendment_dosage_tons_ha'] as num).toDouble(),
      potableRoMembraneAlert: json['potable_ro_membrane_alert'] as String? ?? '',
      irrigationSuitabilityAdvice: json['irrigation_suitability_advice'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'sluice_flap_gate_status': sluiceFlapGateStatus,
        'sluice_closure_timing_notice': sluiceClosureTimingNotice,
        'borewell_pumping_limit_hours': borewellPumpingLimitHours,
        'recommended_salt_tolerant_crops': recommendedSaltTolerantCrops,
        'gypsum_amendment_dosage_tons_ha': gypsumAmendmentDosageTonsHa,
        'potable_ro_membrane_alert': potableRoMembraneAlert,
        'irrigation_suitability_advice': irrigationSuitabilityAdvice,
      };
}

class CoastalEstuarineZoneModel {
  final String zoneId;
  final String zoneName;
  final String coastalDistrict;
  final String stateName;
  final double latitude;
  final double longitude;
  final String coastalBodyType;
  final String salinitySeverity;
  final EstuarineSalineWedgeTelemetryModel estuarineWedge;
  final GhybenHerzbergAquiferMetricsModel aquiferMetrics;
  final CoastalAgricultureDirectivesModel directives;

  // ignore: non_constant_identifier_names
  EstuarineSalineWedgeTelemetryModel get estuarine_wedge => estuarineWedge;
  // ignore: non_constant_identifier_names
  GhybenHerzbergAquiferMetricsModel get aquifer_metrics => aquiferMetrics;

  CoastalEstuarineZoneModel({
    required this.zoneId,
    required this.zoneName,
    required this.coastalDistrict,
    required this.stateName,
    required this.latitude,
    required this.longitude,
    required this.coastalBodyType,
    required this.salinitySeverity,
    required this.estuarineWedge,
    required this.aquiferMetrics,
    required this.directives,
  });

  factory CoastalEstuarineZoneModel.fromJson(Map<String, dynamic> json) {
    return CoastalEstuarineZoneModel(
      zoneId: json['zone_id'] as String? ?? '',
      zoneName: json['zone_name'] as String? ?? '',
      coastalDistrict: json['coastal_district'] as String? ?? '',
      stateName: json['state_name'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      coastalBodyType: json['coastal_body_type'] as String? ?? 'Tidal Delta',
      salinitySeverity: json['salinity_severity'] as String? ?? 'SEVERE_SALINE_CONTAMINATION',
      estuarineWedge: EstuarineSalineWedgeTelemetryModel.fromJson(
          json['estuarine_wedge'] as Map<String, dynamic>),
      aquiferMetrics: GhybenHerzbergAquiferMetricsModel.fromJson(
          json['aquifer_metrics'] as Map<String, dynamic>),
      directives: CoastalAgricultureDirectivesModel.fromJson(
          json['directives'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'zone_id': zoneId,
        'zone_name': zoneName,
        'coastal_district': coastalDistrict,
        'state_name': stateName,
        'latitude': latitude,
        'longitude': longitude,
        'coastal_body_type': coastalBodyType,
        'salinity_severity': salinitySeverity,
        'estuarine_wedge': estuarineWedge.toJson(),
        'aquifer_metrics': aquiferMetrics.toJson(),
        'directives': directives.toJson(),
      };
}

class CoastalZoneSummaryModel {
  final String zoneId;
  final String zoneName;
  final String stateName;
  final double salineWedgeLengthKm;
  final double surfaceSalinityPpt;
  final String salinitySeverity;
  final String aquiferVulnerabilityTier;
  final String sluiceFlapGateStatus;

  CoastalZoneSummaryModel({
    required this.zoneId,
    required this.zoneName,
    required this.stateName,
    required this.salineWedgeLengthKm,
    required this.surfaceSalinityPpt,
    required this.salinitySeverity,
    required this.aquiferVulnerabilityTier,
    required this.sluiceFlapGateStatus,
  });

  factory CoastalZoneSummaryModel.fromJson(Map<String, dynamic> json) {
    return CoastalZoneSummaryModel(
      zoneId: json['zone_id'] as String? ?? '',
      zoneName: json['zone_name'] as String? ?? '',
      stateName: json['state_name'] as String? ?? '',
      salineWedgeLengthKm: (json['saline_wedge_length_km'] as num).toDouble(),
      surfaceSalinityPpt: (json['surface_salinity_ppt'] as num).toDouble(),
      salinitySeverity: json['salinity_severity'] as String? ?? 'NORMAL_FRESHWATER',
      aquiferVulnerabilityTier: json['aquifer_vulnerability_tier'] as String? ?? 'SAFE_CONFINED_LENS',
      sluiceFlapGateStatus: json['sluice_flap_gate_status'] as String? ?? 'OPEN',
    );
  }

  Map<String, dynamic> toJson() => {
        'zone_id': zoneId,
        'zone_name': zoneName,
        'state_name': stateName,
        'saline_wedge_length_km': salineWedgeLengthKm,
        'surface_salinity_ppt': surfaceSalinityPpt,
        'salinity_severity': salinitySeverity,
        'aquifer_vulnerability_tier': aquiferVulnerabilityTier,
        'sluice_flap_gate_status': sluiceFlapGateStatus,
      };
}

class SaltwaterIntrusionResponseModel {
  final String timestamp;
  final CoastalEstuarineZoneModel activeZone;
  final List<CoastalZoneSummaryModel> allZones;
  final Map<String, String> vernacularBulletins;
  final String dataSource;
  final bool isOfflineCached;

  SaltwaterIntrusionResponseModel({
    required this.timestamp,
    required this.activeZone,
    required this.allZones,
    required this.vernacularBulletins,
    required this.dataSource,
    this.isOfflineCached = false,
  });

  factory SaltwaterIntrusionResponseModel.fromJson(Map<String, dynamic> json, {bool isOfflineCached = false}) {
    return SaltwaterIntrusionResponseModel(
      timestamp: json['timestamp'] as String? ?? '',
      activeZone: CoastalEstuarineZoneModel.fromJson(json['active_zone'] as Map<String, dynamic>),
      allZones: (json['all_zones'] as List<dynamic>?)
              ?.map((e) => CoastalZoneSummaryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      vernacularBulletins: (json['vernacular_bulletins'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          {},
      dataSource: json['dataSource'] as String? ?? 'INCOIS Ocean State Forecast, CGWB & ICAR-CSSRI',
      isOfflineCached: isOfflineCached,
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'active_zone': activeZone.toJson(),
        'all_zones': allZones.map((e) => e.toJson()).toList(),
        'vernacular_bulletins': vernacularBulletins,
        'dataSource': dataSource,
      };

  factory SaltwaterIntrusionResponseModel.defaultFallback() {
    final estuarineWedge = EstuarineSalineWedgeTelemetryModel(
      estuaryName: 'Matla & Bidyadhari Estuary',
      riverMouthDistanceKm: 18.0,
      salineWedgeLengthKm: 28.5,
      upstreamFreshwaterDischargeCumecs: 45.0,
      estuaryChannelDepthM: 12.0,
      densimetricFroudeNumber: 0.075,
      surfaceSalinityPpt: 14.5,
      bottomBedSalinityPpt: 22.0,
      astronomicalTidalRangeM: 4.80,
      tidalPrismPhase: 'SPRING_HIGH_TIDE',
      tidalPrismVolumeMillionM3: 142.0,
    );

    final aquiferMetrics = GhybenHerzbergAquiferMetricsModel(
      freshwaterPiezometricHeadMMsl: 0.65,
      theoreticalFreshwaterLensDepthM: 26.0,
      measuredSalineInterfaceDepthM: 22.0,
      salineUpconingVelocityCmWeek: 4.2,
      aquiferVulnerabilityTier: 'ACTIVE_SALINE_UPCONING',
      electricalConductivityUsCm: 3850.0,
      totalDissolvedSolidsMgL: 2464.0,
      sodiumAdsorptionRatioSar: 7.8,
      chlorideConcentrationMgL: 1120.0,
    );

    final directives = CoastalAgricultureDirectivesModel(
      sluiceFlapGateStatus: 'CLOSED',
      sluiceClosureTimingNotice: 'Flap gates locked 2.5 hours prior to high astronomical spring tide peak.',
      borewellPumpingLimitHours: 2.5,
      recommendedSaltTolerantCrops: ['CSR-36 Salt-Tolerant Rice', 'Amal-Mana', 'Dhaincha (Sesbania)'],
      gypsumAmendmentDosageTonsHa: 3.5,
      potableRoMembraneAlert: 'Membrane scaling alert: Raw intake TDS exceeds 2400 mg/L. Engage dual anti-scalant dosing.',
      irrigationSuitabilityAdvice: 'DO NOT IRRIGATE directly from estuary or shallow borewells (EC: 3850 uS/cm). High risk of crop root burn.',
    );

    final activeZone = CoastalEstuarineZoneModel(
      zoneId: 'sundarbans_delta',
      zoneName: 'Sundarbans Estuarine Delta',
      coastalDistrict: 'South 24 Parganas',
      stateName: 'West Bengal',
      latitude: 22.15,
      longitude: 88.80,
      coastalBodyType: 'Tidal Delta & Mangrove Estuary',
      salinitySeverity: 'SEVERE_SALINE_CONTAMINATION',
      estuarineWedge: estuarineWedge,
      aquiferMetrics: aquiferMetrics,
      directives: directives,
    );

    return SaltwaterIntrusionResponseModel(
      timestamp: DateTime.now().toUtc().toIso8601String(),
      activeZone: activeZone,
      allZones: [
        CoastalZoneSummaryModel(
          zoneId: 'sundarbans_delta',
          zoneName: 'Sundarbans Estuarine Delta',
          stateName: 'West Bengal',
          salineWedgeLengthKm: 28.5,
          surfaceSalinityPpt: 14.5,
          salinitySeverity: 'SEVERE_SALINE_CONTAMINATION',
          aquiferVulnerabilityTier: 'ACTIVE_SALINE_UPCONING',
          sluiceFlapGateStatus: 'CLOSED',
        ),
        CoastalZoneSummaryModel(
          zoneId: 'cauvery_delta',
          zoneName: 'Cauvery Delta Maritime Aquifer',
          stateName: 'Tamil Nadu',
          salineWedgeLengthKm: 16.2,
          surfaceSalinityPpt: 8.5,
          salinitySeverity: 'SEVERE_SALINE_CONTAMINATION',
          aquiferVulnerabilityTier: 'CRITICAL_AQUIFER_CONTAMINATION',
          sluiceFlapGateStatus: 'CLOSED',
        ),
        CoastalZoneSummaryModel(
          zoneId: 'krishna_godavari',
          zoneName: 'Krishna-Godavari Estuarine Belt',
          stateName: 'Andhra Pradesh',
          salineWedgeLengthKm: 21.0,
          surfaceSalinityPpt: 6.8,
          salinitySeverity: 'MODERATE_BRACKISH_INGRESS',
          aquiferVulnerabilityTier: 'VULNERABLE_THINNING',
          sluiceFlapGateStatus: 'PARTIAL',
        ),
        CoastalZoneSummaryModel(
          zoneId: 'mahanadi_estuary',
          zoneName: 'Mahanadi Coastal Estuary',
          stateName: 'Odisha',
          salineWedgeLengthKm: 19.5,
          surfaceSalinityPpt: 5.2,
          salinitySeverity: 'MODERATE_BRACKISH_INGRESS',
          aquiferVulnerabilityTier: 'VULNERABLE_THINNING',
          sluiceFlapGateStatus: 'CLOSED',
        ),
        CoastalZoneSummaryModel(
          zoneId: 'vembanad_kuttanad',
          zoneName: 'Vembanad Lagoon & Kuttanad Polders',
          stateName: 'Kerala',
          salineWedgeLengthKm: 14.0,
          surfaceSalinityPpt: 3.5,
          salinitySeverity: 'SLIGHT_SALINE_STRESS',
          aquiferVulnerabilityTier: 'ACTIVE_SALINE_UPCONING',
          sluiceFlapGateStatus: 'CLOSED',
        ),
        CoastalZoneSummaryModel(
          zoneId: 'khambhat_narmada',
          zoneName: 'Gulf of Khambhat & Narmada Estuary',
          stateName: 'Gujarat',
          salineWedgeLengthKm: 42.0,
          surfaceSalinityPpt: 18.5,
          salinitySeverity: 'HYPERSALINE_SEAWATER_INCURSION',
          aquiferVulnerabilityTier: 'ACTIVE_SALINE_UPCONING',
          sluiceFlapGateStatus: 'CLOSED',
        ),
        CoastalZoneSummaryModel(
          zoneId: 'goa_zuari',
          zoneName: 'Goa Mandovi-Zuari Estuary',
          stateName: 'Goa',
          salineWedgeLengthKm: 22.5,
          surfaceSalinityPpt: 4.8,
          salinitySeverity: 'SLIGHT_SALINE_STRESS',
          aquiferVulnerabilityTier: 'SAFE_CONFINED_LENS',
          sluiceFlapGateStatus: 'OPEN',
        ),
      ],
      vernacularBulletins: {
        'EN': 'INCOIS & CGWB SALINITY BULLETIN: Sundarbans Estuarine Delta (South 24 Parganas) is experiencing SEVERE_SALINE_CONTAMINATION. Estuarine saline wedge has penetrated 28.5km inland. Groundwater EC is 3850 uS/cm (TDS: 2464 mg/L). Tidal sluice flap gates are CLOSED. Farmers must limit borewell pumping to prevent Ghyben-Herzberg saline upconing.',
        'HI': 'INCOIS एवं CGWB तटीय लवणता बुलेटिन: सुंदरबन डेल्टा में लवणता स्तर अत्यधिक गंभीर है। खारा पानी 28.5 किमी अंतर्देशीय तक पहुंच चुका है। भूजल विद्युत चालकता 3850 uS/cm है। किसान बोरवेल दोहन सीमित करें।',
        'BN': 'INCOIS ও CGWB উপকূলীয় লবণাক্ততা বুলেটিন: সুন্দরবন মোহনা ডেল্টায় লবণাক্ততার মাত্রা তীব্র। নদীর নোনা জলের খাঁড়ি অভ্যন্তরে ২৮.৫ কিমি পর্যন্ত প্রবেশ করেছে। জোয়ারের স্লুইস গেট বন্ধ রাখা হয়েছে। লবণ-সহনশীল ধান (CSR-36) চাষের পরামর্শ দেওয়া হচ্ছে।',
        'TA': 'INCOIS & CGWB உவர்ப்பு புல்லட்டின்: சுந்தரவன டெல்டா பகுதியில் உவர்ப்பு நிலை தீவிரமாக உள்ளது. விவசாயிகள் நிலத்தடி நீர் உறிஞ்சுதலைக் குறைக்கவும்.',
        'TE': 'INCOIS & CGWB తీరప్రాంత లవణీయత హెచ్చరిక: సుందర్బన్స్ డెల్టాలో లవణీయత తీవ్రత ఎక్కువగా ఉంది. రైతులు బోర్వెల్ పంపింగ్‌ను తగ్గించాలి.',
        'ML': 'INCOIS & CGWB തീരദേശ ലവണാംശ ബുള്ളറ്റിൻ: സുന്ദർബൻസ് മേഖലയിൽ ഉപ്പുവെള്ളം നദിക്കുള്ളിലേക്ക് 28.5 കി.മീ വ്യാപിച്ചു. കർഷകർ ഭൂഗർഭജല പമ്പിംഗ് നിയന്ത്രിക്കുക.',
        'GU': 'INCOIS અને CGWB દરિયાકાંઠા ખારાશ બુલેટિન: સુંદરબન ડેલ્ટામાં ખારાશનું પ્રમાણ વધારે છે. દરિયાઈ ખારી ફાચર નદીમાં 28.5 કિમી અંદર પહોંચી ચૂકી છે.',
      },
      dataSource: 'INCOIS Ocean State Forecast, Central Ground Water Board (CGWB) & ICAR-CSSRI [Offline Baseline]',
      isOfflineCached: true,
    );
  }
}
