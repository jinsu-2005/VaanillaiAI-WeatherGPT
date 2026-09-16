import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaanilaiai/models/tsunami_model.dart';
import 'package:vaanilaiai/screens/tsunami_screen.dart';

void main() {
  group('Tsunami Early Warning (ITEWS) Models', () {
    test('defaultFallback creates valid tsunami model with offline flag', () {
      final fallback = TsunamiWarningResponseModel.defaultFallback();
      expect(fallback.isOfflineCached, isTrue);
      expect(fallback.selectedSector.sectorId, 'andaman_nicobar_islands');
      expect(fallback.selectedSector.state, 'Andaman & Nicobar Islands (UT)');
      expect(fallback.selectedSector.alertTier, 'WARNING_RED');
      expect(fallback.selectedSector.seismicSource.momentMagnitudeMw, 8.4);
      expect(fallback.selectedSector.waveMetrics.maximumExpectedWaveAmplitudeM, 4.2);
      expect(fallback.selectedSector.waveMetrics.timeToFirstWaveMinutes, 28);
      expect(fallback.selectedSector.dartBuoys.isNotEmpty, isTrue);
      expect(fallback.selectedSector.dartBuoys.first.buoyId, 'BPR-TB02');
      expect(fallback.selectedSector.dartBuoys.first.isEventModeTriggered, isTrue);
      expect(fallback.selectedSector.tideGauges.isNotEmpty, isTrue);
      expect(fallback.selectedSector.tideGauges.first.stationId, 'INCOIS-TG-PBLR');
      expect(fallback.vernacularBulletins.containsKey('ta'), isTrue);
      expect(fallback.vernacularBulletins['ta'], contains('சுனாமி'));
    });

    test('fromJson and toJson parse tsunami warning telemetry correctly', () {
      final sampleJson = {
        'timestamp': '2026-09-12T00:00:00Z',
        'bulletin_number': 'INCOIS-ITEWS/TSU-WARN/2026-TEST',
        'provenance': 'Indian National Centre for Ocean Information Services Test Provenance',
        'threat_status': 'CRITICAL: Coastal Inundation Threat (Red Alert) Active',
        'selected_sector': {
          'sector_id': 'tamil_nadu_coromandel_coast',
          'sector_name': 'Tamil Nadu & Puducherry Coromandel Coast',
          'state': 'Tamil Nadu & Puducherry',
          'key_coastal_nodes': ['Nagapattinam', 'Chennai Marina'],
          'latitude': 10.7670,
          'longitude': 79.8420,
          'alert_tier': 'WARNING_RED',
          'seismic_source': {
            'moment_magnitude_mw': 8.4,
            'focal_depth_km': 18.0,
            'epicenter_latitude': 9.2500,
            'epicenter_longitude': 93.8500,
            'origin_time_utc': '2026-09-12T04:15:00Z',
            'subduction_zone': 'ANDAMAN_SUMATRA_TRENCH',
            'rupture_mechanism': 'Underthrust Megathrust Faulting',
          },
          'wave_metrics': {
            'estimated_time_of_arrival_eta': '06:10 UTC',
            'time_to_first_wave_minutes': 115,
            'maximum_expected_wave_amplitude_m': 2.8,
            'deep_water_propagation_speed_kmh': 710.0,
            'estimated_inundation_distance_m': 620.0,
            'shoaling_amplification_factor': 4.6,
          },
          'dart_buoys': [
            {
              'buoy_id': 'BPR-TB01',
              'sea_basin': 'East Bay of Bengal',
              'latitude': 13.5000,
              'longitude': 89.2000,
              'water_depth_m': 3320.0,
              'pressure_anomaly_hpa': 8.6,
              'deep_ocean_wave_amplitude_cm': 28.0,
              'is_event_mode_triggered': true,
            }
          ],
          'tide_gauges': [
            {
              'station_id': 'INCOIS-TG-MAA',
              'station_name': 'Chennai Port Trust Tide Gauge',
              'observed_sea_level_m': 1.15,
              'astronomical_tide_m': 0.95,
              'tsunami_residual_amplitude_m': 0.20,
              'last_sample_time_utc': '2026-09-12T04:40:00Z',
            }
          ],
          'evacuation_directives': {
            'vertical_evacuation_altitude_m': 15.0,
            'horizontal_evacuation_distance_km': 1.0,
            'deep_sea_vessel_directive': 'Vessels out to sea (>100m depth)',
            'coastal_siren_network_status': 'ACTIVATED',
            'port_cargo_operations_status': 'SUSPENDED',
            'designated_safe_shelter_locations': ['Nagapattinam Multi-Purpose Tsunami Shelter'],
          },
          'localized_bulletins': {
            'en': 'TSUNAMI WARNING (RED ALERT): Coromandel coast on high alert.',
            'ta': 'சுனாமி சிவப்பு எச்சரிக்கை: நாகப்பட்டினம், சென்னை கடற்கரைகளுக்கு சுனாமி வரக்கூடும்.',
          },
        },
        'all_sectors': [],
        'vernacular_bulletins': {
          'en': 'TSUNAMI WARNING (RED ALERT): Coromandel coast on high alert.',
          'ta': 'சுனாமி சிவப்பு எச்சரிக்கை: நாகப்பட்டினம், சென்னை கடற்கரைகளுக்கு சுனாமி வரக்கூடும்.',
        },
        'is_offline_cached': false,
      };

      final parsed = TsunamiWarningResponseModel.fromJson(sampleJson);
      expect(parsed.selectedSector.sectorId, 'tamil_nadu_coromandel_coast');
      expect(parsed.selectedSector.state, 'Tamil Nadu & Puducherry');
      expect(parsed.selectedSector.alertTier, 'WARNING_RED');
      expect(parsed.selectedSector.waveMetrics.maximumExpectedWaveAmplitudeM, 2.8);
      expect(parsed.vernacularBulletins['ta'], contains('சுனாமி'));

      final serialized = parsed.toJson();
      expect(serialized['selected_sector']['sector_id'], 'tamil_nadu_coromandel_coast');
      expect(serialized['selected_sector']['wave_metrics']['maximum_expected_wave_amplitude_m'], 2.8);
    });
  });

  group('TsunamiScreen Widget Tests', () {
    testWidgets('renders tsunami threat telemetry, DART buoys, and switches vernacular bulletins', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockData = TsunamiWarningResponseModel.defaultFallback();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: TsunamiScreen(initialData: mockData),
        ),
      );

      // Verify screen title and hero metrics
      expect(find.text('Indian Tsunami Early Warning (ITEWS)'), findsOneWidget);
      expect(find.text('Andaman & Nicobar Islands (Near-Field Trench)'), findsOneWidget);
      expect(find.text('4.2'), findsOneWidget);
      expect(find.text('28'), findsOneWidget);
      expect(find.text('RED ALERT: TSUNAMI WARNING'), findsOneWidget);
      expect(find.text('BPR-TB02'), findsOneWidget);
      expect(find.text('EVENT MODE ACTIVE'), findsNWidgets(2));
      expect(find.text('Port Blair Phoenix Bay Jetty'), findsOneWidget);

      // Verify English bulletin is shown by default
      expect(find.textContaining('CRITICAL TSUNAMI WARNING (RED ALERT): Major tsunamigenic earthquake'), findsOneWidget);

      // Switch to Tamil bulletin
      final tamilChip = find.text('தமிழ்');
      expect(tamilChip, findsOneWidget);
      await tester.tap(tamilChip);
      await tester.pumpAndSettle();

      // Verify Tamil vernacular text appears
      expect(find.textContaining('சுனாமி சிவப்பு எச்சரிக்கை'), findsOneWidget);
    });
  });
}
