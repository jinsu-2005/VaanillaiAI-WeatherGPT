import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaanilaiai/models/crop_water_stress_model.dart';
import 'package:vaanilaiai/screens/crop_water_stress_screen.dart';

void main() {
  group('Crop Water Stress (CWSI) Models', () {
    test('defaultFallback creates valid CWSI model with offline flag', () {
      final fallback = CropWaterStressResponseModel.defaultFallback();
      expect(fallback.isOfflineCached, isTrue);
      expect(fallback.selectedZone.zoneId, 'vidarbha_cotton_vertisol');
      expect(fallback.selectedZone.state, 'Maharashtra');
      expect(fallback.selectedZone.primaryCrop, contains('Bt Cotton'));
      expect(fallback.selectedZone.stressTier, 'MODERATE_DEFICIT');
      expect(fallback.selectedZone.evapotranspiration.cropWaterStressIndexCwsi, 0.68);
      expect(fallback.selectedZone.evapotranspiration.canopyAirTempDepartureC, 2.4);
      expect(fallback.selectedZone.soilMoisture.relativeAvailableSoilMoisturePct, 22.5);
      expect(fallback.selectedZone.irrigationDirectives.recommendedIrrigationDepthMm, 35.0);
      expect(fallback.vernacularBulletins.containsKey('mr'), isTrue);
      expect(fallback.vernacularBulletins['mr'], contains('कापूस'));
    });

    test('fromJson and toJson parse crop water stress telemetry correctly', () {
      final sampleJson = {
        'timestamp': '2026-09-12T00:00:00Z',
        'bulletin_number': 'ICAR-IMD/CWSI/2026-TEST',
        'provenance': 'ICAR-CRIDA & IMD Division of Agricultural Meteorology Test Provenance',
        'selected_zone': {
          'zone_id': 'punjab_wheat_rice_alluvium',
          'zone_name': 'Punjab Central Alluvial Cropping Plain',
          'state': 'Punjab',
          'district': 'Ludhiana',
          'primary_crop': 'Wheat (Triticum aestivum)',
          'growth_stage': 'Crown Root Initiation (CRI)',
          'latitude': 30.9010,
          'longitude': 75.8573,
          'soil_texture': 'INDO_GANGETIC_ALLUVIAL',
          'stress_tier': 'OPTIMAL_TURGOR',
          'soil_moisture': {
            'topsoil_10cm_pct': 28.2,
            'root_zone_40cm_pct': 29.5,
            'subsoil_100cm_pct': 30.8,
            'field_capacity_pct': 32.0,
            'wilting_point_pct': 12.0,
            'relative_available_soil_moisture_pct': 81.0,
          },
          'evapotranspiration': {
            'reference_et0_mm_day': 3.2,
            'crop_coefficient_kc': 0.85,
            'actual_etc_mm_day': 2.7,
            'canopy_temperature_c': 18.2,
            'ambient_air_temperature_c': 20.0,
            'canopy_air_temp_departure_c': -1.8,
            'crop_water_stress_index_cwsi': 0.18,
          },
          'irrigation_directives': {
            'recommended_irrigation_depth_mm': 0.0,
            'drip_run_time_hours': 0.0,
            'critical_growth_stage': 'Crown Root Initiation',
            'anti_transpirant_spray': 'Not required',
            'mulch_recommendation': 'Paddy straw residue',
            'intercultivation_tillage': 'Avoid tillage',
          },
          'localized_bulletins': {
            'en': 'OPTIMAL TURGOR: Punjab wheat canopy well-hydrated.',
            'pa': 'ਅਨੁਕੂਲ ਨਮੀ: ਪੰਜਾਬ ਵਿੱਚ ਕਣਕ ਦੀ ਫਸਲ ਵਿੱਚ ਨਮੀ ਦੀ ਸਥਿਤੀ ਬਹੁਤ ਵਧੀਆ ਹੈ।',
          },
        },
        'all_zones': [],
        'vernacular_bulletins': {
          'en': 'OPTIMAL TURGOR: Punjab wheat canopy well-hydrated.',
          'pa': 'ਅਨੁਕੂਲ ਨਮੀ: ਪੰਜਾਬ ਵਿੱਚ ਕਣਕ ਦੀ ਫਸਲ ਵਿੱਚ ਨਮੀ ਦੀ ਸਥਿਤੀ ਬਹੁਤ ਵਧੀਆ ਹੈ।',
        },
        'is_offline_cached': false,
      };

      final parsed = CropWaterStressResponseModel.fromJson(sampleJson);
      expect(parsed.selectedZone.zoneId, 'punjab_wheat_rice_alluvium');
      expect(parsed.selectedZone.state, 'Punjab');
      expect(parsed.selectedZone.stressTier, 'OPTIMAL_TURGOR');
      expect(parsed.selectedZone.evapotranspiration.cropWaterStressIndexCwsi, 0.18);
      expect(parsed.vernacularBulletins['pa'], contains('ਕਣਕ'));

      final serialized = parsed.toJson();
      expect(serialized['selected_zone']['zone_id'], 'punjab_wheat_rice_alluvium');
      expect(serialized['selected_zone']['evapotranspiration']['crop_water_stress_index_cwsi'], 0.18);
    });
  });

  group('CropWaterStressScreen Widget Tests', () {
    testWidgets('renders crop water stress telemetry, soil moisture HUD, and switches vernacular bulletins', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockData = CropWaterStressResponseModel.defaultFallback();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: CropWaterStressScreen(initialData: mockData),
        ),
      );

      // Verify screen title and hero metrics
      expect(find.text('Crop Water Stress (CWSI)'), findsOneWidget);
      expect(find.text('Vidarbha Rainfed Cotton-Soybean Vertisol Belt'), findsOneWidget);
      expect(find.text('0.68'), findsOneWidget);
      expect(find.text('+2.4'), findsOneWidget);
      expect(find.text('MODERATE WATER DEFICIT (CWSI 0.4-0.7)'), findsOneWidget);
      expect(find.text('Topsoil (0-10 cm)'), findsOneWidget);
      expect(find.text('14.5% VWC'), findsOneWidget);
      expect(find.text('35 mm Net'), findsOneWidget);

      // Verify English bulletin is shown by default
      expect(find.textContaining('MODERATE CROP WATER STRESS: Bt Cotton in Vidarbha'), findsOneWidget);

      // Switch to Marathi bulletin
      final marathiChip = find.text('मराठी');
      expect(marathiChip, findsOneWidget);
      await tester.tap(marathiChip);
      await tester.pumpAndSettle();

      // Verify Marathi vernacular text appears
      expect(find.textContaining('मध्यम पीक जल ताण'), findsOneWidget);
    });
  });
}
