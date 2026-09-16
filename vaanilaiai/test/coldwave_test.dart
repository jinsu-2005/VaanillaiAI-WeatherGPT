import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaanilaiai/models/coldwave_model.dart';
import 'package:vaanilaiai/screens/coldwave_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('IMD Cold Wave & Ground Frost Model Unit Tests', () {
    test('ColdWaveResponseModel parses valid JSON correctly', () {
      final jsonSample = {
        'station_id': 'CHURU_RJ',
        'station_name': 'Churu',
        'state': 'Rajasthan',
        'latitude': 28.29,
        'longitude': 74.96,
        'elevation_m': 286.0,
        'is_hill_station': false,
        'timestamp': '2026-09-12T00:00:00Z',
        'cold_wave_severity': 'SEVERE_COLD_WAVE',
        'ground_frost_risk': 'MODERATE',
        'summary_headline': 'Severe Cold Wave warning in effect for Churu.',
        'physics': {
          't_air_min': 1.4,
          't_normal_min': 8.5,
          'departure_c': -7.1,
          't_grass_min': -2.5,
          'sky_cover_oktas': 0,
          'wind_speed_kmh': 3.2,
          'dew_point_c': 0.2,
          'wind_chill_c': 0.1,
          'net_radiation_loss_wm2': 76.5,
        },
        'rabi_crop_advisories': [
          {
            'crop_name': 'Mustard / Rapeseed',
            'critical_stage': 'Pod Formation',
            'injury_mechanism': 'Cellular freezing',
            'yield_loss_risk_pct': 45,
            'countermeasures': [
              'Evening irrigation',
              'Smudge fire',
            ],
          },
        ],
        'urban_shelter': {
          'night_shelter_activated': true,
          'hypothermia_risk': 'HIGH',
          'recommended_clothing_layers': 4,
          'livestock_protection_rules': [
            'Provide straw bedding',
          ],
        },
        'multilingual_bulletins': {
          'en': 'IMD Cold Wave advisory in English.',
          'hi': 'आईएमडी शीत लहर बुलेटिन हिंदी में।',
        },
        'monitoring_stations': [
          {
            'station_id': 'CHURU_RJ',
            'station_name': 'Churu',
            'state': 'Rajasthan',
            'latitude': 28.29,
            'longitude': 74.96,
            'elevation_m': 286.0,
            'is_hill_station': false,
            't_min': 1.4,
            't_grass': -2.5,
            'cold_wave_severity': 'SEVERE_COLD_WAVE',
            'frost_risk': 'MODERATE',
          }
        ],
        'provenance_disclaimer': 'IMD Criteria Verified.',
      };

      final model = ColdWaveResponseModel.fromJson(jsonSample);
      expect(model.stationId, 'CHURU_RJ');
      expect(model.coldWaveSeverity, 'SEVERE_COLD_WAVE');
      expect(model.groundFrostRisk, 'MODERATE');
      expect(model.physics.tAirMin, 1.4);
      expect(model.physics.tGrassMin, -2.5);
      expect(model.rabiCropAdvisories.length, 1);
      expect(model.rabiCropAdvisories.first.cropName, 'Mustard / Rapeseed');
      expect(model.urbanShelter.nightShelterActivated, isTrue);
      expect(model.multilingualBulletins['hi'], contains('आईएमडी'));
    });

    test('ColdWaveResponseModel defaultFallback provides safe calibrated defaults', () {
      final fallback = ColdWaveResponseModel.defaultFallback();
      expect(fallback.stationId, 'CHURU_RJ');
      expect(fallback.physics.tGrassMin, lessThan(fallback.physics.tAirMin));
      expect(fallback.rabiCropAdvisories.isNotEmpty, isTrue);
      expect(fallback.urbanShelter.livestockProtectionRules.isNotEmpty, isTrue);
      expect(fallback.multilingualBulletins.containsKey('en'), isTrue);
      expect(fallback.multilingualBulletins.containsKey('hi'), isTrue);
      expect(fallback.multilingualBulletins.containsKey('pa'), isTrue);
      expect(fallback.multilingualBulletins.containsKey('bn'), isTrue);
      expect(fallback.multilingualBulletins.containsKey('ur'), isTrue);
    });
  });

  group('ColdWaveScreen Widget Tests', () {
    testWidgets('Renders ColdWaveScreen with severity card, physics HUD, and crop directives',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ColdWaveScreen(
            initialStationId: 'CHURU_RJ',
            initialData: ColdWaveResponseModel.defaultFallback(),
          ),
        ),
      );

      // Settle async loading
      await tester.pumpAndSettle();

      // Verify Screen Title
      expect(find.text('Cold Wave & Frost Engine'), findsOneWidget);

      // Verify Station & Severity
      expect(find.textContaining('Churu'), findsWidgets);
      expect(find.textContaining('SEVERE COLD WAVE'), findsWidgets);

      // Verify Ground Frost Physics HUD
      expect(find.textContaining('Stefan-Boltzmann'), findsOneWidget);
      expect(find.textContaining('MODERATE FROST'), findsOneWidget);

      // Scroll to ICAR Rabi Crop Advisories
      await tester.scrollUntilVisible(
        find.textContaining('ICAR Rabi Crop Frost Vulnerability'),
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('ICAR Rabi Crop Frost Vulnerability'), findsOneWidget);
      expect(find.textContaining('Mustard / Rapeseed'), findsOneWidget);

      // Scroll to Urban Rain Basera Shelter
      await tester.scrollUntilVisible(
        find.textContaining('Urban Rain Basera'),
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('Urban Rain Basera'), findsOneWidget);

      // Scroll down to Multilingual Directives and tap Hindi chip
      await tester.scrollUntilVisible(
        find.text('हिंदी'),
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('हिंदी'));
      await tester.pumpAndSettle();

      // Verify Hindi bulletin text
      expect(find.textContaining('आईएमडी शीत लहर बुलेटिन'), findsOneWidget);
    });
  });
}
