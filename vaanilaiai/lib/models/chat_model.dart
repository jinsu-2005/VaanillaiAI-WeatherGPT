import 'alert_model.dart';

class WeatherCardSummaryModel {
  final String locationName;
  final double temperature;
  final double feelsLike;
  final String conditionText;
  final String conditionIcon;
  final int humidity;
  final double windSpeed;
  final int rainProbability;
  final double uvIndex;
  final String sourceType;

  WeatherCardSummaryModel({
    required this.locationName,
    required this.temperature,
    required this.feelsLike,
    required this.conditionText,
    required this.conditionIcon,
    required this.humidity,
    required this.windSpeed,
    required this.rainProbability,
    required this.uvIndex,
    required this.sourceType,
  });

  factory WeatherCardSummaryModel.fromJson(Map<String, dynamic> json) {
    return WeatherCardSummaryModel(
      locationName: json['location_name'] ?? 'Location',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (json['feels_like'] as num?)?.toDouble() ?? 0.0,
      conditionText: json['condition_text'] ?? '',
      conditionIcon: json['condition_icon'] ?? 'sunny',
      humidity: json['humidity'] ?? 0,
      windSpeed: (json['wind_speed'] as num?)?.toDouble() ?? 0.0,
      rainProbability: json['rain_probability'] ?? 0,
      uvIndex: (json['uv_index'] as num?)?.toDouble() ?? 0.0,
      sourceType: json['source_type'] ?? 'NWP_MODEL_ECMWF',
    );
  }
}

class ChatMessageModel {
  final String role; // 'user', 'assistant'
  final String content;
  final String language;
  final String? sessionId;
  final String? intent;
  final String? detectedLocation;
  final WeatherCardSummaryModel? weatherCard;
  final List<DisasterAlertModel> activeAlerts;
  final String? advisorySummary;
  final List<String> citations;
  final List<String> toolsUsed;
  final DateTime timestamp;

  ChatMessageModel({
    required this.role,
    required this.content,
    required this.language,
    this.sessionId,
    this.intent,
    this.detectedLocation,
    this.weatherCard,
    this.activeAlerts = const [],
    this.advisorySummary,
    this.citations = const [],
    this.toolsUsed = const [],
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, {String role = 'assistant'}) {
    return ChatMessageModel(
      role: json['role'] ?? role,
      content: json['response_text'] ?? json['content'] ?? '',
      language: json['language'] ?? 'en',
      sessionId: json['session_id']?.toString(),
      intent: json['intent'],
      detectedLocation: json['detected_location'],
      weatherCard: json['weather_card'] != null
          ? WeatherCardSummaryModel.fromJson(json['weather_card'])
          : null,
      activeAlerts: (json['active_alerts'] as List<dynamic>? ?? [])
          .map((e) => DisasterAlertModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      advisorySummary: json['advisory_summary'],
      citations: List<String>.from(json['citations'] ?? []),
      toolsUsed: List<String>.from(json['tools_used'] ?? []),
      timestamp: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }
}
