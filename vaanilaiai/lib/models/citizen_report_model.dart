class CitizenReportModel {
  final String id;
  final String reportType;
  final String severity;
  final double? waterDepthInches;
  final String description;
  final double latitude;
  final double longitude;
  final String locationName;
  final String? photoUrl;
  final String reporterRole;
  final int upvotes;
  final String createdAt;

  CitizenReportModel({
    required this.id,
    required this.reportType,
    required this.severity,
    this.waterDepthInches,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    this.photoUrl,
    required this.reporterRole,
    this.upvotes = 0,
    required this.createdAt,
  });

  factory CitizenReportModel.fromJson(Map<String, dynamic> json) {
    return CitizenReportModel(
      id: json['id'] ?? '',
      reportType: json['report_type'] ?? 'Waterlogging',
      severity: json['severity'] ?? 'Moderate',
      waterDepthInches: (json['water_depth_inches'] as num?)?.toDouble(),
      description: json['description'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      locationName: json['location_name'] ?? '',
      photoUrl: json['photo_url'],
      reporterRole: json['reporter_role'] ?? 'Citizen',
      upvotes: (json['upvotes'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_type': reportType,
      'severity': severity,
      if (waterDepthInches != null) 'water_depth_inches': waterDepthInches,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
      if (photoUrl != null) 'photo_url': photoUrl,
      'reporter_role': reporterRole,
    };
  }
}
