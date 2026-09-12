import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaanilaiai/models/safar_model.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/screens/air_quality_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SAFAR Air Quality Model Unit Tests', () {
    test('PollutantMetricModel parses JSON and serializes correctly', () {
      final json = {
        'pollutant_code': 'pm2_5',
        'name': 'PM2.5 (Fine Particles)',
        'concentration': 88.0,
        'unit': 'µg/m³',
        'cpcb_sub_index': 193,
        'sub_index_category': 'Moderate',
        'cpcb_safe_limit': 60.0,
        'is_dominant_pollutant': true,
      };

      final model = PollutantMetricModel.fromJson(json);
      expect(model.pollutantCode, 'pm2_5');
      expect(model.concentration, 88.0);
      expect(model.cpcbSubIndex, 193);
      expect(model.subIndexCategory, 'Moderate');
      expect(model.isDominantPollutant, isTrue);

      final exported = model.toJson();
      expect(exported['pollutant_code'], 'pm2_5');
      expect(exported['cpcb_sub_index'], 193);
      expect(exported['is_dominant_pollutant'], isTrue);
    });

    test('AtmosphericDispersionModel and StubbleBiomassSmokeModel serialization', () {
      final dispJson = {
        'mixing_layer_height_m': 480.0,
        'surface_wind_speed_kmh': 8.5,
        'ventilation_coefficient_m2s': 1133.3,
        'dispersion_category': 'Critical',
        'inversion_risk': 'Severe Night Inversion',
        'physical_dispersion_summary': 'Shallow mixing layer prevents dilution.',
      };

      final disp = AtmosphericDispersionModel.fromJson(dispJson);
      expect(disp.mixingLayerHeightM, 480.0);
      expect(disp.surfaceWindSpeedKmh, 8.5);
      expect(disp.ventilationCoefficientM2s, 1133.3);
      expect(disp.dispersionCategory, 'Critical');
      expect(disp.inversionRisk, 'Severe Night Inversion');

      final exportedDisp = disp.toJson();
      expect(exportedDisp['ventilation_coefficient_m2s'], 1133.3);

      final stubbleJson = {
        'active_fire_count_regional': 142,
        'fire_radiative_power_mw': 380.0,
        'transport_wind_direction': 'North-Westerly',
        'transboundary_pm25_contribution_pct': 22.5,
        'agrarian_smoke_impact_level': 'High',
      };

      final stubble = StubbleBiomassSmokeModel.fromJson(stubbleJson);
      expect(stubble.activeFireCountRegional, 142);
      expect(stubble.fireRadiativePowerMw, 380.0);
      expect(stubble.transboundaryPm25ContributionPct, 22.5);
      expect(stubble.agrarianSmokeImpactLevel, 'High');

      final exportedStubble = stubble.toJson();
      expect(exportedStubble['active_fire_count_regional'], 142);
    });

    test('SafarAirQualityModel.defaultFallback provides valid complete baseline', () {
      final fallback = SafarAirQualityModel.defaultFallback(
        latitude: 28.6139,
        longitude: 77.2090,
        locationName: 'New Delhi',
        cityCode: 'delhi',
      );

      expect(fallback.overallAqi, 193);
      expect(fallback.cpcbCategory, 'Moderate');
      expect(fallback.dominantPollutant, 'PM2.5');
      expect(fallback.pollutants.length, 6);
      expect(fallback.pollutants.any((p) => p.isDominantPollutant), isTrue);
      expect(fallback.atmosphericDispersion.mixingLayerHeightM, greaterThan(0));
      expect(fallback.stubbleBiomassSmoke.activeFireCountRegional, greaterThan(0));
      expect(fallback.aqiForecast.length, 2);
      expect(fallback.demographicAdvisories.length, greaterThanOrEqualTo(4));
      expect(fallback.vernacularHealthGuidance, contains('ta'));
      expect(fallback.vernacularHealthGuidance, contains('hi'));
      expect(fallback.vernacularHealthGuidance, contains('pa'));
      expect(fallback.vernacularHealthGuidance, contains('bn'));
      expect(fallback.monitoringStations, isNotEmpty);
    });
  });

  group('AirQualityScreen Widget Tests with SAFAR Intelligence', () {
    testWidgets('Renders SAFAR hero dial, dispersion HUD, 6 pollutants, and demographic guidance',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final weatherProvider = WeatherProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: weatherProvider),
          ],
          child: const MaterialApp(
            home: AirQualityScreen(initialCityCode: 'delhi'),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify Header and Screen Title
      expect(find.text('Air Quality & Atmospheric Dispersion'), findsOneWidget);
      expect(find.text('SAFAR METRO AIR SHED HUBS'), findsOneWidget);

      // Verify Hero Gauge Elements
      expect(find.text('CPCB NAQI'), findsOneWidget);
      expect(find.textContaining('Dominant:'), findsOneWidget);
      expect(find.text('NAQI NATIONAL SCALE'), findsOneWidget);

      // Verify Atmospheric Dispersion HUD
      expect(find.text('Atmospheric Boundary Layer Dispersion'), findsOneWidget);
      expect(find.text('Mixing Height'), findsOneWidget);
      expect(find.text('Surface Winds'), findsOneWidget);
      expect(find.text('Ventilation Index'), findsOneWidget);

      // Verify 6-Pollutant Spectrum
      expect(find.text('CPCB 6-POLLUTANT SPECTRUM'), findsOneWidget);
      expect(find.text('PM2.5'), findsOneWidget);
      expect(find.text('PM10'), findsOneWidget);
      expect(find.text('Nitrogen'), findsOneWidget);
      expect(find.text('Sulfur'), findsOneWidget);
      expect(find.text('Carbon'), findsOneWidget);
      expect(find.text('Surface'), findsOneWidget);

      // Verify Biomass & Stubble Fire Tracking
      expect(find.text('Biomass & Stubble Fire Tracking'), findsOneWidget);
      expect(find.text('Active Fires'), findsOneWidget);

      // Verify 72-Hour Forecast
      expect(find.text('SAFAR 72-Hour AQI Trend Forecast'), findsOneWidget);
      expect(find.text('Tomorrow'), findsOneWidget);

      // Verify Demographic Advisories & Multilingual Guidance
      expect(find.text('Demographic Health Advisories'), findsOneWidget);
      expect(find.text('தமிழ்'), findsOneWidget);
      expect(find.text('हिन्दी'), findsOneWidget);
      expect(find.text('ਪੰਜਾਬੀ'), findsOneWidget);

      // Tap Tamil language toggle and verify vernacular advice
      await tester.tap(find.text('தமிழ்'));
      await tester.pumpAndSettle();
      expect(find.textContaining('காற்றுத் தரக் குறியீடு'), findsOneWidget);

      // Tap Hindi language toggle and verify vernacular advice
      await tester.tap(find.text('हिन्दी'));
      await tester.pumpAndSettle();
      expect(find.textContaining('वायु गुणवत्ता परामर्श'), findsOneWidget);
    });

    testWidgets('Switches SAFAR metro hub to Mumbai via metro chips', (tester) async {
      tester.view.physicalSize = const Size(1080, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final weatherProvider = WeatherProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: weatherProvider),
          ],
          child: const MaterialApp(
            home: AirQualityScreen(initialCityCode: 'delhi'),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Tap Mumbai metro hub chip
      expect(find.text('Mumbai'), findsOneWidget);
      await tester.tap(find.text('Mumbai'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify Mumbai content updated
      expect(find.text('Air Quality & Atmospheric Dispersion'), findsOneWidget);
    });
  });
}
