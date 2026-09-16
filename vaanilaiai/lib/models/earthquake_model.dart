class EarthquakeSourceParametersModel {
  final double momentMagnitudeMw;
  final double localMagnitudeMl;
  final double focalDepthKm;
  final double epicenterLatitude;
  final double epicenterLongitude;
  final String originTimeUtc;
  final String faultMechanism;
  final double faultPlaneStrikeDeg;
  final double ruptureLengthKm;

  const EarthquakeSourceParametersModel({
    required this.momentMagnitudeMw,
    required this.localMagnitudeMl,
    required this.focalDepthKm,
    required this.epicenterLatitude,
    required this.epicenterLongitude,
    required this.originTimeUtc,
    required this.faultMechanism,
    required this.faultPlaneStrikeDeg,
    required this.ruptureLengthKm,
  });

  factory EarthquakeSourceParametersModel.fromJson(Map<String, dynamic> json) {
    return EarthquakeSourceParametersModel(
      momentMagnitudeMw: (json['moment_magnitude_mw'] as num?)?.toDouble() ?? 5.0,
      localMagnitudeMl: (json['local_magnitude_ml'] as num?)?.toDouble() ?? 4.8,
      focalDepthKm: (json['focal_depth_km'] as num?)?.toDouble() ?? 15.0,
      epicenterLatitude: (json['epicenter_latitude'] as num?)?.toDouble() ?? 28.6,
      epicenterLongitude: (json['epicenter_longitude'] as num?)?.toDouble() ?? 77.2,
      originTimeUtc: json['origin_time_utc']?.toString() ?? '2026-09-12T00:00:00Z',
      faultMechanism: json['fault_mechanism']?.toString() ?? 'REVERSE_THRUST',
      faultPlaneStrikeDeg: (json['fault_plane_strike_deg'] as num?)?.toDouble() ?? 0.0,
      ruptureLengthKm: (json['rupture_length_km'] as num?)?.toDouble() ?? 10.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'moment_magnitude_mw': momentMagnitudeMw,
        'local_magnitude_ml': localMagnitudeMl,
        'focal_depth_km': focalDepthKm,
        'epicenter_latitude': epicenterLatitude,
        'epicenter_longitude': epicenterLongitude,
        'origin_time_utc': originTimeUtc,
        'fault_mechanism': faultMechanism,
        'fault_plane_strike_deg': faultPlaneStrikeDeg,
        'rupture_length_km': ruptureLengthKm,
      };
}

class ModifiedMercalliIntensityModel {
  final String epicentralMmi;
  final double feltRadiusKm;
  final String perceivedShaking;
  final String potentialDamage;
  final int didYouFeelItReports;

  const ModifiedMercalliIntensityModel({
    required this.epicentralMmi,
    required this.feltRadiusKm,
    required this.perceivedShaking,
    required this.potentialDamage,
    required this.didYouFeelItReports,
  });

  factory ModifiedMercalliIntensityModel.fromJson(Map<String, dynamic> json) {
    return ModifiedMercalliIntensityModel(
      epicentralMmi: json['epicentral_mmi']?.toString() ?? 'V',
      feltRadiusKm: (json['felt_radius_km'] as num?)?.toDouble() ?? 100.0,
      perceivedShaking: json['perceived_shaking']?.toString() ?? 'Moderate',
      potentialDamage: json['potential_damage']?.toString() ?? 'Minor non-structural damage',
      didYouFeelItReports: (json['did_you_feel_it_reports'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'epicentral_mmi': epicentralMmi,
        'felt_radius_km': feltRadiusKm,
        'perceived_shaking': perceivedShaking,
        'potential_damage': potentialDamage,
        'did_you_feel_it_reports': didYouFeelItReports,
      };
}

class AftershockProbabilityModel {
  final double bathLawLargestAftershockMw;
  final double modifiedOmoriPValue;
  final double reasenbergJones24hProbabilityPct;
  final int expectedAftershocks7Day;
  final String coulombStressTransferDirection;

  const AftershockProbabilityModel({
    required this.bathLawLargestAftershockMw,
    required this.modifiedOmoriPValue,
    required this.reasenbergJones24hProbabilityPct,
    required this.expectedAftershocks7Day,
    required this.coulombStressTransferDirection,
  });

  factory AftershockProbabilityModel.fromJson(Map<String, dynamic> json) {
    return AftershockProbabilityModel(
      bathLawLargestAftershockMw:
          (json['bath_law_largest_aftershock_mw'] as num?)?.toDouble() ?? 3.8,
      modifiedOmoriPValue:
          (json['modified_omori_p_value'] as num?)?.toDouble() ?? 1.0,
      reasenbergJones24hProbabilityPct:
          (json['reasenberg_jones_24h_probability_pct'] as num?)?.toDouble() ?? 10.0,
      expectedAftershocks7Day:
          (json['expected_aftershocks_7_day'] as num?)?.toInt() ?? 5,
      coulombStressTransferDirection:
          json['coulomb_stress_transfer_direction']?.toString() ?? 'N/A',
    );
  }

  Map<String, dynamic> toJson() => {
        'bath_law_largest_aftershock_mw': bathLawLargestAftershockMw,
        'modified_omori_p_value': modifiedOmoriPValue,
        'reasenberg_jones_24h_probability_pct': reasenbergJones24hProbabilityPct,
        'expected_aftershocks_7_day': expectedAftershocks7Day,
        'coulomb_stress_transfer_direction': coulombStressTransferDirection,
      };
}

class StructuralVulnerabilityDirectivesModel {
  final String bisSeismicZone;
  final double designPgaG;
  final String buildingVulnerabilityClass;
  final String postQuakeInspectionPriority;
  final String softStoryCollapseRisk;
  final String masonryInfillDamageRisk;
  final List<String> ndmaDos;
  final List<String> ndmaDonts;

  const StructuralVulnerabilityDirectivesModel({
    required this.bisSeismicZone,
    required this.designPgaG,
    required this.buildingVulnerabilityClass,
    required this.postQuakeInspectionPriority,
    required this.softStoryCollapseRisk,
    required this.masonryInfillDamageRisk,
    required this.ndmaDos,
    required this.ndmaDonts,
  });

  factory StructuralVulnerabilityDirectivesModel.fromJson(Map<String, dynamic> json) {
    return StructuralVulnerabilityDirectivesModel(
      bisSeismicZone: json['bis_seismic_zone']?.toString() ?? 'ZONE_IV',
      designPgaG: (json['design_pga_g'] as num?)?.toDouble() ?? 0.24,
      buildingVulnerabilityClass:
          json['building_vulnerability_class']?.toString() ?? 'C (Moderate)',
      postQuakeInspectionPriority:
          json['post_quake_inspection_priority']?.toString() ?? 'Routine',
      softStoryCollapseRisk:
          json['soft_story_collapse_risk']?.toString() ?? 'LOW',
      masonryInfillDamageRisk:
          json['masonry_infill_damage_risk']?.toString() ?? 'LOW',
      ndmaDos: (json['ndma_dos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [
            'DROP to hands and knees, COVER head under sturdy table, HOLD ON',
            'Move to open ground after shaking stops',
            'Keep emergency torch, whistle, and first-aid kit accessible',
          ],
      ndmaDonts: (json['ndma_donts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [
            'DO NOT run outside during active shaking',
            'DO NOT use elevators during or after an earthquake',
            'DO NOT re-enter visibly damaged buildings',
          ],
    );
  }

  Map<String, dynamic> toJson() => {
        'bis_seismic_zone': bisSeismicZone,
        'design_pga_g': designPgaG,
        'building_vulnerability_class': buildingVulnerabilityClass,
        'post_quake_inspection_priority': postQuakeInspectionPriority,
        'soft_story_collapse_risk': softStoryCollapseRisk,
        'masonry_infill_damage_risk': masonryInfillDamageRisk,
        'ndma_dos': ndmaDos,
        'ndma_donts': ndmaDonts,
      };
}

class SeismotectonicProvinceModel {
  final String provinceId;
  final String provinceName;
  final String state;
  final String dominantFaultSystem;
  final double latitude;
  final double longitude;
  final String alertTier;
  final EarthquakeSourceParametersModel sourceParameters;
  final ModifiedMercalliIntensityModel mmiAssessment;
  final AftershockProbabilityModel aftershockOutlook;
  final StructuralVulnerabilityDirectivesModel structuralDirectives;
  final Map<String, String> vernacularAlerts;

  const SeismotectonicProvinceModel({
    required this.provinceId,
    required this.provinceName,
    required this.state,
    required this.dominantFaultSystem,
    required this.latitude,
    required this.longitude,
    required this.alertTier,
    required this.sourceParameters,
    required this.mmiAssessment,
    required this.aftershockOutlook,
    required this.structuralDirectives,
    required this.vernacularAlerts,
  });

  factory SeismotectonicProvinceModel.fromJson(Map<String, dynamic> json) {
    return SeismotectonicProvinceModel(
      provinceId: json['province_id']?.toString() ?? '',
      provinceName: json['province_name']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      dominantFaultSystem: json['dominant_fault_system']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      alertTier: json['alert_tier']?.toString() ?? 'GREEN_LIGHT',
      sourceParameters: EarthquakeSourceParametersModel.fromJson(
        (json['source_parameters'] as Map<String, dynamic>?) ?? {},
      ),
      mmiAssessment: ModifiedMercalliIntensityModel.fromJson(
        (json['mmi_assessment'] as Map<String, dynamic>?) ?? {},
      ),
      aftershockOutlook: AftershockProbabilityModel.fromJson(
        (json['aftershock_outlook'] as Map<String, dynamic>?) ?? {},
      ),
      structuralDirectives: StructuralVulnerabilityDirectivesModel.fromJson(
        (json['structural_directives'] as Map<String, dynamic>?) ?? {},
      ),
      vernacularAlerts: (json['vernacular_alerts'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          {},
    );
  }

  Map<String, dynamic> toJson() => {
        'province_id': provinceId,
        'province_name': provinceName,
        'state': state,
        'dominant_fault_system': dominantFaultSystem,
        'latitude': latitude,
        'longitude': longitude,
        'alert_tier': alertTier,
        'source_parameters': sourceParameters.toJson(),
        'mmi_assessment': mmiAssessment.toJson(),
        'aftershock_outlook': aftershockOutlook.toJson(),
        'structural_directives': structuralDirectives.toJson(),
        'vernacular_alerts': vernacularAlerts,
      };
}

class EarthquakeResponseModel {
  final String timestamp;
  final String bulletinNumber;
  final String provenance;
  final String nationalSeismicitySynopsis;
  final SeismotectonicProvinceModel selectedProvince;
  final List<SeismotectonicProvinceModel> allProvinces;
  final String seismologicalModel;
  final Map<String, String> vernacularBulletins;
  final bool isOfflineCached;

  const EarthquakeResponseModel({
    required this.timestamp,
    required this.bulletinNumber,
    required this.provenance,
    required this.nationalSeismicitySynopsis,
    required this.selectedProvince,
    required this.allProvinces,
    required this.seismologicalModel,
    required this.vernacularBulletins,
    this.isOfflineCached = false,
  });

  factory EarthquakeResponseModel.fromJson(Map<String, dynamic> json, {bool isOffline = false}) {
    return EarthquakeResponseModel(
      timestamp: json['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
      bulletinNumber: json['bulletin_number']?.toString() ?? 'NCS/IMD-SEIS/LIVE',
      provenance: json['provenance']?.toString() ??
          'National Centre for Seismology (NCS/IMD) & NDMA',
      nationalSeismicitySynopsis: json['national_seismicity_synopsis']?.toString() ??
          'MODERATE: Active seismicity monitored across Indian tectonic provinces',
      selectedProvince: SeismotectonicProvinceModel.fromJson(
        (json['selected_province'] as Map<String, dynamic>?) ?? {},
      ),
      allProvinces: (json['all_provinces'] as List<dynamic>?)
              ?.map((e) => SeismotectonicProvinceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      seismologicalModel: json['seismological_model']?.toString() ??
          'Gutenberg-Richter b-value ~ 0.9; Båth\'s Law Δm ≈ 1.2; IS:1893-2016 BIS Seismic Zonation',
      vernacularBulletins: (json['vernacular_bulletins'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          {},
      isOfflineCached: isOffline || (json['is_offline_cached'] as bool? ?? false),
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'bulletin_number': bulletinNumber,
        'provenance': provenance,
        'national_seismicity_synopsis': nationalSeismicitySynopsis,
        'selected_province': selectedProvince.toJson(),
        'all_provinces': allProvinces.map((p) => p.toJson()).toList(),
        'seismological_model': seismologicalModel,
        'vernacular_bulletins': vernacularBulletins,
        'is_offline_cached': isOfflineCached,
      };

  static EarthquakeResponseModel defaultFallback() {
    const delhiProvince = SeismotectonicProvinceModel(
      provinceId: 'delhi_ncr_igp',
      provinceName: 'Delhi-NCR & Indo-Gangetic Alluvial Plains',
      state: 'Delhi / Haryana / UP / Rajasthan',
      dominantFaultSystem:
          'Delhi-Sargodha Ridge, Mathura Fault & Himalayan Frontal Thrust (HFT) distal effects',
      latitude: 28.6139,
      longitude: 77.2090,
      alertTier: 'GREEN_LIGHT',
      sourceParameters: EarthquakeSourceParametersModel(
        momentMagnitudeMw: 4.2,
        localMagnitudeMl: 4.0,
        focalDepthKm: 8.0,
        epicenterLatitude: 28.75,
        epicenterLongitude: 77.40,
        originTimeUtc: '2026-09-12T06:30:05Z',
        faultMechanism: 'STRIKE_SLIP',
        faultPlaneStrikeDeg: 225.0,
        ruptureLengthKm: 2.5,
      ),
      mmiAssessment: ModifiedMercalliIntensityModel(
        epicentralMmi: 'IV',
        feltRadiusKm: 80.0,
        perceivedShaking: 'Light to Moderate',
        potentialDamage:
            'Widely felt; no significant damage; hanging objects sway; dishes rattle',
        didYouFeelItReports: 22000,
      ),
      aftershockOutlook: AftershockProbabilityModel(
        bathLawLargestAftershockMw: 3.0,
        modifiedOmoriPValue: 0.95,
        reasenbergJones24hProbabilityPct: 5.0,
        expectedAftershocks7Day: 3,
        coulombStressTransferDirection:
            'N along Delhi-Sargodha Ridge toward Sonipat',
      ),
      structuralDirectives: StructuralVulnerabilityDirectivesModel(
        bisSeismicZone: 'ZONE_IV',
        designPgaG: 0.24,
        buildingVulnerabilityClass:
            'C (Moderate — Modern high-rise RCC compliant)',
        postQuakeInspectionPriority: 'Routine',
        softStoryCollapseRisk:
            'LOW for IS:1893-compliant buildings',
        masonryInfillDamageRisk:
            'LOW: Most NCR high-rises use RC frames with brick infill',
        ndmaDos: [
          'Stay calm; minor tremors are common in seismic zone IV',
          'Review family earthquake preparedness plan',
          'Keep heavy objects secured on lower shelves',
        ],
        ndmaDonts: [
          'Do not panic over minor tremors — Delhi NCR is in Zone IV',
          'Do not rush to staircases en masse during shaking',
          'Do not spread unverified earthquake prediction messages',
        ],
      ),
      vernacularAlerts: {
        'en':
            'NCS BULLETIN: M4.2 minor earthquake felt in Delhi-NCR region. No damage reported. Stay calm — minor tremors are normal for BIS Seismic Zone IV.',
        'hi':
            'एनसीएस बुलेटिन: दिल्ली-एनसीआर में 4.2 तीव्रता का हल्का भूकंप अनुभव किया गया। कोई क्षति नहीं। शांत रहें — यह BIS भूकंपीय जोन IV में सामान्य है।',
      },
    );

    const nwHimalaya = SeismotectonicProvinceModel(
      provinceId: 'nw_himalaya_jk_hp',
      provinceName: 'NW Himalaya — Kashmir & Kangra Seismic Gap',
      state: 'Jammu & Kashmir / Himachal Pradesh',
      dominantFaultSystem:
          'Main Boundary Thrust (MBT) & Main Central Thrust (MCT)',
      latitude: 33.7782,
      longitude: 75.3412,
      alertTier: 'ORANGE_DAMAGING',
      sourceParameters: EarthquakeSourceParametersModel(
        momentMagnitudeMw: 6.2,
        localMagnitudeMl: 6.0,
        focalDepthKm: 12.5,
        epicenterLatitude: 33.45,
        epicenterLongitude: 75.10,
        originTimeUtc: '2026-09-12T04:15:22Z',
        faultMechanism: 'REVERSE_THRUST',
        faultPlaneStrikeDeg: 310.0,
        ruptureLengthKm: 28.0,
      ),
      mmiAssessment: ModifiedMercalliIntensityModel(
        epicentralMmi: 'VIII',
        feltRadiusKm: 380.0,
        perceivedShaking: 'Severe to Violent',
        potentialDamage:
            'Moderate to heavy structural damage in older masonry buildings',
        didYouFeelItReports: 14200,
      ),
      aftershockOutlook: AftershockProbabilityModel(
        bathLawLargestAftershockMw: 5.0,
        modifiedOmoriPValue: 1.08,
        reasenbergJones24hProbabilityPct: 42.0,
        expectedAftershocks7Day: 85,
        coulombStressTransferDirection:
            'SE along MBT toward Dharamsala-Kangra segment',
      ),
      structuralDirectives: StructuralVulnerabilityDirectivesModel(
        bisSeismicZone: 'ZONE_V',
        designPgaG: 0.36,
        buildingVulnerabilityClass:
            'A (Highest - Pre-1993 Stone/Mud Masonry)',
        postQuakeInspectionPriority: 'Immediate',
        softStoryCollapseRisk:
            'CRITICAL: Multi-story stilt parking buildings vulnerable',
        masonryInfillDamageRisk:
            'HIGH: URM stone walls at severe failure risk',
        ndmaDos: [
          'DROP-COVER-HOLD under sturdy furniture until shaking stops',
          'Move to open ground if already outside',
          'Keep emergency torch and first aid kit accessible',
        ],
        ndmaDonts: [
          'DO NOT run outside during active shaking',
          'DO NOT use elevators during or after an earthquake',
          'DO NOT re-enter visibly damaged buildings',
        ],
      ),
      vernacularAlerts: {
        'en':
            'NCS/IMD EARTHQUAKE ALERT: M6.2 earthquake near Udhampur, J&K. Severe shaking (MMI VIII). Drop-Cover-Hold.',
        'hi':
            'NCS/IMD भूकंप चेतावनी: उधमपुर, J&K में 6.2 तीव्रता का भूकंप। तीव्र कंपन (MMI VIII)।',
      },
    );

    return const EarthquakeResponseModel(
      timestamp: '2026-09-12T06:30:00Z',
      bulletinNumber: 'NCS/IMD-SEIS/20260912-DELHI',
      provenance:
          'National Centre for Seismology (NCS/IMD) & National Disaster Management Authority (NDMA)',
      nationalSeismicitySynopsis:
          'MODERATE: Active seismicity monitored across Indian tectonic provinces',
      selectedProvince: delhiProvince,
      allProvinces: [delhiProvince, nwHimalaya],
      seismologicalModel:
          'Gutenberg-Richter b-value ~ 0.9; Båth\'s Law Δm ≈ 1.2; IS:1893-2016 BIS Seismic Zonation',
      vernacularBulletins: {
        'en':
            'NCS BULLETIN: M4.2 minor earthquake felt in Delhi-NCR region. No damage reported. Stay calm.',
        'hi':
            'एनसीएस बुलेटिन: दिल्ली-एनसीआर में 4.2 तीव्रता का हल्का भूकंप।',
      },
      isOfflineCached: true,
    );
  }
}
