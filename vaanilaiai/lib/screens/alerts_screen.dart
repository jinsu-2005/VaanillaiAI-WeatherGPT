import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alert_model.dart';
import '../providers/alert_provider.dart';
import '../providers/weather_provider.dart';
import '../theme/app_colors.dart';
import 'weather_map_screen.dart';
import 'imd_sop_screen.dart';
import 'cyclone_tracker_screen.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String _selectedFilter = 'All'; // 'All', 'Red', 'Orange', 'Yellow'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final weather = Provider.of<WeatherProvider>(context, listen: false);
      Provider.of<AlertProvider>(context, listen: false).fetchAlerts(
        latitude: weather.latitude,
        longitude: weather.longitude,
        district: weather.district,
        state: weather.state,
      );
    });
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'red':
        return AppColors.alertRed;
      case 'orange':
        return AppColors.alertOrange;
      case 'yellow':
        return AppColors.alertYellow;
      default:
        return AppColors.alertGreen;
    }
  }

  Color _getSeverityBg(String severity, bool isDark) {
    switch (severity.toLowerCase()) {
      case 'red':
        return isDark ? AppColors.alertRedDarkBg : AppColors.alertRedBg;
      case 'orange':
        return isDark ? AppColors.alertOrangeDarkBg : AppColors.alertOrangeBg;
      case 'yellow':
        return isDark ? AppColors.alertYellowDarkBg : AppColors.alertYellowBg;
      default:
        return isDark ? AppColors.alertGreenDarkBg : AppColors.alertGreenBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final alertProvider = Provider.of<AlertProvider>(context);
    final weatherProvider = Provider.of<WeatherProvider>(context);

    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkOutline : AppColors.lightOutline;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    // Combine real live alerts from AlertProvider and WeatherProvider
    final combinedAlerts = <DisasterAlertModel>[];
    if (weatherProvider.forecast != null) {
      combinedAlerts.addAll(weatherProvider.forecast!.activeWarnings);
    }
    for (final a in alertProvider.activeAlerts) {
      if (!combinedAlerts.any((x) => x.alertId == a.alertId)) {
        combinedAlerts.add(a);
      }
    }

    final filterOptions = ['All', 'Red', 'Orange', 'Yellow'];

    final filtered = _selectedFilter == 'All'
        ? combinedAlerts
        : combinedAlerts.where((a) => a.severity.toLowerCase() == _selectedFilter.toLowerCase()).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Alerts Feed',
            onPressed: () {
              alertProvider.fetchAlerts(
                latitude: weatherProvider.latitude,
                longitude: weatherProvider.longitude,
                district: weatherProvider.district,
                state: weatherProvider.state,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.cyclone_rounded),
            tooltip: 'IMD RSMC Cyclone & Surge Tracker',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CycloneTrackerScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'IMD Disaster SOPs & Helplines',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ImdSopScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.map_rounded),
            tooltip: 'View Alert Map',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WeatherMapScreen()));
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMD RSMC Tropical Cyclone & Storm Surge Banner
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CycloneTrackerScreen()));
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.alertRedDarkBg : AppColors.alertRedBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.alertRed.withValues(alpha: 0.4), width: 1.2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cyclone_rounded, color: AppColors.alertRed, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'IMD RSMC Tropical Cyclone & Storm Surge Tracker',
                            style: TextStyle(
                              color: isDark ? Colors.white : AppColors.alertRed,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Track active storms, Dvorak T-scale, 64kt gale cones & coastal inundation',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : AppColors.alertRed,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.alertRed, size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Emergency Hotline Banner & SOP Entry Point
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ImdSopScreen()));
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceHighlight : AppColors.brandBlueContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppColors.darkOutline : AppColors.brandBlue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone_in_talk_rounded, color: AppColors.brandBlue, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'National Helplines: 112 | NDMA 1078 | SDMA 1070 | DDMA 1077',
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextPrimary : AppColors.brandBlueDark,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap for official IMD Warning Matrix & NDMA SOPs (Do\'s & Don\'ts)',
                            style: TextStyle(
                              color: AppColors.brandBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.brandBlue, size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Filter Pills Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filterOptions.map((f) {
                  final isSelected = _selectedFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedFilter = f;
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.brandBlue : (isDark ? AppColors.darkSurfaceHighlight : AppColors.lightSurfaceHighlight),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.brandBlue : borderColor,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          f == 'All' ? 'All Alerts' : '$f Level',
                          style: TextStyle(
                            color: isSelected ? Colors.white : textSecondary,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Live Alerts List or Stable State
            if (filtered.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.alertGreen.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_rounded, color: AppColors.alertGreen, size: 48),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Active Severe Warnings',
                      style: TextStyle(color: textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Atmospheric and radar feeds indicate stable weather conditions for ${weatherProvider.locationName}.',
                      style: TextStyle(color: textSecondary, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final alert = filtered[index];
                  final accentColor = _getSeverityColor(alert.severity);
                  final cardBg = _getSeverityBg(alert.severity, isDark);

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.warning_amber_rounded, color: accentColor, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    alert.headline,
                                    style: TextStyle(
                                      color: isDark ? textPrimary : accentColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    alert.areaDescription,
                                    style: TextStyle(color: textSecondary, fontSize: 11),
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: (alert.source.toLowerCase().contains('official') ||
                                                  alert.source.toLowerCase().contains('imd') ||
                                                  alert.source.toLowerCase().contains('sdma') ||
                                                  alert.source.toLowerCase().contains('ndma'))
                                              ? AppColors.brandBlue.withValues(alpha: isDark ? 0.2 : 0.1)
                                              : (isDark ? AppColors.darkSurfaceHighlight : Colors.black.withValues(alpha: 0.05)),
                                          borderRadius: BorderRadius.circular(5),
                                          border: Border.all(
                                            color: (alert.source.toLowerCase().contains('official') ||
                                                    alert.source.toLowerCase().contains('imd') ||
                                                    alert.source.toLowerCase().contains('sdma') ||
                                                    alert.source.toLowerCase().contains('ndma'))
                                                ? AppColors.brandBlue.withValues(alpha: 0.4)
                                                : (isDark ? AppColors.darkOutline : Colors.black12),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              (alert.source.toLowerCase().contains('official') ||
                                                      alert.source.toLowerCase().contains('imd') ||
                                                      alert.source.toLowerCase().contains('sdma') ||
                                                      alert.source.toLowerCase().contains('ndma'))
                                                  ? Icons.verified_outlined
                                                  : Icons.analytics_outlined,
                                              size: 10,
                                              color: (alert.source.toLowerCase().contains('official') ||
                                                      alert.source.toLowerCase().contains('imd') ||
                                                      alert.source.toLowerCase().contains('sdma') ||
                                                      alert.source.toLowerCase().contains('ndma'))
                                                  ? AppColors.brandBlue
                                                  : textSecondary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              (alert.source.toLowerCase().contains('official') ||
                                                      alert.source.toLowerCase().contains('imd') ||
                                                      alert.source.toLowerCase().contains('sdma') ||
                                                      alert.source.toLowerCase().contains('ndma'))
                                                  ? 'Official • ${alert.source}'
                                                  : 'Forecast Risk • ${alert.source}',
                                              style: TextStyle(
                                                color: (alert.source.toLowerCase().contains('official') ||
                                                        alert.source.toLowerCase().contains('imd') ||
                                                        alert.source.toLowerCase().contains('sdma') ||
                                                        alert.source.toLowerCase().contains('ndma'))
                                                    ? AppColors.brandBlue
                                                    : textSecondary,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (alert.capIdentifier != null && alert.capIdentifier!.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isDark ? Colors.teal.withValues(alpha: 0.2) : Colors.teal.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                              color: Colors.teal.withValues(alpha: 0.5),
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.hub_outlined, size: 10, color: Colors.teal),
                                              const SizedBox(width: 4),
                                              Text(
                                                'NDMA SACHET • CAP v1.2',
                                                style: TextStyle(
                                                  color: isDark ? Colors.tealAccent : Colors.teal.shade800,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (alert.expiresAt.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Valid until ${alert.expiresAt.length >= 10 ? alert.expiresAt.substring(0, 10) : alert.expiresAt}',
                            style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          alert.description,
                          style: TextStyle(color: textPrimary, fontSize: 13, height: 1.35),
                        ),
                        if (alert.vernacularHeadline != null && alert.vernacularHeadline!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurfaceHighlight : Colors.black.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: accentColor.withValues(alpha: 0.25), width: 0.8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    alert.vernacularLanguage ?? 'Regional',
                                    style: TextStyle(color: accentColor, fontSize: 9, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    alert.vernacularHeadline!,
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (alert.instruction != null && alert.instruction!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurfaceHighlight : Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.shield_outlined, color: AppColors.brandBlue, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    alert.instruction!,
                                    style: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    ),
  ),
);
}
}
