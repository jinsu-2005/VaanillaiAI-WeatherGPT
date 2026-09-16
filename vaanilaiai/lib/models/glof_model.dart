class GlacialLakeMorphometryModel {
  final double surfaceAreaHa;
  final double surfaceAreaKm2;
  final double meanDepthM;
  final double maxDepthM;
  final double waterVolumeMillionM3;
  final double expansionRate10yrPct;
  final String satelliteSensorProvenance;

  const GlacialLakeMorphometryModel({
    required this.surfaceAreaHa,
    required this.surfaceAreaKm2,
    required this.meanDepthM,
    required this.maxDepthM,
    required this.waterVolumeMillionM3,
    required this.expansionRate10yrPct,
    required this.satelliteSensorProvenance,
  });

  factory GlacialLakeMorphometryModel.fromJson(Map<String, dynamic> json) {
    return GlacialLakeMorphometryModel(
      surfaceAreaHa: (json['surface_area_ha'] as num?)?.toDouble() ?? 168.0,
      surfaceAreaKm2: (json['surface_area_km2'] as num?)?.toDouble() ?? 1.68,
      meanDepthM: (json['mean_depth_m'] as num?)?.toDouble() ?? 38.0,
      maxDepthM: (json['max_depth_m'] as num?)?.toDouble() ?? 131.0,
      waterVolumeMillionM3:
          (json['water_volume_million_m3'] as num?)?.toDouble() ?? 63.84,
      expansionRate10yrPct:
          (json['expansion_rate_10yr_pct'] as num?)?.toDouble() ?? 28.5,
      satelliteSensorProvenance: json['satellite_sensor_provenance']?.toString() ??
          'Sentinel-1 SAR Multi-temporal Interferometry',
    );
  }

  Map<String, dynamic> toJson() => {
        'surface_area_ha': surfaceAreaHa,
        'surface_area_km2': surfaceAreaKm2,
        'mean_depth_m': meanDepthM,
        'max_depth_m': maxDepthM,
        'water_volume_million_m3': waterVolumeMillionM3,
        'expansion_rate_10yr_pct': expansionRate10yrPct,
        'satellite_sensor_provenance': satelliteSensorProvenance,
      };
}

class MoraineDamGeotechnicsModel {
  final double crestElevationM;
  final double damHeightM;
  final double crestWidthToHeightRatio;
  final double freeboardHeightM;
  final double permafrostDegradationPct;
  final double hydraulicPipingIndex;
  final String stabilityStatus;

  const MoraineDamGeotechnicsModel({
    required this.crestElevationM,
    required this.damHeightM,
    required this.crestWidthToHeightRatio,
    required this.freeboardHeightM,
    required this.permafrostDegradationPct,
    required this.hydraulicPipingIndex,
    required this.stabilityStatus,
  });

  factory MoraineDamGeotechnicsModel.fromJson(Map<String, dynamic> json) {
    return MoraineDamGeotechnicsModel(
      crestElevationM: (json['crest_elevation_m'] as num?)?.toDouble() ?? 5240.0,
      damHeightM: (json['dam_height_m'] as num?)?.toDouble() ?? 55.0,
      crestWidthToHeightRatio:
          (json['crest_width_to_height_ratio'] as num?)?.toDouble() ?? 1.65,
      freeboardHeightM:
          (json['freeboard_height_m'] as num?)?.toDouble() ?? 4.5,
      permafrostDegradationPct:
          (json['permafrost_degradation_pct'] as num?)?.toDouble() ?? 68.0,
      hydraulicPipingIndex:
          (json['hydraulic_piping_index'] as num?)?.toDouble() ?? 1.25,
      stabilityStatus: json['stability_status']?.toString() ??
          'CRITICAL PIPING & OVERTOPPING SUSCEPTIBILITY',
    );
  }

  Map<String, dynamic> toJson() => {
        'crest_elevation_m': crestElevationM,
        'dam_height_m': damHeightM,
        'crest_width_to_height_ratio': crestWidthToHeightRatio,
        'freeboard_height_m': freeboardHeightM,
        'permafrost_degradation_pct': permafrostDegradationPct,
        'hydraulic_piping_index': hydraulicPipingIndex,
        'stability_status': stabilityStatus,
      };
}

class BreachHydrodynamicsModel {
  final double peakOutflowDischargeM3S;
  final double breachFormationTimeHours;
  final double totalBreachVolumeMillionM3;
  final double wavePropagationSpeedKmh;
  final String triggerMechanism;

  const BreachHydrodynamicsModel({
    required this.peakOutflowDischargeM3S,
    required this.breachFormationTimeHours,
    required this.totalBreachVolumeMillionM3,
    required this.wavePropagationSpeedKmh,
    required this.triggerMechanism,
  });

  factory BreachHydrodynamicsModel.fromJson(Map<String, dynamic> json) {
    return BreachHydrodynamicsModel(
      peakOutflowDischargeM3S:
          (json['peak_outflow_discharge_m3_s'] as num?)?.toDouble() ?? 5300.0,
      breachFormationTimeHours:
          (json['breach_formation_time_hours'] as num?)?.toDouble() ?? 0.8,
      totalBreachVolumeMillionM3:
          (json['total_breach_volume_million_m3'] as num?)?.toDouble() ?? 45.0,
      wavePropagationSpeedKmh:
          (json['wave_propagation_speed_kmh'] as num?)?.toDouble() ?? 45.0,
      triggerMechanism: json['trigger_mechanism']?.toString() ??
          'OVERTOPPING_ICE_AVALANCHE_SURGE',
    );
  }

  Map<String, dynamic> toJson() => {
        'peak_outflow_discharge_m3_s': peakOutflowDischargeM3S,
        'breach_formation_time_hours': breachFormationTimeHours,
        'total_breach_volume_million_m3': totalBreachVolumeMillionM3,
        'wave_propagation_speed_kmh': wavePropagationSpeedKmh,
        'trigger_mechanism': triggerMechanism,
      };
}

class DownstreamImpactNodeModel {
  final String nodeName;
  final double distanceKm;
  final int waveArrivalEtaMin;
  final double peakSurgeDepthM;
  final String infrastructureAlert;
  final double evacuationZoneElevationM;

  const DownstreamImpactNodeModel({
    required this.nodeName,
    required this.distanceKm,
    required this.waveArrivalEtaMin,
    required this.peakSurgeDepthM,
    required this.infrastructureAlert,
    required this.evacuationZoneElevationM,
  });

  factory DownstreamImpactNodeModel.fromJson(Map<String, dynamic> json) {
    return DownstreamImpactNodeModel(
      nodeName: json['node_name']?.toString() ?? 'Downstream Settlement',
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 65.0,
      waveArrivalEtaMin: json['wave_arrival_eta_min'] as int? ?? 87,
      peakSurgeDepthM: (json['peak_surge_depth_m'] as num?)?.toDouble() ?? 18.5,
      infrastructureAlert: json['infrastructure_alert']?.toString() ??
          'RADIAL GATES EMERGENCY FLUSH',
      evacuationZoneElevationM:
          (json['evacuation_zone_elevation_m'] as num?)?.toDouble() ?? 35.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'node_name': nodeName,
        'distance_km': distanceKm,
        'wave_arrival_eta_min': waveArrivalEtaMin,
        'peak_surge_depth_m': peakSurgeDepthM,
        'infrastructure_alert': infrastructureAlert,
        'evacuation_zone_elevation_m': evacuationZoneElevationM,
      };
}

class GlacialLakeCorridorModel {
  final String lakeId;
  final String lakeName;
  final String riverBasin;
  final String state;
  final double latitude;
  final double longitude;
  final double elevationM;
  final String threatTier;
  final GlacialLakeMorphometryModel morphometry;
  final MoraineDamGeotechnicsModel moraineGeotechnics;
  final BreachHydrodynamicsModel breachHydrodynamics;
  final List<DownstreamImpactNodeModel> downstreamImpactTimeline;
  final List<String> ndmaSafetyDirectives;

  const GlacialLakeCorridorModel({
    required this.lakeId,
    required this.lakeName,
    required this.riverBasin,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.elevationM,
    required this.threatTier,
    required this.morphometry,
    required this.moraineGeotechnics,
    required this.breachHydrodynamics,
    required this.downstreamImpactTimeline,
    required this.ndmaSafetyDirectives,
  });

  factory GlacialLakeCorridorModel.fromJson(Map<String, dynamic> json) {
    return GlacialLakeCorridorModel(
      lakeId: json['lake_id']?.toString() ?? 'south_lhonak_sikkim',
      lakeName: json['lake_name']?.toString() ??
          'South Lhonak Lake (Chungthang / Teesta Basin)',
      riverBasin: json['river_basin']?.toString() ?? 'Teesta River Basin',
      state: json['state']?.toString() ?? 'Sikkim',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 27.915,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 88.205,
      elevationM: (json['elevation_m'] as num?)?.toDouble() ?? 5200.0,
      threatTier: json['threat_tier']?.toString() ?? 'CRITICAL_RED_BREACH_IMMINENT',
      morphometry: GlacialLakeMorphometryModel.fromJson(
          json['morphometry'] as Map<String, dynamic>? ?? {}),
      moraineGeotechnics: MoraineDamGeotechnicsModel.fromJson(
          json['moraine_geotechnics'] as Map<String, dynamic>? ?? {}),
      breachHydrodynamics: BreachHydrodynamicsModel.fromJson(
          json['breach_hydrodynamics'] as Map<String, dynamic>? ?? {}),
      downstreamImpactTimeline:
          (json['downstream_impact_timeline'] as List<dynamic>?)
                  ?.map((e) =>
                      DownstreamImpactNodeModel.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [],
      ndmaSafetyDirectives: (json['ndma_safety_directives'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'lake_id': lakeId,
        'lake_name': lakeName,
        'river_basin': riverBasin,
        'state': state,
        'latitude': latitude,
        'longitude': longitude,
        'elevation_m': elevationM,
        'threat_tier': threatTier,
        'morphometry': morphometry.toJson(),
        'moraine_geotechnics': moraineGeotechnics.toJson(),
        'breach_hydrodynamics': breachHydrodynamics.toJson(),
        'downstream_impact_timeline':
            downstreamImpactTimeline.map((e) => e.toJson()).toList(),
        'ndma_safety_directives': ndmaSafetyDirectives,
      };
}

class LakeSummaryModel {
  final String lakeId;
  final String lakeName;
  final String riverBasin;
  final String state;
  final double elevationM;
  final String threatTier;
  final double surfaceAreaHa;
  final double volumeMillionM3;
  final double peakDischargeM3S;
  final int earliestEtaMin;

  const LakeSummaryModel({
    required this.lakeId,
    required this.lakeName,
    required this.riverBasin,
    required this.state,
    required this.elevationM,
    required this.threatTier,
    required this.surfaceAreaHa,
    required this.volumeMillionM3,
    required this.peakDischargeM3S,
    required this.earliestEtaMin,
  });

  factory LakeSummaryModel.fromJson(Map<String, dynamic> json) {
    return LakeSummaryModel(
      lakeId: json['lake_id']?.toString() ?? '',
      lakeName: json['lake_name']?.toString() ?? '',
      riverBasin: json['river_basin']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      elevationM: (json['elevation_m'] as num?)?.toDouble() ?? 0.0,
      threatTier: json['threat_tier']?.toString() ?? 'MODERATE_YELLOW_WATCH',
      surfaceAreaHa: (json['surface_area_ha'] as num?)?.toDouble() ?? 0.0,
      volumeMillionM3: (json['volume_million_m3'] as num?)?.toDouble() ?? 0.0,
      peakDischargeM3S: (json['peak_discharge_m3_s'] as num?)?.toDouble() ?? 0.0,
      earliestEtaMin: json['earliest_eta_min'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'lake_id': lakeId,
        'lake_name': lakeName,
        'river_basin': riverBasin,
        'state': state,
        'elevation_m': elevationM,
        'threat_tier': threatTier,
        'surface_area_ha': surfaceAreaHa,
        'volume_million_m3': volumeMillionM3,
        'peak_discharge_m3_s': peakDischargeM3S,
        'earliest_eta_min': earliestEtaMin,
      };
}

class GlofResponseModel {
  final GlacialLakeCorridorModel selectedLake;
  final List<LakeSummaryModel> allLakes;
  final Map<String, String> bulletins;
  final bool offlineCached;
  final String generatedAt;

  const GlofResponseModel({
    required this.selectedLake,
    required this.allLakes,
    required this.bulletins,
    required this.offlineCached,
    required this.generatedAt,
  });

  factory GlofResponseModel.fromJson(Map<String, dynamic> json) {
    return GlofResponseModel(
      selectedLake: GlacialLakeCorridorModel.fromJson(
          json['selected_lake'] as Map<String, dynamic>? ?? {}),
      allLakes: (json['all_lakes'] as List<dynamic>?)
              ?.map((e) => LakeSummaryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      bulletins: (json['bulletins'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          {},
      offlineCached: json['offline_cached'] as bool? ?? false,
      generatedAt: json['generated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'selected_lake': selectedLake.toJson(),
        'all_lakes': allLakes.map((e) => e.toJson()).toList(),
        'bulletins': bulletins,
        'offline_cached': offlineCached,
        'generated_at': generatedAt,
      };

  factory GlofResponseModel.defaultFallback() {
    const morph = GlacialLakeMorphometryModel(
      surfaceAreaHa: 168.0,
      surfaceAreaKm2: 1.68,
      meanDepthM: 38.0,
      maxDepthM: 131.0,
      waterVolumeMillionM3: 63.84,
      expansionRate10yrPct: 28.5,
      satelliteSensorProvenance:
          'Sentinel-1 SAR & RISAT-1A Multi-temporal Interferometry',
    );

    const geo = MoraineDamGeotechnicsModel(
      crestElevationM: 5240.0,
      damHeightM: 55.0,
      crestWidthToHeightRatio: 1.65,
      freeboardHeightM: 4.5,
      permafrostDegradationPct: 68.0,
      hydraulicPipingIndex: 1.25,
      stabilityStatus: 'CRITICAL PIPING & AVALANCHE OVERTOPPING SUSCEPTIBILITY',
    );

    const hydro = BreachHydrodynamicsModel(
      peakOutflowDischargeM3S: 5300.0,
      breachFormationTimeHours: 0.8,
      totalBreachVolumeMillionM3: 45.0,
      wavePropagationSpeedKmh: 45.0,
      triggerMechanism: 'OVERTOPPING_ICE_AVALANCHE_SURGE',
    );

    const nodes = [
      DownstreamImpactNodeModel(
        nodeName: 'Teesta-III Chungthang Dam',
        distanceKm: 65.0,
        waveArrivalEtaMin: 87,
        peakSurgeDepthM: 18.5,
        infrastructureAlert:
            'RADIAL GATES FULL FLUSH - Open all bottom spillways immediately to prevent catastrophic barrage overtopping.',
        evacuationZoneElevationM: 35.0,
      ),
      DownstreamImpactNodeModel(
        nodeName: 'Mangan District Headquarters',
        distanceKm: 85.0,
        waveArrivalEtaMin: 113,
        peakSurgeDepthM: 12.0,
        infrastructureAlert:
            'CIVILIAN EVACUATION SIREN - Relocate riverbank settlements to designated municipal high grounds.',
        evacuationZoneElevationM: 30.0,
      ),
      DownstreamImpactNodeModel(
        nodeName: 'Dikchu Suspension Bridge & NH-10',
        distanceKm: 115.0,
        waveArrivalEtaMin: 153,
        peakSurgeDepthM: 8.5,
        infrastructureAlert:
            'HIGHWAY CLOSURE - Border Roads Organisation (BRO) emergency bridge and arterial transit halt.',
        evacuationZoneElevationM: 25.0,
      ),
      DownstreamImpactNodeModel(
        nodeName: 'Singtam Municipal Hub',
        distanceKm: 145.0,
        waveArrivalEtaMin: 193,
        peakSurgeDepthM: 6.2,
        infrastructureAlert:
            'FLOOD PLAIN EVACUATION - Public sirens active. Move beyond the 100-year inundation contour.',
        evacuationZoneElevationM: 20.0,
      ),
      DownstreamImpactNodeModel(
        nodeName: 'Rangpo Inter-State Border',
        distanceKm: 170.0,
        waveArrivalEtaMin: 226,
        peakSurgeDepthM: 4.8,
        infrastructureAlert:
            'BORDER DEFENSE & RESCUE - NDRF/SDRF emergency deployment on Teesta riparian corridor.',
        evacuationZoneElevationM: 15.0,
      ),
    ];

    const directives = [
      'IMMEDIATE EVACUATION: All riverside inhabitants within 200m lateral and 30m vertical from Teesta riverbed must evacuate immediately.',
      'HYDROPOWER DIRECTIVE: Teesta-III, Teesta-IV, and Teesta-V barrages must trigger complete sluice flush to eliminate reservoir backwater damming.',
      'HIGHWAY PASS RESTRICTION: BRO must shut NH-10 connectivity between Siliguri, Gangtok, and North Sikkim.',
      'COMMUNICATION ALERT: Indian Army, ITBP, and NDRF base camps on high-frequency satcom link.',
    ];

    final lake = GlacialLakeCorridorModel(
      lakeId: 'south_lhonak_sikkim',
      lakeName: 'South Lhonak Lake (Chungthang / Teesta Basin)',
      riverBasin: 'Teesta River Basin',
      state: 'Sikkim',
      latitude: 27.9150,
      longitude: 88.2050,
      elevationM: 5200.0,
      threatTier: 'CRITICAL_RED_BREACH_IMMINENT',
      morphometry: morph,
      moraineGeotechnics: geo,
      breachHydrodynamics: hydro,
      downstreamImpactTimeline: nodes,
      ndmaSafetyDirectives: directives,
    );

    const summaries = [
      LakeSummaryModel(
        lakeId: 'south_lhonak_sikkim',
        lakeName: 'South Lhonak Lake (Chungthang / Teesta Basin)',
        riverBasin: 'Teesta River Basin',
        state: 'Sikkim',
        elevationM: 5200.0,
        threatTier: 'CRITICAL_RED_BREACH_IMMINENT',
        surfaceAreaHa: 168.0,
        volumeMillionM3: 63.84,
        peakDischargeM3S: 5300.0,
        earliestEtaMin: 87,
      ),
      LakeSummaryModel(
        lakeId: 'shako_cho_sikkim',
        lakeName: 'Shako Cho Glacial Lake (Mangan Basin)',
        riverBasin: 'Teesta Upper Catchment',
        state: 'Sikkim',
        elevationM: 4950.0,
        threatTier: 'HIGH_ORANGE_WARNING',
        surfaceAreaHa: 85.0,
        volumeMillionM3: 27.20,
        peakDischargeM3S: 3350.0,
        earliestEtaMin: 57,
      ),
      LakeSummaryModel(
        lakeId: 'chorabari_uttarakhand',
        lakeName: 'Chorabari Lake / Gandhi Sarovar (Kedarnath)',
        riverBasin: 'Mandakini River Basin',
        state: 'Uttarakhand',
        elevationM: 3900.0,
        threatTier: 'HIGH_ORANGE_WARNING',
        surfaceAreaHa: 35.0,
        volumeMillionM3: 6.30,
        peakDischargeM3S: 2800.0,
        earliestEtaMin: 4,
      ),
      LakeSummaryModel(
        lakeId: 'ghepan_gath_himachal',
        lakeName: 'Ghepan Gath Lake (Lahaul & Spiti)',
        riverBasin: 'Chandra River Basin (Chenab)',
        state: 'Himachal Pradesh',
        elevationM: 4680.0,
        threatTier: 'HIGH_ORANGE_WARNING',
        surfaceAreaHa: 95.0,
        volumeMillionM3: 36.10,
        peakDischargeM3S: 3900.0,
        earliestEtaMin: 44,
      ),
      LakeSummaryModel(
        lakeId: 'chamoli_ronti_uttarakhand',
        lakeName: 'Chamoli / Ronti Glacier Lake (Rishiganga)',
        riverBasin: 'Dhauliganga / Alaknanda Basin',
        state: 'Uttarakhand',
        elevationM: 4400.0,
        threatTier: 'MODERATE_YELLOW_WATCH',
        surfaceAreaHa: 25.0,
        volumeMillionM3: 3.75,
        peakDischargeM3S: 2150.0,
        earliestEtaMin: 30,
      ),
      LakeSummaryModel(
        lakeId: 'pareechu_himachal',
        lakeName: 'Pareechu Glacial Lake (Spiti / Tibet Border)',
        riverBasin: 'Sutlej River Basin',
        state: 'Himachal Pradesh',
        elevationM: 4200.0,
        threatTier: 'MODERATE_YELLOW_WATCH',
        surfaceAreaHa: 65.0,
        volumeMillionM3: 14.30,
        peakDischargeM3S: 2900.0,
        earliestEtaMin: 58,
      ),
      LakeSummaryModel(
        lakeId: 'dibang_cluster_arunachal',
        lakeName: 'Dibang Proglacial Lake Cluster',
        riverBasin: 'Dibang / Brahmaputra Basin',
        state: 'Arunachal Pradesh',
        elevationM: 4800.0,
        threatTier: 'LOW_GREEN_MONITOR',
        surfaceAreaHa: 48.0,
        volumeMillionM3: 9.60,
        peakDischargeM3S: 2400.0,
        earliestEtaMin: 94,
      ),
    ];

    const bulletins = {
      'en':
          'NRSC-CWC-NDMA GLOF BULLETIN for South Lhonak Lake (5200m MSL): Threat Level CRITICAL_RED_BREACH_IMMINENT. Projected peak breach outflow discharge 5,300 m³/s. Earliest flood wave ETA to Teesta-III Chungthang Dam is 87 minutes. Immediate vertical civilian evacuation (>30m above riverbed) and hydropower barrage sluice flush ordered.',
      'hi':
          'एनआरएससी-सीडब्ल्यूसी-एनडीएमए हिमनद झील विस्फोट (GLOF) बुलेटिन - साउथ ल्होनाक झील (5200 मीटर ऊँचाई): चेतावनी स्तर CRITICAL_RED_BREACH_IMMINENT। अनुमानित अधिकतम रिसाव प्रवाह 5,300 घन मीटर/सेकंड। तीस्ता-III चुंगथांग बाँध तक बाढ़ की लहर पहुँचने का समय मात्र 87 मिनट है। नदी किनारे से तुरंत 30 मीटर ऊँचाई पर सुरक्षित स्थानों की ओर जाएँ तथा जलविद्युत बाँधों के फ्लश गेट तुरंत खोलें।',
      'ne':
          'राष्ट्रिय विपद् व्यवस्थापन प्राधिकरण (NDMA) र CWC हिमनदी ताल विष्फोट (GLOF) सूचना - साउथ ल्होनाक ताल (5200 मिटर): खतराको स्तर CRITICAL_RED_BREACH_IMMINENT। अनुमानित उच्च बहाव 5,300 m³/s। तीस्ता-III चुङ्थाङ बाँधसम्म बाढीको लहर आइपुग्ने समय 87 मिनेट मात्र। नदी किनारका बासिन्दा तुरुन्त ३० मिटरभन्दा माथिल्लो सुरक्षित स्थानमा जानुहोस् र जलविद्युत बाँधका ढोकाहरू तत्काल खोल्नुहोस्।',
      'bo':
          'NRSC-CWC-NDMA གངས་རིའི་མཚོ་བརྡོལ་ཉེན་བརྡ། South Lhonak Lake (མཐོ་ཚད་ 5200m): ཉེན་ཚབས་རིམ་པ། CRITICAL_RED_BREACH_IMMINENT། ཆུ་ལོག་ཆེ་ཤོས་ 5,300 m³/s འབབ་རྒྱུའི་ཚོད་དཔག Teesta-III Chungthang Dam ལ་ཆུ་ལོག་སླེབས་པའི་དུས་ཚོད་སྐར་མ་ 87 ཡིན། གཙང་པོའི་འགྲམ་ནས་མཐོ་ཚད་ 30m ཡན་གྱི་ས་ཆ་མཐོན་པོར་འཕྲལ་དུ་གནས་སྤོ་དགོས།',
      'pa':
          'NRSC-CWC-NDMA ਗਲੇਸ਼ੀਅਰ ਝੀਲ ਫਟਣ (GLOF) ਚਿਤਾਵਨੀ - ਸਾਊਥ ਲਹੋਨਾਕ ਝੀਲ (5200 ਮੀਟਰ): ਖ਼ਤਰਾ ਪੱਧਰ CRITICAL_RED_BREACH_IMMINENT। ਅੰਦਾਜ਼ਨ ਸਿਖਰ ਨਿਕਾਸੀ 5,300 ਕਿਊਬਿਕ ਮੀਟਰ/ਸੈਕਿੰਡ। ਤੀਸਤਾ-III ਚੁੰਗਥਾਂਗ ਡੈਮ ਤੱਕ ਹੜ੍ਹ ਦੀ ਲਹਿਰ ਪਹੁੰਚਣ ਦਾ ਸਮਾਂ 87 ਮਿੰਟ ਹੈ। ਨਦੀ ਕੰਢੇ ਤੋਂ ਤੁਰੰਤ 30 ਮੀਟਰ ਉੱਚੇ ਸੁਰੱਖਿਅਤ ਸਥਾਨਾਂ ਤੇ ਜਾਓ।',
      'bn':
          'NRSC-CWC-NDMA হিমবাহ হ্রদ বিস্ফোরণ (GLOF) সতর্কতা - সাউথ লহোনাক হ্রদ (৫২০০ মিটার উচ্চতা): সতর্কতা স্তর CRITICAL_RED_BREACH_IMMINENT। সম্ভাব্য সর্বোচ্চ বন্যা প্রবাহ ৫,৩০০ ঘনমিটার/সেকেন্ড। তিস্তা-III চুংথাং বাঁধে প্লাবন পৌঁছানোর সময় মাত্র ৮৭ মিনিট। নদী তীরবর্তী মানুষ অবিলম্বে ৩০ মিটারের বেশি উঁচু স্থানে আশ্রয় নিন।',
      'as':
          'NRSC-CWC-NDMA হিমবাহ হ্ৰদ বিস্ফোৰণ (GLOF) সতৰ্কবাৰ্তা - দক্ষিণ লহোনাক হ্ৰদ (৫২০০ মিটাৰ): ভাবুকি স্তৰ CRITICAL_RED_BREACH_IMMINENT। সম্ভাৱ্য সৰ্বাধিক নিৰ্গমন প্ৰবাহ ৫,৩০০ ঘনমিটাৰ/ছেকেণ্ড। তিস্তা-III চুংথাং বান্ধ পোৱাৰ আনুমানিক সময় ৮৭ মিনিট। নৈৰ পাৰৰ পৰা তাৎক্ষণিকভাৱে ৩০ মিটাৰ ওখ সুৰক্ষিত স্থানলৈ স্থানান্তৰ হওক।',
    };

    return GlofResponseModel(
      selectedLake: lake,
      allLakes: summaries,
      bulletins: bulletins,
      offlineCached: true,
      generatedAt: DateTime.now().toUtc().toIso8601String(),
    );
  }
}
