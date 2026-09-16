import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaanilaiai/models/pest_forewarning_model.dart';
import 'package:vaanilaiai/screens/pest_forewarning_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('IMD Agro-Climatic Pest Forewarning Model Unit Tests', () {
    test('PestForewarningResponseModel parses valid JSON correctly', () {
      final sampleJson = {
        'zone': {
          'zone_id': 6,
          'zone_name': 'Trans-Gangetic Plains Region',
          'key_states': ['Punjab', 'Haryana', 'Delhi'],
          'dominant_crops': ['Wheat', 'Paddy', 'Cotton', 'Mustard'],
          'typical_pest_threats': ['Cotton Whitefly', 'Mustard Aphid'],
        },
        'location_name': 'Punjab & Haryana Plains',
        'latitude': 30.5,
        'longitude': 75.8,
        'timestamp': '2026-09-12T00:00:00Z',
        'highest_risk_level': 'CRITICAL',
        'summary_headline': 'CRITICAL Risk: Potato Late Blight outbreak alert.',
        'telemetry': {
          'temperature_c': 16.5,
          'relative_humidity_pct': 91.0,
          'leaf_wetness_hours': 11.5,
          'cloud_cover_oktas': 5,
          'growing_degree_days_base5': 161.0,
          'consecutive_favorable_days': 3,
        },
        'alerts': [
          {
            'id': 'POTATO_LATE_BLIGHT',
            'name': 'Potato Late Blight',
            'scientific_name': 'Phytophthora infestans',
            'target_crop': 'Potato (Solanum tuberosum)',
            'causal_agent': 'FUNGAL',
            'risk_level': 'CRITICAL',
            'epidemic_condition': 'FAVORABLE',
            'favorable_microclimate_rule': 'RH >= 90% for >= 10h',
            'economic_threshold_level': 'Initial spots on 1-2% leaves',
            'pre_symptomatic_forewarning': 'Wallin Severity Index = 4',
            'organic_biocontrol_directive': 'Spray Trichoderma viride',
            'chemical_emergency_directive': 'Spray Mancozeb 75 WP',
          },
        ],
        'ipm_calendar_actions': [
          'Scout fields twice a week',
        ],
        'multilingual_bulletins': {
          'en': 'IMD GKMS advisory in English.',
          'pa': 'ਮੌਸਮ ਵਿਭਾਗ ਖੇਤੀ ਚੇਤਾਵਨੀ ਪੰਜਾਬੀ ਵਿੱਚ।',
        },
        'all_zones': [
          {
            'zone_id': 6,
            'zone_name': 'Trans-Gangetic Plains Region',
            'key_states': ['Punjab'],
            'dominant_crops': ['Wheat'],
            'typical_pest_threats': ['Aphid'],
          }
        ],
        'provenance_disclaimer': 'ICAR Verified.',
      };

      final model = PestForewarningResponseModel.fromJson(sampleJson);
      expect(model.zone.zoneId, 6);
      expect(model.zone.zoneName, 'Trans-Gangetic Plains Region');
      expect(model.highestRiskLevel, 'CRITICAL');
      expect(model.telemetry.temperatureC, 16.5);
      expect(model.telemetry.leafWetnessHours, 11.5);
      expect(model.alerts.length, 1);
      expect(model.alerts.first.name, 'Potato Late Blight');
      expect(model.multilingualBulletins['pa'], contains('ਮੌਸਮ ਵਿਭਾਗ'));
    });

    test('PestForewarningResponseModel defaultFallback provides safe calibrated defaults', () {
      final fallback = PestForewarningResponseModel.defaultFallback();
      expect(fallback.zone.zoneId, 6);
      expect(fallback.highestRiskLevel, 'CRITICAL');
      expect(fallback.alerts.length, greaterThanOrEqualTo(3));
      expect(fallback.ipmCalendarActions.isNotEmpty, isTrue);
      expect(fallback.multilingualBulletins.containsKey('en'), isTrue);
      expect(fallback.multilingualBulletins.containsKey('hi'), isTrue);
      expect(fallback.multilingualBulletins.containsKey('pa'), isTrue);
      expect(fallback.multilingualBulletins.containsKey('te'), isTrue);
      expect(fallback.multilingualBulletins.containsKey('ta'), isTrue);
    });
  });

  group('PestForewarningScreen Widget Tests', () {
    testWidgets('Renders PestForewarningScreen with overview, telemetry HUD, alerts, and multilingual toggle',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PestForewarningScreen(
            initialZoneId: 6,
            initialData: PestForewarningResponseModel.defaultFallback(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Screen Title
      expect(find.text('Crop Pest & Disease Forewarning'), findsOneWidget);

      // Verify Zone Name & Risk Header
      expect(find.textContaining('Trans-Gangetic Plains Region'), findsWidgets);
      expect(find.textContaining('CRITICAL RISK'), findsOneWidget);

      // Verify Microclimate HUD
      expect(find.text('Canopy Microclimate Infection Index'), findsOneWidget);
      expect(find.text('Leaf Wetness'), findsOneWidget);

      // Scroll to Alerts Section
      await tester.scrollUntilVisible(
        find.textContaining('Pest & Pathogen Epidemiological Alerts'),
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('Pest & Pathogen Epidemiological Alerts'), findsOneWidget);
      expect(find.text('Potato Late Blight'), findsOneWidget);

      // Scroll to IPM Schedule
      await tester.scrollUntilVisible(
        find.textContaining('Integrated Pest Management'),
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('Integrated Pest Management'), findsOneWidget);

      // Scroll down to Multilingual Directives and tap Punjabi chip
      await tester.scrollUntilVisible(
        find.text('ਪੰਜਾਬੀ'),
        200.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('ਪੰਜਾਬੀ'));
      await tester.pumpAndSettle();

      // Verify Punjabi bulletin text
      expect(find.textContaining('ਮੌਸਮ ਵਿਭਾਗ ਖੇਤੀ ਚੇਤਾਵਨੀ'), findsOneWidget);
    });
  });
}
