import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaanilaiai/models/lightning_model.dart';
import 'package:vaanilaiai/models/weather_model.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/screens/lightning_safety_screen.dart';

class _MockWeatherProvider extends ChangeNotifier implements WeatherProvider {
  @override
  WeatherForecastModel? get forecast => null;
  @override
  bool get isLoading => false;
  @override
  String? get errorMessage => null;
  @override
  String get locationName => 'Madurai';
  @override
  double get latitude => 9.9252;
  @override
  double get longitude => 78.1198;
  @override
  String? get district => 'Madurai';
  @override
  String? get state => 'Tamil Nadu';
  @override
  DateTime? get lastFetchedAt => DateTime.now();
  @override
  bool get isStale => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LightningAlertModel Unit Tests', () {
    test('JSON parsing and serialization with flash-to-bang and vernacular', () {
      final json = {
        'location_name': 'Madurai',
        'threat_level': 'Severe',
        'nearest_strike_km': 4.2,
        'flash_to_bang_delay_seconds': 12.3,
        'strikes_last_30m': 38,
        'strike_trend': 'Increasing',
        'cape_thunderstorm_index_j_kg': 1850.0,
        'cape_stability_verdict': 'High Thunderstorm Potential (Rapid Convective Growth)',
        'sound_rumble_audible': true,
        'safety_rule_30_30': 'Flash to bang under 30 seconds = Danger.',
        'shelter_30min_guidance': 'Remain inside safe shelter for at least 30 minutes.',
        'vernacular_directives': {
          'en': 'When thunder roars, go indoors.',
          'ta': 'இடி மின்னல் ஒலிக்கும்போது உடனடியாக பாதுகாப்பான கட்டிடத்திற்குள் செல்லுங்கள்.',
          'hi': 'बिजली की चमक और गड़गड़ाहट के बीच 30 सेकंड से कम समय हो तो तुरंत पक्के मकान में जाएं।'
        },
        'field_safety_guidance': [
          'Evacuate open fields.',
          'Avoid lone trees.',
        ],
        'last_updated': '2026-09-12 00:00:00',
        'data_unavailable': false,
      };

      final model = LightningAlertModel.fromJson(json);
      expect(model.locationName, 'Madurai');
      expect(model.threatLevel, 'Severe');
      expect(model.nearestStrikeKm, 4.2);
      expect(model.flashToBangDelaySeconds, 12.3);
      expect(model.strikesLast30m, 38);
      expect(model.capeThunderstormIndexJKg, 1850.0);
      expect(model.vernacularDirectives['ta'], contains('பாதுகாப்பான'));
      expect(model.fieldSafetyGuidance.length, 2);

      final outJson = model.toJson();
      expect(outJson['nearest_strike_km'], 4.2);
      expect(outJson['flash_to_bang_delay_seconds'], 12.3);
      expect(outJson['data_unavailable'], isFalse);
    });

    test('unavailable factory creates graceful dataUnavailable instance', () {
      final model = LightningAlertModel.unavailable('Varanasi');
      expect(model.dataUnavailable, isTrue);
      expect(model.threatLevel, 'Unknown');
      expect(model.vernacularDirectives['hi'], contains('बिजली'));
    });
  });

  group('LightningSafetyScreen Widget Tests', () {
    testWidgets('Renders radar proximity, 30-30 timer, and CAPE gauge', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final mockAlert = LightningAlertModel(
        locationName: 'Madurai',
        threatLevel: 'Severe',
        nearestStrikeKm: 4.2,
        flashToBangDelaySeconds: 12.3,
        strikesLast30m: 38,
        strikeTrend: 'Increasing',
        capeThunderstormIndexJKg: 1850.0,
        capeStabilityVerdict: 'High Thunderstorm Potential (Rapid Convective Growth)',
        soundRumbleAudible: true,
        safetyRule3030: 'Flash to bang under 30 seconds = Danger.',
        shelter30minGuidance: 'Remain inside safe shelter for at least 30 minutes.',
        vernacularDirectives: {
          'en': 'When thunder roars, go indoors. Seek sturdy shelter immediately.',
          'ta': 'இடி மின்னல் எச்சரிக்கை: திறந்தவெளிகளையோ மரங்களையோ தவிர்க்கவும்.',
          'hi': 'बिजली चमकने और गड़गड़ाहट पर तुरंत पक्के मकान में जाएं।'
        },
        fieldSafetyGuidance: [
          'Evacuate open fields immediately.',
          'Never seek shelter under isolated trees.',
        ],
        lastUpdated: '2026-09-12 00:00:00',
        dataUnavailable: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<WeatherProvider>(
            create: (_) => _MockWeatherProvider(),
            child: LightningSafetyScreen(initialAlert: mockAlert),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Check Title
      expect(find.text('Damini Lightning & 30-30 Safety'), findsOneWidget);

      // Check Threat Level Banner
      expect(find.text('SEVERE THREAT LEVEL'), findsOneWidget);
      expect(find.text('4.2 km'), findsOneWidget);
      expect(find.text('12.3 sec'), findsOneWidget);

      // Check 30-30 Timer Header & Initial State
      expect(find.text('30-30 Safety Shelter Timer'), findsOneWidget);
      expect(find.text('30:00'), findsOneWidget);

      // Check CAPE Value
      expect(find.text('1850 J/kg'), findsOneWidget);

      // Check Vernacular Section
      expect(find.text('Vernacular Rural Directives'), findsOneWidget);
      expect(find.textContaining('When thunder roars'), findsOneWidget);

      // Tap Tamil language chip
      final tamilChip = find.text('தமிழ்');
      expect(tamilChip, findsOneWidget);
      await tester.tap(tamilChip);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('இடி மின்னல் எச்சரிக்கை'), findsOneWidget);

      // Tap Hindi language chip
      final hindiChip = find.text('हिंदी');
      expect(hindiChip, findsOneWidget);
      await tester.tap(hindiChip);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('बिजली चमकने'), findsOneWidget);

      // Tap "Heard Thunder (Reset 30m)" button
      final resetBtn = find.text('Heard Thunder (Reset 30m)');
      expect(resetBtn, findsOneWidget);
      await tester.tap(resetBtn);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('REMAIN IN INDOOR SHELTER'), findsOneWidget);
    });

    testWidgets('Renders honest unavailable state when alert is unavailable', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final unavailableAlert = LightningAlertModel.unavailable('Madurai');

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<WeatherProvider>(
            create: (_) => _MockWeatherProvider(),
            child: LightningSafetyScreen(initialAlert: unavailableAlert),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Lightning Radar Telemetry Unavailable'), findsOneWidget);
      expect(find.text('Retry Connection'), findsOneWidget);
    });
  });
}
