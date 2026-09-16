class ThermodynamicInstabilityModel {
  final double capeJKg;
  final double liftedIndexC;
  final double kIndexC;
  final double totalTotalsC;
  final double sweatIndex;
  final double bulkWindShear06kmKt;
  final double cinJKg;

  const ThermodynamicInstabilityModel({
    required this.capeJKg,
    required this.liftedIndexC,
    required this.kIndexC,
    required this.totalTotalsC,
    required this.sweatIndex,
    required this.bulkWindShear06kmKt,
    required this.cinJKg,
  });

  factory ThermodynamicInstabilityModel.fromJson(Map<String, dynamic> json) {
    return ThermodynamicInstabilityModel(
      capeJKg: (json['cape_j_kg'] as num?)?.toDouble() ?? 2500.0,
      liftedIndexC: (json['lifted_index_c'] as num?)?.toDouble() ?? -5.0,
      kIndexC: (json['k_index_c'] as num?)?.toDouble() ?? 35.0,
      totalTotalsC: (json['total_totals_c'] as num?)?.toDouble() ?? 50.0,
      sweatIndex: (json['sweat_index'] as num?)?.toDouble() ?? 350.0,
      bulkWindShear06kmKt: (json['bulk_wind_shear_0_6km_kt'] as num?)?.toDouble() ?? 40.0,
      cinJKg: (json['cin_j_kg'] as num?)?.toDouble() ?? 25.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'cape_j_kg': capeJKg,
        'lifted_index_c': liftedIndexC,
        'k_index_c': kIndexC,
        'total_totals_c': totalTotalsC,
        'sweat_index': sweatIndex,
        'bulk_wind_shear_0_6km_kt': bulkWindShear06kmKt,
        'cin_j_kg': cinJKg,
      };
}

class HaboobDensityCurrentModel {
  final double gustFrontSpeedKmh;
  final double dustWallHeightM;
  final double minimumVisibilityM;
  final double pm10SurgeUgM3;
  final double coldPoolTempDropC;
  final String downdraftSpreadDirection;

  const HaboobDensityCurrentModel({
    required this.gustFrontSpeedKmh,
    required this.dustWallHeightM,
    required this.minimumVisibilityM,
    required this.pm10SurgeUgM3,
    required this.coldPoolTempDropC,
    required this.downdraftSpreadDirection,
  });

  factory HaboobDensityCurrentModel.fromJson(Map<String, dynamic> json) {
    return HaboobDensityCurrentModel(
      gustFrontSpeedKmh: (json['gust_front_speed_kmh'] as num?)?.toDouble() ?? 75.0,
      dustWallHeightM: (json['dust_wall_height_m'] as num?)?.toDouble() ?? 500.0,
      minimumVisibilityM: (json['minimum_visibility_m'] as num?)?.toDouble() ?? 300.0,
      pm10SurgeUgM3: (json['pm10_surge_ug_m3'] as num?)?.toDouble() ?? 400.0,
      coldPoolTempDropC: (json['cold_pool_temp_drop_c'] as num?)?.toDouble() ?? 8.0,
      downdraftSpreadDirection: json['downdraft_spread_direction'] as String? ?? 'North-West to South-East',
    );
  }

  Map<String, dynamic> toJson() => {
        'gust_front_speed_kmh': gustFrontSpeedKmh,
        'dust_wall_height_m': dustWallHeightM,
        'minimum_visibility_m': minimumVisibilityM,
        'pm10_surge_ug_m3': pm10SurgeUgM3,
        'cold_pool_temp_drop_c': coldPoolTempDropC,
        'downdraft_spread_direction': downdraftSpreadDirection,
      };
}

class AviationGridImpactModel {
  final String microburstRisk;
  final String powerGridRisk;
  final String airportAlert;
  final String structuralDamageRisk;

  const AviationGridImpactModel({
    required this.microburstRisk,
    required this.powerGridRisk,
    required this.airportAlert,
    required this.structuralDamageRisk,
  });

  factory AviationGridImpactModel.fromJson(Map<String, dynamic> json) {
    return AviationGridImpactModel(
      microburstRisk: json['microburst_risk'] as String? ?? 'Moderate Microburst Risk',
      powerGridRisk: json['power_grid_risk'] as String? ?? 'Risk of distribution line tripping',
      airportAlert: json['airport_alert'] as String? ?? 'Aviation crosswind advisory',
      structuralDamageRisk: json['structural_damage_risk'] as String? ?? 'Damage to temporary structures',
    );
  }

  Map<String, dynamic> toJson() => {
        'microburst_risk': microburstRisk,
        'power_grid_risk': powerGridRisk,
        'airport_alert': airportAlert,
        'structural_damage_risk': structuralDamageRisk,
      };
}

class ConvectiveStormHotspotModel {
  final String hotspotId;
  final String hotspotName;
  final String state;
  final double latitude;
  final double longitude;
  final String phenomenon;
  final String warningStage;
  final String headline;
  final ThermodynamicInstabilityModel thermodynamics;
  final HaboobDensityCurrentModel densityCurrent;
  final AviationGridImpactModel aviationGrid;
  final double radarReflectivityDbz;
  final int nowcastValidityHours;

  const ConvectiveStormHotspotModel({
    required this.hotspotId,
    required this.hotspotName,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.phenomenon,
    required this.warningStage,
    required this.headline,
    required this.thermodynamics,
    required this.densityCurrent,
    required this.aviationGrid,
    required this.radarReflectivityDbz,
    required this.nowcastValidityHours,
  });

  factory ConvectiveStormHotspotModel.fromJson(Map<String, dynamic> json) {
    return ConvectiveStormHotspotModel(
      hotspotId: json['hotspot_id'] as String? ?? 'kolkata_gangetic_wb',
      hotspotName: json['hotspot_name'] as String? ?? 'Kolkata & Gangetic West Bengal Corridor',
      state: json['state'] as String? ?? 'West Bengal',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 22.5726,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 88.3639,
      phenomenon: json['phenomenon'] as String? ?? 'KALBAISHAKHI_NORWESTER',
      warningStage: json['warning_stage'] as String? ?? 'STAGE_4_RED_SEVERE_WARNING',
      headline: json['headline'] as String? ?? 'Red Alert: Severe Kalbaishakhi squall line advancing.',
      thermodynamics: ThermodynamicInstabilityModel.fromJson(json['thermodynamics'] as Map<String, dynamic>? ?? {}),
      densityCurrent: HaboobDensityCurrentModel.fromJson(json['density_current'] as Map<String, dynamic>? ?? {}),
      aviationGrid: AviationGridImpactModel.fromJson(json['aviation_grid'] as Map<String, dynamic>? ?? {}),
      radarReflectivityDbz: (json['radar_reflectivity_dbz'] as num?)?.toDouble() ?? 60.0,
      nowcastValidityHours: (json['nowcast_validity_hours'] as num?)?.toInt() ?? 3,
    );
  }

  Map<String, dynamic> toJson() => {
        'hotspot_id': hotspotId,
        'hotspot_name': hotspotName,
        'state': state,
        'latitude': latitude,
        'longitude': longitude,
        'phenomenon': phenomenon,
        'warning_stage': warningStage,
        'headline': headline,
        'thermodynamics': thermodynamics.toJson(),
        'density_current': densityCurrent.toJson(),
        'aviation_grid': aviationGrid.toJson(),
        'radar_reflectivity_dbz': radarReflectivityDbz,
        'nowcast_validity_hours': nowcastValidityHours,
      };
}

class ConvectiveStormResponseModel {
  final String timestamp;
  final ConvectiveStormHotspotModel selectedHotspot;
  final List<ConvectiveStormHotspotModel> allHotspots;
  final Map<String, String> vernacularBulletins;
  final String imdBulletinReference;
  final String provenance;
  final bool isOfflineCached;

  const ConvectiveStormResponseModel({
    required this.timestamp,
    required this.selectedHotspot,
    required this.allHotspots,
    required this.vernacularBulletins,
    required this.imdBulletinReference,
    required this.provenance,
    this.isOfflineCached = false,
  });

  factory ConvectiveStormResponseModel.fromJson(Map<String, dynamic> json, {bool isOfflineCached = false}) {
    final rawHotspots = json['all_hotspots'] as List<dynamic>? ?? [];
    final hotspots = rawHotspots.map((e) => ConvectiveStormHotspotModel.fromJson(e as Map<String, dynamic>)).toList();

    final rawBulletins = json['vernacular_bulletins'] as Map<String, dynamic>? ?? {};
    final bulletins = rawBulletins.map((k, v) => MapEntry(k, v.toString()));

    return ConvectiveStormResponseModel(
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      selectedHotspot: ConvectiveStormHotspotModel.fromJson(json['selected_hotspot'] as Map<String, dynamic>? ?? {}),
      allHotspots: hotspots.isNotEmpty ? hotspots : [ConvectiveStormHotspotModel.fromJson(const {})],
      vernacularBulletins: bulletins,
      imdBulletinReference: json['imd_bulletin_reference'] as String? ?? 'IMD-SWFDP/NOWCAST/2026-ST',
      provenance: json['provenance'] as String? ??
          'India Meteorological Department (IMD) & WMO Severe Weather Forecasting Demonstration Project',
      isOfflineCached: isOfflineCached,
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'selected_hotspot': selectedHotspot.toJson(),
        'all_hotspots': allHotspots.map((e) => e.toJson()).toList(),
        'vernacular_bulletins': vernacularBulletins,
        'imd_bulletin_reference': imdBulletinReference,
        'provenance': provenance,
        'is_offline_cached': isOfflineCached,
      };

  factory ConvectiveStormResponseModel.defaultFallback() {
    const kolkata = ConvectiveStormHotspotModel(
      hotspotId: 'kolkata_gangetic_wb',
      hotspotName: 'Kolkata & Gangetic West Bengal Corridor',
      state: 'West Bengal',
      latitude: 22.5726,
      longitude: 88.3639,
      phenomenon: 'KALBAISHAKHI_NORWESTER',
      warningStage: 'STAGE_4_RED_SEVERE_WARNING',
      headline:
          'Red Alert: Severe Kalbaishakhi squall line advancing from Chhotanagpur Plateau with gale winds up to 95 km/h, intense lightning, and severe hail.',
      thermodynamics: ThermodynamicInstabilityModel(
        capeJKg: 3650.0,
        liftedIndexC: -7.2,
        kIndexC: 41.0,
        totalTotalsC: 56.0,
        sweatIndex: 415.0,
        bulkWindShear06kmKt: 52.0,
        cinJKg: 15.0,
      ),
      densityCurrent: HaboobDensityCurrentModel(
        gustFrontSpeedKmh: 95.0,
        dustWallHeightM: 450.0,
        minimumVisibilityM: 150.0,
        pm10SurgeUgM3: 420.0,
        coldPoolTempDropC: 10.5,
        downdraftSpreadDirection: 'North-West to South-East',
      ),
      aviationGrid: AviationGridImpactModel(
        microburstRisk: 'Severe Microburst Alert — Low-Level Wind Shear >45 kt',
        powerGridRisk: 'Extreme risk of 400kV / 220kV transmission line tripping',
        airportAlert: 'CCU (Kolkata Airport) ground operations cautioned',
        structuralDamageRisk: 'High risk of tree uprooting and billboard collapse',
      ),
      radarReflectivityDbz: 62.0,
      nowcastValidityHours: 3,
    );

    const bikaner = ConvectiveStormHotspotModel(
      hotspotId: 'bikaner_thar_desert',
      hotspotName: 'Bikaner & Western Thar Desert Sector',
      state: 'Rajasthan',
      latitude: 28.0229,
      longitude: 73.3119,
      phenomenon: 'HABOOB_ANDHI_DUST_STORM',
      warningStage: 'STAGE_4_RED_SEVERE_WARNING',
      headline:
          'Red Alert: Massive convective Haboob dust wall (>2,500m height) advancing across Thar Desert. Zero optical visibility (<50m).',
      thermodynamics: ThermodynamicInstabilityModel(
        capeJKg: 2150.0,
        liftedIndexC: -4.2,
        kIndexC: 32.0,
        totalTotalsC: 54.0,
        sweatIndex: 340.0,
        bulkWindShear06kmKt: 40.0,
        cinJKg: 60.0,
      ),
      densityCurrent: HaboobDensityCurrentModel(
        gustFrontSpeedKmh: 88.0,
        dustWallHeightM: 2600.0,
        minimumVisibilityM: 40.0,
        pm10SurgeUgM3: 1850.0,
        coldPoolTempDropC: 11.0,
        downdraftSpreadDirection: 'West to East-North-East',
      ),
      aviationGrid: AviationGridImpactModel(
        microburstRisk: 'Extreme dust-raising microburst hazard',
        powerGridRisk: 'Severe insulator flashovers and transmission tower bending torque',
        airportAlert: 'Runway visual range collapsed; traffic holding',
        structuralDamageRisk: 'Severe blinding on National Highways and acute respiratory crisis',
      ),
      radarReflectivityDbz: 48.0,
      nowcastValidityHours: 3,
    );

    return const ConvectiveStormResponseModel(
      timestamp: '2026-09-12T06:00:00Z',
      selectedHotspot: kolkata,
      allHotspots: [kolkata, bikaner],
      vernacularBulletins: {
        'en':
            'IMD SEVERE CONVECTIVE NOWCAST: Kolkata Corridor under STAGE 4 RED SEVERE WARNING for Kalbaishakhi Norwester. Leading gust front: 95 km/h, CAPE: 3650 J/kg. Stay indoors away from electrical poles.',
        'hi':
            'आईएमडी गंभीर तूफ़ान चेतावनी: कोलकाता क्षेत्र में कालवैशाखी तूफ़ान के लिए रेड अलर्ट जारी। हवा की गति 95 किमी/घंटा। सुरक्षित पक्के मकान में रहें।',
        'bn':
            'আইএমডি তীব্র কালবৈশাখী ও বজ্রঝড় সতর্কতা: কলকাতায় লাল সতর্কতা (Red Alert) জারি করা হয়েছে। দমকা ঝড়ের গতিবেগ ৯৫ কিমি/ঘণ্টা। গাছ ও বিদ্যুতের খুঁটির নিচে আশ্রয় নেবেন না।',
        'or':
            'ଆଇଏମଡି ଭୀଷଣ କାଳବୈଶାଖୀ ସତର୍କତା: କୋଲକାତା ଓ ଉପକୂଳ ଅଞ୍ଚଳରେ ରେଡ୍ ଆଲର୍ଟ। ପବନର ବେଗ ୯୫ କିମି/ଘଣ୍ଟା। ଘର ଭିତରେ ସୁରକ୍ଷିତ ରୁହନ୍ତୁ।',
        'as':
            'আইএমডি তীব্র বৰদৈচিলা সতৰ্কবাণী: বতাহৰ গতিবেগ ৯৫ কিমি/ঘণ্টা। অহা ৩ ঘণ্টাৰ বাবে সাৱধান হওক আৰু নিৰাপদ স্থানত থাকক।',
      },
      imdBulletinReference: 'IMD-SWFDP/NOWCAST/2026-ST-0912',
      provenance: 'India Meteorological Department (IMD) & WMO Severe Weather Forecasting Demonstration Project',
      isOfflineCached: true,
    );
  }
}
