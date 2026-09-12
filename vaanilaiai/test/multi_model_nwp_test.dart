import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaanilaiai/models/multi_model_nwp_model.dart';
import 'package:vaanilaiai/screens/multi_model_nwp_screen.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/models/weather_model.dart';

class _MockNwpWeatherProvider extends ChangeNotifier implements WeatherProvider {
  final WeatherForecastModel? _mockForecast;

  _MockNwpWeatherProvider(this._mockForecast);

  @override
  WeatherForecastModel? get forecast => _mockForecast;
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

final sampleJson = {

      'location_name': 'Chennai',
      'latitude': 13.0827,
      'longitude': 80.2707,
      'elevation': 14.0,
      'days_count': 3,
      'overall_confidence': 'High',
      'overall_summary': 'Strong multi-model agreement across ECMWF IFS, NOAA GFS, and DWD ICON.',
      'daily_comparisons': [
        {
          'date': '2026-09-12',
          'day_name': 'Saturday',
          'models': {
            'ecmwf_ifs025': {
              'model_id': 'ecmwf_ifs025',
              'model_name': 'ECMWF IFS (0.25°)',
              'agency': 'ECMWF (Europe)',
              'resolution_km': 25.0,
              'precipitation_mm': 12.0,
              'temperature_max': 34.0,
              'temperature_min': 26.0,
            },
            'gfs_seamless': {
              'model_id': 'gfs_seamless',
              'model_name': 'NOAA GFS (0.25°)',
              'agency': 'NOAA / NCEP (USA)',
              'resolution_km': 25.0,
              'precipitation_mm': 10.5,
              'temperature_max': 35.0,
              'temperature_min': 27.0,
            },
            'icon_seamless': {
              'model_id': 'icon_seamless',
              'model_name': 'DWD ICON (13km)',
              'agency': 'DWD (Germany)',
              'resolution_km': 13.0,
              'precipitation_mm': 14.0,
              'temperature_max': 33.5,
              'temperature_min': 25.5,
            },
          },
          'consensus_rain_mean_mm': 12.2,
          'consensus_rain_min_mm': 10.5,
          'consensus_rain_max_mm': 14.0,
          'rain_spread_mm': 3.5,
          'consensus_temp_max': 34.2,
          'consensus_temp_min': 26.2,
          'confidence': 'High',
          'divergence_note': 'Strong consensus across all three global models.',
        },
      ],
      'model_metadata': [
        {
          'model_id': 'ecmwf_ifs025',
          'full_name': 'ECMWF IFS',
          'agency': 'ECMWF',
          'country': 'Europe',
          'resolution': '25 km',
          'primary_strength': 'Global gold standard for synoptic steering.',
        },
      ],
      'provenance': 'Open-Meteo Multi-Model Global NWP Ensemble API',
    };

void main() {
  group('MultiModelComparisonModel Unit Tests', () {
    test('Model deserializes from complete JSON accurately', () {
      final model = MultiModelComparisonModel.fromJson(sampleJson);

      expect(model.locationName, 'Chennai');
      expect(model.latitude, 13.0827);
      expect(model.elevation, 14.0);
      expect(model.daysCount, 3);
      expect(model.overallConfidence, 'High');
      expect(model.dailyComparisons.length, 1);

      final d = model.dailyComparisons.first;
      expect(d.dayName, 'Saturday');
      expect(d.consensusRainMeanMm, 12.2);
      expect(d.rainSpreadMm, 3.5);
      expect(d.models.containsKey('ecmwf_ifs025'), true);
      expect(d.models['ecmwf_ifs025']!.precipitationMm, 12.0);
      expect(d.models['gfs_seamless']!.temperatureMax, 35.0);
      expect(d.models['icon_seamless']!.resolutionKm, 13.0);

      expect(model.modelMetadata.length, 1);
      expect(model.modelMetadata.first.agency, 'ECMWF');
    });

    test('Roundtrip serialization preserves model integrity', () {
      final model = MultiModelComparisonModel.fromJson(sampleJson);
      final serialized = model.toJson();
      final roundtrip = MultiModelComparisonModel.fromJson(serialized);

      expect(roundtrip.locationName, model.locationName);
      expect(roundtrip.overallSummary, model.overallSummary);
      expect(roundtrip.dailyComparisons.first.models.length, 3);
    });

    test('Handles empty and fallback states safely', () {
      final emptyModel = MultiModelComparisonModel.fromJson({});
      expect(emptyModel.locationName, 'Location');
      expect(emptyModel.dailyComparisons, isEmpty);
      expect(emptyModel.overallConfidence, 'Moderate');

      final unavailable = MultiModelComparisonModel.unavailable('Bengaluru');
      expect(unavailable.dataUnavailable, true);
      expect(unavailable.overallConfidence, 'Unavailable');
      expect(unavailable.locationName, 'Bengaluru');
    });
  });

  group('MultiModelNwpScreen Widget Tests', () {
    testWidgets('Renders unavailable error state cleanly when data fails', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<WeatherProvider>(
            create: (_) => _MockNwpWeatherProvider(null),
            child: const MultiModelNwpScreen(),
          ),
        ),
      );

      // Initial pump
      await tester.pump();
      // Allow async future to settle
      await tester.pump(const Duration(seconds: 1));

      // Check for title in app bar
      expect(find.text('NWP Multi-Model Ensemble'), findsOneWidget);
    });

    testWidgets('Renders complete multi-model matrix and consensus details', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      SharedPreferences.setMockInitialValues({
        'nwp_comparison_13.08_80.27_5': json.encode(sampleJson),
      });

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<WeatherProvider>(
            create: (_) => _MockNwpWeatherProvider(null),
            child: const MultiModelNwpScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('NWP Multi-Model Ensemble'), findsOneWidget);
      expect(find.text('Chennai'), findsOneWidget);
      expect(find.text('High Consensus'), findsOneWidget);
      expect(find.text('ECMWF IFS'), findsAtLeast(1));
      expect(find.text('NOAA GFS'), findsOneWidget);
      expect(find.text('DWD ICON'), findsOneWidget);
      expect(find.text('Spread: 3.5 mm'), findsOneWidget);
      expect(find.text('Meteorological Divergence Insight'), findsOneWidget);
      expect(find.text('NWP Operational Models Guide'), findsOneWidget);
    });
  });
}

