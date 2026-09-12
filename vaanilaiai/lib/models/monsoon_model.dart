class SubDivisionalMonsoonModel {
  final String subDivisionCode;
  final String name;
  final String state;
  final double actualRainfallMm;
  final double normalRainfallMm;
  final double departurePercentage;
  final String departureCategory;
  final String departureColor;
  final double soilMoistureIndex;
  final String droughtRiskLevel;
  final bool isUserSubDivision;

  SubDivisionalMonsoonModel({
    required this.subDivisionCode,
    required this.name,
    required this.state,
    required this.actualRainfallMm,
    required this.normalRainfallMm,
    required this.departurePercentage,
    required this.departureCategory,
    this.departureColor = 'Green',
    this.soilMoistureIndex = 0.60,
    this.droughtRiskLevel = 'Normal',
    this.isUserSubDivision = false,
  });

  factory SubDivisionalMonsoonModel.fromJson(Map<String, dynamic> json) {
    return SubDivisionalMonsoonModel(
      subDivisionCode: json['sub_division_code'] ?? '',
      name: json['name'] ?? '',
      state: json['state'] ?? '',
      actualRainfallMm: (json['actual_rainfall_mm'] as num?)?.toDouble() ?? 0.0,
      normalRainfallMm: (json['normal_rainfall_mm'] as num?)?.toDouble() ?? 0.0,
      departurePercentage: (json['departure_percentage'] as num?)?.toDouble() ?? 0.0,
      departureCategory: json['departure_category'] ?? 'Normal',
      departureColor: json['departure_color'] ?? 'Green',
      soilMoistureIndex: (json['soil_moisture_index'] as num?)?.toDouble() ?? 0.60,
      droughtRiskLevel: json['drought_risk_level'] ?? 'Normal',
      isUserSubDivision: json['is_user_sub_division'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sub_division_code': subDivisionCode,
      'name': name,
      'state': state,
      'actual_rainfall_mm': actualRainfallMm,
      'normal_rainfall_mm': normalRainfallMm,
      'departure_percentage': departurePercentage,
      'departure_category': departureCategory,
      'departure_color': departureColor,
      'soil_moisture_index': soilMoistureIndex,
      'drought_risk_level': droughtRiskLevel,
      'is_user_sub_division': isUserSubDivision,
    };
  }
}

class OceanicTeleconnectionModel {
  final String indexCode;
  final String name;
  final double currentValue;
  final String unit;
  final String phase;
  final String impactOnMonsoon;
  final String mechanismSummary;

  OceanicTeleconnectionModel({
    required this.indexCode,
    required this.name,
    required this.currentValue,
    required this.unit,
    required this.phase,
    required this.impactOnMonsoon,
    required this.mechanismSummary,
  });

  factory OceanicTeleconnectionModel.fromJson(Map<String, dynamic> json) {
    return OceanicTeleconnectionModel(
      indexCode: json['index_code'] ?? '',
      name: json['name'] ?? '',
      currentValue: (json['current_value'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
      phase: json['phase'] ?? '',
      impactOnMonsoon: json['impact_on_monsoon'] ?? 'Neutral',
      mechanismSummary: json['mechanism_summary'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index_code': indexCode,
      'name': name,
      'current_value': currentValue,
      'unit': unit,
      'phase': phase,
      'impact_on_monsoon': impactOnMonsoon,
      'mechanism_summary': mechanismSummary,
    };
  }
}

class SeasonalForecastOutlookModel {
  final String seasonName;
  final String onsetStatus;
  final int probBelowNormalPct;
  final int probNormalPct;
  final int probAboveNormalPct;
  final String officialLrfVerdict;

  SeasonalForecastOutlookModel({
    required this.seasonName,
    required this.onsetStatus,
    required this.probBelowNormalPct,
    required this.probNormalPct,
    required this.probAboveNormalPct,
    required this.officialLrfVerdict,
  });

  factory SeasonalForecastOutlookModel.fromJson(Map<String, dynamic> json) {
    return SeasonalForecastOutlookModel(
      seasonName: json['season_name'] ?? 'Southwest Monsoon Season (June - September)',
      onsetStatus: json['onset_status'] ?? 'Active Monsoon',
      probBelowNormalPct: (json['prob_below_normal_pct'] as num?)?.toInt() ?? 20,
      probNormalPct: (json['prob_normal_pct'] as num?)?.toInt() ?? 50,
      probAboveNormalPct: (json['prob_above_normal_pct'] as num?)?.toInt() ?? 30,
      officialLrfVerdict: json['official_lrf_verdict'] ?? 'Normal Monsoon anticipated nationwide.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'season_name': seasonName,
      'onset_status': onsetStatus,
      'prob_below_normal_pct': probBelowNormalPct,
      'prob_normal_pct': probNormalPct,
      'prob_above_normal_pct': probAboveNormalPct,
      'official_lrf_verdict': officialLrfVerdict,
    };
  }
}

class MonsoonIntelligenceModel {
  final double latitude;
  final double longitude;
  final String locationName;
  final SubDivisionalMonsoonModel userSubDivision;
  final List<OceanicTeleconnectionModel> teleconnections;
  final SeasonalForecastOutlookModel seasonalOutlook;
  final List<SubDivisionalMonsoonModel> allSubDivisions;
  final List<String> adaptationDirectives;
  final Map<String, String> vernacularAdvisories;
  final String provenanceAuthority;
  final String lastUpdated;

  MonsoonIntelligenceModel({
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.userSubDivision,
    this.teleconnections = const [],
    required this.seasonalOutlook,
    this.allSubDivisions = const [],
    this.adaptationDirectives = const [],
    this.vernacularAdvisories = const {},
    this.provenanceAuthority = 'IMD Climate Services & NCMRWF Coupled Modeling',
    required this.lastUpdated,
  });

  factory MonsoonIntelligenceModel.fromJson(Map<String, dynamic> json) {
    var rawSubDivs = json['all_sub_divisions'] as List<dynamic>? ?? [];
    List<SubDivisionalMonsoonModel> subDivList =
        rawSubDivs.map((e) => SubDivisionalMonsoonModel.fromJson(e as Map<String, dynamic>)).toList();

    var rawTele = json['teleconnections'] as List<dynamic>? ?? [];
    List<OceanicTeleconnectionModel> teleList =
        rawTele.map((e) => OceanicTeleconnectionModel.fromJson(e as Map<String, dynamic>)).toList();

    Map<String, String> vernMap = {};
    if (json['vernacular_advisories'] is Map) {
      (json['vernacular_advisories'] as Map).forEach((k, v) {
        vernMap[k.toString()] = v.toString();
      });
    }

    SubDivisionalMonsoonModel userSub;
    if (json['user_sub_division'] != null) {
      userSub = SubDivisionalMonsoonModel.fromJson(json['user_sub_division'] as Map<String, dynamic>);
    } else if (subDivList.isNotEmpty) {
      userSub = subDivList.first;
    } else {
      userSub = SubDivisionalMonsoonModel(
        subDivisionCode: 'sd_31',
        name: 'Tamil Nadu, Puducherry & Karaikal',
        state: 'Tamil Nadu',
        actualRainfallMm: 510.0,
        normalRainfallMm: 440.0,
        departurePercentage: 15.9,
        departureCategory: 'Normal',
        departureColor: 'Green',
        soilMoistureIndex: 0.62,
        isUserSubDivision: true,
      );
    }

    return MonsoonIntelligenceModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      locationName: json['location_name'] ?? 'Location',
      userSubDivision: userSub,
      teleconnections: teleList,
      seasonalOutlook: json['seasonal_outlook'] != null
          ? SeasonalForecastOutlookModel.fromJson(json['seasonal_outlook'] as Map<String, dynamic>)
          : SeasonalForecastOutlookModel(
              seasonName: 'Southwest Monsoon Season (June - September)',
              onsetStatus: 'Active Pan-India Monsoon',
              probBelowNormalPct: 14,
              probNormalPct: 48,
              probAboveNormalPct: 38,
              officialLrfVerdict: 'Normal to Above-Normal Monsoon likely nationwide (106% LPA).',
            ),
      allSubDivisions: subDivList,
      adaptationDirectives: (json['adaptation_directives'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      vernacularAdvisories: vernMap,
      provenanceAuthority: json['provenance_authority'] ?? 'IMD Climate Services & NCMRWF Coupled Modeling',
      lastUpdated: json['last_updated'] ?? DateTime.now().toUtc().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
      'user_sub_division': userSubDivision.toJson(),
      'teleconnections': teleconnections.map((e) => e.toJson()).toList(),
      'seasonal_outlook': seasonalOutlook.toJson(),
      'all_sub_divisions': allSubDivisions.map((e) => e.toJson()).toList(),
      'adaptation_directives': adaptationDirectives,
      'vernacular_advisories': vernacularAdvisories,
      'provenance_authority': provenanceAuthority,
      'last_updated': lastUpdated,
    };
  }

  factory MonsoonIntelligenceModel.defaultFallback({
    double latitude = 13.0827,
    double longitude = 80.2707,
    String locationName = 'Chennai',
  }) {
    final defaultSubDivs = [
      SubDivisionalMonsoonModel(
        subDivisionCode: 'sd_31',
        name: 'Tamil Nadu, Puducherry & Karaikal',
        state: 'Tamil Nadu',
        actualRainfallMm: 510.0,
        normalRainfallMm: 440.0,
        departurePercentage: 15.9,
        departureCategory: 'Normal',
        departureColor: 'Green',
        soilMoistureIndex: 0.62,
        droughtRiskLevel: 'Normal',
        isUserSubDivision: true,
      ),
      SubDivisionalMonsoonModel(
        subDivisionCode: 'sd_23',
        name: 'Konkan & Goa',
        state: 'Maharashtra & Goa',
        actualRainfallMm: 3150.0,
        normalRainfallMm: 2910.0,
        departurePercentage: 8.2,
        departureCategory: 'Normal',
        departureColor: 'Green',
        soilMoistureIndex: 0.92,
        droughtRiskLevel: 'Normal',
      ),
      SubDivisionalMonsoonModel(
        subDivisionCode: 'sd_32',
        name: 'Coastal Karnataka',
        state: 'Karnataka',
        actualRainfallMm: 3290.0,
        normalRainfallMm: 3080.0,
        departurePercentage: 6.8,
        departureCategory: 'Normal',
        departureColor: 'Green',
        soilMoistureIndex: 0.94,
        droughtRiskLevel: 'Normal',
      ),
      SubDivisionalMonsoonModel(
        subDivisionCode: 'sd_35',
        name: 'Kerala & Mahe',
        state: 'Kerala',
        actualRainfallMm: 2180.0,
        normalRainfallMm: 2040.0,
        departurePercentage: 6.9,
        departureCategory: 'Normal',
        departureColor: 'Green',
        soilMoistureIndex: 0.89,
        droughtRiskLevel: 'Normal',
      ),
      SubDivisionalMonsoonModel(
        subDivisionCode: 'sd_17',
        name: 'West Rajasthan',
        state: 'Rajasthan',
        actualRainfallMm: 340.0,
        normalRainfallMm: 270.0,
        departurePercentage: 25.9,
        departureCategory: 'Excess',
        departureColor: 'Light Blue',
        soilMoistureIndex: 0.38,
        droughtRiskLevel: 'Normal',
      ),
    ];

    final defaultTeleconnections = [
      OceanicTeleconnectionModel(
        indexCode: 'enso_nino34',
        name: 'ENSO (Niño 3.4 SST Anomaly)',
        currentValue: -0.65,
        unit: '°C Anomaly',
        phase: 'La Niña (Cool Phase)',
        impactOnMonsoon: 'Favorable',
        mechanismSummary:
            'Cool equatorial Pacific sea surface temperatures enhance Walker circulation, strengthening cross-equatorial monsoon flows toward India.',
      ),
      OceanicTeleconnectionModel(
        indexCode: 'iod_dmi',
        name: 'Indian Ocean Dipole (IOD)',
        currentValue: 0.48,
        unit: '°C DMI',
        phase: 'Positive IOD (Active)',
        impactOnMonsoon: 'Favorable',
        mechanismSummary:
            'Warmer western equatorial Indian Ocean waters create an anomalous convergence zone, pumping moisture into central and peninsular India.',
      ),
      OceanicTeleconnectionModel(
        indexCode: 'mjo_convective',
        name: 'Madden-Julian Oscillation (MJO)',
        currentValue: 3.0,
        unit: 'Phase',
        phase: 'Phase 3 (Tropical Indian Ocean)',
        impactOnMonsoon: 'Favorable',
        mechanismSummary:
            'Convectively active eastward pulse over the Indian Ocean triggers enhanced convective rain spells and low-pressure formations.',
      ),
    ];

    final defaultOutlook = SeasonalForecastOutlookModel(
      seasonName: 'Southwest Monsoon Season (June - September)',
      onsetStatus: 'Active Pan-India Monsoon',
      probBelowNormalPct: 14,
      probNormalPct: 48,
      probAboveNormalPct: 38,
      officialLrfVerdict:
          'Normal to Above-Normal Monsoon likely nationwide (106% of LPA). Favorable ENSO and positive IOD support agrarian water security.',
    );

    return MonsoonIntelligenceModel(
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      userSubDivision: defaultSubDivs.first,
      teleconnections: defaultTeleconnections,
      seasonalOutlook: defaultOutlook,
      allSubDivisions: defaultSubDivs,
      adaptationDirectives: [
        'Favorable La Niña and positive IOD alignment indicate robust active spells for rainfed Kharif sowing.',
        'Conserve rainwater in farm ponds and recharge village percolation tanks during excess precipitation episodes.',
        'Ensure field drainage in low-lying clay soil tracts to prevent waterlogging during monsoon surges.',
        'Schedule top-dressing nitrogen fertilizers between major rainfall pulses to prevent runoff leaching.',
      ],
      vernacularAdvisories: {
        'ta': 'பருவமழை வழிகாட்டுதல்: லா நினா சாதகமான நிலையில் உள்ளதால் இயல்பான அல்லது இயல்புக்கு அதிகமான மழை பெய்யும். மானாவாரி விதைப்பு மற்றும் பண்ணைக் குட்டை நீர் சேமிப்பைத் திட்டமிடவும்.',
        'hi': 'मानसून दीर्घावधि पूर्वानुमान: ला नीना और सकारात्मक आईओडी के कारण सामान्य से अधिक वर्षा की संभावना है। खरीफ बुवाई और जल संचयन के लिए अनुकूल समय।',
        'mr': 'मान्सून दीर्घकालीन अंदाज: ला निना परिस्थितीमुळे सरासरीपेक्षा चांगल्या पावसाची शक्यता. खरीप पेरणीसाठी योग्य नियोजन करा.',
        'bn': 'মৌসুমি দীর্ঘমেয়াদী পূর্বাভাস: লা নিনা প্রভাবের কারণে স্বাভাবিক বা তার বেশি বৃষ্টিপাতের সম্ভাবনা। খরিফ চাষের জন্য উপযোগী জল ব্যবস্থাপনা বজায় রাখুন।',
      },
      provenanceAuthority: 'IMD Climate Services & NCMRWF Coupled Teleconnection Modeling',
      lastUpdated: DateTime.now().toUtc().toIso8601String(),
    );
  }
}
