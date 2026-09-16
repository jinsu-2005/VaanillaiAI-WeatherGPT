import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaanilaiai/models/earthquake_model.dart';
import 'package:vaanilaiai/screens/earthquake_screen.dart';

void main() {
  group('NCS/IMD Earthquake Seismology Models', () {
    test('defaultFallback creates valid seismological model with offline flag', () {
      final fallback = EarthquakeResponseModel.defaultFallback();
      expect(fallback.isOfflineCached, isTrue);
      expect(fallback.selectedProvince.provinceId, 'delhi_ncr_igp');
      expect(fallback.selectedProvince.alertTier, 'GREEN_LIGHT');
      expect(fallback.selectedProvince.sourceParameters.momentMagnitudeMw, 4.2);
      expect(fallback.selectedProvince.sourceParameters.focalDepthKm, 8.0);
      expect(fallback.selectedProvince.mmiAssessment.epicentralMmi, 'IV');
      expect(fallback.selectedProvince.aftershockOutlook.bathLawLargestAftershockMw, 3.0);
      expect(fallback.selectedProvince.structuralDirectives.bisSeismicZone, 'ZONE_IV');
      expect(fallback.selectedProvince.structuralDirectives.designPgaG, 0.24);
      expect(fallback.selectedProvince.structuralDirectives.ndmaDos.isNotEmpty, isTrue);
      expect(fallback.selectedProvince.structuralDirectives.ndmaDonts.isNotEmpty, isTrue);
      expect(fallback.vernacularBulletins.containsKey('hi'), isTrue);
      expect(fallback.vernacularBulletins['hi'], contains('दिल्ली'));
    });

    test('fromJson and toJson parse earthquake telemetry correctly', () {
      final sampleJson = {
        'timestamp': '2026-09-12T00:00:00Z',
        'bulletin_number': 'NCS/IMD-SEIS/TEST-2026',
        'provenance': 'National Centre for Seismology Test Provenance',
        'national_seismicity_synopsis': 'ELEVATED: Significant seismic event recorded',
        'selected_province': {
          'province_id': 'kutch_saurashtra_gj',
          'province_name': 'Kutch & Saurashtra Intraplate Rift Zone',
          'state': 'Gujarat',
          'dominant_fault_system': 'Kutch Mainland Fault (KMF) & Katrol Hill Fault (KHF)',
          'latitude': 23.3500,
          'longitude': 70.3000,
          'alert_tier': 'ORANGE_DAMAGING',
          'source_parameters': {
            'moment_magnitude_mw': 5.8,
            'local_magnitude_ml': 5.6,
            'focal_depth_km': 16.0,
            'epicenter_latitude': 23.4000,
            'epicenter_longitude': 70.2500,
            'origin_time_utc': '2026-09-12T05:20:00Z',
            'fault_mechanism': 'REVERSE_THRUST',
            'fault_plane_strike_deg': 285.0,
            'rupture_length_km': 22.0,
          },
          'mmi_assessment': {
            'epicentral_mmi': 'VII',
            'felt_radius_km': 310.0,
            'perceived_shaking': 'Very Strong',
            'potential_damage': 'Moderate damage to ordinary structures',
            'did_you_feel_it_reports': 8600,
          },
          'aftershock_outlook': {
            'bath_law_largest_aftershock_mw': 4.6,
            'modified_omori_p_value': 1.10,
            'reasenberg_jones_24h_probability_pct': 38.0,
            'expected_aftershocks_7_day': 64,
            'coulomb_stress_transfer_direction': 'WNW along KMF toward Bhuj segment',
          },
          'structural_directives': {
            'bis_seismic_zone': 'ZONE_V',
            'design_pga_g': 0.36,
            'building_vulnerability_class': 'B (Vulnerable Rubble Stone Masonry)',
            'post_quake_inspection_priority': 'Urgent',
            'soft_story_collapse_risk': 'HIGH: Open ground storey parking buildings',
            'masonry_infill_damage_risk': 'SEVERE: Unreinforced masonry collapse risk',
            'ndma_dos': [
              'DROP-COVER-HOLD under sturdy furniture',
              'Stay away from glass windows and electric cables',
            ],
            'ndma_donts': [
              'DO NOT rush towards exits during active shaking',
              'DO NOT light matches or gas stoves',
            ],
          },
          'vernacular_alerts': {
            'en': 'NCS ALERT: M5.8 earthquake near Bhachau, Kutch.',
            'gu': 'એનસીએસ ચેતવણી: કચ્છના ભચાઉ નજીક ૫.૮ ની તીવ્રતાનો ભૂકંપ.',
          },
        },
        'all_provinces': [],
        'seismological_model': 'Modified Omori Law; Reasenberg-Jones Aftershock Sequence',
        'vernacular_bulletins': {
          'en': 'NCS ALERT: M5.8 earthquake near Bhachau, Kutch.',
          'gu': 'એનસીએસ ચેતવણી: કચ્છના ભચાઉ નજીક ૫.૮ ની તીવ્રતાનો ભૂકંપ.',
        },
        'is_offline_cached': false,
      };

      final parsed = EarthquakeResponseModel.fromJson(sampleJson);
      expect(parsed.selectedProvince.provinceId, 'kutch_saurashtra_gj');
      expect(parsed.selectedProvince.alertTier, 'ORANGE_DAMAGING');
      expect(parsed.selectedProvince.sourceParameters.momentMagnitudeMw, 5.8);
      expect(parsed.selectedProvince.mmiAssessment.epicentralMmi, 'VII');
      expect(parsed.selectedProvince.structuralDirectives.bisSeismicZone, 'ZONE_V');
      expect(parsed.vernacularBulletins['gu'], contains('કચ્છના'));

      final serialized = parsed.toJson();
      expect(serialized['selected_province']['province_id'], 'kutch_saurashtra_gj');
      expect(
        serialized['selected_province']['source_parameters']['moment_magnitude_mw'],
        5.8,
      );
    });
  });

  group('EarthquakeScreen Widget Tests', () {
    testWidgets('renders earthquake seismology metrics, MMI intensity, and switches language',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fallbackData = EarthquakeResponseModel.defaultFallback();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: EarthquakeScreen(initialData: fallbackData),
        ),
      );
      await tester.pumpAndSettle();

      // Check header, magnitude, and zone badge
      expect(find.text('🌍 Earthquake Seismology'), findsOneWidget);
      expect(find.text('4.2'), findsWidgets);
      expect(find.text('ZONE IV'), findsWidgets);

      // Check province selector chips
      expect(find.text('NW Himalaya (J&K/HP)'), findsOneWidget);
      expect(find.text('Delhi-NCR (IGP)'), findsOneWidget);

      // Check NDMA safety instructions
      expect(find.text('🛡️ NDMA Earthquake Safety'), findsOneWidget);
      expect(find.text('Stay calm; minor tremors are common in seismic zone IV'), findsOneWidget);

      // Verify language switching to Hindi
      final hindiChip = find.text('हिंदी');
      expect(hindiChip, findsOneWidget);
      await tester.tap(hindiChip);
      await tester.pumpAndSettle();

      // Check vernacular text displayed
      expect(find.textContaining('दिल्ली'), findsWidgets);
    });
  });
}
