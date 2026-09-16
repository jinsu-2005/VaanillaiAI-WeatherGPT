import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaanilaiai/models/ocean_state_model.dart';
import 'package:vaanilaiai/screens/ocean_state_screen.dart';

void main() {
  group('INCOIS Ocean State Forecast & Rip Current Models', () {
    test('defaultFallback creates valid ocean state model with offline flag', () {
      final fallback = OceanStateResponseModel.defaultFallback();
      expect(fallback.isOfflineCached, isTrue);
      expect(fallback.selectedBeach.beachId, 'puri_golden_beach_or');
      expect(fallback.selectedBeach.state, 'Odisha');
      expect(fallback.selectedBeach.alertTier, 'ORANGE_ALERT');
      expect(fallback.selectedBeach.waveMetrics.significantWaveHeightM, 3.20);
      expect(fallback.selectedBeach.waveMetrics.maximumWaveHeightM, 5.40);
      expect(fallback.selectedBeach.ripCurrent.peakRipVelocityMs, 1.45);
      expect(fallback.selectedBeach.directives.lifeguardFlag, 'RED_HIGH_HAZARD');
      expect(fallback.vernacularBroadcasts.containsKey('or'), isTrue);
      expect(fallback.vernacularBroadcasts['or'], contains('ପୁରୀ'));
    });

    test('fromJson and toJson parse ocean state telemetry correctly', () {
      final sampleJson = {
        'timestamp': '2026-09-12T00:00:00Z',
        'bulletin_number': 'INCOIS-OSF/WAVE-RIP/2026-TEST',
        'provenance': 'INCOIS OSF Test Provenance',
        'national_sea_state_synopsis': 'CRITICAL: High Swell Surge Active',
        'selected_beach': {
          'beach_id': 'kovalam_vizhinjam_kl',
          'beach_name': 'Kovalam Lighthouse Beach & Vizhinjam',
          'coastal_district': 'Thiruvananthapuram',
          'state': 'Kerala',
          'water_body': 'Arabian Sea',
          'latitude': 8.3988,
          'longitude': 76.9785,
          'alert_tier': 'RED_WARNING',
          'wave_metrics': {
            'significant_wave_height_m': 3.85,
            'maximum_wave_height_m': 6.30,
            'peak_wave_period_s': 18.5,
            'mean_wave_direction_deg': 220.0,
            'wave_steepness_ratio': 0.038,
            'sea_surface_current_speed_knots': 2.8,
          },
          'swell_surge': {
            'is_kallakkadal_active': true,
            'distant_source_basin': 'Southern Indian Ocean',
            'swell_wave_period_s': 18.5,
            'coastal_overwash_risk': 'CRITICAL',
            'artisan_craft_anchoring_directive': 'Evacuate crafts 25m inland.',
          },
          'rip_current': {
            'risk_level': 'HIGH_DEADLY',
            'peak_rip_velocity_ms': 1.65,
            'rip_channel_locations': ['Lighthouse Promontory Reef Gap'],
            'rip_survival_instruction': 'Swim parallel to shore.',
          },
          'directives': {
            'lifeguard_flag': 'DOUBLE_RED_PROHIBITED',
            'bathing_swimming_advisory': 'BEACH CLOSED TO PUBLIC',
            'water_sports_status': 'SUSPENDED',
            'country_boat_catamaran_directive': 'BANNED',
            'deep_sea_trawler_advisory': 'Offshore safe zone',
            'active_lifeguard_towers_count': 6,
          },
          'vernacular_broadcasts': {
            'en': 'KALLAKKADAL SWELL SURGE WARNING: Kovalam beach closed.',
            'ml': 'കള്ളക്കടൽ മുന്നറിയിപ്പ്: കോവളം തീരത്ത് രാക്ഷസത്തിരകൾ.',
          },
        },
        'all_beaches': [],
        'numerical_model_wave_watch': 'WAVEWATCH-III',
        'vernacular_broadcasts': {
          'en': 'KALLAKKADAL SWELL SURGE WARNING: Kovalam beach closed.',
          'ml': 'കള്ളക്കടൽ മുന്നറിയിപ്പ്: കോവളം തീരത്ത് രാക്ഷസത്തിരകൾ.',
        },
        'is_offline_cached': false,
      };

      final parsed = OceanStateResponseModel.fromJson(sampleJson);
      expect(parsed.selectedBeach.beachId, 'kovalam_vizhinjam_kl');
      expect(parsed.selectedBeach.state, 'Kerala');
      expect(parsed.selectedBeach.alertTier, 'RED_WARNING');
      expect(parsed.selectedBeach.swellSurge.isKallakkadalActive, isTrue);
      expect(parsed.selectedBeach.waveMetrics.peakWavePeriodS, 18.5);
      expect(parsed.vernacularBroadcasts['ml'], contains('കള്ളക്കടൽ'));

      final serialized = parsed.toJson();
      expect(serialized['selected_beach']['beach_id'], 'kovalam_vizhinjam_kl');
      expect(serialized['selected_beach']['wave_metrics']['significant_wave_height_m'], 3.85);
    });
  });

  group('OceanStateScreen Widget Tests', () {
    testWidgets('renders hero wave card, rip current HUD, and switches language',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockData = OceanStateResponseModel.defaultFallback();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: OceanStateScreen(initialData: mockData),
        ),
      );

      // Verify screen title and hero metrics
      expect(find.text('INCOIS Ocean State Forecast'), findsOneWidget);
      expect(find.text('High Wave, Kallakkadal & Rip Current Engine'), findsOneWidget);
      expect(find.text('Puri Golden Beach & Swargadwar'), findsOneWidget);
      expect(find.text('3.20'), findsOneWidget);
      expect(find.text('Hmax: 5.4m'), findsOneWidget);
      expect(find.text('ORANGE ALERT'), findsOneWidget);
      expect(find.text('RED FLAG: HIGH HAZARD & ROUGH SURF'), findsOneWidget);

      // Verify Rip Current HUD
      expect(find.text('Beach Rip Current Hazard HUD'), findsOneWidget);
      expect(find.text('1.45 m/s'), findsOneWidget);
      expect(find.text('HIGH DEADLY'), findsOneWidget);

      // Verify Wave Physics grid
      expect(find.text('WAVEWATCH-III Numerical Wave Physics'), findsOneWidget);
      expect(find.text('13.5 s'), findsOneWidget); // Peak period
      expect(find.text('195°'), findsOneWidget); // Direction

      // Verify English broadcast bulletin by default
      expect(
        find.textContaining('HIGH WAVE & RIP CURRENT ALERT: Puri Golden Beach'),
        findsOneWidget,
      );

      // Switch to Odia bulletin
      final odiaChip = find.text('ଓଡ଼ିଆ');
      expect(odiaChip, findsOneWidget);
      await tester.tap(odiaChip);
      await tester.pumpAndSettle();

      // Verify Odia vernacular broadcast appears
      expect(find.textContaining('ଉଚ୍ଚ ଜୁଆର ଓ ରିପ୍ କରେଣ୍ଟ ଚେତାବନୀ'), findsOneWidget);
    });
  });
}
