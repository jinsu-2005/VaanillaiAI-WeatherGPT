import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vaanilaiai/models/weather_model.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/screens/heat_stress_screen.dart';
import 'package:vaanilaiai/utils/heat_stress_calculator.dart';

void main() {
  group('HeatStressCalculator Unit Tests', () {
    test('Low / Normal thermal conditions test', () {
      final res = HeatStressCalculator.calculate(
        temperatureC: 22.0,
        humidityPercent: 50,
      );

      expect(res.category, HeatStressCategory.low);
      expect(res.categoryName, 'Low Stress');
      expect(res.heatIndex, closeTo(22.0, 0.5));
      expect(res.wetBulbTemperature, lessThan(18.0));
      expect(res.workRestGuidance, contains('Normal work schedule'));
    });

    test('Caution level thermal stress test', () {
      final res = HeatStressCalculator.calculate(
        temperatureC: 30.0,
        humidityPercent: 60,
      );

      expect(res.category, HeatStressCategory.caution);
      expect(res.categoryName, 'Caution');
      expect(res.heatIndex, greaterThan(32.0));
      expect(res.heatIndex, lessThan(41.0));
      expect(res.workRestGuidance, contains('45 minutes work'));
    });

    test('Extreme Caution level thermal stress test', () {
      final res = HeatStressCalculator.calculate(
        temperatureC: 34.0,
        humidityPercent: 70,
      );

      expect(res.category, HeatStressCategory.extremeCaution);
      expect(res.categoryName, 'Extreme Caution');
      expect(res.heatIndex, greaterThan(41.0));
      expect(res.workRestGuidance, contains('30 minutes work'));
      expect(res.advisory, contains('10 AM'));
    });

    test('Danger level thermal stress test', () {
      final res = HeatStressCalculator.calculate(
        temperatureC: 43.0,
        humidityPercent: 65,
      );

      expect(res.category, HeatStressCategory.danger);
      expect(res.categoryName, 'Danger');
      expect(res.heatIndex, greaterThanOrEqualTo(54.0));
      expect(res.workRestGuidance, contains('Suspend direct sun labor'));
    });

    test('Stull Wet-Bulb formula produces physically consistent results', () {
      // At 100% RH, wet-bulb temp must equal dry-bulb air temperature
      final res100 = HeatStressCalculator.calculate(
        temperatureC: 30.0,
        humidityPercent: 100,
      );
      expect(res100.wetBulbTemperature, closeTo(30.0, 1.0));

      // At low RH, wet-bulb must be significantly lower than dry-bulb
      final resLow = HeatStressCalculator.calculate(
        temperatureC: 35.0,
        humidityPercent: 20,
      );
      expect(resLow.wetBulbTemperature, lessThan(20.0));
    });
  });

  group('HeatStressScreen Widget Tests', () {
    testWidgets('Renders thermal unavailable state when forecast is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<WeatherProvider>(
            create: (_) => _MockWeatherProvider(forecast: null),
            child: const HeatStressScreen(),
          ),
        ),
      );

      expect(find.text('Thermal Data Unavailable'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.whatshot_rounded), findsOneWidget);
    });

    testWidgets('Renders full heat stress metrics, gauges, and safety directives', (tester) async {
      final sampleForecast = WeatherForecastModel(
        locationName: 'Madurai',
        latitude: 9.9252,
        longitude: 78.1198,
        dataSource: 'live',
        lastFetchedAt: DateTime.now(),
        current: CurrentWeatherModel(
          temperature: 35.0,
          feelsLike: 42.0,
          humidity: 65,
          windSpeed: 12.0,
          windDirection: 200,
          pressure: 1010.0,
          precipitation: 0.0,
          rain: 0.0,
          cloudCover: 10,
          visibility: 10.0,
          uvIndex: 8.0,
          weatherCode: 1,
          conditionText: 'Mainly clear',
          conditionIcon: 'sunny',
          isDay: true,
          provenance: WeatherProvenanceModel(
            sourceType: 'NWP_MODEL',
            providerName: 'Open-Meteo',
            modelResolution: '2.0km',
            forecastConfidence: 0.95,
            lastUpdated: '2026-09-11 12:00',
          ),
        ),
        hourly: [
          HourlyForecastModel(
            time: '2026-09-11T12:00',
            temperature: 36.0,
            feelsLike: 44.0,
            precipitationProbability: 10,
            precipitation: 0.0,
            rain: 0.0,
            weatherCode: 1,
            conditionText: 'Clear',
            conditionIcon: 'sunny',
            windSpeed: 10.0,
            windDirection: 180,
            humidity: 60,
            uvIndex: 9.0,
            isDay: true,
          ),
          HourlyForecastModel(
            time: '2026-09-11T13:00',
            temperature: 37.0,
            feelsLike: 46.0,
            precipitationProbability: 10,
            precipitation: 0.0,
            rain: 0.0,
            weatherCode: 1,
            conditionText: 'Clear',
            conditionIcon: 'sunny',
            windSpeed: 10.0,
            windDirection: 180,
            humidity: 55,
            uvIndex: 9.0,
            isDay: true,
          ),
        ],
        daily: [],
        activeWarnings: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<WeatherProvider>(
            create: (_) => _MockWeatherProvider(forecast: sampleForecast),
            child: const HeatStressScreen(),
          ),
        ),
      );

      expect(find.text('HEAT INDEX'), findsOneWidget);
      expect(find.text('WET-BULB TEMP'), findsOneWidget);
      expect(find.text('FIELD & LABOR SAFETY DIRECTIVES'), findsOneWidget);
      expect(find.text('Work / Rest Interval'), findsOneWidget);
      expect(find.text('Hourly Hydration Target'), findsOneWidget);
      expect(find.text('HEAT ILLNESS FIRST-AID PROTOCOL'), findsOneWidget);
      expect(find.text('HOURLY HEAT STRESS OUTLOOK (24H)'), findsOneWidget);
    });
  });
}

class _MockWeatherProvider extends WeatherProvider {
  final WeatherForecastModel? _mockForecast;
  _MockWeatherProvider({WeatherForecastModel? forecast}) : _mockForecast = forecast;

  @override
  WeatherForecastModel? get forecast => _mockForecast;

  @override
  bool get isLoading => false;

  @override
  String get locationName => 'Madurai';

  @override
  Future<void> fetchWeather({bool forceRefresh = false}) async {}
}
