import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vaanilaiai/models/weather_model.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/screens/air_quality_screen.dart';
import 'package:vaanilaiai/screens/rainfall_history_screen.dart';
import 'package:vaanilaiai/widgets/data_source_indicator.dart';

void main() {
  group('Weather Model & Freshness Tests', () {
    test('WeatherForecastModel default provenance and freshness metadata', () {
      final current = CurrentWeatherModel(
        temperature: 28.5,
        feelsLike: 31.0,
        humidity: 75,
        windSpeed: 14.0,
        windDirection: 180,
        windGusts: 20.0,
        pressure: 1012.0,
        precipitation: 0.0,
        rain: 0.0,
        cloudCover: 25,
        visibility: 10.0,
        uvIndex: 6.0,
        weatherCode: 1,
        conditionText: 'Mainly Clear',
        conditionIcon: 'mostly_sunny',
        isDay: true,
        provenance: WeatherProvenanceModel(
          sourceType: 'NWP_MODEL_ECMWF',
          providerName: 'Open-Meteo High-Resolution NWP',
          forecastConfidence: 0.9,
          modelResolution: '2.5km High-Resolution Grid',
          lastUpdated: '12:00',
        ),
      );

      final now = DateTime.now();
      final forecast = WeatherForecastModel(
        locationName: 'Nagercoil',
        district: 'Kanyakumari',
        state: 'Tamil Nadu',
        latitude: 8.1833,
        longitude: 77.4119,
        current: current,
        hourly: [],
        daily: [],
        airQuality: null, // Nullable AQI when data not available
        activeWarnings: [],
        lastFetchedAt: now,
        dataSource: 'live',
      );

      expect(forecast.locationName, 'Nagercoil');
      expect(forecast.airQuality, isNull);
      expect(forecast.dataSource, 'live');
      expect(forecast.lastFetchedAt, now);

      // Test copyWith updating dataSource to cached
      final cachedCopy = forecast.copyWith(dataSource: 'cached');
      expect(cachedCopy.dataSource, 'cached');
      expect(cachedCopy.locationName, 'Nagercoil');
      expect(cachedCopy.current.temperature, 28.5);

      // Test copyWith updating dataSource to stale
      final staleCopy = forecast.copyWith(dataSource: 'stale');
      expect(staleCopy.dataSource, 'stale');
    });

    test('AirQualityModel nullable deserialization safety', () {
      final jsonWithAqi = {
        'location_name': 'Nagercoil',
        'latitude': 8.18,
        'longitude': 77.41,
        'current': {
          'temperature_2m': 28.0,
          'relative_humidity_2m': 70,
          'weather_code': 0,
        },
        'hourly': [],
        'daily': [],
        'air_quality': null,
        'active_warnings': [],
        'data_source': 'forecast_model',
      };

      final model = WeatherForecastModel.fromJson(jsonWithAqi);
      expect(model.airQuality, isNull);
      expect(model.dataSource, 'forecast_model');
      expect(model.lastFetchedAt, isNotNull);
    });
  });

  group('DataSourceIndicator Widget Tests', () {
    testWidgets('Renders Live status with relative time', (tester) async {
      final now = DateTime.now();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataSourceIndicator(
              lastUpdated: now,
              dataSource: 'live',
            ),
          ),
        ),
      );

      expect(find.text('Updated Just now'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    });

    testWidgets('Renders Cached status', (tester) async {
      final twoMinAgo = DateTime.now().subtract(const Duration(minutes: 2));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataSourceIndicator(
              lastUpdated: twoMinAgo,
              dataSource: 'cached',
            ),
          ),
        ),
      );

      expect(find.text('Cached • 2m ago'), findsOneWidget);
      expect(find.byIcon(Icons.offline_pin_outlined), findsOneWidget);
    });

    testWidgets('Renders Stale/Saved data status with Retry action', (tester) async {
      bool retryPressed = false;
      final fiveMinAgo = DateTime.now().subtract(const Duration(minutes: 5));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataSourceIndicator(
              lastUpdated: fiveMinAgo,
              dataSource: 'stale',
              onRefresh: () {
                retryPressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Saved data • 5m ago'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retryPressed, isTrue);
    });

    testWidgets('Renders Unavailable status', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DataSourceIndicator(
              dataSource: 'unavailable',
            ),
          ),
        ),
      );

      expect(find.text('Unavailable'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });
  });

  group('AirQualityScreen Widget Tests', () {
    testWidgets('Renders honest unavailable state when AQI data is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<WeatherProvider>(
            create: (_) => _TestWeatherProvider(forecast: null),
            child: const AirQualityScreen(),
          ),
        ),
      );

      expect(find.text('Air Quality Data Unavailable'), findsOneWidget);
      expect(find.text('Check Again'), findsOneWidget);
      expect(find.byIcon(Icons.air_rounded), findsOneWidget);
    });
  });

  group('RainfallHistoryScreen Widget Tests', () {
    testWidgets('Renders honest unavailable state when forecast is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<WeatherProvider>(
            create: (_) => _TestWeatherProvider(forecast: null),
            child: const RainfallHistoryScreen(),
          ),
        ),
      );

      expect(find.text('Precipitation Forecast Unavailable'), findsOneWidget);
      expect(find.text('Refresh Forecast'), findsOneWidget);
      expect(find.byIcon(Icons.water_drop_outlined), findsOneWidget);
    });
  });
}

class _TestWeatherProvider extends WeatherProvider {
  final WeatherForecastModel? _customForecast;
  final bool _customLoading;
  _TestWeatherProvider({WeatherForecastModel? forecast, bool isLoading = false})
      : _customForecast = forecast,
        _customLoading = isLoading;

  @override
  WeatherForecastModel? get forecast => _customForecast;

  @override
  bool get isLoading => _customLoading;

  @override
  String get locationName => 'Nagercoil';

  @override
  Future<void> fetchWeather({bool forceRefresh = false}) async {}
}
