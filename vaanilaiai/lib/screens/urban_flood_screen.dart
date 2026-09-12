import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../theme/app_colors.dart';
import '../utils/urban_flood_calculator.dart';
import '../widgets/citizen_report_dialog.dart';
import 'river_basin_hydro_screen.dart';

class UrbanFloodScreen extends StatefulWidget {
  const UrbanFloodScreen({super.key});

  @override
  State<UrbanFloodScreen> createState() => _UrbanFloodScreenState();
}

class _UrbanFloodScreenState extends State<UrbanFloodScreen> {
  double _drainCapacity = UrbanFloodCalculator.defaultDrainCapacity;
  double _imperviousRatio = UrbanFloodCalculator.defaultImperviousRatio;
  String _selectedWardType = 'Dense Urban Metro';

  final Map<String, double> _wardTypes = {
    'Dense Urban Metro': 0.85,
    'Sub-Urban Residential': 0.65,
    'Peri-Urban / Open': 0.40,
  };

  final Map<String, double> _drainageCapacities = {
    'Standard Municipal (20 mm/h)': 20.0,
    'Clogged / Silted Drain (10 mm/h)': 10.0,
    'High-Capacity Storm Canal (30 mm/h)': 30.0,
  };

  void _shareFloodAdvisory(UrbanFloodResult res, String locationName) {
    final sb = StringBuffer();
    sb.writeln('🌊 *URBAN FLOOD & WATERLOGGING ADVISORY* 🌊');
    sb.writeln('📍 Location: $locationName');
    sb.writeln('🚨 Inundation Risk Score: ${res.riskScore}/100 (${res.tierName})');
    sb.writeln('📏 Estimated Water Depth: ${res.estimatedWaterDepthInches} inches');
    sb.writeln('🚇 Underpass Status: ${res.underpassStatus}');
    sb.writeln('');
    sb.writeln('📋 *SUMMARY:*');
    sb.writeln(res.summaryText);
    sb.writeln('');
    sb.writeln('🛵 *TWO-WHEELER:* ${res.twoWheelerDirective}');
    sb.writeln('🚗 *CARS & CABS:* ${res.carDirective}');
    sb.writeln('⚡ *ELECTRICAL SAFETY:* ${res.pedestrianDirective}');
    sb.writeln('');
    sb.writeln('Shared via VaanilaiAI Urban Flood Intelligence.');

    Clipboard.setData(ClipboardData(text: sb.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Urban Flood Advisory copied to clipboard!'),
        backgroundColor: AppColors.alertGreen,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weather = Provider.of<WeatherProvider>(context);
    final forecast = weather.forecast;

    final surfaceColor = AppColors.surface(isDark);
    final borderColor = AppColors.border(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);
    final textTertiary = AppColors.textTertiaryC(isDark);
    final accentBlue = isDark ? AppColors.brandBlueLight : AppColors.brandBlue;

    if (forecast == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Urban Flood & Inundation Index')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.water_damage_rounded, size: 56, color: AppColors.weatherRain),
              const SizedBox(height: 16),
              Text(
                'Weather telemetry unavailable for waterlogging computation.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textPrimary, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => weather.fetchWeather(forceRefresh: true),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry Fetch'),
              ),
            ],
          ),
        ),
      );
    }

    final curr = forecast.current;
    final hourly = forecast.hourly;

    // Peak hourly rain and 3h cumulative from hourly forecast
    double peakHourly = curr.precipitation.toDouble();
    for (int i = 0; i < hourly.length && i < 6; i++) {
      final p = hourly[i].precipitation;
      if (p > peakHourly) peakHourly = p;
    }

    double threeHourSum = 0.0;
    for (int i = 0; i < hourly.length && i < 3; i++) {
      threeHourSum += hourly[i].precipitation;
    }

    final floodResult = UrbanFloodCalculator.calculate(
      peakHourlyRainMm: peakHourly,
      threeHourCumulativeMm: threeHourSum,
      drainCapacityMmPerHour: _drainCapacity,
      imperviousSurfaceRatio: _imperviousRatio,
    );

    final hourlyTimeline = UrbanFloodCalculator.calculateHourlyTimeline(hourly);

    Color tierColor = AppColors.alertGreen;
    if (floodResult.tier == UrbanFloodRiskTier.severe) {
      tierColor = AppColors.alertRed;
    } else if (floodResult.tier == UrbanFloodRiskTier.high) {
      tierColor = AppColors.alertOrange;
    } else if (floodResult.tier == UrbanFloodRiskTier.moderate) {
      tierColor = AppColors.alertYellow;
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Urban Flood & Inundation Index',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
            Text(
              '${weather.locationName} • Micro-Catchment Pooling',
              style: TextStyle(fontSize: 11, color: accentBlue, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, size: 20),
            tooltip: 'Share Inundation Advisory',
            onPressed: () => _shareFloodAdvisory(floodResult, weather.locationName),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Refresh',
            onPressed: () => weather.fetchWeather(forceRefresh: true),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 0. CWC River Basin Flood & Dam Telemetry Hub Banner
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RiverBasinHydroScreen(
                          initialLat: weather.latitude,
                          initialLon: weather.longitude,
                          initialLocationName: weather.locationName,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0C4A6E), Color(0xFF0284C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0C4A6E).withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.water_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'CWC River Basin & Dam Telemetry',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.open_in_new_rounded, color: Colors.white70, size: 14),
                                ],
                              ),
                              SizedBox(height: 2),
                              Text(
                                'River Hydrographs • Dam Storage % of FRL • Spillway Alerts',
                                style: TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Colors.white),
                      ],
                    ),
                  ),
                ),

                // 1. Inundation Risk Score Gauge Card
                _buildRiskGaugeCard(floodResult, tierColor, surfaceColor, borderColor, textPrimary, textSecondary, isDark),
                const SizedBox(height: 16),

                // 2. Micro-Catchment Parameter Tuners (Ward density & drain capacity)
                _buildTopologyTunerCard(surfaceColor, borderColor, textPrimary, textSecondary, textTertiary, isDark),
                const SizedBox(height: 16),

                // 3. Hydrological Metric Grid (Street Depth, Peak Rate, Surplus, 3h Accumulation)
                _buildHydrologicalMetricGrid(floodResult, peakHourly, threeHourSum, surfaceColor, borderColor, textPrimary, textSecondary, textTertiary, isDark),
                const SizedBox(height: 16),

                // 4. Critical Hotspot Vulnerability & Underpass Status
                _buildVulnerabilityChecklist(floodResult, weather.locationName, surfaceColor, borderColor, textPrimary, textSecondary, textTertiary, isDark),
                const SizedBox(height: 16),

                // 5. Commuter & Transit Directives
                _buildCommuterDirectivesCard(floodResult, surfaceColor, borderColor, textPrimary, textSecondary, isDark),
                const SizedBox(height: 16),

                // 6. 24-Hour Waterlogging Hourly Risk Timeline
                _buildHourlyTimelineCard(hourlyTimeline, surfaceColor, borderColor, textPrimary, textSecondary, textTertiary, isDark),
                const SizedBox(height: 16),

                // 7. Crowdsourced Citizen Reporting Action Banner
                _buildCrowdsourceBanner(surfaceColor, borderColor, textPrimary, textSecondary, accentBlue, isDark),
                const SizedBox(height: 16),

                // 8. Provenance & Hydrological Disclaimer
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.verified_user_rounded, color: AppColors.alertGreen, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Hydrological model employs the Rational Runoff formula (Q = C·I·A) integrated with municipal drain discharge thresholds (15–25 mm/h). Ground truth may vary with localized garbage blockage.',
                          style: TextStyle(color: textTertiary, fontSize: 10.5, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRiskGaugeCard(
    UrbanFloodResult res,
    Color tierColor,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INUNDATION RISK SCORE',
                    style: TextStyle(color: textSecondary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${res.riskScore}',
                        style: TextStyle(
                          color: tierColor,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        ' / 100',
                        style: TextStyle(color: textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: tierColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: tierColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      res.tierName,
                      style: TextStyle(color: tierColor, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: res.riskScore / 100.0,
              backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(tierColor),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            res.summaryText,
            style: TextStyle(color: textPrimary, fontSize: 13, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildTopologyTunerCard(
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color textTertiary,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: AppColors.brandBlue, size: 18),
              const SizedBox(width: 8),
              Text(
                'Catchment Topology & Drainage Parameters',
                style: TextStyle(color: textPrimary, fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Ward Type Selector
          Text('Ward Built-Up Density:', style: TextStyle(color: textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _wardTypes.keys.map((ward) {
                final isSel = _selectedWardType == ward;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(ward, style: TextStyle(fontSize: 11.5, color: isSel ? Colors.white : null)),
                    selected: isSel,
                    selectedColor: AppColors.brandBlue,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedWardType = ward;
                          _imperviousRatio = _wardTypes[ward]!;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          // Drain Capacity Selector
          Text('Stormwater Drain Capacity:', style: TextStyle(color: textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _drainageCapacities.entries.map((entry) {
                final isSel = (_drainCapacity - entry.value).abs() < 0.1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(entry.key, style: TextStyle(fontSize: 11.5, color: isSel ? Colors.white : null)),
                    selected: isSel,
                    selectedColor: AppColors.brandBlue,
                    onSelected: (val) {
                      if (val) {
                        setState(() => _drainCapacity = entry.value);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHydrologicalMetricGrid(
    UrbanFloodResult res,
    double peakRain,
    double threeHourRain,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color textTertiary,
    bool isDark,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            title: 'EST. WATER DEPTH',
            value: '${res.estimatedWaterDepthInches}"',
            subtitle: res.estimatedWaterDepthInches > 0 ? '${(res.estimatedWaterDepthInches * 2.54).toStringAsFixed(1)} cm pooling' : 'Dry surface',
            icon: Icons.water_rounded,
            iconColor: AppColors.weatherRain,
            surfaceColor: surfaceColor,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textTertiary: textTertiary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            title: 'PEAK RAIN RATE',
            value: '${peakRain.toStringAsFixed(1)} mm/h',
            subtitle: 'Over next 6 hours',
            icon: Icons.speed_rounded,
            iconColor: AppColors.alertOrange,
            surfaceColor: surfaceColor,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textTertiary: textTertiary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            title: 'DRAIN SURPLUS',
            value: '${res.drainSurplusMmPerHour} mm/h',
            subtitle: res.drainSurplusMmPerHour > 0 ? 'Exceeds drain' : 'Within capacity',
            icon: Icons.call_split_rounded,
            iconColor: res.drainSurplusMmPerHour > 0 ? AppColors.alertRed : AppColors.alertGreen,
            surfaceColor: surfaceColor,
            borderColor: borderColor,
            textPrimary: textPrimary,
            textTertiary: textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color surfaceColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textTertiary,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: textTertiary, fontSize: 9.5, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(color: textTertiary, fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildVulnerabilityChecklist(
    UrbanFloodResult res,
    String locationName,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color textTertiary,
    bool isDark,
  ) {
    Color statusColor = AppColors.alertGreen;
    if (res.underpassStatus.contains('Submerged')) {
      statusColor = AppColors.alertRed;
    } else if (res.underpassStatus.contains('Flooding')) {
      statusColor = AppColors.alertOrange;
    } else if (res.underpassStatus.contains('Caution')) {
      statusColor = AppColors.alertYellow;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.crisis_alert_rounded, color: AppColors.alertOrange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Critical Infrastructure Vulnerability',
                        style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  res.underpassStatus,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildHotspotItem(Icons.subway_rounded, '$locationName Railway Underpasses & Subways', res.underpassStatus, statusColor, textPrimary, textTertiary),
          _buildHotspotItem(Icons.add_road_rounded, 'Arterial Ring Road & Low-Level Junctions', res.riskScore > 50 ? 'Severe Gridlock Risk' : 'Normal Traffic', res.riskScore > 50 ? AppColors.alertOrange : AppColors.alertGreen, textPrimary, textTertiary),
          _buildHotspotItem(Icons.waves_rounded, 'Stormwater Canal Outfall Corridors', res.drainSurplusMmPerHour > 0 ? 'Backflow Risk' : 'Free Outflow', res.drainSurplusMmPerHour > 0 ? AppColors.alertOrange : AppColors.alertGreen, textPrimary, textTertiary),
        ],
      ),
    );
  }

  Widget _buildHotspotItem(
    IconData icon,
    String name,
    String status,
    Color statusColor,
    Color textPrimary,
    Color textTertiary,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: textTertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(name, style: TextStyle(color: textPrimary, fontSize: 12.5, fontWeight: FontWeight.w500)),
          ),
          Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildCommuterDirectivesCard(
    UrbanFloodResult res,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.commute_rounded, color: AppColors.brandBlue, size: 18),
              const SizedBox(width: 8),
              Text(
                'Commuter & Transit Directives',
                style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDirectiveRow(Icons.two_wheeler_rounded, 'Two-Wheelers & Scooters', res.twoWheelerDirective, textPrimary, textSecondary),
          const Divider(height: 16),
          _buildDirectiveRow(Icons.directions_car_rounded, 'Cars & Cabs', res.carDirective, textPrimary, textSecondary),
          const Divider(height: 16),
          _buildDirectiveRow(Icons.bolt_rounded, 'Pedestrians & Electrical Safety', res.pedestrianDirective, textPrimary, textSecondary),
        ],
      ),
    );
  }

  Widget _buildDirectiveRow(IconData icon, String title, String directive, Color textPrimary, Color textSecondary) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.brandBlue, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(directive, style: TextStyle(color: textSecondary, fontSize: 12, height: 1.35)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyTimelineCard(
    List<HourlyFloodRiskPoint> timeline,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color textTertiary,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule_rounded, color: AppColors.weatherRain, size: 18),
              const SizedBox(width: 8),
              Text(
                '24-Hour Street Waterlogging Outlook',
                style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: timeline.map((pt) {
                Color ptColor = AppColors.alertGreen;
                if (pt.tier == UrbanFloodRiskTier.severe) {
                  ptColor = AppColors.alertRed;
                } else if (pt.tier == UrbanFloodRiskTier.high) {
                  ptColor = AppColors.alertOrange;
                } else if (pt.tier == UrbanFloodRiskTier.moderate) {
                  ptColor = AppColors.alertYellow;
                }

                return Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E283D) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Text(pt.time, style: TextStyle(color: textPrimary, fontSize: 11.5, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(
                        '${pt.riskScore}',
                        style: TextStyle(color: ptColor, fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.water_drop_rounded, size: 11, color: AppColors.weatherRain),
                            const SizedBox(width: 2),
                            Text('${pt.rainMm}mm', style: TextStyle(color: textSecondary, fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrowdsourceBanner(
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color accentBlue,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A2B44), const Color(0xFF142033)]
              : [const Color(0xFFE0F2FE), const Color(0xFFF0F9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFBAE6FD),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentBlue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.campaign_rounded, color: accentBlue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Witness Waterlogging or Flooding?',
                  style: TextStyle(color: textPrimary, fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Report water depth & road obstacles to alert neighbors and municipal responders.',
                  style: TextStyle(color: textSecondary, fontSize: 11.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const CitizenReportDialog(),
              );
            },
            child: const Text('Report', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
