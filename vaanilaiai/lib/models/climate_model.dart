class MonthlyClimateStatsModel {
  final String monthName;
  final int monthIndex;
  final double avgTemperatureC;
  final double totalRainfallMm;
  final int rainyDaysCount;

  MonthlyClimateStatsModel({
    required this.monthName,
    required this.monthIndex,
    required this.avgTemperatureC,
    required this.totalRainfallMm,
    required this.rainyDaysCount,
  });

  factory MonthlyClimateStatsModel.fromJson(Map<String, dynamic> json) {
    return MonthlyClimateStatsModel(
      monthName: json['month_name'] ?? '',
      monthIndex: json['month_index'] ?? 1,
      avgTemperatureC: (json['avg_temperature_c'] as num?)?.toDouble() ?? 0.0,
      totalRainfallMm: (json['total_rainfall_mm'] as num?)?.toDouble() ?? 0.0,
      rainyDaysCount: json['rainy_days_count'] ?? 0,
    );
  }
}

class YearlyClimateStatsModel {
  final int year;
  final double annualRainfallMm;
  final double annualMeanTempC;
  final double maxTempRecordedC;
  final double minTempRecordedC;
  final List<MonthlyClimateStatsModel> monthlyStats;

  YearlyClimateStatsModel({
    required this.year,
    required this.annualRainfallMm,
    required this.annualMeanTempC,
    required this.maxTempRecordedC,
    required this.minTempRecordedC,
    required this.monthlyStats,
  });

  factory YearlyClimateStatsModel.fromJson(Map<String, dynamic> json) {
    return YearlyClimateStatsModel(
      year: json['year'] ?? 2023,
      annualRainfallMm: (json['annual_rainfall_mm'] as num?)?.toDouble() ?? 0.0,
      annualMeanTempC: (json['annual_mean_temp_c'] as num?)?.toDouble() ?? 0.0,
      maxTempRecordedC: (json['max_temp_recorded_c'] as num?)?.toDouble() ?? 0.0,
      minTempRecordedC: (json['min_temp_recorded_c'] as num?)?.toDouble() ?? 0.0,
      monthlyStats: (json['monthly_stats'] as List<dynamic>? ?? [])
          .map((e) => MonthlyClimateStatsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ClimateComparisonModel {
  final String locationName;
  final double latitude;
  final double longitude;
  final int year1;
  final int year2;
  final YearlyClimateStatsModel year1Stats;
  final YearlyClimateStatsModel year2Stats;
  final double rainfallDifferenceMm;
  final double rainfallChangePercent;
  final double temperatureDifferenceC;
  final String climateSummary;

  ClimateComparisonModel({
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.year1,
    required this.year2,
    required this.year1Stats,
    required this.year2Stats,
    required this.rainfallDifferenceMm,
    required this.rainfallChangePercent,
    required this.temperatureDifferenceC,
    required this.climateSummary,
  });

  factory ClimateComparisonModel.fromJson(Map<String, dynamic> json) {
    return ClimateComparisonModel(
      locationName: json['location_name'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      year1: json['year_1'] ?? 2022,
      year2: json['year_2'] ?? 2023,
      year1Stats: YearlyClimateStatsModel.fromJson(json['year_1_stats'] ?? {}),
      year2Stats: YearlyClimateStatsModel.fromJson(json['year_2_stats'] ?? {}),
      rainfallDifferenceMm: (json['rainfall_difference_mm'] as num?)?.toDouble() ?? 0.0,
      rainfallChangePercent: (json['rainfall_change_percent'] as num?)?.toDouble() ?? 0.0,
      temperatureDifferenceC: (json['temperature_difference_c'] as num?)?.toDouble() ?? 0.0,
      climateSummary: json['climate_summary'] ?? '',
    );
  }
}

class ClimateTrendModel {
  final String locationName;
  final double latitude;
  final double longitude;
  final int startYear;
  final int endYear;
  final List<YearlyClimateStatsModel> multiYearStats;
  final double averageAnnualRainfallMm;
  final double rainfallTrendSlope;
  final double warmingTrendCPerDecade;
  final String trendDescription;

  ClimateTrendModel({
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.startYear,
    required this.endYear,
    required this.multiYearStats,
    required this.averageAnnualRainfallMm,
    required this.rainfallTrendSlope,
    required this.warmingTrendCPerDecade,
    required this.trendDescription,
  });

  factory ClimateTrendModel.fromJson(Map<String, dynamic> json) {
    return ClimateTrendModel(
      locationName: json['location_name'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      startYear: json['start_year'] ?? 2018,
      endYear: json['end_year'] ?? 2024,
      multiYearStats: (json['multi_year_stats'] as List<dynamic>? ?? [])
          .map((e) => YearlyClimateStatsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      averageAnnualRainfallMm: (json['average_annual_rainfall_mm'] as num?)?.toDouble() ?? 0.0,
      rainfallTrendSlope: (json['rainfall_trend_slope'] as num?)?.toDouble() ?? 0.0,
      warmingTrendCPerDecade: (json['warming_trend_c_per_decade'] as num?)?.toDouble() ?? 0.0,
      trendDescription: json['trend_description'] ?? '',
    );
  }
}
