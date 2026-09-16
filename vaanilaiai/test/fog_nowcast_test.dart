import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaanilaiai/models/fog_model.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/screens/fog_nowcast_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('IMD FogPass & Low-Visibility Model Unit Tests', () {
    final sampleJson = {
      'location_name': 'New Delhi (IGI Airport)',
      'latitude': 28.5665,
      'longitude': 77.1031,
      'visibility_meters': 90,
      'visibility_tier': 'Dense Fog',
      'severity_color_hex': '#D32F2F',
      'rvr_status': 'CAT IIIB (Blind Autoland)',
      'rvr_alert_summary': 'RVR 90m: CAT-IIIB Precision Autoland Active. Holding patterns in effect.',
      'physics': {
        'air_temperature_c': 9.8,
        'dew_point_c': 9.5,
        'dew_point_depression_c': 0.3,
        'relative_humidity_percent': 98.0,
        'surface_wind_speed_kmh': 2.5,
        'radiation_inversion_intensity': 'Strong Nocturnal Ground Inversion',
        'fog_type': 'Dense Radiation Fog',
        'formation_onset_time': '02:30 IST',
        'dissipation_expected_time': '10:00 IST',
      },
      'highway_advisory': {
        'expressway_name': 'Yamuna & Eastern Peripheral Expressways',
        'advised_speed_kmh': 30,
        'normal_speed_limit_kmh': 100,
        'following_distance_multiplier': '4x normal spacing (min 100 meters)',
        'hazard_lights_directive': 'Use low-beam yellow fog lamps. Avoid high beams.',
        'pileup_risk_level': 'High',
        'nearest_layby_parking': 'Jewar Toll Plaza Lay-by',
        'action_summary': 'Dense fog corridor. Maximum 30 km/h speed limit.',
      },
      'railway_fogpass': {
        'fogpass_active': true,
        'locomotive_speed_cap_kmh': 60,
        'rail_corridor': 'Delhi-Kanpur-Prayagraj Trunk Route',
        'signal_visibility': 'Signals obscured beyond 30 meters — GPS FogPass active',
        'expected_delay_bracket': '2 to 4 hours delay expected on North-bound trains',
        'detonator_rule_active': true,
      },
      'corridor_stations': [
        {
          'station_id': '42182',
          'station_name': 'New Delhi (IGI Airport & Yamuna Expressway)',
          'state': 'Delhi NCR',
          'latitude': 28.5665,
          'longitude': 77.1031,
          'visibility_meters': 90,
          'visibility_tier': 'Dense Fog',
          'rvr_category': 'CAT IIIB (Blind Autoland)',
          'is_airport': true,
          'distance_km': 0.0,
        },
        {
          'station_id': '42071',
          'station_name': 'Amritsar (GT Road / NH-44 Hub)',
          'state': 'Punjab',
          'latitude': 31.7096,
          'longitude': 74.7973,
          'visibility_meters': 45,
          'visibility_tier': 'Very Dense Fog',
          'rvr_category': 'CAT IIIC (Airport Shutdown)',
          'is_airport': true,
          'distance_km': 395.0,
        },
      ],
      'vernacular_advisories': {
        'en': 'CRITICAL FOG ALERT: Visibility down to 90m. Max safe speed 30 km/h.',
        'hi': 'अत्यधिक घना कोहरा चेतावनी: दृश्यता केवल 90 मीटर है। अधिकतम सुरक्षित गति 30 किमी/घंटा।',
        'pa': 'ਬਹੁਤ ਸੰਘਣੀ ਧੁੰਦ ਚੇਤਾਵਨੀ: ਵਿਜ਼ੀਬਿਲਟੀ ਸਿਰਫ਼ 90 ਮੀਟਰ ਹੈ।',
        'bn': 'ঘন কুয়াশা সতর্কতা: দৃশ্যমানতা মাত্র ৯০ মিটার।',
        'ta': 'அடர்ந்த மூடுபனி எச்சரிக்கை: பார்வை திறன் 90 மீட்டராக குறைந்துள்ளது.',
      },
      'source_provenance': 'IMD Winter Fog Experiment (WiFEX) & MoRTH / NHAI Highway Safety Protocol',
      'generated_at': '2026-09-12T08:00:00Z',
    };

    test('FogNowcastResponseModel parses valid JSON correctly', () {
      final model = FogNowcastResponseModel.fromJson(sampleJson);

      expect(model.locationName, 'New Delhi (IGI Airport)');
      expect(model.visibilityMeters, 90);
      expect(model.visibilityTier, 'Dense Fog');
      expect(model.rvrStatus, 'CAT IIIB (Blind Autoland)');

      // Check physics
      expect(model.physics.dewPointDepressionC, 0.3);
      expect(model.physics.relativeHumidityPercent, 98.0);

      // Check highway advisory
      expect(model.highwayAdvisory.advisedSpeedKmh, 30);
      expect(model.highwayAdvisory.pileupRiskLevel, 'High');

      // Check railway FogPass
      expect(model.railwayFogpass.locomotiveSpeedCapKmh, 60);
      expect(model.railwayFogpass.fogpassActive, isTrue);

      // Check corridor stations
      expect(model.corridorStations.length, 2);
      expect(model.corridorStations.first.stationId, '42182');

      // Check serialization round-trip
      final serialized = model.toJson();
      final roundTrip = FogNowcastResponseModel.fromJson(serialized);
      expect(roundTrip.visibilityMeters, 90);
    });

    test('FogNowcastResponseModel defaultFallback provides safe calibrated defaults', () {
      final fallback = FogNowcastResponseModel.defaultFallback(location: 'Varanasi');
      expect(fallback.locationName, 'Varanasi');
      expect(fallback.visibilityMeters, greaterThan(0));
      expect(fallback.corridorStations.isNotEmpty, isTrue);
      expect(fallback.vernacularAdvisories.containsKey('hi'), isTrue);
      expect(fallback.highwayAdvisory.advisedSpeedKmh, 30);
    });
  });

  group('FogNowcastScreen Widget Tests', () {
    testWidgets('Renders FogNowcastScreen with visibility meter, RVR card, and safety HUDs', (tester) async {
      final weatherProvider = WeatherProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WeatherProvider>.value(value: weatherProvider),
          ],
          child: const MaterialApp(
            home: FogNowcastScreen(),
          ),
        ),
      );

      // Wait for initial fallback load and layout
      await tester.pumpAndSettle();

      // Verify Screen Title
      expect(find.text('IMD FogPass & Low-Visibility'), findsOneWidget);

      // Verify Visibility Meter and Metric
      expect(find.text('METERS VISIBILITY'), findsOneWidget);

      // Verify Aviation RVR section
      expect(find.text('Civil Aviation Runway Visual Range (RVR)'), findsOneWidget);

      // Verify NHAI Expressway section
      expect(find.text('NHAI Expressway Pileup Prevention'), findsOneWidget);

      // Verify Indian Railways FogPass section
      expect(find.text('Indian Railways FogPass Driver Assistance'), findsOneWidget);

      // Scroll to multilingual section
      await tester.scrollUntilVisible(
        find.text('Multilingual Highway Safety Directives'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Verify Multilingual Section and Toggle
      expect(find.text('Multilingual Highway Safety Directives'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('हिंदी'), findsOneWidget);

      // Tap on Hindi language chip
      await tester.tap(find.text('हिंदी'));
      await tester.pumpAndSettle();

      // Verify Hindi advisory is rendered
      expect(find.textContaining('घना कोहरा'), findsOneWidget);
    });
  });
}
