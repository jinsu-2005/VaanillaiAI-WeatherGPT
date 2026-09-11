class CropStageAdvisoryModel {
  final String cropType;
  final String growthStage;
  final String locationName;
  final String stageVulnerability;
  final String waterRequirementStatus;
  final String irrigationDirective;
  final String chemicalSprayingDirective;
  final String pestDiseaseAlert;
  final String? harvestLogisticsAdvice;
  final List<String> actionItems;

  CropStageAdvisoryModel({
    required this.cropType,
    required this.growthStage,
    required this.locationName,
    required this.stageVulnerability,
    required this.waterRequirementStatus,
    required this.irrigationDirective,
    required this.chemicalSprayingDirective,
    required this.pestDiseaseAlert,
    this.harvestLogisticsAdvice,
    this.actionItems = const [],
  });

  factory CropStageAdvisoryModel.fromJson(Map<String, dynamic> json) {
    return CropStageAdvisoryModel(
      cropType: json['crop_type'] ?? 'Paddy/Rice',
      growthStage: json['growth_stage'] ?? 'Vegetative',
      locationName: json['location_name'] ?? 'Location',
      stageVulnerability: json['stage_vulnerability'] ?? 'Low',
      waterRequirementStatus: json['water_requirement_status'] ?? 'Balanced',
      irrigationDirective: json['irrigation_directive'] ?? 'Normal scheduled irrigation.',
      chemicalSprayingDirective: json['chemical_spraying_directive'] ?? 'Normal spraying window.',
      pestDiseaseAlert: json['pest_disease_alert'] ?? 'Standard pest surveillance advised.',
      harvestLogisticsAdvice: json['harvest_logistics_advice'],
      actionItems: (json['action_items'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
