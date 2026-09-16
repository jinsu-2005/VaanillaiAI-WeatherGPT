import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vaanilaiai/models/flash_drought_model.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/screens/flash_drought_screen.dart';

void main() {
  group('IMD & CWC Flash Drought & Soil Desiccation Model Tests', () {
    test('FlashDroughtResponseModel parses valid JSON correctly', () {
      final json = {
        'hotspot': {
          'hotspot_id': 'RAYALASEEMA_BASIN',
          'name': 'Rayalaseema Dryland Basin',
          'districts': ['Anantapur', 'Kurnool'],
          'state': 'Andhra Pradesh',
          'latitude': 14.6819,
          'longitude': 77.6006,
          'soil_type': 'Red Sandy Loams (Alfisols)',
          'primary_kharif_crops': ['Groundnut', 'Sunflower'],
          'irrigation_coverage_pct': 18.0,
        },
        'assessment_timestamp': '2026-09-12T06:00:00Z',
        'overall_intensity_tier': 'EXTREME_FLASH_DROUGHT',
        'rapid_intensification_detected': true,
        'atmospheric_demand': {
          'reference_evapotranspiration_e0_mm_day': 7.2,
          'eddi_2week': 2.15,
          'eddi_4week': 1.85,
          'evaporative_demand_tier': 'EXTREME_EVAPORATIVE_DEMAND',
          'vapor_pressure_deficit_kpa': 3.1,
          'air_temperature_max_c': 39.5,
          'temp_max_departure_c': 4.8,
          'solar_radiation_mj_m2_day': 25.5,
          'wind_speed_2m_ms': 4.5,
        },
        'soil_desiccation': {
          'topsoil_moisture_0_10cm_pct': 8.5,
          'rootzone_moisture_10_40cm_pct': 14.0,
          'rootzone_percentile': 8.0,
          'percentile_drop_14days': 38.0,
          'desiccation_rate_pct_per_day': 1.45,
          'desiccation_velocity': 'CRITICAL_EXPLOSIVE',
          'evaporative_stress_index_esi': 0.18,
          'consecutive_rainless_days': 19,
        },
        'crop_vulnerability': {
          'primary_crop': 'Groundnut',
          'current_growth_stage': 'Peg Penetration & Pod Development',
          'vulnerability_tier': 'CRITICAL_REPRODUCTIVE_SUSCEPTIBILITY',
          'yield_loss_risk_pct': 65.0,
          'damage_multiplier': 2.05,
          'transpirational_stress_label': 'Inability of pegs to penetrate dry soil.',
        },
        'directives': {
          'anti_transpirant_spray_recommendation': 'Spray 1% Potassium Nitrate (KNO3).',
          'mulching_directive': 'Apply straw mulching.',
          'micro_irrigation_pulse_schedule': 'DEFICIT PULSE IRRIGATION: Restrict to night.',
          'salvage_action': 'Thin out alternate rows.',
          'actionable_bullet_points': [
            'Spray 1% Potassium Nitrate.',
            'Apply dust mulching.',
          ],
        },
        'monitored_hotspots': [
          {
            'hotspot_id': 'RAYALASEEMA_BASIN',
            'name': 'Rayalaseema Basin',
            'state': 'Andhra Pradesh',
            'intensity_tier': 'EXTREME_FLASH_DROUGHT',
            'eddi_2week': 2.15,
            'rootzone_percentile': 8.0,
            'primary_crop': 'Groundnut',
          }
        ],
        'vernacular_bulletins': {
          'en': 'Flash drought alert for Rayalaseema',
          'te': 'రాయలసీమ ఫ్లాష్ కరువు హెచ్చరిక',
        },
        'metadata': {
          'source_authority': 'IMD, CWC & ICAR-CRIDA',
        },
      };

      final model = FlashDroughtResponseModel.fromJson(json);
      expect(model.hotspot.hotspotId, 'RAYALASEEMA_BASIN');
      expect(model.hotspot.state, 'Andhra Pradesh');
      expect(model.overallIntensityTier, 'EXTREME_FLASH_DROUGHT');
      expect(model.rapidIntensificationDetected, isTrue);
      expect(model.atmosphericDemand.referenceEvapotranspirationE0MmDay, 7.2);
      expect(model.soilDesiccation.rootzonePercentile, 8.0);
      expect(model.cropVulnerability.primaryCrop, 'Groundnut');
      expect(model.cropVulnerability.damageMultiplier, 2.05);
      expect(model.directives.actionableBulletPoints.length, 2);
      expect(model.monitoredHotspots.length, 1);
      expect(model.vernacularBulletins['en'], 'Flash drought alert for Rayalaseema');
    });

    test('defaultFallback provides comprehensive offline Vidarbha hotspot telemetry', () {
      final fallback = FlashDroughtResponseModel.defaultFallback();
      expect(fallback.hotspot.hotspotId, 'VIDARBHA_HOTSPOT');
      expect(fallback.hotspot.state, 'Maharashtra');
      expect(fallback.rapidIntensificationDetected, isTrue);
      expect(fallback.cropVulnerability.primaryCrop, 'Soybean');
      expect(fallback.soilDesiccation.rootzonePercentile, 11.5);
      expect(fallback.atmosphericDemand.eddi2week, 1.75);
      expect(fallback.monitoredHotspots.length, 7);
      expect(fallback.vernacularBulletins.containsKey('en'), isTrue);
      expect(fallback.vernacularBulletins.containsKey('hi'), isTrue);
      expect(fallback.vernacularBulletins.containsKey('mr'), isTrue);
      expect(fallback.vernacularBulletins.containsKey('te'), isTrue);
      expect(fallback.vernacularBulletins.containsKey('kn'), isTrue);
    });
  });

  group('FlashDroughtScreen Widget Tests', () {
    testWidgets('renders hero risk card, atmospheric demand, soil desiccation, and directives', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final testData = FlashDroughtResponseModel.defaultFallback();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<WeatherProvider>(
            create: (_) => WeatherProvider(),
            child: FlashDroughtScreen(initialData: testData),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Screen Title
      expect(find.text('Flash Drought & Soil Desiccation'), findsOneWidget);
      expect(find.text('IMD, CWC & ICAR-CRIDA Rapid Drought Engine'), findsOneWidget);

      // Verify Hotspot Hero Card
      expect(find.text('Vidarbha Agro-Ecological Hotspot'), findsOneWidget);
      expect(find.text('SEVERE FLASH DROUGHT'), findsAtLeastNWidgets(1));
      expect(find.text('2-Week EDDI'), findsOneWidget);
      expect(find.text('+1.75'), findsOneWidget);
      expect(find.text('Root Percentile'), findsOneWidget);
      expect(find.text('11.5th'), findsOneWidget);
      expect(find.text('Irrigation Cover'), findsOneWidget);
      expect(find.text('14.5%'), findsOneWidget);

      // Verify Rapid Intensification Alert Banner
      expect(find.textContaining('RAPID INTENSIFICATION DETECTED'), findsOneWidget);

      // Verify Atmospheric Evaporative Thirst & VPD
      expect(find.text('Atmospheric Evaporative Thirst & VPD'), findsOneWidget);
      expect(find.text('Penman-Monteith E0'), findsOneWidget);
      expect(find.text('6.85 mm/d'), findsOneWidget);
      expect(find.text('Vapor Pressure Deficit'), findsOneWidget);
      expect(find.text('2.85 kPa'), findsOneWidget);

      // Verify 2-Depth Soil Desiccation & ESI
      expect(find.text('2-Depth Soil Desiccation & ESI'), findsOneWidget);
      expect(find.text('Topsoil (0-10 cm)'), findsOneWidget);
      expect(find.text('10.2% VWC'), findsOneWidget);
      expect(find.text('Root Zone (10-40 cm)'), findsOneWidget);
      expect(find.text('15.8% VWC'), findsOneWidget);

      // Verify Crop Vulnerability Card
      expect(find.text('Crop Vulnerability: Soybean'), findsOneWidget);
      expect(find.text('Stage: R1-R3 Early Flowering & Pod Initiation'), findsOneWidget);
      expect(find.text('Projected Yield Loss'), findsOneWidget);
      expect(find.text('48.0%'), findsOneWidget);

      // Verify Directives Card
      expect(find.text('ICAR-CRIDA Emergency Directives'), findsOneWidget);
      expect(find.textContaining('Spray 1% Potassium Nitrate (KNO3)'), findsAtLeastNWidgets(1));

      // Verify Vernacular Bulletin
      expect(find.text('Regional Vernacular Bulletin'), findsOneWidget);
      expect(find.textContaining('IMD-CWC FLASH DROUGHT ALERT for Vidarbha Agro-Ecological Hotspot'), findsOneWidget);

      // Verify National Hotspots Grid
      expect(find.text('National Monitored Flash Drought Hotspots'), findsOneWidget);
    });
  });
}
