import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaanilaiai/models/cyclone_model.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/screens/cyclone_tracker_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('IMD Cyclone Tracker Model Tests', () {
    test('CycloneTrackerResponseModel parses valid JSON correctly', () {
      final json = {
        'basin_status': 'Active Cyclone Alert',
        'active_systems_count': 1,
        'selected_system': {
          'system_id': 'michaung-2023',
          'name': 'MICHAUNG',
          'basin': 'Bay of Bengal',
          'is_active': true,
          'warning_stage': 'Stage 3: Cyclone Warning',
          'stage_color_hex': '#D32F2F',
          'dvorak': {
            't_number': 4.0,
            'ci_number': 4.0,
            'central_pressure_hpa': 988.0,
            'pressure_deficit_hpa': 22.0,
            'max_sustained_wind_kt': 65.0,
            'max_sustained_wind_kmh': 120.0,
            'gust_speed_kmh': 145.0,
            'intensity_stage': 'Very Severe Cyclonic Storm (VSCS)',
            'intensity_code': 'VSCS',
          },
          'current_latitude': 14.2,
          'current_longitude': 80.3,
          'movement_direction': 'North-Northwest (NNW)',
          'movement_speed_kmh': 12.0,
          'distance_to_user_km': 130.0,
          'projected_landfall_location': 'South Andhra Pradesh Coast (Near Bapatla)',
          'projected_landfall_time': '05 Dec 2023, 11:30 IST',
          'landfall_eta_hours': 11.5,
          'track_points': [
            {
              'forecast_hour': 0,
              'timestamp_iso': '2023-12-04T18:00:00Z',
              'latitude': 14.2,
              'longitude': 80.3,
              'stage_code': 'VSCS',
              'stage_name': 'Very Severe Cyclonic Storm',
              'central_pressure_hpa': 988.0,
              'max_wind_kmh': 120.0,
              'status': 'Current',
              'cone_of_uncertainty_km': 25.0,
            }
          ],
          'gale_radii': {
            'radius_34kt_ne_km': 220.0,
            'radius_34kt_se_km': 180.0,
            'radius_34kt_sw_km': 130.0,
            'radius_34kt_nw_km': 160.0,
            'radius_50kt_ne_km': 110.0,
            'radius_50kt_se_km': 85.0,
            'radius_50kt_sw_km': 60.0,
            'radius_50kt_nw_km': 75.0,
            'radius_64kt_ne_km': 45.0,
            'radius_64kt_se_km': 35.0,
            'radius_64kt_sw_km': 25.0,
            'radius_64kt_nw_km': 30.0,
          },
          'storm_surge_forecasts': [
            {
              'coastal_district': 'Bapatla, Andhra Pradesh',
              'astronomical_tide_m': 0.9,
              'peak_surge_m': 1.6,
              'total_water_level_m': 2.5,
              'inland_inundation_km': 3.4,
              'surge_risk_tier': 'High',
              'surge_warning_note': 'Inundation of low lying coastal areas during landfall.',
            }
          ],
          'evacuation': {
            'red_zone_action': 'Mandatory evacuation to cyclone shelters.',
            'orange_zone_action': 'Move to pucca structures.',
            'yellow_zone_action': 'Secure loose items.',
            'port_warning_signal': 9,
            'port_signal_meaning': 'Great Danger Signal 9',
            'shelters_active_count': 214,
          },
          'vernacular_bulletin': {
            'en': 'IMD RSMC Alert: Severe Cyclonic Storm MICHAUNG.',
            'ta': 'இந்திய வானிலை மையம்: புயல் மிக்ஜாம் எச்சரிக்கை.',
          },
        },
        'available_systems': [],
        'nearest_system_distance_km': 130.0,
        'basin_readiness_summary': 'Basin active vigilance.',
        'rsmc_bulletin_no': 'RSMC/NIO/CYC-01',
        'issued_at': '2026-09-12T00:00:00Z',
        'authority_disclaimer': 'RSMC New Delhi / IMD MoES',
      };

      final model = CycloneTrackerResponseModel.fromJson(json);
      expect(model.basinStatus, 'Active Cyclone Alert');
      expect(model.selectedSystem.name, 'MICHAUNG');
      expect(model.selectedSystem.dvorak.tNumber, 4.0);
      expect(model.selectedSystem.dvorak.pressureDeficitHpa, 22.0);
      expect(model.selectedSystem.galeRadii.radius34ktNeKm, 220.0);
      expect(model.selectedSystem.stormSurgeForecasts.first.totalWaterLevelM, 2.5);
      expect(model.selectedSystem.evacuation.portWarningSignal, 9);
      expect(model.isOfflineCached, false);

      // Verify toJson roundtrip
      final serialized = model.toJson();
      expect(serialized['basin_status'], 'Active Cyclone Alert');
      expect(serialized['selected_system']['name'], 'MICHAUNG');
    });

    test('defaultFallback provides complete calibrated data for offline disaster resilience', () {
      final fallback = CycloneTrackerResponseModel.defaultFallback();
      expect(fallback.isOfflineCached, true);
      expect(fallback.selectedSystem.name, 'MICHAUNG');
      expect(fallback.selectedSystem.dvorak.tNumber, 4.0);
      expect(fallback.selectedSystem.trackPoints.length, greaterThanOrEqualTo(3));
      expect(fallback.selectedSystem.stormSurgeForecasts.isNotEmpty, true);
      expect(fallback.selectedSystem.evacuation.sheltersActiveCount, greaterThan(0));
      expect(fallback.selectedSystem.vernacularBulletin.containsKey('ta'), true);
      expect(fallback.selectedSystem.vernacularBulletin.containsKey('hi'), true);
      expect(fallback.selectedSystem.vernacularBulletin.containsKey('bn'), true);
      expect(fallback.selectedSystem.vernacularBulletin.containsKey('or'), true);
    });
  });

  group('CycloneTrackerScreen Widget Tests', () {
    testWidgets('Renders CycloneTrackerScreen with intensity card, Dvorak dial, surge, and evacuation directives', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final weatherProvider = WeatherProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WeatherProvider>.value(value: weatherProvider),
          ],
          child: const MaterialApp(
            home: CycloneTrackerScreen(),
          ),
        ),
      );

      // Initial loading
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Check AppBar
      expect(find.text('IMD Cyclone Tracker'), findsOneWidget);
      expect(find.text('RSMC New Delhi • North Indian Ocean'), findsOneWidget);

      // Check Hero Card elements
      expect(find.text('CYCLONE MICHAUNG'), findsOneWidget);
      expect(find.text('T4.0'), findsOneWidget);
      expect(find.text('CI 4.0'), findsOneWidget);

      // Check Central Pressure Deficit and Sustained Wind
      expect(find.text('Central Deficit (ΔP)'), findsOneWidget);
      expect(find.text('Max Sustained'), findsOneWidget);

      // Check Landfall & Storm Surge
      expect(find.text('Landfall Trajectory & Geodetic Proximity'), findsOneWidget);
      expect(find.text('Coastal Storm Surge & Inundation Projections'), findsOneWidget);

      // Check Gale Wind Radii
      expect(find.text('Gale Wind Radii Quadrant Extents (km)'), findsOneWidget);

      // Check Evacuation & Port Signal
      expect(find.text('NDMA Coastal Evacuation Directives'), findsOneWidget);
      expect(find.text('PORT SIGNAL 9'), findsOneWidget);

      // Check Vernacular Broadcast & Language Toggle
      expect(find.text('Vernacular Emergency Broadcast'), findsOneWidget);
      expect(find.text('தமிழ்'), findsOneWidget);
      expect(find.text('हिंदी'), findsOneWidget);
    });

    testWidgets('Tapping vernacular language chip updates emergency bulletin text', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final weatherProvider = WeatherProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WeatherProvider>.value(value: weatherProvider),
          ],
          child: const MaterialApp(
            home: CycloneTrackerScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Initially in English
      expect(find.textContaining('IMD RSMC Alert'), findsWidgets);

      // Tap Tamil chip
      final tamilChip = find.text('தமிழ்');
      expect(tamilChip, findsOneWidget);
      await tester.tap(tamilChip);
      await tester.pumpAndSettle();

      // Should now render Tamil emergency bulletin
      expect(find.textContaining('இந்திய வானிலை மையம்'), findsOneWidget);
    });
  });
}
