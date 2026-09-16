import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaanilaiai/models/forest_fire_model.dart';
import 'package:vaanilaiai/screens/forest_fire_screen.dart';

void main() {
  group('Forest Fire & FWI Models', () {
    test('defaultFallback creates valid forest fire model with offline flag', () {
      final fallback = ForestFireResponse.defaultFallback();
      expect(fallback.isOfflineCached, isTrue);
      expect(fallback.selectedZone.zoneId, 'uttarakhand_garhwal_pine');
      expect(fallback.selectedZone.state, 'Uttarakhand');
      expect(fallback.selectedZone.biomeType, 'CHIR_PINE_CONIFEROUS');
      expect(fallback.selectedZone.indices.dangerTier, 'VERY_HIGH');
      expect(fallback.selectedZone.indices.fwiFireWeatherIndex, 38.6);
      expect(fallback.selectedZone.behavior.crownFireRisk, isTrue);
      expect(fallback.selectedZone.behavior.estimatedRateOfSpreadMHr, 620.0);
      expect(fallback.vernacularBulletins.containsKey('hi'), isTrue);
      expect(fallback.vernacularBulletins['hi'], contains('चीड़'));
    });

    test('fromJson and toJson parse forest fire telemetry correctly', () {
      final sampleJson = {
        'timestamp': '2026-09-12T00:00:00Z',
        'bulletin_number': 'FSI-ISRO/FF-FWIE/2026-TEST',
        'provenance': 'Forest Survey of India Test Provenance',
        'selected_zone': {
          'zone_id': 'similipal_tiger_reserve',
          'zone_name': 'Similipal Biosphere Reserve & Tiger Sanctuary',
          'state': 'Odisha',
          'reserve_name': 'Similipal Tiger Reserve',
          'latitude': 21.8500,
          'longitude': 86.3500,
          'biome_type': 'DRY_DECIDUOUS_SAL',
          'indices': {
            'ffmc_fine_fuel_moisture': 94.2,
            'dmc_duff_moisture': 76.5,
            'dc_drought_code': 520.0,
            'isi_initial_spread_index': 18.2,
            'bui_buildup_index': 112.0,
            'fwi_fire_weather_index': 48.5,
            'danger_tier': 'EXTREME',
          },
          'active_thermal_hotspots': [
            {
              'sensor': 'SNPP_VIIRS_375M',
              'detection_timestamp': '2026-09-12T03:45:00Z',
              'latitude': 21.8620,
              'longitude': 86.3680,
              'brightness_temp_kelvin': 382.0,
              'fire_radiative_power_mw': 45.6,
              'confidence_pct': 98.0,
            }
          ],
          'total_frp_mw': 210.8,
          'behavior': {
            'estimated_rate_of_spread_m_hr': 840.0,
            'flame_length_m': 4.5,
            'fireline_intensity_kw_m': 4600.0,
            'crown_fire_risk': true,
            'spot_fire_probability_pct': 78.0,
          },
          'directives': {
            'ranger_deployment_alert': 'Full mobilization of Odisha Forest Protection Force.',
            'firebreak_clearance_width_m': 20.0,
            'wildlife_corridor_status': 'Elephant corridor active with solar water pumps.',
            'tribal_ntfp_collection_directive': 'Moratorium on Mahua collection.',
            'aerial_water_bombing_standby': true,
          },
          'localized_bulletins': {
            'en': 'Extreme Forest Fire Danger at Similipal Tiger Reserve.',
            'or': 'ଶିମିଳିପାଳ ବ୍ୟାଘ୍ର ଅଭୟାରଣ୍ୟରେ ଚରମ ବଣନିଆଁ ବିପଦ।',
          },
        },
        'all_zones': [],
        'vernacular_bulletins': {
          'en': 'Extreme Forest Fire Danger at Similipal Tiger Reserve.',
          'or': 'ଶିମିଳିପାଳ ବ୍ୟାଘ୍ର ଅଭୟାରଣ୍ୟରେ ଚରମ ବଣନିଆଁ ବିପଦ।',
        },
        'is_offline_cached': false,
      };

      final parsed = ForestFireResponse.fromJson(sampleJson);
      expect(parsed.selectedZone.zoneId, 'similipal_tiger_reserve');
      expect(parsed.selectedZone.state, 'Odisha');
      expect(parsed.selectedZone.indices.dangerTier, 'EXTREME');
      expect(parsed.selectedZone.indices.fwiFireWeatherIndex, 48.5);
      expect(parsed.vernacularBulletins['or'], contains('ଶିମିଳିପାଳ'));

      final serialized = parsed.toJson();
      expect(serialized['selected_zone']['zone_id'], 'similipal_tiger_reserve');
      expect(serialized['selected_zone']['indices']['fwi_fire_weather_index'], 48.5);
    });
  });

  group('ForestFireScreen Widget Tests', () {
    testWidgets('renders forest fire FWI telemetry and switches vernacular bulletins', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockData = ForestFireResponse.defaultFallback();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: ForestFireScreen(initialData: mockData),
        ),
      );

      // Verify screen title and hero metrics
      expect(find.text('Forest Fire & Van Agni FWI'), findsOneWidget);
      expect(find.text('Garhwal & Kumaon Chir Pine Forests'), findsOneWidget);
      expect(find.text('38.6'), findsNWidgets(2));
      expect(find.text('VERY HIGH FIRE DANGER (FWI 30-45)'), findsOneWidget);
      expect(find.text('620 m/hr'), findsOneWidget);
      expect(find.text('3.8 m'), findsOneWidget);

      // Verify English bulletin is shown by default
      expect(find.textContaining('Very High Fire Weather Index (FWI 38.6) in Garhwal-Kumaon Chir Pine forest divisions'), findsOneWidget);

      // Switch to Kannada bulletin
      final kannadaChip = find.text('ಕನ್ನಡ');
      expect(kannadaChip, findsOneWidget);
      await tester.tap(kannadaChip);
      await tester.pumpAndSettle();

      // Verify Kannada vernacular text appears
      expect(find.textContaining('ಗರ್ಹ್ವಾಲ್ ಪೈನ್ ಅರಣ್ಯಗಳಲ್ಲಿ ತೀವ್ರ ಕಾಡ್ಗಿಚ್ಚಿನ ಅಪಾಯ'), findsOneWidget);
    });
  });
}
