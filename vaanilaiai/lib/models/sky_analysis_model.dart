class SkyAnalysisModel {
  final String cloudGenus;
  final String cloudDescription;
  final int cloudCoveragePercentage;
  final int? rainOnsetEstimatedMinutes;
  final String squallRiskLevel;
  final double confidenceScore;
  final String actionableVerdict;
  final String vernacularSummary;
  /// True when no real sky analysis was performed (backend unreachable).
  final bool dataUnavailable;

  SkyAnalysisModel({
    required this.cloudGenus,
    required this.cloudDescription,
    required this.cloudCoveragePercentage,
    this.rainOnsetEstimatedMinutes,
    required this.squallRiskLevel,
    required this.confidenceScore,
    required this.actionableVerdict,
    required this.vernacularSummary,
    this.dataUnavailable = false,
  });

  factory SkyAnalysisModel.fromJson(Map<String, dynamic> json) {
    return SkyAnalysisModel(
      cloudGenus: json['cloud_genus'] ?? 'Cumulus',
      cloudDescription: json['cloud_description'] ?? '',
      cloudCoveragePercentage: (json['cloud_coverage_percentage'] as num?)?.toInt() ?? 60,
      rainOnsetEstimatedMinutes: (json['rain_onset_estimated_minutes'] as num?)?.toInt(),
      squallRiskLevel: json['squall_risk_level'] ?? 'Low',
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.85,
      actionableVerdict: json['actionable_verdict'] ?? '',
      vernacularSummary: json['vernacular_summary'] ?? '',
      dataUnavailable: json['data_unavailable'] ?? false,
    );
  }

  /// Creates an "unavailable" placeholder when sky analysis cannot be performed.
  factory SkyAnalysisModel.unavailable(String locationName) {
    return SkyAnalysisModel(
      cloudGenus: 'Unknown',
      cloudDescription: 'Sky analysis could not be performed. The image analysis service is currently unavailable.',
      cloudCoveragePercentage: 0,
      squallRiskLevel: 'Unknown',
      confidenceScore: 0.0,
      actionableVerdict: 'Sky analysis is temporarily unavailable. Please try again later.',
      vernacularSummary: 'வான் பகுப்பாய்வு தற்போது கிடைக்கவில்லை.',
      dataUnavailable: true,
    );
  }
}

