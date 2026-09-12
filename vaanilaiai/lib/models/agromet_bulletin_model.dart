class AgrometDayForecastModel {
  final String date;
  final String dayName;
  final double rainfallMm;
  final double tempMaxC;
  final double tempMinC;
  final int humidityMorningPct;
  final int humidityEveningPct;
  final double windSpeedKmh;
  final String windDirectionCardinal;
  final int cloudCoverOcta;

  AgrometDayForecastModel({
    required this.date,
    required this.dayName,
    required this.rainfallMm,
    required this.tempMaxC,
    required this.tempMinC,
    required this.humidityMorningPct,
    required this.humidityEveningPct,
    required this.windSpeedKmh,
    required this.windDirectionCardinal,
    required this.cloudCoverOcta,
  });

  factory AgrometDayForecastModel.fromJson(Map<String, dynamic> json) {
    return AgrometDayForecastModel(
      date: json['date']?.toString() ?? '',
      dayName: json['day_name']?.toString() ?? 'Day',
      rainfallMm: (json['rainfall_mm'] as num?)?.toDouble() ?? 0.0,
      tempMaxC: (json['temp_max_c'] as num?)?.toDouble() ?? 32.0,
      tempMinC: (json['temp_min_c'] as num?)?.toDouble() ?? 22.0,
      humidityMorningPct: (json['humidity_morning_pct'] as num?)?.toInt() ?? 75,
      humidityEveningPct: (json['humidity_evening_pct'] as num?)?.toInt() ?? 55,
      windSpeedKmh: (json['wind_speed_kmh'] as num?)?.toDouble() ?? 12.0,
      windDirectionCardinal: json['wind_direction_cardinal']?.toString() ?? 'NW',
      cloudCoverOcta: (json['cloud_cover_octa'] as num?)?.toInt() ?? 3,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'day_name': dayName,
    'rainfall_mm': rainfallMm,
    'temp_max_c': tempMaxC,
    'temp_min_c': tempMinC,
    'humidity_morning_pct': humidityMorningPct,
    'humidity_evening_pct': humidityEveningPct,
    'wind_speed_kmh': windSpeedKmh,
    'wind_direction_cardinal': windDirectionCardinal,
    'cloud_cover_octa': cloudCoverOcta,
  };
}

class CropAgrometAdvisoryModel {
  final String cropName;
  final String stage;
  final String riskLevel;
  final String advisoryText;
  final String? pestDiseaseAdvisory;
  final String? recommendedIntervention;

  CropAgrometAdvisoryModel({
    required this.cropName,
    required this.stage,
    required this.riskLevel,
    required this.advisoryText,
    this.pestDiseaseAdvisory,
    this.recommendedIntervention,
  });

  factory CropAgrometAdvisoryModel.fromJson(Map<String, dynamic> json) {
    return CropAgrometAdvisoryModel(
      cropName: json['crop_name']?.toString() ?? 'Crop',
      stage: json['stage']?.toString() ?? 'Active Growth',
      riskLevel: json['risk_level']?.toString() ?? 'Normal',
      advisoryText: json['advisory_text']?.toString() ?? '',
      pestDiseaseAdvisory: json['pest_disease_advisory']?.toString(),
      recommendedIntervention: json['recommended_intervention']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'crop_name': cropName,
    'stage': stage,
    'risk_level': riskLevel,
    'advisory_text': advisoryText,
    'pest_disease_advisory': pestDiseaseAdvisory,
    'recommended_intervention': recommendedIntervention,
  };
}

class LivestockAdvisoryModel {
  final String livestockType;
  final String riskLevel;
  final String managementAdvice;
  final String? vaccinationOrDiseaseAlert;

  LivestockAdvisoryModel({
    required this.livestockType,
    required this.riskLevel,
    required this.managementAdvice,
    this.vaccinationOrDiseaseAlert,
  });

  factory LivestockAdvisoryModel.fromJson(Map<String, dynamic> json) {
    return LivestockAdvisoryModel(
      livestockType: json['livestock_type']?.toString() ?? 'Livestock',
      riskLevel: json['risk_level']?.toString() ?? 'Normal',
      managementAdvice: json['management_advice']?.toString() ?? '',
      vaccinationOrDiseaseAlert: json['vaccination_or_disease_alert']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'livestock_type': livestockType,
    'risk_level': riskLevel,
    'management_advice': managementAdvice,
    'vaccination_or_disease_alert': vaccinationOrDiseaseAlert,
  };
}

class DistrictAgrometBulletinModel {
  final String district;
  final String state;
  final String bulletinNumber;
  final String issueDate;
  final String validFrom;
  final String validUntil;
  final String amfuCenter;
  final String synopticWeatherSummary;
  final List<AgrometDayForecastModel> fiveDayForecast;
  final List<String> generalFarmAdvisories;
  final List<CropAgrometAdvisoryModel> cropAdvisories;
  final List<LivestockAdvisoryModel> livestockAdvisories;
  final String provenanceDisclaimer;
  final bool isOfflineCached;

  DistrictAgrometBulletinModel({
    required this.district,
    required this.state,
    required this.bulletinNumber,
    required this.issueDate,
    required this.validFrom,
    required this.validUntil,
    required this.amfuCenter,
    required this.synopticWeatherSummary,
    this.fiveDayForecast = const [],
    this.generalFarmAdvisories = const [],
    this.cropAdvisories = const [],
    this.livestockAdvisories = const [],
    this.provenanceDisclaimer = 'Prepared in accordance with ICAR-IMD Gramin Krishi Mausam Seva (GKMS) protocols.',
    this.isOfflineCached = false,
  });

  factory DistrictAgrometBulletinModel.fromJson(Map<String, dynamic> json, {bool isOffline = false}) {
    return DistrictAgrometBulletinModel(
      district: json['district']?.toString() ?? 'District Agromet Zone',
      state: json['state']?.toString() ?? 'India',
      bulletinNumber: json['bulletin_number']?.toString() ?? 'GKMS/BULLETIN',
      issueDate: json['issue_date']?.toString() ?? '',
      validFrom: json['valid_from']?.toString() ?? '',
      validUntil: json['valid_until']?.toString() ?? '',
      amfuCenter: json['amfu_center']?.toString() ?? 'ICAR-IMD Agromet Field Unit (AMFU)',
      synopticWeatherSummary: json['synoptic_weather_summary']?.toString() ?? '',
      fiveDayForecast: (json['five_day_forecast'] as List?)
              ?.map((e) => AgrometDayForecastModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      generalFarmAdvisories: (json['general_farm_advisories'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      cropAdvisories: (json['crop_advisories'] as List?)
              ?.map((e) => CropAgrometAdvisoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      livestockAdvisories: (json['livestock_advisories'] as List?)
              ?.map((e) => LivestockAdvisoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      provenanceDisclaimer: json['provenance_disclaimer']?.toString() ??
          'Prepared in accordance with ICAR-IMD Gramin Krishi Mausam Seva (GKMS) protocols.',
      isOfflineCached: isOffline || (json['is_offline_cached'] == true),
    );
  }

  Map<String, dynamic> toJson() => {
    'district': district,
    'state': state,
    'bulletin_number': bulletinNumber,
    'issue_date': issueDate,
    'valid_from': validFrom,
    'valid_until': validUntil,
    'amfu_center': amfuCenter,
    'synoptic_weather_summary': synopticWeatherSummary,
    'five_day_forecast': fiveDayForecast.map((e) => e.toJson()).toList(),
    'general_farm_advisories': generalFarmAdvisories,
    'crop_advisories': cropAdvisories.map((e) => e.toJson()).toList(),
    'livestock_advisories': livestockAdvisories.map((e) => e.toJson()).toList(),
    'provenance_disclaimer': provenanceDisclaimer,
    'is_offline_cached': isOfflineCached,
  };
}
