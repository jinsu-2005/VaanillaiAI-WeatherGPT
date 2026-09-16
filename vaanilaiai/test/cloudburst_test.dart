import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaanilaiai/models/cloudburst_model.dart';
import 'package:vaanilaiai/screens/cloudburst_screen.dart';

void main() {
  group('Cloudburst & Landslide Debris Flow Models', () {
    test('defaultFallback creates valid mountain hazard model with offline flag', () {
      final fallback = CloudburstResponseModel.defaultFallback();
      expect(fallback.isOfflineCached, isTrue);
      expect(fallback.selectedCatchment.catchmentId, 'kedarnath_mandakini');
      expect(fallback.selectedCatchment.orographicPrecipitation.cloudburstCategory, 'CLOUDBURST');
      expect(fallback.selectedCatchment.orographicPrecipitation.rainRateMmHr, 112.0);
      expect(fallback.selectedCatchment.slopeStability.factorOfSafety, lessThan(1.0));
      expect(fallback.selectedCatchment.slopeStability.landslideRiskTier, 'CRITICAL_IMMINENT_FAILURE');
      expect(fallback.selectedCatchment.hydrodynamics.flashFloodStage, 'CATASTROPHIC_DEBRIS_FLOW');
      expect(fallback.vernacularBulletins.containsKey('hi'), isTrue);
      expect(fallback.vernacularBulletins['hi'], contains('मंदाकिनी'));
    });

    test('fromJson and toJson parse mountain telemetry correctly', () {
      final sampleJson = {
        'timestamp': '2026-09-12T00:00:00Z',
        'selected_catchment': {
          'catchment_id': 'wayanad_vythiri_meppadi',
          'catchment_name': 'Vellarimala, Meppadi & Chooralmala Catchment',
          'mountain_range': 'Western Ghats Sahyadri',
          'state': 'Kerala',
          'elevation_m': 850,
          'latitude': 11.5372,
          'longitude': 76.1264,
          'dominant_lithology': 'Deep Weathered Laterite Regolith',
          'orographic_precipitation': {
            'rain_rate_mm_hr': 94.0,
            'accumulated_3h_mm': 210.0,
            'accumulated_24h_mm': 372.0,
            'condensation_level_m': 700.0,
            'cloud_top_height_km': 12.8,
            'radar_reflectivity_dbz': 54.0,
            'cloudburst_category': 'MINI_CLOUDBURST',
          },
          'slope_stability': {
            'slope_angle_degrees': 34.0,
            'ari_3day_mm': 240.0,
            'ari_15day_mm': 580.0,
            'pore_water_pressure_ratio': 0.98,
            'factor_of_safety': 0.78,
            'landslide_risk_tier': 'CRITICAL_IMMINENT_FAILURE',
          },
          'hydrodynamics': {
            'peak_discharge_m3_s': 640.0,
            'debris_slurry_volume_m3': 280000.0,
            'boulder_velocity_m_s': 7.8,
            'bridge_scour_threat': 'Total Submersion',
            'flash_flood_stage': 'CATASTROPHIC_DEBRIS_FLOW',
          },
          'directives': {
            'evacuation_order': 'Evacuate Chooralmala immediately.',
            'pilgrimage_transit_advisory': 'Sabarimala routes on high alert.',
            'ghat_road_transit_status': 'Thamarassery Churam closed.',
            'plantation_worker_protocol': 'Stop all tea estate operations.',
          },
          'bulletins': {
            'en': 'Wayanad Meppadi Debris Flow Warning.',
            'ml': 'മേപ്പാടി-ചൂരൽമല മേഖലയിൽ അതീവ ജാഗ്രത.',
          },
        },
        'all_catchments': [
          {
            'catchment_id': 'wayanad_vythiri_meppadi',
            'catchment_name': 'Vellarimala, Meppadi & Chooralmala Catchment',
            'mountain_range': 'Western Ghats Sahyadri',
            'state': 'Kerala',
            'elevation_m': 850,
            'latitude': 11.5372,
            'longitude': 76.1264,
            'dominant_lithology': 'Deep Weathered Laterite Regolith',
            'orographic_precipitation': {
              'rain_rate_mm_hr': 94.0,
              'accumulated_3h_mm': 210.0,
              'accumulated_24h_mm': 372.0,
              'condensation_level_m': 700.0,
              'cloud_top_height_km': 12.8,
              'radar_reflectivity_dbz': 54.0,
              'cloudburst_category': 'MINI_CLOUDBURST',
            },
            'slope_stability': {
              'slope_angle_degrees': 34.0,
              'ari_3day_mm': 240.0,
              'ari_15day_mm': 580.0,
              'pore_water_pressure_ratio': 0.98,
              'factor_of_safety': 0.78,
              'landslide_risk_tier': 'CRITICAL_IMMINENT_FAILURE',
            },
            'hydrodynamics': {
              'peak_discharge_m3_s': 640.0,
              'debris_slurry_volume_m3': 280000.0,
              'boulder_velocity_m_s': 7.8,
              'bridge_scour_threat': 'Total Submersion',
              'flash_flood_stage': 'CATASTROPHIC_DEBRIS_FLOW',
            },
            'directives': {
              'evacuation_order': 'Evacuate Chooralmala immediately.',
              'pilgrimage_transit_advisory': 'Sabarimala routes on high alert.',
              'ghat_road_transit_status': 'Thamarassery Churam closed.',
              'plantation_worker_protocol': 'Stop all tea estate operations.',
            },
            'bulletins': {
              'en': 'Wayanad Meppadi Debris Flow Warning.',
              'ml': 'മേപ്പാടി-ചൂരൽമല മേഖലയിൽ അതീവ ജാഗ്രത.',
            },
          }
        ],
        'vernacular_bulletins': {
          'en': 'Wayanad Meppadi Debris Flow Warning.',
          'ml': 'മേപ്പാടി-ചൂരൽമല മേഖലയിൽ അതീവ ജാഗ്രത.',
        },
        'bulletin_number': 'IMD-GSI/OC-FFLDE/2026-TEST',
        'provenance': 'IMD Mountain Meteorology Division & Geological Survey of India (GSI) NLEWS',
        'is_offline_cached': false,
      };

      final parsed = CloudburstResponseModel.fromJson(sampleJson);
      expect(parsed.selectedCatchment.catchmentId, 'wayanad_vythiri_meppadi');
      expect(parsed.selectedCatchment.state, 'Kerala');
      expect(parsed.selectedCatchment.orographicPrecipitation.accumulated24hMm, 372.0);
      expect(parsed.selectedCatchment.slopeStability.factorOfSafety, 0.78);
      expect(parsed.vernacularBulletins['ml'], contains('ചൂരൽമല'));

      final serialized = parsed.toJson();
      expect(serialized['selected_catchment']['catchment_id'], 'wayanad_vythiri_meppadi');
      expect(serialized['selected_catchment']['slope_stability']['factor_of_safety'], 0.78);
    });
  });

  group('CloudburstScreen Widget Tests', () {
    testWidgets('renders cloudburst telemetry and switches vernacular bulletins', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockData = CloudburstResponseModel.defaultFallback();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: CloudburstScreen(initialData: mockData),
        ),
      );

      // Verify screen title and hero metrics
      expect(find.text('Cloudburst & Landslide Debris Flow'), findsOneWidget);
      expect(find.text('Mandakini Valley & Kedarnath Basin'), findsOneWidget);
      expect(find.text('Rain Intensity'), findsOneWidget);
      expect(find.text('112 mm/h'), findsOneWidget);
      expect(find.text('CLOUDBURST (≥100 mm/h)'), findsOneWidget);
      expect(find.text('0.82'), findsOneWidget);
      expect(find.text('CRITICAL IMMINENT FAILURE'), findsOneWidget);

      // Verify English bulletin is shown by default
      expect(find.textContaining('Mandakini Valley under active CLOUDBURST'), findsOneWidget);

      // Switch to Hindi bulletin
      final hindiChip = find.text('हिंदी');
      expect(hindiChip, findsOneWidget);
      await tester.tap(hindiChip);
      await tester.pumpAndSettle();

      // Verify Hindi vernacular text appears
      expect(find.textContaining('मंदाकिनी घाटी में सक्रिय बादल फटा'), findsOneWidget);
    });
  });
}
