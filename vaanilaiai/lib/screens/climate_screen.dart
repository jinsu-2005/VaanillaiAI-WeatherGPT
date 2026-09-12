import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/climate_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/locale_provider.dart';
import '../theme/app_colors.dart';
import 'monsoon_teleconnections_screen.dart';

class ClimateScreen extends StatefulWidget {
  const ClimateScreen({super.key});

  @override
  State<ClimateScreen> createState() => _ClimateScreenState();
}

class _ClimateScreenState extends State<ClimateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final weather = Provider.of<WeatherProvider>(context, listen: false);
      Provider.of<ClimateProvider>(context, listen: false).fetchClimateData(
        latitude: weather.latitude,
        longitude: weather.longitude,
        locationName: weather.locationName,
      );
    });
  }

  void _showYearSelector(
    BuildContext context,
    ClimateProvider climateProvider,
    WeatherProvider weatherProvider,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color accentBlue,
    bool isDark,
  ) {
    final presets = [
      {'label': 'Recent 1-Year Delta', 'y1': 2022, 'y2': 2023},
      {'label': '5-Year Climate Shift', 'y1': 2018, 'y2': 2023},
      {'label': '10-Year Decadal Change', 'y1': 2013, 'y2': 2023},
      {'label': 'Millennium Baseline', 'y1': 2000, 'y2': 2023},
      {'label': '30-Year Normal Comparison', 'y1': 1993, 'y2': 2023},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Comparison Years',
                    style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Choose a historical comparison window to evaluate climate anomalies and rainfall shifts:',
                style: TextStyle(color: textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              ...presets.map((p) {
                final y1 = p['y1'] as int;
                final y2 = p['y2'] as int;
                final isSelected = climateProvider.year1 == y1 && climateProvider.year2 == y2;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      climateProvider.setYears(
                        y1,
                        y2,
                        lat: weatherProvider.latitude,
                        lon: weatherProvider.longitude,
                        locName: weatherProvider.locationName,
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? accentBlue.withValues(alpha: 0.12) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? accentBlue : borderColor,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p['label'] as String,
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                ),
                              ),
                              Text(
                                '$y1 vs $y2',
                                style: TextStyle(color: accentBlue, fontSize: 11.5, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle_rounded, color: accentBlue, size: 18),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final climateProvider = Provider.of<ClimateProvider>(context);
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    final surfaceColor = AppColors.surface(isDark);
    final borderColor = AppColors.border(isDark);
    final textPrimary = AppColors.textPrimaryC(isDark);
    final textSecondary = AppColors.textSecondaryC(isDark);
    final textTertiary = AppColors.textTertiaryC(isDark);
    final accentBlue = isDark ? AppColors.brandBlueLight : AppColors.brandBlue;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localeProvider.t('climate'),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            Text(
              'Historical Trends & Climate Intelligence',
              style: TextStyle(fontSize: 11, color: textTertiary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Climate Records',
            onPressed: climateProvider.isLoading
                ? null
                : () {
                    climateProvider.fetchClimateData(
                      latitude: weatherProvider.latitude,
                      longitude: weatherProvider.longitude,
                      locationName: weatherProvider.locationName,
                    );
                  },
          ),
        ],
      ),
      body: climateProvider.isLoading && climateProvider.comparison == null
          ? Center(child: SpinKitPulse(color: accentBlue, size: 50))
          : climateProvider.comparison != null
              ? Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: RefreshIndicator(
                      onRefresh: () => climateProvider.fetchClimateData(
                        latitude: weatherProvider.latitude,
                        longitude: weatherProvider.longitude,
                        locationName: weatherProvider.locationName,
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Offline Cache Banner if loaded from local cache
                            if (climateProvider.comparison!.isOfflineCached) ...[
                              Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.alertYellow.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.alertYellow.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.cloud_off_rounded, size: 16, color: AppColors.alertYellow),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Offline Cached Archive Records (Reconnecting to refresh)',
                                        style: TextStyle(color: textPrimary, fontSize: 11.5, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Location & Interactive Year Selector Card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderColor, width: 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          weatherProvider.locationName,
                                          style: TextStyle(
                                            color: textPrimary,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () => _showYearSelector(
                                          context,
                                          climateProvider,
                                          weatherProvider,
                                          surfaceColor,
                                          borderColor,
                                          textPrimary,
                                          textSecondary,
                                          accentBlue,
                                          isDark,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: accentBlue.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: accentBlue.withValues(alpha: 0.4), width: 1),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${climateProvider.year1} vs ${climateProvider.year2}',
                                                style: TextStyle(
                                                  color: accentBlue,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(Icons.arrow_drop_down_rounded, color: accentBlue, size: 18),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    climateProvider.comparison!.climateSummary,
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 13,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // IMD Sub-Divisional Monsoon & Oceanic Teleconnections Hub
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    accentBlue.withValues(alpha: 0.18),
                                    surfaceColor,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: accentBlue.withValues(alpha: 0.4), width: 1.2),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: accentBlue.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.cyclone_rounded, color: accentBlue, size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Monsoon Teleconnections & LRF',
                                              style: TextStyle(
                                                color: textPrimary,
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'IMD 36',
                                                style: TextStyle(color: Colors.greenAccent, fontSize: 9.5, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Oceanic drivers (ENSO Niño 3.4, IOD, MJO) & 36 sub-divisional rainfall departures.',
                                          style: TextStyle(color: textSecondary, fontSize: 11.5, height: 1.3),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => MonsoonTeleconnectionsScreen(
                                            initialLat: weatherProvider.latitude,
                                            initialLon: weatherProvider.longitude,
                                            initialLocationName: weatherProvider.locationName,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accentBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      visualDensity: VisualDensity.compact,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: const Text('Explore', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Anomaly Comparison Cards
                            Row(
                              children: [
                                Expanded(
                                  child: _buildAnomalyCard(
                                    label: 'Rainfall Change',
                                    value:
                                        '${climateProvider.comparison!.rainfallDifferenceMm > 0 ? "+" : ""}${climateProvider.comparison!.rainfallDifferenceMm.toStringAsFixed(1)} mm',
                                    sub:
                                        '(${climateProvider.comparison!.rainfallChangePercent > 0 ? "+" : ""}${climateProvider.comparison!.rainfallChangePercent.toStringAsFixed(1)}%)',
                                    valueColor: climateProvider.comparison!.rainfallDifferenceMm >= 0
                                        ? accentBlue
                                        : AppColors.alertOrange,
                                    surfaceColor: surfaceColor,
                                    borderColor: borderColor,
                                    textSecondary: textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildAnomalyCard(
                                    label: 'Mean Temp Diff',
                                    value:
                                        '${climateProvider.comparison!.temperatureDifferenceC > 0 ? "+" : ""}${climateProvider.comparison!.temperatureDifferenceC.toStringAsFixed(2)} °C',
                                    sub: 'Year-on-year anomaly',
                                    valueColor: climateProvider.comparison!.temperatureDifferenceC > 0
                                        ? AppColors.alertOrange
                                        : accentBlue,
                                    surfaceColor: surfaceColor,
                                    borderColor: borderColor,
                                    textSecondary: textSecondary,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Monthly Rainfall Bar Chart with Dynamic Scaling
                            _buildMonthlyRainfallChart(
                              climateProvider,
                              surfaceColor,
                              borderColor,
                              textPrimary,
                              textSecondary,
                              textTertiary,
                              accentBlue,
                            ),

                            const SizedBox(height: 16),

                            // Multi-Year Trend Chart & Description
                            if (climateProvider.trends != null) ...[
                              _buildLongTermTrendCard(
                                climateProvider,
                                surfaceColor,
                                borderColor,
                                textPrimary,
                                textSecondary,
                                textTertiary,
                                accentBlue,
                                isDark,
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Provenance Footer
                            Center(
                              child: Text(
                                'Data Source: Open-Meteo Historical Weather API (ERA5 Reanalysis Archive)\nBaseline reference period 1991-2020 WMO standard normals.',
                                style: TextStyle(color: textTertiary, fontSize: 10.5, height: 1.4),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : _buildUnavailableState(
                  surfaceColor,
                  borderColor,
                  textPrimary,
                  textSecondary,
                  accentBlue,
                  weatherProvider,
                  climateProvider,
                ),
    );
  }

  Widget _buildMonthlyRainfallChart(
    ClimateProvider climateProvider,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color textTertiary,
    Color accentBlue,
  ) {
    // Dynamically calculate chart max Y to avoid overflow/clipping during intense monsoons
    double maxMonthRain = 50.0;
    for (final s in climateProvider.comparison!.year1Stats.monthlyStats) {
      if (s.totalRainfallMm > maxMonthRain) maxMonthRain = s.totalRainfallMm;
    }
    for (final s in climateProvider.comparison!.year2Stats.monthlyStats) {
      if (s.totalRainfallMm > maxMonthRain) maxMonthRain = s.totalRainfallMm;
    }
    final dynamicMaxY = max(100.0, (maxMonthRain * 1.2).ceilToDouble());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Rainfall Distribution',
                style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
              ),
              Row(
                children: [
                  _buildLegend(AppColors.brandBlueDark, '${climateProvider.year1}', textSecondary),
                  const SizedBox(width: 12),
                  _buildLegend(accentBlue, '${climateProvider.year2}', textSecondary),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: dynamicMaxY,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                        final idx = val.toInt();
                        if (idx >= 0 && idx < months.length) {
                          return Text(months[idx], style: TextStyle(color: textTertiary, fontSize: 10));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: borderColor,
                    strokeWidth: 0.8,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(12, (i) {
                  final y1 = (i < climateProvider.comparison!.year1Stats.monthlyStats.length)
                      ? climateProvider.comparison!.year1Stats.monthlyStats[i].totalRainfallMm
                      : 0.0;
                  final y2 = (i < climateProvider.comparison!.year2Stats.monthlyStats.length)
                      ? climateProvider.comparison!.year2Stats.monthlyStats[i].totalRainfallMm
                      : 0.0;

                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: y1,
                        color: AppColors.brandBlueDark,
                        width: 7,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                      ),
                      BarChartRodData(
                        toY: y2,
                        color: accentBlue,
                        width: 7,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLongTermTrendCard(
    ClimateProvider climateProvider,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color textTertiary,
    Color accentBlue,
    bool isDark,
  ) {
    final trends = climateProvider.trends!;
    final stats = trends.multiYearStats;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up_rounded, color: AppColors.alertOrange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Multi-Year Climate Warming Trend',
                style: TextStyle(color: textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            trends.trendDescription,
            style: TextStyle(color: textSecondary, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.alertOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.alertOrange.withValues(alpha: 0.3)),
            ),
            child: Text(
              'Warming Rate: +${trends.warmingTrendCPerDecade.toStringAsFixed(2)} °C per decade',
              style: const TextStyle(color: AppColors.alertOrange, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
          if (stats.length >= 3) ...[
            const SizedBox(height: 18),
            Text(
              'Annual Mean Temperature Trend (${trends.startYear} - ${trends.endYear})',
              style: TextStyle(color: textPrimary, fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (val) => FlLine(color: borderColor, strokeWidth: 0.8),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          final idx = val.toInt();
                          if (idx >= 0 && idx < stats.length) {
                            return Text(
                              '\'${stats[idx].year.toString().substring(2)}',
                              style: TextStyle(color: textTertiary, fontSize: 10),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(stats.length, (i) {
                        return FlSpot(i.toDouble(), stats[i].annualMeanTempC);
                      }),
                      isCurved: true,
                      color: AppColors.alertOrange,
                      barWidth: 2.5,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                          radius: 3,
                          color: AppColors.alertOrange,
                          strokeColor: surfaceColor,
                          strokeWidth: 1.5,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.alertOrange.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUnavailableState(
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    Color accentBlue,
    WeatherProvider weatherProvider,
    ClimateProvider climateProvider,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.alertOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.history_toggle_off_rounded, color: AppColors.alertOrange, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                'Historical Climate Records Unavailable',
                style: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Unable to reach Open-Meteo ERA5 reanalysis archive servers. Connect to internet to retrieve historical climate anomaly trends.',
                style: TextStyle(color: textSecondary, fontSize: 13, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  climateProvider.fetchClimateData(
                    latitude: weatherProvider.latitude,
                    longitude: weatherProvider.longitude,
                    locationName: weatherProvider.locationName,
                  );
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry Archive Connection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnomalyCard({
    required String label,
    required String value,
    required String sub,
    required Color valueColor,
    required Color surfaceColor,
    required Color borderColor,
    required Color textSecondary,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: valueColor, fontSize: 17, fontWeight: FontWeight.w800)),
          Text(sub, style: TextStyle(color: valueColor.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label, Color textSecondary) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: textSecondary, fontSize: 11)),
      ],
    );
  }
}
