class ThermalStressMetricsModel {
  final double seaSurfaceTempC;
  final double climatologicalMmmC;
  final double sstAnomalyC;
  final double coralHotspotC;
  final double degreeHeatingWeeks;
  final String bleachingAlertLevel;

  const ThermalStressMetricsModel({
    required this.seaSurfaceTempC,
    required this.climatologicalMmmC,
    required this.sstAnomalyC,
    required this.coralHotspotC,
    required this.degreeHeatingWeeks,
    required this.bleachingAlertLevel,
  });

  factory ThermalStressMetricsModel.fromJson(Map<String, dynamic> json) {
    return ThermalStressMetricsModel(
      seaSurfaceTempC: (json['sea_surface_temp_c'] as num?)?.toDouble() ?? 30.5,
      climatologicalMmmC: (json['climatological_mmm_c'] as num?)?.toDouble() ?? 29.5,
      sstAnomalyC: (json['sst_anomaly_c'] as num?)?.toDouble() ?? 1.5,
      coralHotspotC: (json['coral_hotspot_c'] as num?)?.toDouble() ?? 1.5,
      degreeHeatingWeeks: (json['degree_heating_weeks'] as num?)?.toDouble() ?? 6.0,
      bleachingAlertLevel: json['bleaching_alert_level'] as String? ?? 'BLEACHING_WARNING',
    );
  }

  Map<String, dynamic> toJson() => {
        'sea_surface_temp_c': seaSurfaceTempC,
        'climatological_mmm_c': climatologicalMmmC,
        'sst_anomaly_c': sstAnomalyC,
        'coral_hotspot_c': coralHotspotC,
        'degree_heating_weeks': degreeHeatingWeeks,
        'bleaching_alert_level': bleachingAlertLevel,
      };
}

class MarineHeatwaveTelemetryModel {
  final String category;
  final int durationDays;
  final double peakAnomalyC;
  final double depthPenetrationM;
  final String pelagicFishDisplacement;

  const MarineHeatwaveTelemetryModel({
    required this.category,
    required this.durationDays,
    required this.peakAnomalyC,
    required this.depthPenetrationM,
    required this.pelagicFishDisplacement,
  });

  factory MarineHeatwaveTelemetryModel.fromJson(Map<String, dynamic> json) {
    return MarineHeatwaveTelemetryModel(
      category: json['category'] as String? ?? 'CATEGORY_II_STRONG',
      durationDays: (json['duration_days'] as num?)?.toInt() ?? 14,
      peakAnomalyC: (json['peak_anomaly_c'] as num?)?.toDouble() ?? 2.2,
      depthPenetrationM: (json['depth_penetration_m'] as num?)?.toDouble() ?? 25.0,
      pelagicFishDisplacement: json['pelagic_fish_displacement'] as String? ??
          'Pelagic fish species displaced toward deeper, cooler thermoclines.',
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'duration_days': durationDays,
        'peak_anomaly_c': peakAnomalyC,
        'depth_penetration_m': depthPenetrationM,
        'pelagic_fish_displacement': pelagicFishDisplacement,
      };
}

class CoastalSeaFogTelemetryModel {
  final bool isFogActive;
  final double seaAirTempDiffC;
  final double nauticalVisibilityM;
  final double marineInversionHeightM;
  final String vtsChannelStatus;

  const CoastalSeaFogTelemetryModel({
    required this.isFogActive,
    required this.seaAirTempDiffC,
    required this.nauticalVisibilityM,
    required this.marineInversionHeightM,
    required this.vtsChannelStatus,
  });

  factory CoastalSeaFogTelemetryModel.fromJson(Map<String, dynamic> json) {
    return CoastalSeaFogTelemetryModel(
      isFogActive: json['is_fog_active'] as bool? ?? false,
      seaAirTempDiffC: (json['sea_air_temp_diff_c'] as num?)?.toDouble() ?? 1.0,
      nauticalVisibilityM: (json['nautical_visibility_m'] as num?)?.toDouble() ?? 8000.0,
      marineInversionHeightM: (json['marine_inversion_height_m'] as num?)?.toDouble() ?? 300.0,
      vtsChannelStatus: json['vts_channel_status'] as String? ?? 'Normal Open Navigation',
    );
  }

  Map<String, dynamic> toJson() => {
        'is_fog_active': isFogActive,
        'sea_air_temp_diff_c': seaAirTempDiffC,
        'nautical_visibility_m': nauticalVisibilityM,
        'marine_inversion_height_m': marineInversionHeightM,
        'vts_channel_status': vtsChannelStatus,
      };
}

class MarineConservationDirectivesModel {
  final String reefProtectionNotice;
  final String divingTourismAdvisory;
  final String artisanalFisherGuidance;
  final String artificialShadingStatus;

  const MarineConservationDirectivesModel({
    required this.reefProtectionNotice,
    required this.divingTourismAdvisory,
    required this.artisanalFisherGuidance,
    required this.artificialShadingStatus,
  });

  factory MarineConservationDirectivesModel.fromJson(Map<String, dynamic> json) {
    return MarineConservationDirectivesModel(
      reefProtectionNotice: json['reef_protection_notice'] as String? ?? 'Avoid mechanical damage to fragile corals.',
      divingTourismAdvisory: json['diving_tourism_advisory'] as String? ?? 'Strict neutral buoyancy for all divers.',
      artisanalFisherGuidance: json['artisanal_fisher_guidance'] as String? ??
          'Target deeper shelf waters for pelagic fishing operations.',
      artificialShadingStatus:
          json['artificial_shading_status'] as String? ?? 'In-situ coral nurseries under active thermal monitoring.',
    );
  }

  Map<String, dynamic> toJson() => {
        'reef_protection_notice': reefProtectionNotice,
        'diving_tourism_advisory': divingTourismAdvisory,
        'artisanal_fisher_guidance': artisanalFisherGuidance,
        'artificial_shading_status': artificialShadingStatus,
      };
}

class MarineHotspotSectorModel {
  final String hotspotId;
  final String sectorName;
  final String maritimeZone;
  final String stateOrUt;
  final double latitude;
  final double longitude;
  final String reefType;
  final List<String> dominantCoralTaxa;
  final ThermalStressMetricsModel thermalStress;
  final MarineHeatwaveTelemetryModel heatwave;
  final CoastalSeaFogTelemetryModel coastalFog;
  final MarineConservationDirectivesModel directives;

  const MarineHotspotSectorModel({
    required this.hotspotId,
    required this.sectorName,
    required this.maritimeZone,
    required this.stateOrUt,
    required this.latitude,
    required this.longitude,
    required this.reefType,
    required this.dominantCoralTaxa,
    required this.thermalStress,
    required this.heatwave,
    required this.coastalFog,
    required this.directives,
  });

  factory MarineHotspotSectorModel.fromJson(Map<String, dynamic> json) {
    return MarineHotspotSectorModel(
      hotspotId: json['hotspot_id'] as String? ?? 'gulf_of_mannar_rameshwaram',
      sectorName: json['sector_name'] as String? ?? 'Gulf of Mannar Biosphere Reserve & Rameswaram',
      maritimeZone: json['maritime_zone'] as String? ?? 'Gulf of Mannar / Palk Bay',
      stateOrUt: json['state_or_ut'] as String? ?? 'Tamil Nadu',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 9.2876,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 79.3129,
      reefType: json['reef_type'] as String? ?? 'Fringing Reef Complex',
      dominantCoralTaxa: (json['dominant_coral_taxa'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          ['Acropora formosa', 'Porites lutea', 'Montipora digitata'],
      thermalStress: ThermalStressMetricsModel.fromJson(json['thermal_stress'] as Map<String, dynamic>? ?? {}),
      heatwave: MarineHeatwaveTelemetryModel.fromJson(json['heatwave'] as Map<String, dynamic>? ?? {}),
      coastalFog: CoastalSeaFogTelemetryModel.fromJson(json['coastal_fog'] as Map<String, dynamic>? ?? {}),
      directives: MarineConservationDirectivesModel.fromJson(json['directives'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'hotspot_id': hotspotId,
        'sector_name': sectorName,
        'maritime_zone': maritimeZone,
        'state_or_ut': stateOrUt,
        'latitude': latitude,
        'longitude': longitude,
        'reef_type': reefType,
        'dominant_coral_taxa': dominantCoralTaxa,
        'thermal_stress': thermalStress.toJson(),
        'heatwave': heatwave.toJson(),
        'coastal_fog': coastalFog.toJson(),
        'directives': directives.toJson(),
      };
}

class MarineHeatwaveResponseModel {
  final String timestamp;
  final MarineHotspotSectorModel selectedSector;
  final List<MarineHotspotSectorModel> allSectors;
  final Map<String, String> vernacularBulletins;
  final String bulletinNumber;
  final String provenance;
  final bool isOfflineCached;

  const MarineHeatwaveResponseModel({
    required this.timestamp,
    required this.selectedSector,
    required this.allSectors,
    required this.vernacularBulletins,
    required this.bulletinNumber,
    required this.provenance,
    this.isOfflineCached = false,
  });

  factory MarineHeatwaveResponseModel.fromJson(Map<String, dynamic> json, {bool isOfflineCached = false}) {
    final rawSectors = json['all_sectors'] as List<dynamic>? ?? [];
    final sectors = rawSectors.map((e) => MarineHotspotSectorModel.fromJson(e as Map<String, dynamic>)).toList();

    final rawBulletins = json['vernacular_bulletins'] as Map<String, dynamic>? ?? {};
    final bulletins = rawBulletins.map((k, v) => MapEntry(k, v.toString()));

    return MarineHeatwaveResponseModel(
      timestamp: json['timestamp'] as String? ?? DateTime.now().toUtc().toIso8601String(),
      selectedSector: MarineHotspotSectorModel.fromJson(json['selected_sector'] as Map<String, dynamic>? ?? {}),
      allSectors: sectors,
      vernacularBulletins: bulletins,
      bulletinNumber: json['bulletin_number'] as String? ?? 'INCOIS-MHW/CRW/2026-DEFAULT',
      provenance: json['provenance'] as String? ??
          'INCOIS Ocean State Forecast, MoES Marine Living Resources & Coral Reef Watch (CRW)',
      isOfflineCached: isOfflineCached || (json['is_offline_cached'] as bool? ?? false),
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'selected_sector': selectedSector.toJson(),
        'all_sectors': allSectors.map((e) => e.toJson()).toList(),
        'vernacular_bulletins': vernacularBulletins,
        'bulletin_number': bulletinNumber,
        'provenance': provenance,
        'is_offline_cached': isOfflineCached,
      };

  static MarineHeatwaveResponseModel defaultFallback() {
    const mannar = MarineHotspotSectorModel(
      hotspotId: 'gulf_of_mannar_rameshwaram',
      sectorName: 'Gulf of Mannar Biosphere Reserve & Rameswaram',
      maritimeZone: 'Gulf of Mannar / Palk Bay',
      stateOrUt: 'Tamil Nadu',
      latitude: 9.2876,
      longitude: 79.3129,
      reefType: 'Fringing Reef & Patch Reef Complexes',
      dominantCoralTaxa: ['Acropora formosa', 'Porites lutea', 'Montipora digitata', 'Favia speciosa'],
      thermalStress: ThermalStressMetricsModel(
        seaSurfaceTempC: 31.8,
        climatologicalMmmC: 29.8,
        sstAnomalyC: 2.0,
        coralHotspotC: 2.0,
        degreeHeatingWeeks: 9.4,
        bleachingAlertLevel: 'ALERT_LEVEL_1',
      ),
      heatwave: MarineHeatwaveTelemetryModel(
        category: 'CATEGORY_II_STRONG',
        durationDays: 19,
        peakAnomalyC: 2.4,
        depthPenetrationM: 22.0,
        pelagicFishDisplacement:
            'Lesser sardines and Indian mackerel displaced to offshore depths (>30m); nearshore artisanal catch down by 45%.',
      ),
      coastalFog: CoastalSeaFogTelemetryModel(
        isFogActive: false,
        seaAirTempDiffC: 0.8,
        nauticalVisibilityM: 8500.0,
        marineInversionHeightM: 350.0,
        vtsChannelStatus: 'Normal Open Navigation',
      ),
      directives: MarineConservationDirectivesModel(
        reefProtectionNotice:
            'Coral Bleaching Alert Level 1: Widespread bleaching of branching Acropora corals observed across Krusadai and Shingle islands.',
        divingTourismAdvisory:
            'Prohibit boat anchoring on shallow reef flats (<5m depth); restrict snorkeling tourism to designated sandy paths.',
        artisanalFisherGuidance:
            'Artisanal fishers advised to set nets in deeper shelf waters (>35m) where cooler thermoclines prevail.',
        artificialShadingStatus:
            'Tamil Nadu Forest Department & SDMRI deploying shade cloth covers over in-situ coral nurseries.',
      ),
    );

    const lakshadweep = MarineHotspotSectorModel(
      hotspotId: 'lakshadweep_kavaratti',
      sectorName: 'Lakshadweep Atolls (Kavaratti & Agatti Lagoons)',
      maritimeZone: 'Southeastern Arabian Sea',
      stateOrUt: 'Lakshadweep',
      latitude: 10.5669,
      longitude: 72.6420,
      reefType: 'Atoll Lagoon & Barrier Reef Wall',
      dominantCoralTaxa: ['Acropora branching corals', 'Pocillopora damicornis', 'Porites solida'],
      thermalStress: ThermalStressMetricsModel(
        seaSurfaceTempC: 32.2,
        climatologicalMmmC: 29.5,
        sstAnomalyC: 2.7,
        coralHotspotC: 2.7,
        degreeHeatingWeeks: 13.5,
        bleachingAlertLevel: 'ALERT_LEVEL_2',
      ),
      heatwave: MarineHeatwaveTelemetryModel(
        category: 'CATEGORY_III_SEVERE',
        durationDays: 28,
        peakAnomalyC: 3.1,
        depthPenetrationM: 35.0,
        pelagicFishDisplacement:
            'Live baitfish in lagoons decimated by thermal shock; Skipjack and Yellowfin tuna schools displaced 20 nm offshore.',
      ),
      coastalFog: CoastalSeaFogTelemetryModel(
        isFogActive: false,
        seaAirTempDiffC: 0.5,
        nauticalVisibilityM: 12000.0,
        marineInversionHeightM: 500.0,
        vtsChannelStatus: 'Normal Open Navigation',
      ),
      directives: MarineConservationDirectivesModel(
        reefProtectionNotice:
            'CRITICAL EMERGENCY: Bleaching Alert Level 2 (DHW > 12 °C-weeks). Severe lagoon coral mortality.',
        divingTourismAdvisory:
            'Halt all recreational scuba diving and underwater propeller craft in lagoon passages.',
        artisanalFisherGuidance:
            'Pole-and-line tuna boats facing acute live bait scarcity. Utilize artificial jigs in deep oceanic zones.',
        artificialShadingStatus:
            'Urgent ex-situ cryopreservation of coral gametes and seawater pumping over shallow nurseries active.',
      ),
    );

    return const MarineHeatwaveResponseModel(
      timestamp: '2026-09-12T06:00:00Z',
      selectedSector: mannar,
      allSectors: [mannar, lakshadweep],
      vernacularBulletins: {
        'en':
            'INCOIS & MOES MARINE HEATWAVE BULLETIN: Gulf of Mannar is under ALERT LEVEL 1 & CATEGORY II STRONG. SST: 31.8°C (+2.0°C anomaly), DHW: 9.4 °C-weeks. Cease anchoring on shallow reef flats.',
        'ta':
            'இன்கோயிஸ் கடல் வெப்ப அலை எச்சரிக்கை: மன்னார் வளைகுடா பகுதியில் பவளப்பாறை வெளுத்தல் நிலை 1 (Alert Level 1) जारी செய்யப்பட்டுள்ளது. கடல் வெப்பநிலை 31.8°C. பவளப்பாறை பகுதிகளில் படகு நங்கூரமிடுவதைத் தவிர்க்கவும்.',
        'ml':
            'ഇൻകോയിസ് സമുദ്ര താപതരംഗ മുന്നറിയിപ്പ്: ഗൾഫ് ഓഫ് മന്നാർ മേഖലയിൽ പവിഴപ്പുറ്റ് വെളുക്കൽ മുന്നറിയിപ്പ് (Alert Level 1) നിലവിലുണ്ട്. സമുദ്ര താപനില 31.8°C. ആഴക്കടലിൽ മത്സ്യബന്ധനം നടത്തുക.',
        'gu':
            'ઇન્કોઇસ મરીન હીટવેવ બુલેટિન: મન્નારના અખાતમાં પરવાળાના બ્લીચિંગની ચેતવણી (Alert Level 1). દરિયાઈ સપાટીનું તાપમાન 31.8°C છે. પરવાળાના વિસ્તારોનું રક્ષણ કરો.',
        'mr':
            'इनकॉईस सागरी उष्णतेची लाट इशारा: मन्नारच्या आखातात प्रवाळ विरंजन इशारा (Alert Level 1) जारी. सागरी तापमान 31.8°C. प्रवाळ खडकांवर नौका नांगरण्यास मनाई.',
      },
      bulletinNumber: 'INCOIS-MHW/CRW/202609-SECGUL',
      provenance: 'INCOIS Ocean State Forecast, MoES Marine Living Resources & Coral Reef Watch (CRW)',
      isOfflineCached: true,
    );
  }
}
