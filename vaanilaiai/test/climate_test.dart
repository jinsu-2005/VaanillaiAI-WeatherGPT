import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vaanilaiai/models/climate_model.dart';
import 'package:vaanilaiai/providers/climate_provider.dart';
import 'package:vaanilaiai/providers/locale_provider.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/models/weather_model.dart';
import 'package:vaanilaiai/screens/climate_screen.dart';

class _MockClimateWeatherProvider extends ChangeNotifier implements WeatherProvider {
  @override
  WeatherForecastModel? get forecast => null;
  @override
  bool get isLoading => false;
  @override
  String? get errorMessage => null;
  @override
  String get locationName => 'Chennai';
  @override
  double get latitude => 13.0827;
  @override
  double get longitude => 80.2707;
  @override
  String? get district => 'Chennai';
  @override
  String? get state => 'Tamil Nadu';
  @override
  DateTime? get lastFetchedAt => DateTime.now();
  @override
  bool get isStale => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockClimateProvider extends ChangeNotifier implements ClimateProvider {
  final ClimateComparisonModel? _mockComparison;
  final ClimateTrendModel? _mockTrends;
  final bool _mockLoading;

  _MockClimateProvider({
    ClimateComparisonModel? comparison,
    ClimateTrendModel? trends,
    bool loading = false,
  })  : _mockComparison = comparison,
        _mockTrends = trends,
        _mockLoading = loading;

  @override
  ClimateComparisonModel? get comparison => _mockComparison;
  @override
  ClimateTrendModel? get trends => _mockTrends;
  @override
  bool get isLoading => _mockLoading;
  @override
  String? get errorMessage => null;
  @override
  int get year1 => _mockComparison?.year1 ?? 2022;
  @override
  int get year2 => _mockComparison?.year2 ?? 2023;

  @override
  Future<void> fetchClimateData({
    required double latitude,
    required double longitude,
    String locationName = 'Location',
    int? year1,
    int? year2,
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Climate Models Unit Tests', () {
    final sampleComparisonJson = {
      'location_name': 'Chennai',
      'latitude': 13.0827,
      'longitude': 80.2707,
      'year_1': 2022,
      'year_2': 2023,
      'year_1_stats': {
        'year': 2022,
        'annual_rainfall_mm': 1250.4,
        'annual_mean_temp_c': 28.6,
        'max_temp_recorded_c': 41.2,
        'min_temp_recorded_c': 20.4,
        'monthly_stats': [
          {
            'month_name': 'January',
            'month_index': 1,
            'avg_temperature_c': 25.1,
            'total_rainfall_mm': 12.0,
            'rainy_days_count': 1,
          },
        ],
      },
      'year_2_stats': {
        'year': 2023,
        'annual_rainfall_mm': 1390.8,
        'annual_mean_temp_c': 29.1,
        'max_temp_recorded_c': 42.0,
        'min_temp_recorded_c': 21.0,
        'monthly_stats': [
          {
            'month_name': 'January',
            'month_index': 1,
            'avg_temperature_c': 25.8,
            'total_rainfall_mm': 8.5,
            'rainy_days_count': 1,
          },
        ],
      },
      'rainfall_difference_mm': 140.4,
      'rainfall_change_percent': 11.2,
      'temperature_difference_c': 0.5,
      'climate_summary': 'Rainfall increased by 140.4 mm (11.2%) while mean temperature rose by 0.50°C.',
    };

    final sampleTrendsJson = {
      'location_name': 'Chennai',
      'latitude': 13.0827,
      'longitude': 80.2707,
      'start_year': 2018,
      'end_year': 2024,
      'multi_year_stats': [
        {
          'year': 2018,
          'annual_rainfall_mm': 1100.0,
          'annual_mean_temp_c': 28.2,
          'max_temp_recorded_c': 40.5,
          'min_temp_recorded_c': 19.8,
          'monthly_stats': [],
        },
        {
          'year': 2021,
          'annual_rainfall_mm': 1280.0,
          'annual_mean_temp_c': 28.7,
          'max_temp_recorded_c': 41.0,
          'min_temp_recorded_c': 20.2,
          'monthly_stats': [],
        },
        {
          'year': 2024,
          'annual_rainfall_mm': 1350.0,
          'annual_mean_temp_c': 29.3,
          'max_temp_recorded_c': 42.5,
          'min_temp_recorded_c': 21.5,
          'monthly_stats': [],
        },
      ],
      'average_annual_rainfall_mm': 1243.3,
      'rainfall_trend_slope': 41.6,
      'warming_trend_c_per_decade': 1.83,
      'trend_description': 'Warming rate of +1.83°C per decade with rainfall shifting upwards by 41.6 mm/year.',
    };

    test('ClimateComparisonModel deserializes and serializes accurately', () {
      final model = ClimateComparisonModel.fromJson(sampleComparisonJson, isOfflineCached: true);
      expect(model.locationName, 'Chennai');
      expect(model.year1, 2022);
      expect(model.year2, 2023);
      expect(model.rainfallDifferenceMm, 140.4);
      expect(model.temperatureDifferenceC, 0.5);
      expect(model.isOfflineCached, true);
      expect(model.year1Stats.monthlyStats.first.totalRainfallMm, 12.0);

      final serialized = model.toJson();
      expect(serialized['year_1'], 2022);
      expect(serialized['rainfall_difference_mm'], 140.4);
    });

    test('ClimateTrendModel deserializes and serializes accurately', () {
      final trends = ClimateTrendModel.fromJson(sampleTrendsJson, isOfflineCached: false);
      expect(trends.locationName, 'Chennai');
      expect(trends.startYear, 2018);
      expect(trends.endYear, 2024);
      expect(trends.multiYearStats.length, 3);
      expect(trends.warmingTrendCPerDecade, 1.83);
      expect(trends.isOfflineCached, false);

      final serialized = trends.toJson();
      expect(serialized['start_year'], 2018);
      expect(serialized['warming_trend_c_per_decade'], 1.83);
    });
  });

  group('ClimateScreen Widget Tests', () {
    testWidgets('Renders honest unavailable state when comparison is null', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WeatherProvider>(create: (_) => _MockClimateWeatherProvider()),
            ChangeNotifierProvider<ClimateProvider>(create: (_) => _MockClimateProvider(comparison: null)),
            ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),
          ],
          child: const MaterialApp(home: ClimateScreen()),
        ),
      );

      await tester.pump();
      expect(find.text('Historical Climate Records Unavailable'), findsOneWidget);
      expect(find.text('Retry Archive Connection'), findsOneWidget);
    });

    testWidgets('Renders complete climate intelligence dashboard when loaded', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));

      final comparison = ClimateComparisonModel.fromJson({
        'location_name': 'Chennai',
        'latitude': 13.0827,
        'longitude': 80.2707,
        'year_1': 2022,
        'year_2': 2023,
        'year_1_stats': {
          'year': 2022,
          'annual_rainfall_mm': 1250.0,
          'annual_mean_temp_c': 28.5,
          'max_temp_recorded_c': 41.0,
          'min_temp_recorded_c': 20.0,
          'monthly_stats': List.generate(
            12,
            (i) => {
              'month_name': 'Month $i',
              'month_index': i + 1,
              'avg_temperature_c': 28.0,
              'total_rainfall_mm': (i + 1) * 15.0,
              'rainy_days_count': 2,
            },
          ),
        },
        'year_2_stats': {
          'year': 2023,
          'annual_rainfall_mm': 1380.0,
          'annual_mean_temp_c': 29.0,
          'max_temp_recorded_c': 42.0,
          'min_temp_recorded_c': 21.0,
          'monthly_stats': List.generate(
            12,
            (i) => {
              'month_name': 'Month $i',
              'month_index': i + 1,
              'avg_temperature_c': 28.5,
              'total_rainfall_mm': (i + 1) * 18.0,
              'rainy_days_count': 3,
            },
          ),
        },
        'rainfall_difference_mm': 130.0,
        'rainfall_change_percent': 10.4,
        'temperature_difference_c': 0.5,
        'climate_summary': 'Year-on-year precipitation increase of 130mm with slight temperature warming.',
      }, isOfflineCached: true);

      final trends = ClimateTrendModel.fromJson({
        'location_name': 'Chennai',
        'latitude': 13.0827,
        'longitude': 80.2707,
        'start_year': 2018,
        'end_year': 2024,
        'multi_year_stats': [
          {
            'year': 2018,
            'annual_rainfall_mm': 1100.0,
            'annual_mean_temp_c': 28.2,
            'max_temp_recorded_c': 40.5,
            'min_temp_recorded_c': 19.8,
            'monthly_stats': [],
          },
          {
            'year': 2021,
            'annual_rainfall_mm': 1280.0,
            'annual_mean_temp_c': 28.7,
            'max_temp_recorded_c': 41.0,
            'min_temp_recorded_c': 20.2,
            'monthly_stats': [],
          },
          {
            'year': 2024,
            'annual_rainfall_mm': 1350.0,
            'annual_mean_temp_c': 29.3,
            'max_temp_recorded_c': 42.5,
            'min_temp_recorded_c': 21.5,
            'monthly_stats': [],
          },
        ],
        'average_annual_rainfall_mm': 1243.3,
        'rainfall_trend_slope': 41.6,
        'warming_trend_c_per_decade': 1.83,
        'trend_description': 'Warming rate of +1.83°C per decade.',
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WeatherProvider>(create: (_) => _MockClimateWeatherProvider()),
            ChangeNotifierProvider<ClimateProvider>(
              create: (_) => _MockClimateProvider(comparison: comparison, trends: trends),
            ),
            ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),
          ],
          child: const MaterialApp(home: ClimateScreen()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Chennai'), findsOneWidget);
      expect(find.text('2022 vs 2023'), findsOneWidget);
      expect(find.text('Rainfall Change'), findsOneWidget);
      expect(find.text('Mean Temp Diff'), findsOneWidget);
      expect(find.text('Monthly Rainfall Distribution'), findsOneWidget);
      expect(find.text('Multi-Year Climate Warming Trend'), findsOneWidget);
      expect(find.text('Warming Rate: +1.83 °C per decade'), findsOneWidget);
      expect(find.text('Offline Cached Archive Records (Reconnecting to refresh)'), findsOneWidget);
    });
  });
}
