class OceanColorTelemetryModel {
  final double chlorophyllAMgM3;
  final String productivityTier;
  final double diffuseAttenuationK490;
  final bool phytoplanktonBloomActive;
  final bool harmfulAlgalBloomRisk;

  const OceanColorTelemetryModel({
    required this.chlorophyllAMgM3,
    required this.productivityTier,
    required this.diffuseAttenuationK490,
    required this.phytoplanktonBloomActive,
    required this.harmfulAlgalBloomRisk,
  });

  factory OceanColorTelemetryModel.fromJson(Map<String, dynamic> json) {
    return OceanColorTelemetryModel(
      chlorophyllAMgM3:
          (json['chlorophyll_a_mg_m3'] as num?)?.toDouble() ?? 1.85,
      productivityTier:
          json['productivity_tier'] as String? ?? 'OPTIMAL_HIGH_YIELD',
      diffuseAttenuationK490:
          (json['diffuse_attenuation_k490'] as num?)?.toDouble() ?? 0.14,
      phytoplanktonBloomActive:
          json['phytoplankton_bloom_active'] as bool? ?? true,
      harmfulAlgalBloomRisk:
          json['harmful_algal_bloom_risk'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'chlorophyll_a_mg_m3': chlorophyllAMgM3,
        'productivity_tier': productivityTier,
        'diffuse_attenuation_k490': diffuseAttenuationK490,
        'phytoplankton_bloom_active': phytoplanktonBloomActive,
        'harmful_algal_bloom_risk': harmfulAlgalBloomRisk,
      };
}

class ThermalFrontTelemetryModel {
  final double seaSurfaceTempCelsius;
  final double sstGradientDegCPerKm;
  final String thermalFrontType;
  final String mesoscaleEddyType;
  final double seaSurfaceHeightAnomalyCm;

  const ThermalFrontTelemetryModel({
    required this.seaSurfaceTempCelsius,
    required this.sstGradientDegCPerKm,
    required this.thermalFrontType,
    required this.mesoscaleEddyType,
    required this.seaSurfaceHeightAnomalyCm,
  });

  factory ThermalFrontTelemetryModel.fromJson(Map<String, dynamic> json) {
    return ThermalFrontTelemetryModel(
      seaSurfaceTempCelsius:
          (json['sea_surface_temp_celsius'] as num?)?.toDouble() ?? 28.4,
      sstGradientDegCPerKm:
          (json['sst_gradient_deg_c_per_km'] as num?)?.toDouble() ?? 0.65,
      thermalFrontType:
          json['thermal_front_type'] as String? ?? 'COASTAL_UPWELLING_FRONT',
      mesoscaleEddyType: json['mesoscale_eddy_type'] as String? ??
          'CYCLONIC_COLD_CORE_UPWELLING',
      seaSurfaceHeightAnomalyCm:
          (json['sea_surface_height_anomaly_cm'] as num?)?.toDouble() ?? -6.2,
    );
  }

  Map<String, dynamic> toJson() => {
        'sea_surface_temp_celsius': seaSurfaceTempCelsius,
        'sst_gradient_deg_c_per_km': sstGradientDegCPerKm,
        'thermal_front_type': thermalFrontType,
        'mesoscale_eddy_type': mesoscaleEddyType,
        'sea_surface_height_anomaly_cm': seaSurfaceHeightAnomalyCm,
      };
}

class NavigationalVectorModel {
  final String landingHarbourName;
  final int trueBearingDegrees;
  final String compassDirection;
  final double distanceNauticalMiles;
  final double distanceKilometers;
  final double centroidLatitude;
  final double centroidLongitude;
  final int targetDepthFathoms;
  final double targetDepthMeters;

  const NavigationalVectorModel({
    required this.landingHarbourName,
    required this.trueBearingDegrees,
    required this.compassDirection,
    required this.distanceNauticalMiles,
    required this.distanceKilometers,
    required this.centroidLatitude,
    required this.centroidLongitude,
    required this.targetDepthFathoms,
    required this.targetDepthMeters,
  });

  factory NavigationalVectorModel.fromJson(Map<String, dynamic> json) {
    return NavigationalVectorModel(
      landingHarbourName: json['landing_harbour_name'] as String? ??
          'Thoppumpady / Munambam Fishing Harbour',
      trueBearingDegrees: json['true_bearing_degrees'] as int? ?? 235,
      compassDirection: json['compass_direction'] as String? ?? 'SW',
      distanceNauticalMiles:
          (json['distance_nautical_miles'] as num?)?.toDouble() ?? 25.0,
      distanceKilometers:
          (json['distance_kilometers'] as num?)?.toDouble() ?? 46.3,
      centroidLatitude:
          (json['centroid_latitude'] as num?)?.toDouble() ?? 9.78,
      centroidLongitude:
          (json['centroid_longitude'] as num?)?.toDouble() ?? 75.82,
      targetDepthFathoms: json['target_depth_fathoms'] as int? ?? 28,
      targetDepthMeters:
          (json['target_depth_meters'] as num?)?.toDouble() ?? 51.2,
    );
  }

  Map<String, dynamic> toJson() => {
        'landing_harbour_name': landingHarbourName,
        'true_bearing_degrees': trueBearingDegrees,
        'compass_direction': compassDirection,
        'distance_nautical_miles': distanceNauticalMiles,
        'distance_kilometers': distanceKilometers,
        'centroid_latitude': centroidLatitude,
        'centroid_longitude': centroidLongitude,
        'target_depth_fathoms': targetDepthFathoms,
        'target_depth_meters': targetDepthMeters,
      };
}

class EconomicFuelSavingsModel {
  final String craftType;
  final double scoutingTimeReductionPct;
  final double dieselSavedLiters;
  final double rupeeFuelCostSavingsInr;
  final double carbonEmissionReductionKgCo2;

  const EconomicFuelSavingsModel({
    required this.craftType,
    required this.scoutingTimeReductionPct,
    required this.dieselSavedLiters,
    required this.rupeeFuelCostSavingsInr,
    required this.carbonEmissionReductionKgCo2,
  });

  factory EconomicFuelSavingsModel.fromJson(Map<String, dynamic> json) {
    return EconomicFuelSavingsModel(
      craftType:
          json['craft_type'] as String? ?? 'TRADITIONAL_MOTORIZED_FRP',
      scoutingTimeReductionPct:
          (json['scouting_time_reduction_pct'] as num?)?.toDouble() ?? 45.0,
      dieselSavedLiters:
          (json['diesel_saved_liters'] as num?)?.toDouble() ?? 35.0,
      rupeeFuelCostSavingsInr:
          (json['rupee_fuel_cost_savings_inr'] as num?)?.toDouble() ?? 3150.0,
      carbonEmissionReductionKgCo2:
          (json['carbon_emission_reduction_kg_co2'] as num?)?.toDouble() ??
              93.8,
    );
  }

  Map<String, dynamic> toJson() => {
        'craft_type': craftType,
        'scouting_time_reduction_pct': scoutingTimeReductionPct,
        'diesel_saved_liters': dieselSavedLiters,
        'rupee_fuel_cost_savings_inr': rupeeFuelCostSavingsInr,
        'carbon_emission_reduction_kg_co2': carbonEmissionReductionKgCo2,
      };
}

class EcologicalConservationBoundaryModel {
  final String nearestMpaName;
  final double distanceToMpaBoundaryKm;
  final String mpaBufferViolationRisk;
  final String minimumLegalSizeAdvisory;
  final String artisanalExclusiveZoneStatus;

  const EcologicalConservationBoundaryModel({
    required this.nearestMpaName,
    required this.distanceToMpaBoundaryKm,
    required this.mpaBufferViolationRisk,
    required this.minimumLegalSizeAdvisory,
    required this.artisanalExclusiveZoneStatus,
  });

  factory EcologicalConservationBoundaryModel.fromJson(
      Map<String, dynamic> json) {
    return EcologicalConservationBoundaryModel(
      nearestMpaName: json['nearest_mpa_name'] as String? ??
          'Vembanad Estuarine Wetland Buffer',
      distanceToMpaBoundaryKm:
          (json['distance_to_mpa_boundary_km'] as num?)?.toDouble() ?? 18.5,
      mpaBufferViolationRisk:
          json['mpa_buffer_violation_risk'] as String? ?? 'SAFE_OUTSIDE_BUFFER',
      minimumLegalSizeAdvisory: json['minimum_legal_size_advisory']
              as String? ??
          'Oil Sardine MLS >= 10 cm, Indian Mackerel MLS >= 14 cm',
      artisanalExclusiveZoneStatus:
          json['artisanal_exclusive_zone_status'] as String? ??
              '0-10 km Coastal Zone Reserved Exclusively for Traditional Motorized Crafts',
    );
  }

  Map<String, dynamic> toJson() => {
        'nearest_mpa_name': nearestMpaName,
        'distance_to_mpa_boundary_km': distanceToMpaBoundaryKm,
        'mpa_buffer_violation_risk': mpaBufferViolationRisk,
        'minimum_legal_size_advisory': minimumLegalSizeAdvisory,
        'artisanal_exclusive_zone_status': artisanalExclusiveZoneStatus,
      };
}

class PfzSectorModel {
  final String sectorId;
  final String sectorName;
  final String state;
  final String coastalSea;
  final String primarySpecies;
  final OceanColorTelemetryModel oceanColor;
  final ThermalFrontTelemetryModel thermalFront;
  final NavigationalVectorModel navigationalVector;
  final EconomicFuelSavingsModel fuelSavings;
  final EcologicalConservationBoundaryModel conservation;
  final Map<String, String> vernacularBulletins;

  const PfzSectorModel({
    required this.sectorId,
    required this.sectorName,
    required this.state,
    required this.coastalSea,
    required this.primarySpecies,
    required this.oceanColor,
    required this.thermalFront,
    required this.navigationalVector,
    required this.fuelSavings,
    required this.conservation,
    required this.vernacularBulletins,
  });

  factory PfzSectorModel.fromJson(Map<String, dynamic> json) {
    return PfzSectorModel(
      sectorId: json['sector_id'] as String? ?? 'kochi_malabar',
      sectorName: json['sector_name'] as String? ??
          'Kochi & Munambam FLC (Malabar Coast)',
      state: json['state'] as String? ?? 'Kerala',
      coastalSea: json['coastal_sea'] as String? ?? 'Southeastern Arabian Sea',
      primarySpecies: json['primary_species'] as String? ??
          'SMALL_PELAGICS_SARDINE_MACKEREL',
      oceanColor: json['ocean_color'] != null
          ? OceanColorTelemetryModel.fromJson(
              json['ocean_color'] as Map<String, dynamic>)
          : const OceanColorTelemetryModel(
              chlorophyllAMgM3: 1.85,
              productivityTier: 'OPTIMAL_HIGH_YIELD',
              diffuseAttenuationK490: 0.14,
              phytoplanktonBloomActive: true,
              harmfulAlgalBloomRisk: false,
            ),
      thermalFront: json['thermal_front'] != null
          ? ThermalFrontTelemetryModel.fromJson(
              json['thermal_front'] as Map<String, dynamic>)
          : const ThermalFrontTelemetryModel(
              seaSurfaceTempCelsius: 28.4,
              sstGradientDegCPerKm: 0.65,
              thermalFrontType: 'COASTAL_UPWELLING_FRONT',
              mesoscaleEddyType: 'CYCLONIC_COLD_CORE_UPWELLING',
              seaSurfaceHeightAnomalyCm: -6.2,
            ),
      navigationalVector: json['navigational_vector'] != null
          ? NavigationalVectorModel.fromJson(
              json['navigational_vector'] as Map<String, dynamic>)
          : const NavigationalVectorModel(
              landingHarbourName: 'Thoppumpady / Munambam Fishing Harbour',
              trueBearingDegrees: 235,
              compassDirection: 'SW',
              distanceNauticalMiles: 25.0,
              distanceKilometers: 46.3,
              centroidLatitude: 9.78,
              centroidLongitude: 75.82,
              targetDepthFathoms: 28,
              targetDepthMeters: 51.2,
            ),
      fuelSavings: json['fuel_savings'] != null
          ? EconomicFuelSavingsModel.fromJson(
              json['fuel_savings'] as Map<String, dynamic>)
          : const EconomicFuelSavingsModel(
              craftType: 'TRADITIONAL_MOTORIZED_FRP',
              scoutingTimeReductionPct: 45.0,
              dieselSavedLiters: 35.0,
              rupeeFuelCostSavingsInr: 3150.0,
              carbonEmissionReductionKgCo2: 93.8,
            ),
      conservation: json['conservation'] != null
          ? EcologicalConservationBoundaryModel.fromJson(
              json['conservation'] as Map<String, dynamic>)
          : const EcologicalConservationBoundaryModel(
              nearestMpaName: 'Vembanad Estuarine Wetland Buffer',
              distanceToMpaBoundaryKm: 18.5,
              mpaBufferViolationRisk: 'SAFE_OUTSIDE_BUFFER',
              minimumLegalSizeAdvisory:
                  'Oil Sardine MLS >= 10 cm, Indian Mackerel MLS >= 14 cm',
              artisanalExclusiveZoneStatus:
                  '0-10 km Coastal Zone Reserved Exclusively for Traditional Motorized Crafts',
            ),
      vernacularBulletins: (json['vernacular_bulletins'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v.toString())) ??
          {},
    );
  }

  Map<String, dynamic> toJson() => {
        'sector_id': sectorId,
        'sector_name': sectorName,
        'state': state,
        'coastal_sea': coastalSea,
        'primary_species': primarySpecies,
        'ocean_color': oceanColor.toJson(),
        'thermal_front': thermalFront.toJson(),
        'navigational_vector': navigationalVector.toJson(),
        'fuel_savings': fuelSavings.toJson(),
        'conservation': conservation.toJson(),
        'vernacular_bulletins': vernacularBulletins,
      };
}

class SectorSummaryModel {
  final String sectorId;
  final String sectorName;
  final String state;
  final String productivityTier;
  final String primarySpecies;
  final String compassDirection;
  final double distanceNm;

  const SectorSummaryModel({
    required this.sectorId,
    required this.sectorName,
    required this.state,
    required this.productivityTier,
    required this.primarySpecies,
    required this.compassDirection,
    required this.distanceNm,
  });

  factory SectorSummaryModel.fromJson(Map<String, dynamic> json) {
    return SectorSummaryModel(
      sectorId: json['sector_id'] as String? ?? 'kochi_malabar',
      sectorName: json['sector_name'] as String? ?? 'Kochi & Munambam',
      state: json['state'] as String? ?? 'Kerala',
      productivityTier:
          json['productivity_tier'] as String? ?? 'OPTIMAL_HIGH_YIELD',
      primarySpecies: json['primary_species'] as String? ??
          'SMALL_PELAGICS_SARDINE_MACKEREL',
      compassDirection: json['compass_direction'] as String? ?? 'SW',
      distanceNm: (json['distance_nm'] as num?)?.toDouble() ?? 25.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'sector_id': sectorId,
        'sector_name': sectorName,
        'state': state,
        'productivity_tier': productivityTier,
        'primary_species': primarySpecies,
        'compass_direction': compassDirection,
        'distance_nm': distanceNm,
      };
}

class PfzResponseModel {
  final String sectorId;
  final String sectorName;
  final String state;
  final PfzSectorModel currentSector;
  final List<SectorSummaryModel> allSectors;
  final String lastUpdatedUtc;
  final String dataSource;

  const PfzResponseModel({
    required this.sectorId,
    required this.sectorName,
    required this.state,
    required this.currentSector,
    required this.allSectors,
    required this.lastUpdatedUtc,
    required this.dataSource,
  });

  factory PfzResponseModel.fromJson(Map<String, dynamic> json) {
    return PfzResponseModel(
      sectorId: json['sector_id'] as String? ?? 'kochi_malabar',
      sectorName: json['sector_name'] as String? ?? 'Kochi & Munambam',
      state: json['state'] as String? ?? 'Kerala',
      currentSector: json['current_sector'] != null
          ? PfzSectorModel.fromJson(
              json['current_sector'] as Map<String, dynamic>)
          : PfzResponseModel.defaultFallback().currentSector,
      allSectors: (json['all_sectors'] as List<dynamic>?)
              ?.map((s) => SectorSummaryModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          PfzResponseModel.defaultFallback().allSectors,
      lastUpdatedUtc: json['last_updated_utc'] as String? ??
          DateTime.now().toUtc().toIso8601String(),
      dataSource: json['data_source'] as String? ??
          'INCOIS Oceansat-3 OCM / MODIS Ocean Color & CMFRI Pelagic Fishery Telemetry',
    );
  }

  Map<String, dynamic> toJson() => {
        'sector_id': sectorId,
        'sector_name': sectorName,
        'state': state,
        'current_sector': currentSector.toJson(),
        'all_sectors': allSectors.map((s) => s.toJson()).toList(),
        'last_updated_utc': lastUpdatedUtc,
        'data_source': dataSource,
      };

  factory PfzResponseModel.defaultFallback() {
    return PfzResponseModel(
      sectorId: 'kochi_malabar',
      sectorName: 'Kochi & Munambam FLC (Malabar Coast)',
      state: 'Kerala',
      currentSector: const PfzSectorModel(
        sectorId: 'kochi_malabar',
        sectorName: 'Kochi & Munambam FLC (Malabar Coast)',
        state: 'Kerala',
        coastalSea: 'Southeastern Arabian Sea',
        primarySpecies: 'SMALL_PELAGICS_SARDINE_MACKEREL',
        oceanColor: OceanColorTelemetryModel(
          chlorophyllAMgM3: 1.85,
          productivityTier: 'OPTIMAL_HIGH_YIELD',
          diffuseAttenuationK490: 0.14,
          phytoplanktonBloomActive: true,
          harmfulAlgalBloomRisk: false,
        ),
        thermalFront: ThermalFrontTelemetryModel(
          seaSurfaceTempCelsius: 28.4,
          sstGradientDegCPerKm: 0.65,
          thermalFrontType: 'COASTAL_UPWELLING_FRONT',
          mesoscaleEddyType: 'CYCLONIC_COLD_CORE_UPWELLING',
          seaSurfaceHeightAnomalyCm: -6.2,
        ),
        navigationalVector: NavigationalVectorModel(
          landingHarbourName: 'Thoppumpady / Munambam Fishing Harbour',
          trueBearingDegrees: 235,
          compassDirection: 'SW',
          distanceNauticalMiles: 25.0,
          distanceKilometers: 46.3,
          centroidLatitude: 9.78,
          centroidLongitude: 75.82,
          targetDepthFathoms: 28,
          targetDepthMeters: 51.2,
        ),
        fuelSavings: EconomicFuelSavingsModel(
          craftType: 'TRADITIONAL_MOTORIZED_FRP',
          scoutingTimeReductionPct: 45.0,
          dieselSavedLiters: 35.0,
          rupeeFuelCostSavingsInr: 3150.0,
          carbonEmissionReductionKgCo2: 93.8,
        ),
        conservation: EcologicalConservationBoundaryModel(
          nearestMpaName: 'Vembanad Estuarine Wetland Buffer',
          distanceToMpaBoundaryKm: 18.5,
          mpaBufferViolationRisk: 'SAFE_OUTSIDE_BUFFER',
          minimumLegalSizeAdvisory:
              'Oil Sardine MLS >= 10 cm, Indian Mackerel MLS >= 14 cm (CMFRI Gazetted)',
          artisanalExclusiveZoneStatus:
              '0-10 km Coastal Zone Reserved Exclusively for Traditional Motorized Crafts',
        ),
        vernacularBulletins: {
          'en':
              'INCOIS-CMFRI PFZ ADVISORY FOR KOCHI/MALABAR: High-yield pelagic zone active at 25.0 nm on bearing 235° SW (Depth 28 fathoms). SST thermal front 28.4°C with Chlorophyll-a 1.85 mg/m³ concentrating dense sardine and mackerel schools. Direct vectoring saves 45% scouting time and ~35L diesel per voyage for motorized craft. Bottom trawling strictly prohibited within 10 km artisanal coastal reserve.',
          'ml':
              'കൊച്ചി/മലബാർ തീരദേശ മത്സ്യബന്ധന മേഖല (INCOIS PFZ): തോപ്പുംപടിയിൽ നിന്ന് 235° തെക്ക്-പടിഞ്ഞാറ് (SW) ദിശയിൽ 25 നോട്ടിക്കൽ മൈൽ അകലെ 28 ഫാതം ആഴത്തിൽ മികച്ച ചാള, അയല മീൻകൂട്ടങ്ങൾ കണ്ടെത്തി. ഉപഗ്രഹ മാർഗ്ഗനിർദ്ദേശം വഴി 45% തിരച്ചിൽ സമയം ലാഭിക്കാം. 10 കി.മീ പരമ്പരാഗത മേഖലയിൽ ട്രോളിംഗ് കർശനമായി നിരോധിച്ചിരിക്കുന്നു.',
          'ta':
              'கொச்சி/மலபார் பகுதி மீன்பிடி மண்டல அறிவிப்பு (INCOIS PFZ): துறைமுகத்திலிருந்து 235° தென்மேற்கு திசையில் 25 கடல் மைல் தொலைவில் 28 பாகம் ஆழத்தில் மத்தி, கானாங்கெளுத்தி மீன்கள் அதிகளவில் உள்ளன. நேரடி வழிகாட்டல் மூலம் 45% டீசல் மிச்சமாகும்.',
          'te':
              'కొచ్చి/మలబార్ తీర మత్స్య సలహా (INCOIS PFZ): 235° నైరుతి దిశలో 25 నాటికల్ మైళ్ళ దూరంలో 28 ఫాతంల లోతులో చేపల లభ్యత ఎక్కువగా ఉంది. నేరుగా వెళ్లడం ద్వారా 45% డీజిల్ ఆదా అవుతుంది.',
          'gu':
              'કોચી મલબાર સંભવિત મત્સ્ય ઝોન: 235° દક્ષિણ-પશ્ચિમ દિશામાં 25 નોટિકલ માઈલ પર પ્રચુર માછલીઓ મળી આવી છે. 45% ઇંધણની બચત થશે.',
          'mr':
              'कोची मलबार संभाव्य मत्स्य क्षेत्र (PFZ): 235° नैऋत्य दिशेला 25 नॉटिकल मैल अंतरावर 28 फॅदम खोलीवर बांगडा व तारली माशांचे थवे आहेत. 45% डिझेल बचत होईल.',
          'bn':
              'কোচি মালাবার উপকূলীয় মৎস্য অঞ্চল: 235° দক্ষিণ-পশ্চিমে 25 নটিক্যাল মাইল দূরে প্রচুর সার্ডিন ও ম্যাকেরেল মাছ রয়েছে। 45% জ্বালানি সাশ্রয় হবে।',
          'od':
              'କୋଚି ମାଲାବାର ଉପକୂଳ ମତ୍ସ୍ୟ କ୍ଷେତ୍ର: 235° ଦକ୍ଷିଣ-ପଶ୍ଚିମରେ 25 ନଟିକାଲ୍ ମାଇଲ୍ ଦୂରତାରେ ପ୍ରଚୁର ମାଛ ମିଳିବାର ସମ୍ଭାବନା ଅଛି। 45% ଇନ୍ଧନ ବଞ୍ଚିବ।',
        },
      ),
      allSectors: const [
        SectorSummaryModel(
          sectorId: 'kochi_malabar',
          sectorName: 'Kochi & Munambam FLC',
          state: 'Kerala',
          productivityTier: 'OPTIMAL_HIGH_YIELD',
          primarySpecies: 'SMALL_PELAGICS_SARDINE_MACKEREL',
          compassDirection: 'SW',
          distanceNm: 25.0,
        ),
        SectorSummaryModel(
          sectorId: 'veraval_saurashtra',
          sectorName: 'Veraval & Porbandar',
          state: 'Gujarat',
          productivityTier: 'OPTIMAL_HIGH_YIELD',
          primarySpecies: 'ESTUARINE_PLUME_HILSA_POMFRET',
          compassDirection: 'WSW',
          distanceNm: 38.0,
        ),
        SectorSummaryModel(
          sectorId: 'sassoon_dock_konkan',
          sectorName: 'Sassoon Dock & Ratnagiri',
          state: 'Maharashtra',
          productivityTier: 'OPTIMAL_HIGH_YIELD',
          primarySpecies: 'SMALL_PELAGICS_SARDINE_MACKEREL',
          compassDirection: 'W',
          distanceNm: 28.0,
        ),
        SectorSummaryModel(
          sectorId: 'mangalore_malpe',
          sectorName: 'Mangalore & Malpe FLC',
          state: 'Karnataka',
          productivityTier: 'OPTIMAL_HIGH_YIELD',
          primarySpecies: 'SMALL_PELAGICS_SARDINE_MACKEREL',
          compassDirection: 'WNW',
          distanceNm: 22.0,
        ),
        SectorSummaryModel(
          sectorId: 'tuticorin_mannar',
          sectorName: 'Tuticorin & Pamban',
          state: 'Tamil Nadu',
          productivityTier: 'OPTIMAL_HIGH_YIELD',
          primarySpecies: 'LARGE_PELAGICS_TUNA_SEERFISH',
          compassDirection: 'SE',
          distanceNm: 20.0,
        ),
        SectorSummaryModel(
          sectorId: 'visakhapatnam_kakinada',
          sectorName: 'Visakhapatnam & Kakinada',
          state: 'Andhra Pradesh',
          productivityTier: 'OPTIMAL_HIGH_YIELD',
          primarySpecies: 'LARGE_PELAGICS_TUNA_SEERFISH',
          compassDirection: 'ESE',
          distanceNm: 32.0,
        ),
        SectorSummaryModel(
          sectorId: 'paradeep_gahirmatha',
          sectorName: 'Paradeep & Dhamra',
          state: 'Odisha',
          productivityTier: 'OPTIMAL_HIGH_YIELD',
          primarySpecies: 'ESTUARINE_PLUME_HILSA_POMFRET',
          compassDirection: 'E',
          distanceNm: 35.0,
        ),
      ],
      lastUpdatedUtc: '2026-09-12T12:00:00Z',
      dataSource:
          'INCOIS Oceansat-3 OCM / MODIS Ocean Color & CMFRI Pelagic Fishery Telemetry',
    );
  }
}
