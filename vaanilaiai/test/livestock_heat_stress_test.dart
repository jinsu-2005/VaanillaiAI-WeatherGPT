import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaanilaiai/models/livestock_heat_stress_model.dart';
import 'package:vaanilaiai/screens/livestock_heat_stress_screen.dart';

void main() {
  group('ICAR-NDRI Livestock Heat Stress & THI Models', () {
    test('defaultFallback creates valid biometeorological model with offline flag', () {
      final fallback = LivestockHeatStressResponseModel.defaultFallback();
      expect(fallback.isOfflineCached, isTrue);
      expect(fallback.selectedBasin.basinId, 'karnal_kurukshetra_hr');
      expect(fallback.selectedBasin.state, 'Haryana');
      expect(fallback.selectedBasin.stressTier, 'MODERATE_STRESS');
      expect(fallback.selectedBasin.microclimate.dryBulbTemperatureC, 41.5);
      expect(fallback.selectedBasin.microclimate.relativeHumidityPct, 58.0);
      expect(fallback.selectedBasin.microclimate.temperatureHumidityIndexThi, 87.2);
      expect(fallback.selectedBasin.speciesProfiles.length, 3);

      final murrah = fallback.selectedBasin.speciesProfiles
          .firstWhere((p) => p.speciesCategory == 'MURRAH_WATER_BUFFALO');
      expect(murrah.breedName, 'Murrah Water Buffalo');
      expect(murrah.respirationRateBpm, 78);
      expect(murrah.estimatedMilkYieldDropPct, 22.0);

      expect(fallback.vernacularBulletins.containsKey('pa'), isTrue);
      expect(fallback.vernacularBulletins['pa'], contains('ਆਈਸੀਏਆਰ'));
    });

    test('fromJson and toJson parse livestock biometeorology accurately', () {
      final sampleJson = {
        'timestamp': '2026-09-12T10:00:00Z',
        'bulletin_number': 'ICAR-NDRI/THI-WARN/TEST',
        'provenance': 'ICAR-NDRI Test Division',
        'national_pastoral_summary': 'SEVERE: Extreme Heat Stress Active',
        'selected_basin': {
          'basin_id': 'anand_mehsana_gj',
          'basin_name': 'Anand & Mehsana Dairy Belt',
          'state': 'Gujarat',
          'prominent_dairy_cluster': 'Amul Cooperative Milk Federation',
          'latitude': 22.5645,
          'longitude': 72.9289,
          'stress_tier': 'SEVERE_EMERGENCY',
          'microclimate': {
            'dry_bulb_temperature_c': 42.5,
            'relative_humidity_pct': 60.0,
            'dew_point_temperature_c': 32.0,
            'wind_speed_ms': 1.5,
            'solar_radiation_wm2': 920.0,
            'temperature_humidity_index_thi': 89.2,
            'black_globe_humidity_index_bgthi': 93.8,
          },
          'species_profiles': [
            {
              'species_category': 'MURRAH_WATER_BUFFALO',
              'breed_name': 'Mehsani Water Buffalo',
              'respiration_rate_bpm': 88,
              'rectal_temperature_c': 40.3,
              'estimated_milk_yield_drop_pct': 27.0,
              'dry_matter_intake_reduction_pct': 22.0,
              'conception_rate_penalty_pct': 38.0,
            }
          ],
          'directives': {
            'shed_cooling_protocol': 'Continuous high-pressure misting.',
            'wallowing_pond_recommendation': 'Wallow twice daily.',
            'water_requirement_liters_per_animal': 135.0,
            'dietary_ration_adjustment': 'Buffer with sodium bicarbonate.',
            'grazing_curfew_hours': 'No grazing 10:00 to 17:00.',
            'veterinary_emergency_signs': ['Severe tongue protrusion'],
          },
          'vernacular_bulletins': {
            'en': 'AMUL EMERGENCY: High heat stress alert.',
            'gu': 'અમૂલ કટોકટી: તીવ્ર ગરમી તણાવ ચેતવણી.',
          },
        },
        'all_basins': [],
        'bioclimatic_model': 'Thom Index Formula',
        'vernacular_bulletins': {
          'en': 'AMUL EMERGENCY: High heat stress alert.',
          'gu': 'અમૂલ કટોકટી: તીવ્ર ગરમી તણાવ ચેતવણી.',
        },
        'is_offline_cached': false,
      };

      final parsed = LivestockHeatStressResponseModel.fromJson(sampleJson);
      expect(parsed.selectedBasin.basinId, 'anand_mehsana_gj');
      expect(parsed.selectedBasin.state, 'Gujarat');
      expect(parsed.selectedBasin.stressTier, 'SEVERE_EMERGENCY');
      expect(parsed.selectedBasin.microclimate.temperatureHumidityIndexThi, 89.2);
      expect(parsed.vernacularBulletins['gu'], contains('અમૂલ'));

      final serialized = parsed.toJson();
      expect(serialized['selected_basin']['basin_id'], 'anand_mehsana_gj');
      expect(
        serialized['selected_basin']['microclimate']['temperature_humidity_index_thi'],
        89.2,
      );
    });
  });

  group('LivestockHeatStressScreen Widget Tests', () {
    testWidgets('renders hero THI card, species profiles, directives and switches vernacular language',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockData = LivestockHeatStressResponseModel.defaultFallback();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: LivestockHeatStressScreen(initialData: mockData),
        ),
      );

      // Verify screen title and header
      expect(find.text('Livestock Heat Stress (THI)'), findsOneWidget);
      expect(find.text('ICAR-NDRI & IMD AGROMET'), findsOneWidget);
      expect(find.text('Karnal & Kurukshetra Basin'), findsOneWidget);
      expect(find.text('87.2'), findsOneWidget);
      expect(find.text('MODERATE STRESS'), findsOneWidget);

      // Verify Microclimate Grid
      expect(find.text('Shed Biometeorology & Microclimate'), findsOneWidget);
      expect(find.text('41.5°C'), findsOneWidget); // Air Temp
      expect(find.text('58%'), findsOneWidget); // Humidity
      expect(find.text('1.8 m/s'), findsOneWidget); // Airflow

      // Verify Species Vulnerability Section
      expect(find.text('Species & Breed Impact Vulnerability'), findsOneWidget);
      expect(find.text('Murrah Water Buffalo'), findsOneWidget);
      expect(find.text('-22.0% Milk Drop'), findsOneWidget);
      expect(find.text('Karan Fries (HF x Tharparkar Crossbred)'), findsOneWidget);
      expect(find.text('-26.5% Milk Drop'), findsOneWidget);

      // Verify Shelter & Nutrition Directives
      expect(find.text('Farm Shelter & Feeding Directives'), findsOneWidget);
      expect(find.text('Shed Cooling & Misting'), findsOneWidget);
      expect(find.text('Wallowing / Water Bathing'), findsOneWidget);

      // Verify Emergency Signs
      expect(find.text('Immediate Veterinary Red Alert Signs'), findsOneWidget);

      // Verify Regional Vernacular Broadcast default (English)
      expect(
        find.textContaining('ICAR-NDRI BIOMET BULLETIN: Karnal-Kurukshetra dairy belt'),
        findsOneWidget,
      );

      // Switch language to Punjabi
      final punjabiChip = find.text('ਪੰਜਾਬੀ');
      expect(punjabiChip, findsOneWidget);
      await tester.tap(punjabiChip);
      await tester.pumpAndSettle();

      // Verify Punjabi broadcast text appears
      expect(
        find.textContaining('ਆਈਸੀਏਆਰ-ਐਨਡੀਆਰਆਈ ਡੇਅਰੀ ਬੁਲੇਟਿਨ'),
        findsOneWidget,
      );
    });
  });
}
