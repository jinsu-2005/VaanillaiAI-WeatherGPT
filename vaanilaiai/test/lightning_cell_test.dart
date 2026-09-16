import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vaanilaiai/models/lightning_cell_model.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/screens/lightning_cell_screen.dart';

void main() {
  group('IITM & IMD Lightning Cell Models', () {
    test('defaultFallback creates valid model with offline flag', () {
      final fallback = LightningCellResponseModel.defaultFallback();
      expect(fallback.isOfflineFallback, isTrue);
      expect(fallback.corridor.id, 'mayurbhanj_odisha');
      expect(fallback.threatTier, 'EXTREME');
      expect(fallback.cellStage, 'MATURE_SUPERCELL');
      expect(fallback.totalLightning.totalFlashRatePerMin, 68.0);
      expect(fallback.totalLightning.intraCloudRatePerMin, 51.0);
      expect(fallback.totalLightning.cloudToGroundRatePerMin, 17.0);
      expect(fallback.totalLightning.isPositiveCgHazard, isTrue);
      expect(fallback.lightningJump.jumpDetected, isTrue);
      expect(fallback.lightningJump.jumpSeverity, 'CRITICAL');
      expect(fallback.lightningJump.leadTimeMinutes, 25);
      expect(fallback.downburstRisk.microburstCategory, 'SEVERE_WET_MICROBURST');
      expect(fallback.radarEcho.hydrometeorClassification, 'GRAUPEL_HAIL_CORE');
      expect(fallback.radarEcho.hailCoreAloftDetected, isTrue);
      expect(fallback.ndmaGuidelines.antiTreeWarning, contains('71%'));
      expect(fallback.vernacularBulletins.containsKey('od'), isTrue);
      expect(fallback.vernacularBulletins['od'], contains('ବଜ୍ରପାତ'));
    });

    test('fromJson and toJson round-trip parsing', () {
      final fallback = LightningCellResponseModel.defaultFallback();
      final json = fallback.toJson();
      final parsed = LightningCellResponseModel.fromJson(json);

      expect(parsed.corridor.id, fallback.corridor.id);
      expect(parsed.threatTier, fallback.threatTier);
      expect(parsed.totalLightning.totalFlashRatePerMin, fallback.totalLightning.totalFlashRatePerMin);
      expect(parsed.lightningJump.deltaFlashRatePerMinSq, fallback.lightningJump.deltaFlashRatePerMinSq);
      expect(parsed.downburstRisk.estimatedGustSpeedKmh, fallback.downburstRisk.estimatedGustSpeedKmh);
      expect(parsed.radarEcho.reflectivityZhhDbz, fallback.radarEcho.reflectivityZhhDbz);
      expect(parsed.climatology.annualFlashDensityPerSqKm, fallback.climatology.annualFlashDensityPerSqKm);
      expect(parsed.vernacularBulletins.length, fallback.vernacularBulletins.length);
    });
  });

  group('LightningCellScreen Widget Tests', () {
    testWidgets('renders hero threat card, LJA jump HUD, and toggles language and corridor', (tester) async {
      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final weatherProvider = WeatherProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<WeatherProvider>.value(value: weatherProvider),
          ],
          child: MaterialApp(
            home: LightningCellScreen(
              initialAssessment: LightningCellResponseModel.defaultFallback(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check App Title
      expect(find.text('Lightning Cell & Downburst Radar'), findsOneWidget);

      // Check Hero Corridor and Threat
      expect(find.text('Mayurbhanj & Chota Nagpur Corridor'), findsOneWidget);
      expect(find.text('EXTREME THREAT'), findsOneWidget);

      // Check Gatlin-Goodman Lightning Jump HUD
      expect(find.text('Gatlin-Goodman Lightning Jump (LJA)'), findsOneWidget);
      expect(find.text('JUMP: CRITICAL'), findsOneWidget);

      // Check Total Lightning Section
      expect(find.text('Total Lightning Partitioning (IC vs CG)'), findsOneWidget);

      // Check Doppler Dual-Pol Radar Card
      expect(find.text('Doppler Dual-Pol Radar Classification'), findsOneWidget);
      expect(find.text('HAIL CORE ALOFT'), findsOneWidget);

      // Check NDMA Safety Guidelines
      expect(find.text('NDMA Lightning Safety Action Plan'), findsOneWidget);

      // Tap on Odia Language Chip
      final odiaChip = find.text('ଓଡ଼ିଆ');
      expect(odiaChip, findsOneWidget);
      await tester.tap(odiaChip);
      await tester.pumpAndSettle();

      // Verify Odia bulletin text appears
      expect(find.textContaining('ବଜ୍ରପାତ'), findsOneWidget);

      // Verify Corridor chips exist
      expect(find.text('Mayurbhanj (OD)'), findsOneWidget);
      expect(find.text('Brahmaputra (AS)'), findsOneWidget);
      expect(find.text('Gangetic Bengal (WB)'), findsOneWidget);

      // Tap on Hindi Language Chip
      final hindiChip = find.text('हिंदी');
      expect(hindiChip, findsOneWidget);
      await tester.tap(hindiChip);
      await tester.pumpAndSettle();
      expect(find.textContaining('बिजली'), findsOneWidget);
    });
  });
}
