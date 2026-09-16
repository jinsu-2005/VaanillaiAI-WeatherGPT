import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vaanilaiai/models/extended_range_prediction_model.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/screens/extended_range_prediction_screen.dart';

void main() {
  group('IMD, NCMRWF & IITM Extended Range Prediction Model Unit Tests', () {
    test('ErpResponseModel parses valid JSON correctly', () {
      final json = {
        'zone_id': 'indo_gangetic_breadbasket',
        'zone_name': 'Indo-Gangetic Breadbasket',
        'state': 'Punjab & Haryana',
        'current_zone': {
          'zone_id': 'indo_gangetic_breadbasket',
          'zone_name': 'Indo-Gangetic Breadbasket',
          'state': 'Punjab & Haryana',
          'sub_division_name': 'Punjab & Haryana Plains',
          'latitude': 30.7333,
          'longitude': 76.7794,
          'dominant_crops': ['Paddy (Basmati)', 'Bt Cotton', 'Maize', 'Sugarcane'],
          'four_week_forecast': [
            {
              'week_number': 1,
              'date_range_label': 'Week 1: 01 Jul - 07 Jul',
              'rainfall_lpa_departure_pct': 42.5,
              'departure_tier': 'LARGE_EXCESS',
              'rainfall_forecast_mm': 92.4,
              'normal_lpa_rainfall_mm': 64.8,
              'max_temp_anomaly_c': -2.1,
              'min_temp_anomaly_c': -0.8,
              'heatwave_coldwave_probability_pct': 5.0,
              'monsoon_spell_state': 'VIGOROUS_MONSOON_SURGE',
            },
            {
              'week_number': 2,
              'date_range_label': 'Week 2: 08 Jul - 14 Jul',
              'rainfall_lpa_departure_pct': 18.0,
              'departure_tier': 'EXCESS',
              'rainfall_forecast_mm': 75.0,
              'normal_lpa_rainfall_mm': 63.5,
              'max_temp_anomaly_c': -1.2,
              'min_temp_anomaly_c': -0.4,
              'heatwave_coldwave_probability_pct': 8.0,
              'monsoon_spell_state': 'ACTIVE_MONSOON',
            },
            {
              'week_number': 3,
              'date_range_label': 'Week 3: 15 Jul - 21 Jul',
              'rainfall_lpa_departure_pct': -5.0,
              'departure_tier': 'NORMAL',
              'rainfall_forecast_mm': 58.0,
              'normal_lpa_rainfall_mm': 61.0,
              'max_temp_anomaly_c': 0.2,
              'min_temp_anomaly_c': 0.1,
              'heatwave_coldwave_probability_pct': 12.0,
              'monsoon_spell_state': 'NORMAL_MONSOON',
            },
            {
              'week_number': 4,
              'date_range_label': 'Week 4: 22 Jul - 28 Jul',
              'rainfall_lpa_departure_pct': -15.0,
              'departure_tier': 'NORMAL',
              'rainfall_forecast_mm': 50.0,
              'normal_lpa_rainfall_mm': 59.0,
              'max_temp_anomaly_c': 0.8,
              'min_temp_anomaly_c': 0.4,
              'heatwave_coldwave_probability_pct': 15.0,
              'monsoon_spell_state': 'NORMAL_MONSOON',
            },
          ],
          'intra_seasonal_pulse': {
            'bsiso_mode': 'BSISO_1_CANONICAL_30_60D',
            'bsiso_active_phase': 5,
            'bsiso_amplitude': 1.45,
            'northward_propagation_speed_deg_per_day': 1.1,
            'mjo_phase': 'PHASE_5_MARITIME_CONTINENT',
            'mjo_amplitude': 1.62,
            'findlater_jet_speed_kt': 38.5,
            'monsoon_trough_position_latitude': 28.6,
            'break_spell_risk': false,
          },
          'agricultural_contingency': {
            'stress_level': 'LOW_OPTIMAL_MOISTURE',
            'sowing_window_status': 'OPTIMAL_SOWING_ONGOING',
            'contingency_crop_alternatives': [
              'Short-duration Basmati PB-1509',
              'PR-126 Paddy'
            ],
            'irrigation_mitigation_directive':
                'Suspend canal and tubewell irrigation due to excess rainfall.',
            'in_situ_moisture_conservation':
                'Ensure proper field bunding to retain rainwater in paddy fields.',
            'standing_crop_intervention':
                'Drain excess standing water from cotton and maize fields.',
          },
          'vernacular_bulletins': {
            'en': 'Vigorous monsoon spell over Punjab and Haryana with large excess precipitation.',
            'pa': 'ਪੰਜਾਬ ਅਤੇ ਹਰਿਆਣਾ ਵਿੱਚ ਜ਼ੋਰਦਾਰ ਮੌਨਸੂਨ ਬਾਰਿਸ਼। ਝੋਨੇ ਦੀ ਲੁਆਈ ਪੂਰੀ ਕਰੋ।',
          },
        },
        'all_zones': [
          {
            'zone_id': 'indo_gangetic_breadbasket',
            'zone_name': 'Indo-Gangetic Breadbasket',
            'state': 'Punjab & Haryana',
            'sub_division_name': 'Punjab & Haryana Plains',
            'current_monsoon_spell': 'VIGOROUS_MONSOON_SURGE',
            'week1_departure_pct': 42.5,
            'week2_departure_pct': 18.0,
            'contingency_alert_active': false,
          },
        ],
        'last_updated_utc': '2026-09-12T12:00:00Z',
        'data_source': 'IMD, NCMRWF, IITM Pune (CFSv2/NCUM-ER MME) & ICAR-CRIDA',
      };

      final model = ErpResponseModel.fromJson(json);
      expect(model.zoneId, 'indo_gangetic_breadbasket');
      expect(model.zoneName, 'Indo-Gangetic Breadbasket');
      expect(model.state, 'Punjab & Haryana');
      expect(model.currentZone.fourWeekForecast.length, 4);
      expect(model.currentZone.fourWeekForecast[0].departureTier, 'LARGE_EXCESS');
      expect(model.currentZone.fourWeekForecast[0].rainfallForecastMm, 92.4);
      expect(model.currentZone.fourWeekForecast[0].monsoonSpellState, 'VIGOROUS_MONSOON_SURGE');
      expect(model.currentZone.intraSeasonalPulse.bsisoActivePhase, 5);
      expect(model.currentZone.intraSeasonalPulse.findlaterJetSpeedKt, 38.5);
      expect(model.currentZone.intraSeasonalPulse.monsoonTroughPositionLatitude, 28.6);
      expect(model.currentZone.agriculturalContingency.stressLevel, 'LOW_OPTIMAL_MOISTURE');
      expect(model.currentZone.vernacularBulletins['pa'], contains('ਝੋਨੇ'));
      expect(model.allZones.length, 1);
    });

    test('ErpResponseModel defaultFallback provides calibrated Vidarbha break monsoon baseline', () {
      final fallback = ErpResponseModel.defaultFallback();
      expect(fallback.zoneId, 'vidarbha_central_rainfed');
      expect(fallback.zoneName, 'Central India Rainfed Soybean-Cotton Zone');
      expect(fallback.state, 'Maharashtra');
      expect(fallback.currentZone.fourWeekForecast.length, 4);
      expect(fallback.currentZone.fourWeekForecast[0].departureTier, 'DEFICIENT');
      expect(fallback.currentZone.fourWeekForecast[0].rainfallLpaDeparturePct, -42.0);
      expect(fallback.currentZone.fourWeekForecast[0].monsoonSpellState, 'BREAK_MONSOON_CRITICAL');
      expect(fallback.currentZone.intraSeasonalPulse.bsisoActivePhase, 7);
      expect(fallback.currentZone.intraSeasonalPulse.breakSpellRisk, true);
      expect(fallback.currentZone.agriculturalContingency.stressLevel, 'WARNING_PROLONGED_DRY_SPELL');
      expect(fallback.allZones.length, 7);

      // Verify regional bulletins for all 8 languages
      final bulletins = fallback.currentZone.vernacularBulletins;
      expect(bulletins.containsKey('en'), true);
      expect(bulletins.containsKey('hi'), true);
      expect(bulletins.containsKey('mr'), true);
      expect(bulletins.containsKey('te'), true);
      expect(bulletins.containsKey('pa'), true);
      expect(bulletins.containsKey('bn'), true);
      expect(bulletins.containsKey('gu'), true);
      expect(bulletins.containsKey('kn'), true);

      expect(bulletins['mr'], contains('विदर्भ'));
      expect(bulletins['hi'], contains('मध्य भारत'));
    });
  });

  group('ExtendedRangePredictionScreen Widget Tests', () {
    testWidgets('Renders ExtendedRangePredictionScreen with zone selector, spell HUD, 4-week matrix, BSISO telemetry, ICAR directives, and language switcher',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final weatherProvider = WeatherProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WeatherProvider>.value(value: weatherProvider),
          ],
          child: MaterialApp(
            home: ExtendedRangePredictionScreen(
              initialData: ErpResponseModel.defaultFallback(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify AppBar title & subtitle
      expect(find.text('Monsoon Extended Range (ERP)'), findsOneWidget);
      expect(find.text('IMD, NCMRWF & IITM 4-Week Multi-Model Ensemble'), findsOneWidget);

      // Verify Agro-climatic zones section
      expect(find.text('AGRO-CLIMATIC MONSOON ZONES'), findsOneWidget);
      expect(find.text('7 Monitored Belts'), findsOneWidget);

      // Verify Hero Spell Status Card
      expect(find.text('Central India Rainfed Soybean-Cotton Zone'), findsOneWidget);
      expect(find.text('BREAK MONSOON CRITICAL'), findsWidgets);
      expect(find.text('Sub-Division: Vidarbha & West Madhya Pradesh (Maharashtra)'), findsOneWidget);
      expect(find.text('Soybean (JS 335, JS 9560)'), findsOneWidget);

      // Verify 4-Week Multi-Model Ensemble Matrix
      expect(find.text('4-WEEK MULTI-MODEL ENSEMBLE FORECAST MATRIX'), findsOneWidget);
      expect(find.text('Week 1: Days 1–7 (12–18 Sep)'), findsOneWidget);
      expect(find.text('Week 2: Days 8–14 (19–25 Sep)'), findsOneWidget);
      expect(find.text('Week 3: Days 15–21 (26 Sep – 02 Oct)'), findsOneWidget);
      expect(find.text('Week 4: Days 22–28 (03–09 Oct)'), findsOneWidget);

      // Verify Intra-Seasonal Monsoon Pulse Telemetry HUD
      expect(find.text('INTRA-SEASONAL MONSOON PULSE (BSISO & MJO)'), findsOneWidget);
      expect(find.text('BOREAL SUMMER OSCILLATION'), findsOneWidget);
      expect(find.text('NORTHWARD PROPAGATION'), findsOneWidget);
      expect(find.text('MADDEN-JULIAN OSCILLATION'), findsOneWidget);
      expect(find.text('SOMALI / FINDLATER JET (850 hPa)'), findsOneWidget);

      // Verify ICAR-CRIDA District Contingency Directives
      expect(find.text('ICAR-CRIDA DISTRICT CONTINGENCY ADVICE'), findsOneWidget);
      expect(find.text('Emergency Crop Alternatives:'), findsOneWidget);

      // Verify Regional Agro-Met Bulletin Card
      expect(find.text('REGIONAL AGRO-MET BULLETIN'), findsOneWidget);

      // Tap Marathi language chip
      final mrChip = find.text('मराठी (MR)');
      expect(mrChip, findsOneWidget);
      await tester.tap(mrChip);
      await tester.pumpAndSettle();

      // Verify Marathi bulletin content is displayed
      expect(
        find.textContaining('विदर्भ व मध्य भारत हवामान अंदाज'),
        findsOneWidget,
      );
    });
  });
}
