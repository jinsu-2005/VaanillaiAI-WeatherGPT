import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaanilaiai/models/alert_model.dart';
import 'package:vaanilaiai/providers/alert_provider.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/screens/alerts_screen.dart';

class FakeAlertProvider extends AlertProvider {
  final AlertSummaryModel _summary;
  FakeAlertProvider(this._summary);

  @override
  AlertSummaryModel? get alertSummary => _summary;

  @override
  List<DisasterAlertModel> get activeAlerts => _summary.alerts;

  @override
  Future<void> fetchAlerts({
    double? latitude,
    double? longitude,
    String? district,
    String? state,
  }) async {
    // No-op in widget tests to prevent unmocked HTTP 400
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('NDMA Sachet OASIS CAP Alerts Tests', () {
    final sampleCapJson = {
      'alert_id': 'NDMA-IN-TN-2026-09-001',
      'source': 'NDMA Sachet • Tamil Nadu SDMA',
      'category': 'Heavy Rainfall',
      'severity': 'Red',
      'urgency': 'Immediate',
      'headline': 'Red Alert: Torrential Deluge Expected in Coastal Districts',
      'description': 'Very heavy to extremely heavy rainfall with localized inundation.',
      'instruction': 'Move to designated cyclone/flood shelters immediately.',
      'area_description': 'Chennai, Tamil Nadu',
      'district': 'Chennai',
      'state': 'Tamil Nadu',
      'effective_from': '2026-09-12T00:30:00+05:30',
      'expires_at': '2026-09-13T00:30:00+05:30',
      'is_active': true,
      'color_hex': '#E53E3E',
      'cap_identifier': 'NDMA-IN-TN-2026-09-001',
      'polygon_url': 'https://sachet.ndma.gov.in/cap_public_website/FetchPolygonXMLFile?identifier=NDMA-IN-TN-2026-09-001',
      'vernacular_headline': 'சிவப்பு எச்சரிக்கை: மிகக் கடுமையான கனமழை எதிர்பார்க்கப்படுகிறது',
      'vernacular_language': 'ta-IN',
      'sender_org': 'Tamil Nadu SDMA',
    };

    test('DisasterAlertModel parses CAP XML fields accurately', () {
      final model = DisasterAlertModel.fromJson(sampleCapJson);

      expect(model.alertId, 'NDMA-IN-TN-2026-09-001');
      expect(model.capIdentifier, 'NDMA-IN-TN-2026-09-001');
      expect(model.severity, 'Red');
      expect(model.vernacularHeadline, contains('சிவப்பு எச்சரிக்கை'));
      expect(model.vernacularLanguage, 'ta-IN');
      expect(model.polygonUrl, contains('FetchPolygonXMLFile'));
      expect(model.senderOrg, 'Tamil Nadu SDMA');
    });

    test('AlertSummaryModel parses list of CAP alerts', () {
      final summaryJson = {
        'total_active_alerts': 1,
        'highest_severity': 'Red',
        'alerts': [sampleCapJson],
      };

      final summary = AlertSummaryModel.fromJson(summaryJson);
      expect(summary.totalActiveAlerts, 1);
      expect(summary.highestSeverity, 'Red');
      expect(summary.alerts.first.capIdentifier, 'NDMA-IN-TN-2026-09-001');
    });

    testWidgets('AlertsScreen renders NDMA Sachet CAP v1.2 badge & vernacular text', (tester) async {
      final weatherProvider = WeatherProvider();
      final alert = DisasterAlertModel.fromJson(sampleCapJson);
      final alertProvider = FakeAlertProvider(
        AlertSummaryModel(
          totalActiveAlerts: 1,
          highestSeverity: 'Red',
          alerts: [alert],
        ),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WeatherProvider>.value(value: weatherProvider),
            ChangeNotifierProvider<AlertProvider>.value(value: alertProvider),
          ],
          child: const MaterialApp(
            home: AlertsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the NDMA SACHET • CAP v1.2 badge is displayed
      expect(find.text('NDMA SACHET • CAP v1.2'), findsOneWidget);

      // Verify the vernacular language tag & headline are displayed
      expect(find.text('ta-IN'), findsOneWidget);
      expect(find.text('சிவப்பு எச்சரிக்கை: மிகக் கடுமையான கனமழை எதிர்பார்க்கப்படுகிறது'), findsOneWidget);

      // Verify the main headline and instructions
      expect(find.text('Red Alert: Torrential Deluge Expected in Coastal Districts'), findsOneWidget);
      expect(find.text('Move to designated cyclone/flood shelters immediately.'), findsOneWidget);
    });
  });
}
