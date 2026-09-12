class DisasterAlertModel {
  final String alertId;
  final String source;
  final String category;
  final String severity; // Red, Orange, Yellow, Green
  final String urgency;
  final String headline;
  final String description;
  final String? instruction;
  final String areaDescription;
  final String? district;
  final String? state;
  final String effectiveFrom;
  final String expiresAt;
  final bool isActive;
  final String colorHex;
  final String? capIdentifier;
  final String? polygonUrl;
  final String? vernacularHeadline;
  final String? vernacularLanguage;
  final String? senderOrg;

  DisasterAlertModel({
    required this.alertId,
    required this.source,
    required this.category,
    required this.severity,
    required this.urgency,
    required this.headline,
    required this.description,
    this.instruction,
    required this.areaDescription,
    this.district,
    this.state,
    required this.effectiveFrom,
    required this.expiresAt,
    required this.isActive,
    required this.colorHex,
    this.capIdentifier,
    this.polygonUrl,
    this.vernacularHeadline,
    this.vernacularLanguage,
    this.senderOrg,
  });

  factory DisasterAlertModel.fromJson(Map<String, dynamic> json) {
    return DisasterAlertModel(
      alertId: json['alert_id'] ?? '',
      source: json['source'] ?? 'IMD',
      category: json['category'] ?? 'Weather Alert',
      severity: json['severity'] ?? 'Yellow',
      urgency: json['urgency'] ?? 'Immediate',
      headline: json['headline'] ?? '',
      description: json['description'] ?? '',
      instruction: json['instruction'],
      areaDescription: json['area_description'] ?? '',
      district: json['district'],
      state: json['state'],
      effectiveFrom: json['effective_from'] ?? '',
      expiresAt: json['expires_at'] ?? '',
      isActive: json['is_active'] ?? true,
      colorHex: json['color_hex'] ?? '#E53E3E',
      capIdentifier: json['cap_identifier'],
      polygonUrl: json['polygon_url'],
      vernacularHeadline: json['vernacular_headline'],
      vernacularLanguage: json['vernacular_language'],
      senderOrg: json['sender_org'],
    );
  }
}

class AlertSummaryModel {
  final int totalActiveAlerts;
  final String highestSeverity;
  final List<DisasterAlertModel> alerts;

  AlertSummaryModel({
    required this.totalActiveAlerts,
    required this.highestSeverity,
    required this.alerts,
  });

  factory AlertSummaryModel.fromJson(Map<String, dynamic> json) {
    return AlertSummaryModel(
      totalActiveAlerts: json['total_active_alerts'] ?? 0,
      highestSeverity: json['highest_severity'] ?? 'Green',
      alerts: (json['alerts'] as List<dynamic>? ?? [])
          .map((e) => DisasterAlertModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
