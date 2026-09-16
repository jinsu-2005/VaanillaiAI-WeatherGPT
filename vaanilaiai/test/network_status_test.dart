import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaanilaiai/providers/network_provider.dart';
import 'package:vaanilaiai/providers/locale_provider.dart';
import 'package:vaanilaiai/providers/weather_provider.dart';
import 'package:vaanilaiai/widgets/network_status_badge.dart';
import 'package:vaanilaiai/widgets/offline_status_banner.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('NetworkProvider Unit Tests', () {
    test('Initializes with custom online status without platform channels', () {
      final onlineProvider = NetworkProvider(initialIsOnline: true, enableListener: false);
      expect(onlineProvider.isOnline, isTrue);
      expect(onlineProvider.isOffline, isFalse);
      expect(onlineProvider.connectionType, 'Wi-Fi');

      final offlineProvider = NetworkProvider(initialIsOnline: false, enableListener: false);
      expect(offlineProvider.isOnline, isFalse);
      expect(offlineProvider.isOffline, isTrue);
      expect(offlineProvider.connectionType, 'Offline');
    });

    test('Transitions from offline to online triggers state change', () {
      final provider = NetworkProvider(initialIsOnline: false, enableListener: false);
      expect(provider.isOnline, isFalse);

      // Simulate coming back online
      provider.setOnlineStatusForTesting(true, results: [ConnectivityResult.wifi]);
      expect(provider.isOnline, isTrue);
      expect(provider.isOffline, isFalse);
      expect(provider.connectionType, 'Wi-Fi');
    });

    test('Correctly identifies cellular / mobile data', () {
      final provider = NetworkProvider(initialIsOnline: true, enableListener: false);
      provider.setOnlineStatusForTesting(true, results: [ConnectivityResult.mobile]);
      expect(provider.connectionType, 'Mobile Data');
    });
  });

  group('NetworkStatusBadge Widget Tests', () {
    testWidgets('Renders Online badge when device is connected', (WidgetTester tester) async {
      final networkProvider = NetworkProvider(initialIsOnline: true, enableListener: false);
      final localeProvider = LocaleProvider();
      final weatherProvider = WeatherProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: networkProvider),
            ChangeNotifierProvider.value(value: localeProvider),
            ChangeNotifierProvider.value(value: weatherProvider),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: NetworkStatusBadge(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Online'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_rounded), findsOneWidget);
    });

    testWidgets('Renders Offline badge and opens details sheet on tap', (WidgetTester tester) async {
      final networkProvider = NetworkProvider(initialIsOnline: false, enableListener: false);
      final localeProvider = LocaleProvider();
      final weatherProvider = WeatherProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: networkProvider),
            ChangeNotifierProvider.value(value: localeProvider),
            ChangeNotifierProvider.value(value: weatherProvider),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: NetworkStatusBadge(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Offline'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);

      // Tap to open connection details modal sheet
      await tester.tap(find.byType(NetworkStatusBadge));
      await tester.pumpAndSettle();

      expect(find.text('Connection Status'), findsOneWidget);
      expect(find.text('No Internet Connection detected'), findsOneWidget);
      expect(find.text('Check Connection'), findsOneWidget);
    });

    testWidgets('Supports localized labels for Tamil and Hindi', (WidgetTester tester) async {
      final networkProvider = NetworkProvider(initialIsOnline: true, enableListener: false);
      final localeProvider = LocaleProvider();
      final weatherProvider = WeatherProvider();

      await localeProvider.setLanguage('ta');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: networkProvider),
            ChangeNotifierProvider.value(value: localeProvider),
            ChangeNotifierProvider.value(value: weatherProvider),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: NetworkStatusBadge(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('ஆன்லைன்'), findsOneWidget);

      await localeProvider.setLanguage('hi');
      await tester.pumpAndSettle();
      expect(find.text('ऑनलाइन'), findsOneWidget);
    });
  });

  group('OfflineStatusBanner Widget Tests', () {
    testWidgets('Remains hidden when app is online', (WidgetTester tester) async {
      final networkProvider = NetworkProvider(initialIsOnline: true, enableListener: false);
      final localeProvider = LocaleProvider();
      final weatherProvider = WeatherProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: networkProvider),
            ChangeNotifierProvider.value(value: localeProvider),
            ChangeNotifierProvider.value(value: weatherProvider),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: OfflineStatusBanner(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('You are offline. Showing cached weather data.'), findsNothing);
      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('Displays warning banner with retry button when offline', (WidgetTester tester) async {
      final networkProvider = NetworkProvider(initialIsOnline: false, enableListener: false);
      final localeProvider = LocaleProvider();
      final weatherProvider = WeatherProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: networkProvider),
            ChangeNotifierProvider.value(value: localeProvider),
            ChangeNotifierProvider.value(value: weatherProvider),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: OfflineStatusBanner(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('You are offline. Showing cached weather data.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    });
  });

  group('Navigation Flow Network Status Integration', () {
    testWidgets('Renders offline status banner and badge in layout when offline', (WidgetTester tester) async {
      final networkProvider = NetworkProvider(initialIsOnline: false);
      final localeProvider = LocaleProvider();
      final weatherProvider = WeatherProvider();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: networkProvider),
            ChangeNotifierProvider.value(value: localeProvider),
            ChangeNotifierProvider.value(value: weatherProvider),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  OfflineStatusBanner(),
                  NetworkStatusBadge(),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Offline banner and badge should both be visible
      expect(find.byType(OfflineStatusBanner), findsOneWidget);
      expect(find.text('You are offline. Showing cached weather data.'), findsOneWidget);
      expect(find.byType(NetworkStatusBadge), findsWidgets);
    });
  });
}
