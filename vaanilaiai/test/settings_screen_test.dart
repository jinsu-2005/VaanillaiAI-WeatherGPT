import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaanilaiai/providers/auth_provider.dart';
import 'package:vaanilaiai/providers/locale_provider.dart';
import 'package:vaanilaiai/providers/theme_provider.dart';
import 'package:vaanilaiai/screens/settings_screen.dart';

class FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  final UserModel _mockUser = UserModel(
    uid: 'test_uid',
    displayName: 'Jinsu J',
    email: 'jinsu@example.com',
    role: UserRole.citizen,
    isGuest: false,
  );

  @override
  UserModel? get user => _mockUser;

  @override
  bool get isGuest => false;

  @override
  bool get isLoggedIn => true;

  @override
  bool get isLoading => false;

  @override
  String? get errorMessage => null;

  @override
  void clearError() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'is_dark_mode': true,
      'temp_unit': '°C',
      'wind_unit': 'km/h',
      'notifications_enabled': true,
      'app_language': 'en',
    });
  });

  Widget createTestWidget({bool isDark = true}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider<AuthProvider>(create: (_) => FakeAuthProvider()),
      ],
      child: MaterialApp(
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        home: const SettingsScreen(),
      ),
    );
  }

  group('SettingsScreen Developer & Updates Section Tests', () {
    testWidgets('renders Developer section with required developer and SIH 2026 details', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll to ensure elements are built
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Verify DEVELOPER section header
      expect(find.text('DEVELOPER'), findsOneWidget);

      // Verify "Developed by Jinsu J"
      expect(find.text('Developed by Jinsu J'), findsOneWidget);

      // Verify "Developed for Smart India Hackathon (SIH) 2026"
      expect(find.text('Developed for Smart India Hackathon (SIH) 2026'), findsOneWidget);

      // Verify SIH badge tag
      expect(find.text('SIH 2026'), findsOneWidget);
    });

    testWidgets('renders Updates section with check for updates and GitHub repository actions', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll to view Updates section
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Verify UPDATES section header
      expect(find.text('UPDATES'), findsOneWidget);

      // Verify "Latest Updates / Check for Updates" action
      expect(find.text('Latest Updates / Check for Updates'), findsOneWidget);

      // Verify "GitHub Repository"
      expect(find.text('GitHub Repository'), findsOneWidget);
      expect(find.text('jinsu-2005/VaanillaiAI-WeatherGPT'), findsOneWidget);

      // Verify "Download Latest Release"
      expect(find.text('Download Latest Release'), findsOneWidget);
    });

    testWidgets('renders successfully in Light theme', (tester) async {
      await tester.pumpWidget(createTestWidget(isDark: false));
      await tester.pumpAndSettle();

      expect(find.text('ABOUT'), findsOneWidget);

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('DEVELOPER'), findsOneWidget);
      expect(find.text('UPDATES'), findsOneWidget);
      expect(find.text('Developed by Jinsu J'), findsOneWidget);
      expect(find.text('Developed for Smart India Hackathon (SIH) 2026'), findsOneWidget);
    });

    testWidgets('tapping SIH tile opens info dialog with hackathon mission details', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final sihTile = find.text('Developed for Smart India Hackathon (SIH) 2026');
      await tester.ensureVisible(sihTile);
      await tester.tap(sihTile);
      await tester.pumpAndSettle();

      expect(find.text('Smart India Hackathon 2026'), findsOneWidget);
      expect(find.textContaining('Ministry of Earth Sciences (MoES)'), findsWidgets);

      // Close dialog
      final closeButton = find.text('Close');
      expect(closeButton, findsOneWidget);
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      expect(find.text('Smart India Hackathon 2026'), findsNothing);
    });

    testWidgets('tapping Check for Updates triggers status feedback', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final updatesTile = find.text('Latest Updates / Check for Updates');
      await tester.ensureVisible(updatesTile);
      await tester.tap(updatesTile);
      await tester.pump();

      // Verify SnackBar feedback
      expect(find.textContaining('Checking for updates'), findsOneWidget);
    });

    testWidgets('preserves existing About section and action tile', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('ABOUT'), findsOneWidget);
      expect(find.text('About VaanilaiAI'), findsOneWidget);
    });
  });
}
