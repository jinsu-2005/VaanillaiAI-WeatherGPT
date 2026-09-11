import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaanilaiai/models/alert_model.dart';
import 'package:vaanilaiai/theme/app_colors.dart';
import 'package:vaanilaiai/widgets/metric_card.dart';
import 'package:vaanilaiai/widgets/alert_banner.dart';

void main() {
  test('DisasterAlertModel JSON deserialization test', () {
    final json = {
      'alert_id': 'IMD-2026-001',
      'source': 'IMD',
      'category': 'Cyclone Warning',
      'severity': 'Red',
      'urgency': 'Immediate',
      'headline': 'Extremely Heavy Rainfall & Strong Winds',
      'description': 'Squally weather with wind speed reaching 65-75 kmph.',
      'instruction': 'Fishermen advised not to venture into deep sea.',
      'area_description': 'Coastal Kanyakumari and adjoining Gulf of Mannar',
      'district': 'Kanyakumari',
      'state': 'Tamil Nadu',
      'effective_from': '2026-09-02T10:00:00Z',
      'expires_at': '2026-09-03T18:00:00Z',
      'is_active': true,
      'color_hex': '#E53E3E',
    };

    final model = DisasterAlertModel.fromJson(json);
    expect(model.alertId, 'IMD-2026-001');
    expect(model.severity, 'Red');
    expect(model.district, 'Kanyakumari');
    expect(model.isActive, true);
  });

  testWidgets('MetricCard widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MetricCard(
            icon: Icons.water_drop_outlined,
            title: 'Humidity',
            value: '78%',
            subtitle: 'High Moisture',
            accentColor: AppColors.aiCyan,
          ),
        ),
      ),
    );

    expect(find.text('Humidity'), findsOneWidget);
    expect(find.text('78%'), findsOneWidget);
    expect(find.text('High Moisture'), findsOneWidget);
  });

  testWidgets('AlertBanner widget test', (WidgetTester tester) async {
    final alert = DisasterAlertModel(
      alertId: 'IMD-001',
      source: 'IMD',
      category: 'Flood Alert',
      severity: 'Orange',
      urgency: 'Immediate',
      headline: 'Heavy Inflow Expected in Dam Basin',
      description: 'Residents in low lying areas should remain alert.',
      instruction: 'Move livestock to higher ground.',
      areaDescription: 'Pechiparai Basin',
      effectiveFrom: '2026-09-02',
      expiresAt: '2026-09-03',
      isActive: true,
      colorHex: '#F97316',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AlertBanner(alerts: [alert]),
        ),
      ),
    );

    expect(find.text('ORANGE'), findsOneWidget);
    expect(find.text('Flood Alert'), findsOneWidget);
    expect(find.text('Heavy Inflow Expected in Dam Basin'), findsOneWidget);
  });
}
