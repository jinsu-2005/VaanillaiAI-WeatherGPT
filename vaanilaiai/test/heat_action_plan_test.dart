import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaanilaiai/models/heat_action_plan_model.dart';
import 'package:vaanilaiai/screens/heat_action_plan_screen.dart';

void main() {
  group('Heat Action Plan & Solar UV Models', () {
    test('defaultFallback creates valid HAP model with offline flag', () {
      final fallback = HeatActionPlanResponseModel.defaultFallback();
      expect(fallback.isOfflineCached, isTrue);
      expect(fallback.selectedZone.zoneId, 'phalodi_churu_thar');
      expect(fallback.selectedZone.state, 'Rajasthan');
      expect(fallback.selectedZone.alertTier, 'EXTREME_HEAT_RED');
      expect(fallback.selectedZone.thermalMetrics.maxTempC, 49.8);
      expect(fallback.selectedZone.thermalMetrics.departureC, 7.8);
      expect(fallback.selectedZone.uvMetrics.uvIndex, 13.5);
      expect(fallback.selectedZone.uvMetrics.uvCategory, 'EXTREME');
      expect(fallback.selectedZone.municipalDirectives.coolRoofInitiativeActive, isTrue);
      expect(fallback.selectedZone.municipalDirectives.solarReflectanceIndexSri, 82.0);
      expect(fallback.vernacularBulletins.containsKey('hi'), isTrue);
      expect(fallback.vernacularBulletins['hi'], contains('फलोदी'));
    });

    test('fromJson and toJson parse heat action plan metrics correctly', () {
      final sampleJson = {
        'timestamp': '2026-09-12T00:00:00Z',
        'bulletin_number': 'NDMA-IMD/HAP-UVIE/2026-TEST',
        'provenance': 'National Disaster Management Authority Test Provenance',
        'selected_zone': {
          'zone_id': 'ahmedabad_metropolitan',
          'zone_name': 'Ahmedabad Municipal Corporation (AMC Heat Action Plan)',
          'state': 'Gujarat',
          'district': 'Ahmedabad',
          'latitude': 23.0225,
          'longitude': 72.5714,
          'alert_tier': 'SEVERE_HEAT_ALERT_ORANGE',
          'thermal_metrics': {
            'max_temp_c': 44.2,
            'normal_temp_c': 40.5,
            'departure_c': 3.7,
            'consecutive_heatwave_days': 4,
            'relative_humidity_pct': 32.0,
            'wet_bulb_temp_c': 28.1,
            'night_min_temp_c': 30.5,
          },
          'uv_metrics': {
            'uv_index': 11.8,
            'uv_category': 'EXTREME',
            'peak_uv_hour': '12:00 - 15:00',
            'ozone_column_du': 268.0,
            'minimal_erythemal_dose_rate_med_hr': 2.8,
            'time_to_sunburn_minutes': 14,
            'recommended_spf': 50,
          },
          'municipal_directives': {
            'cool_roof_initiative_active': true,
            'solar_reflectance_index_sri': 84.5,
            'bocw_labor_work_suspension_hours': '12:00 - 16:00 (AMC Directive)',
            'active_pyau_water_stations': 420,
            'hospital_heatstroke_beds': 80,
            'emergency_cooling_ice_bath_ready': true,
            'ors_distribution_booths': 210,
          },
          'vulnerable_demographics': [
            'Urban slum residents',
            'Traffic police personnel',
          ],
          'localized_bulletins': {
            'en': 'ORANGE ALERT: AMC Heat Action Plan active across Ahmedabad.',
            'gu': 'ઓરેન્જ એલર્ટ: અમદાવાદ મ્યુનિસિપલ કોર્પોરેશન હીટ એક્શન પ્લાન સક્રિય.',
          },
        },
        'all_zones': [],
        'vernacular_bulletins': {
          'en': 'ORANGE ALERT: AMC Heat Action Plan active across Ahmedabad.',
          'gu': 'ઓરેન્જ એલર્ટ: અમદાવાદ મ્યુનિસિપલ કોર્પોરેશન હીટ એક્શન પ્લાન સક્રિય.',
        },
        'is_offline_cached': false,
      };

      final parsed = HeatActionPlanResponseModel.fromJson(sampleJson);
      expect(parsed.selectedZone.zoneId, 'ahmedabad_metropolitan');
      expect(parsed.selectedZone.state, 'Gujarat');
      expect(parsed.selectedZone.alertTier, 'SEVERE_HEAT_ALERT_ORANGE');
      expect(parsed.selectedZone.thermalMetrics.maxTempC, 44.2);
      expect(parsed.vernacularBulletins['gu'], contains('અમદાવાદ'));

      final serialized = parsed.toJson();
      expect(serialized['selected_zone']['zone_id'], 'ahmedabad_metropolitan');
      expect(serialized['selected_zone']['thermal_metrics']['max_temp_c'], 44.2);
    });
  });

  group('HeatActionPlanScreen Widget Tests', () {
    testWidgets('renders HAP telemetry, UV HUD, and switches vernacular bulletins', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockData = HeatActionPlanResponseModel.defaultFallback();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: HeatActionPlanScreen(initialData: mockData),
        ),
      );

      // Verify screen title and hero metrics
      expect(find.text('Heat Action Plan (HAP)'), findsOneWidget);
      expect(find.text('Phalodi & Churu Arid Desert Corridor'), findsOneWidget);
      expect(find.text('49.8'), findsOneWidget);
      expect(find.text('+7.8'), findsOneWidget);
      expect(find.text('RED ALERT: EXTREME HEATWAVE'), findsOneWidget);
      expect(find.text('13.5'), findsOneWidget);
      expect(find.text('EXTREME HAZARD'), findsOneWidget);

      // Verify English bulletin is shown by default
      expect(find.textContaining('RED ALERT: Extreme severe heatwave emergency in Phalodi corridor'), findsOneWidget);

      // Switch to Hindi bulletin
      final hindiChip = find.text('हिंदी');
      expect(hindiChip, findsOneWidget);
      await tester.tap(hindiChip);
      await tester.pumpAndSettle();

      // Verify Hindi vernacular text appears
      expect(find.textContaining('फलोदी और चुरु क्षेत्र में भीषण लू की आपात स्थिति'), findsOneWidget);
    });
  });
}
