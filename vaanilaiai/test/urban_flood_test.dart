import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vaanilaiai/models/weather_model.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/screens/urban_flood_screen.dart';
import 'package:vaanilaiai/utils/urban_flood_calculator.dart';

void main() {
  group('UrbanFloodCalculator Unit Tests', () {
    test('Dry / Low rain conditions produce Low Risk', () {
      final res = UrbanFloodCalculator.calculate(
        peakHourlyRainMm: 0.0,
        threeHourCumulativeMm: 0.0,
      );

      expect(res.riskScore, 0);
      expect(res.tier, UrbanFloodRiskTier.low);
      expect(res.tierName, 'Low Risk');
      expect(res.estimatedWaterDepthInches, 0.0);
      expect(res.underpassStatus, contains('Open'));
      expect(res.drainSurplusMmPerHour, 0.0);
    });

    test('Moderate rain triggers Moderate Risk', () {
      final res = UrbanFloodCalculator.calculate(
        peakHourlyRainMm: 15.0,
        threeHourCumulativeMm: 25.0,
      );

      expect(res.tier, UrbanFloodRiskTier.moderate);
      expect(res.riskScore, greaterThanOrEqualTo(26));
      expect(res.riskScore, lessThanOrEqualTo(50));
      expect(res.underpassStatus, contains('Caution'));
      expect(res.estimatedWaterDepthInches, greaterThan(0.0));
      expect(res.estimatedWaterDepthInches, lessThanOrEqualTo(2.5));
    });

    test('Intense downpour exceeding drain capacity triggers High Risk', () {
      final res = UrbanFloodCalculator.calculate(
        peakHourlyRainMm: 35.0,
        threeHourCumulativeMm: 50.0,
      );

      expect(res.tier, UrbanFloodRiskTier.high);
      expect(res.riskScore, greaterThanOrEqualTo(51));
      expect(res.riskScore, lessThanOrEqualTo(75));
      expect(res.underpassStatus, contains('Flooding'));
      expect(res.estimatedWaterDepthInches, greaterThanOrEqualTo(2.5));
      expect(res.twoWheelerDirective, contains('HAZARD'));
    });

    test('Cloudburst / Extreme torrential rain triggers Severe Inundation Hazard', () {
      final res = UrbanFloodCalculator.calculate(
        peakHourlyRainMm: 65.0,
        threeHourCumulativeMm: 120.0,
      );

      expect(res.tier, UrbanFloodRiskTier.severe);
      expect(res.riskScore, greaterThanOrEqualTo(76));
      expect(res.underpassStatus, contains('Submerged'));
      expect(res.estimatedWaterDepthInches, greaterThanOrEqualTo(6.0));
      expect(res.twoWheelerDirective, contains('DO NOT RIDE'));
      expect(res.pedestrianDirective, contains('ELECTRICAL HAZARD'));
    });

    test('Rational Method: Higher impervious ratio increases runoff surplus', () {
      final resDense = UrbanFloodCalculator.calculate(
        peakHourlyRainMm: 30.0,
        threeHourCumulativeMm: 40.0,
        imperviousSurfaceRatio: 0.85, // Dense urban
      );

      final resGreen = UrbanFloodCalculator.calculate(
        peakHourlyRainMm: 30.0,
        threeHourCumulativeMm: 40.0,
        imperviousSurfaceRatio: 0.40, // Peri-urban green
      );

      expect(resDense.runoffRateMmPerHour, greaterThan(resGreen.runoffRateMmPerHour));
      expect(resDense.riskScore, greaterThan(resGreen.riskScore));
    });

    test('Hourly timeline calculation generates correct point count and values', () {
      final hourlyMock = List.generate(
        12,
        (i) => HourlyForecastModel(
          time: '2026-09-12T${i.toString().padLeft(2, '0')}:00',
          temperature: 28.0,
          feelsLike: 30.0,
          precipitationProbability: 80,
          precipitation: i * 3.0,
          rain: i * 3.0,
          weatherCode: 61,
          conditionText: 'Rain',
          conditionIcon: 'rain',
          windSpeed: 10.0,
          windDirection: 180,
          humidity: 85,
          uvIndex: 2.0,
          isDay: true,
        ),
      );

      final timeline = UrbanFloodCalculator.calculateHourlyTimeline(hourlyMock);
      expect(timeline.length, 12);
      expect(timeline[0].tier, UrbanFloodRiskTier.low);
      expect(timeline[0].riskScore, lessThanOrEqualTo(5));
      expect(timeline.last.riskScore, greaterThan(50)); // later hours have heavy rain
    });
  });

  group('UrbanFloodScreen Widget Tests', () {
    testWidgets('Renders unavailable state when forecast is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<WeatherProvider>(
            create: (_) => _MockFloodWeatherProvider(null),
            child: const UrbanFloodScreen(),
          ),
        ),
      );

      expect(find.text('Urban Flood & Inundation Index'), findsOneWidget);
      expect(find.text('Weather telemetry unavailable for waterlogging computation.'), findsOneWidget);
      expect(find.text('Retry Fetch'), findsOneWidget);
    });

    testWidgets('Renders full inundation metrics, gauges, and safety directives', (WidgetTester tester) async {
      final sampleForecast = WeatherForecastModel(
        locationName: 'Chennai Central',
        latitude: 13.0827,
        longitude: 80.2707,
        elevation: 10.0,
        current: CurrentWeatherModel(
          temperature: 29.0,
          feelsLike: 33.0,
          weatherCode: 65,
          conditionText: 'Heavy Rain',
          conditionIcon: 'rain',
          humidity: 90,
          windSpeed: 22.0,
          windDirection: 80,
          pressure: 1008.0,
          uvIndex: 2.0,
          precipitation: 28.0,
          rain: 28.0,
          cloudCover: 90,
          visibility: 5.0,
          isDay: true,
          provenance: WeatherProvenanceModel(
            sourceType: 'NWP_MODEL',
            providerName: 'Open-Meteo',
            modelResolution: '2.0km',
            forecastConfidence: 0.95,
            lastUpdated: '2026-09-12 10:00',
          ),
        ),
        hourly: [
          HourlyForecastModel(
            time: '2026-09-12T10:00',
            temperature: 29.0,
            feelsLike: 33.0,
            precipitationProbability: 95,
            precipitation: 28.0,
            rain: 28.0,
            weatherCode: 65,
            conditionText: 'Heavy Rain',
            conditionIcon: 'rain',
            windSpeed: 22.0,
            windDirection: 80,
            humidity: 90,
            uvIndex: 2.0,
            isDay: true,
          ),
          HourlyForecastModel(
            time: '2026-09-12T11:00',
            temperature: 28.5,
            feelsLike: 32.0,
            precipitationProbability: 90,
            precipitation: 22.0,
            rain: 22.0,
            weatherCode: 63,
            conditionText: 'Moderate Rain',
            conditionIcon: 'rain',
            windSpeed: 20.0,
            windDirection: 80,
            humidity: 92,
            uvIndex: 2.0,
            isDay: true,
          ),
        ],
        daily: [],
        activeWarnings: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<WeatherProvider>(
            create: (_) => _MockFloodWeatherProvider(sampleForecast),
            child: const UrbanFloodScreen(),
          ),
        ),
      );

      expect(find.text('Urban Flood & Inundation Index'), findsOneWidget);
      expect(find.text('INUNDATION RISK SCORE'), findsOneWidget);
      expect(find.text('EST. WATER DEPTH'), findsOneWidget);
      expect(find.text('PEAK RAIN RATE'), findsOneWidget);
      expect(find.text('DRAIN SURPLUS'), findsOneWidget);
      expect(find.text('Critical Infrastructure Vulnerability'), findsOneWidget);
      expect(find.text('Commuter & Transit Directives'), findsOneWidget);
      expect(find.text('Two-Wheelers & Scooters'), findsOneWidget);
      expect(find.text('Cars & Cabs'), findsOneWidget);
      expect(find.text('Pedestrians & Electrical Safety'), findsOneWidget);
      expect(find.text('24-Hour Street Waterlogging Outlook'), findsOneWidget);
      expect(find.text('Witness Waterlogging or Flooding?'), findsOneWidget);
    });
  });
}

class _MockFloodWeatherProvider extends WeatherProvider {
  final WeatherForecastModel? _mockForecast;
  _MockFloodWeatherProvider(this._mockForecast);

  @override
  WeatherForecastModel? get forecast => _mockForecast;

  @override
  bool get isLoading => false;

  @override
  String get locationName => 'Chennai Central';

  @override
  Future<void> fetchWeather({bool forceRefresh = false}) async {}
}
