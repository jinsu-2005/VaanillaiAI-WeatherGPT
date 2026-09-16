import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vaanilaiai/models/agri_storage_model.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/screens/agri_storage_screen.dart';

void main() {
  group('IMD & ICAR Post-Harvest Mandi Storage & Grain Defense Model Tests', () {
    test('AgriStorageResponseModel parses valid JSON correctly', () {
      final json = {
        'mandi': {
          'mandi_id': 'KARNAL_APMC',
          'name': 'Karnal New Grain Market',
          'district': 'Karnal',
          'state': 'Haryana',
          'latitude': 29.6857,
          'longitude': 76.9905,
          'primary_commodities': ['Paddy', 'Wheat', 'Mustard'],
          'daily_arrival_metric_tonnes': 14200.0,
          'storage_capacity_metric_tonnes': 95000.0,
          'open_plinth_pct': 42.0,
        },
        'assessment_timestamp': '2026-09-12T06:00:00Z',
        'overall_risk_tier': 'MODERATE_WEATHER_ALERT',
        'ambient_temperature_c': 29.0,
        'ambient_relative_humidity_pct': 72.0,
        'weather_condition': 'Humid Overcast Sky with High Spoilage Vapor',
        'crop_hygroscopic_metrics': [
          {
            'crop_name': 'Paddy',
            'current_moisture_content_pct': 14.8,
            'equilibrium_moisture_content_pct': 14.5,
            'safe_storage_limit_pct': 14.0,
            'moisture_surplus_deficit_pct': 0.8,
            'moisture_state': 'UNSAFE_ELEVATED_MOISTURE',
            'henderson_thompson_k': 1.9e-5,
            'henderson_thompson_c': 35.7,
            'henderson_thompson_n': 2.15,
          },
        ],
        'open_yard_telemetry': {
          'yard_type_label': 'Open Plinth / CAP Storage Yard',
          'surface_inundation_risk_pct': 30.0,
          'forecast_rain_24h_mm': 6.5,
          'forecast_hail_probability_pct': 10.0,
          'wind_gust_kmh': 28.0,
          'dunnage_pallet_elevation_cm': 15.0,
          'waterlogging_clearance_hours': 1.5,
        },
        'fungal_mycotoxin_telemetry': {
          'aflatoxin_b1_risk_level': 'HIGH_FUNGAL_PROLIFERATION',
          'optimal_growth_temp_range': '25°C - 37°C',
          'ambient_temp_c': 29.0,
          'relative_humidity_pct': 72.0,
          'mold_spore_incubation_index': 5.5,
          'fssai_limit_ug_per_kg': 15.0,
          'projected_aflatoxin_ppb': 12.8,
        },
        'storage_directives': {
          'tarpaulin_status': 'HIGH_PRIORITY_PREPOSITIONING',
          'dunnage_pallet_height_recommendation_cm': 15.0,
          'aeration_fan_schedule_recommendation': 'Run aeration fans safely below 70% RH.',
          'open_platform_evacuation_needed': false,
          'recommended_actions': [
            'Maintain minimum 15cm dunnage.',
            'Deploy tarpaulins with sandbag ballasts.',
          ],
        },
        'monitored_mandis': [
          {
            'mandi_id': 'KARNAL_APMC',
            'name': 'Karnal New Grain Market',
            'state': 'Haryana',
            'risk_tier': 'MODERATE_WEATHER_ALERT',
            'predominant_crop': 'Paddy',
            'current_ambient_rh_pct': 72.0,
            'tarpaulin_status': 'HIGH_PRIORITY_PREPOSITIONING',
          }
        ],
        'vernacular_bulletins': {
          'en': 'Mandi storage alert for Karnal',
          'hi': 'करनाल मंडी भंडारण चेतावनी',
        },
        'metadata': {
          'source_authority': 'IMD Agromet & ICAR-CIPHET',
        },
      };

      final model = AgriStorageResponseModel.fromJson(json);
      expect(model.mandi.mandiId, 'KARNAL_APMC');
      expect(model.mandi.name, 'Karnal New Grain Market');
      expect(model.mandi.state, 'Haryana');
      expect(model.overallRiskTier, 'MODERATE_WEATHER_ALERT');
      expect(model.cropHygroscopicMetrics.length, 1);
      expect(model.cropHygroscopicMetrics[0].cropName, 'Paddy');
      expect(model.cropHygroscopicMetrics[0].safeStorageLimitPct, 14.0);
      expect(model.openYardTelemetry.dunnagePalletElevationCm, 15.0);
      expect(model.fungalMycotoxinTelemetry.fssaiLimitUgPerKg, 15.0);
      expect(model.storageDirectives.tarpaulinStatus, 'HIGH_PRIORITY_PREPOSITIONING');
      expect(model.monitoredMandis.length, 1);
      expect(model.vernacularBulletins['en'], 'Mandi storage alert for Karnal');
    });

    test('defaultFallback provides comprehensive offline Khanna APMC telemetry', () {
      final fallback = AgriStorageResponseModel.defaultFallback();
      expect(fallback.mandi.mandiId, 'KHANNA_APMC');
      expect(fallback.mandi.state, 'Punjab');
      expect(fallback.cropHygroscopicMetrics.length, 3);
      expect(fallback.cropHygroscopicMetrics.any((c) => c.cropName == 'Wheat'), isTrue);
      expect(fallback.openYardTelemetry.surfaceInundationRiskPct, 48.0);
      expect(fallback.fungalMycotoxinTelemetry.fssaiLimitUgPerKg, 15.0);
      expect(fallback.monitoredMandis.length, 7);
      expect(fallback.vernacularBulletins.containsKey('en'), isTrue);
      expect(fallback.vernacularBulletins.containsKey('hi'), isTrue);
      expect(fallback.vernacularBulletins.containsKey('pa'), isTrue);
    });
  });

  group('AgriStorageScreen Widget Tests', () {
    testWidgets('renders hero risk card, Henderson-Thompson matrix, and directives', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final testData = AgriStorageResponseModel.defaultFallback();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<WeatherProvider>(
            create: (_) => WeatherProvider(),
            child: AgriStorageScreen(initialData: testData),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Screen Title
      expect(find.text('Mandi Storage & Grain Defense'), findsOneWidget);
      expect(find.text('IMD & ICAR-CIPHET Post-Harvest Weather Engine'), findsOneWidget);

      // Verify Mandi Hero Card
      expect(find.text('Khanna APMC Grain Market'), findsNWidgets(2));
      expect(find.text('HIGH MOISTURE SURGE'), findsAtLeastNWidgets(1));
      expect(find.text('Ambient Temp'), findsOneWidget);
      expect(find.text('28.5°C'), findsOneWidget);
      expect(find.text('Ambient Humidity'), findsOneWidget);
      expect(find.text('76.0%'), findsOneWidget);

      // Verify Henderson-Thompson Equilibrium Moisture (EMC)
      expect(find.text('Henderson-Thompson Equilibrium Moisture (EMC)'), findsOneWidget);
      expect(find.text('Wheat'), findsOneWidget);
      expect(find.text('Paddy'), findsOneWidget);
      expect(find.text('Maize'), findsOneWidget);

      // Verify Aspergillus Flavus & Aflatoxin B1 Threat HUD
      expect(find.text('Aspergillus Flavus & Aflatoxin B1 Threat'), findsOneWidget);
      expect(find.text('HIGH FUNGAL PROLIFERATION'), findsOneWidget);
      expect(find.text('14.2 ppb'), findsOneWidget);
      expect(find.text('FSSAI Limit: 15 ppb'), findsOneWidget);

      // Verify Open Plinth & Yard Exposure
      expect(find.text('Open Plinth & Auction Yard Exposure'), findsOneWidget);
      expect(find.text('24h Rain Forecast'), findsOneWidget);
      expect(find.text('18.5 mm'), findsOneWidget);
      expect(find.text('Hail Probability'), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);

      // Verify Mandi Storage Directives
      expect(find.text('Mandi Storage Directives'), findsOneWidget);
      expect(find.text('IMMEDIATE TIRPAL DEPLOYMENT'), findsOneWidget);
      expect(find.text('Mandatory Operational Steps:'), findsOneWidget);
      expect(find.textContaining('Maintain minimum 15.0 cm wooden dunnage crates'), findsOneWidget);

      // Verify Vernacular Advisory
      expect(find.text('Regional Vernacular Advisory'), findsOneWidget);
      expect(find.textContaining('IMD-ICAR MANDI ALERT for Khanna APMC Grain Market'), findsOneWidget);

      // Verify National Monitored Mandi Hubs
      expect(find.text('National Monitored Mandi Hubs'), findsOneWidget);
    });
  });
}
