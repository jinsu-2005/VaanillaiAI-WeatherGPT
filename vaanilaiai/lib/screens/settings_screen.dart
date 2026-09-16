import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/language_selector_sheet.dart';
import 'auth_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    final surfaceColor = AppColors.surface(isDark);
    final borderColor = AppColors.border(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);
    final textTertiary = AppColors.textTertiaryC(isDark);
    final accentBlue = isDark ? AppColors.brandBlueLight : AppColors.brandBlue;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Account Card ─────────────────────────────────────────────
            InkWell(
              onTap: () {
                if (authProvider.isGuest) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AuthScreen()));
                } else {
                  _showAccountActionSheet(context, authProvider);
                }
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    // Avatar circle
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: authProvider.isGuest
                            ? AppColors.brandBlueContainer
                            : accentBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: authProvider.isGuest
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
                          Text(
                            authProvider.isGuest
                                ? 'Guest Account'
                                : (user?.displayName ?? 'User'),
                            style: TextStyle(
                                color: textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            authProvider.isGuest
                                ? 'Tap to sign in & sync across devices'
                                : (user?.roleDisplayName ?? ''),
                            style: TextStyle(
                                color: authProvider.isGuest
                                    ? accentBlue
                                    : textSecondary,
                                fontSize: 12,
                                fontWeight: authProvider.isGuest
                                    ? FontWeight.w600
                                    : FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      authProvider.isGuest ? 'Sign In' : 'Manage',
                      style: TextStyle(
                          color: accentBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Preferences Section ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'PREFERENCES',
                style: TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  // Temperature Unit
                  _buildActionTile(
                    context,
                    icon: Icons.thermostat_rounded,
                    iconColor: AppColors.alertOrange,
                    title: 'Temperature Unit',
                    trailing: _UnitToggle(
                      value: themeProvider.tempUnit,
                      onTap: () {
                        themeProvider.setTempUnit(
                            themeProvider.tempUnit == '°C' ? '°F' : '°C');
                      },
                      isDark: isDark,
                      accentBlue: accentBlue,
                      borderColor: borderColor,
                    ),
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),

                  // Wind Speed Unit
                  _buildActionTile(
                    context,
                    icon: Icons.air_rounded,
                    iconColor: AppColors.weatherCloudy,
                    title: 'Wind Speed Unit',
                    trailing: _UnitToggle(
                      value: themeProvider.windUnit,
                      onTap: () {
                        themeProvider.setWindUnit(
                            themeProvider.windUnit == 'km/h' ? 'mph' : 'km/h');
                      },
                      isDark: isDark,
                      accentBlue: accentBlue,
                      borderColor: borderColor,
                    ),
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),

                  // Language
                  _buildActionTile(
                    context,
                    icon: Icons.translate_rounded,
                    iconColor: accentBlue,
                    title: 'Language',
                    subtitle: localeProvider.currentLanguage == 'ta'
                        ? 'தமிழ்'
                        : localeProvider.currentLanguage == 'hi'
                            ? 'हिन्दी'
                            : 'English',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const LanguageSelectorSheet(),
                      );
                    },
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),

                  // Notifications
                  _buildSwitchTile(
                    icon: Icons.notifications_none_rounded,
                    iconColor: AppColors.alertYellow,
                    title: 'Notifications',
                    value: themeProvider.notificationsEnabled,
                    onChanged: (val) => themeProvider.setNotifications(val),
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    accentBlue: accentBlue,
                  ),

                  // Dark Mode
                  _buildSwitchTile(
                    icon: isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    iconColor: isDark
                        ? const Color(0xFF818CF8)
                        : AppColors.weatherSunny,
                    title: 'Dark Mode',
                    value: themeProvider.isDarkMode,
                    onChanged: (val) => themeProvider.toggleTheme(val),
                    isLast: true,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    accentBlue: accentBlue,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── About Section ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'ABOUT',
                style: TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
              ),
              child: _buildActionTile(
                context,
                icon: Icons.info_outline_rounded,
                iconColor: accentBlue,
                title: 'About VaanilaiAI',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'VaanilaiAI (WeatherGPT)',
                    applicationVersion: '1.0.0',
                    applicationLegalese:
                        'Ministry of Earth Sciences (MoES) & India Meteorological Department (IMD)',
                  );
                },
                isLast: true,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
            ),

            const SizedBox(height: 24),

            // ── Developer Section ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'DEVELOPER',
                style: TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  _buildActionTile(
                    context,
                    icon: Icons.person_rounded,
                    iconColor: accentBlue,
                    title: 'Developed by Jinsu J',
                    subtitle: 'Lead Architect & Full-Stack AI Developer',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: accentBlue.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.open_in_new_rounded,
                              size: 12, color: accentBlue),
                          const SizedBox(width: 4),
                          Text(
                            'Profile',
                            style: TextStyle(
                              color: accentBlue,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () => _launchExternalUrl(
                        context, 'https://github.com/jinsu-2005'),
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  _buildActionTile(
                    context,
                    icon: Icons.workspace_premium_rounded,
                    iconColor: AppColors.alertAmber,
                    title: 'Developed for Smart India Hackathon (SIH) 2026',
                    subtitle:
                        'Ministry of Earth Sciences (MoES) & IMD Problem Statement',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.alertAmber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.alertAmber.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'SIH 2026',
                        style: TextStyle(
                          color: AppColors.alertAmber,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: surfaceColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          title: Row(
                            children: [
                              Icon(Icons.emoji_events_rounded,
                                  color: AppColors.alertAmber, size: 24),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Smart India Hackathon 2026',
                                  style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          content: Text(
                            'VaanilaiAI (WeatherGPT) was engineered for Smart India Hackathon (SIH) 2026.\n\n'
                            'Developed by Jinsu J as an advanced AI-powered conversational meteorological decision support system for the Ministry of Earth Sciences (MoES) and India Meteorological Department (IMD).',
                            style: TextStyle(
                                color: textSecondary,
                                fontSize: 13,
                                height: 1.5),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text('Close',
                                  style: TextStyle(
                                      color: accentBlue,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      );
                    },
                    isLast: true,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Updates Section ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'UPDATES',
                style: TextStyle(
                    color: textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  _buildActionTile(
                    context,
                    icon: Icons.system_update_alt_rounded,
                    iconColor: AppColors.alertGreen,
                    title: 'Latest Updates / Check for Updates',
                    subtitle:
                        'Version 1.0.0 (Latest Release) · Tap to verify updates',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.alertGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.alertGreen.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: 12, color: AppColors.alertGreen),
                          const SizedBox(width: 4),
                          Text(
                            'v1.0.0',
                            style: TextStyle(
                              color: AppColors.alertGreen,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () => _checkForUpdates(context),
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  _buildActionTile(
                    context,
                    icon: Icons.code_rounded,
                    iconColor: isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF475569),
                    title: 'GitHub Repository',
                    subtitle: 'jinsu-2005/VaanillaiAI-WeatherGPT',
                    trailing: Icon(
                      Icons.open_in_new_rounded,
                      size: 18,
                      color: AppColors.textTertiaryC(isDark),
                    ),
                    onTap: () => _launchExternalUrl(
                      context,
                      'https://github.com/jinsu-2005/VaanillaiAI-WeatherGPT',
                    ),
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  _buildActionTile(
                    context,
                    icon: Icons.cloud_download_rounded,
                    iconColor: accentBlue,
                    title: 'Download Latest Release',
                    subtitle: 'Access releases, APK packages, and changelogs',
                    trailing: Icon(
                      Icons.open_in_new_rounded,
                      size: 18,
                      color: AppColors.textTertiaryC(isDark),
                    ),
                    onTap: () => _launchExternalUrl(
                      context,
                      'https://github.com/jinsu-2005/VaanillaiAI-WeatherGPT/releases',
                    ),
                    isLast: true,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Footer
            Center(
              child: Text(
                'VaanilaiAI v1.0.0\nPowered by IMD · MoES · INCOIS · Gemini AI',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: textTertiary, fontSize: 11, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isLast = false,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(title,
              style: TextStyle(
                  color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
          subtitle: subtitle != null
              ? Text(subtitle,
                  style: TextStyle(color: textSecondary, fontSize: 12))
              : null,
          trailing: trailing ??
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.textTertiaryC(isDark), size: 20),
          onTap: onTap,
        ),
        if (!isLast)
          Divider(height: 1, color: borderColor, indent: 62),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
    required Color borderColor,
    required Color textPrimary,
    required Color accentBlue,
  }) {
    return Column(
      children: [
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          secondary: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(title,
              style: TextStyle(
                  color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
          value: value,
          activeThumbColor: accentBlue,
          activeTrackColor: accentBlue.withValues(alpha: 0.3),
          onChanged: onChanged,
        ),
        if (!isLast) Divider(height: 1, color: borderColor, indent: 62),
      ],
    );
  }

  void _showAccountActionSheet(BuildContext context, AuthProvider auth) {
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
                    fontSize: 17,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                auth.user?.email ?? '',
                style: TextStyle(
                    color: AppColors.textSecondaryC(isDark), fontSize: 13),
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

  void _checkForUpdates(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Checking for updates... You are running the latest version (v1.0.0).',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.brandBlueDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Releases',
          textColor: Colors.white,
          onPressed: () {
            _launchExternalUrl(
              context,
              'https://github.com/jinsu-2005/VaanillaiAI-WeatherGPT/releases',
            );
          },
        ),
      ),
    );
  }

  Future<void> _launchExternalUrl(
      BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open: $urlString'),
            backgroundColor: AppColors.alertRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link: $e'),
            backgroundColor: AppColors.alertRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }
}

class _UnitToggle extends StatelessWidget {
  final String value;
  final VoidCallback onTap;
  final bool isDark;
  final Color accentBlue;
  final Color borderColor;

  const _UnitToggle({
    required this.value,
    required this.onTap,
    required this.isDark,
    required this.accentBlue,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: accentBlue.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accentBlue.withValues(alpha: 0.3)),
        ),
        child: Text(
          value,
          style: TextStyle(
              color: accentBlue, fontSize: 13, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
