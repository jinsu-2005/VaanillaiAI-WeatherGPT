class AgricultureAdvisoryModel {
  final String locationName;
  final String? district;
  final String date;
  final String sprayingSuitability; // Favorable, Risky, Unfavorable
  final String sprayingReason;
  final List<String> suitableSprayingHours;
  final String irrigationAdvice;
  final double rainRisk24hMm;
  final String rainRiskLevel;
  final String heatStressLevel;
  final String pestDiseaseRisk;
  final List<String> cropSpecificTips;
  final String officialDisclaimer;

  AgricultureAdvisoryModel({
    required this.locationName,
    this.district,
    required this.date,
    required this.sprayingSuitability,
    required this.sprayingReason,
    required this.suitableSprayingHours,
    required this.irrigationAdvice,
    required this.rainRisk24hMm,
    required this.rainRiskLevel,
    required this.heatStressLevel,
    required this.pestDiseaseRisk,
    required this.cropSpecificTips,
    required this.officialDisclaimer,
  });

  factory AgricultureAdvisoryModel.fromJson(Map<String, dynamic> json) {
    return AgricultureAdvisoryModel(
      locationName: json['location_name'] ?? '',
      district: json['district'],
      date: json['date'] ?? '',
      sprayingSuitability: json['spraying_suitability'] ?? 'Favorable',
      sprayingReason: json['spraying_reason'] ?? '',
      suitableSprayingHours: List<String>.from(json['suitable_spraying_hours'] ?? []),
      irrigationAdvice: json['irrigation_advice'] ?? '',
      rainRisk24hMm: (json['rain_risk_24h_mm'] as num?)?.toDouble() ?? 0.0,
      rainRiskLevel: json['rain_risk_level'] ?? 'Low',
      heatStressLevel: json['heat_stress_level'] ?? 'Normal',
      pestDiseaseRisk: json['pest_disease_risk'] ?? 'Low',
      cropSpecificTips: List<String>.from(json['crop_specific_tips'] ?? []),
      officialDisclaimer: json['official_disclaimer'] ?? '',
    );
  }
}

class TravelAdvisoryModel {
  final String locationName;
  final String? district;
  final String date;
  final String overallSuitability; // Good, Caution, Hazardous
  final int travelRiskScore; // 0 - 100
  final String roadSafetyCondition;
  final String visibilityCondition;
  final double visibilityMeters;
  final String windHazardLevel;
  final String flightDisruptionRisk;
  final List<String> safetyRecommendations;

  TravelAdvisoryModel({
    required this.locationName,
    this.district,
    required this.date,
    required this.overallSuitability,
    required this.travelRiskScore,
    required this.roadSafetyCondition,
    required this.visibilityCondition,
    required this.visibilityMeters,
    required this.windHazardLevel,
    required this.flightDisruptionRisk,
    required this.safetyRecommendations,
  });

  factory TravelAdvisoryModel.fromJson(Map<String, dynamic> json) {
    return TravelAdvisoryModel(
      locationName: json['location_name'] ?? '',
      district: json['district'],
      date: json['date'] ?? '',
      overallSuitability: json['overall_suitability'] ?? 'Good',
      travelRiskScore: json['travel_risk_score'] ?? 10,
      roadSafetyCondition: json['road_safety_condition'] ?? '',
      visibilityCondition: json['visibility_condition'] ?? '',
      visibilityMeters: (json['visibility_meters'] as num?)?.toDouble() ?? 10000.0,
      windHazardLevel: json['wind_hazard_level'] ?? 'Gentle Wind',
      flightDisruptionRisk: json['flight_disruption_risk'] ?? 'Low',
      safetyRecommendations: List<String>.from(json['safety_recommendations'] ?? []),
    );
  }
}
