import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/alert_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/network_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/language_selector_sheet.dart';
import '../widgets/network_status_badge.dart';
import '../widgets/offline_status_banner.dart';
import 'home_dashboard_screen.dart';
import 'weather_map_screen.dart';
import 'chat_screen.dart';
import 'alerts_screen.dart';
import 'more_screen.dart';
import 'advisories_screen.dart';
import 'climate_screen.dart';
import 'auth_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// Maps the full 7-tab index to the 5-item mobile nav index
  int get _mobileNavIndex {
    if (_currentIndex <= 3) return _currentIndex;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final alertProvider = Provider.of<AlertProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final networkProvider = Provider.of<NetworkProvider>(context);

    final isDesktop = MediaQuery.of(context).size.width >= 900;

    final surfaceColor = AppColors.surface(isDark);
    final borderColor = AppColors.border(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);
    final accentBlue = isDark ? AppColors.brandBlueLight : AppColors.brandBlue;

    final List<Widget> screens = [
      HomeDashboardScreen(onNavigateTab: _onTabTapped),
      const WeatherMapScreen(),
      const ChatScreen(),
      const AlertsScreen(),
      const AdvisoriesScreen(),
      const ClimateScreen(),
      MoreScreen(onNavigateTab: _onTabTapped),
    ];

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // ─── Desktop Sidebar ──────────────────────────────────────────
            Container(
              width: 256,
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border(right: BorderSide(color: borderColor, width: 1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.brandBlue, AppColors.brandBlueLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(Icons.wb_sunny_rounded,
                                color: Colors.white, size: 22),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VaanilaiAI',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: accentBlue,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              'WeatherGPT • IMD / MoES',
                              style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 1, color: borderColor),
                  const SizedBox(height: 8),

                  // Navigation Items
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      children: [
                        _buildSidebarItem(0, Icons.home_rounded, 'Dashboard',
                            textPrimary, textSecondary, accentBlue),
                        _buildSidebarItem(1, Icons.map_rounded, 'Live Radar Map',
                            textPrimary, textSecondary, accentBlue),
                        _buildSidebarItem(2, Icons.smart_toy_rounded,
                            'AI WeatherGPT', textPrimary, textSecondary, accentBlue),
                        _buildSidebarItem(
                          3,
                          Icons.notifications_rounded,
                          localeProvider.t('alerts'),
                          textPrimary,
                          textSecondary,
                          accentBlue,
                          badgeCount: alertProvider.alertCount,
                        ),
                        _buildSidebarItem(4, Icons.agriculture_rounded,
                            'Agro & Sea Advisories', textPrimary, textSecondary, accentBlue),
                        _buildSidebarItem(5, Icons.trending_up_rounded,
                            'Climate Trends', textPrimary, textSecondary, accentBlue),
                        _buildSidebarItem(6, Icons.grid_view_rounded,
                            'More Features', textPrimary, textSecondary, accentBlue),
                      ],
                    ),
                  ),

                  // Network Connectivity telemetry
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      children: [
                        const NetworkStatusBadge(),
                        const Spacer(),
                        Text(
                          networkProvider.connectionType,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Divider(height: 1, color: borderColor),

                  // User Profile & Controls
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            if (authProvider.isGuest) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const AuthScreen()));
                            } else {
                              _onTabTapped(6);
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceHL(isDark),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: authProvider.isGuest
                                      ? AppColors.brandBlueContainer
                                      : AppColors.brandBlue,
                                  child: Text(
                                    authProvider.isGuest
                                        ? '?'
                                        : (authProvider.user?.displayName
                                                    .isNotEmpty ==
                                                true
                                            ? authProvider.user!.displayName[0]
                                                .toUpperCase()
                                            : 'U'),
                                    style: TextStyle(
                                      color: authProvider.isGuest
                                          ? AppColors.brandBlue
                                          : Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        authProvider.isGuest
                                            ? 'Guest Citizen'
                                            : (authProvider.user?.displayName ??
                                                'User'),
                                        style: TextStyle(
                                            color: textPrimary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        authProvider.isGuest
                                            ? 'Tap to sign in'
                                            : authProvider.user!.roleDisplayName
                                                .split(' ')[0],
                                        style: TextStyle(
                                            color: accentBlue,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Tooltip(
                              message: isDark ? 'Light Mode' : 'Dark Mode',
                              child: IconButton(
                                icon: Icon(
                                  isDark
                                      ? Icons.light_mode_rounded
                                      : Icons.dark_mode_rounded,
                                  color: accentBlue,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    themeProvider.toggleTheme(!isDark),
                              ),
                            ),
                            const NetworkStatusBadge(compact: true),
                            InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) =>
                                      const LanguageSelectorSheet(),
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSurfaceHighlight
                                      : AppColors.brandBlueContainer,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: accentBlue.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  localeProvider.currentLanguage.toUpperCase(),
                                  style: TextStyle(
                                      color: accentBlue,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  const OfflineStatusBanner(),
                  Expanded(
                    child: IndexedStack(
                      index: _currentIndex,
                      children: screens,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // ─── Mobile Layout with M3 NavigationBar ─────────────────────────────
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const OfflineStatusBanner(),
            if (networkProvider.isOffline)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: NetworkStatusBadge(compact: true),
                ),
              ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: screens,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: borderColor, width: 0.8)),
        ),
        child: NavigationBar(
          selectedIndex: _mobileNavIndex,
          onDestinationSelected: (index) {
            if (index == 4) {
              _onTabTapped(6); // "More" maps to index 6
            } else {
              _onTabTapped(index);
            }
          },
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map_rounded),
              label: 'Map',
            ),
            const NavigationDestination(
              icon: Icon(Icons.smart_toy_outlined),
              selectedIcon: Icon(Icons.smart_toy_rounded),
              label: 'AI Chat',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: alertProvider.alertCount > 0,
                label: Text('${alertProvider.alertCount}'),
                backgroundColor: AppColors.alertRed,
                child: const Icon(Icons.notifications_none_rounded),
              ),
              selectedIcon: Badge(
                isLabelVisible: alertProvider.alertCount > 0,
                label: Text('${alertProvider.alertCount}'),
                backgroundColor: AppColors.alertRed,
                child: const Icon(Icons.notifications_rounded),
              ),
              label: localeProvider.t('alerts'),
            ),
            const NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem(
    int index,
    IconData icon,
    String label,
    Color textPrimary,
    Color textSecondary,
    Color accentColor, {
    int badgeCount = 0,
  }) {
    final isSelected = _currentIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _onTabTapped(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border(
                      left: BorderSide(color: accentColor, width: 3),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(icon,
                    color: isSelected ? accentColor : textSecondary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? accentColor : textPrimary,
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (badgeCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.alertRed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
