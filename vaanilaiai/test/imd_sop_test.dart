import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaanilaiai/models/imd_sop_model.dart';
import 'package:vaanilaiai/screens/imd_sop_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('IMD SOP Model Unit Tests', () {
    test('IMDWarningStageModel color getters and JSON serialization', () {
      final stage = IMDWarningStageModel(
        code: 'Red',
        name: 'Warning (Take Action)',
        actionRequired: 'Evacuate low lying areas',
        impactSummary: 'Extreme risk to life',
        colorHex: '#C62828',
        precipitationThreshold: '> 204.4 mm / 24h',
        windThreshold: '>= 89 km/h',
        temperatureThreshold: '>= 47°C',
      );

      expect(stage.color, equals(const Color(0xFFC62828)));
      expect(stage.code, 'Red');

      final json = stage.toJson();
      final fromJson = IMDWarningStageModel.fromJson(json);
      expect(fromJson.code, 'Red');
      expect(fromJson.precipitationThreshold, '> 204.4 mm / 24h');

      final green = IMDWarningStageModel.fromJson({'code': 'Green'});
      expect(green.color, equals(const Color(0xFF2E7D32)));
      final yellow = IMDWarningStageModel.fromJson({'code': 'Yellow'});
      expect(yellow.color, equals(const Color(0xFFF9A825)));
      final orange = IMDWarningStageModel.fromJson({'code': 'Orange'});
      expect(orange.color, equals(const Color(0xFFE65100)));
    });

    test('HazardSOPModel icon getters and JSON parsing', () {
      final cyclone = HazardSOPModel(
        hazardId: 'cyclone',
        title: 'Tropical Cyclone',
        severityLevel: 'Red',
        leadTimePhase: 'Landfall',
        immediateActions: ['Action 1', 'Action 2'],
        dos: ['Do 1', 'Do 2'],
        donts: ['Dont 1', 'Dont 2'],
        vulnerableGuidance: 'Protect livestock',
      );

      expect(cyclone.icon, equals(Icons.cyclone_rounded));
      final json = cyclone.toJson();
      final fromJson = HazardSOPModel.fromJson(json);
      expect(fromJson.hazardId, 'cyclone');
      expect(fromJson.dos.length, 2);

      final rain = HazardSOPModel.fromJson({'hazard_id': 'heavy_rainfall_flood'});
      expect(rain.icon, equals(Icons.water_drop_rounded));
      final lightning = HazardSOPModel.fromJson({'hazard_id': 'thunderstorm_lightning'});
      expect(lightning.icon, equals(Icons.flash_on_rounded));
      final heat = HazardSOPModel.fromJson({'hazard_id': 'heatwave'});
      expect(heat.icon, equals(Icons.wb_sunny_rounded));
    });

    test('EmergencyContactModel serialization', () {
      final contact = EmergencyContactModel(
        name: 'National Emergency',
        phoneNumber: '112',
        agency: 'MHA',
        category: 'National Emergency',
      );

      expect(contact.phoneNumber, '112');
      final json = contact.toJson();
      final fromJson = EmergencyContactModel.fromJson(json);
      expect(fromJson.phoneNumber, '112');
      expect(fromJson.agency, 'MHA');
    });

    test('IMDSOPResponseModel defaultFallback provides complete offline catalog', () {
      final fallback = IMDSOPResponseModel.defaultFallback();
      expect(fallback.isOfflineCached, isTrue);
      expect(fallback.warningStages.length, 4);

      final codes = fallback.warningStages.map((s) => s.code).toList();
      expect(codes, containsAll(['Green', 'Yellow', 'Orange', 'Red']));

      expect(fallback.hazardSops.length, 5);
      final hazardIds = fallback.hazardSops.map((h) => h.hazardId).toList();
      expect(hazardIds, containsAll(['cyclone', 'heavy_rainfall_flood', 'thunderstorm_lightning', 'heatwave', 'dense_fog_coldwave']));

      expect(fallback.emergencyContacts.length, 6);
      final numbers = fallback.emergencyContacts.map((c) => c.phoneNumber).toList();
      expect(numbers, containsAll(['112', '1078', '1070', '1077', '108', '101']));
    });
  });

  group('ImdSopScreen Widget Tests', () {
    testWidgets('Renders IMD Warning Matrix and SOPs cleanly', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: ImdSopScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Check AppBar Title
      expect(find.text('IMD Warning Matrix & SOPs'), findsOneWidget);

      // Check Section Headers
      expect(find.text('IMD 4-Stage Warning Color Matrix'), findsOneWidget);
      expect(find.text('Emergency Helplines (24x7 Toll-Free)'), findsOneWidget);
      expect(find.text('Hazard Standard Operating Procedures (SOPs)'), findsOneWidget);

      // Check Emergency Numbers
      expect(find.text('112'), findsOneWidget);
      expect(find.text('1078'), findsOneWidget);
      expect(find.text('1070'), findsOneWidget);

      // Check 4 Stage Chips
      expect(find.text('Green'), findsOneWidget);
      expect(find.text('Yellow'), findsOneWidget);
      expect(find.text('Orange'), findsOneWidget);
      expect(find.text('Red'), findsOneWidget);

      // Check Do's and Don'ts section titles
      expect(find.text('Standard Do\'s (Approved Actions)'), findsOneWidget);
      expect(find.text('Strict Don\'ts (Prohibited Actions)'), findsOneWidget);
    });

    testWidgets('Tapping warning stage chip updates selection card', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: ImdSopScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Red warning stage
      final redChip = find.text('Red');
      expect(redChip, findsOneWidget);
      await tester.tap(redChip);
      await tester.pumpAndSettle();

      expect(find.text('RED'), findsOneWidget);
      expect(find.text('Warning (Take Action)'), findsOneWidget);
      expect(find.textContaining('Extremely Heavy rain (> 204.4 mm / 24h)'), findsOneWidget);
    });

    testWidgets('Tapping emergency contact copies number and shows snackbar', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: ImdSopScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final contact112 = find.text('112');
      expect(contact112, findsOneWidget);
      await tester.tap(contact112);
      await tester.pump(); // trigger SnackBar animation

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Copied'), findsOneWidget);
      expect(find.textContaining('112'), findsWidgets);
    });
  });
}
