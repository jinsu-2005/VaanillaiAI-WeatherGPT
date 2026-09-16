import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaanilaiai/models/saltwater_intrusion_model.dart';
import 'package:vaanilaiai/screens/saltwater_intrusion_screen.dart';

void main() {
  group('INCOIS & CGWB Coastal Estuarine Saltwater Intrusion Model Tests', () {
    test('SaltwaterIntrusionResponseModel defaultFallback creates valid model', () {
      final model = SaltwaterIntrusionResponseModel.defaultFallback();
      expect(model.activeZone.zoneId, 'sundarbans_delta');
      expect(model.activeZone.salinitySeverity, 'SEVERE_SALINE_CONTAMINATION');
      expect(model.allZones.length, 7);
      expect(model.activeZone.estuarineWedge.salineWedgeLengthKm, 28.5);
      expect(model.activeZone.aquiferMetrics.electricalConductivityUsCm, 3850.0);
      expect(model.vernacularBulletins.containsKey('EN'), isTrue);
      expect(model.vernacularBulletins.containsKey('HI'), isTrue);
      expect(model.vernacularBulletins.containsKey('BN'), isTrue);
      expect(model.vernacularBulletins.containsKey('TA'), isTrue);
    });

    test('SaltwaterIntrusionResponseModel serialization roundtrip', () {
      final model = SaltwaterIntrusionResponseModel.defaultFallback();
      final json = model.toJson();
      final parsed = SaltwaterIntrusionResponseModel.fromJson(json);

      expect(parsed.activeZone.zoneName, model.activeZone.zoneName);
      expect(parsed.activeZone.estuarineWedge.estuaryName, model.activeZone.estuarineWedge.estuaryName);
      expect(parsed.allZones.length, model.allZones.length);
    });
  });

  group('SaltwaterIntrusionScreen Widget Tests', () {
    testWidgets('renders SaltwaterIntrusionScreen with telemetry HUD and directives', (tester) async {
      final fallbackData = SaltwaterIntrusionResponseModel.defaultFallback();

      await tester.pumpWidget(
        MaterialApp(
          home: SaltwaterIntrusionScreen(initialData: fallbackData),
        ),
      );
      await tester.pumpAndSettle();

      // Verify app bar title
      expect(find.text('Coastal Saline Intrusion & Aquifers'), findsOneWidget);

      // Verify active zone name
      expect(find.text('Sundarbans Estuarine Delta'), findsWidgets);

      // Verify severity
      expect(find.textContaining('SEVERE SALINE CONTAMINATION'), findsWidgets);

      // Verify wedge telemetry
      expect(find.textContaining('28.5'), findsWidgets);

      // Verify vernacular bulletin is visible
      expect(find.textContaining('INCOIS & CGWB SALINITY BULLETIN'), findsOneWidget);
    });
  });
}
