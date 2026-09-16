import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaanilaiai/models/solar_energy_model.dart';
import 'package:vaanilaiai/screens/solar_energy_screen.dart';

void main() {
  group('NISE/IMD Solar Radiation & Rooftop PV Models', () {
    test('defaultFallback creates valid solar energy model with offline flag', () {
      final fallback = SolarEnergyResponseModel.defaultFallback();
      expect(fallback.isOfflineCached, isTrue);
      expect(fallback.selectedSector.parkId, 'bhadla_rajasthan');
      expect(fallback.selectedSector.radiationTier, 'EXCELLENT');
      expect(fallback.selectedSector.irradiance.ghiWm2, 985.0);
      expect(fallback.selectedSector.pvPerformance.pvCellTemperatureC, 62.4);
      expect(fallback.selectedSector.soilingAdvisory.soilingLossPct, 12.8);
      expect(fallback.selectedSector.rooftopEconomics.length, 4);

      final sys3kw = fallback.selectedSector.rooftopEconomics
          .firstWhere((e) => e.capacityKwp == 3.0);
      expect(sys3kw.dailyGenerationKwh, 17.55);
      expect(sys3kw.monthlySavingsInr, 3791.0);

      expect(fallback.vernacularBulletins.containsKey('hi'), isTrue);
      expect(fallback.vernacularBulletins['hi'], contains('भडला'));
    });

    test('fromJson and toJson parse solar irradiance telemetry accurately', () {
      final sampleJson = {
        'timestamp': '2026-09-12T00:00:00Z',
        'bulletin_number': 'NISE-IMD/SOLAR-PV/TEST-2026',
        'provenance': 'National Institute of Solar Energy Test Provenance',
        'national_solar_overview': 'HIGH-YIELD SOLAR REGIME ACTIVE',
        'selected_sector': {
          'park_id': 'pavagada_karnataka',
          'park_name': 'Pavagada Solar Park',
          'state': 'Karnataka',
          'installed_capacity_mw': 2050.0,
          'latitude': 14.0987,
          'longitude': 77.2755,
          'radiation_tier': 'EXCELLENT',
          'irradiance': {
            'ghi_wm2': 925.0,
            'dni_wm2': 820.0,
            'dhi_wm2': 160.0,
            'solar_zenith_angle_deg': 24.8,
            'clearness_index_kt': 0.70,
            'cloud_attenuation_pct': 6.0,
          },
          'pv_performance': {
            'ambient_temperature_c': 33.5,
            'pv_cell_temperature_c': 52.8,
            'temperature_derating_pct': -10.6,
            'performance_ratio_pct': 82.0,
            'specific_yield_kwh_per_kwp': 5.52,
          },
          'soiling_advisory': {
            'soiling_loss_pct': 6.4,
            'cleaning_recommended': false,
            'cleaning_urgency': 'ROUTINE',
            'next_rain_washout_forecast': 'Rain expected in 48 hours.',
            'optimal_cleaning_window': 'Evening after sunset.',
          },
          'rooftop_economics': [
            {
              'capacity_kwp': 3.0,
              'daily_generation_kwh': 16.56,
              'monthly_generation_kwh': 496.8,
              'monthly_savings_inr': 3577.0,
              'co2_offset_kg_per_month': 407.4,
            }
          ],
          'hourly_forecast': [
            {
              'hour': '12:00',
              'ghi_wm2': 925.0,
              'cell_temperature_c': 52.8,
              'estimated_generation_kwh_per_kwp': 0.74,
            }
          ],
          'vernacular_bulletins': {
            'en': 'PAVAGADA SOLAR ALERT: Generating 5.52 kWh/kWp.',
            'kn': 'ಪಾವಗಡ ಸೋಲಾರ್ ವರದಿ: ಅತ್ಯುತ್ತಮ ಸೌರ ವಿದ್ಯುತ್ ಉತ್ಪಾದನೆ.',
          },
        },
        'all_sectors': [],
        'solar_physics_model': 'Sandia Cell Model; Perez Diffuse Model',
        'vernacular_bulletins': {
          'en': 'PAVAGADA SOLAR ALERT: Generating 5.52 kWh/kWp.',
          'kn': 'ಪಾವಗಡ ಸೋಲಾರ್ ವರದಿ: ಅತ್ಯುತ್ತಮ ಸೌರ ವಿದ್ಯುತ್ ಉತ್ಪಾದನೆ.',
        },
        'is_offline_cached': false,
      };

      final parsed = SolarEnergyResponseModel.fromJson(sampleJson);
      expect(parsed.selectedSector.parkId, 'pavagada_karnataka');
      expect(parsed.selectedSector.irradiance.ghiWm2, 925.0);
      expect(parsed.selectedSector.pvPerformance.performanceRatioPct, 82.0);
      expect(parsed.vernacularBulletins['kn'], contains('ಪಾವಗಡ'));

      final serialized = parsed.toJson();
      expect(serialized['selected_sector']['park_id'], 'pavagada_karnataka');
      expect(
        serialized['selected_sector']['irradiance']['ghi_wm2'],
        925.0,
      );
    });
  });

  group('SolarEnergyScreen Widget Tests', () {
    testWidgets('renders solar irradiance, rooftop calculator, and switches language',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fallbackData = SolarEnergyResponseModel.defaultFallback();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: SolarEnergyScreen(initialData: fallbackData),
        ),
      );
      await tester.pumpAndSettle();

      // Check header, GHI value, and park name
      expect(find.text('☀️ Solar Radiation & Rooftop PV'), findsOneWidget);
      expect(find.text('985'), findsWidgets);
      expect(find.text('Bhadla Mega Solar Park (Phalodi)'), findsOneWidget);
      expect(find.text('EXCELLENT SOLAR REGIME'), findsOneWidget);

      // Check PM Surya Ghar Rooftop Solar Calculator
      expect(find.text('🏠 PM Surya Ghar Rooftop Solar Calculator'), findsOneWidget);
      expect(find.text('3 kWp'), findsOneWidget);
      expect(find.text('17.55 kWh/day'), findsOneWidget);

      // Tap 5 kWp rooftop size
      final fiveKwpChip = find.text('5 kWp');
      expect(fiveKwpChip, findsOneWidget);
      await tester.tap(fiveKwpChip);
      await tester.pumpAndSettle();

      // Verify updated calculation for 5 kWp
      expect(find.text('29.25 kWh/day'), findsOneWidget);

      // Verify language switching to Hindi
      final hindiChip = find.text('हिंदी');
      expect(hindiChip, findsOneWidget);
      await tester.tap(hindiChip);
      await tester.pumpAndSettle();

      // Check vernacular text displayed
      expect(find.textContaining('भडला'), findsWidgets);
    });
  });
}
