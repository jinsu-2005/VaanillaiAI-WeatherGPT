/// Data models for Multi-Model Numerical Weather Prediction (NWP) Ensemble Comparison.
class NwpModelOutputModel {
  final String modelId;
  final String modelName;
  final String agency;
  final double resolutionKm;
  final double precipitationMm;
  final double temperatureMax;
  final double temperatureMin;

  const NwpModelOutputModel({
    required this.modelId,
    required this.modelName,
    required this.agency,
    required this.resolutionKm,
    required this.precipitationMm,
    required this.temperatureMax,
    required this.temperatureMin,
  });

  factory NwpModelOutputModel.fromJson(Map<String, dynamic> json) {
    return NwpModelOutputModel(
      modelId: json['model_id'] as String? ?? 'unknown',
      modelName: json['model_name'] as String? ?? 'Model',
      agency: json['agency'] as String? ?? '',
      resolutionKm: (json['resolution_km'] as num?)?.toDouble() ?? 25.0,
      precipitationMm: (json['precipitation_mm'] as num?)?.toDouble() ?? 0.0,
      temperatureMax: (json['temperature_max'] as num?)?.toDouble() ?? 30.0,
      temperatureMin: (json['temperature_min'] as num?)?.toDouble() ?? 24.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'model_id': modelId,
        'model_name': modelName,
        'agency': agency,
        'resolution_km': resolutionKm,
        'precipitation_mm': precipitationMm,
        'temperature_max': temperatureMax,
        'temperature_min': temperatureMin,
      };
}

class DailyNwpComparisonModel {
  final String date;
  final String dayName;
  final Map<String, NwpModelOutputModel> models;
  final double consensusRainMeanMm;
  final double consensusRainMinMm;
  final double consensusRainMaxMm;
  final double rainSpreadMm;
  final double consensusTempMax;
  final double consensusTempMin;
  final String confidence;
  final String divergenceNote;

  const DailyNwpComparisonModel({
    required this.date,
    required this.dayName,
    required this.models,
    required this.consensusRainMeanMm,
    required this.consensusRainMinMm,
    required this.consensusRainMaxMm,
    required this.rainSpreadMm,
    required this.consensusTempMax,
    required this.consensusTempMin,
    required this.confidence,
    required this.divergenceNote,
  });

  factory DailyNwpComparisonModel.fromJson(Map<String, dynamic> json) {
    final rawModels = json['models'] as Map<String, dynamic>? ?? {};
    final modelsMap = <String, NwpModelOutputModel>{};
    rawModels.forEach((k, v) {
      if (v is Map<String, dynamic>) {
        modelsMap[k] = NwpModelOutputModel.fromJson(v);
      }
    });

    return DailyNwpComparisonModel(
      date: json['date'] as String? ?? '',
      dayName: json['day_name'] as String? ?? '',
      models: modelsMap,
      consensusRainMeanMm: (json['consensus_rain_mean_mm'] as num?)?.toDouble() ?? 0.0,
      consensusRainMinMm: (json['consensus_rain_min_mm'] as num?)?.toDouble() ?? 0.0,
      consensusRainMaxMm: (json['consensus_rain_max_mm'] as num?)?.toDouble() ?? 0.0,
      rainSpreadMm: (json['rain_spread_mm'] as num?)?.toDouble() ?? 0.0,
      consensusTempMax: (json['consensus_temp_max'] as num?)?.toDouble() ?? 30.0,
      consensusTempMin: (json['consensus_temp_min'] as num?)?.toDouble() ?? 24.0,
      confidence: json['confidence'] as String? ?? 'Moderate',
      divergenceNote: json['divergence_note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'day_name': dayName,
        'models': models.map((k, v) => MapEntry(k, v.toJson())),
        'consensus_rain_mean_mm': consensusRainMeanMm,
        'consensus_rain_min_mm': consensusRainMinMm,
        'consensus_rain_max_mm': consensusRainMaxMm,
        'rain_spread_mm': rainSpreadMm,
        'consensus_temp_max': consensusTempMax,
        'consensus_temp_min': consensusTempMin,
        'confidence': confidence,
        'divergence_note': divergenceNote,
      };
}

class NwpModelMetadataModel {
  final String modelId;
  final String fullName;
  final String agency;
  final String country;
  final String resolution;
  final String primaryStrength;

  const NwpModelMetadataModel({
    required this.modelId,
    required this.fullName,
    required this.agency,
    required this.country,
    required this.resolution,
    required this.primaryStrength,
  });

  factory NwpModelMetadataModel.fromJson(Map<String, dynamic> json) {
    return NwpModelMetadataModel(
      modelId: json['model_id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      agency: json['agency'] as String? ?? '',
      country: json['country'] as String? ?? '',
      resolution: json['resolution'] as String? ?? '',
      primaryStrength: json['primary_strength'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'model_id': modelId,
        'full_name': fullName,
        'agency': agency,
        'country': country,
        'resolution': resolution,
        'primary_strength': primaryStrength,
      };
}

class MultiModelComparisonModel {
  final String locationName;
  final double latitude;
  final double longitude;
  final double? elevation;
  final int daysCount;
  final String overallConfidence;
  final String overallSummary;
  final List<DailyNwpComparisonModel> dailyComparisons;
  final List<NwpModelMetadataModel> modelMetadata;
  final String provenance;
  final bool dataUnavailable;

  const MultiModelComparisonModel({
    required this.locationName,
    required this.latitude,
    required this.longitude,
    this.elevation,
    required this.daysCount,
    required this.overallConfidence,
    required this.overallSummary,
    required this.dailyComparisons,
    required this.modelMetadata,
    required this.provenance,
    this.dataUnavailable = false,
  });

  factory MultiModelComparisonModel.fromJson(Map<String, dynamic> json) {
    final dailyList = (json['daily_comparisons'] as List<dynamic>?)
            ?.map((e) => DailyNwpComparisonModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final metaList = (json['model_metadata'] as List<dynamic>?)
            ?.map((e) => NwpModelMetadataModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return MultiModelComparisonModel(
      locationName: json['location_name'] as String? ?? 'Location',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      elevation: (json['elevation'] as num?)?.toDouble(),
      daysCount: json['days_count'] as int? ?? dailyList.length,
      overallConfidence: json['overall_confidence'] as String? ?? 'Moderate',
      overallSummary: json['overall_summary'] as String? ?? '',
      dailyComparisons: dailyList,
      modelMetadata: metaList,
      provenance: json['provenance'] as String? ??
          'Open-Meteo Multi-Model Global NWP Ensemble API (ECMWF, NOAA/NCEP, DWD)',
      dataUnavailable: false,
    );
  }

  Map<String, dynamic> toJson() => {
        'location_name': locationName,
        'latitude': latitude,
        'longitude': longitude,
        'elevation': elevation,
        'days_count': daysCount,
        'overall_confidence': overallConfidence,
        'overall_summary': overallSummary,
        'daily_comparisons': dailyComparisons.map((e) => e.toJson()).toList(),
        'model_metadata': modelMetadata.map((e) => e.toJson()).toList(),
        'provenance': provenance,
      };

  factory MultiModelComparisonModel.unavailable(String locationName) {
    return MultiModelComparisonModel(
      locationName: locationName,
      latitude: 0.0,
      longitude: 0.0,
      daysCount: 0,
      overallConfidence: 'Unavailable',
      overallSummary:
          'Multi-model NWP server connection unavailable. Check internet connectivity or try again later.',
      dailyComparisons: const [],
      modelMetadata: const [],
      provenance: 'Offline Notice',
      dataUnavailable: true,
    );
  }
}
