import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaanilaiai/models/wind_energy_model.dart';
import 'package:vaanilaiai/screens/wind_energy_screen.dart';

void main() {
  group('NIWE/IMD Wind Resource & Wind Farm Generation Models', () {
    test('defaultFallback creates valid wind energy model with offline flag', () {
      final fallback = WindEnergyResponseModel.defaultFallback();
      expect(fallback.offlineCached, isTrue);
      expect(fallback.selectedCorridor.corridorId, 'muppandal_tamil_nadu');
      expect(fallback.selectedCorridor.state, 'Tamil Nadu');
      expect(fallback.selectedCorridor.installedCapacityMw, 1500.0);
      expect(fallback.selectedCorridor.terrainRoughnessAlpha, 0.20);
      expect(fallback.selectedCorridor.resourceTier, 'OUTSTANDING');

      // Hub height profiles
      expect(fallback.selectedCorridor.hubHeightProfiles.length, 7);
      final h100 = fallback.selectedCorridor.hubHeightProfiles.firstWhere((e) => e.heightM == 100);
      expect(h100.windSpeedMs, 10.15);
      expect(h100.windPowerDensityWm2, 597.4);
      expect(h100.cardinalDirection, 'WSW');

      // Turbines
      expect(fallback.selectedCorridor.turbineProfiles.length, 2);
      final t3mw = fallback.selectedCorridor.turbineProfiles.firstWhere((e) => e.ratedPowerMw == 3.0);
      expect(t3mw.operatingState, 'RATED_FULL_LOAD');
      expect(t3mw.capacityUtilizationFactorPct, 88.7);

      // Repowering
      expect(fallback.selectedCorridor.repowering.energyYieldMultiplier, 3.2);
      expect(fallback.selectedCorridor.repowering.co2AbatementTonsYr, 4500.0);

      // Summaries & Bulletins
      expect(fallback.allCorridors.length, 7);
      expect(fallback.bulletins.containsKey('ta'), isTrue);
      expect(fallback.bulletins['ta'], contains('தேசிய காற்று ஆற்றல் நிறுவனம்'));
    });

    test('fromJson and toJson round-trip parsing matches accurately', () {
      final sampleJson = {
        'selected_corridor': {
          'corridor_id': 'kutch_gujarat',
          'corridor_name': 'Kutch Wind Corridor',
          'state': 'Gujarat',
          'installed_capacity_mw': 1100.0,
          'latitude': 23.242,
          'longitude': 69.6669,
          'elevation_m': 35.0,
          'terrain_roughness_alpha': 0.14,
          'resource_tier': 'GOOD',
          'surface_wind_10m_ms': 5.9,
          'surface_wind_dir_deg': 235.0,
          'air_density': {
            'surface_temperature_c': 33.0,
            'surface_pressure_hpa': 1009.0,
            'air_density_kgm3': 1.148,
            'standard_density_kgm3': 1.225,
            'density_ratio': 0.937,
            'thermal_derating_note': 'Thermal derating test note',
          },
          'weibull': {
            'shape_k': 2.15,
            'scale_c_ms': 7.6,
            'annual_mean_speed_ms': 6.8,
          },
          'hub_height_profiles': [
            {
              'height_m': 100,
              'wind_speed_ms': 8.14,
              'wind_speed_kmh': 29.3,
              'wind_power_density_wm2': 310.0,
              'wind_direction_deg': 235.0,
              'cardinal_direction': 'SW',
              'resource_tier': 'GOOD',
            }
          ],
          'turbine_profiles': [
            {
              'model_name': 'Test Turbine 3MW',
              'rated_power_mw': 3.0,
              'rotor_diameter_m': 140.0,
              'hub_height_m': 140,
              'cut_in_speed_ms': 2.8,
              'rated_speed_ms': 10.5,
              'cut_out_speed_ms': 25.0,
              'operating_state': 'PARTIAL_LOAD_RAMP',
              'gross_hourly_output_mw': 1.8,
              'wake_loss_pct': 7.8,
              'bop_electrical_loss_pct': 3.1,
              'blade_soiling_loss_pct': 2.2,
              'net_hourly_output_mw': 1.57,
              'daily_generation_mwh': 37.68,
              'capacity_utilization_factor_pct': 52.3,
            }
          ],
          'repowering': {
            'legacy_turbine_rating_kw': 500.0,
            'modern_turbine_rating_mw': 3.0,
            'energy_yield_multiplier': 2.8,
            'co2_abatement_tons_yr': 3800.0,
            'repowering_priority': 'HIGH',
          },
          'hourly_forecast': [
            {
              'hour': '12:00',
              'wind_speed_100m_ms': 8.5,
              'wind_direction_deg': 235.0,
              'expected_net_mw': 52.0,
              'cuf_pct': 52.0,
            }
          ],
        },
        'all_corridors': [
          {
            'corridor_id': 'kutch_gujarat',
            'corridor_name': 'Kutch Wind Corridor',
            'state': 'Gujarat',
            'installed_capacity_mw': 1100.0,
            'resource_tier': 'GOOD',
            'reference_speed_100m_ms': 8.14,
            'reference_wpd_100m_wm2': 310.0,
            'cuf_pct': 29.5,
          }
        ],
        'bulletins': {
          'en': 'English test bulletin',
          'gu': 'ગુજરાતી બુલેટિન',
        },
        'offline_cached': false,
        'generated_at': '2026-09-12T00:00:00Z',
      };

      final parsed = WindEnergyResponseModel.fromJson(sampleJson);
      expect(parsed.selectedCorridor.corridorId, 'kutch_gujarat');
      expect(parsed.selectedCorridor.state, 'Gujarat');
      expect(parsed.selectedCorridor.turbineProfiles.first.ratedPowerMw, 3.0);
      expect(parsed.bulletins['gu'], 'ગુજરાતી બુલેટિન');

      final serialized = parsed.toJson();
      expect(serialized['selected_corridor']['corridor_id'], 'kutch_gujarat');
      expect(serialized['all_corridors'].length, 1);
    });
  });

  group('WindEnergyScreen Widget Tests', () {
    testWidgets('renders hero card, shear profile, turbine HUD, and toggles hub height and language',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fallback = WindEnergyResponseModel.defaultFallback();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: WindEnergyScreen(initialData: fallback),
        ),
      );
      await tester.pumpAndSettle();

      // Check AppBar & Hero Title
      expect(find.text('Wind Energy & Hub-Height Atlas'), findsOneWidget);
      expect(find.text('NIWE · MNRE · IMD National Grid Forecaster'), findsOneWidget);
      expect(find.text('Muppandal (TN)'), findsOneWidget);

      // Check Hub Height Tabs & Profile Heights
      expect(find.text('80m'), findsNWidgets(2));
      expect(find.text('100m'), findsNWidgets(2));
      expect(find.text('120m'), findsNWidgets(2));
      expect(find.text('140m'), findsNWidgets(2));
      expect(find.text('150m'), findsNWidgets(2));

      // Check Section Headers
      expect(find.text('Vertical Wind Shear Profile (Hellmann Law)'), findsOneWidget);
      expect(find.text('Atmospheric Air Density & Weibull Dynamics'), findsOneWidget);
      expect(find.text('Utility Turbine Generation & Losses'), findsOneWidget);
      expect(find.text('MNRE Wind Repowering Feasibility'), findsOneWidget);
      expect(find.text('24-Hour Diurnal Generation Profile'), findsOneWidget);
      expect(find.text('Regional Operational Dispatch Bulletin'), findsOneWidget);

      // Tap on 120m hub height tab
      await tester.tap(find.text('120m').first);
      await tester.pumpAndSettle();

      // Tap on Tamil language chip
      final tamilFinder = find.text('தமிழ்');
      expect(tamilFinder, findsOneWidget);
      await tester.tap(tamilFinder);
      await tester.pumpAndSettle();
      expect(find.textContaining('தேசிய காற்று ஆற்றல் நிறுவனம்'), findsOneWidget);

      // Tap on 2.0 MW turbine toggle button
      final btn2mw = find.textContaining('2.0 MW');
      if (btn2mw.evaluate().isNotEmpty) {
        await tester.tap(btn2mw.first);
        await tester.pumpAndSettle();
      }
    });
  });
}
