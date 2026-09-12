import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaanilaiai/models/marine_model.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/screens/marine_ocean_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('INCOIS Marine Model Serialization and Fallback Tests', () {
    test('MarineAdvisoryModel parses full INCOIS JSON payload correctly', () {
      final json = {
        'location_name': 'Chennai Marina',
        'coastal_region': 'Coromandel Coast',
        'coastal_sector_name': 'Tamil Nadu & South Andhra Coast',
        'is_coastal_location': true,
        'date': '2026-09-12',
        'sea_condition': 'Moderate (Swell Alert Active)',
        'sea_condition_color': 'Yellow',
        'significant_wave_height_m': 2.1,
        'swell_height_m': 1.9,
        'swell_period_seconds': 13.5,
        'swell_direction_cardinal': 'SSW',
        'kallakkadal_surge_risk': 'Warning',
        'kallakkadal_explanation': 'High-energy Southern Ocean swells arriving with 13.5s wave period.',
        'coastal_wind_knots': 18,
        'coastal_wind_kmh': 33.3,
        'wind_gusts_kmh': 45.0,
        'wind_direction_deg': 200,
        'wind_direction_cardinal': 'SSW',
        'sea_surface_temperature_c': 29.2,
        'chlorophyll_a_mg_m3': 2.1,
        'potential_fishing_zone_status': 'High Potential',
        'pfz_bearing_direction': '125° SE',
        'pfz_distance_nautical_miles': 14.5,
        'deep_sea_navigation_safe': true,
        'vessel_category_directives': {
          'catamarans_country_craft': 'Avoid shore launching during peak surge.',
          'motorized_frp_boats': 'Safe beyond 3 NM from shoreline.',
          'mechanized_trawlers': 'Normal operations permitted.',
        },
        'fishermen_warning_text': 'Southern Ocean swell alert in effect.',
        'vernacular_coastal_directives': {
          'ta': 'கள்ளக்கடல் எச்சரிக்கை: நாட்டுப்படகுகள் கடலுக்கு செல்ல வேண்டாம்.',
          'ml': 'കള്ളക്കടൽ മുന്നറിയിപ്പ്: ചെറിയ ബോട്ടുകൾ ജാഗ്രത പാലിക്കുക.',
          'hi': 'कल्लाक्कदल चेतावनी: छोटी नौकाएं सतर्क रहें।',
        },
        'port_warning_signal_number': 3,
        'port_warning_signal_name': 'Signal III - Local Cautionary',
        'port_warning_signal_description': 'Port is threatened by squally weather.',
        'tide_high_time': '02:30 PM',
        'tide_high_height_m': 1.65,
        'tide_low_time': '08:45 PM',
        'tide_low_height_m': 0.38,
        'official_authority': 'INCOIS & IMD Marine Division',
        'data_unavailable': false,
        'is_offline_cached': false,
      };

      final model = MarineAdvisoryModel.fromJson(json);

      expect(model.locationName, 'Chennai Marina');
      expect(model.coastalSectorName, 'Tamil Nadu & South Andhra Coast');
      expect(model.isCoastalLocation, isTrue);
      expect(model.significantWaveHeightM, 2.1);
      expect(model.swellHeightM, 1.9);
      expect(model.swellPeriodSeconds, 13.5);
      expect(model.kallakkadalSurgeRisk, 'Warning');
      expect(model.portWarningSignalNumber, 3);
      expect(model.portWarningSignalName, contains('Signal III'));
      expect(model.vesselCategoryDirectives['catamarans_country_craft'], contains('shore launching'));
      expect(model.vernacularCoastalDirectives['ta'], contains('கள்ளக்கடல்'));

      // Verify JSON serialization round-trip
      final exported = model.toJson();
      expect(exported['coastal_sector_name'], 'Tamil Nadu & South Andhra Coast');
      expect(exported['kallakkadal_surge_risk'], 'Warning');
      expect(exported['swell_period_seconds'], 13.5);
    });

    test('MarineAdvisoryModel.unavailable generates dataUnavailable flag', () {
      final unavail = MarineAdvisoryModel.unavailable('Bengaluru Urban');
      expect(unavail.dataUnavailable, isTrue);
      expect(unavail.seaCondition, 'Data Unavailable');
      expect(unavail.kallakkadalSurgeRisk, 'None');
    });

    test('MarineAdvisoryModel.defaultFallback generates calibrated coastal and inland baselines', () {
      final coastal = MarineAdvisoryModel.defaultFallback('Kochi Harbor', isCoastal: true);
      expect(coastal.isCoastalLocation, isTrue);
      expect(coastal.kallakkadalSurgeRisk, 'Watch');
      expect(coastal.swellPeriodSeconds, 12.8);
      expect(coastal.isOfflineCached, isTrue);
      expect(coastal.vesselCategoryDirectives, isNotEmpty);

      final inland = MarineAdvisoryModel.defaultFallback('New Delhi', isCoastal: false);
      expect(inland.isCoastalLocation, isFalse);
      expect(inland.significantWaveHeightM, 0.0);
      expect(inland.kallakkadalSurgeRisk, 'None');
      expect(inland.fishermenWarningText, contains('Inland territory'));
    });
  });

  group('MarineOceanScreen Widget Tests', () {
    testWidgets('Renders INCOIS Ocean State screen with Swell Surge and Fleet Directives', (tester) async {
      final weatherProvider = WeatherProvider();

      tester.view.physicalSize = const Size(1080, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: weatherProvider),
          ],
          child: const MaterialApp(
            home: MarineOceanScreen(
              initialLat: 13.0827,
              initialLon: 80.2707,
              initialLocationName: 'Chennai Marina',
            ),
          ),
        ),
      );

      // Wait for initial async fallback to populate
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Check AppBar
      expect(find.text('INCOIS Ocean & Marine State'), findsOneWidget);

      // Check Kallakkadal Swell Surge Card
      expect(find.text('Kallakkadal Swell Surge'), findsOneWidget);

      // Check Port Warning Signal
      expect(find.textContaining('SIGNAL'), findsWidgets);

      // Check 3-Tier Fleet Directives
      expect(find.text('Fleet Safety Directives (3 Tiers)'), findsOneWidget);
      expect(find.text('1. Catamarans & Traditional Craft'), findsOneWidget);
      expect(find.text('2. FRP Motorized Craft (Outboard)'), findsOneWidget);
      expect(find.text('3. Mechanized Multi-Day Trawlers'), findsOneWidget);

      // Check Oceanographic Metrics
      expect(find.text('Oceanographic Metrics'), findsOneWidget);
      expect(find.text('Significant Wave Height'), findsOneWidget);
      expect(find.text('Astronomical Tides'), findsOneWidget);

      // Check PFZ Card
      expect(find.text('INCOIS Potential Fishing Zone (PFZ)'), findsOneWidget);

      // Check Multilingual directves toggle
      expect(find.text('தமிழ்'), findsOneWidget);
      expect(find.text('മലയാളം'), findsOneWidget);
      expect(find.text('हिंदी'), findsOneWidget);

      // Tap Tamil chip and verify vernacular update
      await tester.tap(find.text('தமிழ்'));
      await tester.pumpAndSettle();
      expect(find.textContaining('அலைகள்'), findsOneWidget);
    });

    testWidgets('Renders clean Inland Notice for non-coastal locations', (tester) async {
      final weatherProvider = WeatherProvider();

      tester.view.physicalSize = const Size(1080, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: weatherProvider),
          ],
          child: const MaterialApp(
            home: MarineOceanScreen(
              initialLat: 28.6139,
              initialLon: 77.2090,
              initialLocationName: 'New Delhi',
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Check inland notice
      expect(find.text('Inland Territory Notice'), findsOneWidget);
      expect(find.textContaining('inland district with no direct marine coastline'), findsOneWidget);
      expect(find.text('View Chennai Marina Ocean State'), findsOneWidget);

      // Tap the preset button to navigate to coastal preview
      await tester.tap(find.text('View Chennai Marina Ocean State'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should now show coastal Kallakkadal surge card
      expect(find.text('Kallakkadal Swell Surge'), findsOneWidget);
    });
  });
}
