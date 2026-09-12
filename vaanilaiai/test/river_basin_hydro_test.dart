import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaanilaiai/models/hydro_model.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/screens/river_basin_hydro_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CWC Hydro Model Unit Tests', () {
    test('RiverGaugeStationModel parses JSON and serializes back correctly', () {
      final json = {
        'station_code': 'cwc_ganga_varanasi',
        'name': 'Varanasi (Dashashwamedh Ghat)',
        'river': 'Ganga',
        'basin': 'Ganga',
        'state': 'Uttar Pradesh',
        'latitude': 25.3076,
        'longitude': 83.0104,
        'current_level_m': 70.85,
        'warning_level_m': 70.26,
        'danger_level_m': 71.26,
        'highest_flood_level_m': 73.90,
        'trend': 'Rising',
        'flood_stage': 'Warning',
        'distance_km': 2.4,
      };

      final model = RiverGaugeStationModel.fromJson(json);
      expect(model.stationCode, 'cwc_ganga_varanasi');
      expect(model.name, contains('Varanasi'));
      expect(model.river, 'Ganga');
      expect(model.currentLevelM, 70.85);
      expect(model.warningLevelM, 70.26);
      expect(model.dangerLevelM, 71.26);
      expect(model.trend, 'Rising');
      expect(model.floodStage, 'Warning');
      expect(model.distanceKm, 2.4);

      final exported = model.toJson();
      expect(exported['station_code'], 'cwc_ganga_varanasi');
      expect(exported['flood_stage'], 'Warning');
      expect(exported['current_level_m'], 70.85);
    });

    test('DamReservoirModel parses JSON and calculates storage metrics', () {
      final json = {
        'reservoir_code': 'dam_mettur',
        'name': 'Mettur Dam (Stanley Reservoir)',
        'river': 'Cauvery',
        'basin': 'Cauvery',
        'state': 'Tamil Nadu',
        'latitude': 11.8000,
        'longitude': 77.8000,
        'full_reservoir_level_m': 36.58,
        'current_level_m': 35.10,
        'live_storage_capacity_tmc': 93.47,
        'current_storage_tmc': 84.12,
        'storage_percent': 90.0,
        'inflow_cusecs': 42000.0,
        'outflow_cusecs': 38000.0,
        'spillway_gates_open': 8,
        'spillway_status': 'Heavy Inflow Spillage',
        'downstream_alert': 'Surplus flood release active. Avoid riverbed.',
        'distance_km': 150.0,
      };

      final dam = DamReservoirModel.fromJson(json);
      expect(dam.reservoirCode, 'dam_mettur');
      expect(dam.name, contains('Mettur Dam'));
      expect(dam.storagePercent, 90.0);
      expect(dam.spillwayGatesOpen, 8);
      expect(dam.spillwayStatus, 'Heavy Inflow Spillage');

      final exported = dam.toJson();
      expect(exported['storage_percent'], 90.0);
      expect(exported['spillway_gates_open'], 8);
    });

    test('CwcHydroOverviewModel.defaultFallback provides valid offline baseline', () {
      final fallback = CwcHydroOverviewModel.defaultFallback(
        latitude: 25.3076,
        longitude: 83.0104,
        locationName: 'Varanasi',
        basinName: 'Ganga',
      );

      expect(fallback.selectedBasin, 'Ganga');
      expect(fallback.isOfflineCached, isTrue);
      expect(fallback.nearestGaugeStation, isNotNull);
      expect(fallback.nearestReservoir, isNotNull);
      expect(fallback.gaugeStations, isNotEmpty);
      expect(fallback.reservoirs, isNotEmpty);
      expect(fallback.downstreamDirectives, isNotEmpty);
      expect(fallback.vernacularRiparianAlerts['hi'], isNotNull);
    });
  });

  group('RiverBasinHydroScreen Widget Tests', () {
    testWidgets('Renders CWC river basin telemetry screen with hydrograph and dam gauges', (tester) async {
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
            home: RiverBasinHydroScreen(
              initialLat: 25.3076,
              initialLon: 83.0104,
              initialLocationName: 'Varanasi',
              initialBasin: 'Ganga',
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Check AppBar Title
      expect(find.text('CWC River Basin & Dam Telemetry'), findsOneWidget);

      // Check Basin Summary Card
      expect(find.text('Ganga River Basin'), findsOneWidget);
      expect(find.text('Monitored Stations'), findsOneWidget);

      // Check Nearest Gauge Station
      expect(find.textContaining('Varanasi'), findsWidgets);
      expect(find.textContaining('Danger Mark:'), findsOneWidget);
      expect(find.textContaining('Warning Mark:'), findsOneWidget);

      // Check Nearest Dam Reservoir Card
      expect(find.textContaining('Tehri Dam'), findsWidgets);
      expect(find.text('Storage of FRL'), findsOneWidget);
      expect(find.text('Catchment Inflow'), findsOneWidget);

      // Check Downstream Riparian Directives
      expect(find.text('Downstream Riparian Directives'), findsOneWidget);
      expect(find.text('हिंदी'), findsOneWidget);
      expect(find.text('தமிழ்'), findsOneWidget);
      expect(find.text('বাংলা'), findsOneWidget);

      // Tap on Hindi language chip and verify vernacular update
      await tester.tap(find.text('हिंदी'));
      await tester.pumpAndSettle();
      expect(find.textContaining('बाढ़ चेतावनी'), findsOneWidget);

      // Tap on Tamil language chip and verify vernacular update
      await tester.tap(find.text('தமிழ்'));
      await tester.pumpAndSettle();
      expect(find.textContaining('ஆற்றுப்படுகை'), findsOneWidget);
    });

    testWidgets('Switches active river basin via basin chips', (tester) async {
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
            home: RiverBasinHydroScreen(
              initialLat: 25.3076,
              initialLon: 83.0104,
              initialLocationName: 'Varanasi',
              initialBasin: 'Ganga',
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify initial Ganga basin
      expect(find.text('Ganga River Basin'), findsOneWidget);

      // Tap on Cauvery basin chip
      await tester.tap(find.text('Cauvery'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify basin changes to Cauvery
      expect(find.text('Cauvery River Basin'), findsOneWidget);
    });
  });
}
