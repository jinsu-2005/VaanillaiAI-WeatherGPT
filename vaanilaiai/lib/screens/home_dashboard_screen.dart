import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../providers/alert_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';
import '../models/lightning_model.dart';
import '../services/api_service.dart';
import '../widgets/alert_banner.dart';
import '../widgets/weather_hero_card.dart';
import '../widgets/hourly_forecast_strip.dart';
import '../widgets/daily_forecast_list.dart';
import '../widgets/language_selector_sheet.dart';
import '../widgets/lightning_threat_card.dart';
import '../widgets/citizen_report_dialog.dart';
import 'location_search_screen.dart';
import 'sky_scanner_screen.dart';
import 'heat_stress_screen.dart';
import 'urban_flood_screen.dart';
import 'multi_model_nwp_screen.dart';
import '../widgets/skeleton_loading.dart';
import '../widgets/data_source_indicator.dart';

class HomeDashboardScreen extends StatefulWidget {
  final Function(int) onNavigateTab;

  const HomeDashboardScreen({super.key, required this.onNavigateTab});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final ApiService _apiService = ApiService();
  LightningAlertModel? _lightningAlert;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLightningAlert();
    });
  }

  Future<void> _fetchLightningAlert() async {
    final wp = Provider.of<WeatherProvider>(context, listen: false);
    try {
      final alert = await _apiService.getLightningAlert(
        latitude: wp.latitude,
        longitude: wp.longitude,
        locationName: wp.locationName,
      );
      if (mounted) {
        setState(() => _lightningAlert = alert);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final alertProvider = Provider.of<AlertProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 950;
    final isTablet = screenWidth >= 650 && !isDesktop;

    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);
    final surfaceColor = AppColors.surface(isDark);
    final borderColor = AppColors.border(isDark);
    final accentBlue = isDark ? AppColors.brandBlueLight : AppColors.brandBlue;

    final curr = weatherProvider.forecast?.current;
    final atmosphericGlow = curr != null
        ? AppColors.atmosphericGlow(curr.conditionIcon, curr.isDay)
        : accentBlue;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: isDesktop ? null : 0,
        leading: isDesktop
            ? null
            : IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => widget.onNavigateTab(6),
              ),
        automaticallyImplyLeading: !isDesktop,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'VaanilaiAI',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: accentBlue,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceHighlight
                      : AppColors.brandBlueContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'WeatherGPT',
                  style: TextStyle(
                    color: isDark ? AppColors.brandBlueLight : AppColors.brandBlueDark,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Search location button
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            icon: Icon(Icons.search_rounded, color: accentBlue, size: 22),
            tooltip: 'Search Indian City or Village',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LocationSearchScreen()),
              );
            },
          ),
          if (!isDesktop) ...[
            // Theme toggle
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: accentBlue,
                size: 20,
              ),
              tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              onPressed: () => themeProvider.toggleTheme(!isDark),
            ),
            // Language switcher
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceHighlight
                      : AppColors.brandBlueContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  localeProvider.currentLanguage.toUpperCase(),
                  style: TextStyle(
                    color: accentBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const LanguageSelectorSheet(),
                );
              },
            ),
          ],
          // Notification Bell with Badge
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            icon: Badge(
              isLabelVisible: alertProvider.alertCount > 0,
              label: Text('${alertProvider.alertCount}'),
              backgroundColor: AppColors.alertRed,
              child: const Icon(Icons.notifications_none_rounded, size: 22),
            ),
            tooltip: 'Weather Alerts',
            onPressed: () => widget.onNavigateTab(3),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: weatherProvider.isLoading && weatherProvider.forecast == null
          ? const WeatherDashboardSkeleton()
          : weatherProvider.errorMessage != null &&
                  weatherProvider.forecast == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.alertRed.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.cloud_off_rounded,
                              color: AppColors.alertRed, size: 48),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Unable to load weather data',
                          style: TextStyle(
                              color: textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          weatherProvider.errorMessage!,
                          style: TextStyle(color: textSecondary, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentBlue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(180, 48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry Connection'),
                          onPressed: () => weatherProvider.fetchWeather(),
                        ),
                      ],
                    ),
                  ),
                )
              : weatherProvider.forecast != null
                  ? RefreshIndicator(
                      color: accentBlue,
                      onRefresh: () async {
                        await weatherProvider.fetchWeather();
                        await alertProvider.fetchAlerts(
                          latitude: weatherProvider.latitude,
                          longitude: weatherProvider.longitude,
                          district: weatherProvider.district,
                          state: weatherProvider.state,
                        );
                      },
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 380,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  center: const Alignment(0.0, -0.9),
                                  radius: 1.2,
                                  colors: [
                                    atmosphericGlow.withValues(alpha: isDark ? 0.16 : 0.09),
                                    atmosphericGlow.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1300),
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.symmetric(
                                  horizontal: (isDesktop || isTablet) ? 24 : 0,
                                  vertical: (isDesktop || isTablet) ? 16 : 0,
                                ),
                                child: (isDesktop || isTablet)
                                    ? _buildDesktopLayout(
                                        context,
                                        weatherProvider,
                                        surfaceColor,
                                        borderColor,
                                        textPrimary,
                                        textSecondary,
                                        isDark,
                                      )
                                    : _buildMobileLayout(
                                        context,
                                        weatherProvider,
                                        surfaceColor,
                                        borderColor,
                                        textPrimary,
                                        textSecondary,
                                        isDark,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
    );
  }

  // ── Desktop two-column layout ─────────────────────────────────────────────
  Widget _buildDesktopLayout(
    BuildContext context,
    WeatherProvider weatherProvider,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final forecast = weatherProvider.forecast!;
    final curr = forecast.current;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (forecast.activeWarnings.any((a) => a.severity.toLowerCase() != 'green')) ...[
          AlertBanner(
            alerts: forecast.activeWarnings
                .where((a) => a.severity.toLowerCase() != 'green')
                .toList(),
            onTap: () => widget.onNavigateTab(3),
          ),
          const SizedBox(height: 12),
        ],
        if (weatherProvider.isStale) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DataSourceIndicator(
              lastUpdated: weatherProvider.lastFetchedAt,
              dataSource: 'stale',
              onRefresh: () => weatherProvider.fetchWeather(forceRefresh: true),
            ),
          ),
        ],
        _buildInstitutionalActions(context, isDark),
        if (_lightningAlert != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: LightningThreatCard(
              alert: _lightningAlert!,
              onRefresh: _fetchLightningAlert,
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left (60%): Hero + Hourly
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  WeatherHeroCard(
                    forecast: forecast,
                    onLocationTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const LocationSearchScreen())),
                  ),
                  const SizedBox(height: 16),
                  HourlyForecastStrip(hourly: forecast.hourly),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Right (40%): 7-Day + Telemetry
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  DailyForecastList(daily: forecast.daily),
                  const SizedBox(height: 16),
                  _TelemetryCard(
                    aqiValue: forecast.airQuality?.aqi,
                    aqiLabel: forecast.airQuality?.category,
                    uvIndex: curr.uvIndex,
                    pressure: curr.pressure,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── Mobile single-column layout ───────────────────────────────────────────
  Widget _buildMobileLayout(
    BuildContext context,
    WeatherProvider weatherProvider,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    final forecast = weatherProvider.forecast!;
    final curr = forecast.current;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (forecast.activeWarnings.any((a) => a.severity.toLowerCase() != 'green'))
          AlertBanner(
            alerts: forecast.activeWarnings
                .where((a) => a.severity.toLowerCase() != 'green')
                .toList(),
            onTap: () => widget.onNavigateTab(3),
          ),
        WeatherHeroCard(
          forecast: forecast,
          onLocationTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const LocationSearchScreen())),
        ),
        if (weatherProvider.isStale) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: DataSourceIndicator(
              lastUpdated: weatherProvider.lastFetchedAt,
              dataSource: 'stale',
              onRefresh: () => weatherProvider.fetchWeather(forceRefresh: true),
            ),
          ),
        ],
        _buildInstitutionalActions(context, isDark),
        if (_lightningAlert != null)
          LightningThreatCard(
            alert: _lightningAlert!,
            onRefresh: _fetchLightningAlert,
          ),
        HourlyForecastStrip(hourly: forecast.hourly),

        // ── Compact 3-metric strip (mobile exclusive) ──────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: _MetricPill(
                  icon: Icons.eco_rounded,
                  iconColor: forecast.airQuality != null ? AppColors.alertGreen : textSecondary,
                  label: 'AQI',
                  value: forecast.airQuality?.aqi != null ? '${forecast.airQuality!.aqi}' : '--',
                  sub: forecast.airQuality?.category ?? 'Unavailable',
                  subColor: forecast.airQuality != null ? AppColors.alertGreen : textSecondary,
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricPill(
                  icon: Icons.wb_sunny_outlined,
                  iconColor: AppColors.weatherSunny,
                  label: 'UV Index',
                  value: curr.uvIndex.round().toString(),
                  sub: curr.uvIndex > 7
                      ? 'Very High'
                      : curr.uvIndex > 5
                          ? 'High'
                          : 'Moderate',
                  subColor: curr.uvIndex > 5
                      ? AppColors.alertOrange
                      : AppColors.alertYellow,
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MetricPill(
                  icon: Icons.compress_rounded,
                  iconColor: AppColors.brandBlue,
                  label: 'Pressure',
                  value: '${curr.pressure.round()}',
                  sub: 'hPa',
                  subColor: AppColors.brandBlue,
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
              ),
            ],
          ),
        ),

        DailyForecastList(daily: forecast.daily),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInstitutionalActions(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // 1. Gemini Sky Vision AI Scanner
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SkyScannerScreen()),
              ),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Sky Vision AI',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // 2. Report Ground Hazard (Citizen Science)
            InkWell(
              onTap: () => showDialog(
                context: context,
                builder: (_) => const CitizenReportDialog(),
              ),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_location_alt_rounded, color: Colors.teal, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Report Hazard',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // 3. Marine & Port Signals
            InkWell(
              onTap: () => widget.onNavigateTab(2),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sailing_rounded, color: Colors.blueAccent, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Marine & PFZ',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // 4. Heat Stress & Wet-Bulb
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HeatStressScreen()),
              ),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.whatshot_rounded, color: AppColors.alertOrange, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Heat Stress & Wet-Bulb',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // 5. Urban Flood & Inundation Index
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UrbanFloodScreen()),
              ),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.water_damage_rounded, color: AppColors.weatherRain, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Urban Flood & Inundation',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // 6. NWP Multi-Model Ensemble
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MultiModelNwpScreen()),
              ),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.hub_rounded, color: AppColors.brandBlue, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'NWP Models (ECMWF/GFS)',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable Telemetry Card (desktop right column) ────────────────────────────
class _TelemetryCard extends StatelessWidget {
  final int? aqiValue;
  final String? aqiLabel;
  final double uvIndex;
  final double pressure;
  final Color surfaceColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;

  const _TelemetryCard({
    this.aqiValue,
    this.aqiLabel,
    required this.uvIndex,
    required this.pressure,
    required this.surfaceColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final uvSub = uvIndex > 7
        ? 'Very High'
        : uvIndex > 5
            ? 'High'
            : 'Moderate';
    final uvColor = uvIndex > 5 ? AppColors.alertOrange : AppColors.alertYellow;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_rounded,
                  color: AppColors.brandBlue, size: 18),
              const SizedBox(width: 8),
              Text(
                'Atmospheric Telemetry',
                style: TextStyle(
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _TelemetryTile(
                label: 'Air Quality',
                value: aqiValue != null ? '$aqiValue AQI' : '--',
                sub: aqiValue != null ? (aqiLabel ?? 'Good') : 'Unavailable',
                color: aqiValue != null ? AppColors.alertGreen : textSecondary,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              _Divider(color: borderColor),
              _TelemetryTile(
                label: 'UV Index',
                value: '${uvIndex.round()} / 11',
                sub: uvSub,
                color: uvColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
              _Divider(color: borderColor),
              _TelemetryTile(
                label: 'Barometer',
                value: '${pressure.round()}',
                sub: 'hPa · Normal',
                color: AppColors.brandBlue,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TelemetryTile extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;
  final Color textPrimary;
  final Color textSecondary;

  const _TelemetryTile({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: textSecondary,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(sub,
            style: TextStyle(
                fontSize: 11,
                color: textSecondary,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final Color color;
  const _Divider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 44, color: color);
  }
}

// ── Mobile metric pill ────────────────────────────────────────────────────────
class _MetricPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String sub;
  final Color subColor;
  final Color surfaceColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;

  const _MetricPill({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.sub,
    required this.subColor,
    required this.surfaceColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.10) : borderColor,
          width: 0.9,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 12),
                const SizedBox(width: 3),
                Text(
                  label,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              sub,
              style: TextStyle(
                color: subColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
