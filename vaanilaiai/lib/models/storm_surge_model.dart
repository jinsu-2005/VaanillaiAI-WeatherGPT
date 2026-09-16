class CyclonicForcingParametersModel {
  final String cycloneName;
  final String imdClassification;
  final double sustainedWindSpeedKmh;
  final double centralPressureHpa;
  final double forwardSpeedKmh;
  final String landfallPoint;
  final double distanceToLandfallKm;

  const CyclonicForcingParametersModel({
    required this.cycloneName,
    required this.imdClassification,
    required this.sustainedWindSpeedKmh,
    required this.centralPressureHpa,
    required this.forwardSpeedKmh,
    required this.landfallPoint,
    required this.distanceToLandfallKm,
  });

  factory CyclonicForcingParametersModel.fromJson(Map<String, dynamic> json) {
    return CyclonicForcingParametersModel(
      cycloneName: json['cyclone_name'] as String? ?? 'Cyclonic System',
      imdClassification: json['imd_classification'] as String? ?? 'Severe Cyclonic Storm',
      sustainedWindSpeedKmh: (json['sustained_wind_speed_kmh'] as num?)?.toDouble() ?? 100.0,
      centralPressureHpa: (json['central_pressure_hpa'] as num?)?.toDouble() ?? 985.0,
      forwardSpeedKmh: (json['forward_speed_kmh'] as num?)?.toDouble() ?? 15.0,
      landfallPoint: json['landfall_point'] as String? ?? 'Coastline',
      distanceToLandfallKm: (json['distance_to_landfall_km'] as num?)?.toDouble() ?? 50.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'cyclone_name': cycloneName,
        'imd_classification': imdClassification,
        'sustained_wind_speed_kmh': sustainedWindSpeedKmh,
        'central_pressure_hpa': centralPressureHpa,
        'forward_speed_kmh': forwardSpeedKmh,
        'landfall_point': landfallPoint,
        'distance_to_landfall_km': distanceToLandfallKm,
      };
}

class HydrodynamicComponentsModel {
  final double astronomicalTideM;
  final double stormSurgePeakM;
  final double waveSetupM;
  final double totalWaterLevelM;
  final double coastalEmbankmentCrestM;
  final double overtoppingDepthM;
  final double freeboardMarginM;
  final String peakSurgeWindowUtc;

  const HydrodynamicComponentsModel({
    required this.astronomicalTideM,
    required this.stormSurgePeakM,
    required this.waveSetupM,
    required this.totalWaterLevelM,
    required this.coastalEmbankmentCrestM,
    required this.overtoppingDepthM,
    required this.freeboardMarginM,
    required this.peakSurgeWindowUtc,
  });

  factory HydrodynamicComponentsModel.fromJson(Map<String, dynamic> json) {
    return HydrodynamicComponentsModel(
      astronomicalTideM: (json['astronomical_tide_m'] as num?)?.toDouble() ?? 3.5,
      stormSurgePeakM: (json['storm_surge_peak_m'] as num?)?.toDouble() ?? 2.0,
      waveSetupM: (json['wave_setup_m'] as num?)?.toDouble() ?? 0.6,
      totalWaterLevelM: (json['total_water_level_m'] as num?)?.toDouble() ?? 6.1,
      coastalEmbankmentCrestM: (json['coastal_embankment_crest_m'] as num?)?.toDouble() ?? 5.8,
      overtoppingDepthM: (json['overtopping_depth_m'] as num?)?.toDouble() ?? 0.3,
      freeboardMarginM: (json['freeboard_margin_m'] as num?)?.toDouble() ?? -0.3,
      peakSurgeWindowUtc: json['peak_surge_window_utc'] as String? ?? 'Window pending',
    );
  }

  Map<String, dynamic> toJson() => {
        'astronomical_tide_m': astronomicalTideM,
        'storm_surge_peak_m': stormSurgePeakM,
        'wave_setup_m': waveSetupM,
        'total_water_level_m': totalWaterLevelM,
        'coastal_embankment_crest_m': coastalEmbankmentCrestM,
        'overtopping_depth_m': overtoppingDepthM,
        'freeboard_margin_m': freeboardMarginM,
        'peak_surge_window_utc': peakSurgeWindowUtc,
      };
}

class TidalBoreMetricsModel {
  final bool borePhenomenonActive;
  final double boreHeightM;
  final double borePropagationSpeedKmh;
  final double upstreamPenetrationKm;
  final String riverBasinName;
  final String boreSafetyAdvisory;

  const TidalBoreMetricsModel({
    required this.borePhenomenonActive,
    required this.boreHeightM,
    required this.borePropagationSpeedKmh,
    required this.upstreamPenetrationKm,
    required this.riverBasinName,
    required this.boreSafetyAdvisory,
  });

  factory TidalBoreMetricsModel.fromJson(Map<String, dynamic> json) {
    return TidalBoreMetricsModel(
      borePhenomenonActive: json['bore_phenomenon_active'] as bool? ?? false,
      boreHeightM: (json['bore_height_m'] as num?)?.toDouble() ?? 0.0,
      borePropagationSpeedKmh: (json['bore_propagation_speed_kmh'] as num?)?.toDouble() ?? 0.0,
      upstreamPenetrationKm: (json['upstream_penetration_km'] as num?)?.toDouble() ?? 0.0,
      riverBasinName: json['river_basin_name'] as String? ?? 'Estuary',
      boreSafetyAdvisory: json['bore_safety_advisory'] as String? ?? 'Normal estuarine conditions',
    );
  }

  Map<String, dynamic> toJson() => {
        'bore_phenomenon_active': borePhenomenonActive,
        'bore_height_m': boreHeightM,
        'bore_propagation_speed_kmh': borePropagationSpeedKmh,
        'upstream_penetration_km': upstreamPenetrationKm,
        'river_basin_name': riverBasinName,
        'bore_safety_advisory': boreSafetyAdvisory,
      };
}

class SalineInundationMetricsModel {
  final double maxInlandIntrusionKm;
  final double estimatedInundatedAreaSqKm;
  final double surgeWaterSalinityPpt;
  final int embankmentBreachesReported;
  final String paddyAquacultureContaminationRisk;

  const SalineInundationMetricsModel({
    required this.maxInlandIntrusionKm,
    required this.estimatedInundatedAreaSqKm,
    required this.surgeWaterSalinityPpt,
    required this.embankmentBreachesReported,
    required this.paddyAquacultureContaminationRisk,
  });

  factory SalineInundationMetricsModel.fromJson(Map<String, dynamic> json) {
    return SalineInundationMetricsModel(
      maxInlandIntrusionKm: (json['max_inland_intrusion_km'] as num?)?.toDouble() ?? 2.0,
      estimatedInundatedAreaSqKm: (json['estimated_inundated_area_sq_km'] as num?)?.toDouble() ?? 30.0,
      surgeWaterSalinityPpt: (json['surge_water_salinity_ppt'] as num?)?.toDouble() ?? 25.0,
      embankmentBreachesReported: (json['embankment_breaches_reported'] as num?)?.toInt() ?? 0,
      paddyAquacultureContaminationRisk: json['paddy_aquaculture_contamination_risk'] as String? ?? 'HIGH',
    );
  }

  Map<String, dynamic> toJson() => {
        'max_inland_intrusion_km': maxInlandIntrusionKm,
        'estimated_inundated_area_sq_km': estimatedInundatedAreaSqKm,
        'surge_water_salinity_ppt': surgeWaterSalinityPpt,
        'embankment_breaches_reported': embankmentBreachesReported,
        'paddy_aquaculture_contamination_risk': paddyAquacultureContaminationRisk,
      };
}

class CoastalInfrastructureDirectivesModel {
  final String sluiceGateAction;
  final String stormSurgeBarrierStatus;
  final String cycloneShelterMobilization;
  final String marineCraftHarborDirective;
  final String drinkingWaterWellSealingOrder;
  final List<String> designatedShelters;

  const CoastalInfrastructureDirectivesModel({
    required this.sluiceGateAction,
    required this.stormSurgeBarrierStatus,
    required this.cycloneShelterMobilization,
    required this.marineCraftHarborDirective,
    required this.drinkingWaterWellSealingOrder,
    required this.designatedShelters,
  });

  factory CoastalInfrastructureDirectivesModel.fromJson(Map<String, dynamic> json) {
    return CoastalInfrastructureDirectivesModel(
      sluiceGateAction: json['sluice_gate_action'] as String? ?? 'LOCKED_SHUT_BACKFLOW_PREVENTION',
      stormSurgeBarrierStatus: json['storm_surge_barrier_status'] as String? ?? 'Operational',
      cycloneShelterMobilization: json['cyclone_shelter_mobilization'] as String? ?? 'Shelters prepared',
      marineCraftHarborDirective: json['marine_craft_harbor_directive'] as String? ?? 'Boats secured',
      drinkingWaterWellSealingOrder: json['drinking_water_well_sealing_order'] as String? ?? 'Protect potable sources',
      designatedShelters: (json['designated_shelters'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'sluice_gate_action': sluiceGateAction,
        'storm_surge_barrier_status': stormSurgeBarrierStatus,
        'cyclone_shelter_mobilization': cycloneShelterMobilization,
        'marine_craft_harbor_directive': marineCraftHarborDirective,
        'drinking_water_well_sealing_order': drinkingWaterWellSealingOrder,
        'designated_shelters': designatedShelters,
      };
}

class EstuarySurgeSectorModel {
  final String sectorId;
  final String sectorName;
  final String state;
  final String waterBody;
  final double latitude;
  final double longitude;
  final String threatTier;
  final String tidalPhase;
  final CyclonicForcingParametersModel cyclonicForcing;
  final HydrodynamicComponentsModel hydrodynamics;
  final TidalBoreMetricsModel tidalBore;
  final SalineInundationMetricsModel inundation;
  final CoastalInfrastructureDirectivesModel directives;
  final Map<String, String> vernacularBulletins;

  const EstuarySurgeSectorModel({
    required this.sectorId,
    required this.sectorName,
    required this.state,
    required this.waterBody,
    required this.latitude,
    required this.longitude,
    required this.threatTier,
    required this.tidalPhase,
    required this.cyclonicForcing,
    required this.hydrodynamics,
    required this.tidalBore,
    required this.inundation,
    required this.directives,
    required this.vernacularBulletins,
  });

  factory EstuarySurgeSectorModel.fromJson(Map<String, dynamic> json) {
    return EstuarySurgeSectorModel(
      sectorId: json['sector_id'] as String? ?? 'sundarbans_wb',
      sectorName: json['sector_name'] as String? ?? 'Sundarbans Delta',
      state: json['state'] as String? ?? 'West Bengal',
      waterBody: json['water_body'] as String? ?? 'Bay of Bengal',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 21.85,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 88.15,
      threatTier: json['threat_tier'] as String? ?? 'EMERGENCY_RED',
      tidalPhase: json['tidal_phase'] as String? ?? 'SPRING_HIGH_TIDE',
      cyclonicForcing: CyclonicForcingParametersModel.fromJson(
          json['cyclonic_forcing'] as Map<String, dynamic>? ?? {}),
      hydrodynamics: HydrodynamicComponentsModel.fromJson(
          json['hydrodynamics'] as Map<String, dynamic>? ?? {}),
      tidalBore: TidalBoreMetricsModel.fromJson(
          json['tidal_bore'] as Map<String, dynamic>? ?? {}),
      inundation: SalineInundationMetricsModel.fromJson(
          json['inundation'] as Map<String, dynamic>? ?? {}),
      directives: CoastalInfrastructureDirectivesModel.fromJson(
          json['directives'] as Map<String, dynamic>? ?? {}),
      vernacularBulletins: (json['vernacular_bulletins'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          const {},
    );
  }

  Map<String, dynamic> toJson() => {
        'sector_id': sectorId,
        'sector_name': sectorName,
        'state': state,
        'water_body': waterBody,
        'latitude': latitude,
        'longitude': longitude,
        'threat_tier': threatTier,
        'tidal_phase': tidalPhase,
        'cyclonic_forcing': cyclonicForcing.toJson(),
        'hydrodynamics': hydrodynamics.toJson(),
        'tidal_bore': tidalBore.toJson(),
        'inundation': inundation.toJson(),
        'directives': directives.toJson(),
        'vernacular_bulletins': vernacularBulletins,
      };
}

class StormSurgeResponseModel {
  final String timestamp;
  final String bulletinNumber;
  final String provenance;
  final String nationalCoastalThreatSummary;
  final EstuarySurgeSectorModel selectedSector;
  final List<EstuarySurgeSectorModel> allSectors;
  final String numericalModelCoupling;
  final Map<String, String> vernacularBulletins;
  final bool isOfflineCached;

  const StormSurgeResponseModel({
    required this.timestamp,
    required this.bulletinNumber,
    required this.provenance,
    required this.nationalCoastalThreatSummary,
    required this.selectedSector,
    required this.allSectors,
    required this.numericalModelCoupling,
    required this.vernacularBulletins,
    this.isOfflineCached = false,
  });

  factory StormSurgeResponseModel.fromJson(Map<String, dynamic> json) {
    return StormSurgeResponseModel(
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      bulletinNumber: json['bulletin_number'] as String? ?? 'INCOIS-IMD/SS-TIDE/OFFLINE',
      provenance: json['provenance'] as String? ??
          'INCOIS-IMD Joint Storm Surge Warning Centre (ADCIRC-SWAN Numerical Hydrodynamic Model)',
      nationalCoastalThreatSummary: json['national_coastal_threat_summary'] as String? ??
          'Indian Coastal Estuary & Tidal Surge Warning in effect',
      selectedSector: EstuarySurgeSectorModel.fromJson(
          json['selected_sector'] as Map<String, dynamic>? ?? {}),
      allSectors: (json['all_sectors'] as List<dynamic>?)
              ?.map((e) => EstuarySurgeSectorModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      numericalModelCoupling: json['numerical_model_coupling'] as String? ??
          'Coupled ADCIRC (Advanced Circulation 2DDI) + SWAN + FES2014 Global Tide',
      vernacularBulletins: (json['vernacular_bulletins'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          const {},
      isOfflineCached: json['is_offline_cached'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'bulletin_number': bulletinNumber,
        'provenance': provenance,
        'national_coastal_threat_summary': nationalCoastalThreatSummary,
        'selected_sector': selectedSector.toJson(),
        'all_sectors': allSectors.map((e) => e.toJson()).toList(),
        'numerical_model_coupling': numericalModelCoupling,
        'vernacular_bulletins': vernacularBulletins,
        'is_offline_cached': isOfflineCached,
      };

  factory StormSurgeResponseModel.defaultFallback() {
    const sundarbans = EstuarySurgeSectorModel(
      sectorId: 'sundarbans_wb',
      sectorName: 'Sundarbans Delta & Hooghly Estuary',
      state: 'West Bengal',
      waterBody: 'Northern Bay of Bengal - Hooghly River Estuary',
      latitude: 21.8500,
      longitude: 88.1500,
      threatTier: 'EMERGENCY_RED',
      tidalPhase: 'SPRING_HIGH_TIDE',
      cyclonicForcing: CyclonicForcingParametersModel(
        cycloneName: "Severe Cyclonic Storm 'Dana'",
        imdClassification: 'Very Severe Cyclonic Storm (VSCS)',
        sustainedWindSpeedKmh: 125.0,
        centralPressureHpa: 974.0,
        forwardSpeedKmh: 16.0,
        landfallPoint: 'Dhamra / Sagar Island Corridor',
        distanceToLandfallKm: 48.0,
      ),
      hydrodynamics: HydrodynamicComponentsModel(
        astronomicalTideM: 4.20,
        stormSurgePeakM: 2.65,
        waveSetupM: 0.75,
        totalWaterLevelM: 7.60,
        coastalEmbankmentCrestM: 6.20,
        overtoppingDepthM: 1.40,
        freeboardMarginM: -1.40,
        peakSurgeWindowUtc: '2026-09-12T13:00:00Z to 2026-09-12T17:30:00Z',
      ),
      tidalBore: TidalBoreMetricsModel(
        borePhenomenonActive: true,
        boreHeightM: 2.20,
        borePropagationSpeedKmh: 26.5,
        upstreamPenetrationKm: 58.0,
        riverBasinName: 'Hooghly & Muriganga Tidal River Reach',
        boreSafetyAdvisory:
            'Extreme bore wavefront traveling upstream against river current. Halt country boat ferries and fishing ghat operations.',
      ),
      inundation: SalineInundationMetricsModel(
        maxInlandIntrusionKm: 4.80,
        estimatedInundatedAreaSqKm: 128.5,
        surgeWaterSalinityPpt: 28.5,
        embankmentBreachesReported: 5,
        paddyAquacultureContaminationRisk: 'CRITICAL',
      ),
      directives: CoastalInfrastructureDirectivesModel(
        sluiceGateAction:
            'LOCKED_SHUT_BACKFLOW_PREVENTION: All 84 drainage sluices along Kakdwip, Gosaba, and Sagar Island locked to prevent high salinity river ingress into freshwater bheris and Aman paddy polders.',
        stormSurgeBarrierStatus:
            'Sundarbans Earthen Dykes Saturated: Geo-tube embankment reinforcement teams deployed at Patharpratima and Hingalganj breaches.',
        cycloneShelterMobilization:
            'Mandatory evacuation of low-lying island habitations within 2 km of river dykes to Multi-Purpose Cyclone Shelters (MPCS).',
        marineCraftHarborDirective:
            'Complete prohibition of mechanized trawlers in Kakdwip, Fraserganj, and Diamond Harbour. All crafts secured with double mooring warps.',
        drinkingWaterWellSealingOrder:
            'Raise deep tubewell discharge nozzles by 1.5m and seal handpump wellheads with plastic sleeves to avoid seawater aquifer contamination.',
        designatedShelters: [
          'Sagar Island Central MPCS',
          'Kakdwip Block II Cyclone Shelter',
          'Gosaba Pakhiralay Disaster Shelter',
          'Namkhana Narayanpur High School Shelter',
        ],
      ),
      vernacularBulletins: {
        'en':
            'EMERGENCY STORM SURGE WARNING: Sundarbans & Hooghly Estuary face catastrophic Total Water Level of 7.60m during Spring High Tide. Embankment overtopping by 1.4m underway. Immediate evacuation to cyclone shelters mandatory.',
        'hi':
            'आपातकालीन चक्रवाती तूफान लहर चेतावनी: सुंदरबन और हुगली मुहाने में स्प्रिंग हाई टाइड के दौरान 7.60 मीटर जलस्तर का अनुमान है। तटबंध 1.4 मीटर ऊपर से बह रहे हैं। तुरंत बहुउद्देशीय चक्रवात आश्रयों में जाएं।',
        'bn':
            'জরুরি ঘূর্ণিঝড় জলোচ্ছ্বাস সতর্কবার্তা: সুন্দরবন এবং হুগলি মোহনায় ভরা কোটালের কারণে মোট জলস্তর ৭.৬০ মিটারে পৌঁছানোর আশঙ্কা। নদীর বাঁধ উপচে ১.৪০ মিটার উচ্চতায় নোনা জল ঢুকছে। অবিলম্বে নিকটবর্তী সাইক্লোন শেল্টারে আশ্রয় নিন।',
      },
    );

    const paradeep = EstuarySurgeSectorModel(
      sectorId: 'paradeep_mahanadi_or',
      sectorName: 'Paradeep Port & Mahanadi Estuary',
      state: 'Odisha',
      waterBody: 'Bay of Bengal - Mahanadi River Mouth',
      latitude: 20.3167,
      longitude: 86.6111,
      threatTier: 'EMERGENCY_RED',
      tidalPhase: 'SPRING_HIGH_TIDE',
      cyclonicForcing: CyclonicForcingParametersModel(
        cycloneName: "Severe Cyclonic Storm 'Dana'",
        imdClassification: 'Very Severe Cyclonic Storm (VSCS)',
        sustainedWindSpeedKmh: 130.0,
        centralPressureHpa: 970.0,
        forwardSpeedKmh: 17.5,
        landfallPoint: 'Bhadrak / Kendrapara Coast',
        distanceToLandfallKm: 35.0,
      ),
      hydrodynamics: HydrodynamicComponentsModel(
        astronomicalTideM: 3.10,
        stormSurgePeakM: 2.85,
        waveSetupM: 0.85,
        totalWaterLevelM: 6.80,
        coastalEmbankmentCrestM: 5.90,
        overtoppingDepthM: 0.90,
        freeboardMarginM: -0.90,
        peakSurgeWindowUtc: '2026-09-12T14:00:00Z to 2026-09-12T19:00:00Z',
      ),
      tidalBore: TidalBoreMetricsModel(
        borePhenomenonActive: false,
        boreHeightM: 0.40,
        borePropagationSpeedKmh: 12.0,
        upstreamPenetrationKm: 14.0,
        riverBasinName: 'Mahanadi - Devi River Delta',
        boreSafetyAdvisory:
            'Moderate surge wave propagating up Mahanadi navigation channels. River mouth fishing craft restricted.',
      ),
      inundation: SalineInundationMetricsModel(
        maxInlandIntrusionKm: 5.20,
        estimatedInundatedAreaSqKm: 142.0,
        surgeWaterSalinityPpt: 29.2,
        embankmentBreachesReported: 4,
        paddyAquacultureContaminationRisk: 'CRITICAL',
      ),
      directives: CoastalInfrastructureDirectivesModel(
        sluiceGateAction:
            'LOCKED_SHUT_BACKFLOW_PREVENTION: Paradeep lock gates and Mahanadi canal headworks shut to prevent sea surge penetrating agricultural hinterlands of Jagatsinghpur and Kendrapara.',
        stormSurgeBarrierStatus:
            'Paradeep Port Breakwaters Overwashed: Gantry crane operations suspended, all berths cleared.',
        cycloneShelterMobilization:
            'State Disaster Rapid Action Force (ODRAF) executing 100% evacuation of villages within 3km of the coast.',
        marineCraftHarborDirective:
            'Deep-sea fishing trawlers locked in Mahanadi fishing harbor; no movement past outer anchorage.',
        drinkingWaterWellSealingOrder:
            'Rural Water Supply (RWSS) chlorinated water pouches positioned; seal tubewells against backwash.',
        designatedShelters: [
          'Paradeep Port MPCS Block A',
          'Ersama Cyclone Shelter',
          'Rajnagar Kendrapara Disaster Haven',
          'Kujang Community Cyclone Shelter',
        ],
      ),
      vernacularBulletins: {
        'en':
            'CRITICAL STORM SURGE BULLETIN: Paradeep & Mahanadi Estuary experiencing 6.80m Total Water Level. Severe dyke overtopping (0.90m) in Ersama and Rajnagar. Move immediately to ODRAF cyclone shelters.',
        'hi':
            'गंभीर तूफान लहर चेतावनी: पारादीप और महानदी मुहाने पर कुल जल स्तर 6.80 मीटर पार कर चुका है। 0.90 मीटर ऊंचे ज्वार से तटबंध टूटने का खतरा है। तुरंत निकटतम चक्रवात केंद्र में शरण लें।',
        'or':
            'ଜରୁରୀକାଳୀନ ବାତ୍ୟା ଜୁଆର ଚେତାବନୀ: ପାରାଦ୍ୱୀପ ଏବଂ ମହାନଦୀ ମୁହାଣରେ ସମୁଦ୍ର ଜଳସ୍ତର ୬.୮୦ ମିଟରକୁ ବୃଦ୍ଧି ପାଇଛି। ଏରସମା ଓ ରାଜନଗର ଅଞ୍ଚଳରେ ଲୁଣା ବନ୍ଧ ଡେଇଁ ପାଣି ପ୍ରବେଶ କରୁଛି। ତୁରନ୍ତ ବାତ୍ୟା ଆଶ୍ରୟସ୍ଥଳୀକୁ ଯାଆନ୍ତୁ।',
      },
    );

    return StormSurgeResponseModel(
      timestamp: '2026-09-12T05:00:00Z',
      bulletinNumber: 'INCOIS-IMD/SS-TIDE/202609-SUNDAR',
      provenance:
          'INCOIS-IMD Joint Storm Surge Warning Centre (ADCIRC-SWAN Numerical Hydrodynamic Model)',
      nationalCoastalThreatSummary:
          'CRITICAL: Coastal Embankment Overtopping & Catastrophic Saline Inundation (Red Alert)',
      selectedSector: sundarbans,
      allSectors: const [sundarbans, paradeep],
      numericalModelCoupling:
          'Coupled ADCIRC (Advanced Circulation 2DDI) + SWAN (Simulating Waves Nearshore) + FES2014 Global Tide',
      vernacularBulletins: sundarbans.vernacularBulletins,
      isOfflineCached: true,
    );
  }
}
