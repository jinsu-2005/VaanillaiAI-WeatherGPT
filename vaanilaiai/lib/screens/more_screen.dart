import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import 'air_quality_screen.dart';
import 'sun_moon_screen.dart';
import 'rainfall_history_screen.dart';
import 'saved_locations_screen.dart';
import 'voice_weather_screen.dart';
import 'settings_screen.dart';
import 'advisories_screen.dart';
import 'climate_screen.dart';
import 'heat_stress_screen.dart';
import 'auth_screen.dart';
import 'agromet_bulletin_screen.dart';
import 'urban_flood_screen.dart';
import 'multi_model_nwp_screen.dart';
import 'imd_sop_screen.dart';
import 'lightning_safety_screen.dart';
import 'marine_ocean_screen.dart';
import 'river_basin_hydro_screen.dart';
import 'monsoon_teleconnections_screen.dart';
import 'cyclone_tracker_screen.dart';

class MoreScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const MoreScreen({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isGuest = authProvider.isGuest;

    final surfaceColor = AppColors.surface(isDark);
    final borderColor = AppColors.border(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);
    final accentBlue = isDark ? AppColors.brandBlueLight : AppColors.brandBlue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Features & Intelligence'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── User Profile Card ────────────────────────────────────────
            InkWell(
              onTap: () {
                if (isGuest) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const AuthScreen()));
                } else {
                  _showProfileDialog(context, authProvider);
                }
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isGuest
                        ? borderColor
                        : accentBlue.withValues(alpha: 0.5),
                    width: isGuest ? 1.0 : 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isGuest ? AppColors.brandBlueContainer : accentBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isGuest
                            ? Icon(Icons.person_outline_rounded,
                                color: accentBlue, size: 28)
                            : Text(
                                user?.displayName.isNotEmpty == true
                                    ? user!.displayName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800),
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                isGuest
                                    ? 'Guest Citizen'
                                    : (user?.displayName ?? 'User'),
                                style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              ),
                              if (!isGuest) ...[
                                const SizedBox(width: 6),
                                Icon(Icons.verified_rounded,
                                    color: accentBlue, size: 16),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isGuest
                                ? 'Tap to sign in & sync across devices'
                                : (user?.roleDisplayName ?? ''),
                            style: TextStyle(
                              color: isGuest ? accentBlue : textSecondary,
                              fontSize: 12,
                              fontWeight: isGuest
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isGuest ? Icons.login_rounded : Icons.chevron_right_rounded,
                      color: accentBlue,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Section: Navigation ──────────────────────────────────────
            _sectionHeader('Navigation', textSecondary),
            const SizedBox(height: 8),
            _buildMenuSection(
              context,
              surfaceColor,
              borderColor,
              textPrimary,
              [
                _MenuItem(Icons.dashboard_rounded, 'Dashboard', accentBlue,
                    () => onNavigateTab(0)),
                _MenuItem(Icons.satellite_alt_rounded, 'Satellite & Radar GIS Map', accentBlue,
                    () => onNavigateTab(1)),
                _MenuItem(Icons.smart_toy_rounded, 'AI WeatherGPT', accentBlue,
                    () => onNavigateTab(2)),
                _MenuItem(Icons.crisis_alert_rounded, 'Disaster Alerts', AppColors.alertRed,
                    () => onNavigateTab(3)),
              ],
            ),

            const SizedBox(height: 20),

            // ── Section: Intelligence Tools ──────────────────────────────
            _sectionHeader('Intelligence Tools', textSecondary),
            const SizedBox(height: 8),
            _buildMenuSection(
              context,
              surfaceColor,
              borderColor,
              textPrimary,
              [
                _MenuItem(Icons.agriculture_rounded, 'Agro & Farmer Advisory',
                    AppColors.alertGreen, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AdvisoriesScreen()));
                }),
                _MenuItem(Icons.description_rounded, 'District Agromet Bulletin (GKMS)',
                    AppColors.alertGreen, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AgrometBulletinScreen()));
                }),
                _MenuItem(Icons.trending_up_rounded, 'Climate Trends & 5Y Analysis',
                    AppColors.alertOrange, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ClimateScreen()));
                }),
                _MenuItem(Icons.eco_rounded, 'Air Quality Index (AQI)',
                    AppColors.alertGreen, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AirQualityScreen()));
                }),
                _MenuItem(Icons.water_drop_rounded, 'Rainfall History',
                    AppColors.weatherRain, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const RainfallHistoryScreen()));
                }),
                _MenuItem(Icons.whatshot_rounded, 'Heat Stress & Wet-Bulb Monitor',
                    AppColors.alertOrange, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const HeatStressScreen()));
                }),
                _MenuItem(Icons.water_damage_rounded, 'Urban Flood & Inundation Risk',
                    AppColors.weatherRain, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const UrbanFloodScreen()));
                }),
                _MenuItem(Icons.hub_rounded, 'NWP Multi-Model Ensemble',
                    AppColors.brandBlue, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const MultiModelNwpScreen()));
                }),
                _MenuItem(Icons.shield_outlined, 'IMD Warning Matrix & SOPs',
                    AppColors.alertRed, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ImdSopScreen()));
                }),
                _MenuItem(Icons.flash_on_rounded, 'Damini Lightning & 30-30 Safety',
                    AppColors.alertOrange, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LightningSafetyScreen()));
                }),
                _MenuItem(Icons.radar_rounded, 'MOSDAC Satellite & DWR Radar',
                    Colors.cyan, () => onNavigateTab(1)),
                _MenuItem(Icons.tsunami_rounded, 'INCOIS Marine & Kallakkadal Swell',
                    Colors.indigoAccent, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const MarineOceanScreen()));
                }),
                _MenuItem(Icons.water_rounded, 'CWC River Basin & Dam Telemetry',
                    Colors.lightBlue, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const RiverBasinHydroScreen()));
                }),
                _MenuItem(Icons.cyclone_rounded, 'Monsoon Teleconnections & LRF',
                    Colors.cyanAccent, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const MonsoonTeleconnectionsScreen()));
                }),
                _MenuItem(Icons.storm_rounded, 'IMD Cyclone & Surge Tracker',
                    AppColors.alertRed, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CycloneTrackerScreen()));
                }),
                _MenuItem(Icons.wb_twilight_rounded, 'Sun & Moon Tracker',
                    AppColors.weatherSunny, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SunMoonScreen()));
                }),
                _MenuItem(Icons.mic_rounded, 'Voice Weather', accentBlue, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const VoiceWeatherScreen()));
                }),
              ],
            ),

            const SizedBox(height: 20),

            // ── Section: Account & Settings ──────────────────────────────
            _sectionHeader('Account & Settings', textSecondary),
            const SizedBox(height: 8),
            _buildMenuSection(
              context,
              surfaceColor,
              borderColor,
              textPrimary,
              [
                _MenuItem(Icons.location_on_rounded, 'Manage Locations',
                    accentBlue, () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SavedLocationsScreen()));
                }),
                _MenuItem(Icons.settings_rounded, 'Settings & Themes', accentBlue,
                    () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()));
                }),
              ],
            ),

            const SizedBox(height: 24),

            // Footer
            Center(
              child: Text(
                'VaanilaiAI v1.0 · Powered by IMD / MoES & Gemini AI',
                style: TextStyle(
                    color: AppColors.textTertiaryC(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
}

  Widget _sectionHeader(String title, Color textSecondary) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    List<_MenuItem> items,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          return Column(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 20),
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
                trailing: Icon(Icons.chevron_right_rounded,
                    color: AppColors.textTertiaryC(
                        Theme.of(context).brightness == Brightness.dark),
                    size: 20),
                onTap: item.onTap,
              ),
              if (!isLast)
                Divider(
                    height: 1,
                    color: borderColor,
                    indent: 62,
                    endIndent: 0),
            ],
          );
        }),
      ),
    );
  }

  void _showProfileDialog(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface(isDark),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.brandBlue,
                child: Text(
                  auth.user?.displayName.isNotEmpty == true
                      ? auth.user!.displayName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                auth.user?.displayName ?? 'User',
                style: TextStyle(
                    color: AppColors.textPrimaryC(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                auth.user?.email ?? '',
                style: TextStyle(
                    color: AppColors.textSecondaryC(isDark), fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                auth.user?.roleDisplayName ?? '',
                style: const TextStyle(
                    color: AppColors.brandBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.alertRed,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out to Guest Mode'),
                onPressed: () {
                  auth.signOut();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback onTap;

  const _MenuItem(this.icon, this.title, this.iconColor, this.onTap);
}
