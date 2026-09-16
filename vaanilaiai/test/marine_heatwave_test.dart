import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaanilaiai/models/marine_heatwave_model.dart';
import 'package:vaanilaiai/screens/marine_heatwave_screen.dart';

void main() {
  group('INCOIS Marine Heatwave & Coral Bleaching Models', () {
    test('defaultFallback creates valid marine heatwave model with offline flag', () {
      final fallback = MarineHeatwaveResponseModel.defaultFallback();
      expect(fallback.isOfflineCached, isTrue);
      expect(fallback.selectedSector.hotspotId, 'gulf_of_mannar_rameshwaram');
      expect(fallback.selectedSector.thermalStress.degreeHeatingWeeks, greaterThan(8.0));
      expect(fallback.selectedSector.thermalStress.bleachingAlertLevel, 'ALERT_LEVEL_1');
      expect(fallback.selectedSector.heatwave.category, 'CATEGORY_II_STRONG');
      expect(fallback.vernacularBulletins.containsKey('ta'), isTrue);
      expect(fallback.vernacularBulletins['ta'], contains('மன்னார் வளைகுடா'));
    });

    test('fromJson and toJson parse marine telemetry correctly', () {
      final sampleJson = {
        'timestamp': '2026-09-12T00:00:00Z',
        'selected_sector': {
          'hotspot_id': 'lakshadweep_kavaratti',
          'sector_name': 'Lakshadweep Coral Atolls (Kavaratti & Kadmat)',
          'maritime_zone': 'Arabian Sea (Central Lakshadweep)',
          'state_or_ut': 'Lakshadweep UT',
          'latitude': 10.5667,
          'longitude': 72.6417,
          'reef_type': 'Coral Atolls & Lagoons',
          'dominant_coral_taxa': ['Acropora formosa', 'Porites lutea'],
          'thermal_stress': {
            'sea_surface_temp_c': 32.4,
            'climatological_mmm_c': 29.8,
            'sst_anomaly_c': 2.6,
            'coral_hotspot_c': 2.6,
            'degree_heating_weeks': 13.5,
            'bleaching_alert_level': 'ALERT_LEVEL_2',
          },
          'heatwave': {
            'category': 'CATEGORY_III_SEVERE',
            'duration_days': 41,
            'peak_anomaly_c': 2.9,
            'depth_penetration_m': 38.0,
            'pelagic_fish_displacement': 'Displaced to deeper thermocline',
          },
          'coastal_fog': {
            'is_fog_active': false,
            'sea_air_temp_diff_c': -0.4,
            'nautical_visibility_m': 4200.0,
            'marine_inversion_height_m': 150.0,
            'vts_channel_status': 'Standard navigation. Good visibility across reef passages.',
          },
          'directives': {
            'reef_protection_notice': 'Halt all scuba diving tourism in bleaching lagoons.',
            'diving_tourism_advisory': 'No motorized watercraft over reef flats.',
            'artisanal_fisher_guidance': 'Deep line trolling beyond 80m dropoff advised.',
            'artificial_shading_status': 'Emergency nursery shading active.',
          },
        },
        'all_sectors': [
          {
            'hotspot_id': 'lakshadweep_kavaratti',
            'sector_name': 'Lakshadweep Coral Atolls (Kavaratti & Kadmat)',
            'maritime_zone': 'Arabian Sea (Central Lakshadweep)',
            'state_or_ut': 'Lakshadweep UT',
            'latitude': 10.5667,
            'longitude': 72.6417,
            'reef_type': 'Coral Atolls & Lagoons',
            'dominant_coral_taxa': ['Acropora formosa', 'Porites lutea'],
            'thermal_stress': {
              'sea_surface_temp_c': 32.4,
              'climatological_mmm_c': 29.8,
              'sst_anomaly_c': 2.6,
              'coral_hotspot_c': 2.6,
              'degree_heating_weeks': 13.5,
              'bleaching_alert_level': 'ALERT_LEVEL_2',
            },
            'heatwave': {
              'category': 'CATEGORY_III_SEVERE',
              'duration_days': 41,
              'peak_anomaly_c': 2.9,
              'depth_penetration_m': 38.0,
              'pelagic_fish_displacement': 'Displaced to deeper thermocline',
            },
            'coastal_fog': {
              'is_fog_active': false,
              'sea_air_temp_diff_c': -0.4,
              'nautical_visibility_m': 4200.0,
              'marine_inversion_height_m': 150.0,
              'vts_channel_status': 'Standard navigation.',
            },
            'directives': {
              'reef_protection_notice': 'Halt all scuba diving tourism.',
              'diving_tourism_advisory': 'No motorized watercraft.',
              'artisanal_fisher_guidance': 'Deep line trolling advised.',
              'artificial_shading_status': 'Active.',
            },
          }
        ],
        'vernacular_bulletins': {
          'en': 'Emergency Level 2 Bleaching in progress.',
          'ml': 'കവരത്തി അറ്റോളുകളിൽ ഗുരുതരമായ പവിഴപ്പുറ്റ് ബ്ലീച്ചിംഗ്.',
        },
        'bulletin_number': 'INCOIS-MHW/CRW/2026-TEST',
        'provenance': 'INCOIS-OOMAD Indian Ocean Marine Heatwave Diagnostic System',
        'is_offline_cached': false,
      };

      final parsed = MarineHeatwaveResponseModel.fromJson(sampleJson);
      expect(parsed.selectedSector.hotspotId, 'lakshadweep_kavaratti');
      expect(parsed.selectedSector.thermalStress.bleachingAlertLevel, 'ALERT_LEVEL_2');
      expect(parsed.selectedSector.heatwave.durationDays, 41);
      expect(parsed.vernacularBulletins['ml'], contains('പവിഴപ്പുറ്റ്'));

      final serialized = parsed.toJson();
      expect(serialized['selected_sector']['hotspot_id'], 'lakshadweep_kavaratti');
      expect(serialized['selected_sector']['thermal_stress']['degree_heating_weeks'], 13.5);
    });
  });

  group('MarineHeatwaveScreen Widget Tests', () {
    testWidgets('renders marine heatwave telemetry and switches vernacular bulletins', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockData = MarineHeatwaveResponseModel.defaultFallback();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: MarineHeatwaveScreen(initialData: mockData),
        ),
      );

      // Verify screen renders title and thermal stress metrics
      expect(find.text('INCOIS Marine Heatwave & Reefs'), findsOneWidget);
      expect(find.text('Gulf of Mannar Biosphere Reserve & Rameswaram'), findsOneWidget);
      expect(find.text('Sea Surface Temp'), findsOneWidget);
      expect(find.text('Degree Heating Wks'), findsOneWidget);
      expect(find.text('Alert Level 1'), findsOneWidget);
      expect(find.text('Category II Strong'), findsOneWidget);

      // Verify English bulletin is shown by default
      expect(find.textContaining('ALERT LEVEL 1 & CATEGORY II STRONG'), findsOneWidget);

      // Switch to Tamil bulletin
      final tamilChip = find.text('தமிழ்');
      expect(tamilChip, findsOneWidget);
      await tester.tap(tamilChip);
      await tester.pumpAndSettle();

      // Verify Tamil vernacular text appears
      expect(find.textContaining('மன்னார் வளைகுடா பகுதியில் பவளப்பாறை வெளுத்தல்'), findsOneWidget);
    });
  });
}
