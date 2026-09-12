import 'alert_model.dart';

class WeatherProvenanceModel {
  final String sourceType;
  final String providerName;
  final String? modelResolution;
  final double forecastConfidence;
  final String lastUpdated;

  WeatherProvenanceModel({
    required this.sourceType,
    required this.providerName,
    this.modelResolution,
    required this.forecastConfidence,
    required this.lastUpdated,
  });

  factory WeatherProvenanceModel.fromJson(Map<String, dynamic> json) {
    return WeatherProvenanceModel(
      sourceType: json['source_type'] ?? 'NWP_MODEL_ECMWF',
      providerName: json['provider_name'] ?? 'Open-Meteo High-Resolution NWP',
      modelResolution: json['model_resolution'],
      forecastConfidence: (json['forecast_confidence'] as num?)?.toDouble() ?? 0.95,
      lastUpdated: json['last_updated'] ?? '',
    );
  }
}

class AirQualityModel {
  final int aqi;
  final double pm25;
  final double pm10;
  final String category;
  final String colorHex;

  AirQualityModel({
    required this.aqi,
    required this.pm25,
    required this.pm10,
    required this.category,
    required this.colorHex,
  });

  factory AirQualityModel.fromJson(Map<String, dynamic> json) {
    return AirQualityModel(
      aqi: json['aqi'] ?? 50,
      pm25: (json['pm2_5'] as num?)?.toDouble() ?? 25.0,
      pm10: (json['pm10'] as num?)?.toDouble() ?? 45.0,
      category: json['category'] ?? 'Good',
      colorHex: json['color_hex'] ?? '#38A169',
    );
  }
}

class CurrentWeatherModel {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double pressure;
  final double windSpeed;
  final int windDirection;
  final double? windGusts;
  final double precipitation;
  final double rain;
  final int cloudCover;
  final double visibility;
  final double uvIndex;
  final int weatherCode;
  final String conditionText;
  final String conditionIcon;
  final bool isDay;
  final WeatherProvenanceModel provenance;

  CurrentWeatherModel({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDirection,
    this.windGusts,
    required this.precipitation,
    required this.rain,
    required this.cloudCover,
    required this.visibility,
    required this.uvIndex,
    required this.weatherCode,
    required this.conditionText,
    required this.conditionIcon,
    required this.isDay,
    required this.provenance,
  });

  factory CurrentWeatherModel.fromJson(Map<String, dynamic> json) {
    return CurrentWeatherModel(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (json['feels_like'] as num?)?.toDouble() ?? 0.0,
      humidity: json['humidity'] ?? 0,
      pressure: (json['pressure'] as num?)?.toDouble() ?? 1013.25,
      windSpeed: (json['wind_speed'] as num?)?.toDouble() ?? 0.0,
      windDirection: json['wind_direction'] ?? 0,
      windGusts: (json['wind_gusts'] as num?)?.toDouble(),
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      rain: (json['rain'] as num?)?.toDouble() ?? 0.0,
      cloudCover: json['cloud_cover'] ?? 0,
      visibility: (json['visibility'] as num?)?.toDouble() ?? 10000.0,
      uvIndex: (json['uv_index'] as num?)?.toDouble() ?? 0.0,
      weatherCode: json['weather_code'] ?? 0,
      conditionText: json['condition_text'] ?? 'Clear sky',
      conditionIcon: json['condition_icon'] ?? 'sunny',
      isDay: json['is_day'] ?? true,
      provenance: WeatherProvenanceModel.fromJson(json['provenance'] ?? {}),
    );
  }
}

class HourlyForecastModel {
  final String time;
  final double temperature;
  final double feelsLike;
  final int precipitationProbability;
  final double precipitation;
  final double rain;
  final int weatherCode;
  final String conditionText;
  final String conditionIcon;
  final double windSpeed;
  final int windDirection;
  final int humidity;
  final double uvIndex;
  final bool isDay;

  HourlyForecastModel({
    required this.time,
    required this.temperature,
    required this.feelsLike,
    required this.precipitationProbability,
    required this.precipitation,
    required this.rain,
    required this.weatherCode,
    required this.conditionText,
    required this.conditionIcon,
    required this.windSpeed,
    required this.windDirection,
    required this.humidity,
    required this.uvIndex,
    required this.isDay,
  });

  factory HourlyForecastModel.fromJson(Map<String, dynamic> json) {
    return HourlyForecastModel(
      time: json['time'] ?? '',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (json['feels_like'] as num?)?.toDouble() ?? 0.0,
      precipitationProbability: json['precipitation_probability'] ?? 0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      rain: (json['rain'] as num?)?.toDouble() ?? 0.0,
      weatherCode: json['weather_code'] ?? 0,
      conditionText: json['condition_text'] ?? '',
      conditionIcon: json['condition_icon'] ?? 'sunny',
      windSpeed: (json['wind_speed'] as num?)?.toDouble() ?? 0.0,
      windDirection: json['wind_direction'] ?? 0,
      humidity: json['humidity'] ?? 0,
      uvIndex: (json['uv_index'] as num?)?.toDouble() ?? 0.0,
      isDay: json['is_day'] ?? true,
    );
  }
}

class DailyForecastModel {
  final String date;
  final double tempMax;
  final double tempMin;
  final double precipitationSum;
  final int precipitationProbabilityMax;
  final double rainSum;
  final double windSpeedMax;
  final int windDirectionDominant;
  final double uvIndexMax;
  final int weatherCode;
  final String conditionText;
  final String conditionIcon;
  final String sunrise;
  final String sunset;

  DailyForecastModel({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.precipitationSum,
    required this.precipitationProbabilityMax,
    required this.rainSum,
    required this.windSpeedMax,
    required this.windDirectionDominant,
    required this.uvIndexMax,
    required this.weatherCode,
    required this.conditionText,
    required this.conditionIcon,
    required this.sunrise,
    required this.sunset,
  });

  factory DailyForecastModel.fromJson(Map<String, dynamic> json) {
    return DailyForecastModel(
      date: json['date'] ?? '',
      tempMax: (json['temp_max'] as num?)?.toDouble() ?? 0.0,
      tempMin: (json['temp_min'] as num?)?.toDouble() ?? 0.0,
      precipitationSum: (json['precipitation_sum'] as num?)?.toDouble() ?? 0.0,
      precipitationProbabilityMax: json['precipitation_probability_max'] ?? 0,
      rainSum: (json['rain_sum'] as num?)?.toDouble() ?? 0.0,
      windSpeedMax: (json['wind_speed_max'] as num?)?.toDouble() ?? 0.0,
      windDirectionDominant: json['wind_direction_dominant'] ?? 0,
      uvIndexMax: (json['uv_index_max'] as num?)?.toDouble() ?? 0.0,
      weatherCode: json['weather_code'] ?? 0,
      conditionText: json['condition_text'] ?? '',
      conditionIcon: json['condition_icon'] ?? 'sunny',
      sunrise: json['sunrise'] ?? '',
      sunset: json['sunset'] ?? '',
    );
  }
}

class WeatherForecastModel {
  final String locationName;
  final String? district;
  final String? state;
  final double latitude;
  final double longitude;
  final double? elevation;
  final CurrentWeatherModel current;
  final List<HourlyForecastModel> hourly;
  final List<DailyForecastModel> daily;
  final AirQualityModel? airQuality;
  final List<DisasterAlertModel> activeWarnings;
  final String? uncertaintyNotes;
  /// When this data was fetched (client-side timestamp).
  final DateTime? lastFetchedAt;
  /// Source label: 'live', 'cached', 'forecast_model', 'estimated', 'unavailable'
  final String dataSource;

  WeatherForecastModel({
    required this.locationName,
    this.district,
    this.state,
    required this.latitude,
    required this.longitude,
    this.elevation,
    required this.current,
    required this.hourly,
    required this.daily,
    this.airQuality,
    required this.activeWarnings,
    this.uncertaintyNotes,
    this.lastFetchedAt,
    this.dataSource = 'live',
  });

  factory WeatherForecastModel.fromJson(Map<String, dynamic> json) {
    return WeatherForecastModel(
      locationName: json['location_name'] ?? 'Location',
      district: json['district'],
      state: json['state'],
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      elevation: (json['elevation'] as num?)?.toDouble(),
      current: CurrentWeatherModel.fromJson(json['current'] ?? {}),
      hourly: (json['hourly'] as List<dynamic>? ?? [])
          .map((e) => HourlyForecastModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      daily: (json['daily'] as List<dynamic>? ?? [])
          .map((e) => DailyForecastModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      airQuality: json['air_quality'] != null ? AirQualityModel.fromJson(json['air_quality']) : null,
      activeWarnings: (json['active_warnings'] as List<dynamic>? ?? [])
          .map((e) => DisasterAlertModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      uncertaintyNotes: json['uncertainty_notes'],
      lastFetchedAt: DateTime.now(),
      dataSource: json['data_source'] ?? 'live',
    );
  }

  /// Creates a copy with updated metadata (e.g. marking as cached).
  WeatherForecastModel copyWith({
    String? dataSource,
    DateTime? lastFetchedAt,
  }) {
    return WeatherForecastModel(
      locationName: locationName,
      district: district,
      state: state,
      latitude: latitude,
      longitude: longitude,
      elevation: elevation,
      current: current,
      hourly: hourly,
      daily: daily,
      airQuality: airQuality,
      activeWarnings: activeWarnings,
      uncertaintyNotes: uncertaintyNotes,
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
      dataSource: dataSource ?? this.dataSource,
    );
  }
}
