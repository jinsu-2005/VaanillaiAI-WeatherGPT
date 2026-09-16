import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaanilaiai/models/hazmat_model.dart';
import 'package:vaanilaiai/screens/hazmat_screen.dart';

void main() {
  group('Hazmat Dispersion Models', () {
    test('defaultFallback creates valid chemical dispersion model with offline flag', () {
      final fallback = HazmatDispersionResponse.defaultFallback();
      expect(fallback.isOfflineCached, isTrue);
      expect(fallback.selectedCluster.clusterId, 'dahej_pcpir_gujarat');
      expect(fallback.selectedCluster.activeGasProfile.species, 'CHLORINE_CL2');
      expect(fallback.selectedCluster.activeGasProfile.chemicalFormula, 'Cl2');
      expect(fallback.selectedCluster.dispersionMetrics.centerlinePeakConcentrationPpm, 48.6);
      expect(fallback.selectedCluster.dispersionMetrics.protectiveActionDistanceKm, 4.2);
      expect(fallback.selectedCluster.dispersionMetrics.initialIsolationZoneM, 400.0);
      expect(fallback.selectedCluster.emergencyProtocol.waterSprayCurtainRecommended, isTrue);
      expect(fallback.vernacularBulletins.containsKey('gu'), isTrue);
      expect(fallback.vernacularBulletins['gu'], contains('દહેજ'));
    });

    test('fromJson and toJson parse hazmat telemetry correctly', () {
      final sampleJson = {
        'timestamp': '2026-09-12T00:00:00Z',
        'bulletin_number': 'CPCB-IMD/HAZMAT-ADPE/2026-TEST',
        'provenance': 'CPCB & IMD Test Provenance',
        'selected_cluster': {
          'cluster_id': 'manali_industrial_corridor_chennai',
          'cluster_name': 'Manali Petrochemical & Fertilizer Complex (Chennai)',
          'state': 'Tamil Nadu',
          'district': 'Chennai / Tiruvallur',
          'latitude': 13.1667,
          'longitude': 80.2667,
          'major_industrial_sectors': ['Nitrogenous Fertilizer (Urea / Ammonia)', 'Petroleum Refining (CPCL)'],
          'active_gas_profile': {
            'species': 'AMMONIA_NH3',
            'common_name': 'Anhydrous Ammonia',
            'chemical_formula': 'NH3',
            'cas_number': '7664-41-7',
            'molecular_weight_g_mol': 17.03,
            'vapor_density_air_ratio': 0.59,
            'odor_threshold_ppm': 5.0,
            'aegl_1_ppm': 30.0,
            'aegl_2_ppm': 160.0,
            'aegl_3_ppm': 1100.0,
            'idlh_ppm': 300.0,
          },
          'atmospheric_telemetry': {
            'wind_speed_m_s': 4.5,
            'wind_direction_degrees': 65.0,
            'wind_direction_cardinal': 'ENE',
            'pasquill_stability_class': 'CLASS_D_NEUTRAL',
            'mixing_height_m': 600.0,
            'ambient_temp_c': 31.0,
            'relative_humidity_pct': 82.0,
            'solar_radiation_w_m2': 450.0,
            'inversion_layer_present': false,
          },
          'dispersion_metrics': {
            'release_rate_kg_s': 25.0,
            'release_height_m': 12.0,
            'centerline_peak_concentration_ppm': 340.0,
            'protective_action_distance_km': 3.5,
            'initial_isolation_zone_m': 300.0,
            'plume_width_1km_m': 290.0,
            'transit_time_buffer_min': 11.2,
            'severity_tier': 'SIGNIFICANT_TANK_LEAK',
          },
          'emergency_protocol': {
            'crosswind_escape_direction': 'EVACUATE CROSSWIND towards Madhavaram.',
            'shelter_in_place_directives': 'Cover mouth with wet fabric.',
            'recommended_ppe': 'Level B splash suit with SCBA.',
            'medical_countermeasures': 'Flush eyes for 15 mins. Administer oxygen.',
            'water_spray_curtain_recommended': true,
          },
          'sensitive_downwind_receptors': ['Manali New Town Habitations (1.5 km WSW)'],
          'localized_bulletins': {
            'en': 'Emergency Ammonia Release at Manali.',
            'ta': 'மணலி தொழிற்பேட்டையில் அம்மோனியா வாயு கசிவு.',
          },
        },
        'all_clusters': [],
        'vernacular_bulletins': {
          'en': 'Emergency Ammonia Release at Manali.',
          'ta': 'மணலி தொழிற்பேட்டையில் அம்மோனியா வாயு கசிவு.',
        },
        'is_offline_cached': false,
      };

      final parsed = HazmatDispersionResponse.fromJson(sampleJson);
      expect(parsed.selectedCluster.clusterId, 'manali_industrial_corridor_chennai');
      expect(parsed.selectedCluster.state, 'Tamil Nadu');
      expect(parsed.selectedCluster.activeGasProfile.species, 'AMMONIA_NH3');
      expect(parsed.selectedCluster.dispersionMetrics.centerlinePeakConcentrationPpm, 340.0);
      expect(parsed.vernacularBulletins['ta'], contains('மணலி'));

      final serialized = parsed.toJson();
      expect(serialized['selected_cluster']['cluster_id'], 'manali_industrial_corridor_chennai');
      expect(serialized['selected_cluster']['dispersion_metrics']['centerline_peak_concentration_ppm'], 340.0);
    });
  });

  group('HazmatScreen Widget Tests', () {
    testWidgets('renders hazmat plume telemetry and switches vernacular bulletins', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockData = HazmatDispersionResponse.defaultFallback();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: HazmatScreen(initialData: mockData),
        ),
      );

      // Verify screen title and hero metrics
      expect(find.text('Industrial Hazmat & Plume'), findsOneWidget);
      expect(find.text('Chlorine Gas'), findsOneWidget);
      expect(find.text('Cl2'), findsOneWidget);
      expect(find.text('48.6'), findsOneWidget);
      expect(find.text('SIGNIFICANT TANK LEAK'), findsOneWidget);
      expect(find.text('4.2 km'), findsOneWidget);
      expect(find.text('400 m'), findsOneWidget);

      // Verify English bulletin is shown by default
      expect(find.textContaining('Significant Chlorine (Cl2) plume dispersion detected at Dahej PCPIR'), findsOneWidget);

      // Switch to Gujarati bulletin
      final gujaratiChip = find.text('ગુજરાતી');
      expect(gujaratiChip, findsOneWidget);
      await tester.tap(gujaratiChip);
      await tester.pumpAndSettle();

      // Verify Gujarati vernacular text appears
      expect(find.textContaining('દહેજ પીસીપીઆઇઆરમાં ક્લોરિન વાયુનું ગંભીર લીકેજ'), findsOneWidget);
    });
  });
}
