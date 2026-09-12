import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaanilaiai/models/agromet_bulletin_model.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/screens/agromet_bulletin_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DistrictAgrometBulletinModel Unit Tests', () {
    test('Model deserializes from complete JSON accurately', () {
      final jsonMap = {
        'district': 'Thanjavur',
        'state': 'Tamil Nadu',
        'bulletin_number': 'GKMS/TN/THAN/2026/74',
        'issue_date': '12-Sep-2026',
        'valid_from': '12-Sep-2026',
        'valid_until': '17-Sep-2026',
        'amfu_center': 'AMFU, Tamil Nadu Agricultural University (TNAU) & KVK',
        'synoptic_weather_summary': 'Light to moderate rainfall spells expected over 5 days.',
        'five_day_forecast': [
          {
            'date': '2026-09-12',
            'day_name': 'Sat',
            'rainfall_mm': 12.5,
            'temp_max_c': 34.0,
            'temp_min_c': 24.0,
            'humidity_morning_pct': 82,
            'humidity_evening_pct': 60,
            'wind_speed_kmh': 14.0,
            'wind_direction_cardinal': 'SW',
            'cloud_cover_octa': 5,
          },
          {
            'date': '2026-09-13',
            'day_name': 'Sun',
            'rainfall_mm': 0.0,
            'temp_max_c': 35.0,
            'temp_min_c': 25.0,
            'humidity_morning_pct': 70,
            'humidity_evening_pct': 52,
            'wind_speed_kmh': 11.0,
            'wind_direction_cardinal': 'W',
            'cloud_cover_octa': 2,
          }
        ],
        'general_farm_advisories': [
          'Ensure drainage channels are clear.',
          'Spray during morning hours.'
        ],
        'crop_advisories': [
          {
            'crop_name': 'Paddy / Rice',
            'stage': 'Tillering',
            'risk_level': 'Watch',
            'advisory_text': 'Maintain 3 cm standing water.',
            'pest_disease_advisory': 'Monitor for blast.',
            'recommended_intervention': 'Spray Tricyclazole if needed.'
          }
        ],
        'livestock_advisories': [
          {
            'livestock_type': 'Dairy Cattle & Buffaloes',
            'risk_level': 'Normal',
            'management_advice': 'Provide cool drinking water and mineral mix.',
            'vaccination_or_disease_alert': 'FMD booster recommended.'
          }
        ],
        'provenance_disclaimer': 'Prepared under ICAR-IMD GKMS protocols.',
        'is_offline_cached': false,
      };

      final model = DistrictAgrometBulletinModel.fromJson(jsonMap);

      expect(model.district, 'Thanjavur');
      expect(model.state, 'Tamil Nadu');
      expect(model.bulletinNumber, 'GKMS/TN/THAN/2026/74');
      expect(model.amfuCenter, contains('TNAU'));
      expect(model.fiveDayForecast.length, 2);
      expect(model.fiveDayForecast[0].rainfallMm, 12.5);
      expect(model.fiveDayForecast[0].cloudCoverOcta, 5);
      expect(model.fiveDayForecast[0].dayName, 'Sat');
      expect(model.cropAdvisories.length, 1);
      expect(model.cropAdvisories[0].cropName, 'Paddy / Rice');
      expect(model.livestockAdvisories.length, 1);
      expect(model.livestockAdvisories[0].livestockType, contains('Cattle'));
      expect(model.isOfflineCached, false);
    });

    test('Roundtrip serialization into JSON preserves all properties', () {
      final original = DistrictAgrometBulletinModel(
        district: 'Pune',
        state: 'Maharashtra',
        bulletinNumber: 'GKMS/MAH/PUNE/2026/55',
        issueDate: '12-Sep-2026',
        validFrom: '12-Sep-2026',
        validUntil: '17-Sep-2026',
        amfuCenter: 'AMFU, MPKV Rahuri',
        synopticWeatherSummary: 'Dry weather expected.',
        fiveDayForecast: [
          AgrometDayForecastModel(
            date: '2026-09-12',
            dayName: 'Sat',
            rainfallMm: 2.0,
            tempMaxC: 31.0,
            tempMinC: 21.0,
            humidityMorningPct: 65,
            humidityEveningPct: 45,
            windSpeedKmh: 10.0,
            windDirectionCardinal: 'NW',
            cloudCoverOcta: 3,
          )
        ],
        generalFarmAdvisories: ['Intercultivation advised.'],
        cropAdvisories: [
          CropAgrometAdvisoryModel(
            cropName: 'Sugarcane',
            stage: 'Grand Growth',
            riskLevel: 'Normal',
            advisoryText: 'Earth up along rows.',
          )
        ],
        livestockAdvisories: [
          LivestockAdvisoryModel(
            livestockType: 'Poultry',
            riskLevel: 'Normal',
            managementAdvice: 'Ventilate sheds.',
          )
        ],
        isOfflineCached: true,
      );

      final jsonMap = original.toJson();
      final roundtrip = DistrictAgrometBulletinModel.fromJson(jsonMap);

      expect(roundtrip.district, 'Pune');
      expect(roundtrip.state, 'Maharashtra');
      expect(roundtrip.bulletinNumber, 'GKMS/MAH/PUNE/2026/55');
      expect(roundtrip.isOfflineCached, true);
      expect(roundtrip.fiveDayForecast[0].rainfallMm, 2.0);
      expect(roundtrip.cropAdvisories[0].cropName, 'Sugarcane');
      expect(roundtrip.livestockAdvisories[0].livestockType, 'Poultry');
    });

    test('Model handles missing fields with safe defaults', () {
      final model = DistrictAgrometBulletinModel.fromJson({});
      expect(model.district, 'District Agromet Zone');
      expect(model.state, 'India');
      expect(model.fiveDayForecast, isEmpty);
      expect(model.cropAdvisories, isEmpty);
      expect(model.livestockAdvisories, isEmpty);
      expect(model.isOfflineCached, false);
    });
  });

  group('AgrometBulletinScreen Widget Tests', () {
    testWidgets('Renders bulletin screen and loads cached data cleanly', (WidgetTester tester) async {
      // Seed SharedPreferences with an offline cached bulletin
      final sampleBulletin = {
        'district': 'Thanjavur',
        'state': 'Tamil Nadu',
        'bulletin_number': 'GKMS/TN/THAN/2026/74',
        'issue_date': '12-Sep-2026',
        'valid_from': '12-Sep-2026',
        'valid_until': '17-Sep-2026',
        'amfu_center': 'AMFU, Tamil Nadu Agricultural University (TNAU) & KVK',
        'synoptic_weather_summary': 'Light to moderate rainfall spells expected across the delta basin.',
        'five_day_forecast': [
          {
            'date': '2026-09-12',
            'day_name': 'Sat',
            'rainfall_mm': 12.5,
            'temp_max_c': 34.0,
            'temp_min_c': 24.0,
            'humidity_morning_pct': 82,
            'humidity_evening_pct': 60,
            'wind_speed_kmh': 14.0,
            'wind_direction_cardinal': 'SW',
            'cloud_cover_octa': 5,
          }
        ],
        'general_farm_advisories': [
          'Drain excess water from low-lying fields.'
        ],
        'crop_advisories': [
          {
            'crop_name': 'Paddy / Rice',
            'stage': 'Tillering',
            'risk_level': 'Watch',
            'advisory_text': 'Maintain 3 cm standing water in paddy fields.',
            'pest_disease_advisory': 'Monitor for blast disease.',
            'recommended_intervention': 'Apply Tricyclazole spray.'
          }
        ],
        'livestock_advisories': [
          {
            'livestock_type': 'Dairy Cattle & Buffaloes',
            'risk_level': 'Normal',
            'management_advice': 'Provide cool drinking water and mineral salt.',
            'vaccination_or_disease_alert': 'Routine HS and BQ vaccinations.'
          }
        ],
        'provenance_disclaimer': 'Prepared in accordance with ICAR-IMD Gramin Krishi Mausam Seva (GKMS) protocols.',
        'is_offline_cached': true,
      };

      final cacheKey = 'agromet_bulletin_Thanjavur_10.79_79.14';
      SharedPreferences.setMockInitialValues({
        cacheKey: json.encode(sampleBulletin),
      });

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<WeatherProvider>(
            create: (_) => _MockAgrometWeatherProvider(),
            child: const AgrometBulletinScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify UI elements
      expect(find.text('Agromet Bulletin (GKMS)'), findsOneWidget);
      expect(find.textContaining('Thanjavur'), findsWidgets);
      expect(find.text('Offline Saved Bulletin'), findsOneWidget);
      expect(find.text('ICAR - IMD GKMS'), findsOneWidget);
      expect(find.text('Synoptic Weather Synopsis'), findsOneWidget);
      expect(find.text('5-Day District Agromet Forecast Matrix'), findsOneWidget);
      expect(find.text('Farm Operations & Spray Directives'), findsOneWidget);
      expect(find.text('Major District Crops - Phenology & Protection'), findsOneWidget);
      expect(find.text('Animal Husbandry & Livestock Management'), findsOneWidget);
      expect(find.text('Paddy / Rice'), findsOneWidget);
      expect(find.text('Dairy Cattle & Buffaloes'), findsOneWidget);
    });
  });
}

class _MockAgrometWeatherProvider extends WeatherProvider {
  @override
  double get latitude => 10.7870;

  @override
  double get longitude => 79.1378;

  @override
  String? get district => 'Thanjavur';

  @override
  String get locationName => 'Thanjavur';

  @override
  bool get isLoading => false;

  @override
  Future<void> fetchWeather({bool forceRefresh = false}) async {}
}
