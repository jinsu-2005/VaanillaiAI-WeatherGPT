import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vaanilaiai/models/convective_storm_model.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/screens/convective_storm_screen.dart';

void main() {
  group('IMD Severe Thunderstorm & Haboob Model Unit Tests', () {
    test('ConvectiveStormResponseModel parses valid JSON correctly', () {
      final json = {
        'timestamp': '2026-09-12T06:00:00Z',
        'selected_hotspot': {
          'hotspot_id': 'kolkata_gangetic_wb',
          'hotspot_name': 'Kolkata & Gangetic WB',
          'state': 'West Bengal',
          'latitude': 22.5726,
          'longitude': 88.3639,
          'phenomenon': 'KALBAISHAKHI_NORWESTER',
          'warning_stage': 'STAGE_3_ORANGE_WARNING',
          'headline': 'Severe Kalbaishakhi squall line advancing across Hooghly & Howrah.',
          'thermodynamics': {
            'cape_j_kg': 3200.0,
            'lifted_index_c': -6.8,
            'k_index_c': 39.5,
            'total_totals_c': 54.0,
            'sweat_index': 420.0,
            'bulk_wind_shear_0_6km_kt': 42.0,
            'cin_j_kg': 22.0,
          },
          'density_current': {
            'gust_front_speed_kmh': 85.0,
            'dust_wall_height_m': 300.0,
            'minimum_visibility_m': 1200.0,
            'pm10_surge_ug_m3': 280.0,
            'cold_pool_temp_drop_c': 9.5,
            'downdraft_spread_direction': 'North-West to South-East',
          },
          'aviation_grid': {
            'microburst_risk': 'Severe Microburst & LLWS Alert',
            'power_grid_risk': 'High risk of 220kV/400kV line tripping',
            'airport_alert': 'NSCB International Airport ground ops halted',
            'structural_damage_risk': 'Severe risk to temporary roofs & billboards',
          },
          'radar_reflectivity_dbz': 62.5,
          'nowcast_validity_hours': 3,
        },
        'all_hotspots': [],
        'vernacular_bulletins': {
          'en': 'IMD SEVERE THUNDERSTORM / KALBAISHAKHI NOWCAST: ORANGE ALERT for Kolkata.',
          'bn': 'আইএমডি কালবৈশাখী সতর্কতা: কলকাতার জন্য কমলা সতর্কতা জারি।',
        },
        'bulletin_number': 'IMD-NSTS-2026/09/KW-101',
        'provenance': 'IMD National Severe Thunderstorm Warning System',
      };

      final model = ConvectiveStormResponseModel.fromJson(json);
      expect(model.selectedHotspot.hotspotId, 'kolkata_gangetic_wb');
      expect(model.selectedHotspot.phenomenon, 'KALBAISHAKHI_NORWESTER');
      expect(model.selectedHotspot.warningStage, 'STAGE_3_ORANGE_WARNING');
      expect(model.selectedHotspot.thermodynamics.capeJKg, 3200.0);
      expect(model.selectedHotspot.thermodynamics.bulkWindShear06kmKt, 42.0);
      expect(model.selectedHotspot.densityCurrent.gustFrontSpeedKmh, 85.0);
      expect(model.selectedHotspot.aviationGrid.microburstRisk, contains('Severe Microburst'));
      expect(model.vernacularBulletins['bn'], contains('আইএমডি কালবৈশাখী'));
    });

    test('ConvectiveStormResponseModel defaultFallback provides calibrated convective defaults', () {
      final fallback = ConvectiveStormResponseModel.defaultFallback();
      expect(fallback.selectedHotspot.hotspotId, 'kolkata_gangetic_wb');
      expect(fallback.allHotspots.length, greaterThanOrEqualTo(2));
      expect(fallback.selectedHotspot.thermodynamics.capeJKg, greaterThan(2500.0));
      expect(fallback.vernacularBulletins.containsKey('en'), isTrue);
      expect(fallback.vernacularBulletins.containsKey('hi'), isTrue);
      expect(fallback.vernacularBulletins.containsKey('bn'), isTrue);
      expect(fallback.vernacularBulletins.containsKey('or'), isTrue);
      expect(fallback.vernacularBulletins.containsKey('as'), isTrue);
      expect(fallback.isOfflineCached, isTrue);
    });
  });

  group('ConvectiveStormScreen Widget Tests', () {
    testWidgets('Renders ConvectiveStormScreen with hero alert, thermodynamic HUD, Haboob card, and Bengali vernacular toggle',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));

      final weatherProvider = WeatherProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WeatherProvider>.value(value: weatherProvider),
          ],
          child: MaterialApp(
            home: ConvectiveStormScreen(
              initialData: ConvectiveStormResponseModel.defaultFallback(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify AppBar title & subtitle
      expect(find.text('Severe Storm & Haboob Warning'), findsOneWidget);
      expect(find.text('Kalbaishakhi • Haboob • Squall Nowcast'), findsOneWidget);

      // Verify Hubs selector header
      expect(find.text('Severe Convective Monitoring Hubs'), findsOneWidget);

      // Verify Hero card
      expect(find.text('Kolkata & Gangetic West Bengal Corridor'), findsAtLeastNWidgets(1));
      expect(find.text('STAGE 4 RED SEVERE WARNING'), findsOneWidget);

      // Verify Thermodynamic HUD
      expect(find.text('Thermodynamic Convective Instability'), findsOneWidget);
      expect(find.text('CAPE Energy'), findsOneWidget);
      expect(find.text('Lifted Index (LI)'), findsOneWidget);
      expect(find.text('George\'s K-Index'), findsOneWidget);
      expect(find.text('Total Totals (TT)'), findsOneWidget);
      expect(find.text('SWEAT Index'), findsOneWidget);
      expect(find.text('0-6 km Bulk Shear'), findsOneWidget);

      // Verify Cold-Pool Haboob Dynamics card
      expect(find.text('Cold-Pool Haboob & Squall Dynamics'), findsOneWidget);
      expect(find.text('Gust Front Speed'), findsOneWidget);
      expect(find.text('Dust/Squall Wall'), findsOneWidget);
      expect(find.text('Min. Visibility'), findsOneWidget);

      // Verify Aviation & Power Grid Resilience
      expect(find.text('Aviation & Power Grid Resilience'), findsOneWidget);
      expect(find.text('Microburst / LLWS'), findsOneWidget);
      expect(find.text('Power Grid Risk'), findsOneWidget);

      // Verify Multilingual bulletin switcher
      expect(find.text('Emergency Convective Bulletin'), findsOneWidget);
      final bengaliChip = find.text('বাংলা');
      expect(bengaliChip, findsOneWidget);
      await tester.tap(bengaliChip);
      await tester.pumpAndSettle();

      // Verify Bengali bulletin content rendered
      expect(find.textContaining('আইএমডি তীব্র কালবৈশাখী ও বজ্রঝড় সতর্কতা'), findsOneWidget);
    });
  });
}
